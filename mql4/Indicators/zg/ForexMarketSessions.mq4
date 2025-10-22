//+------------------------------------------------------------------+
//|                  ForexMarketSessions.mq4                  |
//|     六大外汇市场时段 + 自动夏令时 + 当前市场状态面板 |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window

//──────────────────────────────────────────────
// 参数
//──────────────────────────────────────────────
input bool   ShowLabels   = true;
input bool   ShowBoxes    = true;
input bool   ShowStatusPanel = true;
input double BoxHeightPct = 0.015;

// 市场配色
color clrSydney    = clrDeepSkyBlue;
color clrTokyo     = clrTomato;
color clrHongKong  = clrGold;
color clrFrankfurt = clrOrange;
color clrLondon    = clrLimeGreen;
color clrNewYork   = clrViolet;
color clrOverlap   = clrWhite;

//──────────────────────────────────────────────
struct Session
{
   string name;
   double openUTC;
   double closeUTC;
   color  col;
   bool   dstEurope;
   bool   dstUS;
   bool   dstAU;
   bool   isOpen;
};

Session sessions[];

//──────────────────────────────────────────────
// DST 辅助函数
//──────────────────────────────────────────────
datetime NthWeekdayOfMonth(int year, int month, int weekday, int nth)
{
   datetime t = StrToTime(StringFormat("%04d.%02d.01 00:00", year, month));
   int dayOfWeek = TimeDayOfWeek(t);
   int delta = (weekday - dayOfWeek + 7) % 7 + (nth - 1) * 7;
   return (t + delta * 86400);
}

bool IsDST_US(datetime t)
{
   int y = TimeYear(t);
   datetime start = NthWeekdayOfMonth(y, 3, 0, 2);
   datetime end   = NthWeekdayOfMonth(y, 11, 0, 1);
   return (t >= start && t < end);
}

bool IsDST_Europe(datetime t)
{
   int y = TimeYear(t);
   datetime start = NthWeekdayOfMonth(y, 3, 0, 5);
   datetime end   = NthWeekdayOfMonth(y, 10, 0, 5);
   return (t >= start && t < end);
}

bool IsDST_Australia(datetime t)
{
   int y = TimeYear(t);
   datetime start = NthWeekdayOfMonth(y, 10, 0, 1);
   datetime end   = NthWeekdayOfMonth(y + 1, 4, 0, 1);
   return (t >= start || t < end);
}

//──────────────────────────────────────────────
// 初始化
//──────────────────────────────────────────────
int OnInit()
{
   ArrayResize(sessions,6);

   //sessions[0].name="Sydney (澳洲)";
   sessions[0].name="Sydney";
   sessions[0].openUTC=22; sessions[0].closeUTC=7;
   sessions[0].col=clrSydney; sessions[0].dstAU=true;

   //sessions[1].name="Tokyo (东京)";
   sessions[1].name="Tokyo";
   sessions[1].openUTC=0; sessions[1].closeUTC=9;
   sessions[1].col=clrTokyo;

   //sessions[2].name="Hong Kong (香港)";
   sessions[2].name="HongKong";
   sessions[2].openUTC=1; sessions[2].closeUTC=10;
   sessions[2].col=clrHongKong;

   //sessions[3].name="Frankfurt (德国)";
   sessions[3].name="Frankfurt";
   sessions[3].openUTC=7; sessions[3].closeUTC=16;
   sessions[3].col=clrFrankfurt; sessions[3].dstEurope=true;

   //sessions[4].name="London (英国)";
   sessions[4].name="London";
   sessions[4].openUTC=8; sessions[4].closeUTC=17;
   sessions[4].col=clrLondon; sessions[4].dstEurope=true;

   //sessions[5].name="New York (美国)";
   sessions[5].name="NewYork";
   sessions[5].openUTC=13; sessions[5].closeUTC=22;
   sessions[5].col=clrNewYork; sessions[5].dstUS=true;

   DrawSessions();
   EventSetTimer(60);  // 每分钟刷新状态
   return(INIT_SUCCEEDED);
}

//──────────────────────────────────────────────
// 绘制市场时间段
//──────────────────────────────────────────────
void DrawSessions()
{
   ObjectsDeleteAll(0, "SESSION_");

   datetime now = TimeCurrent();
   //datetime today = iTime(NULL, PERIOD_D1, 0);
   //dayStart = today;
   // 先计算 UTC 当天午夜
   datetime utcNow = TimeGMT();
   // "YYYY.MM.DD"
   string utcDateStr = TimeToString(utcNow, TIME_DATE);
   // 当天 UTC 午夜
   datetime utcToday = StrToTime(utcDateStr + " 00:00");
   int brokerOffset = (int)(TimeCurrent() - TimeGMT());

   double priceMin = WindowPriceMin();
   double priceMax = WindowPriceMax();
   double h = (priceMax - priceMin) * BoxHeightPct;
   double yBottom = priceMin + h;

   bool dstUS = IsDST_US(now);
   bool dstEU = IsDST_Europe(now);
   bool dstAU = IsDST_Australia(now);

   for(int i=0;i<ArraySize(sessions);i++)
   {
      double openUTC = sessions[i].openUTC;
      double closeUTC = sessions[i].closeUTC;

      // 应用 DST 调整
      if (sessions[i].dstUS && dstUS) { openUTC -= 1; closeUTC -= 1; }
      if (sessions[i].dstEurope && dstEU) { openUTC -= 1; closeUTC -= 1; }
      if (sessions[i].dstAU && dstAU) { openUTC -= 1; closeUTC -= 1; }

      // 计算该 session 在 UTC 的 open/close 时间（基于 utcToday）
      datetime openT_utc  = utcToday + (int)(openUTC * 3600.0);
      datetime closeT_utc = utcToday + (int)(closeUTC * 3600.0);
      
      // // 若跨午夜（例如 open 22:00, close 07:00），则 openT_utc 可能在 closeT_utc 之后
      // 把 open 移到前一天，保证 open < close
      if(openT_utc > closeT_utc)
          openT_utc -= 86400;   // open 前移一天
      
      // 现在把 UTC 时间转换到经纪商/图表时间，用于绘图    
      //datetime openT = dayStart + (int)((openUTC*3600) + brokerOffset);
      //datetime closeT = dayStart + (int)((closeUTC*3600) + brokerOffset);
      datetime openT  = openT_utc  + brokerOffset;
      datetime closeT = closeT_utc + brokerOffset;
      
      // 如果你仍想保证 closeT > openT（多余保险）
      //if (closeT < openT) closeT += 86400;
      if(closeT <= openT) closeT += 86400;

      // sessions[i].isOpen 判断（用图表当前时间 TimeCurrent()）
      sessions[i].isOpen = (TimeCurrent() >= openT && TimeCurrent() < closeT);
      // 保存状态
      //sessions[i].isOpen = (now >= openT && now < closeT);

      string rectName = "SESSION_BOX_"+IntegerToString(i);
      if (ShowBoxes)
      {  double y1 = yBottom + h * i;
         double y2 = yBottom + h * (i + 1);
         if(ObjectFind(0, rectName) < 0)
             ObjectCreate(0, rectName, OBJ_RECTANGLE, 0, openT, y1, closeT, y2);
         else {
             ObjectMove(0, rectName, 0, openT, y1);
             ObjectMove(0, rectName, 1, closeT, y2);
         }
         ObjectSetInteger(0, rectName, OBJPROP_COLOR, sessions[i].col);
         ObjectSetInteger(0, rectName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, rectName, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, rectName, OBJPROP_BACK, true);
         ObjectSetInteger(0, rectName, OBJPROP_FILL, true);
      }

      if (ShowLabels)
      {
         string lbl = "SESSION_LABEL_"+IntegerToString(i);
         //ObjectCreate(0,lbl,OBJ_TEXT,0,openT+5*60,yBottom + h*(i+3) + (i%2)*h*0.3);
         if(ObjectFind(0, lbl) < 0)
             ObjectCreate(0,lbl,OBJ_TEXT,0,openT+5*60,yBottom + h*(i+2));
         else 
             ObjectMove(0, lbl, 0, openT+5*60, yBottom + h*(i+2));
         ObjectSetString(0,lbl,OBJPROP_TEXT,sessions[i].name);
         ObjectSetInteger(0,lbl,OBJPROP_COLOR,sessions[i].col);
         ObjectSetInteger(0,lbl,OBJPROP_FONTSIZE,8);
         ObjectSetInteger(0, lbl, OBJPROP_ANCHOR, ANCHOR_LEFT);
         ObjectSetInteger(0,lbl,OBJPROP_BACK,true);
         ObjectSetInteger(0,lbl,OBJPROP_HIDDEN,true);
      }
   }

   if (ShowStatusPanel) DrawStatusPanel();
}

//──────────────────────────────────────────────
// 当前市场状态面板（带重叠提示）
//──────────────────────────────────────────────
void DrawStatusPanel()
{/*
   string panelName = "SESSION_STATUS";
   //string text = "📊 当前市场状态：\n";
   string text = "Current Market Status:\n";
   string openList = "";

   for(int i=0;i<ArraySize(sessions);i++)
   {
      //string mark = sessions[i].isOpen ? "🟢 开市" : "⚫ 休市";
      string mark = sessions[i].isOpen ? "Open" : "Closed";
      text += sessions[i].name + " - " + mark + "\n";
      if (sessions[i].isOpen)
      {
         if (openList != "") openList += " + ";
         openList += sessions[i].name;
      }
   }

   if (openList == "")
      //text += "\n当前无市场开市";
      text += "\nNo markets are currently open";
   else if (StringFind(openList," + ")>=0)
      //text += "\n🔥 当前重叠市场：\n" + openList;
      text += "\nCurrently Overlapping Markets:\n" + openList;
   else
      //text += "\n当前活跃市场：\n" + openList;
      text += "\nCurrently Active Market:\n" + openList;

   if(ObjectFind(0,panelName)<0)
      ObjectCreate(0,panelName,OBJ_LABEL,0,0,0);

   //ObjectSetInteger(0,panelName,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,panelName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,panelName,OBJPROP_XDISTANCE,15);
   ObjectSetInteger(0,panelName,OBJPROP_YDISTANCE,20);
   ObjectSetString(0,panelName,OBJPROP_TEXT,text);
   ObjectSetInteger(0,panelName,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,panelName,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,panelName,OBJPROP_FONT,"Consolas");
   ObjectSetInteger(0,panelName,OBJPROP_BACK,false);
   */
    //string text = "Current Market Status:\n";
    string text = "";
    string openList = "";

    for(int i=0; i<ArraySize(sessions); i++)
    {
        //string mark = sessions[i].isOpen ? "[O] Open" : "[ ] Closed";
        //text += sessions[i].name + " - " + mark + "\n";

        if (sessions[i].isOpen)
        {
            if (openList != "") openList += " + ";
            openList += sessions[i].name;
        }
    }

    if (openList == "")
        text += "\nNo markets are currently open";
    else if (StringFind(openList, " + ") >= 0)
        text += "\n!!! Currently Overlapping Markets: " + openList;
    else
        text += "\nCurrently Active Market: " + openList;

    // 使用 Comment 显示
    Comment(text);
}

//──────────────────────────────────────────────
void OnTimer()
{
   DrawSessions();
}

//──────────────────────────────────────────────
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, "SESSION_");
   ObjectDelete(0,"SESSION_STATUS");
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {return(rates_total);}
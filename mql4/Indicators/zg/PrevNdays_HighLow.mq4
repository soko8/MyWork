//+------------------------------------------------------------------+
//| Prev3Days_HighLow.mq4                                          |
//| 描述: 在任意图表上绘制前 N 天（默认 3 天）的每日最高点与最低点，自动重绘（每日刷新）|
//| 用法: 将文件放入 MQL4/Indicators，编译后附加到任意品种任意周期图表         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property strict

// 要显示的过去天数（1..10）
input int    __DaysToShow = 3;
// 线是否向右延伸
input bool   ExtendToRight = false;
// 线宽
input int    LineWidth = 1;
// 可按需修改（若DaysToShow>3则循环使用）
color  HighColors[3] = {clrRed, clrOrange, clrMagenta};
color  LowColors[3]  = {clrBlue, clrAqua, clrGreen};

string objPrefix = "P3DH_";
string objPrefixL = "P3DL_";

// 上次刷新日期
datetime lastRefresh = 0;

int DaysToShow;

//+------------------------------------------------------------------+
int OnInit()
  {
   DaysToShow = __DaysToShow;
   if(DaysToShow<1) DaysToShow=1;
   // 防止过多
   if(DaysToShow>10) DaysToShow=10;

   // 首次创建/刷新
   RefreshLines();

   // 每分钟检查一次是否跨日
   EventSetTimer(60);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   // 可选删除对象
   DeleteAllObjects();
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   datetime curDay = iTime(NULL, PERIOD_D1, 0);
   if(curDay != lastRefresh)
     {
      RefreshLines();
      lastRefresh = curDay;
     }
  }

//+------------------------------------------------------------------+
void RefreshLines()
  {
   for(int j=1;j<=DaysToShow;j++)
     {
      // 数据不足则跳过
      if(iBars(NULL,PERIOD_D1)<=j) continue;

      double ph = iHigh(NULL,PERIOD_D1,j);
      double pl = iLow(NULL,PERIOD_D1,j);
      datetime tStart = iTime(NULL,PERIOD_D1,j);
      datetime tEnd   = (j==1 ? iTime(NULL,PERIOD_D1,0) : iTime(NULL,PERIOD_D1,j-1));

      if(ExtendToRight)
         tEnd = TimeCurrent(); // 向右延伸到当前时间

      string dateCode = TimeToString(tStart,TIME_DATE);
      string nameH = objPrefix + IntegerToString(j) + "_" + dateCode;
      string nameL = objPrefixL + IntegerToString(j) + "_" + dateCode;

      CreateOrUpdateTrendLine(nameH, tStart, tEnd, ph, GetColorFromArray(HighColors,j-1));
      CreateOrUpdateTrendLine(nameL, tStart, tEnd, pl, GetColorFromArray(LowColors,j-1));
     }

   CleanupOldObjects();
   ChartRedraw();
   lastRefresh = iTime(NULL, PERIOD_D1, 0);
  }

//+------------------------------------------------------------------+
void CreateOrUpdateTrendLine(string name, datetime t1, datetime t2, double price, color col)
  {
   if(ObjectFind(0,name) < 0)
     {
      if(!ObjectCreate(0,name,OBJ_TREND,0,t1,price,t2,price))
         Print("创建失败: ", name);
     }
   else
     {
      ObjectSetInteger(0,name,OBJPROP_TIME1,t1);
      ObjectSetInteger(0,name,OBJPROP_TIME2,t2);
      ObjectSetDouble(0,name,OBJPROP_PRICE1,price);
      ObjectSetDouble(0,name,OBJPROP_PRICE2,price);
     }

   ObjectSetInteger(0,name,OBJPROP_WIDTH,LineWidth);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_COLOR,col);
   ObjectSetInteger(0,name,OBJPROP_RAY,false); // 不无限延伸
  }

//+------------------------------------------------------------------+
color GetColorFromArray(color &arr[],int idx)
  {
   int len = ArraySize(arr);
   if(len==0) return clrWhite;
   return arr[idx % len];
  }

//+------------------------------------------------------------------+
void CleanupOldObjects()
  {
   int total = ObjectsTotal();
   for(int i=total-1;i>=0;i--)
     {
      string name = ObjectName(0,i);
      if(StringFind(name,objPrefix,0)>=0 || StringFind(name,objPrefixL,0)>=0)
        {
         int underscore = StringFind(name,"_",0);
         if(underscore>StringLen(objPrefix))
           {
            string idxStr = StringSubstr(name, StringLen(objPrefix), underscore-StringLen(objPrefix));
            int idx = (int) StringToInteger(idxStr);
            if(idx>DaysToShow) ObjectDelete(0,name);
           }
        }
     }
  }

//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int total = ObjectsTotal();
   for(int i=total-1;i>=0;i--)
     {
      string name = ObjectName(0,i);
      if(StringFind(name,objPrefix,0)>=0 || StringFind(name,objPrefixL,0)>=0)
         ObjectDelete(0,name);
     }
  }


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
// End of file
//+------------------------------------------------------------------+

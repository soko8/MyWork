//+------------------------------------------------------------------+
//|                                         SymbolChanger_v4_fixed.mq4|
//| 图表品种切换器（自动换行 + 高亮 + Hover + 半透明）by GPT-5       |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property strict

//=== 输入参数 ===
//input string Symbols      = "EURUSD,USDJPY,GBPUSD,AUDUSD,USDCAD,USDCHF,NZDUSD,EURJPY,EURCAD,GBPJPY";
input string Symbols      = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY,CNHJPY,USDCNH,XAGUSD,XAUUSD,XNGUSD,XTIUSD,ETHUSD,JP225";
int    ButtonWidth  = 54;
int    ButtonHeight = 16;
input int    Spacing      = 3;
input int    Corner       = 1;
input int    X_Offset     = 58;
input int    Y_Offset     = 2;
input color  ButtonColor  = clrDodgerBlue;
input color  ActiveColor  = clrLimeGreen;
input color  HoverColor   = clrDeepSkyBlue;
input color  TextColor    = clrWhite;
input double Transparency = 0.4;   // 0~1 越大越“透明”

//=== 全局变量 ===
string prefix = "SC_";
string symbols[];
int count = 0;
int hoveredIndex = -1;  // 当前鼠标悬停的按钮索引

//+------------------------------------------------------------------+
int OnInit()
{
   ObjectsDeleteAll(0, prefix);
   count = StringSplit(Symbols, ',', symbols);
   if(count <= 0)
   {
      Print("❌ 无效的符号列表，请检查输入参数 Symbols");
      return(INIT_FAILED);
   }

   CreateButtons();
   ChartRedraw();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, prefix);
}

//+------------------------------------------------------------------+
//| 创建按钮并自动多行布局                                           |
//+------------------------------------------------------------------+
void CreateButtons()
{
   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   //int perRow = MathMax(1, (chartWidth - X_Offset) / (ButtonWidth + Spacing));

   for(int i = 0; i < count; i++)
   {
      string s = StringTrimCustom(symbols[i]);
      string name = prefix + s;

      //int row = i / perRow;
      //int col = i % perRow;

      //int x = X_Offset + col * (ButtonWidth + Spacing);
      //int y = Y_Offset + row * (ButtonHeight + Spacing);
      
      // 竖直排列（靠右）
      int x = X_Offset;  // 因为Corner=1，X_Offset表示离右边距离
      int y = Y_Offset + i * (ButtonHeight + Spacing);

      color bg = (s == Symbol()) ? ActiveColor : ButtonColor;
      bg = MakeTransparent(bg, Transparency);

      // --- 背景矩形
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, ButtonWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, ButtonHeight);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);

      // --- 文本层
      string lbl = name + "_txt";
      if(ObjectFind(0, lbl) < 0)
         ObjectCreate(0, lbl, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, lbl, OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, lbl, OBJPROP_XDISTANCE, x + ButtonWidth/2 - 30);
      ObjectSetInteger(0, lbl, OBJPROP_YDISTANCE, y + 1);
      ObjectSetString(0, lbl, OBJPROP_TEXT, s);
      ObjectSetInteger(0, lbl, OBJPROP_FONTSIZE, 6);
      ObjectSetInteger(0, lbl, OBJPROP_COLOR, TextColor);
      ObjectSetInteger(0, lbl, OBJPROP_HIDDEN, true);
   }
}

//+------------------------------------------------------------------+
//| 统一响应鼠标相关事件（点击与移动）                                |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &l, const double &d, const string &s)
{
   // 鼠标移动 —— 更新 hoveredIndex（使用 l/d 作为像素坐标）
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int mx = (int)l;
      int my = (int)d;
      int newHover = -1;

      for(int i = 0; i < count; i++)
      {
         string sym = StringTrimCustom(symbols[i]);
         string name = prefix + sym;
         int x = ObjectGetInteger(0, name, OBJPROP_XDISTANCE);
         int y = ObjectGetInteger(0, name, OBJPROP_YDISTANCE);
         int w = ObjectGetInteger(0, name, OBJPROP_XSIZE);
         int h = ObjectGetInteger(0, name, OBJPROP_YSIZE);

         if(PointInRect(mx, my, Corner, x, y, w, h))
         {
            newHover = i;
            break;
         }
      }

      if(newHover != hoveredIndex)
      {
         hoveredIndex = newHover;
         UpdateHighlight();
      }
      return;
   }

   // 点击事件 —— 检查是否点击按钮并切换
   if(id == CHARTEVENT_CLICK || id == CHARTEVENT_OBJECT_CLICK)
   {
      int mx = (int)l;
      int my = (int)d;

      for(int i = 0; i < count; i++)
      {
         string sym = StringTrimCustom(symbols[i]);
         string name = prefix + sym;

         if(PointInRect(mx, my, Corner,
                        ObjectGetInteger(0, name, OBJPROP_XDISTANCE),
                        ObjectGetInteger(0, name, OBJPROP_YDISTANCE),
                        ObjectGetInteger(0, name, OBJPROP_XSIZE),
                        ObjectGetInteger(0, name, OBJPROP_YSIZE)))
         {
            if(Symbol() != sym)
            {
               ChartSetSymbolPeriod(0, sym, PERIOD_CURRENT);
               // 切换后重建或更新颜色
               hoveredIndex = -1;
               UpdateHighlight();
            }
            break;
         }
      }
      return;
   }
}

//+------------------------------------------------------------------+
//| 更新按钮颜色（含高亮与Hover）                                     |
//+------------------------------------------------------------------+
void UpdateHighlight()
{
   for(int i = 0; i < count; i++)
   {
      string sym = StringTrimCustom(symbols[i]);
      string name = prefix + sym;
      color bg;

      if(i == hoveredIndex && sym != Symbol())
         bg = HoverColor;
      else if(sym == Symbol())
         bg = ActiveColor;
      else
         bg = ButtonColor;

      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, MakeTransparent(bg, Transparency));
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| 工具函数：去空格                                                 |
//+------------------------------------------------------------------+
string StringTrimCustom(string s)
{
   int start = 0;
   int end = StringLen(s) - 1;
   while(start <= end && StringGetChar(s, start) == ' ') start++;
   while(end >= start && StringGetChar(s, end) == ' ') end--;
   if(end < start) return "";
   return StringSubstr(s, start, end - start + 1);
}

//+------------------------------------------------------------------+
//| 工具函数：颜色提取 / 合成                                         |
//+------------------------------------------------------------------+
int GetRValue(color c){ return (c & 0x0000FF); }
int GetGValue(color c){ return ((c >> 8) & 0x0000FF); }
int GetBValue(color c){ return ((c >> 16) & 0x0000FF); }
color RGB(int r,int g,int b){ return (color)((r&0xFF)|((g&0xFF)<<8)|((b&0xFF)<<16)); }

//+------------------------------------------------------------------+
//| 模拟半透明                                                       |
//+------------------------------------------------------------------+
color MakeTransparent(color c,double alpha)
{
   int r=(int)(GetRValue(c)*(1-alpha)+255*alpha);
   int g=(int)(GetGValue(c)*(1-alpha)+255*alpha);
   int b=(int)(GetBValue(c)*(1-alpha)+255*alpha);
   return RGB(r,g,b);
}

//+------------------------------------------------------------------+
//| 判断鼠标是否在矩形范围                                           |
//+------------------------------------------------------------------+
bool PointInRect(int mx,int my,int corner,int x,int y,int w,int h)
{
   int cw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int ch=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   int left,top;
   switch(corner)
   {
      case 0: left=x; top=y; break;
      case 1: left=cw-x-w; top=y; break;
      case 2: left=x; top=ch-y-h; break;
      case 3: left=cw-x-w; top=ch-y-h; break;
      default:left=x; top=y;
   }
   return(mx>=left && mx<=left+w && my>=top && my<=top+h);
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
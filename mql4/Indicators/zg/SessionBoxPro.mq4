#property indicator_chart_window
#property indicator_buffers 0

extern int DaysToDraw = 5;
extern bool TransparentBackground = false;

int GMTOffsetHours = 0;

int OnInit() {
   GMTOffsetHours = GetServerGMTOffsetHours();
   return(INIT_SUCCEEDED);
}

int GetServerGMTOffsetHours() {
   return (int)((TimeCurrent() - TimeGMT()) / 3600);
}

bool IsLondonDST(datetime t) {
   int year = TimeYear(t);
   datetime start = GetLastSunday(year, 3);
   datetime end   = GetLastSunday(year, 10);
   return (t >= start && t < end);
}

bool IsNewYorkDST(datetime t) {
   int year = TimeYear(t);
   datetime start = GetSecondSunday(year, 3);
   datetime end   = GetFirstSunday(year, 11);
   return (t >= start && t < end);
}

datetime GetLastSunday(int year, int month) {
   for (int d = 31; d >= 1; d--) {
      datetime dt = StrToTime(year + "." + month + "." + d + " 00:00");
      if (TimeDayOfWeek(dt) == 0) return dt;
   }
   return 0;
}

datetime GetSecondSunday(int year, int month) {
   int count = 0;
   for (int d = 1; d <= 14; d++) {
      datetime dt = StrToTime(year + "." + month + "." + d + " 00:00");
      if (TimeDayOfWeek(dt) == 0 && ++count == 2) return dt;
   }
   return 0;
}

datetime GetFirstSunday(int year, int month) {
   for (int d = 1; d <= 7; d++) {
      datetime dt = StrToTime(year + "." + month + "." + d + " 00:00");
      if (TimeDayOfWeek(dt) == 0) return dt;
   }
   return 0;
}

datetime GetSessionTime(datetime day, int gmtHour) {
   return day + (gmtHour + GMTOffsetHours) * 3600;
}

double PriceOffsetByPixels(int pixels)
{
   // 当前主图的可视价格范围和高度
   double pmin = ChartGetDouble(0, CHART_PRICE_MIN);
   double pmax = ChartGetDouble(0, CHART_PRICE_MAX);
   int    hpx  = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

   if (hpx <= 0) return 0.0;
   double pricePerPixel = (pmax - pmin) / (double)hpx;
   return pricePerPixel * pixels;
}


void DrawSessionBox(string namePrefix, datetime startTime, datetime endTime, color boxColor, string labelText) {
   int startIndex = iBarShift(NULL, PERIOD_M1, startTime, false);
   int endIndex = iBarShift(NULL, PERIOD_M1, endTime, false);
   //int startIndex = iBarShift(NULL, PERIOD_M1, startTime, true);
   //int endIndex = iBarShift(NULL, PERIOD_M1, endTime, true);
   
   // 数据缺失
   /*
   if (startIndex < 0 || endIndex < 0) {
      Print("data missing: ", labelText, " ", TimeToStr(startTime));
      return; // 跳过绘制
   }
   */


   double high = -1e10, low = 1e10;
   for (int i = endIndex; i <= startIndex; i++) {
      high = MathMax(high, iHigh(NULL, PERIOD_M1, i));
      low  = MathMin(low, iLow(NULL, PERIOD_M1, i));
   }
//Print("high==", high, "  low==", low, "  (high - low)==", (high - low), "  (high - low)/_Point", (high - low)/_Point);
   double openPrice = iOpen(NULL, PERIOD_M1, startIndex);
   string dateStr = TimeToStr(startTime, TIME_DATE);
   string boxName = namePrefix + dateStr;
   string textName = boxName + "_label";
   string statName = boxName + "_stats";

   ObjectDelete(boxName);
   ObjectDelete(textName);
   ObjectDelete(statName);

   ObjectCreate(boxName, OBJ_RECTANGLE, 0, startTime, high, endTime, low);
   ObjectSetInteger(0, boxName, OBJPROP_COLOR, boxColor);
   //ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_SOLID);
   //ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DASH);
   //ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DOT);
   //ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DASHDOT);
   ObjectSetInteger(0, boxName, OBJPROP_STYLE, STYLE_DASHDOTDOT);
   ObjectSetInteger(0, boxName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, boxName, OBJPROP_BACK, TransparentBackground);

   // 获取当前图表缩放级别 (1~5)
   int scale = (int)ChartGetInteger(0, CHART_SCALE);
   // 根据缩放级别调整字体大小
   int fontSize = 8 + scale; // 缩放越大，字体越大
   
   double offset = PriceOffsetByPixels(20); // 例如 18 像素

   //string stats = StringFormat("%s O:%.2f H:%.2f L:%.2f R:%.2f", labelText, openPrice, high, low, high - low);
   int range = (high - low)/_Point;
   string stats = StringFormat("%s R:%d", labelText, range);
   ObjectCreate(statName, OBJ_TEXT, 0, startTime, high + offset);
   ObjectSetInteger(0, statName, OBJPROP_COLOR, boxColor);
   ObjectSetInteger(0, statName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, statName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, statName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetString(0, statName, OBJPROP_TEXT, stats);
}

void CleanupOldObjects() {
   datetime cutoffDay = iTime(NULL, PERIOD_D1, DaysToDraw - 1);
   int total = ObjectsTotal();
   for (int i = total - 1; i >= 0; i--) {
      string name = ObjectName(i);
      if (StringFind(name, "Asia_") == 0 || StringFind(name, "Europe_") == 0 || StringFind(name, "US_") == 0) {
         string dateStr = StringSubstr(name, StringFind(name, "_") + 1);
         datetime objDay = StrToTime(dateStr);
         if (objDay < cutoffDay) ObjectDelete(name);
      }
   }
}

void OnDeinit(const int reason) {
   int total = ObjectsTotal();
   for (int i = total - 1; i >= 0; i--) {
      string name = ObjectName(i);
      if (StringFind(name, "Asia_") == 0 || StringFind(name, "Europe_") == 0 || StringFind(name, "US_") == 0)
         ObjectDelete(name);
   }
}

/*


时间(GMT) →  0    2    4    6    8    10   12   14   16   18   20   22   24
              |----|----|----|----|----|----|----|----|----|----|----|----|

亚洲盘 (Tokyo)   ██████████
                 00:00 ──────── 09:00

欧洲盘 (London)                     ██████████
                                    08:00 ──────── 17:00

美盘 (New York)                               ██████████
                                               13:00 ──────── 22:00


- 亚盘（亚洲盘）：北京时间 06:00 – 14:00 （对应 GMT 00:00 – 08:00）
- 欧盘（欧洲盘）：北京时间 14:00 – 20:00 （对应 GMT 08:00 – 14:00，冬令时推迟一小时）
- 美盘（美洲盘）：北京时间 20:00 – 次日 05:00 （对应 GMT 14:00 – 23:00，冬令时推迟一小时）

- 亚洲盘 (Tokyo)：GMT 00:00 – 09:00
- 主导市场：东京、新加坡、香港
- 活跃货币对：USD/JPY、AUD/JPY、EUR/JPY

- 欧洲盘 (London)：GMT 08:00 – 17:00
- 主导市场：伦敦
- 活跃货币对：EUR/USD、GBP/USD、EUR/GBP
- GMT14:00 是欧洲盘与美盘的重叠开始，不是收盘。
- 正式收盘时间：GMT17:00（伦敦证券交易所 16:30 本地时间）。

开盘
1. 法兰克福市场
- 当地时间：09:00 开盘
- 对应 GMT：冬令时为 GMT08:00，夏令时为 GMT07:00
- 因此在夏令时期间，欧洲盘的“早盘”可能会被认为是 GMT07:00。
2. 伦敦市场
- 当地时间：08:00 开盘
- 对应 GMT：冬令时为 GMT08:00，夏令时为 GMT07:00
- 伦敦是全球外汇交易量最大的市场，所以多数人以伦敦开盘为欧洲盘的开始。


收盘
1. 欧洲盘的核心市场
- 伦敦证券交易所 (LSE)：当地时间 08:00–16:30
- 对应 GMT：08:00–16:30（全年固定）
- 因此收盘时间约为 GMT17:00（考虑到夏令时，GMT 与英国本地时间差异会变化）。
- 法兰克福证券交易所 (FWB)：当地时间 09:00–17:30
- 对应 GMT：08:00–16:30（电子盘更早开）
- 巴黎泛欧交易所 (Euronext)：与法兰克福基本同步。
2. 夏令时与冬令时的影响
- 欧洲采用夏令时（3月最后一个周日至10月最后一个周日）。
- 夏令时期间：伦敦时间比 GMT 快 1 小时 → 收盘约 GMT15:30–16:30。
- 冬令时期间：伦敦时间与 GMT 对齐 → 收盘约 GMT16:30–17:00。



- 美盘 (New York)：GMT 13:00 – 22:00
- 主导市场：纽约
- 活跃货币对：EUR/USD、USD/JPY、GBP/USD

- 美股/美盘标准时间：09:30–16:00 ET
- 换算 GMT：夏令时 13:30–20:00，冬令时 14:30–21:00
- 外汇习惯：美盘活跃时段常指 GMT13:00–17:00（欧美重叠），但完整美盘可到 GMT20:00–21:00


重叠时段
- 亚洲盘与欧洲盘重叠：GMT 08:00 – 09:00
- 欧洲盘与美盘重叠：GMT 13:00 – 17:00（波动最强）


*/
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   CleanupOldObjects();

   for (int i = 0; i < DaysToDraw; i++) {
      datetime day = iTime(NULL, PERIOD_D1, i);
      //Print("i=", i, "  day==", TimeToStr(day));

      // 悉尼开盘时间（GMT）
      //datetime asiaStart = GetSessionTime(day, -2);
      // 东京开盘时间（GMT）
      datetime asiaStart = GetSessionTime(day, 0);
      // 东京收盘时间（GMT）
      //datetime asiaEnd   = GetSessionTime(day, 6);
      // 香港，新加坡收盘时间（GMT）
      datetime asiaEnd   = GetSessionTime(day, 9);
      //datetime asiaEnd   = GetSessionTime(day, 8);
//Print("i=", i, "  day==", TimeToStr(day), " AsiaStart=", TimeToStr(asiaStart), " iBarShift=", iBarShift(NULL, PERIOD_M1, asiaStart, true));
      bool londonDST = IsLondonDST(day);
      int londonOpenGMT = londonDST ? 7 : 8;
      int londonCloseGMT = londonDST ? 15 : 16;
      //int londonCloseGMT = 17;
      datetime europeStart = GetSessionTime(day, londonOpenGMT);
      datetime europeEnd   = GetSessionTime(day, londonCloseGMT);

      bool nyDST = IsNewYorkDST(day);
      int nyOpenGMT = nyDST ? 12 : 13;
      //int nyOpenGMT = nyDST ? 13 : 14;
      int nyCloseGMT = nyDST ? 20 : 21;
      datetime usStart = GetSessionTime(day, nyOpenGMT);
      datetime usEnd   = GetSessionTime(day, nyCloseGMT);

      DrawSessionBox("Asia_", asiaStart, asiaEnd, clrDodgerBlue, "Asia");
      DrawSessionBox("Europe_", europeStart, europeEnd, clrMediumSeaGreen, "EU");
      DrawSessionBox("US_", usStart, usEnd, clrTomato, "US");
   }

   return(rates_total);
}


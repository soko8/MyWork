//+------------------------------------------------------------------+
//|                                              RangeStatistics.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Gao Zeng.QQ--183947281,mail--soko8@sina.com."
#property link      "https://www.mql5.com"
#property version   "1.02"
#property strict
//#property indicator_separate_window
#property indicator_chart_window

//--- input parameters
input    int                  BarNumber = 1250;
input    ENUM_TIMEFRAMES      TimeFrame = PERIOD_D1;
input    bool                 EURUSD_Show = true;
input    bool                 USDJPY_Show = true;
input    bool                 GBPUSD_Show = true;
input    bool                 AUDUSD_Show = true;
input    bool                 USDCHF_Show = true;
input    bool                 USDCAD_Show = true;
input    bool                 NZDUSD_Show = true;

input    bool                 XAUUSD_Show = true;
input    bool                 XAGUSD_Show = true;

input    bool                 EURJPY_Show = true;
input    bool                 EURGBP_Show = true;
input    bool                 EURAUD_Show = true;
input    bool                 EURCHF_Show = true;
input    bool                 EURCAD_Show = true;
input    bool                 EURNZD_Show = true;

input    bool                 GBPJPY_Show = true;
input    bool                 AUDJPY_Show = true;
input    bool                 CHFJPY_Show = true;
input    bool                 CADJPY_Show = true;
input    bool                 NZDJPY_Show = true;

input    bool                 GBPAUD_Show = true;
input    bool                 GBPCHF_Show = true;
input    bool                 GBPCAD_Show = true;
input    bool                 GBPNZD_Show = true;

input    bool                 AUDCHF_Show = true;
input    bool                 AUDCAD_Show = true;
input    bool                 AUDNZD_Show = true;

input    bool                 CADCHF_Show = true;
input    bool                 NZDCHF_Show = true;

input    bool                 NZDCAD_Show = true;

input    string               symbolPrefix = "";
input    string               symbolSuffix = "";


const    int                  HEADER_COUNT = 20;

const    string               btnNmSortAsc = "SortAsc";
const    string               btnNmSortDesc = "SortDesc";

const    string               rectNmSortValue = "RectSortValue";
const    string               textNmSortValue = "SortValue";

const    string               btnNmHeader = "HeaderBtn_";
const    string               btnNmSymbol = "Symbol_";

const    int                  RANGES[15][2] = {
                                               {0  , 25},
                                               {25 , 50},
                                               {50 , 75},
                                               {75 , 100},
                                               {100, 125},
                                               {125, 150},
                                               {150, 175},
                                               {175, 200},
                                               {200, 225},
                                               {225, 250},
                                               {250, 275},
                                               {275, 300},
                                               {300, 350},
                                               {350, 400},
                                               {400, 9999}
                                              };

const    string               HEADER_TEXT[20] = {  "",
                                                   "0~25",
                                                   "25~50",
                                                   "50~75",
                                                   "75~100",
                                                   "100~125",
                                                   "125~150",
                                                   "150~175",
                                                   "175~200",
                                                   "200~225",
                                                   "225~250",
                                                   "250~275",
                                                   "275~300",
                                                   "300~350",
                                                   "350~400",
                                                   "400~",
                                                   "Min",
                                                   "Max",
                                                   "Average",
                                                   "spread"
                                                };
                                                
         string               arraySymbols[];
         bool                 isSelectedHeader[];
         bool                 isSelectedSymbol[];
         
         double               sortValue[];
         double               rangeCount_0_25[];
         double               rangeCount_25_50[];
         double               rangeCount_50_75[];
         double               rangeCount_75_100[];
         double               rangeCount_100_125[];
         double               rangeCount_125_150[];
         double               rangeCount_150_175[];
         double               rangeCount_175_200[];
         double               rangeCount_200_225[];
         double               rangeCount_225_250[];
         double               rangeCount_250_275[];
         double               rangeCount_275_300[];
         double               rangeCount_300_350[];
         double               rangeCount_350_400[];
         double               rangeCount_400[];
         double               minRange[];
         double               maxRange[];
         double               average[];
         double               symbolSpread[];

int OnInit() {
   initArraySymbols();
   
   int X_column[21] =   {
                           2,
                           114,
                           161,
                           208,
                           255,
                           302,
                           349,
                           396,
                           443,
                           490,
                           538,
                           584,
                           631,
                           678,
                           725,
                           772,
                           819,
                           866,
                           913,
                           960,
                           1007
                        };
   
   int y;
   y = 30;
   
   ButtonCreate(btnNmSortAsc, "Asc", X_column[0], y, 55, 16, clrDarkGreen, 12, clrWhite);
   
   ButtonCreate(btnNmSortDesc, "Desc", X_column[0]+55+1, y, 55, 16, clrMistyRose, 12, clrBlack);
   
   RectLabelCreate(rectNmSortValue, X_column[1], y, 45, 16);
   SetText(textNmSortValue, HEADER_TEXT[0], X_column[1]+2, y+1, 8);
   
   for (int i = 1; i < HEADER_COUNT; i++) {
      ButtonCreate(btnNmHeader+IntegerToString(i), HEADER_TEXT[i], X_column[i+1], y, 45, 16, clrLavender, 8, clrBlack);
   }
   
   int symbolCount = ArraySize(arraySymbols);
   
   for (int i = 0; i < symbolCount; i++) {
      y = 47+i*17;
      
      ButtonCreate(btnNmSymbol+IntegerToString(i), arraySymbols[i], X_column[0], y, 111, 16, clrLavender, 10, clrBlack);
      
      for (int j = 1; j <= HEADER_COUNT; j++) {
         RectLabelCreate("Rect_"+IntegerToString(i)+"_"+IntegerToString(j), X_column[j], y, 45, 16);
         SetText(IntegerToString(i)+"_"+IntegerToString(j), "", X_column[j]+2, y+1, 8);
      }

   }
   
   EventSetTimer(24*60*60);
   
   OnTimer();
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   //destroyObjects();
   ObjectDelete(btnNmSortAsc);
   ObjectDelete(btnNmSortDesc);
   ObjectDelete(rectNmSortValue);
   ObjectDelete(textNmSortValue);
   for (int i = 1; i <= HEADER_COUNT; i++) {
      ObjectDelete(btnNmHeader+IntegerToString(i));
   }
   
   int symbolCount = ArraySize(arraySymbols);
   for (int i = 0; i < symbolCount; i++) {

      ObjectDelete(btnNmSymbol+IntegerToString(i));

      for (int j = 1; j <= HEADER_COUNT; j++) {
         ObjectDelete("Rect_"+IntegerToString(i)+"_"+IntegerToString(j));
         ObjectDelete(IntegerToString(i)+"_"+IntegerToString(j));
      }

   }
   
   EventKillTimer();

}

void OnTimer() {
   
   int symbolCount = ArraySize(arraySymbols);
   
   long total = 0;
   int minV = 10000;
   int maxV = 0;
   int rangeCount_0_25_v;
   int rangeCount_25_50_v;
   int rangeCount_50_75_v;
   int rangeCount_75_100_v;
   int rangeCount_100_125_v;
   int rangeCount_125_150_v;
   int rangeCount_150_175_v;
   int rangeCount_175_200_v;
   int rangeCount_200_225_v;
   int rangeCount_225_250_v;
   int rangeCount_250_275_v;
   int rangeCount_275_300_v;
   int rangeCount_300_350_v;
   int rangeCount_350_400_v;
   int rangeCount_400_v;
   
   for (int i = 0; i < symbolCount; i++) {

      string symbol = arraySymbols[i];
      total = 0;
      minV = 10000;
      maxV = 0;
      rangeCount_0_25_v = 0;
      rangeCount_25_50_v = 0;
      rangeCount_50_75_v = 0;
      rangeCount_75_100_v = 0;
      rangeCount_100_125_v = 0;
      rangeCount_125_150_v = 0;
      rangeCount_150_175_v = 0;
      rangeCount_175_200_v = 0;
      rangeCount_200_225_v = 0;
      rangeCount_225_250_v = 0;
      rangeCount_250_275_v = 0;
      rangeCount_275_300_v = 0;
      rangeCount_300_350_v = 0;
      rangeCount_350_400_v = 0;
      rangeCount_400_v = 0;
      
      double vpoint  = MarketInfo(symbol, MODE_POINT); 
      for (int j = 1; j <= BarNumber; j++) {
         
         
         double hij = iHigh(symbol, TimeFrame, j);
         double lij = iLow(symbol, TimeFrame, j);
         
         int diff = (int) ((hij - lij)/vpoint);

         total += diff;
         if (diff < minV) {
            minV = diff;
         }
         if (maxV < diff) {
            maxV = diff;
         }
         
         if (0 <= diff && diff < 250) {
            rangeCount_0_25_v++;
         } else if (250 <= diff && diff < 500) {
            rangeCount_25_50_v++;
         } else if (500 <= diff && diff < 750) {
            rangeCount_50_75_v++;
         } else if (750 <= diff && diff < 1000) {
            rangeCount_75_100_v++;
         } else if (1000 <= diff && diff < 1250) {
            rangeCount_100_125_v++;
         } else if (1250 <= diff && diff < 1500) {
            rangeCount_125_150_v++;
         } else if (1500 <= diff && diff < 1750) {
            rangeCount_150_175_v++;
         } else if (1750 <= diff && diff < 2000) {
            rangeCount_175_200_v++;
         } else if (2000 <= diff && diff < 2250) {
            rangeCount_200_225_v++;
         } else if (2250 <= diff && diff < 2500) {
            rangeCount_225_250_v++;
         }  else if (2500 <= diff && diff < 2750) {
            rangeCount_250_275_v++;
         } else if (2750 <= diff && diff < 3000) {
            rangeCount_275_300_v++;
         } else if (3000 <= diff && diff < 3500) {
            rangeCount_300_350_v++;
         } else if (3500 <= diff && diff < 4000) {
            rangeCount_350_400_v++;
         } else if (4000 <= diff) {
            rangeCount_400_v++;
         }
      }
      
      minRange[i] = NormalizeDouble(1.0*minV/10, 1);
      maxRange[i] = NormalizeDouble(1.0*maxV/10, 1);
      average[i] = NormalizeDouble(1.0*total/BarNumber/10, 1);
      rangeCount_0_25[i] = NormalizeDouble((100.0*rangeCount_0_25_v/BarNumber), 2);
      rangeCount_25_50[i] = NormalizeDouble((100.0*rangeCount_25_50_v/BarNumber), 2);
      rangeCount_50_75[i] = NormalizeDouble((100.0*rangeCount_50_75_v/BarNumber), 2);
      rangeCount_75_100[i] = NormalizeDouble(100.0*rangeCount_75_100_v/BarNumber, 2);
      rangeCount_100_125[i] = NormalizeDouble(100.0*rangeCount_100_125_v/BarNumber, 2);
      rangeCount_125_150[i] = NormalizeDouble(100.0*rangeCount_125_150_v/BarNumber, 2);
      rangeCount_150_175[i] = NormalizeDouble(100.0*rangeCount_150_175_v/BarNumber, 2);
      rangeCount_175_200[i] = NormalizeDouble(100.0*rangeCount_175_200_v/BarNumber, 2);
      rangeCount_200_225[i] = NormalizeDouble(100.0*rangeCount_200_225_v/BarNumber, 2);
      rangeCount_225_250[i] = NormalizeDouble(100.0*rangeCount_225_250_v/BarNumber, 2);
      rangeCount_250_275[i] = NormalizeDouble(100.0*rangeCount_250_275_v/BarNumber, 2);
      rangeCount_275_300[i] = NormalizeDouble(100.0*rangeCount_275_300_v/BarNumber, 2);
      rangeCount_300_350[i] = NormalizeDouble(100.0*rangeCount_300_350_v/BarNumber, 2);
      rangeCount_350_400[i] = NormalizeDouble(100.0*rangeCount_350_400_v/BarNumber, 2);
      rangeCount_400[i] = NormalizeDouble(100.0*rangeCount_400_v/BarNumber, 2);
      
   }


   for (int i = 0; i < symbolCount; i++) {
      ObjectSetString(0, IntegerToString(i)+"_2", OBJPROP_TEXT, DoubleToStr(rangeCount_0_25[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_3", OBJPROP_TEXT, DoubleToStr(rangeCount_25_50[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_4", OBJPROP_TEXT, DoubleToStr(rangeCount_50_75[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_5", OBJPROP_TEXT, DoubleToStr(rangeCount_75_100[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_6", OBJPROP_TEXT, DoubleToStr(rangeCount_100_125[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_7", OBJPROP_TEXT, DoubleToStr(rangeCount_125_150[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_8", OBJPROP_TEXT, DoubleToStr(rangeCount_150_175[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_9", OBJPROP_TEXT, DoubleToStr(rangeCount_175_200[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_10", OBJPROP_TEXT, DoubleToStr(rangeCount_200_225[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_11", OBJPROP_TEXT, DoubleToStr(rangeCount_225_250[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_12", OBJPROP_TEXT, DoubleToStr(rangeCount_250_275[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_13", OBJPROP_TEXT, DoubleToStr(rangeCount_275_300[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_14", OBJPROP_TEXT, DoubleToStr(rangeCount_300_350[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_15", OBJPROP_TEXT, DoubleToStr(rangeCount_350_400[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_16", OBJPROP_TEXT, DoubleToStr(rangeCount_400[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_17", OBJPROP_TEXT, DoubleToStr(minRange[i], 1));
      ObjectSetString(0, IntegerToString(i)+"_18", OBJPROP_TEXT, DoubleToStr(maxRange[i], 1));
      ObjectSetString(0, IntegerToString(i)+"_19", OBJPROP_TEXT, DoubleToStr(average[i], 1));
   }
   updateSpread();
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
   updateSpread();
   return(rates_total);
}

void initArraySymbols() {

   ArrayResize(arraySymbols, 64);
   
   int count = 0;
   // 1
   if (EURUSD_Show) {
      arraySymbols[count] = symbolPrefix + "EURUSD" + symbolSuffix;
      count++;
   }
   
   // 2
   if (USDJPY_Show) {
      arraySymbols[count] = symbolPrefix + "USDJPY" + symbolSuffix;
      count++;
   }
   
   // 3
   if (GBPUSD_Show) {
      arraySymbols[count] = symbolPrefix + "GBPUSD" + symbolSuffix;
      count++;
   }
   
   // 4
   if (AUDUSD_Show) {
      arraySymbols[count] = symbolPrefix + "AUDUSD" + symbolSuffix;
      count++;
   }
   
   // 5
   if (USDCHF_Show) {
      arraySymbols[count] = symbolPrefix + "USDCHF" + symbolSuffix;
      count++;
   }
   
   // 6
   if (USDCAD_Show) {
      arraySymbols[count] = symbolPrefix + "USDCAD" + symbolSuffix;
      count++;
   }
   
   // 7
   if (NZDUSD_Show) {
      arraySymbols[count] = symbolPrefix + "NZDUSD" + symbolSuffix;
      count++;
   }
   
   // 8
   if (XAUUSD_Show) {
      arraySymbols[count] = symbolPrefix + "XAUUSD" + symbolSuffix;
      count++;
   }
   
   // 9
   if (XAGUSD_Show) {
      arraySymbols[count] = symbolPrefix + "XAGUSD" + symbolSuffix;
      count++;
   }
   
   // 10
   if (EURJPY_Show) {
      arraySymbols[count] = symbolPrefix + "EURJPY" + symbolSuffix;
      count++;
   }
   
   // 11
   if (EURGBP_Show) {
      arraySymbols[count] = symbolPrefix + "EURGBP" + symbolSuffix;
      count++;
   }
   
   // 12
   if (EURAUD_Show) {
      arraySymbols[count] = symbolPrefix + "EURAUD" + symbolSuffix;
      count++;
   }
   
   // 13
   if (EURCHF_Show) {
      arraySymbols[count] = symbolPrefix + "EURCHF" + symbolSuffix;
      count++;
   }
   
   // 14
   if (EURCAD_Show) {
      arraySymbols[count] = symbolPrefix + "EURCAD" + symbolSuffix;
      count++;
   }
   
   // 15
   if (EURNZD_Show) {
      arraySymbols[count] = symbolPrefix + "EURNZD" + symbolSuffix;
      count++;
   }
   
   // 16
   if (GBPJPY_Show) {
      arraySymbols[count] = symbolPrefix + "GBPJPY" + symbolSuffix;
      count++;
   }
   
   // 17
   if (AUDJPY_Show) {
      arraySymbols[count] = symbolPrefix + "AUDJPY" + symbolSuffix;
      count++;
   }
   
   // 18
   if (CHFJPY_Show) {
      arraySymbols[count] = symbolPrefix + "CHFJPY" + symbolSuffix;
      count++;
   }
   
   // 19
   if (CADJPY_Show) {
      arraySymbols[count] = symbolPrefix + "CADJPY" + symbolSuffix;
      count++;
   }
   
   // 20
   if (NZDJPY_Show) {
      arraySymbols[count] = symbolPrefix + "NZDJPY" + symbolSuffix;
      count++;
   }
   
   // 21
   if (GBPAUD_Show) {
      arraySymbols[count] = symbolPrefix + "GBPAUD" + symbolSuffix;
      count++;
   }
   
   // 22
   if (GBPCHF_Show) {
      arraySymbols[count] = symbolPrefix + "GBPCHF" + symbolSuffix;
      count++;
   }
   
   // 23
   if (GBPCAD_Show) {
      arraySymbols[count] = symbolPrefix + "GBPCAD" + symbolSuffix;
      count++;
   }
   
   // 24
   if (GBPNZD_Show) {
      arraySymbols[count] = symbolPrefix + "GBPNZD" + symbolSuffix;
      count++;
   }
   
   // 25
   if (AUDCHF_Show) {
      arraySymbols[count] = symbolPrefix + "AUDCHF" + symbolSuffix;
      count++;
   }
   
   // 26
   if (AUDCAD_Show) {
      arraySymbols[count] = symbolPrefix + "AUDCAD" + symbolSuffix;
      count++;
   }
   
   // 27
   if (AUDNZD_Show) {
      arraySymbols[count] = symbolPrefix + "AUDNZD" + symbolSuffix;
      count++;
   }
   
   // 28
   if (CADCHF_Show) {
      arraySymbols[count] = symbolPrefix + "CADCHF" + symbolSuffix;
      count++;
   }
   
   // 29
   if (NZDCHF_Show) {
      arraySymbols[count] = symbolPrefix + "NZDCHF" + symbolSuffix;
      count++;
   }
   
   // 30
   if (NZDCAD_Show) {
      arraySymbols[count] = symbolPrefix + "NZDCAD" + symbolSuffix;
      count++;
   }
   
   ArrayResize(arraySymbols, count, count);
   
   ArrayResize(sortValue, count);
   ArrayResize(rangeCount_0_25, count);
   ArrayResize(rangeCount_25_50, count);
   ArrayResize(rangeCount_50_75, count);
   ArrayResize(rangeCount_75_100, count);
   ArrayResize(rangeCount_100_125, count);
   ArrayResize(rangeCount_125_150, count);
   ArrayResize(rangeCount_150_175, count);
   ArrayResize(rangeCount_175_200, count);
   ArrayResize(rangeCount_200_225, count);
   ArrayResize(rangeCount_225_250, count);
   ArrayResize(rangeCount_250_275, count);
   ArrayResize(rangeCount_275_300, count);
   ArrayResize(rangeCount_300_350, count);
   ArrayResize(rangeCount_350_400, count);
   ArrayResize(rangeCount_400, count);
   ArrayResize(minRange, count);
   ArrayResize(maxRange, count);
   ArrayResize(average, count);
   ArrayResize(symbolSpread, count);
   
   ArrayResize(isSelectedHeader, HEADER_COUNT);
   ArrayResize(isSelectedSymbol, count);
   for (int i = 0; i < count; i++) {
      isSelectedSymbol[i] = false;
   }
   
   for (int i = 0; i < HEADER_COUNT-1; i++) {
      isSelectedHeader[i] = false;
   }
}

void RectLabelCreate(string            name,                         // label name
                     int               x=0,                          // X coordinate
                     int               y=0,                          // Y coordinate
                     int               width=50,                     // width
                     int               height=18,                    // height
                     color             backgroundColor=clrBlack,     // background color
                     color             borderColor=clrWhite,         // flat border color (Flat)
                     ENUM_LINE_STYLE   style=STYLE_SOLID,            // flat border style
                     int               line_width=1,                 // flat border width
                     ENUM_BORDER_TYPE  border=BORDER_FLAT,           // border type
                     ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,     // chart corner for anchoring
                     bool              back=false,                   // in the background
                     bool              selection=false,              // highlight to move
                     bool              hidden=true,                  // hidden in the object list
                     long              z_order=0)                    // priority for mouse click
{

   ResetLastError();

   long chart_ID = ChartID();

   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,0,0,0)) {
      Print(__FUNCTION__, ": failed to create a rectangle label! Error code = ",GetLastError());
   }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,backgroundColor);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,borderColor);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
}

void SetText(  string            name,
               string            text,
               int               x=0,
               int               y=0,
               int               fontSize=8,
               color             fontColor=clrWhite,
               string            fontName="Arial",
               ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER)
{
   long chart_ID = ChartID();
   if (ObjectFind(chart_ID, name) < 0) {
      ObjectCreate(chart_ID, name,OBJ_LABEL,0,0,0);
   }

   ObjectSetInteger(chart_ID, name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID, name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID, name,OBJPROP_CORNER,corner);
   ObjectSet(name, OBJPROP_BACK, false);
   ObjectSetText(name, text, fontSize, fontName, fontColor);
}

void ButtonCreate(string            name,                      // button name
                  string            text,                      // text
                  int               x=0,                       // X coordinate
                  int               y=0,                       // Y coordinate
                  int               width=50,                  // button width
                  int               height=18,                 // button height
                  color             backgroundColor=clrAzure,  // background color
                  int               fontSize=8,                // font size
                  color             textColor=clrBlack,        // text color
                  string            fontName="Arial",          // font
                  color             borderColor=clrWhite,      // border color
                  ENUM_BORDER_TYPE  border=BORDER_RAISED,      // border type
                  ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,  // chart corner for anchoring
                  bool              state=false,               // pressed/released
                  bool              back=false,                // in the background
                  bool              selection=false,           // highlight to move
                  bool              hidden=true,               // hidden in the object list
                  long              z_order=0)                 // priority for mouse click
{ 
   ResetLastError(); 
   long chart_ID = 0;
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,0,0,0)) {
      Print(__FUNCTION__, ": failed to create the button! Error code = ",GetLastError());
   }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,fontName);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,fontSize);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,textColor);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,backgroundColor);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   if (id == CHARTEVENT_OBJECT_CLICK) {
      /*************** for Symbol Button Start ***************************************/
      int symbolCount = ArraySize(arraySymbols);
      
      for (int i = 0; i < symbolCount; i++) {
         string symbol = arraySymbols[i];
         //string btnNameI = btnNmSymbol+IntegerToString(i);
         //string btnTextI = ObjectGetString(0, btnNameI, OBJPROP_TEXT);
         string btnTextClick = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (symbol == btnTextClick) {
            int startPosition = StringFind(sparam, "_");
            startPosition++;
            string rowid = StringSubstr(sparam, startPosition, StringLen(sparam)-startPosition);
            //printf("rowid=" + rowid);
            if (isSelectedSymbol[i]) {
               isSelectedSymbol[i] = false;
               //color rowBGColor = clrBlack;
               //color rowFontColor = clrWhite;
               ObjectSetInteger(0, sparam, OBJPROP_BGCOLOR, clrLavender);
               //ObjectSetInteger(0, symbol, OBJPROP_COLOR, clrBlack);

               for (int j = 1; j <= HEADER_COUNT; j++) {
                  ObjectSetInteger(0, "Rect_"+rowid+"_"+IntegerToString(j), OBJPROP_BGCOLOR, clrBlack);
                  //ObjectSetInteger(0, symbol+"_"+IntegerToString(j), OBJPROP_COLOR, clrWhite);
               }
            } else {
               isSelectedSymbol[i] = true;
               color rowBGColor = clrCrimson;
               //color rowFontColor = clrWhite;
               ObjectSetInteger(0, sparam, OBJPROP_BGCOLOR, rowBGColor);
               //ObjectSetInteger(0, symbol, OBJPROP_COLOR, rowFontColor);
               
               for (int j = 1; j <= HEADER_COUNT; j++) {
                  ObjectSetInteger(0, "Rect_"+rowid+"_"+IntegerToString(j), OBJPROP_BGCOLOR, rowBGColor);
                  //ObjectSetInteger(0, symbol+"_"+IntegerToString(j), OBJPROP_COLOR, rowFontColor);
               }
            }
            return;
         }
      }
      /*************** for Symbol Button End   ***************************************/
      
      /*************** for Header Button Start ***************************************/
      for (int i = 1; i < HEADER_COUNT; i++) {
         string btnName = btnNmHeader+IntegerToString(i);
         if (btnName == sparam) {
            if (isSelectedHeader[i]) {
               isSelectedHeader[i] = false;
               ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, clrLavender);
               //ObjectSetInteger(0, btnName, OBJPROP_COLOR, rowFontColor);
               //int symbolCount = ArraySize(arraySymbols);
               for (int j = 0; j < symbolCount; j++) {
                  ObjectSetInteger(0, "Rect_"+IntegerToString(j)+"_"+IntegerToString(i+1), OBJPROP_BGCOLOR, clrBlack);
                  if (i <= 15) {
                     string lblName = IntegerToString(j)+"_1";
                     string lblValue1 = ObjectGetString(0, lblName, OBJPROP_TEXT);
                     double value = 0.0;
                     if ("" != lblValue1) {
                        value = StrToDouble(lblValue1);
                     }
                     string lblValueI = ObjectGetString(0, IntegerToString(j)+"_"+IntegerToString(i+1), OBJPROP_TEXT);
                     value -= StrToDouble(lblValueI);
                     if (0.0 < value) {
                        ObjectSetString(0, lblName, OBJPROP_TEXT, DoubleToStr(value, 2));
                     } else {
                        ObjectSetString(0, lblName, OBJPROP_TEXT, "");
                     }
                     sortValue[j] = value;
                  }
               }
            } else {
               isSelectedHeader[i] = true;
               ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR, clrOrange);
               //ObjectSetInteger(0, btnName, OBJPROP_COLOR, rowFontColor);
               //int symbolCount = ArraySize(arraySymbols);
               for (int j = 0; j < symbolCount; j++) {
                  ObjectSetInteger(0, "Rect_"+IntegerToString(j)+"_"+IntegerToString(i+1), OBJPROP_BGCOLOR, clrCrimson);
                  if (i <= 15) {
                     string lblName = IntegerToString(j)+"_1";
                     string lblValue1 = ObjectGetString(0, lblName, OBJPROP_TEXT);
                     double value = 0.0;
                     if ("" != lblValue1) {
                        value = StrToDouble(lblValue1);
                     }
                     string lblValueI = ObjectGetString(0, IntegerToString(j)+"_"+IntegerToString(i+1), OBJPROP_TEXT);
                     value += StrToDouble(lblValueI);
                     ObjectSetString(0, lblName, OBJPROP_TEXT, DoubleToStr(value, 2));
                     sortValue[j] = value;
                  }
               }
            }
            return;
         }
      }
      /*************** for Header Button End   ***************************************/
      
      if (btnNmSortAsc == sparam) {
         quick_sort(sortValue, 0, symbolCount-1);
         refreshTable();
         
      } else if (btnNmSortDesc == sparam) {
         
      }
   }

}

void refreshTable() {
   int symbolCount = ArraySize(arraySymbols);
   for (int i = 0; i < symbolCount; i++) {
      ObjectSetString(0, btnNmSymbol+IntegerToString(i), OBJPROP_TEXT, arraySymbols[i]);
      ObjectSetString(0, IntegerToString(i)+"_1", OBJPROP_TEXT, DoubleToStr(sortValue[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_2", OBJPROP_TEXT, DoubleToStr(rangeCount_0_25[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_3", OBJPROP_TEXT, DoubleToStr(rangeCount_25_50[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_4", OBJPROP_TEXT, DoubleToStr(rangeCount_50_75[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_5", OBJPROP_TEXT, DoubleToStr(rangeCount_75_100[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_6", OBJPROP_TEXT, DoubleToStr(rangeCount_100_125[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_7", OBJPROP_TEXT, DoubleToStr(rangeCount_125_150[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_8", OBJPROP_TEXT, DoubleToStr(rangeCount_150_175[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_9", OBJPROP_TEXT, DoubleToStr(rangeCount_175_200[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_10", OBJPROP_TEXT, DoubleToStr(rangeCount_200_225[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_11", OBJPROP_TEXT, DoubleToStr(rangeCount_225_250[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_12", OBJPROP_TEXT, DoubleToStr(rangeCount_250_275[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_13", OBJPROP_TEXT, DoubleToStr(rangeCount_275_300[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_14", OBJPROP_TEXT, DoubleToStr(rangeCount_300_350[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_15", OBJPROP_TEXT, DoubleToStr(rangeCount_350_400[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_16", OBJPROP_TEXT, DoubleToStr(rangeCount_400[i], 2));
      ObjectSetString(0, IntegerToString(i)+"_17", OBJPROP_TEXT, DoubleToStr(minRange[i], 1));
      ObjectSetString(0, IntegerToString(i)+"_18", OBJPROP_TEXT, DoubleToStr(maxRange[i], 1));
      ObjectSetString(0, IntegerToString(i)+"_19", OBJPROP_TEXT, DoubleToStr(average[i], 1));
   }
   updateSpread();
}

template<typename T> 
void swap(T& array[], int i, int j) {
   T temp = array[i];
   array[i] = array[j];
   array[j] = temp;
}

void swapAllArray(int i, int j) {

   swap(sortValue, i, j);
   
   swap(arraySymbols, i, j);
   swap(isSelectedSymbol, i, j);
   
   swap(rangeCount_0_25, i, j);
   swap(rangeCount_25_50, i, j);
   swap(rangeCount_50_75, i, j);
   swap(rangeCount_75_100, i, j);
   swap(rangeCount_100_125, i, j);
   swap(rangeCount_125_150, i, j);
   swap(rangeCount_150_175, i, j);
   swap(rangeCount_175_200, i, j);
   swap(rangeCount_200_225, i, j);
   swap(rangeCount_225_250, i, j);
   swap(rangeCount_250_275, i, j);
   swap(rangeCount_275_300, i, j);
   swap(rangeCount_300_350, i, j);
   swap(rangeCount_350_400, i, j);
   swap(rangeCount_400, i, j);
   swap(minRange, i, j);
   swap(maxRange, i, j);
   swap(average, i, j);
   swap(symbolSpread, i, j);

}


int partition(double& array[], int left, int right) {
   
   double pivotValue = array[right];
   
   int storeIndex = left;
   
   for (int i = left; i < right; i++) {
      if (array[i] < pivotValue) {
         //swap(array, storeIndex, i);
         swapAllArray(storeIndex, i);
         storeIndex++;
      }
   }
   
   //swap(array, right, storeIndex);
   swapAllArray(right, storeIndex);
   return storeIndex;
}

/**
 * http://bubkoo.com/2014/01/12/sort-algorithm/quick-sort/
 */
void quick_sort(double& array[], int left, int right) {

   if (right <= left) {
      return;
   }
   
   int pivotNewIndex = partition(array, left, right);
   
   quick_sort(array, left, pivotNewIndex-1);
   quick_sort(array, pivotNewIndex+1, right);
}

void updateSpread() {
   int countSymbols = ArraySize(arraySymbols);
   for (int i = 0; i < countSymbols; i++) {
      double spreadI = MarketInfo(arraySymbols[i], MODE_SPREAD)/10;
      symbolSpread[i] = spreadI;
      ObjectSetString(0, IntegerToString(i)+"_20", OBJPROP_TEXT, DoubleToStr(spreadI, 1));
   }
}
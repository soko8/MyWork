//+------------------------------------------------------------------+
//|                                               VirtualPending.mq4 |
//|Copyright 2015～2019, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <stderror.mqh>
#include <stdlib.mqh>

//--- input parameters
//input int      N_Offset=10;

//const int            corner            = CORNER_LEFT_UPPER;
const string         chartTemplate     = "ttt";

const int            TOP_INTERVAL      = 2;
const int            INTERVAL_RECT_TXT = 2;

const int            MAX_LOSS_TIMES          = 21;
const int            COUNT_INPUTS            = 5;
const int            MAX_TIMES_ADD_POSITION  = 20;

const int            X_START = 3;
const int            Y_START = 97;

const string         addSymbolBtnName = "addSymbol_btn";
const string         addSymbolEditName = "addSymbol";
const string         timeFrameEditName = "addSymbol_tf";

      string         AllSymbols[1000];
      int            TotalCountSymbos;
      string         arraySymbols[];
      int            arrayLossTimes[][21];
      string         arrayOrderTypes[];
      int            arrayInputs[][5];
      double         arrayAddPosition[][20];
      
      int            arrayLatestLossTimes[];
      
      string         inputTimeFrame;
      string         inputAddSymbol;
      
      string         nowTradingSymbol;
      double         nowTradingSymbolLots;
      int            nowTradingSymbolLossTimes;

int OnInit() {

   TotalCountSymbos = Symbols(AllSymbols);
   initArrays();
   
   // 第一行开始
   RectLabelCreate("curSymbol_rect",                        74,  TOP_INTERVAL, 360);
   SetText("curSymbol_txt",            "当前交易中的产品：",76,  TOP_INTERVAL+INTERVAL_RECT_TXT);
   SetText("curSymbol",                "",                  180, TOP_INTERVAL+INTERVAL_RECT_TXT);
   SetText("curSymbol_lots_txt",       "手数：",            255, TOP_INTERVAL+INTERVAL_RECT_TXT);
   SetText("curSymbol_lots",           "",                  285, TOP_INTERVAL+INTERVAL_RECT_TXT);
   SetText("curSymbol_lossTimes_txt",  "已连亏次数：",      333, TOP_INTERVAL+INTERVAL_RECT_TXT);
   SetText("curSymbol_lossTimes",      "",                  400, TOP_INTERVAL+INTERVAL_RECT_TXT);
   // 第一行结束
   
   // 第二行开始
   SetText(       "addSymbol_txt",     "追加产品：", 3,   24);
   EditCreate(    addSymbolEditName,   "USDJPY",     58,  22, 100);
   SetText(       "addSymbol_tf_txt",  "时间帧：",   165, 24);
   EditCreate(    timeFrameEditName,   "5",          208, 22, 32);
   ButtonCreate(  addSymbolBtnName,    "追加",       243, 22);
   // 第二行结束
   
   // 第三行开始
   RectLabelCreate("title_loss_rect",                 71,  42, 400, 24, clrSienna, clrNONE);
   SetText(        "title_loss_txt", "连续亏损信息",  220, 43, 14);
   
   RectLabelCreate("title_input_rect",                473, 42, 830, 24, clrDarkViolet, clrNONE);
   SetText("        title_input_txt", "输入参数信息", 600, 43, 14);
   
   
   
   // 第三行结束
   
   // 第四行开始
   RectLabelCreate("head_spread_rect",   50, 66, 20, 30);
   SetText("head_spread_txt_up",   "点", 54, 67, 8);
   SetText("head_spread_txt_down", "差", 54, 80, 8);
      
   //RectLabelCreate("head_0_rect", 72, 66, 17, 30);
   //SetText("head_0_txt_up",   "0",  78, 67, 8);
   //SetText("head_0_txt_down", "次", 75, 80, 8);
   
   for (int i = 0; i < MAX_LOSS_TIMES; i++) {
      RectLabelCreate("head_"+IntegerToString(i)+"_rect", 72+i*19, 66, 17, 30);
      if (0 == i) {
         SetText("head_"+IntegerToString(i)+"_txt_up", "当", 75+i*19, 67, 8);
      } else if (i < 10) {
         SetText("head_"+IntegerToString(i)+"_txt_up", IntegerToString(i), 78+i*19, 67, 8);
      } else {
         SetText("head_"+IntegerToString(i)+"_txt_up", IntegerToString(i), 74+i*19, 67, 8);
      }
      
      if (0 == i) {
         SetText("head_"+IntegerToString(i)+"_txt_down", "前", 75+i*19, 80, 8);
      } else {
         SetText("head_"+IntegerToString(i)+"_txt_down", "次", 75+i*19, 80, 8);
      }
      
   }
   
   RectLabelCreate("head_ot_rect",   474, 66, 28, 30);
   SetText("head_ot_txt_up",   "订单", 476, 67, 8);
   SetText("head_ot_txt_down", "类型", 476, 80, 8);
   
   RectLabelCreate("head_N_rect",   504, 66, 28, 30);
   SetText("head_N_txt_up",   "初始", 506, 67, 8);
   SetText("head_N_txt_down", "偏离", 506, 80, 8);
   
   RectLabelCreate("head_sl_rect",   534, 66, 28, 30);
   SetText("head_sl_txt_up",   "止损", 536, 67, 8);
   SetText("head_sl_txt_down", "点数", 536, 80, 8);
   
   RectLabelCreate("head_tp_rect",   564, 66, 28, 30);
   SetText("head_tp_txt_up",   "止赢", 566, 67, 8);
   SetText("head_tp_txt_down", "点数", 566, 80, 8);
   
   RectLabelCreate("head_EntryTimes_rect",   594, 66, 28, 30);
   SetText("head_EntryTimes_txt_up",   "连亏", 596, 67, 8);
   SetText("head_EntryTimes_txt_down", "入场", 596, 80, 8);
   
   RectLabelCreate("head_ap_rect",   624, 66, 678, 18);
   SetText("head_ap_txt",   "加      仓      设      计", 700, 67, 10);
   
   for (int i = 0; i < MAX_TIMES_ADD_POSITION; i++) {
      RectLabelCreate("head_ap_"+IntegerToString(i)+"_rect", 624+i*34, 82, 32, 14);
      if (i < 10) {
         SetText("head_ap_"+IntegerToString(i)+"_txt", IntegerToString(i+1), 636+i*34, 82, 8);
      } else {
         SetText("head_ap_"+IntegerToString(i)+"_txt", IntegerToString(i+1), 635+i*34, 82, 8);
      }
   }
   
   
   // 第四行结束
   
   // 明细行开始
   int countSymbols = ArraySize(arraySymbols);
   string symbolName = "";
   int X = 0;
   int Y = Y_START;
   for (int i = 0; i < countSymbols; i++,Y+=16) {
      symbolName = arraySymbols[i];
      X = X_START;
      // create Button
      ButtonCreate(symbolName+"_btn", symbolName, X, Y, 47, 14, clrLightCyan, 8, clrDarkBlue);
   
      // create spread
      X = X + 45 + 2;
      RectLabelCreate(symbolName+"_spread_rect", X, Y, 20, 14);
      SetText(symbolName+"_spread", "0.0", X+2, Y);
      
      // create Loss Info
      X = X + 20 + 2;
      for (int j = 0; j < MAX_LOSS_TIMES; j++,X+=19) {
         RectLabelCreate(symbolName+"_"+IntegerToString(j)+"_rect", X, Y, 17, 14);
         SetText(symbolName+"_"+IntegerToString(j), IntegerToString(arrayLossTimes[i][j]), X+2, Y);
      }
      
      X = X + 3;
      RectLabelCreate(symbolName+"_ot_rect",   X, Y, 28, 14);
      SetText(symbolName+"_ot",   "", X+2, Y, 8);
      
      X = X + 28 + 2;
      RectLabelCreate(symbolName+"_N_rect",   X, Y, 28, 14);
      SetText(symbolName+"_N", IntegerToString(arrayInputs[i][0]), X+7, Y, 8);
      
      X = X + 28 + 2;
      RectLabelCreate(symbolName+"_sl_rect",   X, Y, 28, 14);
      SetText(symbolName+"_sl", IntegerToString(arrayInputs[i][1]), X+7, Y, 8);
      
      X = X + 28 + 2;
      RectLabelCreate(symbolName+"_tp_rect",   X, Y, 28, 14);
      SetText(symbolName+"_tp", IntegerToString(arrayInputs[i][2]), X+7, Y, 8);
      
      X = X + 28 + 2;
      RectLabelCreate(symbolName+"_EntryTimes_rect",   X, Y, 28, 14);
      SetText(symbolName+"_EntryTimes",   IntegerToString(arrayInputs[i][3]), X+8, Y, 8);
      
      X = X + 28 + 2;
      for (int j = 0; j < MAX_TIMES_ADD_POSITION; j++,X+=34) {
         RectLabelCreate(symbolName+"_ap_"+IntegerToString(j)+"_rect", X, Y, 32, 14);
         SetText(symbolName+"_ap_"+IntegerToString(j), DoubleToStr(arrayAddPosition[i][j], 2), X+2, Y);
      }
   
   }
   
   
   
   /*
   ButtonCreate("eurusd_btn", "EURUSD", 3, 97, 45, 14, clrLightCyan, 8, clrDarkBlue);
   RectLabelCreate("eurusd_spread_rect", 50, 97, 20, 14);
   SetText("eurusd_spread", "3.0", 52, 97);
   //RectLabelCreate("eurusd_0_rect", 72, 77, 17, 14);
   //SetText("eurusd_0", "10", 74, 77);
   //RectLabelCreate("eurusd_1_rect", 72+17+2, 77, 17, 14);
   //SetText("eurusd_1", "10", 74+17+2, 77);
   //RectLabelCreate("eurusd_2_rect", 72+17+2+17+2, 77, 17, 14);
   //SetText("eurusd_2", "10", 74+17+2+17+2, 77);
   for (int i = 0; i <= 20; i++) {
      RectLabelCreate("eurusd_"+IntegerToString(i)+"_rect", 72+i*19, 97, 17, 14);
      SetText("eurusd_"+IntegerToString(i), "9", 74+i*19, 97);
   }
   
   
   RectLabelCreate("eurusd_ot_rect",   474, 97, 28, 14);
   SetText("eurusd_ot",   "Limit", 476, 97, 8);
   
   RectLabelCreate("eurusd_N_rect",   504, 97, 28, 14);
   SetText("eurusd_N",   "10", 511, 97, 8);
   
   RectLabelCreate("eurusd_sl_rect",   534, 97, 28, 14);
   SetText("eurusd_sl",   "30", 541, 97, 8);
   
   RectLabelCreate("eurusd_tp_rect",   564, 97, 28, 14);
   SetText("eurusd_tp",   "60", 571, 97, 8);
   
   RectLabelCreate("eurusd_EntryTimes_rect",   594, 97, 28, 14);
   SetText("eurusd_EntryTimes",   "1", 602, 97, 8);
   
   for (int i = 0; i < 20; i++) {
      RectLabelCreate("eurusd_ap_"+IntegerToString(i)+"_rect", 624+i*34, 97, 32, 14);
      SetText("eurusd_ap_"+IntegerToString(i), "99.99", 626+i*34, 97);
   }
   */
   
   // 明细行结束

   EventSetTimer(3);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();   
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
   
//--- return value of prev_calculated for next call
   return(rates_total);
}

void OnTimer() {

   readInputInfo();
   readStatisticInfo();
   updateData();
   
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedObject = sparam;
      if (clickedObject == addSymbolBtnName) {
         bool isOk = true;
         if(!ObjectGetString(0, addSymbolEditName, OBJPROP_TEXT, 0, inputAddSymbol)) {
            isOk = false;
            Print(__FUNCTION__, ": failed to get the Add Symbol! Error Info: ", ErrorDescription(GetLastError()));
         }

         if (!isRightSymbol(inputAddSymbol)) {
            isOk = false;
            Alert("请输入正确的产品");
         }
         
         if (isExistInList(inputAddSymbol)) {
            isOk = false;
            Alert("该产品在列表中已存在");
         }
         
         if(!ObjectGetString(0, timeFrameEditName, OBJPROP_TEXT, 0, inputTimeFrame)) {
            isOk = false;
            Print(__FUNCTION__, ": failed to get the Time Frame! Error Info: ", ErrorDescription(GetLastError()));
         }
         
         if (     "1" != inputTimeFrame
               && "5" != inputTimeFrame
               && "15" != inputTimeFrame
               && "30" != inputTimeFrame
               && "60" != inputTimeFrame
               && "240" != inputTimeFrame
               && "1440" != inputTimeFrame) {
            isOk = false;
            Alert("请输入[1，5，15，30，60，240，1440]中的任何一个");
         }
         
         if (isOk) {
            addRow();
            updateArray();
         }
      }
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
   if (ObjectFind(0,name) < 0) {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSet(name, OBJPROP_BACK, false);
   ObjectSetText(name, text, fontSize, fontName, fontColor);
}

void OpenChart(string symbol, ENUM_TIMEFRAMES tf=PERIOD_M5) {
   long nextchart = ChartFirst();
   do {
      string chartSymbol = ChartSymbol(nextchart);
      if (-1 < StringFind(chartSymbol, symbol)) {
         ChartSetInteger(nextchart, CHART_BRING_TO_TOP, true);
         ChartSetSymbolPeriod(nextchart, symbol, tf);
         ChartApplyTemplate(nextchart, chartTemplate);
         return;
      }
   } while ((nextchart = ChartNext(nextchart)) != -1);
   long newchartid = ChartOpen(symbol, tf);
   ChartApplyTemplate(newchartid, chartTemplate);
}



void EditCreate(  string            name,                      // object name
                  string            text,                      // text
                  int               x=0,                       // X coordinate
                  int               y=0,                       // Y coordinate
                  int               width=50,                  // width
                  int               height=18,                 // height
                  string            fontName="Arial",          // font
                  int               fontSize=10,               // font size
                  color             fontColor=clrBlack,        // text color
                  color             backgroundColor=clrWhite,  // background color
                  color             borderColor=clrRed,        // border color
                  ENUM_ALIGN_MODE   align=ALIGN_CENTER,        // alignment type
                  bool              read_only=false,           // ability to edit
                  ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,  // chart corner for anchoring
                  bool              back=false,                // in the background
                  bool              selection=false,           // highlight to move
                  bool              hidden=true,               // hidden in the object list
                  long              z_order=0)                 // priority for mouse click
{ 

   ResetLastError();
   long chart_ID = 0;
//--- create edit field
   if(!ObjectCreate(chart_ID,name,OBJ_EDIT,0,0,0)) {
      Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ",GetLastError());
   }
//--- set object coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,fontName);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,fontSize);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,fontColor);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,backgroundColor);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,borderColor);
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

void updateArray() {
   int symbolsArraySize = ArraySize(arraySymbols);
   ArrayResize(arraySymbols, symbolsArraySize+1, symbolsArraySize);
   arraySymbols[symbolsArraySize] = inputAddSymbol;
}

void addRow() {
   string symbolName = inputAddSymbol;
   int X = X_START;
   int symbolsArraySize = ArraySize(arraySymbols);
   int Y = Y_START + 16*symbolsArraySize;
   // create Button
   ButtonCreate(symbolName+"_btn", symbolName, X, Y, 47, 14, clrLightCyan, 8, clrDarkBlue);

   // create spread
   X = X + 45 + 2;
   RectLabelCreate(symbolName+"_spread_rect", X, Y, 20, 14);
   SetText(symbolName+"_spread", "0.0", X+2, Y);
   
   // create Loss Info
   X = X + 20 + 2;
   for (int j = 0; j < MAX_LOSS_TIMES; j++,X+=19) {
      RectLabelCreate(symbolName+"_"+IntegerToString(j)+"_rect", X, Y, 17, 14);
      SetText(symbolName+"_"+IntegerToString(j), "0", X+2, Y);
   }
   
   X = X + 3;
   RectLabelCreate(symbolName+"_ot_rect",   X, Y, 28, 14);
   SetText(symbolName+"_ot",   "", X+2, Y, 8);
   
   X = X + 28 + 2;
   RectLabelCreate(symbolName+"_N_rect",   X, Y, 28, 14);
   SetText(symbolName+"_N", "0", X+7, Y, 8);
   
   X = X + 28 + 2;
   RectLabelCreate(symbolName+"_sl_rect",   X, Y, 28, 14);
   SetText(symbolName+"_sl", "0", X+7, Y, 8);
   
   X = X + 28 + 2;
   RectLabelCreate(symbolName+"_tp_rect",   X, Y, 28, 14);
   SetText(symbolName+"_tp", "0", X+7, Y, 8);
   
   X = X + 28 + 2;
   RectLabelCreate(symbolName+"_EntryTimes_rect",   X, Y, 28, 14);
   SetText(symbolName+"_EntryTimes", "0", X+8, Y, 8);
   
   X = X + 28 + 2;
   for (int j = 0; j < MAX_TIMES_ADD_POSITION; j++,X+=34) {
      RectLabelCreate(symbolName+"_ap_"+IntegerToString(j)+"_rect", X, Y, 32, 14);
      SetText(symbolName+"_ap_"+IntegerToString(j), "0.0", X+2, Y);
   }
}


void readInputInfo() {

   string fileNamePrefix = "VirtualPending_InputInfo_";
   string fileName = "";
   
   int handle = INVALID_HANDLE;
   
   string symbol = "";
   
   int countSymbols = ArraySize(arraySymbols);
   for (int i = 0; i < countSymbols; i++) {
   
      symbol = arraySymbols[i];
      
      if ("0" != ObjectGetString(0, symbol+"_N", OBJPROP_TEXT)) {
         continue;
      }
      
      fileName = fileNamePrefix+symbol+ ".csv";
      handle=FileOpen(fileName, FILE_READ|FILE_CSV, ',');
      
      if(INVALID_HANDLE == handle) {
         Print("Failed to open file " + fileName + ". Error Info:" + ErrorDescription(GetLastError()));
      } else {
         Print(fileName + " file is available for reading");
         
         
         FileReadString(handle);
         FileReadString(handle);
         FileReadString(handle);
         arrayOrderTypes[i] = FileReadString(handle);
         
         FileReadString(handle);
         arrayInputs[i][0] = FileReadString(handle);
         
         FileReadString(handle);
         arrayInputs[i][1] = FileReadString(handle);
         
         FileReadString(handle);
         arrayInputs[i][2] = FileReadString(handle);
         
         FileReadString(handle);
         arrayInputs[i][3] = FileReadString(handle);
         
         for (int j = 0; j < MAX_TIMES_ADD_POSITION; j++) {
            FileReadString(handle);
            arrayAddPosition[i][j] = FileReadString(handle);
         }
         
         FileClose(handle);
         Print("Data is readed, " + fileName + " file is closed");
      
      }
      
   }
   
}

void readStatisticInfo() {

   string fileNamePrefix = "VirtualPending_StatisticInfo_";
   string fileName = "";
   
   int handle = INVALID_HANDLE;
   
   string symbol = "";
   
   int countSymbols = ArraySize(arraySymbols);
   for (int i = 0; i < countSymbols; i++) {
   
      symbol = arraySymbols[i];
      fileName = fileNamePrefix+symbol+ ".csv";
      handle=FileOpen(fileName, FILE_READ|FILE_CSV, ',');
      
      if(INVALID_HANDLE == handle) {
         Print("Failed to open file " + fileName + ". Error Info:" + ErrorDescription(GetLastError()));
      } else {
         Print(fileName + " file is available for reading");
         
         if (nowTradingSymbol == symbol) {
            FileReadString(handle);
            nowTradingSymbolLossTimes = FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            nowTradingSymbolLots = FileReadString(handle);
         } else {
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
            FileReadString(handle);
         }
         FileReadString(handle);
         FileReadString(handle);
         FileReadString(handle);
         arrayLatestLossTimes[i] = FileReadString(handle);
         
         for (int j = 0; j < MAX_LOSS_TIMES; j++) {
            FileReadString(handle);
            arrayLossTimes[i][j] = FileReadString(handle);
         }
         
         FileClose(handle);
         Print("Data is readed, " + fileName + " file is closed");
      
      }
      
   }

}

void updateData() {
   
   string symbol = "";
   
   int countSymbols = ArraySize(arraySymbols);
   for (int i = 0; i < countSymbols; i++) {
   
      symbol = arraySymbols[i];
      
      ObjectSetString(0, symbol+"_spread", OBJPROP_TEXT, "");
      for (int j = 0; j < MAX_LOSS_TIMES; j++) {
         ObjectSetString(0, symbol+"_"+IntegerToString(j), OBJPROP_TEXT, arrayLossTimes[i][j]);
      }
      
      if ("0" != ObjectGetString(0, symbol+"_N", OBJPROP_TEXT)) {
         continue;
      }
      
      ObjectSetString(0, symbol+"_ot", OBJPROP_TEXT, arrayOrderTypes[i]);
      
      ObjectSetString(0, symbol+"_N", OBJPROP_TEXT, arrayInputs[i][0]);
      
      ObjectSetString(0, symbol+"_sl", OBJPROP_TEXT, arrayInputs[i][1]);
      
      ObjectSetString(0, symbol+"_tp", OBJPROP_TEXT, arrayInputs[i][2]);
      
      ObjectSetString(0, symbol+"_EntryTimes", OBJPROP_TEXT, arrayInputs[i][3]);
      
      for (int j = 0; j < MAX_TIMES_ADD_POSITION; j++) {
         ObjectSetString(0, symbol+"_ap_"+IntegerToString(j), OBJPROP_TEXT, arrayAddPosition[i][j]);
      }
   }
}

/*
void EventCreate( string            name="Event",    // event name
                  string            text="Text",     // event text
                  datetime          time=0,          // time
                  color             clr=clrRed,      // color
                  int               width=1,         // point width when highlighted
                  bool              back=false,      // in the background
                  bool              selection=false, // highlight to move
                  bool              hidden=true,     // hidden in the object list
                  long              z_order=0)       // priority for mouse click
{
//--- if time is not set, create the object on the last bar
   if(!time) {
      time=TimeCurrent();
   }
//--- reset the error value
   ResetLastError();
   long chart_ID = 0;
//--- create Event object
   if(!ObjectCreate(chart_ID,name,OBJ_EVENT,0,time,0)) {
      Print(__FUNCTION__, ": failed to create \"Event\" object! Error code = ",GetLastError());
   }
//--- set event text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set anchor point width if the object is highlighted
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving event by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
}
*/

/*
void RectLabelDelete(string name="RectLabel") { 

   ResetLastError();
   
   long chart_ID = ChartID();

   if(!ObjectDelete(chart_ID,name)) {
      Print(__FUNCTION__, ": failed to delete a rectangle label! Error code = ",GetLastError());
   }

}
*/

void initArrays() {

   int countSymbols = 1;
   
   ArrayResize(arraySymbols, countSymbols);
   arraySymbols[0] = "EURUSD";
   //arraySymbols[1] = "GBPUSD";
   /*arraySymbols[2] = "USDJPY";
   arraySymbols[3] = "USDCAD";
   arraySymbols[4] = "USDCHF";
   arraySymbols[5] = "AUDUSD";
   arraySymbols[6] = "NZDUSD";*/
   
   ArrayResize(arrayLossTimes, countSymbols);
   for (int i = 0; i < countSymbols; i++) {
      for (int j = 0; j < MAX_LOSS_TIMES; j++) {
         arrayLossTimes[i][j] = 0;
      }
   }
   
   ArrayResize(arrayInputs, countSymbols);
   for (int i = 0; i < countSymbols; i++) {
      for (int j = 0; j < COUNT_INPUTS; j++) {
         arrayInputs[i][j] = 0;
      }
   }
   
   ArrayResize(arrayAddPosition, countSymbols);
   for (int i = 0; i < countSymbols; i++) {
      for (int j = 0; j < MAX_TIMES_ADD_POSITION; j++) {
         arrayAddPosition[i][j] = 0.0;
      }
   }
   
   ArrayResize(arrayOrderTypes, countSymbols);
   for (int i = 0; i < countSymbols; i++) {
      arrayOrderTypes[i] = "";
   }
   
   ArrayResize(arrayLatestLossTimes, countSymbols);
   for (int i = 0; i < countSymbols; i++) {
      arrayLatestLossTimes[i] = 0;
   }

}


bool isExistInList(string symbol) {
   
   int arrSize = ArraySize(arraySymbols);
   for (int i = 0; i < arrSize; i++) {
      if (symbol == arraySymbols[i]) {
         return true;;
      }
   }
   
   return false;
}

bool isRightSymbol(string symbol) {
   for (int i = 0; i < TotalCountSymbos; i++) {
      if (symbol == AllSymbols[i]) {
         return true;
      }
   }
   
   return false;
}


int Symbols(string& sSymbols[]) {
  int    iCount, handle, handle2, i;
  string sData="Symbols_"+AccountServer()+".csv", sSymbol;
    
  handle=FileOpenHistory("symbols.raw", FILE_BIN | FILE_READ);
  if(handle == -1) return(Error("File: symbols.raw  Error: "+ErrorDescription(GetLastError())));
  handle2=FileOpen(sData, FILE_CSV|FILE_WRITE, ',');
  if(handle2 == -1) return(Error("File: "+sData+"  Error: "+ErrorDescription(GetLastError())));
  iCount=FileSize(handle) / 1936;
  ArrayResize(sSymbols, iCount);
  
  FileWrite(handle2,"Symbol","Description","Point","Digits","Spread","StopLevel",
            "LotSize","TickValue","TickSize","SwapLong","SwapShort","Starting",
            "Expiration","TradeAllowed","MinLot","LotStep","MaxLot","SwapType",
            "ProfitCalcMode","MarginCalcMode","MarginMaintenance","MarginHedged",
            "MarginRequired","FreezeLevel");
  
  for(i=0; i<iCount; i++) {
    sSymbol=FileReadString(handle, 12);
    sSymbols[i]=sSymbol;
    FileWrite(handle2,
              sSymbol,
              StringTransform(StringTrimRight(FileReadString(handle, 75)),","), // Field 1 - Symbol/Instrument Description
              MarketInfo(sSymbol,MODE_POINT),
              MarketInfo(sSymbol,MODE_DIGITS),
              MarketInfo(sSymbol,MODE_SPREAD),
              MarketInfo(sSymbol,MODE_STOPLEVEL),
              MarketInfo(sSymbol,MODE_LOTSIZE),
              MarketInfo(sSymbol,MODE_TICKVALUE),
              MarketInfo(sSymbol,MODE_TICKSIZE),
              MarketInfo(sSymbol,MODE_SWAPLONG),
              MarketInfo(sSymbol,MODE_SWAPSHORT),
              ifS(MarketInfo(sSymbol,MODE_STARTING)==0,"0",
                  TimeToStr(MarketInfo(sSymbol,MODE_STARTING),TIME_DATE|TIME_MINUTES)
                 ),
              ifS(MarketInfo(sSymbol,MODE_EXPIRATION)==0,"0",
                  TimeToStr(MarketInfo(sSymbol,MODE_EXPIRATION),TIME_DATE|TIME_MINUTES)
                 ),
              ifS(MarketInfo(sSymbol,MODE_TRADEALLOWED)==1,"Yes","No"),
              MarketInfo(sSymbol,MODE_MINLOT),
              MarketInfo(sSymbol,MODE_LOTSTEP),
              MarketInfo(sSymbol,MODE_MAXLOT),
              ifS(    MarketInfo(sSymbol,MODE_SWAPTYPE)==0,"0=in points",
                  ifS(MarketInfo(sSymbol,MODE_SWAPTYPE)==1,"1=in base ccy",
                  ifS(MarketInfo(sSymbol,MODE_SWAPTYPE)==2,"2=by interest",
                  ifS(MarketInfo(sSymbol,MODE_SWAPTYPE)==3,"3=in margin ccy",
                      DoubleToStr(MarketInfo(sSymbol,MODE_SWAPTYPE),0))))
                 ),
             ifS(    MarketInfo(sSymbol,MODE_PROFITCALCMODE)==0,"0=Forex",
                 ifS(MarketInfo(sSymbol,MODE_PROFITCALCMODE)==1,"1=CFD",
                 ifS(MarketInfo(sSymbol,MODE_PROFITCALCMODE)==2,"2=Futures",
                     DoubleToStr(MarketInfo(sSymbol,MODE_PROFITCALCMODE),0)))
                ),
             ifS(    MarketInfo(sSymbol,MODE_MARGINCALCMODE)==0,"0=Forex",
                 ifS(MarketInfo(sSymbol,MODE_MARGINCALCMODE)==1,"1=CFD",
                 ifS(MarketInfo(sSymbol,MODE_MARGINCALCMODE)==2,"2=Futures",
                 ifS(MarketInfo(sSymbol,MODE_MARGINCALCMODE)==3,"3=CFD for indices",
                     DoubleToStr(MarketInfo(sSymbol,MODE_MARGINCALCMODE),0))))
                ),
              MarketInfo(sSymbol,MODE_MARGININIT),
              MarketInfo(sSymbol,MODE_MARGINHEDGED),
              MarketInfo(sSymbol,MODE_MARGINREQUIRED),
              MarketInfo(sSymbol,MODE_FREEZELEVEL)
             );
    FileSeek(handle, 1849, SEEK_CUR); // move to start of next record
  }
  
  FileClose(handle2);
  FileClose(handle);
  return(iCount);
}

int Error(string sErrorMessage) {
  Print(sErrorMessage);
  return(-1);
}

string ifS(bool bExpression, string sValue1, string sValue2) {
  if(bExpression) return(sValue1); else return(sValue2);
}

string StringTransform(string sText, string sFind=" ", string sReplace="") {
  int    iLenText=StringLen(sText), iLenFind=StringLen(sFind), i;
  string sReturn="";
  
  for(i=0; i<iLenText; i++) {
    if(StringSubstr(sText,i,iLenFind)==sFind) {
      sReturn=sReturn+sReplace;
      i=i+iLenFind-1;
    }
    else sReturn=sReturn+StringSubstr(sText,i,1);
  }
  return(sReturn);
}
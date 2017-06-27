//+------------------------------------------------------------------+
//|                                                     SwapList.mq4 |
//|      Copyright 2017, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Gao Zeng.QQ--183947281,mail--soko8@sina.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <SymbolsLib.mqh>

class SymbolInfo {
   private:
      string   name;
      double   swapLong;
      double   swapShort;
      int      spread;
   public:
      SymbolInfo() {};
      //--- Copy constructor
      SymbolInfo(const SymbolInfo &symbolInfo) {
         name=symbolInfo.name;
         swapLong=symbolInfo.swapLong;
         swapShort=symbolInfo.swapShort;
         spread=symbolInfo.spread;
      };
      //--- A constructor with an initialization list
      SymbolInfo(string symbolName, double _swapLong, double _swapShort, int _spread): name(symbolName), swapLong(_swapLong), swapShort(_swapShort), spread(_spread) {};

     ~SymbolInfo() {};
     
      void     SetName(string symbolName)       {name=symbolName;}
      string   GetName()                        {return(name);}
      void     SetSwapLong(double _swapLong)     {swapLong=_swapLong;}
      double   GetSwapLong()                    {return(swapLong);}
      void     SetSwapShort(double _swapShort)   {swapShort=_swapShort;}
      double   GetSwapShort()                   {return(swapShort);}
      void     SetSpread(int _spread)            {spread=_spread;}
      int      GetSpread()                      {return(spread);}
};

//--- input parameters
input bool           Not_Show_All_Minus = true;

string SymbolsList[];
SymbolInfo *symbolInfos[];

const int DigitSwap = 2;

const int      Columns = 4;
const string   HEAD_TEXT[4] = {"", "SwapL", "SwapS", "Spread"};


void drawHead() {

   int X = 1;
   int Y = 1;
   
   //for (int i = 0; i < Columns; i++) {
   //   X += 46*i;
   //   RectLabelCreate("Rect_Head_"+HEAD_TEXT[i], X, Y, 45, 16);
   //   SetText("Head_"+HEAD_TEXT[i], HEAD_TEXT[i], X+1, Y+1, 8);
   //}
   int width = 62;
   int height = 18;
   int fontSize = 11;
   
   RectLabelCreate("Rect_Head_"+HEAD_TEXT[0], X, Y, width, height);
   SetText("Head_"+HEAD_TEXT[0], HEAD_TEXT[0], X+5, Y+1, fontSize);
   
   X += width;
   RectLabelCreate("Rect_Head_"+HEAD_TEXT[1], X, Y, width, height);
   SetText("Head_"+HEAD_TEXT[1], HEAD_TEXT[1], X+5, Y+1, fontSize);
   
   X += width;
   RectLabelCreate("Rect_Head_"+HEAD_TEXT[2], X, Y, width, height);
   SetText("Head_"+HEAD_TEXT[2], HEAD_TEXT[2], X+5, Y+1, fontSize);
   
   X += width;
   RectLabelCreate("Rect_Head_"+HEAD_TEXT[3], X, Y, width, height);
   SetText("Head_"+HEAD_TEXT[3], HEAD_TEXT[3], X+5, Y+1, fontSize);
}

void drawSwapList() {
   int X = 1;
   int Y = 19;
   int width = 62;
   int height = 18;
   int fontSize = 10;
   int symbolCount = ArraySize(symbolInfos);
   for (int i = symbolCount-1; 0 <= i; i--) {
      X = 1;
      string symbolName = symbolInfos[i].GetName();

      RectLabelCreate("Rect_"+symbolName, X, Y, width, height);
      SetText(symbolName, symbolName, X+3, Y+1, fontSize);
      
      X += width;
      RectLabelCreate("Rect_"+symbolName+"_SwapL", X, Y, width, height);
      SetText(symbolName+"_SwapL", DoubleToStr(symbolInfos[i].GetSwapLong(), DigitSwap), X+11, Y+1, fontSize);
      
      X += width;
      RectLabelCreate("Rect_"+symbolName+"_SwapS", X, Y, width, height);
      SetText(symbolName+"_SwapS", DoubleToStr(symbolInfos[i].GetSwapShort(), DigitSwap), X+11, Y+1, fontSize);
      
      X += width;
      RectLabelCreate("Rect_"+symbolName+"_Spread", X, Y, width, height);
      SetText(symbolName+"_Spread", symbolInfos[i].GetSpread(), X+11, Y+1, fontSize);
      Y += height;
   }
}


int OnInit() {
   
   if(SymbolsList(SymbolsList, false) <= 0) return (INIT_FAILED);
   int symbolCount = ArraySize(SymbolsList);
   ArrayResize(symbolInfos, symbolCount);
   Print(symbolCount);
   string symbol = NULL;
   double swapLong = 0.0;
   double swapShort = 0.0;
   int spread = 0.0;
   int symbolCnt = 0;
   for (int i = 0; i < symbolCount; i++) {
      
      symbol = SymbolsList[i];
      string symbolType = SymbolType(symbol);
      //Print(symbolType);
      if (StringFind(symbolType, "Forex") < 0) {
         continue;
      }
      //Print(symbolType);
      swapLong = NormalizeDouble(MarketInfo(symbol, MODE_SWAPLONG), DigitSwap);
      swapShort = NormalizeDouble(MarketInfo(symbol, MODE_SWAPSHORT), DigitSwap);
      spread = (int) MarketInfo(symbol, MODE_SPREAD);
      symbolInfos[symbolCnt] = new SymbolInfo(symbol, swapLong, swapShort, spread);
      symbolCnt++;
   }
   Print(symbolCnt);
   ArrayResize(symbolInfos, symbolCnt, symbolCnt);
   quick_sort(0, symbolCnt-1);
   
   
   drawHead();
   drawSwapList();
   //for (int i = 0; i < symbolCnt; i++) {
   //   Print(symbolInfos[i].GetName() + " Long:" + symbolInfos[i].GetSwapLong() + " Short:" + symbolInfos[i].GetSwapShort());
   //}
   //Print(SymbolDescription(Symbol()));
      
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   ObjectsDeleteAll();
   int symbolCount = ArraySize(symbolInfos);
   for (int i = 0; i < symbolCount; i++) {
      delete GetPointer(symbolInfos[i]);
   }
   
   //EventKillTimer();

}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {

   return(rates_total);
}

void OnTimer() {

   
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}


void swap(int i, int j) {
   SymbolInfo *temp = symbolInfos[i];
   
   symbolInfos[i] = symbolInfos[j];
   symbolInfos[j] = temp;
}

int partition(int left, int right) {
   
   double pivotValue = MathMax(symbolInfos[right].GetSwapLong(), symbolInfos[right].GetSwapShort());
   
   int storeIndex = left;
   
   for (int i = left; i < right; i++) {
      if (MathMax(symbolInfos[i].GetSwapLong(), symbolInfos[i].GetSwapShort()) < pivotValue) {
         swap(storeIndex, i);
         storeIndex++;
      }
   }
   
   swap(right, storeIndex);
   return storeIndex;
}

/**
 * http://bubkoo.com/2014/01/12/sort-algorithm/quick-sort/
 */
 
void quick_sort(int left, int right) {

   if (right <= left) {
      return;
   }
   
   int pivotNewIndex = partition(left, right);
   
   quick_sort(left, pivotNewIndex-1);
   quick_sort(pivotNewIndex+1, right);
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
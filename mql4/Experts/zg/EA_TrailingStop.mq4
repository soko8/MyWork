//+------------------------------------------------------------------+
//|                                              EA_TrailingStop.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

enum Operate_Mode
{
    OPM_MagicNumber,
    OPM_CurrentWindowSymbol,
    OPM_MagicNumber_And_CurrentWindowSymbol,
    OPM_ALL
};
enum Trailing_Stop_Method
{
    TSM_Fix,
    TSM_MA,
    TSM_Sar,
    TSM_ATR,
    TSM_BollingerBands
};
input ENUM_TIMEFRAMES            Timeframe            = PERIOD_CURRENT;
input Operate_Mode               OperateMode          = OPM_ALL;
input Trailing_Stop_Method       TrailingStopMode     = TSM_Fix;
input int                        TargetMagicNumber    = 168168;
input int                        OffsetPoint          = -20;
input string ____TSM_Fix_Set = "================";
input int                  TSM_Fix_Point              = 200;
input string ____TSM_MA_Set = "================";
input int                  TSM_MA_Period              = 55;
input ENUM_MA_METHOD       TSM_MA_Method              = MODE_EMA;
input ENUM_APPLIED_PRICE   TSM_MA_Applied_Price       = PRICE_WEIGHTED;
input string ____TSM_Sar_Set = "================";
input double               TSM_Sar_Step               = 0.02;
input double               TSM_Sar_Maximum            = 0.2;
input string ____TSM_ATR_Set = "================";
input int                  TSM_ATR_Period             = 34;
input string ____TSM_BollingerBands_Set = "================";
input int                  TSM_BollingerBands_Period        = 55;
input double               TSM_BollingerBands_Deviation     = 2;
input ENUM_APPLIED_PRICE   TSM_BollingerBands_Applied_Price = PRICE_WEIGHTED;
input int                  TSM_BollingerBands_LineIndex     = MODE_MAIN;

input string ____Display_Set = "================";
input int                        Coordinates_X    = 10;
input int                        Coordinates_Y    = 30;

Operate_Mode _operateMode;
Trailing_Stop_Method _trailingStopMode;
int _targetMagicNumber, _offsetPoint, _tsmFixPoint, _tsmMaPeriod, _tsmAtrPeriod, _tsmBBPeriod, _tsmBBLineIndex;
ENUM_TIMEFRAMES _tfTsmMa, _tfTsmSar, _tfTsmAtr, _tfTsmBB;
ENUM_MA_METHOD _tsmMaMethod;
ENUM_APPLIED_PRICE _tsmMaAppliedPrice, _tsmBBAppliedPrice;
double _tsmSarStep, _tsmSarMaximum, _tsmBBDeviation;

datetime barTime = 0;
bool     Stop_EA = true;


int OnInit() {
   _operateMode = OperateMode;
   _trailingStopMode = TrailingStopMode;
   _targetMagicNumber = TargetMagicNumber;
   _offsetPoint = OffsetPoint;
   _tsmFixPoint = TSM_Fix_Point;
   _tfTsmMa = Timeframe;
   _tfTsmSar = Timeframe;
   _tfTsmAtr = Timeframe;
   _tfTsmBB = Timeframe;
   _tsmMaPeriod = TSM_MA_Period;
   _tsmMaMethod = TSM_MA_Method;
   _tsmMaAppliedPrice = TSM_MA_Applied_Price;
   _tsmSarStep = TSM_Sar_Step;
   _tsmSarMaximum = TSM_Sar_Maximum;
   _tsmAtrPeriod = TSM_ATR_Period;
   _tsmBBPeriod = TSM_BollingerBands_Period;
   _tsmBBDeviation = TSM_BollingerBands_Deviation;
   _tsmBBAppliedPrice = TSM_BollingerBands_Applied_Price;
   _tsmBBLineIndex = TSM_BollingerBands_LineIndex;
   
   draw();
   
//--- create timer
   EventSetTimer(1);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll(0, ObjNamePrefix);
}

void OnTick() {}

void OnTimer() {
   if (Stop_EA) return;
   if (TSM_Fix != _trailingStopMode) {
      datetime nowBarTime = iTime(NULL, Timeframe, 0);
      // not new bar
      if (barTime == nowBarTime) return;

      // new bar then go on
      barTime = nowBarTime;
   }
   for (int i=OrdersTotal()-1; 0<=i; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (!isTargetOrder()) continue;
         int orderType = OrderType();
         string symbolName = OrderSymbol();
         double sl = 0.0;
         double slOrder = OrderStopLoss();
         if (OP_BUY == orderType) {
            sl = getSl4Buy(symbolName);
            if (slOrder < sl) modify(sl);

         /*****************************************************************************************************************/
         } else if (OP_SELL == orderType) {
            sl = getSl4Sell(symbolName);
            if (sl < slOrder) modify(sl);
         }
      } else {
         Print("Failed to call OrderSelect() method for position #", i, " Error code=", ErrorDescription(GetLastError()));
      }
   }

}


bool isTargetOrder() {
   if (OPM_ALL == _operateMode) return true;
   if (OPM_MagicNumber == _operateMode && OrderMagicNumber() == _targetMagicNumber) return true;
   if (OPM_CurrentWindowSymbol == _operateMode && OrderSymbol() == _Symbol) return true;
   if (OPM_MagicNumber_And_CurrentWindowSymbol == _operateMode && OrderMagicNumber() == _targetMagicNumber && OrderSymbol() == _Symbol) return true;
   return false;
}

double getSlByIndicator(string symbolName) {
   double sl = 0.0;
   
   switch (_trailingStopMode) {
      case TSM_MA:
         sl = iMA(symbolName, _tfTsmMa, _tsmMaPeriod, 0, _tsmMaMethod, _tsmMaAppliedPrice, 1);
         break;
      case TSM_Sar:
         sl = iSAR(symbolName, _tfTsmSar, _tsmSarStep, _tsmSarMaximum, 1);
         break;
      case TSM_ATR:
         sl = iATR(symbolName, _tfTsmAtr, _tsmAtrPeriod, 1);
         break;
      case TSM_BollingerBands:
         sl = iBands(symbolName, _tfTsmBB, _tsmBBPeriod, _tsmBBDeviation, 0, _tsmBBAppliedPrice, _tsmBBLineIndex, 1);
         break;
      default: break;
   }

   return sl;
}

double getSl4Buy(string symbolName) {
   double sl = 0.0;
   double vpoint = MarketInfo(symbolName, MODE_POINT);
   switch (_trailingStopMode) {
      case TSM_Fix:
         sl = MarketInfo(symbolName, MODE_BID) - _tsmFixPoint*vpoint;
         break;
      case TSM_MA:
      case TSM_Sar:
      case TSM_ATR:
      case TSM_BollingerBands:
         sl = getSlByIndicator(symbolName);
         sl += _offsetPoint*vpoint;
         break;
      default: break;
   }

   return NormalizeDouble(sl, (int) MarketInfo(symbolName, MODE_DIGITS));
}

double getSl4Sell(string symbolName) {
   double sl = 0.0;
   double vpoint = MarketInfo(symbolName, MODE_POINT);
   switch (_trailingStopMode) {
      case TSM_Fix:
         sl = MarketInfo(symbolName, MODE_ASK) + _tsmFixPoint*vpoint;
         break;
      case TSM_MA:
      case TSM_Sar:
      case TSM_ATR:
      case TSM_BollingerBands:
         sl = getSlByIndicator(symbolName);
         sl -= _offsetPoint*vpoint;
         break;
      default: break;
   }

   return NormalizeDouble(sl, (int) MarketInfo(symbolName, MODE_DIGITS));
}


void modify(double sl) {
   if (OrderModify(OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), 0, clrNONE)) {
      Print("Order modified successfully.", "Ticket ID=", OrderTicket());
   } else {
      Print("Error in OrderModify.", "Ticket ID=", OrderTicket(), " Symbol=", OrderSymbol(), " Error code=", ErrorDescription(GetLastError()));
   }
}


void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}

const int            PanelWidth        = 830;
const int            PanelHeight       = 400;
const string         ObjNamePrefix     = "TS_";
const int            RowHeight         = 35;

void draw() {
   int x = Coordinates_X;
   int y = Coordinates_Y;
   color btnBgColor = clrGray;
   color btnFontColor = clrWhiteSmoke;
   int btnFontSize = 6;
   int lblFontSize = 7;
   color lblFontColor = clrWhite;
   CreatePanel(ObjNamePrefix+"Panel",x,y,PanelWidth,PanelHeight);
   SetText(ObjNamePrefix+"lbl_"+"OPM", "Operate Mode ：", x+3, y+1, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_ALL",                                 "ALL",                          x+15,               y+RowHeight-4,  50, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol",                 "CurrentSymbol",                x+15+50+10,         y+RowHeight-4, 140, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_MagicNumber",                         "MagicNumber",                  x+15+50+140+20,     y+RowHeight-4, 130, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol", "MagicNumber ＆ CurrentSymbol", x+15+50+140+130+30, y+RowHeight-4, 294, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   SetText(ObjNamePrefix+"lbl_"+"OPM_MagicNumber", "Magic Number ：", x+15, y+2*RowHeight, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"OPM_MagicNumber", x+15+170, y+2*RowHeight-4, 474, RowHeight, lblFontSize, "1234567890");
   
   CreateButton(ObjNamePrefix+"btn_"+"EA_Status", "Stopped", x+690, y+RowHeight-4, 130, 4*RowHeight, btnBgColor, btnFontColor, 9);
   
   SetText(ObjNamePrefix+"lbl_"+"TSM", "Trailing Stop Method ：", x+3, y+4*RowHeight, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_Fix",             "Fix",            x+10,       y+5*RowHeight-4,   50, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_MA",              "MA",             x+20+50,    y+5*RowHeight-4,   50, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_Sar",             "Sar",            x+30+100,   y+5*RowHeight-4,   50, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_ATR",             "ATR",            x+40+150,   y+5*RowHeight-4,   50, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_BollingerBands",  "BollingerBands", x+50+200,   y+5*RowHeight-4,  140, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   
   SetText(ObjNamePrefix+"lbl_"+"FixPoint", "Fix Point ：", x+460, y+5*RowHeight-4, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"FixPoint", x+570, y+5*RowHeight-4, 80, RowHeight, lblFontSize, "12345");
   
   SetText(ObjNamePrefix+"lbl_"+"Offset", "Offset Point   ：", x+50, y+6*RowHeight+2, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"Offset", x+210, y+6*RowHeight, 80, RowHeight, lblFontSize, "12345");
   SetText(ObjNamePrefix+"lbl_"+"Period", "Period ：", x+370, y+6*RowHeight+2, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"Period", x+460, y+6*RowHeight, 80, RowHeight, lblFontSize, "123");
   
   SetText(ObjNamePrefix+"lbl_"+"AppliedPrice", "Applied Price ：", x+50, y+7*RowHeight+4, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_CLOSE",      "CLOSE",    x+210,       y+7*RowHeight+4,  78, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_OPEN",       "OPEN",     x+296,       y+7*RowHeight+4,  68, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_HIGH",       "HIGH",     x+372,       y+7*RowHeight+4,  62, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_LOW",        "LOW",      x+442,       y+7*RowHeight+4,  60, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_MEDIAN",     "MEDIAN",   x+510,       y+7*RowHeight+4,  86, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_TYPICAL",    "TYPICAL",  x+604,       y+7*RowHeight+4,  94, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_WEIGHTED",   "WEIGHTED", x+706,       y+7*RowHeight+4,  120, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   
   SetText(ObjNamePrefix+"lbl_"+"Ma_Method", "MA Method    ：", x+50, y+8*RowHeight+4, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_SMA",  "SMA",   x+210,       y+8*RowHeight+4,  78, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_EMA",  "EMA",   x+310,       y+8*RowHeight+4,  78, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_SMMA", "SMMA",  x+410,       y+8*RowHeight+4,  78, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_LWMA", "LWMA",  x+510,       y+8*RowHeight+4,  78, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);

   SetText(ObjNamePrefix+"lbl_"+"SarStep", "Sar Step        ：", x+50, y+9*RowHeight+5, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"SarStep", x+210, y+9*RowHeight+6, 80, RowHeight, lblFontSize, "12345");
   SetText(ObjNamePrefix+"lbl_"+"SarMaximum", "Sar Maximum ：", x+370, y+9*RowHeight+5, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"SarMaximum", x+530, y+9*RowHeight+6, 80, RowHeight, lblFontSize, "123");
   
   SetText(ObjNamePrefix+"lbl_"+"BB_Deviation", "BB Deviation ：", x+50, y+10*RowHeight+8, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"BB_Deviation", x+210, y+10*RowHeight+9, 80, RowHeight, lblFontSize, "12345");
   SetText(ObjNamePrefix+"lbl_"+"BB_LineIndex", "BB LineIndex  ：", x+370, y+10*RowHeight+8, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"BB_MAIN",  "MAIN",   x+530,       y+10*RowHeight+9,  82, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"BB_UPPER",  "UPPER",   x+620,       y+10*RowHeight+9,  82, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"BB_LOWER", "LOWER",  x+710,       y+10*RowHeight+9,  82, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
}


void SetText(string name,string text,int x,int y,color fontColor,int fontSize=8) {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(chartId,name,OBJPROP_TEXT,text);
}

void SetObjText(string name,string str,int x,int y,color colour,string fontName="Wingdings 3",int fontsize=12) {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(chartId,name,OBJPROP_BACK,false);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(chartId,name,OBJPROP_TEXT,str);
   ObjectSetString(chartId,name,OBJPROP_FONT,fontName);
}

void CreatePanel(string name,int x,int y,int width,int height,color backgroundColor=clrBlack,color borderColor=clrWhite,int borderWidth=1)
  {
   long chartId = 0;
   if(0 < ObjectFind(chartId,name)) ObjectDelete(chartId, name);
   if(ObjectCreate(chartId,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chartId,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chartId,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chartId,name,OBJPROP_COLOR,borderColor);
      ObjectSetInteger(chartId,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(chartId,name,OBJPROP_WIDTH,borderWidth);
      ObjectSetInteger(chartId,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(chartId,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(chartId,name,OBJPROP_BACK,false);
      ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(chartId,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(chartId,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(chartId,name,OBJPROP_ZORDER,0);
      ObjectSetInteger(chartId,name,OBJPROP_BGCOLOR,backgroundColor);
     }
  }

void CreateButton(string btnName,string text,int x,int y,int width,int height,int backgroundColor=clrBlack,int textColor=clrWhite, int fontSize = 8, ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) {
   ResetLastError();
   long chartId = 0;
   if(ObjectFind(chartId,btnName)<0) {
      if(!ObjectCreate(chartId,btnName,OBJ_BUTTON,0,0,0)) {
         Print(__FUNCTION__, ": failed to create the button! Error code = ",ErrorDescription(GetLastError()));
         return;
      }
   }
   ObjectSetString(chartId,btnName,OBJPROP_TEXT,text);
   ObjectSetInteger(chartId,btnName,OBJPROP_XSIZE,width);
   ObjectSetInteger(chartId,btnName,OBJPROP_YSIZE,height);
   ObjectSetInteger(chartId,btnName,OBJPROP_CORNER,corner);
   ObjectSetInteger(chartId,btnName,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,btnName,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,btnName,OBJPROP_BGCOLOR,backgroundColor);
   ObjectSetInteger(chartId,btnName,OBJPROP_COLOR,textColor);
   ObjectSetInteger(chartId,btnName,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,btnName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartId,btnName,OBJPROP_BORDER_TYPE,BORDER_RAISED);

   //ChartRedraw();
}

void CreateEdit(const string           name="Edit",              // object name
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const int              font_size=10,             // font size
                const string           text="Text",              // text
                const string           font="Arial",             // font
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE)       // border color
{
//--- reset the error value
   ResetLastError();
   long chart_ID=0;
   int sub_window=0;
   if(ObjectFind(chart_ID, name)<0) {
//--- create edit field
      if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0)) {
         Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ", ErrorDescription(GetLastError()));
         return;
      }
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
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK, false);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED, false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN, true);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER, 0);
}
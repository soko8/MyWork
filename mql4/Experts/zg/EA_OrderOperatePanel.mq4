//+------------------------------------------------------------------+
//| OrderOperatePanel.mq4 |
//| Copyright 2023, MetaQuotes Software Corp. |
//| https://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link "https://www.mql4.com"
#property version "1.00"
#property strict
#include <stdlib.mqh>
//--- input parameters
/*
input int Input1=1;
input bool Input2=true;
input datetime Input3=D'2023.12.06 22:34:45';
input double Input4=1.0;
input string Input5="a";
*/
input int         In_Offset_Point_CurrentPrice     = 400;
input int         In_Stoploss_Point                = 200;
input int         In_TakeProfit_Point              = 300;
input double      In_Lots                          = 0.01;
input int         Magic_Number                     = 168;
input bool        In_4Kdisplay                     = true;

const int StartX=4;
const int StartY=4;

const string   ObjNamePrefix  ="OO_";
const int      slippage       = 0;
const string   COMMENT        = "OOP_Order";

const color          ClrBtnBgSelected  = clrGreenYellow;
const color          ClrBtnFtSelected  = clrBlack;
const color          ClrBtnBg          = clrGray;
const color          ClrBtnFt          = clrWhiteSmoke;


int offsetPoint, slPoint, tpPoint, trade_operation=-1;
double lots, offset, sl, tp;

int OnInit() {
   offsetPoint = In_Offset_Point_CurrentPrice;
   slPoint = In_Stoploss_Point;
   tpPoint = In_TakeProfit_Point;
   lots = In_Lots;
   offset = NormalizeDouble(offsetPoint*Point, Digits);
   sl = NormalizeDouble(slPoint*Point, Digits);
   tp = NormalizeDouble(tpPoint*Point, Digits);

   if (In_4Kdisplay) draw4k(); else draw();
   
   checkInputLot();
   checkInputSl();
   checkInputTp();
   
   EventSetTimer(60);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll(0, ObjNamePrefix);
}

void OnTick() {}

void OnTimer() {
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (CHARTEVENT_OBJECT_CLICK == id) {
      if (ObjNamePrefix+"btn_"+"buy" == sparam) {
         trade_operation = OP_BUY;
         setBtnEnable(sparam);
         setBtnDisable(ObjNamePrefix+"btn_"+"sell");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyStop");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellStop");
      } else
      if (ObjNamePrefix+"btn_"+"sell" == sparam) {
         trade_operation = OP_SELL;
         setBtnEnable(sparam);
         setBtnDisable(ObjNamePrefix+"btn_"+"buy");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyStop");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellStop");
      } else
      if (ObjNamePrefix+"btn_"+"buyLimit" == sparam) {
         trade_operation = OP_BUYLIMIT;
         setBtnEnable(sparam);
         setBtnDisable(ObjNamePrefix+"btn_"+"buy");
         setBtnDisable(ObjNamePrefix+"btn_"+"sell");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyStop");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellStop");
      } else
      if (ObjNamePrefix+"btn_"+"sellLimit" == sparam) {
         trade_operation = OP_SELLLIMIT;
         setBtnEnable(sparam);
         setBtnDisable(ObjNamePrefix+"btn_"+"buy");
         setBtnDisable(ObjNamePrefix+"btn_"+"sell");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyStop");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellStop");
      } else
      if (ObjNamePrefix+"btn_"+"buyStop" == sparam) {
         trade_operation = OP_BUYSTOP;
         setBtnEnable(sparam);
         setBtnDisable(ObjNamePrefix+"btn_"+"buy");
         setBtnDisable(ObjNamePrefix+"btn_"+"sell");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellStop");
      } else
      if (ObjNamePrefix+"btn_"+"sellStop" == sparam) {
         trade_operation = OP_SELLSTOP;
         setBtnEnable(sparam);
         setBtnDisable(ObjNamePrefix+"btn_"+"buy");
         setBtnDisable(ObjNamePrefix+"btn_"+"sell");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"sellLimit");
         setBtnDisable(ObjNamePrefix+"btn_"+"buyStop");
      } else
      if (ObjNamePrefix+"btn_"+"NewOrder" == sparam) {
         bool error = checkInputLot();
         error = error || checkInputSl();
         error = error || checkInputTp();
         if (error) return;
         if (OP_BUY != trade_operation && OP_SELL != trade_operation) {
            if (offsetPoint < 1) {
               ObjectSetInteger(0, ObjNamePrefix+"edt_"+"Offset_Point", OBJPROP_BGCOLOR, clrRed);
               Alert("Offset Point is invalid.");
               return;
            }
            ObjectSetInteger(0, ObjNamePrefix+"edt_"+"Offset_Point", OBJPROP_BGCOLOR, clrWhite);
         }
         if (trade_operation < 0 || 5 < trade_operation) Alert("trade operation not select");
         else if (createOrder()) {
            switch (trade_operation) {
               case OP_BUY:
                  setBtnDisable(ObjNamePrefix+"btn_"+"buy");
                  break;
               case OP_SELL:
                  setBtnDisable(ObjNamePrefix+"btn_"+"sell");
                  break;
               case OP_BUYLIMIT:
                  setBtnDisable(ObjNamePrefix+"btn_"+"buyLimit");
                  break;
               case OP_SELLLIMIT:
                  setBtnDisable(ObjNamePrefix+"btn_"+"sellLimit");
                  break;
               case OP_BUYSTOP:
                  setBtnDisable(ObjNamePrefix+"btn_"+"buyStop");
                  break;
               case OP_SELLSTOP:
                  setBtnDisable(ObjNamePrefix+"btn_"+"sellStop");
                  break;
               default: break;
            }
         }
      }
   }
   else if (CHARTEVENT_OBJECT_ENDEDIT == id) {
      if (ObjNamePrefix+"edt_"+"Offset_Point" == sparam) {
         offsetPoint = StrToInteger(ObjectGetString(0, sparam, OBJPROP_TEXT));
         offset = NormalizeDouble(offsetPoint*Point, Digits);
      } else

      if (ObjNamePrefix+"edt_"+"lots" == sparam) {
         lots = StrToInteger(ObjectGetString(0, sparam, OBJPROP_TEXT));
      } else

      if (ObjNamePrefix+"edt_"+"tp" == sparam) {
         tpPoint = StrToInteger(ObjectGetString(0, sparam, OBJPROP_TEXT));
         tp = NormalizeDouble(tpPoint*Point, Digits);
      } else

      if (ObjNamePrefix+"edt_"+"sl" == sparam) {
         slPoint = StrToInteger(ObjectGetString(0, sparam, OBJPROP_TEXT));
         sl = NormalizeDouble(slPoint*Point, Digits);
      }
   }
}

bool createOrder() {
   double openPrice = 0.0, slPrice = 0.0, tpPrice = 0.0;

   switch (trade_operation) {
      case OP_BUY:
         openPrice = Ask;
         if (0 < slPoint) slPrice = Bid - sl;
         if (0 < tpPoint) tpPrice = Bid + tp;
         break;
      case OP_SELL:
         openPrice = Bid;
         if (0 < slPoint) slPrice = Ask + sl;
         if (0 < tpPoint) tpPrice = Ask - tp;
         break;
      case OP_BUYLIMIT:
         openPrice = Ask - offset;
         if (0 < slPoint) slPrice = openPrice - sl;
         if (0 < tpPoint) tpPrice = openPrice + tp;
         break;
      case OP_SELLLIMIT:
         openPrice = Bid + offset;
         if (0 < slPoint) slPrice = openPrice + sl;
         if (0 < tpPoint) tpPrice = openPrice - tp;
         break;
      case OP_BUYSTOP:
         openPrice = Ask + offset;
         if (0 < slPoint) slPrice = openPrice - sl;
         if (0 < tpPoint) tpPrice = openPrice + tp;
         break;
      case OP_SELLSTOP:
         openPrice = Bid - offset;
         if (0 < slPoint) slPrice = openPrice + sl;
         if (0 < tpPoint) tpPrice = openPrice - tp;
         break;
      default: break;
   }
   
   openPrice = NormalizeDouble(openPrice, Digits);
   slPrice = NormalizeDouble(slPrice, Digits);
   tpPrice = NormalizeDouble(tpPrice, Digits);

   int ticket = OrderSend(_Symbol, trade_operation, lots, openPrice, slippage, slPrice, tpPrice, COMMENT, Magic_Number, 0, clrNONE);
   
   if (ticket < 0) {Print("OrderSend failed with error #", ErrorDescription(GetLastError()), " Symbol=", _Symbol); return false;}
   
   Print("OrderSend placed successfully. Ticket ID=", ticket, " Symbol=", _Symbol);
   return true;
}

bool checkInputLot() {
   bool isError = false;
   isError = !isValidLot(lots);
   if (isError) {
      ObjectSetInteger(0, ObjNamePrefix+"edt_"+"lots", OBJPROP_BGCOLOR, clrRed);
   } else {
      ObjectSetInteger(0, ObjNamePrefix+"edt_"+"lots", OBJPROP_BGCOLOR, clrWhite);
   }
   return isError;
}

bool checkInputSl() {
   bool isError = false;
   isError = !isValidStopLevel(slPoint);
   if (isError) {
      ObjectSetInteger(0, ObjNamePrefix+"edt_"+"sl", OBJPROP_BGCOLOR, clrRed);
   } else {
      ObjectSetInteger(0, ObjNamePrefix+"edt_"+"sl", OBJPROP_BGCOLOR, clrWhite);
   }
   return isError;
}

bool checkInputTp() {
   bool isError = false;
   isError = !isValidStopLevel(tpPoint);
   if (isError) {
      ObjectSetInteger(0, ObjNamePrefix+"edt_"+"tp", OBJPROP_BGCOLOR, clrRed);
   } else {
      ObjectSetInteger(0, ObjNamePrefix+"edt_"+"tp", OBJPROP_BGCOLOR, clrWhite);
   }
   return isError;
}

bool isValidLot(double lot) {
   double minLot = MarketInfo(_Symbol, MODE_MINLOT);
   if (lot < minLot) {
      Print("The lot(", lot, ") is less than the Minimum permitted amount of a lot(", minLot, ").");
      return false;
   }
   
   double maxLot = MarketInfo(_Symbol, MODE_MAXLOT);
   if (maxLot < lot) {
      Print("The lot(", lot, ") is greater than the Maximum permitted amount of a lot(", maxLot, ").");
      return false;
   }
   
   return true;
}

bool isValidStopLevel(int inputPoint) {
   int stopLevel = (int) MarketInfo(_Symbol, MODE_STOPLEVEL);
   if (0 == stopLevel) return true;
   if (inputPoint < stopLevel) {
      Print("The input point(", inputPoint, ") is less than the Minimum permitted amount of stop level(", stopLevel, ").");
      return false;
   }
   return true;
} 

void draw4k() {
   const int            PanelWidth        = 450;
   const int            PanelHeight       = 160;
   const int            RowHeight         = 35;
   const int            btnFontSize       = 7;
   const int            lblFontSize       = 7;
   const int            edtFontSize       = 12;
   const color          lblFontColor      = clrWhite;
   const int            RowHeightEdt      = 35;
   const int            MarginLeft        = 6;
   const int            MarginTop         = 6;
   const int            Interval          = 2;

   string objName = ObjNamePrefix+"Panel";
   int x = StartX;
   int y = StartY;
   CreatePanel(objName,x,y,PanelWidth,PanelHeight);

   objName = ObjNamePrefix+"btn_"+"buyStop";
   x += MarginLeft;
   y += MarginTop;
   CreateButton(objName,    "Buy Stop",    x, y, 100, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"sellLimit";
   x += (100 + Interval);
   CreateButton(objName,  "Sell Limit",  x, y, 100, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"buy";
   x = StartX + MarginLeft;
   y += RowHeight + Interval;
   CreateButton(objName,        "Buy",         x, y, 50, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"edt_"+"Offset_Point";
   x += (50 + Interval -1);
   CreateEdit(objName,                x, y, 100, RowHeightEdt,edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(offsetPoint));

   objName = ObjNamePrefix+"btn_"+"sell";
   x += (100 + Interval -1);
   CreateButton(objName,       "Sell",        x, y, 50, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"buyLimit";
   x = StartX + MarginLeft;
   y += RowHeight + Interval;
   CreateButton(objName,   "Buy Limit",   x, y, 100, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"sellStop";
   x += (100 + Interval);
   CreateButton(objName,   "Sell Stop",   x, y, 100, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"NewOrder";
   x = StartX + MarginLeft;
   y += RowHeight + Interval;
   CreateButton(objName,   "New Order",   x, y, 202, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);
   
   objName = ObjNamePrefix+"lbl_"+"tp";
   x = StartX + MarginLeft + 10*Interval + 100*2;
   y = StartY + MarginTop;
   SetText(objName, "TP  :",   x, y, lblFontColor, lblFontSize);
   objName = ObjNamePrefix+"edt_"+"tp";
   x += 70;
   CreateEdit(objName,          x, y, 150, RowHeightEdt, edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(tpPoint));
   
   objName = ObjNamePrefix+"lbl_"+"lots";
   x = StartX + MarginLeft + 10*Interval + 100*2;
   y = StartY + MarginTop + RowHeight + Interval;
   SetText(objName, "Lots:", x, y, lblFontColor, lblFontSize);
   objName = ObjNamePrefix+"edt_"+"lots";
   x += 70;
   CreateEdit(objName,        x, y, 150, RowHeightEdt, edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToStr(lots, 2));
   
   objName = ObjNamePrefix+"lbl_"+"sl";
   x = StartX + MarginLeft + 10*Interval + 100*2;
   y = StartY + MarginTop + 2*RowHeight + 2*Interval;
   SetText(objName, "SL  :",   x, y, lblFontColor, lblFontSize);
   objName = ObjNamePrefix+"edt_"+"sl";
   x += 70;
   CreateEdit(objName,          x, y, 150, RowHeightEdt, edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(slPoint));
}

void draw() {
   const int            PanelWidth        = 236;
   const int            PanelHeight       = 99;
   const int            RowHeight         = 21;
   const int            btnFontSize       = 6;
   const int            lblFontSize       = 7;
   const int            edtFontSize       = 8;
   const color          lblFontColor      = clrWhite;
   const int            RowHeightEdt      = 21;
   const int            MarginLeft        = 6;
   const int            MarginTop         = 6;
   const int            Interval          = 2;

   string objName = ObjNamePrefix+"Panel";
   int x = StartX;
   int y = StartY;
   CreatePanel(objName,x,y,PanelWidth,PanelHeight);

   objName = ObjNamePrefix+"btn_"+"buyStop";
   x += MarginLeft;
   y += MarginTop;
   CreateButton(objName,    "Buy Stop",    x, y, 60, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"sellLimit";
   x += (60 + Interval);
   CreateButton(objName,  "Sell Limit",  x, y, 60, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"buy";
   x = StartX + MarginLeft;
   y += RowHeight + Interval;
   CreateButton(objName,        "Buy",         x, y, 30, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"edt_"+"Offset_Point";
   x += (30 + Interval -1);
   CreateEdit(objName,                x, y, 60, RowHeightEdt,edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(offsetPoint));

   objName = ObjNamePrefix+"btn_"+"sell";
   x += (60 + Interval -1);
   CreateButton(objName,       "Sell",        x, y, 30, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"buyLimit";
   x = StartX + MarginLeft;
   y += RowHeight + Interval;
   CreateButton(objName,   "Buy Limit",   x, y, 60, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"sellStop";
   x += (60 + Interval);
   CreateButton(objName,   "Sell Stop",   x, y, 60, RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);

   objName = ObjNamePrefix+"btn_"+"NewOrder";
   x = StartX + MarginLeft;
   y += RowHeight + Interval;
   CreateButton(objName,   "New Order",   x, y, 123,RowHeight, ClrBtnBg, ClrBtnFt, btnFontSize);
   
   objName = ObjNamePrefix+"lbl_"+"tp";
   x = StartX + MarginLeft + 4*Interval + 60*2;
   y = StartY + MarginTop;
   SetText(objName, "TP   :",   x, y, lblFontColor, lblFontSize);
   objName = ObjNamePrefix+"edt_"+"tp";
   x += 40;
   CreateEdit(objName,          x, y, 60, RowHeightEdt, edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(tpPoint));
   
   objName = ObjNamePrefix+"lbl_"+"lots";
   x = StartX + MarginLeft + 4*Interval + 60*2;
   y = StartY + MarginTop + RowHeight + Interval;
   SetText(objName, "Lots :", x, y, lblFontColor, lblFontSize);
   objName = ObjNamePrefix+"edt_"+"lots";
   x += 40;
   CreateEdit(objName,        x, y, 60, RowHeightEdt, edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToStr(lots, 2));
   
   objName = ObjNamePrefix+"lbl_"+"sl";
   x = StartX + MarginLeft + 4*Interval + 60*2;
   y = StartY + MarginTop + 2*RowHeight + 2*Interval;
   SetText(objName, "SL   :",   x, y, lblFontColor, lblFontSize);
   objName = ObjNamePrefix+"edt_"+"sl";
   x += 40;
   CreateEdit(objName,          x, y, 60, RowHeightEdt, edtFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(slPoint));
}

void setBtnEnable(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,ClrBtnBgSelected);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,ClrBtnFtSelected);
}

void setBtnDisable(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,ClrBtnBg);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,ClrBtnFt);
}

/**
 * link:   https://en.wikipedia.org/wiki/List_of_typefaces_included_with_Microsoft_Windows
 * monospace fonts:
 *   Courier New
 *   Lucida Sans Typewriter
 *   Cascadia Code
 *   Consolas
 *   Lucida Console
 *   Fixedsys
 */
void SetText(string name,string text,int x,int y,color fontColor,int fontSize=8, string font="Lucida Sans Typewriter") {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(chartId,name,OBJPROP_TEXT,text);
   ObjectSetString(chartId,name,OBJPROP_FONT,font);
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

/*
   font : "Times New Roman"  "Microsoft Sans Serif"  "Cambria"  "Georgia"  "Impact"   "Tahoma"
*/
void CreateButton(string btnName,string text,int x,int y,int width,int height,int backgroundColor=clrBlack
                  ,int textColor=clrWhite, int fontSize = 8, string font="Tahoma", ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) {
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
   ObjectSetString(chartId,btnName,OBJPROP_FONT,font);
}


void CreateEdit(const string           name="Edit",              // object name
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const int              font_size=10,             // font size
                const string           text="Text",              // text
                const string           font="Fixedsys",          // font
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

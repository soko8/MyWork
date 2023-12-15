//+------------------------------------------------------------------+
//|                                                 EA_NewsTrade.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

input int            In_Seconds              = 300;
input int            In_Offset_Point         = 100;
input double         In_Lots                 = 0.01;
input int            In_Stoploss_Point       = 200;
input int            In_TakeProfit_Point     = 30000;
input int            Magic_Number            = 88888;


datetime newsTime = D'2023.12.06 22:34:45';  // Local Time
bool Stop_EA=true, isCreated=false;
bool NeedDeletePendingOrder=true, isDeletedPendingOrder=false;


int seconds, offsetPoint, slPoint, tpPoint, openedOrderTicket=-1;
double lots, offset, sl, tp;

const int slippage = 0;
const string COMMENT = "News Trade";
const string ObjNamePrefix = "NsTd_";

const string TxtStatusStop = "Stopped";
const string TxtStatusRun = "Running";

const color          ClrBtnBgEnabled   = clrGreen;
const color          ClrBtnFtEnabled   = clrBlack;
const color          ClrBtnBg          = clrGray;
const color          ClrBtnFt          = clrWhiteSmoke;

int OnInit() {
   seconds = In_Seconds;
   offsetPoint = In_Offset_Point;
   lots = In_Lots;
   slPoint = In_Stoploss_Point;
   tpPoint = In_TakeProfit_Point;
   offset = NormalizeDouble(offsetPoint*Point, Digits);
   sl = NormalizeDouble(slPoint*Point, Digits);
   tp = NormalizeDouble(tpPoint*Point, Digits);

   draw();
   //EventSetTimer(1);
   

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   //EventKillTimer();
   ObjectsDeleteAll(0, ObjNamePrefix);
}

void OnTick() {
   if (Stop_EA) {
      return;
   }
   datetime nowLocalTime = TimeLocal();
   if (!isCreated && nowLocalTime < newsTime && newsTime <= nowLocalTime+seconds) {
      double openPrice = 0.0, slPrice = 0.0, tpPrice = 0.0;
      
      openPrice = Ask + offset;
      if (0 < slPoint) slPrice = openPrice - sl;
      if (0 < tpPoint) tpPrice = openPrice + tp;
      openPrice = NormalizeDouble(openPrice, Digits);
      slPrice = NormalizeDouble(slPrice, Digits);
      tpPrice = NormalizeDouble(tpPrice, Digits);
      int ticket = OrderSend(_Symbol, OP_BUYSTOP, lots, openPrice, slippage, slPrice, tpPrice, COMMENT, Magic_Number, 0, clrNONE);
      if (ticket < 0) Print("OrderSend(BUYSTOP) failed with error #", ErrorDescription(GetLastError()), " Symbol=", _Symbol);
      else Print("OrderSend placed successfully. Ticket ID=", ticket, " Symbol=", _Symbol);
      
      openPrice = Bid - offset;
      if (0 < slPoint) slPrice = openPrice + sl;
      if (0 < tpPoint) tpPrice = openPrice - tp;
      openPrice = NormalizeDouble(openPrice, Digits);
      slPrice = NormalizeDouble(slPrice, Digits);
      tpPrice = NormalizeDouble(tpPrice, Digits);
      ticket = OrderSend(_Symbol, OP_SELLSTOP, lots, openPrice, slippage, slPrice, tpPrice, COMMENT, Magic_Number, 0, clrNONE);
      if (ticket < 0) Print("OrderSend(SELLSTOP) failed with error #", ErrorDescription(GetLastError()), " Symbol=", _Symbol);
      else Print("OrderSend placed successfully. Ticket ID=", ticket, " Symbol=", _Symbol);
   }
   else if (newsTime < nowLocalTime) {
      if (openedOrderTicket < 0) {
         for (int i=OrdersTotal()-1; 0<=i; i--) {
            if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
               if (Magic_Number == OrderMagicNumber() && _Symbol == OrderSymbol()) {
                  if (OP_BUY == OrderType() || OP_SELL == OrderType()) openedOrderTicket = OrderTicket();
               }
            } else {
               Print("Failed to call OrderSelect() method for position #", i, " Error code=", ErrorDescription(GetLastError()));
            }
         }
      }
      trailing_stop();
   }
   
}

void trailing_stop() {
   if (openedOrderTicket < 0) return;
   if (NeedDeletePendingOrder && !isDeletedPendingOrder) {
      for (int i=OrdersTotal()-1; 0<=i; i--) {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (Magic_Number == OrderMagicNumber() && _Symbol == OrderSymbol()) {
               if (OP_BUY != OrderType() && OP_SELL != OrderType()) {
                  if (OrderDelete(OrderTicket())) isDeletedPendingOrder = true;
                  else Print("Failed to delete order #", OrderTicket(), " Error code=", ErrorDescription(GetLastError()));
               }
            }
         } else {
            Print("Failed to call OrderSelect() method for position #", i, " Error code=", ErrorDescription(GetLastError()));
         }
      }
   }
   
   if(OrderSelect(openedOrderTicket, SELECT_BY_TICKET)) {
      double slPrice = 0.0;
      double slOrder = OrderStopLoss();
      if (OP_BUY == OrderType()) {
         slPrice = NormalizeDouble(Bid - sl, Digits);
         if (slOrder < slPrice) modify(slPrice);
      } else {
         slPrice = NormalizeDouble(Ask + sl, Digits);
         if (slPrice < slOrder) modify(slPrice);
      }
   
   } else {
      Print("Failed to call OrderSelect() method for ticket #", openedOrderTicket, " Error code=", ErrorDescription(GetLastError()));
   }
   
}

void modify(double slPrice) {
   if (OrderModify(OrderTicket(), OrderOpenPrice(), slPrice, OrderTakeProfit(), 0, clrNONE)) {
      Print("Order modified successfully.", "Ticket ID=", OrderTicket());
   } else {
      Print("Error in OrderModify.", "Ticket ID=", OrderTicket(), " Symbol=", OrderSymbol(), " Error code=", ErrorDescription(GetLastError()));
   }
}

void OnTimer() {
//---
   
}

bool isValidNewsTime() {
   string objName = ObjNamePrefix+"edt_"+"NewsTime";
   string newsTimeStr = ObjectGetString(0, objName, OBJPROP_TEXT);
   StringReplace(newsTimeStr, "-", ".");
   StringReplace(newsTimeStr, "/", ".");
   int strLength = StringLen(newsTimeStr);
   if (4 != strLength && 5 != strLength && 10 != strLength && 11 != strLength && 16 != strLength) return false;
   int pos = StringFind(newsTimeStr, ":");
   if (pos < 0) return false;
   
   for (int i=0; i<strLength; i++) {
      ushort charCd = StringGetChar(newsTimeStr, i);
      // (space)
      if (32 == charCd) continue;
      // -./0123456789:
      if (45 <= charCd && charCd <= 58) continue;
      return false;
   }
   
   return true;
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (CHARTEVENT_OBJECT_CLICK == id) {
      if (ObjNamePrefix+"btn_"+"EA_Status" == sparam) {
         if (Stop_EA) {
            bool isValidTime = isValidNewsTime();
            if (!isValidTime) {
               ObjectSetInteger(0,ObjNamePrefix+"edt_"+"NewsTime",OBJPROP_BGCOLOR,clrRed);
               return;
            }
            Stop_EA = false;
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,ClrBtnBgEnabled);
            ObjectSetInteger(0,sparam,OBJPROP_COLOR,ClrBtnFtEnabled);
            
         } else {
            Stop_EA = true;
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,ClrBtnBg);
            ObjectSetInteger(0,sparam,OBJPROP_COLOR,ClrBtnFt);
         }
      }
   } else
   if (CHARTEVENT_OBJECT_ENDEDIT == id) {
      if (ObjNamePrefix+"edt_"+"NewsTime" == sparam) {
         string newsTimeStr = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (!isValidNewsTime()) {
            ObjectSetInteger(0, sparam, OBJPROP_BGCOLOR, clrRed);
            return;
         }
         
         StringReplace(newsTimeStr, "-", ".");
         StringReplace(newsTimeStr, "/", ".");
         newsTime = StrToTime(newsTimeStr);
         if (newsTime < TimeLocal()) {
            Alert("It is not a future time.");
            ObjectSetInteger(0, sparam, OBJPROP_BGCOLOR, clrRed);
         } else {
            ObjectSetInteger(0, sparam, OBJPROP_BGCOLOR, clrWhite);
         }
      }
   }
}

void draw() {
   const int PanelWidth = 168;
   const int PanelHeight = 158;
   const int Start_X = 6;
   const int Start_Y = 6;
   const int MarginLeft = 6;
   const int MarginTop = 6;
   const int RowHeight = 21;
   const int RowHeightEdt = 23;
   const int Interval = 2;
   
   const int   lblFontSize    = 8;
   const color lblFontColor   = clrWhite;
   const int   edtFontSize    = 9;
   
   string objName = ObjNamePrefix+"Panel";
   int x = Start_X;
   int y = Start_Y;
   CreatePanel(objName, x, y, PanelWidth, PanelHeight);
   
   objName = ObjNamePrefix+"lbl_"+"NewsTime";
   x += MarginLeft;
   y += MarginTop;
   SetText(objName, "News Time :",  x, y, lblFontColor, lblFontSize);

   objName = ObjNamePrefix+"edt_"+"NewsTime";
   //x += (30 + Interval -1);
   y += RowHeight;
   CreateEdit(objName,              x, y, 160, RowHeightEdt, edtFontSize, "2023-12-06 22:34");
   //ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(offsetPoint));
   
   objName = ObjNamePrefix+"lbl_"+"NewsTimeTips1";
   y += RowHeight;
   SetText(objName, "Local Time 24h",  x+MarginLeft, y, lblFontColor, lblFontSize-1);
   objName = ObjNamePrefix+"lbl_"+"NewsTimeTips2";
   y += RowHeight-7;
   SetText(objName, "hh:mi",  x+MarginLeft, y, lblFontColor, lblFontSize-1);
   objName = ObjNamePrefix+"lbl_"+"NewsTimeTips3";
   y += RowHeight-7;
   SetText(objName, "mm.dd hh:mi",  x+MarginLeft, y, lblFontColor, lblFontSize-1);
   objName = ObjNamePrefix+"lbl_"+"NewsTimeTips4";
   y += RowHeight-7;
   SetText(objName, "yyyy.mm.dd hh:mi",  x+MarginLeft, y, lblFontColor, lblFontSize-1);
   
   objName = ObjNamePrefix+"btn_"+"EA_Status";
   y += RowHeight;
   CreateButton(objName, TxtStatusStop, x, y, 100, 2*RowHeight, ClrBtnBg, ClrBtnFt, 9);
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
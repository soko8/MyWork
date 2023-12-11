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
input int         In_Offset_Point_CurrentPrice     = 200;
input int         In_Stoploss_Point                = 200;
input int         In_TakeProfit_Point              = 300;
input double      In_Lots                          = 0.01;
input int         Magic_Number                     = 168;

const int StartX=4;
const int StartY=4;
const int PanelWidth=400;
const int PanelHeight=160;
const string ObjNamePrefix="OO_";
const int slippage = 0;
const string COMMENT = "OOP_Order";

const int            RowHeight         = 35;

int offsetPoint, slPoint, tpPoint, trade_operation;
double lots, offset, sl, tp;

int OnInit() {
   offsetPoint = In_Offset_Point_CurrentPrice;
   slPoint = In_Stoploss_Point;
   tpPoint = In_TakeProfit_Point;
   lots = In_Lots;
   offset = NormalizeDouble(offsetPoint*Point, Digits);
   sl = NormalizeDouble(slPoint*Point, Digits);
   tp = NormalizeDouble(tpPoint*Point, Digits);

   int x = StartX;
   int y = StartY;
   color btnBgColor = clrGray;
   color btnFontColor = clrWhiteSmoke;
   int btnFontSize = 6;
   int lblFontSize = 7;
   color lblFontColor = clrWhite;
   CreatePanel(ObjNamePrefix+"Panel",x,y,PanelWidth,PanelHeight);
   CreateButton(ObjNamePrefix+"btn_"+"buyStop",    "Buy Stop",    x+12,    y+12,             100, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"sellLimit",  "Sell Limit",  x+116,   y+12,             100, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"buy",        "Buy",         x+12,    y+RowHeight+12,    50, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"Offset_Point",                x+14+50, y+RowHeight+11,   100, RowHeight,   lblFontSize, "12345");
   CreateButton(ObjNamePrefix+"btn_"+"sell",       "Sell",        x+166,   y+RowHeight+12,    50, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"buyLimit",   "Buy Limit",   x+12,    y+2*RowHeight+12, 100, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"sellStop",   "Sell Stop",   x+116,   y+2*RowHeight+12, 100, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   
   CreateButton(ObjNamePrefix+"btn_"+"NewOrder", "New Order", x+12, y+3*RowHeight+12, 204, RowHeight-4, btnBgColor, btnFontColor, btnFontSize);
   
   SetText(ObjNamePrefix+"lbl_"+"tp", "   TP ：", x+222, y+12, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"tp", x+290, y+10, 100, RowHeight, lblFontSize, "12345");
   
   SetText(ObjNamePrefix+"lbl_"+"lots", "Lots ：", x+222, y+RowHeight+11, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"lots", x+290, y+RowHeight+11, 100, RowHeight, lblFontSize, "12345");
   
   SetText(ObjNamePrefix+"lbl_"+"sl", "   SL ：", x+222, y+2*RowHeight+12, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"sl", x+290, y+2*RowHeight+12, 100, RowHeight, lblFontSize, "12345");
   
//--- create timer
   EventSetTimer(60);

//---
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();
}

void OnTick() {

}

void OnTimer() {
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

}

void createOrder() {
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
   
   if (ticket < 0) Print("OrderSend failed with error #", ErrorDescription(GetLastError()), " Symbol=", _Symbol);
   else Print("OrderSend placed successfully. Ticket ID=", ticket, " Symbol=", _Symbol);
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

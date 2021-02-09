//+------------------------------------------------------------------+
//|                                                DrawHandOfGod.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+
const int RowInterval=0;
const int ColumnInterval=0;
const int RowHeight=40;

const string Font_Name = "Lucida Bright";
const int Font_Size = 8;
const int Border_Width = 1;
                                           //  1              2              3              4          5             6             7          8             9              10         11            12            13
const string   ColumnName[13]              ={ "Num",         "ticketL",     "OpenPriceL",  "LotsL",   "ProfitL",    "OrderTypeL", "CloseL",  "ticketS",    "OpenPriceS",  "LotsS",   "ProfitS",    "OrderTypeS", "CloseS"   };
const string   ColumnType[13]              ={ "lbl",         "lbl",         "lbl",         "lbl",     "lbl",        "lbl",        "btn",     "lbl",        "lbl",         "lbl",     "lbl",        "lbl",        "btn"      };
const string   ColumnShow[13]              ={ "99",          "12345678",    "1234.12345",  "9999.99", "99999.99",   "Trend",      "CloseL",  "12345678",   "9999.99999",  "9999.99", "99999.99",   "Retrace",    "CloseS"   };
const int      ColumnWidth[13]             ={  46,            180,           180,           120,       160,          120,          130,       180,          180,           120,       160,          120,          130       };
const int      ColumnWidthAdjust[13]       ={  8,             24,            18,            10,        24,           12,            4,        24,           18,            10,        24,           12,            4        };
const color    ColumnColor[13]             ={ clrWhite,      clrWhite,      clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite,  clrWhite,     clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite   };
const color    ColumnColorBackground[13]   ={ clrBlack,      clrBlack,      clrBlack,      clrBlack,  clrBlack,     clrBlack,     clrBlack,  clrBlack,     clrBlack,      clrBlack,  clrBlack,     clrBlack,     clrBlack   };
const color    ColumnColorBorder[13]       ={ clrWhite,      clrWhite,      clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite,  clrWhite,     clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite   };

const string   h1ColumnType[13]            ={ "lbl",         "lbl",         "lbl",         "lbl",     "lbl",        "lbl",        "btn",     "lbl",        "lbl",         "lbl",     "lbl",        "lbl",        "btn"      };
const string   h1ColumnShow[13]            ={ "No",          "Ticket Id L", "Open Price",  "Lot",     "Profit",     "Type",       "CloseAL", "Ticket Id S","Open Price",  "Lot",     "Profit",     "Type",       "CloseAS"  };
const int      h1ColumnWidth[13]           ={  46,            180,           180,           120,       160,          120,          130,       180,          180,           120,       160,          120,          130       };
const int      h1ColumnWidthAdjust[13]     ={  6,             35,            20,            40,        40,           30,           4,         35,           20,            40,        40,           30,           4         };
const color    h1ColumnColor[13]           ={ clrWhite,      clrWhite,      clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite,  clrWhite,     clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite   };
const color    h1ColumnColorBackground[13] ={ clrDarkViolet, clrNavy,       clrNavy,       clrNavy,   clrNavy,      clrNavy,      clrNavy,   clrMaroon,    clrMaroon,     clrMaroon, clrMaroon,    clrMaroon,    clrMaroon  };
const color    h1ColumnColorBorder[13]     ={ clrWhite,      clrWhite,      clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite,  clrWhite,     clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite   };

const string   sumColumnType[13]           ={ "btn",         "lbl",         "lbl",         "lbl",     "lbl",        "lbl",        "btn",     "lbl",        "lbl",         "lbl",     "lbl",        "lbl",        "btn"      };
const string   sumColumnShow[13]           ={ "E",           "Total",       "",            "Sum Lot", "Sum Profit", "",           "ClosePL", "",           "",            "Sum Lot", "Sum Profit", "",           "ClosePS"  };
const int      sumColumnWidth[13]          ={  46,            180,           180,           120,       160,          120,          130,       180,          180,           120,       160,          120,          130       };
const int      sumColumnWidthAdjust[13]    ={  6,             35,            20,            6,         6,            30,           4,         35,           20,            6,         6,            30,           4         };
const color    sumColumnColor[13]          ={ clrBlack,      clrWhite,      clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite,  clrWhite,     clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite   };
const color    sumColumnColorBackground[13]={ clrLime,       clrIndigo,     clrIndigo,     clrIndigo, clrIndigo,    clrIndigo,    clrIndigo, clrIndigo,    clrIndigo,     clrIndigo, clrIndigo,    clrIndigo,    clrIndigo  };
const color    sumColumnColorBorder[13]    ={ clrWhite,      clrWhite,      clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite,  clrWhite,     clrWhite,      clrWhite,  clrWhite,     clrWhite,     clrWhite   };


void draw(int rowCount) export {
   DrawSum(2, 20);
   DrawHeader(2, 60);
   DrawData(rowCount, 2, 100);
}

void DrawSum(int startXi, int startYi) {
   int x = startXi;
   int y = startYi;

   const string pNamePrefix = "Rec";
   const string hNamePrefix1 = "Sum";

   long chartId = 0;
   
   int columnCount = ArraySize(ColumnName);
   for (int colIndex=0; colIndex<columnCount; colIndex++) {
      string columnType = sumColumnType[colIndex];
      if ("lbl"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,sumColumnWidth[colIndex],RowHeight,sumColumnColorBackground[colIndex],sumColumnColorBorder[colIndex],Border_Width);
         SetText(hNamePrefix1+columnType+ColumnName[colIndex],sumColumnShow[colIndex],x+sumColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,sumColumnColor[colIndex]);
         x += sumColumnWidth[colIndex] + ColumnInterval;
      } else if ("btn"==columnType) {
         CreateButton(hNamePrefix1+columnType+ColumnName[colIndex],sumColumnShow[colIndex],x,y,sumColumnWidth[colIndex],RowHeight,sumColumnColorBackground[colIndex],sumColumnColor[colIndex]);
         x += sumColumnWidth[colIndex] + ColumnInterval;
      } else if ("lbo"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,sumColumnWidth[colIndex],RowHeight,sumColumnColorBackground[colIndex],sumColumnColorBorder[colIndex],Border_Width);
         SetObjText(hNamePrefix1+columnType+ColumnName[colIndex],sumColumnShow[colIndex],x+sumColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,sumColumnColor[colIndex]);
         x += sumColumnWidth[colIndex] + ColumnInterval;
      }
   }

}

void DrawHeader(int startXi, int startYi) {

   //DrawComponent(500, 200, 60, 50, "LotAdjust", "0.01", "Lot");
   
   //int startXi = 2;
   //int startYi = 60;
   int x = startXi;
   int y = startYi;

   const string pNamePrefix = "Rec";
   const string hNamePrefix1 = "H1";

   long chartId = 0;
   
   int columnCount = ArraySize(ColumnName);
   for (int colIndex=0; colIndex<columnCount; colIndex++) {
      string columnType = h1ColumnType[colIndex];
      if ("lbl"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
         SetText(hNamePrefix1+columnType+ColumnName[colIndex],h1ColumnShow[colIndex],x+h1ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,h1ColumnColor[colIndex]);
         x += h1ColumnWidth[colIndex] + ColumnInterval;
      } else if ("btn"==columnType) {
         CreateButton(hNamePrefix1+columnType+ColumnName[colIndex],h1ColumnShow[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
         x += h1ColumnWidth[colIndex] + ColumnInterval;
      } else if ("lbo"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
         SetObjText(hNamePrefix1+columnType+ColumnName[colIndex],h1ColumnShow[colIndex],x+h1ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,h1ColumnColor[colIndex]);
         x += h1ColumnWidth[colIndex] + ColumnInterval;
      }
   }

}

void DrawData(int rowCount, int startXi, int startYi) {
   //int startXi = 2;
   //int startYi = 100;
   int x = startXi;
   int y = startYi;

   const string panelNamePrefix = "Rec";

   long chartId = 0;

   for (int i=0; i<rowCount; i++) {
      x = startXi;
      
      int columnCount = ArraySize(ColumnName);
      for (int colIndex=0; colIndex<columnCount; colIndex++) {
         string columnType = ColumnType[colIndex];
         if ("lbl"==columnType) {
            CreatePanel(panelNamePrefix+columnType+ColumnName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
            SetText(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
         } else if ("btn"==columnType) {
            CreateButton(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
         } else if ("lbo"==columnType) {
            CreatePanel(panelNamePrefix+columnType+ColumnName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
            SetObjText(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
         }
      }
      ObjectSetString(chartId,ColumnType[0]+ColumnName[0]+IntegerToString(i),OBJPROP_TEXT,IntegerToString(i+1, 2));

      y += RowHeight + RowInterval;

   }
}

void DrawComponent(int x, int y, int width, int height, string labelName, string initValue, string labelText) {
   CreateButton(labelName+"Up","▲",x,y,30,height,clrBlack,clrGreen);
   CreatePanel("Rec"+labelName+"Value",x+30,y,width,RowHeight,clrBlack,clrWhite,1);
   SetText(labelName+"Value",initValue,x+30+1,y+1,clrWhite);
   CreateButton(labelName+"Dn","▼",x+30+width,y,30,height,clrBlack,clrWhite);
   SetText(labelName,labelText,x+30+width+30,y,clrWhite);
}

void SetText(string name,string text,int x,int y,color fontColor,int fontSize=8) {

   long chartId = 0;

   if (ObjectFind(chartId,name)<0)

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



void CreatePanel(string name,int x,int y,int width,int height,color backgroundColor,color borderColor,int borderWidth) {

   long chartId = 0;

   if (ObjectCreate(chartId,name,OBJ_RECTANGLE_LABEL,0,0,0)) {

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

      ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,0);

      ObjectSetInteger(chartId,name,OBJPROP_SELECTED,0);

      ObjectSetInteger(chartId,name,OBJPROP_HIDDEN,true);

      ObjectSetInteger(chartId,name,OBJPROP_ZORDER,0);

   }

   ObjectSetInteger(chartId,name,OBJPROP_BGCOLOR,backgroundColor);

}



void CreateButton(string btnName,string text,int x,int y,int width,int height,int backgroundColor,int textColor) {

   ResetLastError();

   long chartId = 0;

   if (ObjectFind(chartId,btnName)<0) {

      if (!ObjectCreate(chartId,btnName,OBJ_BUTTON,0,0,0)) {

         Print(__FUNCTION__, ": failed to create the button! Error code = ",ErrorDescription(GetLastError()));

         return;

      }

      ObjectSetString(chartId,btnName,OBJPROP_TEXT,text);

      ObjectSetInteger(chartId,btnName,OBJPROP_XSIZE,width);

      ObjectSetInteger(chartId,btnName,OBJPROP_YSIZE,height);

      ObjectSetInteger(chartId,btnName,OBJPROP_CORNER,CORNER_LEFT_UPPER);

      ObjectSetInteger(chartId,btnName,OBJPROP_XDISTANCE,x);

      ObjectSetInteger(chartId,btnName,OBJPROP_YDISTANCE,y);

      ObjectSetInteger(chartId,btnName,OBJPROP_BGCOLOR,backgroundColor);

      ObjectSetInteger(chartId,btnName,OBJPROP_COLOR,textColor);

      ObjectSetInteger(chartId,btnName,OBJPROP_FONTSIZE,Font_Size);

      ObjectSetInteger(chartId,btnName,OBJPROP_HIDDEN,true);

      //ObjectSetInteger(chart_ID,btnName,OBJPROP_BORDER_COLOR,borderColor);

      ObjectSetInteger(chartId,btnName,OBJPROP_BORDER_TYPE,BORDER_RAISED);

      

      ChartRedraw();      

   }



}

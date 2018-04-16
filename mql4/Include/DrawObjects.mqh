//+------------------------------------------------------------------+
//|                                                  DrawObjects.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#import "DrawObjects.ex4"
   void RectLabelCreate(string         name,                         // label name
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
                     long              z_order=0);                   // priority for mouse click
   
void DrawLine(string ctlName,
            double Price = 0,
            color LineColor = clrGold,
            ENUM_LINE_STYLE LineStyle = STYLE_SOLID,
            int LineWidth = 1);

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
                  long              z_order=0);                // priority for mouse click

void SetText(  string            name,
               string            text,
               int               x=0,
               int               y=0,
               int               fontSize=8,
               color             fontColor=clrWhite,
               string            fontName="Arial",
               ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER);
#import
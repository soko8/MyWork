//+------------------------------------------------------------------+
//|                                                DrawDashBoard.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <Arrays\List.mqh>
#include <Infos\SymbolInfo.mqh>

#define COL_NO_Disable                                0
#define COL_NO_PROFIT                                 1
#define COL_NO_BUY                                    2
#define COL_NO_LOT_L                                  3
#define COL_NO_CLOSE_L                                4
#define COL_NO_PROFIT_L                               5
#define COL_NO_NUM_L                                  6
#define COL_NO_SELL                                   7
#define COL_NO_LOT_S                                  8
#define COL_NO_CLOSE_S                                9
#define COL_NO_PROFIT_S                              10
#define COL_NO_NUM_S                                 11
#define COL_NO_SPREAD                                12
#define COL_NO_PAIR_NAME                             13
#define COL_NO_ADR                                   14
#define COL_NO_CDR                                   15
#define COL_NO_RSI                                   16
#define COL_NO_CCI                                   17
#define COL_NO_SAR                                   18
#define COL_NO_MA1                                   19
#define COL_NO_MA2                                   20
#define COL_NO_MA3                                   21
#define COL_NO_MA4                                   22
#define COL_NO_BID_RATIO                             23
#define COL_NO_REL_STRENGTH                          24
#define COL_NO_BS_RATIO                              25
#define COL_NO_GAP                                   26
#define COL_NO_STO                                   27
#define COL_NO_1KH                                   28
#define COL_NO_MDD                                   29
#define COL_NO_MPROFIT                               30
#define clrHBGC1                          C'25,202,173'
#define clrHBGC2                       C'227, 237, 205'
#define clrHBGC3                       C'253, 230, 224'
#define clrHBGC5                       C'199, 237, 204'


const int RowInterval=0;
const int ColumnInterval=0;
const int RowHeight=40;

const string Font_Name = "Lucida Bright";
const int Font_Size = 8;
const int Border_Width = 1;


                                         //   1          2                3         4          5           6                7          8         9               10           11            12         13        14          15        16        17        18         19            20         21         22         23         24             25                  26               27         28              29                30                31           32          33
const string   ColumnName[31]             ={ "Disable", "Profit",        "Buy",    "BuyLot",  "CloseBuy", "BuyProfit",     "BuyNum",  "Sell",   "SellLot",      "CloseSell", "SellProfit", "SellNum", "Spread", "PairName", "ADR",    "CDR",    "RSI",    "CCI",     "SAR",        "MA1",     "MA2",     "MA3",     "MA4",     "BidRatio",    "RelativeStrength", "BSRatio",       "GAP",     "Stochastic1"  ,"1muKinkoHyo"    ,"MaxDrawdown"    ,"MaxProfit"};
const string   ColumnShow[31]             ={ "~",       "123456.12",     "B",      "1234.12", "CL",       "12345.12",      "12",      "S",      "1234.12",      "CS",        "12345.12",   "12",      "99.9",   "EURUSD",   "999.9",  "123.1",  "123",    "-123",    "12.12",      "++",      "==",      "++",      "--",      "12.12% ==",   "-5 ==",            "-5.5 ==",       "-5.5 ==", "12.1 ++"      ,"12.1 ++"        ,"12345.12"       ,"12345.12"};
const string   ColumnType[31]             ={ "btn",     "lbl",           "btn",    "lbl",     "btn",      "lbl",           "lbl",     "btn",    "lbl",          "btn",       "lbl",        "lbl",     "lbl",    "btn",      "lbl",    "lbl",    "lbl",    "lbl",     "lbl",        "lbl",     "lbl",     "lbl",     "lbl",     "lbl",         "lbl",              "lbl",           "lbl",     "lbl"          ,"lbl"            ,"lbl"            ,"lbl"};
const int      ColumnWidth[31]            ={  30,        134,             55,       106,       47,         120,             46,        55,       106,            47,          120,          46,        64,       124,        74,       74,       60,       65,        74,           52,        52,        52,        52,        80,            60,                 194,             76,        160           ,160              ,120              ,120};
const int      ColumnWidthAdjust[31]      ={  0,         2,               0,        2,         0,          2,               0,         0,        2,              0,           2,            0,         8,        0,          6,        6,        14,       4,         22,           12,        12,        12,        12,        2,             2,                  2,               2,         2             ,2                ,2                ,2};
const color    ColumnColor[31]            ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,           clrWhite,        clrWhite,  clrWhite       ,clrWhite         ,clrWhite         ,clrWhite};
const color    ColumnColorBackground[31]  ={ clrBlack,  clrBlack,        clrBlack, clrBlack,  clrBlack,   clrBlack,        clrBlack,  clrBlack, clrBlack,       clrBlack,    clrBlack,     clrBlack,  clrBlack, clrBlack,   clrBlack, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrBlack,  clrBlack,  clrBlack,  clrBlack,      clrBlack,           clrBlack,        clrBlack,  clrBlack       ,clrBlack         ,clrBlack         ,clrBlack};
const color    ColumnColorBorder[31]      ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,           clrWhite,        clrWhite,  clrWhite       ,clrWhite         ,clrWhite         ,clrWhite};

const string   h1ColumnShow[31]           ={ "~",       "Profit",        "C+",     "Lot",     "CL",       "Profit",        "#",       "C-",     "Lot",          "CS",        "Profit",     "#",       "Spd",    "Symbol",   "ADR",    "CDR",    "RSI",    "CCI",     "SAR",        "M5",      "30",      "H1",      "H4",      "BidR",        "Rel",              "BuySellRatio",  "GAP",     "Stochastic"   ,"1muKinko"       ,"MaxDD"          ,"MaxProfit"};
const string   h1ColumnType[31]           ={ "lbl",     "lbl",           "btn",    "lbl",     "btn",      "lbl",           "lbl",     "btn",    "lbl",          "btn",       "lbl",        "lbl",     "btn",    "btn",      "lbl",    "lbl",    "btn",    "btn",     "btn",        "btn",     "btn",     "btn",     "btn",     "btn",         "btn",              "btn",           "btn",     "btn"          ,"btn"            ,"lbl"            ,"lbl"};
const int      h1ColumnWidth[31]          ={  30,        134,             55,       106,       47,         120,             46,        55,       106,            47,          120,          46,        64,       124,        74,       74,       60,       65,        74,           52,        52,        52,        52,        80,            60,                 194,             76,        160           ,160              ,120              ,120};
const int      h1ColumnWidthAdjust[31]    ={  6,         39,              0,        30,        0,          30,              14,        0,        30,             0,           30,           14,        8,        0,          8,        8,        8,        8,         8,            7,         7,         7,         7,         10,            6,                  2,               6,         22            ,22               ,16               ,2};
const color    h1ColumnColor[31]          ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrBlack, clrBlack,   clrBlack, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrBlack,  clrBlack,  clrBlack,  clrBlack,      clrBlack,           clrBlack,        clrBlack,  clrBlack       ,clrBlack         ,clrBlack         ,clrBlack};
const color    h1ColumnColorBackground[31]={ clrBlack,  clrBlack,        clrNavy,  clrNavy,   clrNavy,    clrNavy,         clrNavy,   clrMaroon,clrMaroon,      clrMaroon,   clrMaroon,    clrMaroon, clrHBGC1, clrOrange,  clrOrange,clrOrange,clrHBGC1, clrHBGC1,  clrHBGC1,     clrHBGC1,  clrHBGC1,  clrHBGC1,  clrHBGC1,  clrHBGC1,      clrHBGC1,           clrHBGC1,        clrHBGC1,  clrHBGC1       ,clrHBGC1         ,clrOrange        ,clrOrange};
const color    h1ColumnColorBorder[31]    ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,           clrWhite,        clrWhite,  clrWhite       ,clrWhite         ,clrWhite         ,clrWhite};

const string   h2ColumnShow[31]           ={ "",        "TrailingStop:", "▲",      "10",      "▼",        "",              "",        "",       "TP:",          "▲",         "",           "▼",       "",       "",         "",       "",       "RSI",    "CCI",     "SAR",        "M5",      "30",      "H1",      "H4",      "BidR",        "Rel",              "BuySellRatio",  "GAP",     "Sto1"         ,""               ,""               ,""};
const string   h2ColumnType[31]           ={ "lbl",     "lbl",           "btn",    "lbl",     "btn",      "lbl",           "lbl",     "lbl",    "lbl",          "btn",       "lbl",        "btn",     "lbl",    "lbl",      "lbl",    "lbl",    "lbl",    "lbl",     "lbl",        "lbl",     "lbl",     "lbl",     "lbl",     "lbl",         "lbl",              "lbl",           "lbl",     "lbl"          ,"lbl"            ,"lbl"            ,"lbl"};
const int      h2ColumnWidth[31]          ={  30,        134,             55,       106,       47,         120,             46,        55,       106,            47,          120,          46,        64,       124,        74,       74,       60,       65,        74,           52,        52,        52,        52,        80,            60,                 194,             76,        160           ,160              ,120              ,120};
const int      h2ColumnWidthAdjust[31]    ={  0,         6,               0,        30,        0,          1,               9,         0,        60,             0,           30,           9,         8,        0,          8,        8,        8,        8,         8,            7,         7,         7,         7,         10,            6,                  4,               6,         22            ,22               ,22               ,22};
const color    h2ColumnColor[31]          ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrBlack,  clrBlack,  clrBlack,  clrBlack,      clrBlack,           clrBlack,        clrBlack,  clrBlack       ,clrBlack         ,clrBlack         ,clrBlack};
const color    h2ColumnColorBackground[31]={ clrBlack,  clrDarkViolet,   clrIndigo,clrBlue,   clrIndigo,  clrBlack,        clrBlack,  clrBlack, clrDarkViolet,  clrIndigo,   clrBlue,      clrIndigo,  clrBlack, clrBlack,   clrBlack, clrHBGC2, clrHBGC2, clrHBGC2,  clrHBGC2,     clrHBGC2,  clrHBGC2,  clrHBGC2,  clrHBGC2,  clrHBGC2,      clrHBGC2,           clrHBGC2,        clrHBGC2,  clrHBGC2       ,clrHBGC2         ,clrHBGC2         ,clrHBGC2};
const color    h2ColumnColorBorder[31]    ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,           clrWhite,        clrWhite,  clrWhite       ,clrWhite         ,clrWhite         ,clrWhite};


const string   h3ColumnShow[31]           ={ "M",       "Lot:",          "▲",      "0.01",    "▼",        "",              "",        "",       "SL:",          "▲",         "",           "▼",       "",       "",         "",       "",       "RSI",    "CCI",     "SAR",        "MA",      "",        "",        "",        "Price Action","",                 "",              "",        "Sto1"         ,""               ,""               ,""};
const string   h3ColumnType[31]           ={ "btn",     "lbl",           "btn",    "lbl",     "btn",      "lbl",           "lbl",     "lbl",    "lbl",          "btn",       "lbl",        "btn",     "lbl",    "lbl",      "lbl",    "lbl",    "lbl",    "lbl",     "lbl",        "lbl",     "lbl",     "lbl",     "lbl",     "lbl",         "lbl",              "lbl",           "lbl",     "lbl"          ,"lbl"            ,"lbl"            ,"lbl"};
const int      h3ColumnWidth[31]          ={  30,        134,             55,       106,       47,         120,             46,        55,       106,            47,          120,          46,        64,       124,        74,       74,       60,       65,        74,           208,       0,         0,         0,         410,           0,                  0,               0,         160           ,160              ,120              ,120};
const int      h3ColumnWidthAdjust[31]    ={  0,         86,              0,        30,        0,          2,               9,         0,        60,             0,           30,           9,         8,        0,          8,        8,        8,        8,         8,            85,        0,         0,         0,         10,            0,                  0,               0,         22            ,22               ,22               ,22};
const color    h3ColumnColor[31]          ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrNONE,   clrNONE,   clrNONE,   clrBlack,     clrNONE,             clrNONE,         clrNONE,   clrBlack       ,clrBlack         ,clrBlack         ,clrBlack};
const color    h3ColumnColorBackground[31]={ clrRed,    clrDarkViolet,   clrIndigo,clrBlue,   clrIndigo,  clrBlack,        clrBlack,  clrBlack, clrDarkViolet,  clrIndigo,   clrBlue,      clrIndigo,  clrBlack, clrBlack,   clrBlack, clrHBGC3, clrHBGC3, clrHBGC3,  clrHBGC3,     clrHBGC3,  clrNONE,   clrNONE,   clrNONE,   clrHBGC3,     clrNONE,             clrNONE,         clrNONE,   clrHBGC3       ,clrHBGC3         ,clrHBGC3         ,clrHBGC3};
const color    h3ColumnColorBorder[31]    ={ clrWhite,  clrWhite,        clrWhite, clrWhite,  clrWhite,   clrWhite,        clrWhite,  clrWhite, clrWhite,       clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrNONE,   clrNONE,   clrNONE,   clrWhite,     clrNONE,             clrNONE,         clrNONE,   clrWhite       ,clrWhite         ,clrWhite         ,clrWhite};



const int      unuseColumnCount = 5;

void DrawDashBoard(CList *symbolList) export {
   int startX = 2;
   int startY = 100;
   DrawHeader3(startX, startY);
   DrawHeader2(startX, startY+RowHeight);
   DrawHeader1(startX, startY+RowHeight*2);
   DrawData(startX, startY+RowHeight*3, symbolList);
}

void DrawHeader3(int startXi, int startYi) {
   int x = startXi;
   int y = startYi;
   const string pNamePrefix = "Rec";
   const string hNamePrefix1 = "H3";
   long chartId = 0;

   int columnCount = ArraySize(ColumnName);
   columnCount = columnCount;
   
   for (int colIndex=0; colIndex<columnCount; colIndex++) {
      string columnType = h3ColumnType[colIndex];
      if ("lbl"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,h3ColumnWidth[colIndex],RowHeight,h3ColumnColorBackground[colIndex],h3ColumnColorBorder[colIndex],Border_Width);
         SetText(hNamePrefix1+columnType+ColumnName[colIndex],h3ColumnShow[colIndex],x+h3ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,h3ColumnColor[colIndex]);
         x += h3ColumnWidth[colIndex] + ColumnInterval;

      } else if ("btn"==columnType) {
         CreateButton(hNamePrefix1+columnType+ColumnName[colIndex],h3ColumnShow[colIndex],x,y,h3ColumnWidth[colIndex],RowHeight,h3ColumnColorBackground[colIndex],h3ColumnColor[colIndex]);
         x += h3ColumnWidth[colIndex] + ColumnInterval;

      } else if ("lbo"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,h3ColumnWidth[colIndex],RowHeight,h3ColumnColorBackground[colIndex],h3ColumnColorBorder[colIndex],Border_Width);
         SetObjText(hNamePrefix1+columnType+ColumnName[colIndex],h3ColumnShow[colIndex],x+h3ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,h3ColumnColor[colIndex]);
         x += h3ColumnWidth[colIndex] + ColumnInterval;
      }
   }
}

void DrawHeader2(int startXi, int startYi) {
   int x = startXi;
   int y = startYi;
   const string pNamePrefix = "Rec";
   const string hNamePrefix1 = "H2";
   long chartId = 0;

   int columnCount = ArraySize(ColumnName);
   columnCount = columnCount;
   for (int colIndex=0; colIndex<columnCount; colIndex++) {
      string columnType = h2ColumnType[colIndex];
      if ("lbl"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,h2ColumnWidth[colIndex],RowHeight,h2ColumnColorBackground[colIndex],h2ColumnColorBorder[colIndex],Border_Width);
         SetText(hNamePrefix1+columnType+ColumnName[colIndex],h2ColumnShow[colIndex],x+h2ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,h2ColumnColor[colIndex]);
         x += h2ColumnWidth[colIndex] + ColumnInterval;

      } else if ("btn"==columnType) {
         CreateButton(hNamePrefix1+columnType+ColumnName[colIndex],h2ColumnShow[colIndex],x,y,h2ColumnWidth[colIndex],RowHeight,h2ColumnColorBackground[colIndex],h2ColumnColor[colIndex]);
         x += h2ColumnWidth[colIndex] + ColumnInterval;

      } else if ("lbo"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,h2ColumnWidth[colIndex],RowHeight,h2ColumnColorBackground[colIndex],h2ColumnColorBorder[colIndex],Border_Width);
         SetObjText(hNamePrefix1+columnType+ColumnName[colIndex],h2ColumnShow[colIndex],x+h2ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,h2ColumnColor[colIndex]);
         x += h2ColumnWidth[colIndex] + ColumnInterval;
      }
   }
   ObjectSetInteger(chartId,"H2lblProfit",OBJPROP_FONTSIZE,7);
   //ObjectSetInteger(chartId,"H2lblSellLot",OBJPROP_FONTSIZE,6);
}

void DrawHeader1(int startXi, int startYi) {
   int x = startXi;
   int y = startYi;
   const string pNamePrefix = "Rec";
   const string hNamePrefix1 = "H1";
   long chartId = 0;

   int columnCount = ArraySize(ColumnName);
   columnCount = columnCount;
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


void DrawData(int startXi, int startYi, CList *symbolList) {
   int x = startXi;
   int y = startYi;
   const string panelNamePrefix = "Rec";
   long chartId = 0;

   int rowCnt = symbolList.Total();
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      x = startXi;
      int columnCount = ArraySize(ColumnName);
      columnCount = columnCount;

      for (int colIndex=0; colIndex<columnCount; colIndex++) {
         string columnType = ColumnType[colIndex];
         if ("lbl"==columnType) {
            CreatePanel(panelNamePrefix+columnType+ColumnName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
            SetText(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
            if(1==i%2) {
               ObjectSetInteger(chartId,panelNamePrefix+columnType+ColumnName[colIndex]+IntegerToString(i),OBJPROP_BGCOLOR,C'41,41,41');
            }

         } else if ("btn"==columnType) {
            CreateButton(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;

         } else if ("lbo"==columnType) {
            CreatePanel(panelNamePrefix+columnType+ColumnName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
            SetObjText(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
         }
      }

      ObjectSetString(chartId,getObjectName(i, COL_NO_PAIR_NAME),OBJPROP_TEXT,si.getName());
      y += RowHeight + RowInterval;
   }

}


string getObjectName(int rowIndex, int columnIndex) export {
   return ColumnType[columnIndex]+ColumnName[columnIndex]+IntegerToString(rowIndex);
}


void refreshOrdersData(CList *symbolList, int MagicNumber, bool isAutoTrade, double coefficient) export {
   int totalOrderCount = 0;
   double totalLot = 0.0;
   double totalProfit = 0.0;
   int rowCnt = symbolList.Total();

   for(int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      si.setOrderCountL(0);
      si.setLotL(0.0);
      si.setProfitL(0.0);
      si.setOrderCountS(0);
      si.setLotS(0.0);
      si.setProfitS(0.0);
   }
   
   //if (isAutoTrade) {
      int cnt = OrdersTotal();
      string symbolName = "";
      double openPrice = 0.0;
      for (int pos=0; pos<cnt; pos++) {
         if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
         for(int i=0; i<rowCnt; i++) {
            SymbolInfo *si = symbolList.GetNodeAtIndex(i);
            symbolName = si.getRealName();
            double vbid = MarketInfo(si.getRealName(), MODE_BID);
            double vask = MarketInfo(si.getRealName(), MODE_ASK);
            if(symbolName==OrderSymbol() && OrderMagicNumber()==MagicNumber) {
               int shift=iBarShift(symbolName,PERIOD_M1,OrderOpenTime());
               int shiftH = iHighest(symbolName,PERIOD_M1,MODE_HIGH,shift,0);
               int shiftL = iLowest(symbolName,PERIOD_M1,MODE_LOW,shift,0);
               if (OP_BUY == OrderType()) {
                  si.setMaxProfit((iHigh(symbolName, PERIOD_M1, shiftH)-OrderOpenPrice())/si.getPoint());
                  si.setMaxDD((iLow(symbolName, PERIOD_M1, shiftL)-OrderOpenPrice())/si.getPoint());
               } else
               if (OP_SELL == OrderType()) {
                  si.setMaxProfit((OrderOpenPrice()-iLow(symbolName, PERIOD_M1, shiftL))/si.getPoint());
                  si.setMaxDD((OrderOpenPrice()-iHigh(symbolName, PERIOD_M1, shiftH))/si.getPoint());
               }
               
               if (isAutoTrade) {
               if (OP_BUY == OrderType()) {
                  if (vask <= (OrderOpenPrice()-si.getStopLoss())) {
                     closeOrderL(si, MagicNumber, 0.0, "Auto StopLoss Close Buy Order.");
                  } else {
                     if (0 == si.getCutTimes()) {
                        if ((OrderOpenPrice()+si.getTakeProfit()) <= vbid) {
                           double partLot = calculatePartLot(symbolName, OrderLots(), coefficient);
                           if (0.001 < partLot) {
                              closeOrderL(si, MagicNumber, partLot, "Auto Take Profit Close Buy Order.");
                              si.setCutTimes(si.getCutTimes()+1);
                           } else {
                              si.setCutTimes(si.getCutTimes()+1);
                           }
                        }
                     } else {
                        if ((OrderOpenPrice()+si.getTakeProfit()+si.getCutTimes()*si.getTrailingStop()) <= vbid) {
                           double partLot = calculatePartLot(symbolName, OrderLots(), coefficient);
                           if (0.001 < partLot) {
                              closeOrderL(si, MagicNumber, partLot, "Auto Trailing Stop Close Buy Order.");
                              si.setCutTimes(si.getCutTimes()+1);
                           } else {
                              si.setCutTimes(si.getCutTimes()+1);
                           }
                        }
                     }
                  }


               } else
               if (OP_SELL == OrderType()) {
                  if ((OrderOpenPrice()+si.getStopLoss()) <= vbid) {
                     closeOrderS(si, MagicNumber, 0.0, "Auto StopLoss Close Sell Order.");
                  } else {
                     if (0 == si.getCutTimes()) {
                        if (vask <= (OrderOpenPrice()-si.getTakeProfit())) {
                           double partLot = calculatePartLot(symbolName, OrderLots(), coefficient);
                           if (0.001 < partLot) {
                              closeOrderL(si, MagicNumber, partLot, "Auto Take Profit Close Sell Order.");
                              si.setCutTimes(si.getCutTimes()+1);
                           } else {
                              si.setCutTimes(si.getCutTimes()+1);
                           }
                        }
                     } else {
                        if (vask <= (OrderOpenPrice()-si.getTakeProfit()-si.getCutTimes()*si.getTrailingStop())) {
                           double partLot = calculatePartLot(symbolName, OrderLots(), coefficient);
                           if (0.001 < partLot) {
                              closeOrderL(si, MagicNumber, partLot, "Auto Trailing Stop Close Sell Order.");
                           } else {
                              si.setCutTimes(si.getCutTimes()+1);
                           }
                        }
                     }
                  }

               }
            }
         }
      }   
   }
   
   //int cnt = OrdersTotal();
   //string symbolName = "";
   double tempProfit = 0.0;
   for (int pos=0; pos<cnt; pos++) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      for(int i=0; i<rowCnt; i++) {
         SymbolInfo *si = symbolList.GetNodeAtIndex(i);
         symbolName = si.getRealName();
         if(symbolName==OrderSymbol() && OrderMagicNumber()==MagicNumber) {
            tempProfit = OrderProfit() + OrderSwap() + OrderCommission();
            totalOrderCount++;
            totalLot += OrderLots();
            totalProfit += tempProfit;
            if (OP_BUY == OrderType()) {
               si.setOrderCountL(si.getOrderCountL() + 1);
               si.setLotL(si.getLotL() + OrderLots());
               si.setProfitL(si.getProfitL() + tempProfit);
            } else
            if (OP_SELL == OrderType()) {
               si.setOrderCountS(si.getOrderCountS() + 1);
               si.setLotS(si.getLotS() + OrderLots());
               si.setProfitS(si.getProfitS() + tempProfit);
            }
         }
      }
   }
   
   long chartId = 0;
   string objName = "";
   color fontColor = clrWhite;
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      
      // Profit
      objName = getObjectName(i, COL_NO_PROFIT);
      fontColor = getProfitColor(si.getProfit());
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      if (0 == (si.getOrderCountL()+si.getOrderCountS())) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(si.getProfit(),2));
      }
      
      // BuyLot
      objName = getObjectName(i, COL_NO_LOT_L);
      if (0 == si.getOrderCountL()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(si.getLotL(),2));
      }
      
      // BuyProfit
      objName = getObjectName(i, COL_NO_PROFIT_L);
      fontColor = getProfitColor(si.getProfitL());
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      if (0 == si.getOrderCountL()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(si.getProfitL(),2));
      }
      
      // BuyNum
      objName = getObjectName(i, COL_NO_NUM_L);
      if (0 == si.getOrderCountL()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, IntegerToString(si.getOrderCountL(),3));
      }
      
      // SellLot
      objName = getObjectName(i, COL_NO_LOT_S);
      if (0 == si.getOrderCountS()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(si.getLotS(),2));
      }
      
      // SellProfit
      objName = getObjectName(i, COL_NO_PROFIT_S);
      fontColor = getProfitColor(si.getProfitS());
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      if (0 == si.getOrderCountS()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(si.getProfitS(),2));
      }
      
      // SellNum
      objName = getObjectName(i, COL_NO_NUM_S);
      if (0 == si.getOrderCountS()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, IntegerToString(si.getOrderCountS(),3));
      }
      
      // Max Drawdown
      objName = getObjectName(i, COL_NO_MDD);
      if (0 == si.getOrderCountS()+si.getOrderCountL()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(si.getMaxDD()/10,1));
      }
      
      // Max Profit
      objName = getObjectName(i, COL_NO_MPROFIT);
      if (0 == si.getOrderCountS()+si.getOrderCountL()) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(si.getMaxProfit()/10,1));
      }
   }
   
   // Profit
   objName = "H1lblProfit";
   ObjectSetInteger(chartId,objName,OBJPROP_COLOR,getProfitColor(totalProfit));
   if (0 == totalOrderCount) {
      ObjectSetString(chartId,objName,OBJPROP_TEXT, "");
   } else {
      ObjectSetString(chartId,objName,OBJPROP_TEXT, DoubleToStr(totalProfit,2));
   }
   
   

}

color getProfitColor(double profit) {
   if (0 < profit) {
      return clrLime;
   }
   
   if (profit < 0) {
      return clrRed;
   }
   
   return clrWhite;
}

double GetAdrValues(string pairName, double point) export {
   double s=0.0;
   double adr1 = 0.0;
   double adr5 = 0.0;
   double adr10 = 0.0;
   double adr20 = 0.0;
   for(int a=1;a<=20;a++) {
      if(point != 0)    s  = s+(iHigh(pairName,PERIOD_D1,a)-iLow(pairName,PERIOD_D1,a))/point;
      //s  = s+(iHigh(pairName,PERIOD_D1,a)-iLow(pairName,PERIOD_D1,a))/point;
      if(a==1)       adr1  = MathRound(s);
      if(a==5)       adr5  = MathRound(s/5);
      if(a==10)      adr10 = MathRound(s/10);
      if(a==20)      adr20 = MathRound(s/20);
   }
   
   double adr=MathRound((adr1+adr5+adr10+adr20)/4.0);
   return adr;
}

int getRelativeStrength(double bidRatio) export {
   if (bidRatio > 97.0) return 9;
   if (bidRatio > 90.0) return 8;
   if (bidRatio > 75.0) return 7;
   if (bidRatio > 60.0) return 6;
   if (bidRatio > 50.0) return 5;
   if (bidRatio > 40.0) return 4;
   if (bidRatio > 25.0) return 3;
   if (bidRatio > 10.0) return 2;
   if (bidRatio > 3.0)  return 1;
   return 0;
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
      ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(chartId,name,OBJPROP_SELECTED,false);
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

const int                  SLIPPAGE=100;

// TODO  SL AND TP
void createOrderL(SymbolInfo *si, double lotSize, int MagicNumber, string comnt="", double slp=0.0, double tpp=0.0) export {
   double openPrice = MarketInfo(si.getRealName(), MODE_ASK);
   double slPrice = slp;
   double tpPrice = tpp;
   int ticketId  = OrderSend(si.getRealName(), OP_BUY , lotSize, openPrice, SLIPPAGE, slPrice, tpPrice, comnt, MagicNumber, 0, clrBlue);
   if (ticketId < 0) {
      int errorCode = GetLastError();
      if (ERR_NO_CONNECTION == errorCode || ERR_MARKET_CLOSED == errorCode) {
         Print(ErrorDescription(errorCode));
      } else {
         string msg = "BUY OrderSend failed. Error:【" + ErrorDescription(errorCode);
         msg += "】 Ask=" + DoubleToStr(openPrice, si.getDigits());
         msg += " lotSize=" + DoubleToStr(lotSize, 2);
         Alert(msg);
      }
   } else {
      si.setCutTimes(0);
      // TODO refresh row
   }
}

void createOrderS(SymbolInfo *si, double lotSize, int MagicNumber, string comnt="", double slp=0.0, double tpp=0.0) export {
   double openPrice = MarketInfo(si.getRealName(), MODE_BID);
   double slPrice = slp;
   double tpPrice = tpp;
   int ticketId  = OrderSend(si.getRealName(), OP_SELL , lotSize, openPrice, SLIPPAGE, slPrice, tpPrice, comnt, MagicNumber, 0, clrBlue);
   if (ticketId < 0) {
      int errorCode = GetLastError();
      if (ERR_NO_CONNECTION == errorCode || ERR_MARKET_CLOSED == errorCode) {
         Print(ErrorDescription(errorCode));
      } else {
         string msg = "SELL OrderSend failed. Error:【" + ErrorDescription(errorCode);
         msg += "】 Bid=" + DoubleToStr(openPrice, si.getDigits());
         msg += " lotSize=" + DoubleToStr(lotSize, 2);
         Alert(msg);
      }
   } else {
      si.setCutTimes(0);
      // TODO refresh row
   }
}

void closeOrderL(SymbolInfo *si, int MagicNumber, double lots=0.0, string message="") export {
   int cnt = OrdersTotal();
   string symbolName = si.getRealName();
   for (int pos=cnt-1; 0<=pos; pos--) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OrderSymbol()!=symbolName) continue;
      if(OP_BUY!=OrderType()) continue;
      double closePrice = MarketInfo(symbolName, MODE_BID);
      double closeOrderLots = lots;
      if (lots < 0.01) {
         closeOrderLots = OrderLots();
      }
      bool isClosed = OrderClose(OrderTicket(), closeOrderLots, closePrice, SLIPPAGE);
      if (isClosed) {
         Print(message);
      } else {
         // Invalid ticket
         if (4108 == GetLastError()) {
            Print("4108:Invalid ticket");
         } else {
            string msg = "BUY OrderClose failed. Error:【" + ErrorDescription(GetLastError());
            msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
            msg += " lotSize=" + DoubleToStr(closeOrderLots, 2);
            msg += " Bid=" + DoubleToStr(closePrice, si.getDigits());
            Alert(msg);
         }
      }
   }
}

void closeOrderS(SymbolInfo *si, int MagicNumber, double lots=0.0, string message="") export {
   int cnt = OrdersTotal();
   string symbolName = si.getRealName();
   for (int pos=cnt-1; 0<=pos; pos--) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OrderSymbol()!=symbolName) continue;
      if(OP_SELL!=OrderType()) continue;
      double closePrice = MarketInfo(symbolName, MODE_ASK);
      double closeOrderLots = lots;
      if (lots < 0.01) {
         closeOrderLots = OrderLots();
      }
      bool isClosed = OrderClose(OrderTicket(), closeOrderLots, closePrice, SLIPPAGE);
      if (isClosed) {
         Print(message);
      } else {
         // Invalid ticket
         if (4108 == GetLastError()) {
            Print("4108:Invalid ticket");
         } else {
            string msg = "SELL OrderClose failed. Error:【" + ErrorDescription(GetLastError());
            msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
            msg += " lotSize=" + DoubleToStr(closeOrderLots, 2);
            msg += " Ask=" + DoubleToStr(closePrice, si.getDigits());
            Alert(msg);
         }
      }
   }
}

void closeAllL(int MagicNumber, string message="") export {
   int cnt = OrdersTotal();
   for (int pos=cnt-1; 0<=pos; pos--) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OP_BUY!=OrderType()) continue;
      double closePrice = MarketInfo(OrderSymbol(), MODE_BID);
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, SLIPPAGE);
      if (isClosed) {
         Print(message);
      } else {
         // Invalid ticket
         if (4108 == GetLastError()) {
            Print("4108:Invalid ticket");
         } else {
            string msg = "BUY OrderClose failed. Error:【" + ErrorDescription(GetLastError());
            msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
            msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
            int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
            msg += " Bid=" + DoubleToStr(closePrice, vdigits);
            Alert(msg);
         }
      }
   }
}

void closeAllS(int MagicNumber, string message="") export {
   int cnt = OrdersTotal();
   for (int pos=cnt-1; 0<=pos; pos--) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OP_SELL!=OrderType()) continue;
      double closePrice = MarketInfo(OrderSymbol(), MODE_ASK);
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, SLIPPAGE);
      if (isClosed) {
         Print(message);
      } else {
         // Invalid ticket
         if (4108 == GetLastError()) {
            Print("4108:Invalid ticket");
         } else {
            string msg = "SELL OrderClose failed. Error:【" + ErrorDescription(GetLastError());
            msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
            msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
            int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
            msg += " Ask=" + DoubleToStr(closePrice, vdigits);
            Alert(msg);
         }
      }
   }
}

void closePositiveProfitOrders(int MagicNumber, string message="", int slippagePerLot=0) export {
   int cnt = OrdersTotal();
   for (int pos=cnt-1; 0<=pos; pos--) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if ((OrderProfit()+OrderCommission()+OrderSwap()) < (OrderLots()*slippagePerLot)) continue;
      
      double closePrice = 0.0;
      if (OP_BUY==OrderType()) {
         closePrice = MarketInfo(OrderSymbol(), MODE_BID);
         
      } else if (OP_SELL==OrderType()) {
         closePrice = MarketInfo(OrderSymbol(), MODE_ASK);
      }
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, SLIPPAGE);
      if (isClosed) {
         Print(message);
      } else {
         // Invalid ticket
         if (4108 == GetLastError()) {
            Print("4108:Invalid ticket");
         } else {
            string msg = "BUY OrderClose failed. Error:【" + ErrorDescription(GetLastError());
            msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
            msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
            int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
            msg += " Bid=" + DoubleToStr(closePrice, vdigits);
            Alert(msg);
         }
      }
   }
}

void closeNegativeProfitOrders(int MagicNumber, string message="", int slippagePerLot=0) export {
   int cnt = OrdersTotal();
   for (int pos=cnt-1; 0<=pos; pos--) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if ((OrderLots()*slippagePerLot) <= (OrderProfit()+OrderCommission()+OrderSwap())) continue;
      
      double closePrice = 0.0;
      if (OP_BUY==OrderType()) {
         closePrice = MarketInfo(OrderSymbol(), MODE_BID);
         
      } else if (OP_SELL==OrderType()) {
         closePrice = MarketInfo(OrderSymbol(), MODE_ASK);
      }
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), closePrice, SLIPPAGE);
      
      if (isClosed) {
         Print(message);
      } else {
         // Invalid ticket
         if (4108 == GetLastError()) {
            Print("4108:Invalid ticket");
         } else {
            string msg = "SELL OrderClose failed. Error:【" + ErrorDescription(GetLastError());
            msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
            msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
            int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
            msg += " Ask=" + DoubleToStr(closePrice, vdigits);
            Alert(msg);
         }
      }
   }
}


string getTimeFrame(ENUM_TIMEFRAMES tf) export {
   if (PERIOD_M1 == tf) {
      return "M1";
   }
   
   if (PERIOD_M5 == tf) {
      return "M5";
   }
   
   if (PERIOD_M15 == tf) {
      return "15";
   }
   
   if (PERIOD_M30 == tf) {
      return "30";
   }
   
   if (PERIOD_H1 == tf) {
      return "H1";
   }
   
   if (PERIOD_H4 == tf) {
      return "H4";
   }
   
   if (PERIOD_D1 == tf) {
      return "D1";
   }
   
   if (PERIOD_W1 == tf) {
      return "W1";
   }
   
   if (PERIOD_MN1 == tf) {
      return "MN";
   }
   
   return "";
}

string getAppliedPrice(ENUM_APPLIED_PRICE appliedPrice) export {
   if (PRICE_CLOSE == appliedPrice) {
      return "C";
   }
   
   if (PRICE_HIGH == appliedPrice) {
      return "H";
   }
   
   if (PRICE_LOW == appliedPrice) {
      return "L";
   }
   
   if (PRICE_MEDIAN == appliedPrice) {
      return "M";
   }
   
   if (PRICE_OPEN == appliedPrice) {
      return "O";
   }
   
   if (PRICE_TYPICAL == appliedPrice) {
      return "T";
   }
   
   if (PRICE_WEIGHTED == appliedPrice) {
      return "W";
   }
   return "";
}

string getMaMethod(ENUM_MA_METHOD MaMethod) export {
   if (MODE_SMA == MaMethod) {
      return "S";
   }
   if (MODE_EMA == MaMethod) {
      return "E";
   }
   if (MODE_SMMA == MaMethod) {
      return "M";
   }
   if (MODE_LWMA == MaMethod) {
      return "L";
   }
   return "";
}

double calculatePartLot(string symbolName, double lot, double multipler) export {
   double LotStepServer = MarketInfo(symbolName, MODE_LOTSTEP);
   double minLot = MarketInfo(symbolName, MODE_MINLOT);
   if (lot < (minLot+0.01)) {
      return 0.0;
   }
   double partLot = lot * multipler;
   partLot = MathCeil(partLot/LotStepServer)*LotStepServer;
   return partLot;
}

bool isExpire(datetime ExpireTime, bool EnableUseTimeControl=true) export {
   if (EnableUseTimeControl) {
      datetime now = TimeGMT();
      if (ExpireTime < now) {
         Alert("Use expired, please contact the author.(使用过期，请联系作者。) email：soko8@sina.com ");
         return true;
      }
   }
   
   return false;
}


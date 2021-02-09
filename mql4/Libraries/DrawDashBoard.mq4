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
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+
      int                  PairCount = 28;
string TradePairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};

const int RowInterval=0;
const int ColumnInterval=0;
const int RowHeight=40;

const string Font_Name = "Lucida Bright";
const int Font_Size = 8;
const int Border_Width = 1;


                                         //   1          2            3         4          5           6            7          8         9          10           11            12        13        14          15        16        17        18         19            20         21         22         23         24             25                   26          27           28           29           30           31              32          33
const string   ColumnName[33]             ={ "Disable", "Profit",    "Buy",    "BuyLot",  "BuyClose", "BuyProfit", "SellNum", "Sell",   "SellLot", "SellClose", "SellProfit", "BuyNum", "Spread", "PairName", "ADR",    "CDR",    "RSI",    "CCI",     "Stochastic"  "MA1",     "MA2",     "MA3",     "MA4",     "BidRatio1",   "RelativeStrength1", "BSRatio1",  "GAP1",     "HeatMap1",  "HeatMap2",  "HeatMap3",  "HeatMap4",  "Spare1",    "Spare2"    };
const string   ColumnShow[33]             ={ "~",       "123456.12", "B",      "1234.12", "CL",       "12345.12",  "12",      "S",      "1234.12", "CS",        "12345.12",   "12",     "12.1",   "EURUSD",   "123.1",  "123.1",  "123",    "-123",    "12.12",      "++",      "==",      "++",      "--",      "12.12% ==",   "-5 ==",             "-5.5 ==",   "-5.5 ==",  "12.1 ++",   "12.1 --",   "12.1 ==",   "12.1 ==",   "12.1 ==",   "12.1 =="   };
const string   ColumnType[33]             ={ "btn",     "lbl",       "btn",    "lbl",     "btn",      "lbl",       "lbl",     "btn",    "lbl",     "btn",       "lbl",        "lbl",    "lbl",    "btn",      "lbl",    "lbl",    "lbl",    "lbl",     "lbl",        "lbl",     "lbl",     "lbl",     "lbl",     "lbl",         "lbl",               "lbl",       "lbl",      "lbl",       "lbl",       "lbl",       "lbl",       "lbl",       "lbl"       };
const int      ColumnWidth[33]            ={  30,        116,         55,       72,        47,         88,          35,        55,       72,        47,          88,           35,       55,       124,        62,       62,       60,       62,        42,           42,        42,        42,        42,        139,           82,                  132,         102,        62,          62,          62,          62,          62,          62         };
const color    ColumnColor[33]            ={ clrWhite,  clrWhite,    clrWhite, clrWhite,  clrWhite,   clrWhite,    clrWhite,  clrWhite, clrWhite,  clrWhite,    clrWhite,     clrWhite, clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,            clrWhite,    clrWhite,   clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite    };
const color    ColumnColorBackground[33]  ={ clrBlack,  clrBlack,    clrBlack, clrBlack,  clrBlack,   clrBlack,    clrBlack,  clrBlack, clrBlack,  clrBlack,    clrBlack,     clrBlack, clrBlack, clrBlack,   clrBlack, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrBlack,  clrBlack,  clrBlack,  clrBlack,      clrBlack,            clrBlack,    clrBlack,   clrBlack,    clrBlack,    clrBlack,    clrBlack,    clrBlack,    clrWhite    };
const color    ColumnColorBorder[33]      ={ clrRed,    clrRed,      clrRed,   clrRed,    clrRed,     clrRed,      clrRed,    clrRed,   clrRed,    clrRed,      clrRed,       clrWhite, clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,            clrWhite,    clrWhite,   clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite    };

const string   h1ColumnShow[33]           ={ "~",       "Profit",    "B",      "Lot",     "CL",       "Profit",    "#",       "S",      "Lot",     "CS",        "Profit",     "#",      "Spd",    "Symbol",   "ADR",    "CDR",    "RSI",    "CCI",     "Sto",        "M5",      "15",      "H1",      "H4",      "BidRatio1",   "RelativeStrength1", "BSRatio1",  "GAP1",     "HeatMap1",  "HeatMap2",  "HeatMap3",  "HeatMap4",  "Spare1",    "Spare1"    };
const string   h1ColumnType[33]           ={ "btn",     "lbl",       "btn",    "lbl",     "btn",      "lbl",       "lbl",     "btn",    "lbl",     "btn",       "lbl",        "lbl",    "lbl",    "btn",      "lbl",    "lbl",    "lbl",    "lbl",     "lbl",        "lbl",     "lbl",     "lbl",     "lbl",     "lbl",         "lbl",               "lbl",       "lbl",      "lbl",       "lbl",       "lbl",       "lbl",       "lbl",       "lbl"       };
const int      h1ColumnWidth[33]          ={  30,        116,         55,       72,        47,         88,          35,        55,       72,        47,          88,           35,       55,       124,        62,       62,       60,       62,        42,           42,        42,        42,        42,        139,           82,                  132,         102,        62,          62,          62,          62,          62,          62         };
const color    h1ColumnColor[33]          ={ clrWhite,  clrWhite,    clrWhite, clrWhite,  clrWhite,   clrWhite,    clrWhite,  clrWhite, clrWhite,  clrWhite,    clrWhite,     clrWhite, clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,            clrWhite,    clrWhite,   clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite    };
const color    h1ColumnColorBackground[33]={ clrBlack,  clrBlack,    clrBlack, clrBlack,  clrBlack,   clrBlack,    clrBlack,  clrBlack, clrBlack,  clrBlack,    clrBlack,     clrBlack, clrBlack, clrBlack,   clrBlack, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrBlack,  clrBlack,  clrBlack,  clrBlack,      clrBlack,            clrBlack,    clrBlack,   clrBlack,    clrBlack,    clrBlack,    clrBlack,    clrBlack,    clrWhite    };
const color    h1ColumnColorBorder[33]    ={ clrRed,    clrRed,      clrRed,   clrRed,    clrRed,     clrRed,      clrRed,    clrRed,   clrRed,    clrRed,      clrRed,       clrWhite, clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,      clrWhite,            clrWhite,    clrWhite,   clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite,    clrWhite    };


/*
                                          //      1            2           3             4                5             6             7              8              9                10               11              12                  13              14              15           16            17            18            19            20            21             22
const string   ColumnName[32]             ={ "btnDisable", "lblProfit", "btnBuy",   "lblBuyLot",  "btnBuyClose",  "lblBuyProfit", "lblSellNum",    "btnSell",   "lblSellLot",   "btnSellClose",    "lblSellProfit",   "lblBuyNum",    "lblSpread",     "btnPair",     "lblADR",     "lblCDR",     "lblRSI",     "lblCCI",     "lblMA1",     "lblMA2",     "lblMA3",     "lblMA4",     "lblBidRatio1",     "lblRelativeStrength1",     "lblBSRatio1",     "lblGAP1",     "lblMA4",     "lblMA4",     "lblMA4",     "lblMA4",     "lblMA4",     "lblMA4"};
const int      ColumnWidth[32]            ={      30,          116,         55,          72,             47,           88,            35,            55,            72,              47,                88,              35,             55,              124,           62,           62,           60,           62,           42,           42,           42,            42,           139,                      82,                   132,             102,           62,           62,           62,           62,           62,           62};
const color    ColumnColor[32]            ={  clrWhite,     clrWhite,    clrWhite,    clrWhite,       clrWhite,     clrWhite,       clrWhite,      clrWhite,      clrWhite,        clrWhite,          clrWhite,        clrWhite,       clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,      clrWhite,                 clrWhite,               clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite};
const color    ColumnColorBackground[32]  ={  clrBlack,     clrBlack,    clrBlack,    clrBlack,       clrBlack,     clrBlack,       clrBlack,      clrBlack,      clrBlack,        clrBlack,          clrBlack,        clrBlack,       clrBlack,        clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,      clrBlack,                 clrBlack,               clrBlack,        clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack};
const color    ColumnColorBorder[32]      ={  clrRed,       clrRed,      clrRed,      clrRed,         clrRed,       clrRed,         clrRed,        clrRed,        clrRed,          clrRed,            clrRed,          clrWhite,       clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,      clrWhite,                 clrWhite,               clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite};

const int      h1ColumnWidth[32]          ={      30,          116,         55,          72,             47,           88,            35,            55,            72,              47,                88,              35,             55,              124,           62,           62,           60,           62,           42,           42,           42,            42,           139,                      82,                   132,             102,           62,           62,           62,           62,           62,           62};
const color    h1ColumnColor[32]          ={  clrWhite,     clrWhite,    clrWhite,    clrWhite,       clrWhite,     clrWhite,       clrWhite,      clrWhite,      clrWhite,        clrWhite,          clrWhite,        clrWhite,       clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,      clrWhite,                 clrWhite,               clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite};
const color    h1ColumnColorBackground[32]={  clrBlack,     clrBlack,    clrBlack,    clrBlack,       clrBlack,     clrBlack,       clrBlack,      clrBlack,      clrBlack,        clrBlack,          clrBlack,        clrBlack,       clrBlack,        clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,      clrBlack,                 clrBlack,               clrBlack,        clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack,     clrBlack};
const color    h1ColumnColorBorder[32]    ={  clrRed,       clrRed,      clrRed,      clrRed,         clrRed,       clrRed,         clrRed,        clrRed,        clrRed,          clrRed,            clrRed,          clrWhite,       clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,      clrWhite,                 clrWhite,               clrWhite,        clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite,     clrWhite};
*/
void DrawDashBoard() export {
   DrawHeader();
   DrawData(PairCount);
}

void DrawHeader() {
   
   int startXi = 2;
   int startYi = 310;
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
         SetText(hNamePrefix1+columnType+ColumnName[colIndex],h1ColumnShow[colIndex],x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
         x += h1ColumnWidth[colIndex] + ColumnInterval;
      } else if ("btn"==columnType) {
         CreateButton(hNamePrefix1+columnType+ColumnName[colIndex],h1ColumnShow[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
         x += h1ColumnWidth[colIndex] + ColumnInterval;
      } else if ("lbo"==columnType) {
         CreatePanel(pNamePrefix+hNamePrefix1+columnType+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
         SetObjText(hNamePrefix1+columnType+ColumnName[colIndex],h1ColumnShow[colIndex],x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
         x += h1ColumnWidth[colIndex] + ColumnInterval;
      }
   }

}

void DrawData(int rowCount) {
   int startXi = 2;
   int startYi = 350;
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
            SetText(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
         } else if ("btn"==columnType) {
            CreateButton(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
         } else if ("lbo"==columnType) {
            CreatePanel(panelNamePrefix+columnType+ColumnName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
            SetObjText(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
            x += ColumnWidth[colIndex] + ColumnInterval;
         }
      }
      ObjectSetString(chartId,ColumnName[0]+IntegerToString(i),OBJPROP_TEXT,IntegerToString(i+1, 2));

      y += RowHeight + RowInterval;

   }
}

/*
void DrawHeader() {
   int startXi = 2;
   int startYi = 310;
   int x = startXi;
   int y = startYi;
   const string pNamePrefix = "Rec";
   const string hNamePrefix1 = "H1";
   
   int colIndex = 0;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"D",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex]," All Profit",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"Buy",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"Lot L",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"CB",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"   L$",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"L#",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"Sell",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"Lot S",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"CS",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"   S$",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"S#",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"Spd",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"  Symbol",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreatePanel(pNamePrefix+hNamePrefix1+ColumnName[colIndex],x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColorBorder[colIndex],Border_Width);
   SetText(hNamePrefix1+ColumnName[colIndex],"ADR",x,y+RowInterval+Border_Width,h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"CDR",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"RSI",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"CCI",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"M5",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"15",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"30",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"H1",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"BidRatio1",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"RS1",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"B/S R1",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
   
   colIndex++;
   CreateButton(hNamePrefix1+ColumnName[colIndex],"GAP1",x,y,h1ColumnWidth[colIndex],RowHeight,h1ColumnColorBackground[colIndex],h1ColumnColor[colIndex]);
   x += h1ColumnWidth[colIndex] + ColumnInterval;
}

void DrawData() {
   int startXi = 2;
   int startYi = 350;
   int x = startXi;
   int y = startYi;
   int colIndex = 0;
   const string panelNamePrefix = "Rec";
   for (int i=0; i<PairCount; i++) {
      x = startXi;
      colIndex = 0;
      CreateButton(ColumnName[colIndex]+TradePairs[i],"~",x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"1234.123",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // buy
      colIndex++;
      CreateButton(ColumnName[colIndex]+TradePairs[i],"Buy",x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"12.12",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreateButton(ColumnName[colIndex]+TradePairs[i],"CB",x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"123.12",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"12",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // sell
      colIndex++;
      CreateButton(ColumnName[colIndex]+TradePairs[i],"Sell",x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"12.12",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreateButton(ColumnName[colIndex]+TradePairs[i],"CS",x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"123.12",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"12",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      // End Sell
      
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"12.1",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      colIndex++;
      CreateButton(ColumnName[colIndex]+TradePairs[i],TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // ADR
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"123",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // CDR
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"123",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // RSI
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"123",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // CCI
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"-123",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // MA1
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i]," ↑",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // MA2
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i]," ↓",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // MA3
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i]," ↑",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // MA4
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"＝",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // BidRatio%1
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"12.12% ＝",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // RelativeStrength1
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"-5 ↓",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // BS Ratio1
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"-9.9 ＝",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      // GAP1
      colIndex++;
      CreatePanel(panelNamePrefix+ColumnName[colIndex]+TradePairs[i],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
      SetText(ColumnName[colIndex]+TradePairs[i],"-9.9 ＝",x,y+RowInterval+Border_Width,ColumnColor[colIndex]);
      x += ColumnWidth[colIndex] + ColumnInterval;
      
      y += RowHeight + RowInterval;
   }

}

*/

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
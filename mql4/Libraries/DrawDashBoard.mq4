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
//#define COL_NO_STO2                                  28
//#define COL_NO_STO3                                  29
//#define COL_NO_                                  30

#define ROW_COUNT                                    28

/****************************RSI**********************************************/
const ENUM_TIMEFRAMES            Timeframe_RSI = PERIOD_H4;
const int                        Period_RSI = 14;
const ENUM_APPLIED_PRICE         Applied_Price_RSI = PRICE_CLOSE;
/****************************RSI**********************************************/

/****************************CCI**********************************************/
const ENUM_TIMEFRAMES            Timeframe_CCI = PERIOD_H4;
const int                        Period_CCI = 14;
const ENUM_APPLIED_PRICE         Applied_Price_CCI = PRICE_CLOSE;
/****************************CCI**********************************************/

/****************************SAR**********************************************/
const ENUM_TIMEFRAMES            Timeframe_SAR = PERIOD_H4;
const double                     Step_SAR = 0.02;
const double                     Maximum_SAR = 0.2;
/****************************SAR**********************************************/

/****************************MA1**********************************************/
const ENUM_TIMEFRAMES            Timeframe_MA1 = PERIOD_M5;
const int                        Period_MA1_Short  = 50;
const int                        Period_MA1_Medium = 100;
const int                        Period_MA1_Long   = 200;
const int                        Shift_MA1 = 0;
const ENUM_MA_METHOD             Method_MA1 = MODE_EMA;
const ENUM_APPLIED_PRICE         Applied_Price_MA1 = PRICE_CLOSE;
/****************************MA1**********************************************/

/****************************MA2**********************************************/
const ENUM_TIMEFRAMES            Timeframe_MA2 = PERIOD_M30;
const int                        Period_MA2_Short  = 50;
const int                        Period_MA2_Medium = 100;
const int                        Period_MA2_Long   = 200;
const int                        Shift_MA2 = 0;
const ENUM_MA_METHOD             Method_MA2 = MODE_EMA;
const ENUM_APPLIED_PRICE         Applied_Price_MA2 = PRICE_CLOSE;
/****************************MA2**********************************************/

/****************************MA3**********************************************/
const ENUM_TIMEFRAMES            Timeframe_MA3 = PERIOD_H1;
const int                        Period_MA3_Short  = 50;
const int                        Period_MA3_Medium = 100;
const int                        Period_MA3_Long   = 200;
const int                        Shift_MA3 = 0;
const ENUM_MA_METHOD             Method_MA3 = MODE_EMA;
const ENUM_APPLIED_PRICE         Applied_Price_MA3 = PRICE_CLOSE;
/****************************MA3**********************************************/

/****************************MA4**********************************************/
const ENUM_TIMEFRAMES            Timeframe_MA4 = PERIOD_H4;
const int                        Period_MA4_Short  = 50;
const int                        Period_MA4_Medium = 100;
const int                        Period_MA4_Long   = 200;
const int                        Shift_MA4 = 0;
const ENUM_MA_METHOD             Method_MA4 = MODE_EMA;
const ENUM_APPLIED_PRICE         Applied_Price_MA4 = PRICE_CLOSE;
/****************************MA4**********************************************/

/****************************GAP**********************************************/
const ENUM_TIMEFRAMES            Timeframe_GAP = PERIOD_H1;
const int                        Interval_GAP = 1800;   // 计算30分钟前BidRatio用
/****************************GAP**********************************************/

/****************************Stochastic1**************************************/
const ENUM_TIMEFRAMES            Timeframe_STO = PERIOD_H4;
const int                        Period_STO_K = 5;
const int                        Period_STO_SLOW = 3;
const int                        Period_STO_D = 3;
const ENUM_MA_METHOD             Method_STO = MODE_EMA;
                                 // 0 - Low/High or 1 - Close/Close
const int                        Price_Field_STO = 1;
/****************************Stochastic1**************************************/



const int RowInterval=0;
const int ColumnInterval=0;
const int RowHeight=40;

const string Font_Name = "Lucida Bright";
const int Font_Size = 8;
const int Border_Width = 1;
                                         //   1          2            3         4          5           6            7          8         9          10           11            12         13        14          15        16        17        18         19            20         21         22         23         24            25                  26               27         28              29              30              31           32          33
const string   ColumnName[33]             ={ "Disable", "Profit",    "Buy",    "BuyLot",  "CloseBuy", "BuyProfit", "BuyNum",  "Sell",   "SellLot", "CloseSell", "SellProfit", "SellNum", "Spread", "PairName", "ADR",    "CDR",    "RSI",    "CCI",     "SAR"         "MA1",     "MA2",     "MA3",     "MA4",     "BidRatio",   "RelativeStrength", "BSRatio",       "GAP",     "Stochastic1",  "Stochastic2",  "Stochastic3",  "HeatMap4",  "Spare1",    "Spare2"    };
const string   ColumnShow[33]             ={ "~",       "123456.12", "B",      "1234.12", "CL",       "12345.12",  "12",      "S",      "1234.12", "CS",        "12345.12",   "12",      "99.9",   "EURUSD",   "999.9",  "123.1",  "123",    "-123",    "12.12",      "++",      "==",      "++",      "--",      "12.12% ==",  "-5 ==",            "-5.5 ==",       "-5.5 ==", "12.1 ++",      "12.1 --",      "12.1 ==",      "12.1 ==",   "12.1 ==",   "12.1 =="   };
const string   ColumnType[33]             ={ "btn",     "lbl",       "btn",    "lbl",     "btn",      "lbl",       "lbl",     "btn",    "lbl",     "btn",       "lbl",        "lbl",     "lbl",    "btn",      "lbl",    "lbl",    "lbl",    "lbl",     "lbl",        "lbl",     "lbl",     "lbl",     "lbl",     "lbl",        "lbl",              "lbl",           "lbl",     "lbl",          "lbl",          "lbl",          "lbl",       "lbl",       "lbl"       };
const int      ColumnWidth[33]            ={  30,        134,         55,       106,       47,         120,         35,        55,       106,       47,          120,          35,        64,       124,        74,       74,       60,       65,        74,           52,        52,        52,        52,        80,           60,                 194,             76,        160,            100,            100,            62,          62,          62         };
const int      ColumnWidthAdjust[33]      ={  0,         2,           0,        2,         0,          2,           2,         0,        2,         0,           2,            2,         8,        0,          6,        6,        14,       4,         22,           12,        12,        12,        12,        2,            2,                  2,               2,         2,              2,              2,              12,          12,          12         };
const color    ColumnColor[33]            ={ clrWhite,  clrWhite,    clrWhite, clrWhite,  clrWhite,   clrWhite,    clrWhite,  clrWhite, clrWhite,  clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,     clrWhite,           clrWhite,        clrWhite,  clrWhite,       clrWhite,       clrWhite,       clrWhite,    clrWhite,    clrWhite    };
const color    ColumnColorBackground[33]  ={ clrBlack,  clrBlack,    clrBlack, clrBlack,  clrBlack,   clrBlack,    clrBlack,  clrBlack, clrBlack,  clrBlack,    clrBlack,     clrBlack,  clrBlack, clrBlack,   clrBlack, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrBlack,  clrBlack,  clrBlack,  clrBlack,     clrBlack,           clrBlack,        clrBlack,  clrBlack,       clrBlack,       clrBlack,       clrBlack,    clrBlack,    clrWhite    };
const color    ColumnColorBorder[33]      ={ clrWhite,  clrWhite,    clrWhite, clrWhite,  clrWhite,   clrWhite,    clrWhite,  clrWhite, clrWhite,  clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,     clrWhite,           clrWhite,        clrWhite,  clrWhite,       clrWhite,       clrWhite,       clrWhite,    clrWhite,    clrWhite    };

const string   h1ColumnShow[33]           ={ "~",       "Profit",    "CP",     "Lot",     "CL",       "Profit",    "#",       "CP",     "Lot",     "CS",        "Profit",     "#",       "Spd",    "Symbol",   "ADR",    "CDR",    "RSI",    "CCI",     "SAR",        "M5",      "30",      "H1",      "H4",      "BidR",       "Rel",              "BuySellRatio",  "GAP",     "Sto1",         "Sto2",         "Sto3",         "HeatMap4",  "Spare1",    "Spare1"    };
const string   h1ColumnType[33]           ={ "btn",     "lbl",       "btn",    "lbl",     "btn",      "lbl",       "lbl",     "btn",    "lbl",     "btn",       "lbl",        "lbl",     "lbl",    "btn",      "lbl",    "lbl",    "lbl",    "lbl",     "lbl",        "lbl",     "lbl",     "lbl",     "lbl",     "lbl",        "lbl",              "lbl",           "lbl",     "lbl",          "lbl",          "lbl",          "lbl",       "lbl",       "lbl"       };
const int      h1ColumnWidth[33]          ={  30,        134,         55,       106,       47,         120,         35,        55,       106,       47,          120,          35,        64,       124,        74,       74,       60,       65,        74,           52,        52,        52,        52,        80,           60,                 194,             76,        160,            100,            100,            62,          62,          62         };
const int      h1ColumnWidthAdjust[33]    ={  0,         39,          0,        30,        0,          30,          9,         0,        30,        0,           30,           9,         8,        0,          8,        8,        8,        8,         8,            7,         7,         7,         7,         10,           6,                  2,               6,         22,             22,             22,             12,          12,          12         };
const color    h1ColumnColor[33]          ={ clrWhite,  clrWhite,    clrWhite, clrWhite,  clrWhite,   clrWhite,    clrWhite,  clrWhite, clrWhite,  clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,     clrWhite,           clrWhite,        clrWhite,  clrWhite,       clrWhite,       clrWhite,       clrWhite,    clrWhite,    clrWhite    };
const color    h1ColumnColorBackground[33]={ clrBlack,  clrBlack,    clrNavy,  clrNavy,   clrNavy,    clrNavy,     clrNavy,   clrMaroon,clrMaroon, clrMaroon,   clrMaroon,    clrMaroon, clrBlack, clrBlack,   clrBlack, clrBlack, clrBlack, clrBlack,  clrBlack,     clrBlack,  clrBlack,  clrBlack,  clrBlack,  clrBlack,     clrBlack,           clrBlack,        clrBlack,  clrBlack,       clrBlack,       clrBlack,       clrBlack,    clrBlack,    clrWhite    };
const color    h1ColumnColorBorder[33]    ={ clrWhite,  clrWhite,    clrWhite, clrWhite,  clrWhite,   clrWhite,    clrWhite,  clrWhite, clrWhite,  clrWhite,    clrWhite,     clrWhite,  clrWhite, clrWhite,   clrWhite, clrWhite, clrWhite, clrWhite,  clrWhite,     clrWhite,  clrWhite,  clrWhite,  clrWhite,  clrWhite,     clrWhite,           clrWhite,        clrWhite,  clrWhite,       clrWhite,       clrWhite,       clrWhite,    clrWhite,    clrWhite    };


void DrawDashBoard(CList *symbolList) export {
   DrawHeader(2, 310);
   DrawData(2, 350, symbolList);
}


void DrawHeader(int startXi, int startYi) {
   int x = startXi;
   int y = startYi;
   const string pNamePrefix = "Rec";
   const string hNamePrefix1 = "H1";
   long chartId = 0;

   int columnCount = ArraySize(ColumnName);
   columnCount = columnCount - 3;
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
      columnCount = columnCount - 3;

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

      ObjectSetString(chartId,getObjectName(i, COL_NO_PAIR_NAME),OBJPROP_TEXT,si.getName());
      y += RowHeight + RowInterval;
   }

}


string getObjectName(int rowIndex, int columnIndex) export {
   return ColumnType[columnIndex]+ColumnName[columnIndex]+IntegerToString(rowIndex);
}


void refreshIndicatorsData(CList *symbolList, string &CurrencyArray[]) {
   int BarShift = 1;
   long chartId = 0;
   string objName = "";
   color fontColor = clrWhite;

   string symbolName = "";
   int rowCnt = symbolList.Total();
   
   
   double BidRatios[];
   double BidRatiosPre[];
   int BaseRelativeStrengths[];
   int BaseRelativeStrengthsPre[];
   ArrayResize(BidRatios, rowCnt);
   ArrayResize(BidRatiosPre, rowCnt);
   ArrayResize(BaseRelativeStrengths, rowCnt);
   ArrayResize(BaseRelativeStrengthsPre, rowCnt);
   
   
   double CurrencyStrengths[];
   double CurrencyStrengthsPre[];
   int currencySize=ArraySize(CurrencyArray);
   
   ArrayInitialize(CurrencyStrengths, 0.0);
   ArrayInitialize(CurrencyStrengthsPre, 0.0);
   /*
   for(int k=0; k<currencySize; k++) {
      CurrencyStrengths[k] = 0;
      CurrencyStrengthsPre[k] = 0;
   }
   */
   
   
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      symbolName = si.getRealName();
      double highGap = iHigh(symbolName, Timeframe_GAP, 0);
      double lowGap  = iLow( symbolName, Timeframe_GAP, 0);
      double rangeGap = highGap - lowGap;
      double VbidRatio = 0.0;
      double prevBidRatio = 0.0;
      if (rangeGap != 0.0) {
         VbidRatio = 100.0 * ((MarketInfo(symbolName, MODE_BID) - lowGap) / rangeGap );
         VbidRatio = MathMin(VbidRatio, 100);
         
         int shift = iBarShift(symbolName, PERIOD_M1, TimeCurrent()-Interval_GAP);
         double prevBid = iClose(symbolName, PERIOD_M1, shift);
         prevBidRatio = MathMin((prevBid-lowGap)/rangeGap*100, 100);
      }
      BidRatios[i] = VbidRatio;
      BidRatiosPre[i] = prevBidRatio;
      
      
      int BaseRelativeStrength = getRelativeStrength(VbidRatio);
      int QuoteRelativeStrength = 9-BaseRelativeStrength;
      
      int BaseRelativeStrengthPre = getRelativeStrength(prevBidRatio);
      int QuoteRelativeStrengthPre = 9-BaseRelativeStrengthPre;
      
      BaseRelativeStrengths[i] = BaseRelativeStrength;
      BaseRelativeStrengthsPre[i] = BaseRelativeStrengthPre;
      
      for (int j=0; j<currencySize; j++) {
         string currency = CurrencyArray[j];
         if (currency == StringSubstr(symbolName, 0, 3)) {
            CurrencyStrengths[j] += BaseRelativeStrength;
            CurrencyStrengthsPre[j] += BaseRelativeStrengthPre;
         }
         if (currency == StringSubstr(symbolName, 3, 3)) {
            CurrencyStrengths[j] += QuoteRelativeStrength;
            CurrencyStrengthsPre[j] += QuoteRelativeStrengthPre;
         }
      }
   
   }
   
   
   

   /*
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      string pair = si.getName();
      
      int BaseRelativeStrength = BaseRelativeStrengths[i];
      int QuoteRelativeStrength = 9-BaseRelativeStrength;
      
      int BaseRelativeStrengthPre = BaseRelativeStrengthsPre[i];
      int QuoteRelativeStrengthPre = 9-BaseRelativeStrengthPre;
      
      for (int j=0; j<currencySize; j++) {
         string currency = CurrencyArray[j];
         if (currency == StringSubstr(pair, 0, 3)) {
            CurrencyStrengths[j] += BaseRelativeStrength;
            CurrencyStrengthsPre[j] += BaseRelativeStrengthPre;
         }
         if (currency == StringSubstr(pair, 3, 3)) {
            CurrencyStrengths[j] += QuoteRelativeStrength;
            CurrencyStrengthsPre[j] += QuoteRelativeStrengthPre;
         }
      }
   }
   */
   
   for(int k=0; k<currencySize; k++) {
      CurrencyStrengths[k] = CurrencyStrengths[k]/(currencySize-1);
      CurrencyStrengthsPre[k] = CurrencyStrengthsPre[k]/(currencySize-1);
   }
   
   double BuyRatios[];
   double SellRatios[];
   
   double BuyRatiosPre[];
   double SellRatiosPre[];
   
   double GAPs[];
   
   ArrayResize(BuyRatios, rowCnt);
   ArrayResize(SellRatios, rowCnt);
   ArrayResize(BuyRatiosPre, rowCnt);
   ArrayResize(SellRatiosPre, rowCnt);
   ArrayResize(GAPs, rowCnt);
   
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      string pair = si.getName();
      
      for (int j=0; j<currencySize; j++) {
         string currency = CurrencyArray[j];
         if (currency == StringSubstr(pair, 0, 3)) {
            BuyRatios[i] = CurrencyStrengths[j];
            BuyRatiosPre[i] = CurrencyStrengthsPre[j];
         }
         if (currency == StringSubstr(pair, 3, 3)) {
            SellRatios[i] = CurrencyStrengths[j];
            SellRatiosPre[i] = CurrencyStrengthsPre[j];
         }
      }
      
      GAPs[i] = (BuyRatios[i]-SellRatios[i])-(BuyRatiosPre[i]-SellRatiosPre[i]);
      /*
      if (0 < gapDirection) {
         GAPs[i] = 1;
      } else if (gapDirection < 0) {
         GAPs[i] = -1;
      } else {
         GAPs[i] = 0;
      }
      */
      
   }
   
   
   
   
   
   
   
   
   
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      symbolName = si.getRealName();
      // Spread
      objName = getObjectName(i, COL_NO_SPREAD);
      int spread = (int)MarketInfo(symbolName,MODE_SPREAD);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,IntegerToString(spread, 3));
      if (30 < spread) {
         fontColor = clrGray;
      } else {
         fontColor = clrWhite;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      // ADR
      objName = getObjectName(i, COL_NO_ADR);
      double Vadr = GetAdrValues(symbolName, si.getPoint());
      string adr = DoubleToStr(Vadr, 0);
      adr = IntegerToString(StrToInteger(adr), 4);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,adr);
      
      // CDR
      objName = getObjectName(i, COL_NO_CDR);
      double Vcdr = (iHigh(symbolName, PERIOD_D1, 0) - iLow(symbolName, PERIOD_D1, 0))/si.getPoint();
      string cdr = DoubleToStr(Vcdr, 0);
      cdr = IntegerToString(StrToInteger(cdr), 4);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,cdr);
      
      // RSI
      objName = getObjectName(i, COL_NO_RSI);
      double Vrsi  = iRSI(symbolName,Timeframe_RSI,Period_RSI,Applied_Price_RSI,BarShift);
      string rsi = DoubleToStr(Vrsi, 0);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,rsi);
      fontColor = clrGray;
      if (75 <= Vrsi) {
         fontColor = clrRed;
      } else if (Vrsi <= 25) {
         fontColor = clrLime;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      // CCI
      objName = getObjectName(i, COL_NO_CCI);
      double Vcci  = iCCI(symbolName,Timeframe_CCI,Period_CCI,Applied_Price_CCI,BarShift);
      string cci = DoubleToStr(Vcci, 0);
      cci = IntegerToString(StrToInteger(cci), 4);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,cci);
      fontColor = clrGray;
      if (100 <= Vcci) {
         fontColor = clrRed;
      } else if (Vcci <= -100) {
         fontColor = clrLime;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      // SAR
      objName = getObjectName(i, COL_NO_SAR);
      double Vsar  = iSAR(symbolName,Timeframe_SAR,Step_SAR,Maximum_SAR,BarShift);
      double Vlow  = iLow(symbolName, Timeframe_SAR, BarShift);
      //double Vhigh = iHigh(TradePairs[i], Timeframe_SAR, BarShift);
      string sar = "▼";
      fontColor = clrRed;
      if (Vsar <= Vlow) {
         sar = "▲";
         fontColor = clrLime;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,sar);
      
      // MA1
      objName = getObjectName(i, COL_NO_MA1);
      double ma1Short   = iMA(symbolName,Timeframe_MA1,Period_MA1_Short,   Shift_MA1,Method_MA1,Applied_Price_MA1,BarShift);
      double ma1Medium  = iMA(symbolName,Timeframe_MA1,Period_MA1_Medium,  Shift_MA1,Method_MA1,Applied_Price_MA1,BarShift);
      double ma1Long    = iMA(symbolName,Timeframe_MA1,Period_MA1_Long,    Shift_MA1,Method_MA1,Applied_Price_MA1,BarShift);
      string ma1 = "〓";
      fontColor = clrYellow;
      if (ma1Long<ma1Medium && ma1Medium<ma1Short) {
         ma1 = "▲";
         fontColor = clrLime;
      } else if (ma1Long>ma1Medium && ma1Medium>ma1Short) {
         ma1 = "▼";
         fontColor = clrRed;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,ma1);
      
      // MA2
      objName = getObjectName(i, COL_NO_MA2);
      double ma2Short   = iMA(symbolName,Timeframe_MA2,Period_MA2_Short,   Shift_MA2,Method_MA2,Applied_Price_MA2,BarShift);
      double ma2Medium  = iMA(symbolName,Timeframe_MA2,Period_MA2_Medium,  Shift_MA2,Method_MA2,Applied_Price_MA2,BarShift);
      double ma2Long    = iMA(symbolName,Timeframe_MA2,Period_MA2_Long,    Shift_MA2,Method_MA2,Applied_Price_MA2,BarShift);
      string ma2 = "〓";
      fontColor = clrYellow;
      if (ma2Long<ma2Medium && ma2Medium<ma2Short) {
         ma2 = "▲";
         fontColor = clrLime;
      } else if (ma2Long>ma2Medium && ma2Medium>ma2Short) {
         ma2 = "▼";
         fontColor = clrRed;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,ma2);
      
      // MA3
      objName = getObjectName(i, COL_NO_MA3);
      double ma3Short   = iMA(symbolName,Timeframe_MA3,Period_MA3_Short,   Shift_MA3,Method_MA3,Applied_Price_MA3,BarShift);
      double ma3Medium  = iMA(symbolName,Timeframe_MA3,Period_MA3_Medium,  Shift_MA3,Method_MA3,Applied_Price_MA3,BarShift);
      double ma3Long    = iMA(symbolName,Timeframe_MA3,Period_MA3_Long,    Shift_MA3,Method_MA3,Applied_Price_MA3,BarShift);
      string ma3 = "〓";
      fontColor = clrYellow;
      if (ma3Long<ma3Medium && ma3Medium<ma3Short) {
         ma3 = "▲";
         fontColor = clrLime;
      } else if (ma3Long>ma3Medium && ma3Medium>ma3Short) {
         ma3 = "▼";
         fontColor = clrRed;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,ma3);
      
      // MA4
      objName = getObjectName(i, COL_NO_MA4);
      double ma4Short   = iMA(symbolName,Timeframe_MA4,Period_MA4_Short,   Shift_MA4,Method_MA4,Applied_Price_MA4,BarShift);
      double ma4Medium  = iMA(symbolName,Timeframe_MA4,Period_MA4_Medium,  Shift_MA4,Method_MA4,Applied_Price_MA4,BarShift);
      double ma4Long    = iMA(symbolName,Timeframe_MA4,Period_MA4_Long,    Shift_MA4,Method_MA4,Applied_Price_MA4,BarShift);
      string ma4 = "〓";
      fontColor = clrYellow;
      if (ma4Long<ma4Medium && ma4Medium<ma4Short) {
         ma4 = "▲";
         fontColor = clrLime;
      } else if (ma4Long>ma4Medium && ma4Medium>ma4Short) {
         ma4 = "▼";
         fontColor = clrRed;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,ma4);
      
      
      
      
      /*
      double highGap = iHigh(symbolName, Timeframe_GAP, 0);
      double lowGap  = iLow( symbolName, Timeframe_GAP, 0);
      double rangeGap = highGap - lowGap;
      if (rangeGap != 0.0) {
         // BidRatio
         objName = getObjectName(i, COL_NO_BID_RATIO);
         double VbidRatio = 100.0 * ((MarketInfo(symbolName, MODE_BID) - lowGap) / rangeGap );
         VbidRatio = MathMin(VbidRatio, 100);
         string bidRatio = DoubleToStr(VbidRatio, 1);
         ObjectSetString(chartId,objName,OBJPROP_TEXT,bidRatio);
         
         
         int shift = iBarShift(symbolName, PERIOD_M1, TimeCurrent()-Interval_GAP);
         double prevBid = iClose(symbolName, PERIOD_M1, shift);
         double prevBidRatio = MathMin((prevBid-lowGap)/rangeGap*100, 100);
         
         
         // RelativeStrength
         objName = getObjectName(i, COL_NO_REL_STRENGTH);
         int baseRelativeStrength = getRelativeStrength(VbidRatio);
         BaseRelativeStrengths[i] = baseRelativeStrength;
         int quoteRelativeStrength = 9-baseRelativeStrength;
         int VRelativeStrength = baseRelativeStrength - quoteRelativeStrength;
         string relativeStrength = IntegerToString(VRelativeStrength, 2);
         ObjectSetString(chartId,objName,OBJPROP_TEXT,relativeStrength);
         
         // BSRatio
         objName = getObjectName(i, COL_NO_BS_RATIO);
         
         
         // GAP
         objName = getObjectName(i, COL_NO_GAP);
      }
      */
      
      // BidRatio
      objName = getObjectName(i, COL_NO_BID_RATIO);
      string bidRatio = DoubleToStr(BidRatios[i], 1);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,bidRatio);
      
      // RelativeStrength
      objName = getObjectName(i, COL_NO_REL_STRENGTH);
      int baseRelativeStrength = BaseRelativeStrengths[i];
      int quoteRelativeStrength = 9-baseRelativeStrength;
      int VRelativeStrength = baseRelativeStrength - quoteRelativeStrength;
      string relativeStrength = IntegerToString(VRelativeStrength, 2);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,relativeStrength);
      
      // BSRatio
      objName = getObjectName(i, COL_NO_BS_RATIO);
      string BSRatio = DoubleToStr(BuyRatios[i], 1)+"-"+DoubleToStr(SellRatios[i], 1)+"="+DoubleToStr((BuyRatios[i]-SellRatios[i]), 1);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,BSRatio);
      
      // GAP
      objName = getObjectName(i, COL_NO_GAP);
      string GAP = DoubleToStr(GAPs[i], 1);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,GAP);
      
      
      // Stochastic
      objName = getObjectName(i, COL_NO_STO);
      double VstoMain   = iStochastic(symbolName,Timeframe_STO,Period_STO_K,Period_STO_D,Period_STO_SLOW,Method_STO,Price_Field_STO,MODE_MAIN,  BarShift);
      double VstoSignal = iStochastic(symbolName,Timeframe_STO,Period_STO_K,Period_STO_D,Period_STO_SLOW,Method_STO,Price_Field_STO,MODE_SIGNAL,BarShift);
      string sto = "M:" + DoubleToStr(VstoMain,2) + "--S:" + DoubleToStr(VstoSignal,2);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,sto);
      
   }
   
   

   
   

}

void refreshOrdersData(CList *symbolList, int MagicNumber) export {
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
   
   int cnt = OrdersTotal();
   string symbolName = "";
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

/*
double getBidRatio(string symbol, ENUM_TIMEFRAMES timeframe=PERIOD_D1) {
   double highValue = iHigh(symbol, timeframe, 0);
   double lowValue = iLow(symbol, timeframe, 0);
   double range = highValue - lowValue;
   if (NormalizeDouble(range, 5) < 0.00001) {
      return 0.0;
   }
   double bidRatio = 100.0 * ((MarketInfo(symbol, MODE_BID) - lowValue) / range );
   bidRatio = MathMin(bidRatio, 100);
   return bidRatio;
}
*/

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
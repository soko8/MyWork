//+------------------------------------------------------------------+
//|                                              EA_DashboardEAX.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Object.mqh>
#include <stdlib.mqh>
#include <Arrays\List.mqh>

#define COL_NO_Move                        0
#define COL_NO_H                           1
#define COL_NO_D                           2
#define COL_NO_N                           3
#define COL_NO_NewL                        4
#define COL_NO_CountL							 5
#define COL_NO_CloseL							 6
#define COL_NO_LotL                        7
#define COL_NO_ProfitL							 8
#define COL_NO_CDR                         9
#define COL_NO_Pair							   10
#define COL_NO_ADR							   11
#define COL_NO_NewS							   12
#define COL_NO_CountS							13
#define COL_NO_CloseS							14
#define COL_NO_LotS							   15
#define COL_NO_ProfitS							16
#define COL_NO_Spread							17
#define COL_NO_Profit							18
#define COL_NO_Pin1							   19
#define COL_NO_Pin2							   20
#define COL_NO_Pin3							   21
#define COL_NO_Pin4							   22
#define COL_NO_Pin5							   23
#define COL_NO_Pin6							   24
#define COL_NO_Pin7							   25
#define COL_NO_Pin8                       26
#define COL_NO_Pin9                       27
#define COL_NO_PairNm							28
#define COL_NO_UseSl                      29
#define COL_NO_AddSlP							30
#define COL_NO_SlP                        31
#define COL_NO_MnsSlP							32
#define COL_NO_UseTp                      33
#define COL_NO_AddTpP							34
#define COL_NO_TpP                        35
#define COL_NO_MnsTpP							36
#define COL_NO_TSfix                      37
#define COL_NO_AddFixP							38
#define COL_NO_FixP                       39
#define COL_NO_MnsFixP							40
#define COL_NO_TSatr                      41
#define COL_NO_TSsar                      42
#define COL_NO_SarVal							43
#define COL_NO_TSma                       44
#define COL_NO_MaVal                      45
#define COL_NO_AddOffset                  46
#define COL_NO_Offset							47
#define COL_NO_MnsOffset                  48
#define COL_NO_Sl2Open							49
#define COL_NO_AddSl2Now                  50
#define COL_NO_Sl2Now							51
#define COL_NO_MnsSl2Now                  52
#define COL_NO_Tp2Open							53
#define COL_NO_AddTp2Now                  54
#define COL_NO_Tp2Now							55
#define COL_NO_MnsTp2Now                  56


input ENUM_TIMEFRAMES      Timeframe                  = PERIOD_CURRENT;

input double               In_Lots                    = 0.01;

input bool                 In_Use_Pin1                = true;
input bool                 In_Use_Pin2                = true;
input bool                 In_Use_Pin3                = true;
input bool                 In_Use_Pin4                = true;
input bool                 In_Use_Pin5                = true;
input bool                 In_Use_Pin6                = true;
input bool                 In_Use_Pin7                = true;
input bool                 In_Use_Pin8                = true;
input bool                 In_Use_Pin9                = true;

input bool                 In_Use_Any_Entry           = false;
input bool                 In_Use_Any_Exit            = false;

input bool                 In_Enable_Stoploss         = true;
input int                  In_Stoploss_Point          = 200;

input bool                 In_Enable_TakeProfit       = true;
input int                  In_TakeProfit_Point        = 30000;

input bool                 In_Enable_TrailingStop     = true;

input bool                 In_Enable_TrailingStopFix  = true;
input int                  In_TrailingStop_Fix_Point  = 200;

input bool                 In_Enable_TrailingStopATR  = true;
input int                  In_TrailingStop_ATR_Period = 34;
input int                  In_TrailingStop_ATR_Multiple= 4;

input bool                 In_Enable_TrailingStopSar  = true;
input double               In_TrailingStop_Sar_Step   = 0.02;
input double               In_TrailingStop_Sar_Maximum= 0.2;

input bool                 In_Enable_TrailingStopMA   = true;
input int                  In_TrailingStop_MA_Period  = 55;
input ENUM_MA_METHOD       In_TrailingStop_MA_Method  = MODE_EMA;
input ENUM_APPLIED_PRICE   In_TrailingStop_MA_Applied_Price = PRICE_WEIGHTED;

input int                  In_TrailingStop_OffsetPoint= 100;
input int                  In_Max_Count_OnePair       = 1;

input string               Prefix                     = "";
input string               Surfix                     = "";
input bool                 UseDefaultPairs            = true;
input string               In_Pairs                   = "";
input int                  Magic_Number               = 88888;
input int                  Coordinates_X              = 10;
input int                  Coordinates_Y              = 30;
input bool                 In_4Kdisplay               = false;

const int SLIPPAGE = 0;
const string COMMENT = "DBEAX";
const string ObjNamePrefix = "DBEAX_";
const string panelNamePrefix = "Rec_";
const string H1NamePrefix = "H1";


const string   ColH1Text[57]        ={ ""      ,"H"     ,"D"     ,"N"     ,""      ,"Count L"  ,""         ,"Lot L" ,"Profit L" ,"CDR"   ,"Symbol","ADR"   ,""      ,"Count S"  ,""         ,"Lot S" ,"Profit S" ,"Spd"      ,"Profit"   ,"P1"    ,"P2"    ,"P3"    ,"P4"    ,"P5"    ,"P6"    ,"P7"    ,"P8"    ,"P9"    ,"Symbol"   ,"SL"   ,""      ,"SL Point",""    ,"TP"   ,""      ,"TP Point",""    ,"Fix"   ,""       ,"Fix Point",""     ,"ATR"   ,"Sar"   ,"Sar Value","MA"  ,"MA Value",""        ,"Offset",""            ,"Open"     ,""         ,"SL To Now",""         ,"Open"     ,""         ,"TP To Now",""       };
const string   ColH1Type[57]        ={ "lbl"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"      ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"      ,"btn"      ,"lbl"      ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"lbl"      ,"btn"  ,"lbl"   ,"lbl","lbl"      ,"btn"  ,"lbl"   ,"lbl","lbl"      ,"btn"   ,"lbl"    ,"lbl" ,"lbl"       ,"btn"   ,"btn"   ,"lbl"      ,"btn" ,"lbl"    ,"lbl"      ,"lbl"   ,"lbl"         ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"         ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"       };
const int      ColH1Width[57]       ={  18     , 18     , 18     , 18     , 0      , 56        , 0         , 42     , 58        , 34     , 64     , 34     , 0      , 56        , 0         , 42     , 58        , 30        , 58        , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 64        , 24    , 0      , 76  , 0         , 24    , 0      , 76  , 0         , 24     , 0       , 66   , 0          , 40     , 30     , 66        , 26   , 66      , 0         , 66     , 0            , 50        , 0         , 86     , 0            , 50        , 0         , 86     , 0          };
const int      ColH1AdjustX[57]     ={  0      , 0      , 0      , 0      , 0      , 4         , 0         , 6      , 6         , 2      , 8      , 3      , 0      , 2         , 0         , 4      , 6         , 2         , 12        , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 8         , 0     , 0      , 12  , 0         , 0     , 0      , 11  , 0         , 0      , 0       , 6    , 0          , 0      , 0      , 2         , 0    , 4       , 0         , 12     , 0            , 7         , 0         , 10     , 0            , 7         , 0         , 8      , 0          };
                                    //   1       2        3        4        5        6           7           8        9           10       11       12       13       14          15         　16        17         18          19          20       21       22       23       24       25       26       27       28       29          30      31       32    33          34      35       36    37          38       39        40     41           42       43       44          45     46        47          48       49             50          51          52      53              54          55          56       57
const string   ColName[57]          ={ "Move"  ,"H"     ,"D"     ,"N"     ,"NewL"  ,"CountL"   ,"CloseL"   ,"LotL"  ,"ProfitL"  ,"CDR"   ,"Pair"  ,"ADR"   ,"NewS"  ,"CountS"   ,"CloseS"   ,"LotS"  ,"ProfitS"  ,"Spread"   ,"Profit"   ,"Pin1"  ,"Pin2"  ,"Pin3"  ,"Pin4"  ,"Pin5"  ,"Pin6"  ,"Pin7"  ,"Pin8"  ,"Pin9"  ,"PairNm"   ,"UseSl","AddSlP","SlP","MnsSlP"   ,"UseTp","AddTpP","TpP","MnsTpP"   ,"TSfix" ,"AddFixP","FixP","MnsFixP"   ,"TSatr" ,"TSsar" ,"SarVal"   ,"TSma","MaVal"  ,"AddOffset","Offset","MnsOffset"   ,"Sl2Open"  ,"AddSl2Now","Sl2Now","MnsSl2Now"   ,"Tp2Open"  ,"AddTp2Now","Tp2Now","MnsTp2Now" };
const string   ColText[57]          ={ "~"     ,"H"     ,"D"     ,"N"     ,"+"     ,"99"       ,"-"        ,"99.99" ,"9999.99"  ,"CDR"   ,"EURUSD","ADR"   ,"+"     ,"10"       ,"-"        ,"12.12" ,"1234.12"  ,"123"      ,"1234.12"  ,"1"     ,"2"     ,"3"     ,"4"     ,"5"     ,"6"     ,"7"     ,"8"     ,"9"     ,""         ,"Sl"   ,"+"     ,"123","-"        ,"Tp"   ,"+"     ,"123","-"        ,"Fix"   ,"+"      ,"123" ,"-"         ,"ATR"   ,"Sar"   ,"12.12345" ,"MA"  ,"12.1234","+"        ,"123"   ,"-"           ,"12345"    ,"+"        ,"12345" ,"-"           ,"12345"    ,"+"        ,"12345" ,"-"         };
const string   ColType[57]          ={ "btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"lbl"      ,"btn"      ,"lbl"   ,"lbl"      ,"lbl"   ,"btn"   ,"lbl"   ,"btn"   ,"lbl"      ,"btn"      ,"lbl"   ,"lbl"      ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"btn"      ,"btn"  ,"btn"   ,"btn","btn"      ,"btn"  ,"btn"   ,"btn","btn"      ,"btn"   ,"btn"    ,"btn" ,"btn"       ,"btn"   ,"btn"   ,"lbl"      ,"btn" ,"lbl"    ,"btn"      ,"lbl"   ,"btn"         ,"lbl"      ,"btn"      ,"lbl"   ,"btn"         ,"lbl"      ,"btn"      ,"lbl"   ,"btn"       };
const int      ColWidth[57]         ={  18     , 18     , 18     , 18     , 18     , 20        , 18        , 42     , 58        , 34     , 64     , 34     , 18     , 20        , 18        , 42     , 58        , 30        , 58        , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 64        , 24    , 18     , 40  , 18        , 24    , 18     , 40  , 18        , 24     , 18      , 30   , 18         , 40     , 30     , 66        , 26   , 66      , 18        , 30     , 18           , 50        , 18        , 50     , 18           , 50        , 18        , 50     , 18         };
const int      ColAdjustX[57]       ={  0      , 0      , 0      , 0      , 0      , 2         , 0         , 2      , 2         , 2      , 0      , 2      , 0      , 2         , 0         , 2      , 2         , 2         , 2         , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 0         , 0     , 0      , 0   , 0         , 0     , 0      , 0   , 0         , 0      , 0       , 0    , 0          , 0      , 0      , 2         , 0    , 2       , 0         , 2      , 0            , 2         , 0         , 2      , 0            , 2         , 0         , 2      , 0          };

const int      ColWidth4K[57]       ={  10     , 10     , 10     , 10     , 30     , 30        , 30        , 55     , 106       , 47     , 120    , 46     , 64     , 124       , 74        , 74     , 60        , 65        , 74        , 52     , 52     , 52     , 52     , 80     , 60     , 60     , 76     , 160    , 160       , 120   , 120    , 120 , 120       , 120   , 120    , 120 , 120       , 120    , 120     , 120  , 120        , 120    , 120    , 120       , 120  , 120     , 120       , 120    , 120          , 120       , 120       , 120    , 120          , 120       , 120       , 120    , 120        };
const int      ColAdjustX4K[57]     ={  0      , 0      , 0      , 2      , 0      , 2         , 0         , 0      , 2         , 0      , 2      , 0      , 8      , 0         , 6         , 6      , 4         , 4         , 2         , 2      , 4      , 4      , 4      , 2      , 2      , 2      , 2      , 2      , 2         , 2     , 2      , 2   , 2         , 2     , 2      , 2   , 2         , 2      , 2       , 2    , 2          , 2      , 2      , 2         , 2    , 2       , 2         , 2      , 2            , 2         , 2         , 2      , 2            , 2         , 2         , 2      , 2          };

const string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};


const int      Border_Width   = 1;
const int      RowHeight      = 25;
const int      RowInterval    = 0;
const int      ColumnInterval = 0;
const color    ColBgClrLblH1  = clrMidnightBlue;
const color    ColBdClrLblH1  = clrWhite;
const color    ColBgClrLbl    = clrBlack;
const color    ColBdClrLbl    = clrBlack;
const color    ColBgClrBtn    = clrBlack;
const color    ColFtClrLbl    = clrWhite;
const color    ColFtClrBtn    = clrWhite;

const int      Start_X        = 10;
const int      Start_Y        = 10;

CList *SymbolList;
string SymbolArray[];
int gvCountSymbol, gvMaxCntOnePair;
bool  gvIsAuto = false, gvUsePin[9];


int OnInit() {

   initSymbols();
   Draw(Start_X, Start_Y, SymbolList);
   EventSetTimer(1);
   

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
   
}

int search(const string &strArray[], const string e) {
   int cnt = ArraySize(strArray);
   for (int i=0; i<cnt; i++) {
      if (e == strArray[i]) {
         return i;
      }
   }
   return -1;
}

void readOrders() {
   int cnt = SymbolList.Total();
   for (int i=0; i<cnt; i++) {
      SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
      si.clearOrderListL();
      si.clearOrderListS();
   }
   
   // from latest(newest) to oldest (positon 0 == the oldest Order. position Max == the latest(newest) Order.)
   for (int i=OrdersTotal()-1; 0<=i; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (Magic_Number == OrderMagicNumber()) {
            string symbolNm = OrderSymbol();
            StringReplace(symbolNm, Prefix, "");
            StringReplace(symbolNm, Surfix, "");
            int pos = search(SymbolArray, symbolNm);
            if (0 <= pos) {
               SymbolInfo *si = SymbolList.GetNodeAtIndex(pos);
               if (OP_BUY == OrderType()) {
                  OrderInfo *oi = new OrderInfo(OrderTicket());
                  si.add2OrderListL(oi);
               } else 
               if (OP_SELL == OrderType()) {
                  OrderInfo *oi = new OrderInfo(OrderTicket());
                  si.add2OrderListS(oi);
               }
            }
         }
      } else {
         Print("Failed to call OrderSelect() method @ position #", i, " Error code=", ErrorDescription(GetLastError()));
      }
   }
}

void update1Row() {

}

void initSymbols() {
   SymbolList = new CList();
   if (UseDefaultPairs) {
      gvCountSymbol = ArraySize(DefaultPairs);
      //ArrayResize(SymbolArray, gvCountSymbol);
      ArrayCopy(SymbolArray, DefaultPairs);

   } else {
      ushort u_sep = StringGetCharacter(",", 0);
      gvCountSymbol = StringSplit(In_Pairs, u_sep, SymbolArray);
   }

   for (int i=0; i<gvCountSymbol; i++) {
      SymbolInfo *si = new SymbolInfo(SymbolArray[i], Prefix, Surfix, i);
      si.setEnableSl(In_Enable_Stoploss);
      si.setSlPoint(In_Stoploss_Point);
      si.setEnableTp(In_Enable_TakeProfit);
      si.setTpPoint(In_TakeProfit_Point);
      si.setEnableTrailingStop(In_Enable_TrailingStop);
      si.setEnableTrailingStopFix(In_Enable_TrailingStopFix);
      si.setTrailingStopFixPoint(In_TrailingStop_Fix_Point);
      si.setEnableTrailingStopAtr(In_Enable_TrailingStopATR);
      si.setEnableTrailingStopSar(In_Enable_TrailingStopSar);
      si.setEnableTrailingStopMa(In_Enable_TrailingStopMA);
      si.setTrailingStopOffset(In_TrailingStop_OffsetPoint);
      si.setEnabled(true);
      si.setMultipleAtr(In_TrailingStop_ATR_Multiple);
      /*
      si.setSignal(0, 0);
      si.setSignal(1, 0);
      si.setSignal(2, 0);
      si.setSignal(3, 0);
      si.setSignal(4, 0);
      si.setSignal(5, 0);
      si.setSignal(6, 0);
      si.setSignal(7, 0);
      si.setSignal(8, 0);
      */
      SymbolList.Add(si);
   }
}

void Draw(int startXi, int startYi, CList *symbolList) {
   int x = startXi;
   int y = startYi;
   long chartId = 0;
   
   int ColumnWidth[];
   int ColumnWidthAdjust[];
   int ColumnH1Width[];
   int ColumnH1WidthAdjust[];
   int columnCount = ArraySize(ColName);
   //ArrayResize(ColumnWidth, columnCount);
   
   if (In_4Kdisplay) {
      ArrayCopy(ColumnWidth, ColWidth4K);
      ArrayCopy(ColumnWidthAdjust, ColAdjustX4K);
   } else {
      ArrayCopy(ColumnWidth, ColWidth);
      ArrayCopy(ColumnWidthAdjust, ColAdjustX);
      ArrayCopy(ColumnH1Width, ColH1Width);
      ArrayCopy(ColumnH1WidthAdjust, ColH1AdjustX);
   }
   
   // header row
   for (int colIndex=0; colIndex<columnCount; colIndex++) {
      string columnType = ColH1Type[colIndex];
      if ("lbl"==columnType) {
         CreatePanel(ObjNamePrefix+H1NamePrefix+panelNamePrefix+columnType+ColName[colIndex],x,y,ColumnH1Width[colIndex],RowHeight,ColBgClrLblH1,ColBdClrLblH1,Border_Width);
         SetText(ObjNamePrefix+H1NamePrefix+columnType+ColName[colIndex],ColH1Text[colIndex],x+ColumnH1WidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColFtClrLbl);
         x += ColumnH1Width[colIndex] + ColumnInterval;

      } else if ("btn"==columnType) {
         CreateButton(ObjNamePrefix+H1NamePrefix+columnType+ColName[colIndex],ColH1Text[colIndex],x,y,ColumnH1Width[colIndex],RowHeight,ColBgClrBtn,ColFtClrBtn);
         x += ColumnH1Width[colIndex] + ColumnInterval;

      } else if ("lbo"==columnType) {
         CreatePanel(ObjNamePrefix+H1NamePrefix+panelNamePrefix+columnType+ColName[colIndex],x,y,ColumnH1Width[colIndex],RowHeight,ColBgClrLblH1,ColBdClrLblH1,Border_Width);
         SetObjText(ObjNamePrefix+H1NamePrefix+columnType+ColName[colIndex],ColH1Text[colIndex],x+ColumnH1WidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColFtClrLbl);
         x += ColumnH1Width[colIndex] + ColumnInterval;
      }
   }
   y += RowHeight + RowInterval;

   // data rows
   int rowCnt = symbolList.Total();
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      x = startXi;

      for (int colIndex=0; colIndex<columnCount; colIndex++) {
         string columnType = ColType[colIndex];
         if ("lbl"==columnType) {
            CreatePanel(ObjNamePrefix+panelNamePrefix+columnType+ColName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColBgClrLbl,ColBdClrLbl,Border_Width);
            SetText(ObjNamePrefix+columnType+ColName[colIndex]+IntegerToString(i),ColText[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColFtClrLbl);
            x += ColumnWidth[colIndex] + ColumnInterval;
            if(1==i%2) {
               ObjectSetInteger(chartId,ObjNamePrefix+columnType+ColName[colIndex]+IntegerToString(i),OBJPROP_BGCOLOR,C'41,41,41');
            }

         } else if ("btn"==columnType) {
            CreateButton(ObjNamePrefix+columnType+ColName[colIndex]+IntegerToString(i),ColText[colIndex],x,y,ColumnWidth[colIndex],RowHeight,ColBgClrBtn,ColFtClrBtn);
            x += ColumnWidth[colIndex] + ColumnInterval;

         } else if ("lbo"==columnType) {
            CreatePanel(ObjNamePrefix+panelNamePrefix+columnType+ColName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColBgClrLbl,ColBdClrLbl,Border_Width);
            SetObjText(ObjNamePrefix+columnType+ColName[colIndex]+IntegerToString(i),ColText[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColFtClrLbl);
            x += ColumnWidth[colIndex] + ColumnInterval;
         }
      }

      ObjectSetString(chartId,getObjectName(i, COL_NO_Pair),OBJPROP_TEXT,si.getName());
      ObjectSetString(chartId,getObjectName(i, COL_NO_PairNm),OBJPROP_TEXT,si.getName());
      y += RowHeight + RowInterval;
   }

}

string getObjectName(int rowIndex, int columnIndex) export {
   return ObjNamePrefix+ColType[columnIndex]+ColName[columnIndex]+IntegerToString(rowIndex);
}

void SetText(string name,string text,int x,int y,color fontColor,int fontSize=7) {
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

void CreateButton(string btnName,string text,int x,int y,int width,int height,int backgroundColor=clrBlack,int textColor=clrWhite, int fontSize = 7, color borderColor=clrNONE, string font="Arial", ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) {
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
   ObjectSetInteger(chartId,btnName,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(chartId,btnName,OBJPROP_COLOR,textColor);
   ObjectSetString(chartId,btnName,OBJPROP_FONT,font);
   ObjectSetInteger(chartId,btnName,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,btnName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartId,btnName,OBJPROP_BORDER_TYPE,BORDER_RAISED);
}

class OrderInfo : public CObject {
private:

protected:
   int               ticketId;            // 订单号
   double            openPrice;           // 开仓价
   datetime          openTime;
   double            lotSize;             // 手数
   double            tpPrice;             // 止盈价
   double            slPrice;             // 止损价
   int               operationType;       // 订单类型
   string            symbolName;          // 货币对名
   bool              active;              // 订单是否可激活
   bool              closed;              // 订单是否被平仓
   bool              valid;               // 订单是否有效
   double            nextTrendPrice;      // 下一个趋势加仓价位
   double            nextRetracePrice;    // 下一个回调加仓价位
   bool              retraceOrder;        // 订单是否是回调单
   double            profit;

public:
                     //OrderInfo() { active = false;closed = false;valid = false; }
                     //OrderInfo(int ticket) { ticketId = ticket; }
                     OrderInfo(int ticket);
                     //OrderInfo(int ticket, string name) { ticketId = ticket;symbolName = name; }
                    ~OrderInfo() {}

   void              setTicketId(int ticketNo)           { ticketId = ticketNo;           }
   int               getTicketId(void)             const { return(ticketId);              }

   void              setOpenPrice(double price)          { openPrice = price;             }
   double            getOpenPrice(void)            const { return(openPrice);             }

   void              setOpenTime(datetime tm)            { openTime = tm;                 }
   datetime          getOpenTime(void)             const { return(openTime);              }


   void              setLotSize(double lots)             { lotSize = lots;                }
   double            getLotSize(void)              const { return(lotSize);               }

   void              setTpPrice(double price)            { tpPrice = price;               }
   double            getTpPrice(void)              const { return(tpPrice);               }

   void              setSlPrice(double price)            { slPrice = price;               }
   double            getSlPrice(void)              const { return(slPrice);               }

   void              setOperationType(int op)            { operationType = op;            }
   int               getOperationType(void)        const { return(operationType);         }

   void              setSymbolName(string symbolNm)      { symbolName = symbolNm;         }
   string            getSymbolName(void)           const { return(symbolName);            }

   void              setActive(bool actived)             { this.active = actived;         }
   bool              isActive(void)                const { return(active);                }

   void              setClosed(bool close)               { this.closed = close;           }
   bool              isClosed(void)                const { return(closed);                }

   void              setValid(bool valided)              { this.valid = valided;          }
   bool              isValid(void)                 const { return(valid);                 }

   void              setNextTrendPrice(double price)     { nextTrendPrice = price;        }
   double            getNextTrendPrice(void)       const { return(nextTrendPrice);        }
   
   void              setNextRetracePrice(double price)   { nextRetracePrice = price;      }
   double            getNextRetracePrice(void)     const { return(nextRetracePrice);      }

   void              setRetraceOrder(bool retrace)       { this.retraceOrder = retrace;   }
   bool              isRetraceOrder(void)          const { return(retraceOrder);          }

   double            getProfit(void) const;
   int               getPoint_Sl2OpenPrice(void) const;
   int               getPoint_Sl2CurrentPrice(void) const;
   int               getPoint_Tp2OpenPrice(void) const;
   int               getPoint_Tp2CurrentPrice(void) const;
};

OrderInfo::OrderInfo(int ticket) {
   ticketId = ticket;
   if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
      symbolName = OrderSymbol();
      openPrice = OrderOpenPrice();
      openTime = OrderOpenTime();
      operationType = OrderType();
      lotSize = OrderLots();
      slPrice = OrderStopLoss();
      tpPrice = OrderTakeProfit();

   } else {
      Print("Failed to call OrderSelect() method for ticket #", ticketId, " Error code=", ErrorDescription(GetLastError()));
   }
}

double OrderInfo::getProfit(void) const {
   double profit_ = 0.0;
   if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
      profit_ += OrderProfit();
      profit_ += OrderCommission();
      profit_ += OrderSwap();

   } else {
      Print("Failed to call OrderSelect() method for ticket #", ticketId, " Error code=", ErrorDescription(GetLastError()));
   }
   return profit_;
}

int OrderInfo::getPoint_Sl2OpenPrice(void) const {
   if (slPrice < 0.0000001) return 0;
   double diff = 0.0;
   if (OP_BUY == operationType) diff = slPrice - openPrice;
   else if (OP_SELL == operationType) diff = openPrice - slPrice;
   return (int)(diff/MarketInfo(symbolName,MODE_POINT));
}

int OrderInfo::getPoint_Tp2OpenPrice(void) const {
   if (tpPrice < 0.0000001) return 0;
   double diff = 0.0;
   if (OP_BUY == operationType) diff = tpPrice - openPrice;
   else if (OP_SELL == operationType) diff = openPrice - tpPrice;
   return (int)(diff/MarketInfo(symbolName,MODE_POINT));
}

int OrderInfo::getPoint_Sl2CurrentPrice(void) const {
   if (slPrice < 0.0000001) return 0;
   double diff = 0.0;
   if (OP_BUY == operationType) diff = slPrice - MarketInfo(symbolName,MODE_BID);
   else if (OP_SELL == operationType) diff = MarketInfo(symbolName,MODE_ASK) - slPrice;
   return (int)(diff/MarketInfo(symbolName,MODE_POINT));
}

int OrderInfo::getPoint_Tp2CurrentPrice(void) const {
   if (tpPrice < 0.0000001) return 0;
   double diff = 0.0;
   if (OP_BUY == operationType) diff = tpPrice - MarketInfo(symbolName,MODE_BID);
   else if (OP_SELL == operationType) diff = MarketInfo(symbolName,MODE_ASK) - tpPrice;
   return (int)(diff/MarketInfo(symbolName,MODE_POINT));
}

class SymbolInfo : public CObject {
private:
protected:
   string            name;
   string            prefix;
   string            suffix;
   double            point;
   int               digits;
   CList             *OrderListL;
   int               orderCountL;
   double            lotL;
   double            profitL;
   CList             *OrderListS;
   int               orderCountS;
   double            lotS;
   double            profitS;
   int               index;
   double            stopLoss;
   double            takeProfit;
   double            trailingStop;
   bool              enabled;
   int               cutTimes;
   double            maxDD;
   double            maxProfit;
   
   bool              enableSl;
   int               slPoint;
   bool              enableTp;
   int               tpPoint;
   bool              enableTrailingStop;
   bool              enableTrailingStopFix;
   int               trailingStopFixPoint;
   
   int               trailingStopOffset;
   
   bool              enableTrailingStopAtr;
   double            multipleAtr;
   double            atrValue;
   
   bool              enableTrailingStopSar;
   double            sarValue;
   
   bool              enableTrailingStopMa;
   double            maValue;
   
   double            adr;
   double            cdr;
   
   int               signals[9];
   
public:
                     SymbolInfo() {}
                     SymbolInfo(string SymbolShortName, string SymbolPrefix="", string SymbolSuffix="", int Index=0);
                    ~SymbolInfo() {}
   void              setName(string symbolNm)                     { name = symbolNm;            }
   string            getName(void)                          const { return(name);               }
   
   void              setPrefix(string SymbolPrefix)               { prefix = SymbolPrefix;      }
   string            getPrefix(void)                        const { return(prefix);             }
   
   void              setSuffix(string SymbolSuffix)               { suffix = SymbolSuffix;      }
   string            getSuffix(void)                        const { return(suffix);             }
   string            getRealName(void)                      const { return(prefix+name+suffix); }
   
   int               spread()                               const { return((int)MarketInfo(prefix+name+suffix,MODE_SPREAD));  }
   
   void              setPoint(double vPoint)                      { point = vPoint;             }
   double            getPoint(void)                         const { return(point);              }
   
   void              setDigits(int vDigits)                       { digits = vDigits;           }
   int               getDigits(void)                        const { return(digits);             }
   /*
   void              setOrderCountL(int vOrderCountL)             { orderCountL = vOrderCountL; }
   int               getOrderCountL(void)                   const { return(orderCountL);        }
   
   void              setLotL(double vLotL)                        { lotL = vLotL;               }
   double            getLotL(void)                          const { return(lotL);               }
   
   void              setProfitL(double vProfitL)                  { profitL = vProfitL;         }
   double            getProfitL(void)                       const { return(profitL);            }
   
   void              setOrderCountS(int vOrderCountS)             { orderCountS = vOrderCountS; }
   int               getOrderCountS(void)                   const { return(orderCountS);        }
   
   void              setLotS(double vLotS)                        { lotS = vLotS;               }
   double            getLotS(void)                          const { return(lotS);               }
   
   void              setProfitS(double vProfitS)                  { profitS = vProfitS;         }
   double            getProfitS(void)                       const { return(profitS);            }
   */
   double            getProfit(void)                        const { return(profitL+profitS);    }
   
   void              setIndex(int vIndex)                         { index = vIndex;             }
   int               getIndex(void)                         const { return(index);              }
   
   void              setStopLoss(double vStopLoss)                { stopLoss = vStopLoss;       }
   double            getStopLoss(void)                      const { return(stopLoss);           }
   
   void              setTakeProfit(double vTakeProfit)            { takeProfit = vTakeProfit;   }
   double            getTakeProfit(void)                    const { return(takeProfit);         }
   
   void              setTrailingStop(double vTrailStop)           { trailingStop = vTrailStop;  }
   double            getTrailingStop(void)                  const { return(trailingStop);       }
   
   void              setEnabled(bool vEnabled)                    { this.enabled = vEnabled;    }
   bool              isEnabled(void)                        const { return(enabled);            }
   
   void              setCutTimes(int vCutTimes)                   { cutTimes = vCutTimes;       }
   int               getCutTimes(void)                      const { return(cutTimes);           }
   
   void              setMaxDD(double vMaxDD)                      { maxDD = vMaxDD;             }
   double            getMaxDD(void)                         const { return(maxDD);              }
   
   void              setMaxProfit(double vMaxProfit)              { maxProfit = vMaxProfit;     }
   double            getMaxProfit(void)                     const { return(maxProfit);          }
   
   void              setOrderListL(CList *orderList)              { OrderListL = orderList;     }
   CList             *getOrderListL(void)                   const { return(OrderListL);         }
   
   void              setOrderListS(CList *orderList)              { OrderListS = orderList;     }
   CList             *getOrderListS(void)                   const { return(OrderListS);         }
   
   void              setEnableSl(bool enable)                     { this.enableSl = enable;     }
   bool              isEnableSl(void)                       const { return(enableSl);           }
   
   void              setSlPoint(int vPoint)                       { slPoint = vPoint;           }
   int               getSlPoint(void)                       const { return(slPoint);            }
   
   void              setEnableTp(bool enable)                     { this.enableSl = enable;     }
   bool              isEnableTp(void)                       const { return(enableSl);           }
   
   void              setTpPoint(int vPoint)                       { tpPoint = vPoint;           }
   int               getTpPoint(void)                       const { return(tpPoint);            }
   
   void              setEnableTrailingStop(bool enable)           { this.enableTrailingStop = enable;    }
   bool              isEnableTrailingStop(void)             const { return(enableTrailingStop);          }
   
   void              setEnableTrailingStopFix(bool enable)        { this.enableTrailingStopFix = enable; }
   bool              isEnableTrailingStopFix(void)          const { return(enableTrailingStopFix);       }
   
   void              setTrailingStopFixPoint(int vPoint)          { trailingStopFixPoint = vPoint;       }
   int               getTrailingStopFixPoint(void)          const { return(trailingStopFixPoint);        }
   
   void              setTrailingStopOffset(int vPoint)            { trailingStopOffset = vPoint;         }
   int               getTrailingStopOffset(void)            const { return(trailingStopOffset);          }
   
   void              setEnableTrailingStopAtr(bool enable)        { this.enableTrailingStopAtr = enable; }
   bool              isEnableTrailingStopAtr(void)          const { return(enableTrailingStopAtr);       }
   
   void              setMultipleAtr(double multiple)              { multipleAtr = multiple;              }
   double            getMultipleAtr(void)                   const { return(multipleAtr);                 }
   
   void              setAtrValue(double atr)                      { atrValue = atr;                      }
   double            getAtrValue(void)                      const { return(atrValue);                    }
   
   void              setEnableTrailingStopSar(bool enable)        { this.enableTrailingStopSar = enable; }
   bool              isEnableTrailingStopSar(void)          const { return(enableTrailingStopSar);       }
   
   void              setSarValue(double sar)                      { sarValue = sar;                      }
   double            getSarValue(void)                      const { return(sarValue);                    }

   void              setEnableTrailingStopMa(bool enable)         { this.enableTrailingStopMa = enable;  }
   bool              isEnableTrailingStopMa(void)           const { return(enableTrailingStopMa);        }
   
   void              setMaValue(double ma)                        { maValue = ma;                        }
   double            getMaValue(void)                       const { return(maValue);                     }
/*
   void              setAdr(double value)                         { adr = value;                         }
   double            getAdr(void)                           const { return(adr);                         }

   void              setCdr(double value)                         { cdr = value;                         }
   double            getCdr(void)                           const { return(cdr);                         }
*/
   void              setSignal(int index_, int signal)            { signals[index_] = signal;            }
   int               getSignal(int index_)                  const { return(signals[index_]);             }

   int               getOrderCount(CList *list)             const { return list.Total();                 }
   int               getOrderCountL(void)                   const { return getOrderCount(OrderListL);    }
   int               getOrderCountS(void)                   const { return getOrderCount(OrderListS);    }
   double            getLot(CList *list) const;
   double            getLotL(void)                          const { return getLot(OrderListL);           }
   double            getLotS(void)                          const { return getLot(OrderListS);           }
   double            getProfit(CList *list) const;
   double            getProfitL(void)                       const { return getProfit(OrderListL);        }
   double            getProfitS(void)                       const { return getProfit(OrderListS);        }
   double            getAdr(void) const;
   double            getCdr(void) const;
   void              clearOrderListL(void)                        { this.OrderListL.Clear();             }
   void              clearOrderListS(void)                        { this.OrderListS.Clear();             }
   int               add2OrderListL(OrderInfo *oi)                { return OrderListL.Add(oi);           }
   int               add2OrderListS(OrderInfo *oi)                { return OrderListS.Add(oi);           }
};

SymbolInfo::SymbolInfo(string SymbolShortName, string SymbolPrefix="", string SymbolSuffix="", int Index=0) {
   this.name = SymbolShortName;
   this.prefix = SymbolPrefix;
   this.suffix = SymbolSuffix;
   this.point = MarketInfo(prefix+name+suffix,MODE_POINT);
   this.digits = (int)MarketInfo(prefix+name+suffix,MODE_DIGITS);
   this.maxDD = 0.0;
   this.maxProfit = 0.0;
   this.index = Index;
   ArrayInitialize(signals, 0);
}

double SymbolInfo::getLot(CList *list) const {
   int cnt = list.Total();
   double lot = 0.0;
   OrderInfo *order;
   for (int i=0; i<cnt; i++) {
      order = list.GetNodeAtIndex(i);
      lot += order.getLotSize();
   }
   return lot;
}

double SymbolInfo::getProfit(CList *list) const {
   int cnt = list.Total();
   double totalProfit = 0.0;
   OrderInfo *order;
   for (int i=0; i<cnt; i++) {
      order = list.GetNodeAtIndex(i);
      totalProfit += order.getProfit();
   }
   return totalProfit;
}

double SymbolInfo::getAdr(void) const {
   string pairName = prefix+name+suffix;
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
   
   double adrVal=MathRound((adr1+adr5+adr10+adr20)/4.0);
   return adrVal;
}

double SymbolInfo::getCdr(void) const {
   string pairName = prefix+name+suffix;
   return (iHigh(pairName, PERIOD_D1, 0) - iLow(pairName, PERIOD_D1, 0))/point;
}

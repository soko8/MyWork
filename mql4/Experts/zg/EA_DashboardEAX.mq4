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

enum Trailing_Stop_Method
{
    TSM_NONE,
    TSM_Fix,
    TSM_ATR,
    TSM_Sar,
    TSM_MA
};

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

input bool                 In_Use_Stoploss         = true;
input int                  In_Stoploss_Point          = 200;

input bool                 In_Use_TakeProfit       = true;
input int                  In_TakeProfit_Point        = 1000;

input Trailing_Stop_Method In_Trailing_Stop_Method    = TSM_Fix;

input int                  In_TrailingStop_Fix_Point  = 200;

input int                  In_TrailingStop_ATR_Period = 34;
input int                  In_TrailingStop_ATR_Multiple= 4;

input double               In_TrailingStop_Sar_Step   = 0.02;
input double               In_TrailingStop_Sar_Maximum= 0.2;

input int                  In_TrailingStop_MA_Period  = 55;
input ENUM_MA_METHOD       In_TrailingStop_MA_Method  = MODE_EMA;
input ENUM_APPLIED_PRICE   In_TrailingStop_MA_Applied_Price = PRICE_WEIGHTED;

input int                  In_TrailingStop_OffsetPoint= 100;

input int                  In_Max_Count_OnePair       = 1;

input int                  In_Step_Add_Point          = 10;

input bool                 In_Spread_Filter           = true;
input int                  In_Limit_Spread            = 25;

input double               In_Lots                    = 0.01;

input bool                 In_Use_Any_Entry           = false;
input bool                 In_Use_Any_Exit            = false;

input bool                 In_Use_Pin1                = false;
input bool                 In_Use_Pin2                = false;
input bool                 In_Use_Pin3                = false;
input bool                 In_Use_Pin4                = false;
input bool                 In_Use_Pin5                = false;
input bool                 In_Use_Pin6                = false;
input bool                 In_Use_Pin7                = false;
input bool                 In_Use_Pin8                = false;
input bool                 In_Use_Pin9                = false;

input string               In_Template_Name           = "MyTemplate";

input string               Prefix                     = "";
input string               Surfix                     = "";
input bool                 UseDefaultPairs            = true;
input string               In_Pairs                   = "";
input int                  Magic_Number               = 88888;
input int                  Coordinates_X              = 1;
input int                  Coordinates_Y              = 40;
input bool                 In_4Kdisplay               = true;

const int      SLIPPAGE          = 0;
const string   COMMENT           = "DBEAX";
const string   ObjNamePrefix     = "DBEAX_";
const string   panelNamePrefix   = "Rec_";
const string   H1NamePrefix      = "H1";

const string   ColH2Name[57]        ={ "Auto"  ,"CloseL","CloseS","CloseP","CloseM","CloseAll" ,"LotTxt"   ,"AddLot","Lot"      ,"MnsLot","StepPointTxt","AddStep","Step","MnsStep","CountS" ,"CloseS","LotS"    ,"ProfitS"  ,"Spread"   ,"Profit","Pin1"  ,"Pin2"  ,"Pin3"  ,"Pin4"  ,"Pin5"  ,"Pin6"  ,"Pin7"  ,"Pin8"  ,"Pin9"     ,"PairNm","UseSl","AddSlP","SlP"  ,"MnsSlP","UseTp","AddTpP","TpP" ,"MnsTpP"   ,"TSfix" ,"AddFixP","FixP" ,"MnsFixP"  ,"TSatr" ,"TSsar" ,"SarVal"   ,"TSma","MaVal"   ,"AddOffset","Offset","MnsOffset"   ,"Sl2Open"  ,"AddSl2Now","Sl2Now"   ,"MnsSl2Now"   ,"Tp2Open"  ,"AddTp2Now","Tp2Now"      };
const string   ColH2Text[57]        ={ "Manual","CL"    ,"CS"    ,"C+"    ,"C-"    ,"CA"       ,"Lot :"    ,"+"     ,"999.99"   ,"-"     ,"Step Point :","+"      ,"12345","-"     ,"Count S",""      ,"Lot S"   ,"Profit S" ,"Spd"      ,"Profit","P1"    ,"P2"    ,"P3"    ,"P4"    ,"P5"    ,"P6"    ,"P7"    ,"P8"    ,"P9"       ,"Symbol","SL"   ,"+"     ,"SL P" ,"-"     ,"TP"   ,"+"     ,"TP P","-"        ,"Fix"   ,"+"      ,"Fix P","-"        ,"ATR"   ,"Sar"   ,"Sar SL"   ,"MA"  ,"MA SL"   ,"+"        ,"Ofset" ,"-"           ,"Open"     ,""         ,"SL To Now",""            ,"Open"     ,""         ,"TP To Now"   };
      string   ColH2Type[57]        ={ "btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"      ,"lbl"      ,"btn"   ,"lbl"      ,"btn"   ,"lbl"         ,"btn"    ,"lbl" ,"btn"    ,"unu"    ,"unu"   ,"unu"     ,"unu"      ,"unu"      ,"unu"   ,"unu"   ,"unu"   ,"unu"   ,"unu"   ,"unu"   ,"unu"   ,"unu"   ,"unu"   ,"unu"      ,"unu"  ,"unu"   ,"unu"   ,"unu"  ,"unu"   ,"unu"  ,"unu"   ,"unu" ,"unu"      ,"unu"   ,"unu"    ,"unu"  ,"unu"      ,"unu"   ,"unu"   ,"unu"      ,"unu" ,"unu"     ,"unu"      ,"unu"   ,"unu"         ,"unu"      ,"unu"      ,"unu"      ,"unu"         ,"unu"      ,"unu"      ,"unu"         };
const int      ColH2Width[57]       ={  58     , 30     , 30     , 30     , 30     , 30        , 50        , 18     , 54        , 18     , 86           , 18      , 50   , 18      , 0       , 46     , 58       , 30        , 58        , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 64        , 24    , 18     , 40     , 18    , 24     , 18    , 40     , 18   , 24        , 18     , 40      , 18    , 40        , 30     , 50     , 26        , 50   , 18       , 40        , 18     , 50           , 0         , 86        , 0         , 50           , 0         , 86        , 0            };
const int      ColH2AdjustX[57]     ={  0      , 0      , 0      , 0      , 0      , 0         , 18        , 0      , 5         , 0      , 10           , 0       , 5    , 0       , 0       , 4      , 6        , 2         , 12        , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 8         , 0     , 0      , 5      , 0     , 0      , 0     , 5      , 0    , 0         , 0      , 4       , 0     , 0         , 0      , 2      , 0         , 4    , 0        , 2         , 0      , 7            , 0         , 10        , 0         , 7            , 0         , 8         , 0            };
const int      ColH2Width4K[57]     ={  88     , 44     , 44     , 44     , 44     , 44        , 70        , 24     , 88        , 24     , 146          , 24      , 60   , 24      , 0       , 46     , 58       , 30        , 58        , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 64        , 24    , 18     , 40     , 18    , 24     , 18    , 40     , 18   , 24        , 18     , 40      , 18    , 40        , 30     , 50     , 26        , 50   , 18       , 40        , 18     , 50           , 0         , 86        , 0         , 50           , 0         , 86        , 0            };
const int      ColH2AdjustX4K[57]   ={  0      , 0      , 0      , 0      , 0      , 0         , 20        , 0      , 10        , 0      , 26           , 0       , 5    , 0       , 0       , 4      , 6        , 2         , 12        , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 8         , 0     , 0      , 5      , 0     , 0      , 0     , 5      , 0    , 0         , 0      , 4       , 0     , 0         , 0      , 2      , 0         , 4    , 0        , 2         , 0      , 7            , 0         , 10        , 0         , 7            , 0         , 8         , 0            };


const string   ColH1Text[57]        ={ ""      ,"H"     ,"D"     ,"N"     ,""      ,"Count L"  ,""         ,"Lot L" ,"Profit L" ,"CDR"   ,"Symbol","ADR"   ,""      ,"Count S"  ,""         ,"Lot S" ,"Profit S" ,"Spd"      ,"Profit"   ,"P1"    ,"P2"    ,"P3"    ,"P4"    ,"P5"    ,"P6"    ,"P7"    ,"P8"    ,"P9"    ,"Symbol"   ,"SL"   ,"+"     ,"SL P","-"       ,"TP"   ,"+"     ,"TP P","-"       ,"Fix"   ,"+"      ,"Fix P","-"        ,"ATR"   ,"Sar"   ,"Sar SL"   ,"MA"  ,"MA SL"  ,"+"        ,"Ofset" ,"-"           ,"Open"     ,""         ,"SL To Now",""         ,"Open"     ,""         ,"TP To Now",""       };
      string   ColH1Type[57]        ={ "lbl"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"      ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"      ,"btn"      ,"lbl"      ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"lbl"      ,"btn"  ,"btn"   ,"lbl","btn"      ,"btn"  ,"btn"   ,"lbl","btn"      ,"btn"   ,"btn"    ,"lbl" ,"btn"       ,"btn"   ,"btn"   ,"lbl"      ,"btn" ,"lbl"    ,"btn"      ,"lbl"   ,"btn"         ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"         ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"       };
const int      ColH1Width[57]       ={  18     , 18     , 18     , 18     , 0      , 56        , 0         , 46     , 58        , 40     , 64     , 40     , 0      , 56        , 0         , 46     , 58        , 30        , 58        , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 64        , 24    , 18     , 40  , 18        , 24    , 18     , 40  , 18        , 24     , 18      , 40   , 18         , 40     , 30     , 50        , 26   , 50      , 18        , 40     , 18           , 50        , 0         , 86     , 0            , 50        , 0         , 86     , 0          };
const int      ColH1AdjustX[57]     ={  0      , 0      , 0      , 0      , 0      , 4         , 0         , 6      , 6         , 6      , 8      , 6      , 0      , 2         , 0         , 4      , 6         , 2         , 12        , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 8         , 0     , 0      , 5   , 0         , 0     , 0      , 5   , 0         , 0      , 0       , 4    , 0          , 0      , 0      , 2         , 0    , 4       , 0         , 2      , 0            , 7         , 0         , 10     , 0            , 7         , 0         , 8      , 0          };

const int      ColH1Width4K[57]     ={  24     , 24     , 24     , 24     , 0      , 88        , 0         , 74     , 106       , 66     , 108    , 66     , 0      , 98        , 0         , 74     , 106       , 50        , 106       , 34     , 34     , 34     , 34     , 34     , 34     , 34     , 34     , 34     , 108       , 34    , 24     , 60  , 24        , 34    , 24     , 60  , 24        , 34     , 24      , 60   , 24         , 70     , 44     , 80        , 40   , 80      , 24        , 70     , 24           , 70        , 0         , 118    , 0            , 70        , 0         , 118    , 0          };
const int      ColH1AdjustX4K[57]   ={  0      , 0      , 0      , 0      , 0      , 4         , 0         , 6      , 6         , 6      , 8      , 6      , 0      , 6         , 0         , 4      , 6         , 2         , 20        , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 0      , 14        , 0     , 0      , 5   , 0         , 0     , 0      , 5   , 0         , 0      , 0       , 4    , 0          , 0      , 0      , 6         , 0    , 6       , 0         , 6      , 0            , 7         , 0         , 2      , 0            , 7         , 0         , 2      , 0          };

                                    //   1       2        3        4        5        6           7           8        9           10       11       12       13       14          15         　16        17         18          19          20       21       22       23       24       25       26       27       28       29          30      31       32    33          34      35       36    37          38       39        40     41           42       43       44          45     46        47          48       49             50          51          52      53              54          55          56       57
const string   ColName[57]          ={ "Move"  ,"H"     ,"D"     ,"N"     ,"NewL"  ,"CountL"   ,"CloseL"   ,"LotL"  ,"ProfitL"  ,"CDR"   ,"Pair"  ,"ADR"   ,"NewS"  ,"CountS"   ,"CloseS"   ,"LotS"  ,"ProfitS"  ,"Spread"   ,"Profit"   ,"Pin1"  ,"Pin2"  ,"Pin3"  ,"Pin4"  ,"Pin5"  ,"Pin6"  ,"Pin7"  ,"Pin8"  ,"Pin9"  ,"PairNm"   ,"UseSl","AddSlP","SlP","MnsSlP"   ,"UseTp","AddTpP","TpP","MnsTpP"   ,"TSfix" ,"AddFixP","FixP","MnsFixP"   ,"TSatr" ,"TSsar" ,"SarVal"   ,"TSma","MaVal"  ,"AddOffset","Offset","MnsOffset"   ,"Sl2Open"  ,"AddSl2Now","Sl2Now","MnsSl2Now"   ,"Tp2Open"  ,"AddTp2Now","Tp2Now","MnsTp2Now" };
const string   ColText[57]          ={ "~"     ,"H"     ,"D"     ,"N"     ,"+"     ,"99"       ,"-"        ,"99.99" ,"9999.99"  ,"CDR"   ,"EURUSD","ADR"   ,"+"     ,"10"       ,"-"        ,"12.12" ,"1234.12"  ,"123"      ,"1234.12"  ,""      ,""      ,""      ,""      ,""      ,""      ,""      ,""      ,""      ,""         ,"Sl"   ,"+"     ,"123","-"        ,"Tp"   ,"+"     ,"123","-"        ,"Fix"   ,"+"      ,"123" ,"-"         ,"ATR"   ,"Sar"   ,"12.12345" ,"MA"  ,"12.1234","+"        ,"123"   ,"-"           ,"12345"    ,"+"        ,"12345" ,"-"           ,"12345"    ,"+"        ,"12345" ,"-"         };
      string   ColType[57]          ={ "btn"   ,"btn"   ,"btn"   ,"btn"   ,"btn"   ,"lbl"      ,"btn"      ,"lbl"   ,"lbl"      ,"lbl"   ,"btn"   ,"lbl"   ,"btn"   ,"lbl"      ,"btn"      ,"lbl"   ,"lbl"      ,"lbl"      ,"lbl"      ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"lbl"   ,"btn"      ,"btn"  ,"btn"   ,"btn","btn"      ,"btn"  ,"btn"   ,"btn","btn"      ,"btn"   ,"btn"    ,"btn" ,"btn"       ,"btn"   ,"btn"   ,"lbl"      ,"btn" ,"lbl"    ,"btn"      ,"lbl"   ,"btn"         ,"lbl"      ,"btn"      ,"lbl"   ,"btn"         ,"lbl"      ,"btn"      ,"lbl"   ,"btn"       };
const int      ColWidth[57]         ={  18     , 18     , 18     , 18     , 18     , 20        , 18        , 46     , 58        , 40     , 64     , 40     , 18     , 20        , 18        , 46     , 58        , 30        , 58        , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 22     , 64        , 24    , 18     , 40  , 18        , 24    , 18     , 40  , 18        , 24     , 18      , 40   , 18         , 40     , 30     , 50        , 26   , 50      , 18        , 40     , 18           , 50        , 18        , 50     , 18           , 50        , 18        , 50     , 18         };
const int      ColAdjustX[57]       ={  0      , 0      , 0      , 0      , 0      , 2         , 0         , 2      , 2         , 2      , 0      , 2      , 0      , 2         , 0         , 2      , 2         , 2         , 2         , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 0         , 0     , 0      , 0   , 0         , 0     , 0      , 0   , 0         , 0      , 0       , 0    , 0          , 0      , 0      , 8         , 0    , 8       , 0         , 6      , 0            , 9         , 0         , 9      , 0            , 9         , 0         , 9      , 0          };

const int      ColWidth4K[57]       ={  24     , 24     , 24     , 24     , 24     , 40        , 24        , 74     , 106       , 66     , 108    , 66     , 24     , 50        , 24        , 74     , 106       , 50        , 106       , 34     , 34     , 34     , 34     , 34     , 34     , 34     , 34     , 34     , 108       , 34    , 24     , 60  , 24        , 34    , 24     , 60  , 24        , 34     , 24      , 60   , 24         , 70     , 44     , 80        , 40   , 80      , 24        , 70     , 24           , 70        , 24        , 70     , 24           , 70        , 24        , 70     , 24         };
const int      ColAdjustX4K[57]     ={  0      , 0      , 0      , 2      , 0      , 2         , 0         , 2      , 2         , 2      , 2      , 6      , 0      , 2         , 0         , 6      , 4         , 2         , 6         , 2      , 4      , 4      , 4      , 2      , 2      , 2      , 2      , 2      , 2         , 2     , 0      , 2   , 0         , 0     , 2      , 0   , 2         , 0      , 0       , 2    , 0          , 0      , 0      , 8         , 0    , 8       , 0         , 8      , 0            , 9         , 2         , 9      , 2            , 9         , 2         , 9      , 2          };

const string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
//const string DefaultPairs[] = {"GBPUSD","EURUSD","USDJPY"};


const int      Border_Width   = 1;
const int      RowHeight2K    = 25;
const int      RowHeight4K    = 35;
const int      RowInterval    = 0;
const int      ColumnInterval = 0;
const color    ColBgClrLblH1  = clrMidnightBlue;
const color    ColBdClrLblH1  = clrWhite;
const color    ColBgClrLbl    = clrBlack;
const color    ColBdClrLbl    = clrWhite;
const color    ColBgClrBtn    = clrBlack;
const color    ColFtClrLbl    = clrWhite;
const color    ColFtClrBtn    = clrWhite;
const color    ColBdClrPin    = clrWhite;

const color ClrBtnBgSelected     = clrGreenYellow;
const color ClrBtnFtSelected     = clrBlack;
const color ClrBtnBgUnselected   = clrGray;
const color ClrBtnFtUnselected   = clrWhiteSmoke;

const color ClrBgSpreadEnable    = clrGreen;
const color ClrFtSpreadEnable    = clrWhite;
const color ClrBgSpreadDisable   = clrDarkGray;
const color ClrFtSpreadDisable   = clrBlack;

const color ClrTxtL              = clrLime;
const color ClrTxtS              = clrRed;

const color Color_Signal_BG_L = clrLime;
const color Color_Signal_BG_S = clrPink;
const color Color_Signal_BG_N = clrBlack;

const color Color_Profit_FT_POSITIVE = clrLime;
const color Color_Profit_FT_NEGATIVE = clrRed;
const color Color_Profit_FT_ZERO     = clrWhite;

const int      Count_Pin      = 9;
const int      Signal_NONE    = 0;

CList *SymbolList;
string SymbolArray[], gvTemplateName;
int gvCountSymbol, gvMaxCntOnePair, gvStepAddPoint, gvLimitSpread;
bool  gvIsAuto = false, gvUsePin[9], gvUseSl, gvUseTp, gvUseAnyEntry, gvUseAnyExit, gvSpreadFilter;
double gvLots, gvTrailingStopSarStep, gvTrailingStopSarMaximum;
Trailing_Stop_Method gvTrailingStopMethod;
int gvTrailingStopFixPoint,gvTrailingStopPeriod=0,gvTrailingStopATRMultiple,gvTrailingStopOffsetPoint;
ENUM_MA_METHOD gvTrailingStopMAMethod;
ENUM_APPLIED_PRICE gvTrailingStopMAAppliedPrice;



int OnInit() {
   gvMaxCntOnePair = In_Max_Count_OnePair;
   gvUseAnyEntry = In_Use_Any_Entry;
   gvUseAnyExit = In_Use_Any_Exit;
   gvUsePin[0] = In_Use_Pin1;
   gvUsePin[1] = In_Use_Pin2;
   gvUsePin[2] = In_Use_Pin3;
   gvUsePin[3] = In_Use_Pin4;
   gvUsePin[4] = In_Use_Pin5;
   gvUsePin[5] = In_Use_Pin6;
   gvUsePin[6] = In_Use_Pin7;
   gvUsePin[7] = In_Use_Pin8;
   gvUsePin[8] = In_Use_Pin9;
   gvLots = In_Lots;
   gvUseSl = In_Use_Stoploss;
   gvUseTp = In_Use_TakeProfit;
   gvStepAddPoint = In_Step_Add_Point;
   gvSpreadFilter = In_Spread_Filter;
   gvLimitSpread = In_Limit_Spread;
   gvTemplateName = In_Template_Name;
   gvTrailingStopMethod = In_Trailing_Stop_Method;
   gvTrailingStopFixPoint = In_TrailingStop_Fix_Point;
   gvTrailingStopATRMultiple = In_TrailingStop_ATR_Multiple;
   gvTrailingStopSarStep = In_TrailingStop_Sar_Step;
   gvTrailingStopSarMaximum = In_TrailingStop_Sar_Maximum;
   gvTrailingStopMAMethod = In_TrailingStop_MA_Method;
   gvTrailingStopMAAppliedPrice = In_TrailingStop_MA_Applied_Price;
   gvTrailingStopOffsetPoint = In_TrailingStop_OffsetPoint;
   if (In_Trailing_Stop_Method == TSM_ATR) gvTrailingStopPeriod=In_TrailingStop_ATR_Period;
   else if (In_Trailing_Stop_Method == TSM_MA) gvTrailingStopPeriod=In_TrailingStop_MA_Period;
   
   
   initSymbols();
   Draw(Coordinates_X, Coordinates_Y, SymbolList);
   EventSetTimer(1);
   

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   delete SymbolList;
   EventKillTimer();
   ObjectsDeleteAll(0, ObjNamePrefix);
}

void OnTick() {}

void OnTimer() {
   readOrders();
   readGlobalVariables();
   trailingStop();
   update();
}

void trailingStop() {
   for (int i=0; i<gvCountSymbol; i++) {
      SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
      if (0 == (si.getOrderCountL() + si.getOrderCountS())) continue;
      if (!si.isEnableTrailingStopFix() && !si.isEnableTrailingStopAtr() && !si.isEnableTrailingStopSar() && !si.isEnableTrailingStopMa()) continue;
      Trailing_Stop_Method tsm = TSM_NONE;
      if (si.isEnableTrailingStopFix()) tsm = TSM_Fix;
      else if (si.isEnableTrailingStopAtr()) tsm = TSM_ATR;
      else if (si.isEnableTrailingStopSar()) tsm = TSM_Sar;
      else if (si.isEnableTrailingStopMa()) tsm = TSM_MA;
      if (0 < si.getOrderCountL()) {
         double slL = getSl4Buy(si.getRealName(), tsm);
         CList *orders = si.getOrderListL();
         for (int j=(orders.Total()-1); 0<=j; j--) {
            OrderInfo *oi = orders.GetNodeAtIndex(j);
            if (oi.getSlPrice() < slL) oi.modifySL(slL);
         }
      }
      if (0 < si.getOrderCountS()) {
         double slS = getSl4Sell(si.getRealName(), tsm);
         CList *orders = si.getOrderListS();
         for (int j=(orders.Total()-1); 0<=j; j--) {
            OrderInfo *oi = orders.GetNodeAtIndex(j);
            if (slS < oi.getSlPrice()) oi.modifySL(slS);
         }
      }
   }
}

double getSlByIndicator(string symbolName, Trailing_Stop_Method tsm) {
   double sl = 0.0;
   
   switch (tsm) {
      case TSM_MA:
         sl = iMA(symbolName, Timeframe, gvTrailingStopPeriod, 0, gvTrailingStopMAMethod, gvTrailingStopMAAppliedPrice, 1);
         break;
      case TSM_Sar:
         sl = iSAR(symbolName, Timeframe, gvTrailingStopSarStep, gvTrailingStopSarMaximum, 1);
         break;
      case TSM_ATR:
         sl = iATR(symbolName, Timeframe, gvTrailingStopPeriod, 1);
         break;
      default: break;
   }

   return sl;
}

double getSl4Buy(string symbolName, Trailing_Stop_Method tsm) {
   double sl = 0.0;
   double vpoint = MarketInfo(symbolName, MODE_POINT);
   switch (tsm) {
      case TSM_Fix:
         sl = MarketInfo(symbolName, MODE_BID) - gvTrailingStopFixPoint*vpoint;
         break;
      case TSM_MA:
      case TSM_Sar:
      case TSM_ATR:
         sl = getSlByIndicator(symbolName, tsm);
         sl += gvTrailingStopOffsetPoint*vpoint;
         break;
      default: break;
   }

   return NormalizeDouble(sl, (int) MarketInfo(symbolName, MODE_DIGITS));
}

double getSl4Sell(string symbolName, Trailing_Stop_Method tsm) {
   double sl = 0.0;
   double vpoint = MarketInfo(symbolName, MODE_POINT);
   switch (tsm) {
      case TSM_Fix:
         sl = MarketInfo(symbolName, MODE_ASK) + gvTrailingStopFixPoint*vpoint;
         break;
      case TSM_MA:
      case TSM_Sar:
      case TSM_ATR:
         sl = getSlByIndicator(symbolName, tsm);
         sl -= gvTrailingStopOffsetPoint*vpoint;
         break;
      default: break;
   }

   return NormalizeDouble(sl, (int) MarketInfo(symbolName, MODE_DIGITS));
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (CHARTEVENT_OBJECT_CLICK != id) return;
   string objNamePrefix_ = ObjNamePrefix+"btn";
   string objNm = objNamePrefix_+ColName[COL_NO_NewL];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int currentOrderCount = si.getOrderCountL() + si.getOrderCountS();
      if (gvMaxCntOnePair <= currentOrderCount) { Print("Max Order Count!");return;}
      createOrder(index, OP_BUY);return;
   }
   
   objNm = objNamePrefix_+ColName[COL_NO_CloseL];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int cnt = si.closeOrdersL();
      Print("Long orders is closed. Count=", cnt);return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_NewS];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int currentOrderCount = si.getOrderCountL() + si.getOrderCountS();
      if (gvMaxCntOnePair <= currentOrderCount) { Print("Max Order Count!");return;}
      createOrder(index, OP_SELL);return;
   }
   
   objNm = objNamePrefix_+ColName[COL_NO_CloseS];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int cnt = si.closeOrdersS();
      Print("Short orders is closed. Count=", cnt);return;
   }
   
   objNm = ObjNamePrefix+"btn"+"Auto";
   if (sparam == objNm) {
      setBtnAuto(!gvIsAuto);
   }

   objNm = ObjNamePrefix+"btn"+"AddLot";
   if (sparam == objNm) {
      gvLots += 0.01;
      ObjectSetString(0, ObjNamePrefix+"lbl"+"Lot", OBJPROP_TEXT, paddingSpaceLeft(gvLots,2,6));
   }

   objNm = ObjNamePrefix+"btn"+"MnsLot";
   if (sparam == objNm) {
      gvLots -= 0.01;
      ObjectSetString(0, ObjNamePrefix+"lbl"+"Lot", OBJPROP_TEXT, paddingSpaceLeft(gvLots,2,6));
   }

   objNm = ObjNamePrefix+"btn"+"AddStep";
   if (sparam == objNm) {
      gvStepAddPoint++;
      ObjectSetString(0, ObjNamePrefix+"lbl"+"Step", OBJPROP_TEXT, IntegerToString(gvStepAddPoint,5));
   }

   objNm = ObjNamePrefix+"btn"+"MnsStep";
   if (sparam == objNm) {
      gvStepAddPoint--;
      ObjectSetString(0, ObjNamePrefix+"lbl"+"Step", OBJPROP_TEXT, IntegerToString(gvStepAddPoint,5));
   }

   objNm = ObjNamePrefix+"btn"+"CloseL";
   if (sparam == objNm) {
   
   }

   objNm = ObjNamePrefix+"btn"+"CloseS";
   if (sparam == objNm) {
   
   }

   objNm = ObjNamePrefix+"btn"+"CloseP";
   if (sparam == objNm) {
   
   }

   objNm = ObjNamePrefix+"btn"+"CloseM";
   if (sparam == objNm) {
   
   }

   objNm = ObjNamePrefix+"btn"+"CloseAll";
   if (sparam == objNm) {
   
   }

   objNm = objNamePrefix_+ColName[COL_NO_Move];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      long curChartId = ChartID();
      long prevChart = ChartFirst();
      bool found = false;
      while(!found) {
         if(prevChart < 0) break;
         if (si.getRealName() == ChartSymbol(prevChart)) {
            if (curChartId != prevChart) {
               found = true;
               break;
            }
         }
         prevChart = ChartNext(prevChart);
      }
      
      if (found) {
         ChartSetInteger(prevChart,CHART_BRING_TO_TOP,0,true);
      } else {
         long chartIdPair = ChartOpen(si.getRealName(), PERIOD_H1);
         ChartApplyTemplate(chartIdPair, gvTemplateName);
      }
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_UseSl];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      si.setEnableSl(!(si.isEnableSl()));
      string h1BtnName = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_UseSl];
      if (si.isEnableSl()) {
         setBtnSelected(sparam);
         bool allEnable = true;
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *sii = SymbolList.GetNodeAtIndex(i);
            allEnable = allEnable && sii.isEnableSl();
         }
         if (allEnable) setBtnSelected(h1BtnName); else setBtnUnselected(h1BtnName);
         
      } else {
         setBtnUnselected(sparam);
         setBtnUnselected(h1BtnName);
      }
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_AddSlP];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int slp = si.getSlPoint() + gvStepAddPoint;
      si.setSlPoint(slp);
      ObjectSetString(0, getObjectName(index, COL_NO_SlP), OBJPROP_TEXT, IntegerToString(slp, 4));return;
   }
   
   objNm = objNamePrefix_+ColName[COL_NO_MnsSlP];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int slp = si.getSlPoint() - gvStepAddPoint;
      si.setSlPoint(slp);
      ObjectSetString(0, getObjectName(index, COL_NO_SlP), OBJPROP_TEXT, IntegerToString(slp, 4));return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_UseTp];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      si.setEnableTp(!si.isEnableTp());
      string h1BtnName = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_UseTp];
      if (si.isEnableTp()) {
         setBtnSelected(sparam);
         bool allEnable = true;
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *sii = SymbolList.GetNodeAtIndex(i);
            allEnable = allEnable && sii.isEnableTp();
         }
         if (allEnable) setBtnSelected(h1BtnName); else setBtnUnselected(h1BtnName);
         
      } else {
         setBtnUnselected(sparam);
         setBtnUnselected(h1BtnName);
      }
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_AddTpP];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int tpp = si.getTpPoint() + gvStepAddPoint;
      si.setTpPoint(tpp);
      ObjectSetString(0, getObjectName(index, COL_NO_TpP), OBJPROP_TEXT, IntegerToString(tpp, 4));return;
   }
   
   objNm = objNamePrefix_+ColName[COL_NO_MnsTpP];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int tpp = si.getTpPoint() - gvStepAddPoint;
      si.setTpPoint(tpp);
      ObjectSetString(0, getObjectName(index, COL_NO_TpP), OBJPROP_TEXT, IntegerToString(tpp, 4));return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_TSfix];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      si.setEnableTrailingStopFix(!si.isEnableTrailingStopFix());
      string h1BtnName = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix];
      if (si.isEnableTrailingStopFix()) {
         setBtnSelected(sparam);
         //si.setEnableTrailingStop(true);
         bool allEnable = true;
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *sii = SymbolList.GetNodeAtIndex(i);
            allEnable = allEnable && sii.isEnableTrailingStopFix();
         }
         if (allEnable) {setBtnSelected(h1BtnName); gvTrailingStopMethod=TSM_Fix;} else {setBtnUnselected(h1BtnName); gvTrailingStopMethod=TSM_NONE;}
         
         si.setEnableTrailingStopAtr(false);setBtnUnselected(getObjectName(index,COL_NO_TSatr));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         si.setEnableTrailingStopSar(false);setBtnUnselected(getObjectName(index,COL_NO_TSsar));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         si.setEnableTrailingStopMa(false);setBtnUnselected(getObjectName(index,COL_NO_TSma));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         
      } else {
         setBtnUnselected(sparam);
         setBtnUnselected(h1BtnName);
         gvTrailingStopMethod=TSM_NONE;
      }
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_AddFixP];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int fixp = si.getTrailingStopFixPoint() + gvStepAddPoint;
      si.setTrailingStopFixPoint(fixp);
      ObjectSetString(0, getObjectName(index, COL_NO_FixP), OBJPROP_TEXT, IntegerToString(fixp, 4));return;
   }
   
   objNm = objNamePrefix_+ColName[COL_NO_MnsFixP];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int fixp = si.getTrailingStopFixPoint() - gvStepAddPoint;
      si.setTrailingStopFixPoint(fixp);
      ObjectSetString(0, getObjectName(index, COL_NO_FixP), OBJPROP_TEXT, IntegerToString(fixp, 4));return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_TSatr];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      si.setEnableTrailingStopAtr(!si.isEnableTrailingStopAtr());
      string h1BtnName = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr];
      if (si.isEnableTrailingStopAtr()) {
         setBtnSelected(sparam);
         //si.setEnableTrailingStop(true);
         bool allEnable = true;
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *sii = SymbolList.GetNodeAtIndex(i);
            allEnable = allEnable && sii.isEnableTrailingStopAtr();
         }
         if (allEnable) {setBtnSelected(h1BtnName); gvTrailingStopMethod=TSM_ATR;} else {setBtnUnselected(h1BtnName); gvTrailingStopMethod=TSM_NONE;}
         
         si.setEnableTrailingStopFix(false);setBtnUnselected(getObjectName(index,COL_NO_TSfix));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         si.setEnableTrailingStopSar(false);setBtnUnselected(getObjectName(index,COL_NO_TSsar));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         si.setEnableTrailingStopMa(false);setBtnUnselected(getObjectName(index,COL_NO_TSma));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         
      } else {
         setBtnUnselected(sparam);
         setBtnUnselected(h1BtnName);
         gvTrailingStopMethod=TSM_NONE;
      }
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_TSsar];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      si.setEnableTrailingStopSar(!si.isEnableTrailingStopSar());
      string h1BtnName = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar];
      if (si.isEnableTrailingStopSar()) {
         setBtnSelected(sparam);
         //si.setEnableTrailingStop(true);
         bool allEnable = true;
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *sii = SymbolList.GetNodeAtIndex(i);
            allEnable = allEnable && sii.isEnableTrailingStopSar();
         }
         if (allEnable) {setBtnSelected(h1BtnName); gvTrailingStopMethod=TSM_Sar;} else {setBtnUnselected(h1BtnName); gvTrailingStopMethod=TSM_NONE;}
         
         si.setEnableTrailingStopFix(false);setBtnUnselected(getObjectName(index,COL_NO_TSfix));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         si.setEnableTrailingStopAtr(false);setBtnUnselected(getObjectName(index,COL_NO_TSatr));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         si.setEnableTrailingStopMa(false);setBtnUnselected(getObjectName(index,COL_NO_TSma));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         
      } else {
         setBtnUnselected(sparam);
         setBtnUnselected(h1BtnName);
         gvTrailingStopMethod=TSM_NONE;
      }
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_TSma];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      si.setEnableTrailingStopMa(!si.isEnableTrailingStopMa());
      string h1BtnName = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma];
      if (si.isEnableTrailingStopMa()) {
         setBtnSelected(sparam);
         //si.setEnableTrailingStop(true);
         bool allEnable = true;
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *sii = SymbolList.GetNodeAtIndex(i);
            allEnable = allEnable && sii.isEnableTrailingStopMa();
         }
         if (allEnable) {setBtnSelected(h1BtnName); gvTrailingStopMethod=TSM_MA;} else {setBtnUnselected(h1BtnName); gvTrailingStopMethod=TSM_NONE;}
         
         si.setEnableTrailingStopFix(false);setBtnUnselected(getObjectName(index,COL_NO_TSfix));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         si.setEnableTrailingStopAtr(false);setBtnUnselected(getObjectName(index,COL_NO_TSatr));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         si.setEnableTrailingStopSar(false);setBtnUnselected(getObjectName(index,COL_NO_TSsar));setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         
      } else {
         setBtnUnselected(sparam);
         setBtnUnselected(h1BtnName);
         gvTrailingStopMethod=TSM_NONE;
      }
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_AddOffset];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int offset = si.getTrailingStopOffset() + gvStepAddPoint;
      si.setTrailingStopOffset(offset);
      ObjectSetString(0, getObjectName(index, COL_NO_Offset), OBJPROP_TEXT, IntegerToString(offset, 4));return;
   }
   
   objNm = objNamePrefix_+ColName[COL_NO_MnsOffset];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      int offset = si.getTrailingStopOffset() - gvStepAddPoint;
      si.setTrailingStopOffset(offset);
      ObjectSetString(0, getObjectName(index, COL_NO_Offset), OBJPROP_TEXT, IntegerToString(offset, 4));return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_AddSl2Now];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      if (0 < si.getOrderCountL()) si.modifySLpOrderL(0, gvStepAddPoint);
      else if (0 < si.getOrderCountS()) si.modifySLpOrderS(0, gvStepAddPoint);
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_MnsSl2Now];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      if (0 < si.getOrderCountL()) si.modifySLpOrderL(0, -gvStepAddPoint);
      else if (0 < si.getOrderCountS()) si.modifySLpOrderS(0, -gvStepAddPoint);
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_AddTp2Now];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      if (0 < si.getOrderCountL()) si.modifyTPpOrderL(0, gvStepAddPoint);
      else if (0 < si.getOrderCountS()) si.modifyTPpOrderS(0, gvStepAddPoint);
      return;
   }

   objNm = objNamePrefix_+ColName[COL_NO_MnsTp2Now];
   if ((0 <= StringFind(sparam, objNm))) {
      int index = StrToInteger(StringSubstr(sparam, StringLen(objNm)));
      SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
      if (0 < si.getOrderCountL()) si.modifyTPpOrderL(0, -gvStepAddPoint);
      else if (0 < si.getOrderCountS()) si.modifyTPpOrderS(0, -gvStepAddPoint);
      return;
   }

   /***************************************** H1 header start ********************************************************/
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Spread];
   if (sparam == objNm) {
      if (gvSpreadFilter) {
         gvSpreadFilter = false; setBtnUnselected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            setSpreadEnable(i);
         }
      } else {
         gvSpreadFilter = true;  setBtnSelected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            if (gvLimitSpread < si.spread()) setSpreadDisable(i); else setSpreadEnable(i);
         }
      }
      return;
   }
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin1];
   if (sparam == objNm) {
      if (gvUsePin[0]) {
         gvUsePin[0] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[0] = true;  setBtnSelected(sparam);
      }
      return;
   }
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin2];
   if (sparam == objNm) {
      if (gvUsePin[1]) {
         gvUsePin[1] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[1] = true;  setBtnSelected(sparam);
      }
      return;
   }
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin3];
   if (sparam == objNm) {
      if (gvUsePin[2]) {
         gvUsePin[2] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[2] = true;  setBtnSelected(sparam);
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin4];
   if (sparam == objNm) {
      if (gvUsePin[3]) {
         gvUsePin[3] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[3] = true;  setBtnSelected(sparam);
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin5];
   if (sparam == objNm) {
      if (gvUsePin[4]) {
         gvUsePin[4] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[4] = true;  setBtnSelected(sparam);
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin6];
   if (sparam == objNm) {
      if (gvUsePin[5]) {
         gvUsePin[5] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[5] = true;  setBtnSelected(sparam);
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin7];
   if (sparam == objNm) {
      if (gvUsePin[6]) {
         gvUsePin[6] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[6] = true;  setBtnSelected(sparam);
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin8];
   if (sparam == objNm) {
      if (gvUsePin[7]) {
         gvUsePin[7] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[7] = true;  setBtnSelected(sparam);
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin9];
   if (sparam == objNm) {
      if (gvUsePin[8]) {
         gvUsePin[8] = false; setBtnUnselected(sparam);
      } else {
         gvUsePin[8] = true;  setBtnSelected(sparam);
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_UseSl];
   if (sparam == objNm) {
      if (gvUseSl) {
         gvUseSl = false; setBtnUnselected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableSl(false);
            setBtnUnselected(objNamePrefix_+ColName[COL_NO_UseSl]+IntegerToString(i));
         }
      } else {
         gvUseSl = true;  setBtnSelected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableSl(true);
            setBtnSelected(objNamePrefix_+ColName[COL_NO_UseSl]+IntegerToString(i));
         }
      }
      return;
   }
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_UseTp];
   if (sparam == objNm) {
      if (gvUseTp) {
         gvUseTp = false; setBtnUnselected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTp(false);
            setBtnUnselected(objNamePrefix_+ColName[COL_NO_UseTp]+IntegerToString(i));
         }
      } else {
         gvUseTp = true;  setBtnSelected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTp(true);
            setBtnSelected(objNamePrefix_+ColName[COL_NO_UseTp]+IntegerToString(i));
         }
      }
      return;
   }
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_AddSlP];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int slp = si.getSlPoint() + gvStepAddPoint;
         si.setSlPoint(slp);
         ObjectSetString(0, getObjectName(i,COL_NO_SlP), OBJPROP_TEXT, IntegerToString(slp, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_MnsSlP];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int slp = si.getSlPoint() - gvStepAddPoint;
         si.setSlPoint(slp);
         ObjectSetString(0, getObjectName(i,COL_NO_SlP), OBJPROP_TEXT, IntegerToString(slp, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_AddTpP];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int tpp = si.getTpPoint() + gvStepAddPoint;
         si.setTpPoint(tpp);
         ObjectSetString(0, getObjectName(i,COL_NO_TpP), OBJPROP_TEXT, IntegerToString(tpp, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_MnsTpP];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int tpp = si.getTpPoint() - gvStepAddPoint;
         si.setTpPoint(tpp);
         ObjectSetString(0, getObjectName(i,COL_NO_TpP), OBJPROP_TEXT, IntegerToString(tpp, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_AddFixP];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int fixp = si.getTrailingStopFixPoint() + gvStepAddPoint;
         si.setTrailingStopFixPoint(fixp);
         ObjectSetString(0, getObjectName(i,COL_NO_FixP), OBJPROP_TEXT, IntegerToString(fixp, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_MnsFixP];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int fixp = si.getTrailingStopFixPoint() - gvStepAddPoint;
         si.setTrailingStopFixPoint(fixp);
         ObjectSetString(0, getObjectName(i,COL_NO_FixP), OBJPROP_TEXT, IntegerToString(fixp, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_AddOffset];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int offset = si.getTrailingStopOffset() + gvStepAddPoint;
         si.setTrailingStopOffset(offset);
         ObjectSetString(0, getObjectName(i,COL_NO_Offset), OBJPROP_TEXT, IntegerToString(offset, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_MnsOffset];
   if (sparam == objNm) {
      for (int i=0; i<gvCountSymbol; i++) {
         SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
         int offset = si.getTrailingStopOffset() - gvStepAddPoint;
         si.setTrailingStopOffset(offset);
         ObjectSetString(0, getObjectName(i,COL_NO_Offset), OBJPROP_TEXT, IntegerToString(offset, 4));
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix];
   if (sparam == objNm) {
      if (TSM_Fix == gvTrailingStopMethod) {
         gvTrailingStopMethod = TSM_NONE;
         setBtnUnselected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopFix(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSfix));
         }
      } else {
         gvTrailingStopMethod = TSM_Fix;
         setBtnSelected(sparam);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopFix(true);
            setBtnSelected(getObjectName(i, COL_NO_TSfix));
            si.setEnableTrailingStopAtr(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSatr));
            si.setEnableTrailingStopSar(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSsar));
            si.setEnableTrailingStopMa(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSma));
         }
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr];
   if (sparam == objNm) {
      if (TSM_ATR == gvTrailingStopMethod) {
         gvTrailingStopMethod = TSM_NONE;
         setBtnUnselected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopAtr(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSatr));
         }
      } else {
         gvTrailingStopMethod = TSM_ATR;
         setBtnSelected(sparam);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopFix(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSfix));
            si.setEnableTrailingStopAtr(true);
            setBtnSelected(getObjectName(i, COL_NO_TSatr));
            si.setEnableTrailingStopSar(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSsar));
            si.setEnableTrailingStopMa(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSma));
         }
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar];
   if (sparam == objNm) {
      if (TSM_Sar == gvTrailingStopMethod) {
         gvTrailingStopMethod = TSM_NONE;
         setBtnUnselected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopSar(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSsar));
         }
      } else {
         gvTrailingStopMethod = TSM_Sar;
         setBtnSelected(sparam);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopFix(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSfix));
            si.setEnableTrailingStopAtr(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSatr));
            si.setEnableTrailingStopSar(true);
            setBtnSelected(getObjectName(i, COL_NO_TSsar));
            si.setEnableTrailingStopMa(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSma));
         }
      }
      return;
   }

   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma];
   if (sparam == objNm) {
      if (TSM_MA == gvTrailingStopMethod) {
         gvTrailingStopMethod = TSM_NONE;
         setBtnUnselected(sparam);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopMa(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSma));
         }
      } else {
         gvTrailingStopMethod = TSM_MA;
         setBtnSelected(sparam);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         for (int i=0; i<gvCountSymbol; i++) {
            SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
            si.setEnableTrailingStopFix(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSfix));
            si.setEnableTrailingStopAtr(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSatr));
            si.setEnableTrailingStopSar(false);
            setBtnUnselected(getObjectName(i, COL_NO_TSsar));
            si.setEnableTrailingStopMa(true);
            setBtnSelected(getObjectName(i, COL_NO_TSma));
         }
      }
      return;
   }





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

int createOrder(int i, int trade_operation) {
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   double openPrice = 0.0, slPrice = 0.0, tpPrice = 0.0;
   double askPrice = MarketInfo(si.getRealName(), MODE_ASK);
   double bidPrice = MarketInfo(si.getRealName(), MODE_BID);
   switch (trade_operation) {
      case OP_BUY:
         openPrice = askPrice;
         if (si.isEnableSl() && 0 < si.getSlPoint()) slPrice = bidPrice - si.getStopLoss();
         if (si.isEnableTp() && 0 < si.getTpPoint()) tpPrice = bidPrice + si.getTakeProfit();
         break;
      case OP_SELL:
         openPrice = bidPrice;
         if (si.isEnableSl() && 0 < si.getSlPoint()) slPrice = askPrice + si.getStopLoss();
         if (si.isEnableTp() && 0 < si.getTpPoint()) tpPrice = askPrice - si.getTakeProfit();
         break;
      default: break;
   }
   
   openPrice = NormalizeDouble(openPrice, si.getDigits());
   slPrice = NormalizeDouble(slPrice, si.getDigits());
   tpPrice = NormalizeDouble(tpPrice, si.getDigits());

   int ticket = OrderSend(si.getRealName(), trade_operation, gvLots, openPrice, SLIPPAGE, slPrice, tpPrice, COMMENT, Magic_Number, 0, clrNONE);
   
   if (ticket < 0) Print("OrderSend failed with error #", ErrorDescription(GetLastError()), " Symbol=", si.getRealName());
   else Print("OrderSend placed successfully. Ticket ID=", ticket, " Symbol=", si.getRealName());
   
   return ticket;
}

bool processSignal(int symbolIndex) {
   if (!gvIsAuto) return false;
   if (isUnusePin()) return false;
   bool orderChange = false;
   SymbolInfo *si = SymbolList.GetNodeAtIndex(symbolIndex);
   if (gvLimitSpread < si.spread()) return false;
   // 1. close order
   if (gvUseAnyExit) {
      bool isExit=isEntryAnyL(symbolIndex);
      if (isExit) {
         // close Short order
         if (0 < si.closeOrdersS()) orderChange = true;

      } else {
         isExit=isEntryAnyS(symbolIndex);
         if (isExit) {
            // close Long order
            if (0 < si.closeOrdersL()) orderChange = true;
         }
      }

   } else {
      bool isExit=isEntryL(symbolIndex);
      if (isExit) {
         // close Short order
         if (0 < si.closeOrdersS()) orderChange = true;

      } else {
         isExit=isEntryS(symbolIndex);
         if (isExit) {
            // close Long order
            if (0 < si.closeOrdersL()) orderChange = true;
         }
      }
   
   }

   int currentOrderCount = si.getOrderCountL() + si.getOrderCountS();
   if (gvMaxCntOnePair <= currentOrderCount) return orderChange;
   
   // 2. create order
   if (gvUseAnyEntry) {
      bool isEntry=isEntryAnyL(symbolIndex);
      if (isEntry) {
         // create Long order
         if (0 <= createOrder(symbolIndex, OP_BUY)) orderChange = true;

      } else {
         isEntry=isEntryAnyS(symbolIndex);
         if (isEntry) {
            // create Short order
            if (0 <= createOrder(symbolIndex, OP_SELL)) orderChange = true;

         }
      }
   }
   else {
      bool isEntry=isEntryL(symbolIndex);
      if (isEntry) {
         // create Long order
         if (0 <= createOrder(symbolIndex, OP_BUY)) orderChange = true;

      } else {
         isEntry=isEntryS(symbolIndex);
         if (isEntry) {
            // create Short order
            if (0 <= createOrder(symbolIndex, OP_SELL)) orderChange = true;

         }
      }
   }

   return orderChange;
}

bool isEntryAnyL(int i) {
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   for (int j=0; j<Count_Pin; j++) {
      if (gvUsePin[j]) {
         if (si.getSignal(j) < 0) return false;
      }
   }
   return true;
}

bool isEntryAnyS(int i) {
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   for (int j=0; j<Count_Pin; j++) {
      if (gvUsePin[j]) {
         if (0 < si.getSignal(j)) return false;
      }
   }
   return true;
}

bool isEntryL(int i) {
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   for (int j=0; j<Count_Pin; j++) {
      if (gvUsePin[j]) {
         if (si.getSignal(j) <= 0) return false;
      }
   }
   return true;
}

bool isEntryS(int i) {
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   for (int j=0; j<Count_Pin; j++) {
      if (gvUsePin[j]) {
         if (0 <= si.getSignal(j)) return false;
      }
   }
   return true;
}

bool isUnusePin() {
   for (int j=0; j<Count_Pin; j++) if (gvUsePin[j]) return false;
   return true;
}

/**
 * A global variable name should be symbol name(not include prefix and surfix) + 'pin' + pin Number.
 * At the same time, Must have a access time global variable.
 * ex.   EURUSDpin1=1
 *       EURUSDpin1Time=2023.12.12 10:10:11
 * Use   datetime t = GlobalVariableSet("EURUSDpin1", 1);
 *       GlobalVariableSet("EURUSDpin1Time", t);
 */
void readGlobalVariables() {
   GlobalVariablesFlush();
   bool anyOrderChanged = false;
   for (int i=0; i<gvCountSymbol; i++) {
      SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
      for (int j=0; j<Count_Pin; j++) {
         string symNm = si.getName();
         StringToUpper(symNm);
         string globalVarName = symNm + "pin" + IntegerToString(j+1);
         if (GlobalVariableCheck(globalVarName)) {
            //datetime signalCreateTime = (datetime) GlobalVariableGet(globalVarName+"Time");
            //if (si.getSignalTime(j) != signalCreateTime) {
               int signal = (int)GlobalVariableGet(globalVarName);
               si.setSignal(j, signal);
               //si.setSignalTime(j, signalCreateTime);
               
               //createOrderWhenSignal(i, j, signal);
            //}
         } else {
            si.setSignal(j, Signal_NONE);
            si.setSignalTime(j, 0);
         }
      }
      setPin(i);
      anyOrderChanged = anyOrderChanged || processSignal(i);
   }
   if (anyOrderChanged) readOrders();
}

void readOrders() {
   //int cnt = SymbolList.Total();
   for (int i=0; i<gvCountSymbol; i++) {
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

string paddingSpaceLeft(double target, int decimalDigits, int digits) {
   string result = DoubleToStr(target, decimalDigits);
   int    length = StringLen(result);
   for(int i = length-1; 0<=i; i--) if (48 == StringGetCharacter(result,i)) length--;
   if(length >= digits) return result;
   for(int i = 0; i < digits - length; i++) result = " " + result;
   return result;
}

void update() {
   long chartId = 0;
   for (int i=0; i<gvCountSymbol; i++) {
      SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
      string objName = getObjectName(i, COL_NO_CountL);
      // Long Order Count
      int cntL = si.getOrderCountL();
      double profitTotal = 0.0;
      if (0 < cntL) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT,IntegerToString(cntL, 2));

         double val = si.getLotL();
         objName = getObjectName(i, COL_NO_LotL);
         ObjectSetString(chartId,objName,OBJPROP_TEXT,paddingSpaceLeft(val, 2, 5));
         
         val = si.getProfitL();
         objName = getObjectName(i, COL_NO_ProfitL);
         ObjectSetString(chartId,objName,OBJPROP_TEXT,paddingSpaceLeft(val, 2, 7));
         color clr = Color_Profit_FT_ZERO;
         if (0 < val) clr=Color_Profit_FT_POSITIVE; else if (val < 0) clr=Color_Profit_FT_NEGATIVE;
         ObjectSetInteger(chartId,objName,OBJPROP_COLOR,clr);
         profitTotal += val;
         
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT,"");
         ObjectSetString(chartId,getObjectName(i, COL_NO_LotL),OBJPROP_TEXT,"");
         ObjectSetString(chartId,getObjectName(i, COL_NO_ProfitL),OBJPROP_TEXT,"");
      }
      
      ObjectSetString(chartId,getObjectName(i, COL_NO_CDR),OBJPROP_TEXT,IntegerToString((int)si.getCdr(), 4));
      ObjectSetString(chartId,getObjectName(i, COL_NO_ADR),OBJPROP_TEXT,IntegerToString((int)si.getAdr(), 4));

      int cntS = si.getOrderCountS();
      objName = getObjectName(i, COL_NO_CountS);
      if (0 < cntS) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT,IntegerToString(cntS, 2));

         double val = si.getLotS();
         objName = getObjectName(i, COL_NO_LotS);
         ObjectSetString(chartId,objName,OBJPROP_TEXT,paddingSpaceLeft(val, 2, 5));
         
         val = si.getProfitS();
         objName = getObjectName(i, COL_NO_ProfitS);
         ObjectSetString(chartId,objName,OBJPROP_TEXT,paddingSpaceLeft(val, 2, 7));
         color clr = Color_Profit_FT_ZERO;
         if (0 < val) clr=Color_Profit_FT_POSITIVE; else if (val < 0) clr=Color_Profit_FT_NEGATIVE;
         ObjectSetInteger(chartId,objName,OBJPROP_COLOR,clr);
         profitTotal += val;
         
      } else {
         ObjectSetString(chartId,objName,OBJPROP_TEXT,"");
         ObjectSetString(chartId,getObjectName(i, COL_NO_LotS),OBJPROP_TEXT,"");
         ObjectSetString(chartId,getObjectName(i, COL_NO_ProfitS),OBJPROP_TEXT,"");
      }
      
      int sprd = si.spread();
      ObjectSetString(chartId,getObjectName(i, COL_NO_Spread),OBJPROP_TEXT,IntegerToString(sprd, 3));
      if (gvSpreadFilter) {
         if (gvLimitSpread < sprd) setSpreadDisable(i); else setSpreadEnable(i);
      }
      else setSpreadEnable(i);
      
      objName = getObjectName(i, COL_NO_Profit);
      if (0 < (cntL+cntS)) {
         ObjectSetString(chartId,objName,OBJPROP_TEXT,paddingSpaceLeft(profitTotal, 2, 7));
         color clr = Color_Profit_FT_ZERO;
         if (0 < profitTotal) clr=Color_Profit_FT_POSITIVE; else if (profitTotal < 0) clr=Color_Profit_FT_NEGATIVE;
         ObjectSetInteger(chartId,objName,OBJPROP_COLOR,clr);
      }
      else ObjectSetString(chartId,objName,OBJPROP_TEXT,"");
      
      setAtrVal(i);
      setSarVal(i);
      setMaVal(i);
      
      if (1 == (si.getOrderCountL()+si.getOrderCountS())) {
         OrderInfo *oi = NULL;
         if (1 == si.getOrderCountL()) oi = si.getOrderListL().GetFirstNode(); else oi = si.getOrderListS().GetFirstNode();
         objName = getObjectName(i, COL_NO_Sl2Open);
         int val = oi.getPoint_Sl2OpenPrice();
         ObjectSetString(chartId, objName, OBJPROP_TEXT, IntegerToString(val,4,32));
         color clr = clrGreen;
         if (val < 0) clr = clrRed;
         ObjectSetInteger(chartId,objName,OBJPROP_COLOR,clr);
         objName = getObjectName(i, COL_NO_Sl2Now);
         ObjectSetString(chartId, objName, OBJPROP_TEXT, IntegerToString(oi.getPoint_Sl2CurrentPrice(),4));
         objName = getObjectName(i, COL_NO_Tp2Open);
         ObjectSetString(chartId, objName, OBJPROP_TEXT, IntegerToString(oi.getPoint_Tp2OpenPrice(),4));
         objName = getObjectName(i, COL_NO_Tp2Now);
         ObjectSetString(chartId, objName, OBJPROP_TEXT, IntegerToString(oi.getPoint_Tp2CurrentPrice(),4));
      } else if(0 <= ObjectFind(chartId,getObjectName(i,COL_NO_Sl2Open))) {
         ObjectSetString(chartId, getObjectName(i, COL_NO_Sl2Open), OBJPROP_TEXT, "");
         ObjectSetString(chartId, getObjectName(i, COL_NO_Sl2Now), OBJPROP_TEXT, "");
         ObjectSetString(chartId, getObjectName(i, COL_NO_Tp2Open), OBJPROP_TEXT, "");
         ObjectSetString(chartId, getObjectName(i, COL_NO_Tp2Now), OBJPROP_TEXT, "");
      }
   }
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
      si.setEnableSl(In_Use_Stoploss);
      si.setSlPoint(In_Stoploss_Point);
      si.setEnableTp(In_Use_TakeProfit);
      si.setTpPoint(In_TakeProfit_Point);
      //si.setEnableTrailingStop(In_Enable_TrailingStop);
      switch (In_Trailing_Stop_Method) {
         case TSM_Fix:
            si.setEnableTrailingStopFix(true);
            si.setEnableTrailingStopAtr(false);
            si.setEnableTrailingStopSar(false);
            si.setEnableTrailingStopMa(false);
            break;
         case TSM_ATR:
            si.setEnableTrailingStopFix(false);
            si.setEnableTrailingStopAtr(true);
            si.setEnableTrailingStopSar(false);
            si.setEnableTrailingStopMa(false);
            break;
         case TSM_Sar:
            si.setEnableTrailingStopFix(false);
            si.setEnableTrailingStopAtr(false);
            si.setEnableTrailingStopSar(true);
            si.setEnableTrailingStopMa(false);
            break;
         case TSM_MA:
            si.setEnableTrailingStopFix(false);
            si.setEnableTrailingStopAtr(false);
            si.setEnableTrailingStopSar(false);
            si.setEnableTrailingStopMa(true);
            break;
         default:
            si.setEnableTrailingStopFix(false);
            si.setEnableTrailingStopAtr(false);
            si.setEnableTrailingStopSar(false);
            si.setEnableTrailingStopMa(false);
            break;
      }
      //si.setEnableTrailingStopFix(In_Enable_TrailingStopFix);
      si.setTrailingStopFixPoint(In_TrailingStop_Fix_Point);
      //si.setEnableTrailingStopAtr(In_Enable_TrailingStopATR);
      //si.setEnableTrailingStopSar(In_Enable_TrailingStopSar);
      //si.setEnableTrailingStopMa(In_Enable_TrailingStopMA);
      si.setTrailingStopOffset(In_TrailingStop_OffsetPoint);
      si.setEnabled(true);
      si.setMultipleAtr(In_TrailingStop_ATR_Multiple);
      SymbolList.Add(si);
   }
}

void setBtnSelected(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,  ClrBtnBgSelected);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,    ClrBtnFtSelected);
}

void setBtnUnselected(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,  ClrBtnBgUnselected);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,    ClrBtnFtUnselected);
}

void setSpreadEnable(int i) {
   string objNm = getObjectName(i, COL_NO_Spread, panelNamePrefix);
   ObjectSetInteger(0,objNm,OBJPROP_BGCOLOR,  ClrBgSpreadEnable);
   objNm = getObjectName(i, COL_NO_Spread);
   ObjectSetInteger(0,objNm,OBJPROP_COLOR,    ClrFtSpreadEnable);
}

void setSpreadDisable(int i) {
   string objNm = getObjectName(i, COL_NO_Spread, panelNamePrefix);
   ObjectSetInteger(0,objNm,OBJPROP_BGCOLOR,  ClrBgSpreadDisable);
   objNm = getObjectName(i, COL_NO_Spread);
   ObjectSetInteger(0,objNm,OBJPROP_COLOR,    ClrFtSpreadDisable);
}

int calculatePointBetween2Price(double p1, double p2, double poi) {
   return ((int)((p1-p2)/poi));
}

void setAtrVal(int i) {
   long chartId = 0;
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   double atrVal = iATR(si.getRealName(), Timeframe, In_TrailingStop_ATR_Period, 0);
   atrVal = NormalizeDouble(atrVal*si.getMultipleAtr(), si.getDigits())/si.getPoint();
   ObjectSetString(chartId, getObjectName(i,COL_NO_TSatr), OBJPROP_TEXT, IntegerToString((int)atrVal));
}

void setSarVal(int i) {
   long chartId = 0;
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   double sarVal = iSAR(si.getRealName(), Timeframe, In_TrailingStop_Sar_Step, In_TrailingStop_Sar_Maximum,0);
   sarVal = NormalizeDouble(sarVal, si.getDigits());
   
   int slp = 0;
   color clr = ClrTxtS;
   if (sarVal < iLow(si.getRealName(), Timeframe, 0)) {
      clr = ClrTxtL;
      double p1 = MarketInfo(si.getRealName(), MODE_BID);
      slp = calculatePointBetween2Price(p1, sarVal, si.getPoint());
   } else {
      double p1 = MarketInfo(si.getRealName(), MODE_ASK);
      slp = calculatePointBetween2Price(sarVal, p1, si.getPoint());
   }
   ObjectSetString(chartId, getObjectName(i,COL_NO_SarVal), OBJPROP_TEXT, IntegerToString(slp));
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_SarVal),OBJPROP_COLOR,clr);
}

void setMaVal(int i) {
   long chartId = 0;
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   double maVal = iMA(si.getRealName(), Timeframe, In_TrailingStop_MA_Period, 0, In_TrailingStop_MA_Method, In_TrailingStop_MA_Applied_Price, 0);
   maVal = NormalizeDouble(maVal, si.getDigits());

   int slp = 0;
   color clr = ClrTxtS;
   if (maVal < iClose(si.getRealName(), Timeframe, 0)) {
      clr = ClrTxtL;
      double p1 = MarketInfo(si.getRealName(), MODE_BID);
      slp = calculatePointBetween2Price(p1, maVal, si.getPoint());
   } else {
      double p1 = MarketInfo(si.getRealName(), MODE_ASK);
      slp = calculatePointBetween2Price(maVal, p1, si.getPoint());
   }
   ObjectSetString(chartId, getObjectName(i,COL_NO_MaVal), OBJPROP_TEXT, IntegerToString(slp));
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_MaVal),OBJPROP_COLOR,clr);
}

void Draw(int startXi, int startYi, CList *symbolList) {
   int x = startXi;
   int y = startYi;
   long chartId = 0;
   
   int ColumnWidth[];
   int ColumnWidthAdjust[];
   int ColumnH1Width[];
   int ColumnH1WidthAdjust[];
   int ColumnH2Width[];
   int ColumnH2WidthAdjust[];
   int columnCount = ArraySize(ColName);
   int RowHeight = RowHeight2K;
   //ArrayResize(ColumnWidth, columnCount);
   
   if (In_4Kdisplay) {
      ArrayCopy(ColumnWidth, ColWidth4K);
      ArrayCopy(ColumnWidthAdjust, ColAdjustX4K);
      ArrayCopy(ColumnH1Width, ColH1Width4K);
      ArrayCopy(ColumnH1WidthAdjust, ColH1AdjustX4K);
      ArrayCopy(ColumnH2Width, ColH2Width4K);
      ArrayCopy(ColumnH2WidthAdjust, ColH2AdjustX4K);
      RowHeight = RowHeight4K;
   } else {
      ArrayCopy(ColumnWidth, ColWidth);
      ArrayCopy(ColumnWidthAdjust, ColAdjustX);
      ArrayCopy(ColumnH1Width, ColH1Width);
      ArrayCopy(ColumnH1WidthAdjust, ColH1AdjustX);
      ArrayCopy(ColumnH2Width, ColH2Width);
      ArrayCopy(ColumnH2WidthAdjust, ColH2AdjustX);
   }
   
   ColH1Type[COL_NO_H] = "UNUSE";
   ColH1Type[COL_NO_D] = "UNUSE";
   ColH1Type[COL_NO_N] = "UNUSE";
   ColType[COL_NO_H] = "UNUSE";
   ColType[COL_NO_D] = "UNUSE";
   ColType[COL_NO_N] = "UNUSE";
   
   if (1 < gvMaxCntOnePair) {
      ColH1Type[COL_NO_Sl2Open] = "UNUSE";
      ColType[COL_NO_Sl2Open] = "UNUSE";
      ColH1Type[COL_NO_AddSl2Now] = "UNUSE";
      ColType[COL_NO_AddSl2Now] = "UNUSE";
      ColH1Type[COL_NO_Sl2Now] = "UNUSE";
      ColType[COL_NO_Sl2Now] = "UNUSE";
      ColH1Type[COL_NO_MnsSl2Now] = "UNUSE";
      ColType[COL_NO_MnsSl2Now] = "UNUSE";
      ColH1Type[COL_NO_Tp2Open] = "UNUSE";
      ColType[COL_NO_Tp2Open] = "UNUSE";
      ColH1Type[COL_NO_AddTp2Now] = "UNUSE";
      ColType[COL_NO_AddTp2Now] = "UNUSE";
      ColH1Type[COL_NO_Tp2Now] = "UNUSE";
      ColType[COL_NO_Tp2Now] = "UNUSE";
      ColH1Type[COL_NO_MnsTp2Now] = "UNUSE";
      ColType[COL_NO_MnsTp2Now] = "UNUSE";
   }
   
   // header row (H2)
   for (int colIndex=0; colIndex<columnCount; colIndex++) {
      string columnType = ColH2Type[colIndex];
      if ("lbl"==columnType) {
         CreatePanel(ObjNamePrefix+panelNamePrefix+columnType+ColH2Name[colIndex],x,y,ColumnH2Width[colIndex],RowHeight,ColBgClrLblH1,ColBdClrLblH1,Border_Width);
         SetText(ObjNamePrefix+columnType+ColH2Name[colIndex],ColH2Text[colIndex],x+ColumnH2WidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColFtClrLbl);
         x += ColumnH2Width[colIndex] + ColumnInterval;

      } else if ("btn"==columnType) {
         CreateButton(ObjNamePrefix+columnType+ColH2Name[colIndex],ColH2Text[colIndex],x,y,ColumnH2Width[colIndex],RowHeight,ColBgClrBtn,ColFtClrBtn);
         x += ColumnH2Width[colIndex] + ColumnInterval;

      } else if ("lbo"==columnType) {
         CreatePanel(ObjNamePrefix+panelNamePrefix+columnType+ColH2Name[colIndex],x,y,ColumnH2Width[colIndex],RowHeight,ColBgClrLblH1,ColBdClrLblH1,Border_Width);
         SetObjText(ObjNamePrefix+columnType+ColH2Name[colIndex],ColH2Text[colIndex],x+ColumnH2WidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColFtClrLbl);
         x += ColumnH2Width[colIndex] + ColumnInterval;
      }
   }

   x = startXi;
   y += RowHeight + RowInterval;
   
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
      
      if (gvSpreadFilter) {
         if (gvLimitSpread < si.spread()) setSpreadDisable(i); else setSpreadEnable(i);
      }
      else setSpreadEnable(i);
      
      if (si.isEnableSl()) setBtnSelected(getObjectName(i, COL_NO_UseSl)); else setBtnUnselected(getObjectName(i, COL_NO_UseSl));
      ObjectSetString(chartId, getObjectName(i,COL_NO_SlP), OBJPROP_TEXT, IntegerToString(si.getSlPoint()));
      
      if (si.isEnableTp()) setBtnSelected(getObjectName(i, COL_NO_UseTp)); else setBtnUnselected(getObjectName(i, COL_NO_UseTp));
      ObjectSetString(chartId, getObjectName(i,COL_NO_TpP), OBJPROP_TEXT, IntegerToString(si.getTpPoint()));
      
      //if (si.isEnableTrailingStop()) {
         if (si.isEnableTrailingStopFix()) setBtnSelected(getObjectName(i, COL_NO_TSfix)); else setBtnUnselected(getObjectName(i, COL_NO_TSfix));
         if (si.isEnableTrailingStopAtr()) setBtnSelected(getObjectName(i, COL_NO_TSatr)); else setBtnUnselected(getObjectName(i, COL_NO_TSatr));
         if (si.isEnableTrailingStopSar()) setBtnSelected(getObjectName(i, COL_NO_TSsar)); else setBtnUnselected(getObjectName(i, COL_NO_TSsar));
         if (si.isEnableTrailingStopMa()) setBtnSelected(getObjectName(i, COL_NO_TSma)); else setBtnUnselected(getObjectName(i, COL_NO_TSma));
/*
      } else {
         setBtnUnselected(getObjectName(i, COL_NO_TSfix));
         setBtnUnselected(getObjectName(i, COL_NO_TSatr));
         setBtnUnselected(getObjectName(i, COL_NO_TSsar));
         setBtnUnselected(getObjectName(i, COL_NO_TSma));
      }
*/
      ObjectSetString(chartId, getObjectName(i,COL_NO_FixP), OBJPROP_TEXT, IntegerToString(si.getTrailingStopFixPoint()));
      
      setAtrVal(i);
      setSarVal(i);
      setMaVal(i);

      ObjectSetString(chartId, getObjectName(i,COL_NO_Offset), OBJPROP_TEXT, IntegerToString(si.getTrailingStopOffset()));
      
      if (1 < gvMaxCntOnePair) {
/*
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_AddSl2Now),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_AddSl2Now),OBJPROP_YSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_MnsSl2Now),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_MnsSl2Now),OBJPROP_YSIZE,0);
         ObjectSetString(chartId, getObjectName(i,COL_NO_AddSl2Now), OBJPROP_TEXT, "");
         ObjectSetString(chartId, getObjectName(i,COL_NO_MnsSl2Now), OBJPROP_TEXT, "");
         
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_AddTp2Now),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_AddTp2Now),OBJPROP_YSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_MnsTp2Now),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_MnsTp2Now),OBJPROP_YSIZE,0);
         ObjectSetString(chartId, getObjectName(i,COL_NO_AddTp2Now), OBJPROP_TEXT, "");
         ObjectSetString(chartId, getObjectName(i,COL_NO_MnsTp2Now), OBJPROP_TEXT, "");
         
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Sl2Open, panelNamePrefix),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Sl2Open, panelNamePrefix),OBJPROP_YSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Sl2Now, panelNamePrefix),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Sl2Now, panelNamePrefix),OBJPROP_YSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Tp2Open, panelNamePrefix),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Tp2Open, panelNamePrefix),OBJPROP_YSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Tp2Now, panelNamePrefix),OBJPROP_XSIZE,0);
         ObjectSetInteger(chartId,getObjectName(i, COL_NO_Tp2Now, panelNamePrefix),OBJPROP_YSIZE,0);
*/
      }
      
      y += RowHeight + RowInterval;
   }
   
   if (1 < gvMaxCntOnePair) {
/*
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Sl2Open],OBJPROP_XSIZE,0);
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Sl2Open],OBJPROP_YSIZE,0);
      ObjectSetString(chartId, ObjNamePrefix+H1NamePrefix+"lbl"+ColName[COL_NO_Sl2Open], OBJPROP_TEXT, "");
      
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Sl2Now],OBJPROP_XSIZE,0);
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Sl2Now],OBJPROP_YSIZE,0);
      ObjectSetString(chartId, ObjNamePrefix+H1NamePrefix+"lbl"+ColName[COL_NO_Sl2Now], OBJPROP_TEXT, "");
      
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Tp2Open],OBJPROP_XSIZE,0);
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Tp2Open],OBJPROP_YSIZE,0);
      ObjectSetString(chartId, ObjNamePrefix+H1NamePrefix+"lbl"+ColName[COL_NO_Tp2Open], OBJPROP_TEXT, "");
      
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Tp2Now],OBJPROP_XSIZE,0);
      ObjectSetInteger(chartId,ObjNamePrefix+H1NamePrefix+panelNamePrefix+"lbl"+ColName[COL_NO_Tp2Now],OBJPROP_YSIZE,0);
      ObjectSetString(chartId, ObjNamePrefix+H1NamePrefix+"lbl"+ColName[COL_NO_Tp2Now], OBJPROP_TEXT, "");
*/
   }
   string objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Spread];
   if (gvSpreadFilter) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin1];
   if (In_Use_Pin1) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin2];
   if (In_Use_Pin2) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin3];
   if (In_Use_Pin3) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin4];
   if (In_Use_Pin4) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin5];
   if (In_Use_Pin5) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin6];
   if (In_Use_Pin6) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin7];
   if (In_Use_Pin7) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin8];
   if (In_Use_Pin8) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_Pin9];
   if (In_Use_Pin9) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_UseSl];
   if (In_Use_Stoploss) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_UseTp];
   if (In_Use_TakeProfit) setBtnSelected(objNm); else setBtnUnselected(objNm);
   
   //objNm = ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix];
   //if (si.isEnableTrailingStopFix) setBtnSelected(objNm); else setBtnUnselected(objNm);
   switch (In_Trailing_Stop_Method) {
      case TSM_Fix:
         setBtnSelected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         break;
      case TSM_ATR:
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnSelected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         break;
      case TSM_Sar:
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnSelected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         break;
      case TSM_MA:
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         setBtnSelected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         break;
      default:
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSfix]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSatr]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSsar]);
         setBtnUnselected(ObjNamePrefix+H1NamePrefix+"btn"+ColName[COL_NO_TSma]);
         break;
   }
   
   ObjectSetString(chartId, ObjNamePrefix+"lbl"+"Lot", OBJPROP_TEXT, paddingSpaceLeft(gvLots,2,6));
   ObjectSetString(chartId, ObjNamePrefix+"lbl"+"Step", OBJPROP_TEXT, IntegerToString(gvStepAddPoint,5));
   setBtnAuto(gvIsAuto);
   
   ChartRedraw();
}

void setBtnAuto(bool status) {
   const color    ClrBtnBgAuto   = clrGreen;
   const color    ClrBtnFtAuto   = clrBlack;
   const color    ClrBtnBgManual = clrGray;
   const color    ClrBtnFtManual = clrWhite;
   const string   TxtStatusAuto  = "Auto";
   const string   TxtStatusManual= "Manual";
   string objName = ObjNamePrefix+"btn"+"Auto";
   gvIsAuto = status;
   if (status) {
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,ClrBtnBgAuto);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,ClrBtnFtAuto);
      ObjectSetString(0,objName,OBJPROP_TEXT,TxtStatusAuto);
      
   } else {
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,ClrBtnBgManual);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,ClrBtnFtManual);
      ObjectSetString(0,objName,OBJPROP_TEXT,TxtStatusManual);
   }
}

void setPin(int i) {
   long chartId = 0;
   SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
   //int i = si.getIndex();
   color clr = Color_Signal_BG_N;
   int signal = si.getSignal(0);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin1, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(1);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin2, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(2);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin3, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(3);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin4, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(4);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin5, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(5);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin6, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(6);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin7, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(7);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin8, panelNamePrefix),OBJPROP_BGCOLOR,clr);

   signal = si.getSignal(8);
         if (0 < signal) clr = Color_Signal_BG_L;
   else  if (signal < 0) clr = Color_Signal_BG_S;
   ObjectSetInteger(chartId,getObjectName(i, COL_NO_Pin9, panelNamePrefix),OBJPROP_BGCOLOR,clr);
}

string getObjectName(int rowIndex, int columnIndex, string recPanelNamePrefix="") export {
   return ObjNamePrefix+recPanelNamePrefix+ColType[columnIndex]+ColName[columnIndex]+IntegerToString(rowIndex);
}

void SetText(string name,string text,int x,int y,color fontColor,int fontSize=7,string fontName="Arial",double angle=0.0,ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER) {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetString(chartId,name,OBJPROP_FONT,fontName);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   
   ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartId,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chartId,name,OBJPROP_ZORDER,-1);
   ObjectSetInteger(chartId,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartId,name,OBJPROP_BACK,false); // display in the foreground (false) or background (true)
   ObjectSetString(chartId,name,OBJPROP_TEXT,text);
   
   ObjectSetDouble(chartId,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chartId,name,OBJPROP_ANCHOR,anchor);
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
   bool              close(double lot=0.0) const;
   bool              modifySL(double sl);
   bool              modifyTP(double tp);
   bool              upOrDownSL(int pointSL);
   bool              upOrDownTP(int pointTP);
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

bool OrderInfo::close(double lot=0.0) const {
   double lots = lot;
   if (lots < 0.001) {
      lots = lotSize;
   }
   double closePrice = 0.0;
   bool isSuccess = false;
   if (OP_BUY == operationType) {
      closePrice = MarketInfo(symbolName, MODE_BID);
      isSuccess= OrderClose(this.ticketId, lots, closePrice, 0, clrRed);
   } else if (OP_SELL == operationType) {
      closePrice = MarketInfo(symbolName, MODE_ASK);
      isSuccess = OrderClose(this.ticketId, lots, closePrice, 0, clrRed);
   }
   if (isSuccess) Print("Order(ticket=", this.ticketId, " is closed successfully. Symbol=", this.symbolName);
   else Print("OrderClose failed with error #", ErrorDescription(GetLastError()), " Symbol=", this.symbolName, " ticket=", this.ticketId);
   
   return isSuccess;
}

bool OrderInfo::modifySL(double sl) {
   bool res = OrderModify(this.ticketId, this.openPrice, sl, this.tpPrice, 0, clrNONE);
   if (res) {
      Print("Order modified successfully.", "Ticket ID=", this.ticketId, " Symbol=", this.symbolName, " ", this.slPrice, "==>", sl);
      this.slPrice = sl;
   } else {
      Print("Error in OrderModify.", "Ticket ID=", this.ticketId, " Symbol=", this.symbolName, " Error code=", ErrorDescription(GetLastError()));
   }
   
   return res;
}

bool OrderInfo::modifyTP(double tp) {
   bool res = OrderModify(this.ticketId, this.openPrice, this.slPrice, tp, 0, clrNONE);
   if (res) {
      Print("Order modified successfully.", "Ticket ID=", this.ticketId, " Symbol=", this.symbolName, " ", this.tpPrice, "==>", tp);
      this.tpPrice = tp;
   } else {
      Print("Error in OrderModify.", "Ticket ID=", this.ticketId, " Symbol=", this.symbolName, " Error code=", ErrorDescription(GetLastError()));
   }
   
   return res;
}

bool OrderInfo::upOrDownSL(int pointSL) {
   double newSLPrice = this.slPrice + pointSL*MarketInfo(this.symbolName, MODE_POINT);
   newSLPrice = NormalizeDouble(newSLPrice, (int)MarketInfo(this.symbolName, MODE_DIGITS));
   return this.modifySL(newSLPrice);
}

bool OrderInfo::upOrDownTP(int pointTP) {
   double newTPPrice = this.tpPrice + pointTP*MarketInfo(this.symbolName, MODE_POINT);
   newTPPrice = NormalizeDouble(newTPPrice, (int)MarketInfo(this.symbolName, MODE_DIGITS));
   return this.modifyTP(newTPPrice);
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
   //bool              enableTrailingStop;
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
   datetime          signalTimes[9];
   
public:
                     SymbolInfo() {}
                     SymbolInfo(string SymbolShortName, string SymbolPrefix="", string SymbolSuffix="", int Index=0);
                    ~SymbolInfo() { delete OrderListL; delete OrderListS;}
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
   
   void              setSlPoint(int vPoint)                       { slPoint=vPoint;stopLoss=vPoint*point;}
   int               getSlPoint(void)                       const { return(slPoint);                     }
   
   void              setEnableTp(bool enable)                     { this.enableTp = enable;              }
   bool              isEnableTp(void)                       const { return(enableTp);                    }
   
   void              setTpPoint(int vPoint)                       { tpPoint=vPoint;takeProfit=vPoint*point;}
   int               getTpPoint(void)                       const { return(tpPoint);                     }
   /*
   void              setEnableTrailingStop(bool enable)           { this.enableTrailingStop = enable;    }
   bool              isEnableTrailingStop(void)             const { return(enableTrailingStop);          }
   */
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

   void              setSignal(int index_, int signal)            { signals[index_] = signal;            }
   int               getSignal(int index_)                  const { return(signals[index_]);             }
   void              setSignalTime(int index_, datetime t)        { signalTimes[index_] = t;             }
   datetime          getSignalTime(int index_)              const { return(signalTimes[index_]);         }

   int               getOrderCountL(void)                   const { return OrderListL.Total();           }
   int               getOrderCountS(void)                   const { return OrderListS.Total();           }
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
   int               closeOrdersL() const;
   int               closeOrdersS() const;
   bool              modifySLOrderL(int index, double sl)   const;
   bool              modifySLOrderS(int index, double sl)   const;
   bool              modifyTPOrderL(int index, double tp)   const;
   bool              modifyTPOrderS(int index, double tp)   const;
   bool              modifySLpOrderL(int index, int pointSl)const;
   bool              modifySLpOrderS(int index, int pointSl)const;
   bool              modifyTPpOrderL(int index, int pointTp)const;
   bool              modifyTPpOrderS(int index, int pointTp)const;
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
   OrderListL = new CList();
   OrderListS = new CList();
   ArrayInitialize(signals, 0);
   ArrayInitialize(signalTimes, 0);
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
      if(point != 0)    s  = s+(iHigh(pairName,PERIOD_D1,a)-iLow(pairName,PERIOD_D1,a))/this.point;
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
   return (iHigh(pairName, PERIOD_D1, 0) - iLow(pairName, PERIOD_D1, 0))/this.point;
}

int SymbolInfo::closeOrdersL(void) const {
   OrderInfo *order;
   int closeCount = 0;
   for (int i=OrderListL.Total()-1; 0<=i; i--) {
      order = OrderListL.GetNodeAtIndex(i);
      if (order.close()) closeCount++;
   }
   return closeCount;
}

int SymbolInfo::closeOrdersS(void) const {
   OrderInfo *order;
   int closeCount = 0;
   for (int i=OrderListS.Total()-1; 0<=i; i--) {
      order = OrderListS.GetNodeAtIndex(i);
      if (order.close()) closeCount++;
   }
   return closeCount;
}

bool SymbolInfo::modifySLOrderL(int i, double sl) const {
   OrderInfo *order = OrderListL.GetNodeAtIndex(i);
   return order.modifySL(sl);
}

bool SymbolInfo::modifySLOrderS(int i, double sl) const {
   OrderInfo *order = OrderListS.GetNodeAtIndex(i);
   return order.modifySL(sl);
}

bool SymbolInfo::modifyTPOrderL(int i, double tp) const {
   OrderInfo *order = OrderListL.GetNodeAtIndex(i);
   return order.modifyTP(tp);
}

bool SymbolInfo::modifyTPOrderS(int i, double tp) const {
   OrderInfo *order = OrderListS.GetNodeAtIndex(i);
   return order.modifyTP(tp);
}

bool SymbolInfo::modifySLpOrderL(int i, int pointSl) const {
   OrderInfo *order = OrderListL.GetNodeAtIndex(i);
   return order.upOrDownSL(pointSl);
}

bool SymbolInfo::modifySLpOrderS(int i, int pointSl) const {
   OrderInfo *order = OrderListS.GetNodeAtIndex(i);
   return order.upOrDownSL(pointSl);
}

bool SymbolInfo::modifyTPpOrderL(int i, int pointTp) const {
   OrderInfo *order = OrderListL.GetNodeAtIndex(i);
   return order.upOrDownTP(pointTp);
}

bool SymbolInfo::modifyTPpOrderS(int i, int pointTp) const {
   OrderInfo *order = OrderListS.GetNodeAtIndex(i);
   return order.upOrDownTP(pointTp);
}
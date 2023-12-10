//+------------------------------------------------------------------+
//|                                             Dashboard-EAX_4K.mq5 |
//|                                  Copyright 2022, Zeng Gao.       |
//|                                             email:soko8@sina.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Zeng Gao."
#property link      "email:soko8@sina.com"
#property version   "1.00"
#property description "email:soko8@sina.com" 

#define EAX_COL_H	0
#define EAX_COL_D	1
#define EAX_COL_N	2
#define EAX_COL_Chart	3
#define EAX_COL_Pair	4
#define EAX_COL_MaxProfit	5
#define EAX_COL_MinProfit	6
#define EAX_COL_SingularModeL	7
#define EAX_COL_TradeModeL	8
#define EAX_COL_GridModeL	9
#define EAX_COL_RetraceModeL	10
#define EAX_COL_OtherModeL	11
#define EAX_COL_PlusOrdL	12
#define EAX_COL_OrdCntL	13
#define EAX_COL_MinusOrdL	14
#define EAX_COL_ProfitLMinus	15
#define EAX_COL_MinusMaxOrdL	16
#define EAX_COL_ProfitLMinusMax	17
#define EAX_COL_LotsL	18
#define EAX_COL_ClosePositiveL	19
#define EAX_COL_ProfitL	20
#define EAX_COL_CloseNegativeL	21
#define EAX_COL_MaxProfitL	22
#define EAX_COL_MinProfitL	23
#define EAX_COL_CloseL	24
#define EAX_COL_Tp2OPL	25
#define EAX_COL_EnableTpL	26
#define EAX_COL_AddTpL	27
#define EAX_COL_Tp2Bid	28
#define EAX_COL_MinusTpL	29
#define EAX_COL_Sl2OPL	30
#define EAX_COL_EnableSlL	31
#define EAX_COL_AddSlL	32
#define EAX_COL_Sl2Ask	33
#define EAX_COL_MinusSlL	34
#define EAX_COL_SwapL	35
#define EAX_COL_SymbolN	36
#define EAX_COL_EnableGrid	37
#define EAX_COL_PlusGrid	38
#define EAX_COL_GridPips	39
#define EAX_COL_MinusGrid	40
#define EAX_COL_EnableRetrace	41
#define EAX_COL_PlusRetrace	42
#define EAX_COL_RetracePips	43
#define EAX_COL_MinusRetrace	44
#define EAX_COL_SwapS	45
#define EAX_COL_SingularModeS	46
#define EAX_COL_TradeModeS	47
#define EAX_COL_GridModeS	48
#define EAX_COL_RetraceModeS	49
#define EAX_COL_OtherModeS	50
#define EAX_COL_PlusOrdS	51
#define EAX_COL_OrdCntS	52
#define EAX_COL_MinusOrdS	53
#define EAX_COL_ProfitSMinus	54
#define EAX_COL_MinusMaxOrdS	55
#define EAX_COL_ProfitSMinusMax	56
#define EAX_COL_LotsS	57
#define EAX_COL_ClosePositiveS	58
#define EAX_COL_ProfitS	59
#define EAX_COL_CloseNegativeS	60
#define EAX_COL_MaxProfitS	61
#define EAX_COL_MinProfitS	62
#define EAX_COL_CloseS	63
#define EAX_COL_Tp2OPS	64
#define EAX_COL_EnableTpS	65
#define EAX_COL_AddTpS	66
#define EAX_COL_Tp2Ask	67
#define EAX_COL_MinusTpS	68
#define EAX_COL_Sl2OPS	69
#define EAX_COL_EnableSlS	70
#define EAX_COL_AddSlS	71
#define EAX_COL_Sl2Bid	72
#define EAX_COL_MinusSlS	73
#define EAX_COL_Profit	74
#define EAX_COL_CloseLS	75
#define EAX_COL_Spread	76
#define EAX_COL_ADR	77
#define EAX_COL_CDR	78
#define EAX_COL_PIN1	79
#define EAX_COL_PIN2	80
#define EAX_COL_PIN3	81
#define EAX_COL_PIN4	82
#define EAX_COL_PIN5	83
#define EAX_COL_PIN6	84
#define EAX_COL_PIN7	85
#define EAX_COL_PIN8	86
#define EAX_COL_PIN9	87

#define clrHBGC1                       C'025, 202, 173'
#define clrHBGC2                       C'227, 237, 205'
#define clrHBGC3                       C'253, 230, 224'
#define clrHBGC4                       C'255, 242, 226'

//enum OrderMode {Singular_Order_Mode, Plural_Order_Mode};


//#include <Generic\ArrayList.mqh>
#include <Arrays\List.mqh>
#include <RowInfo.mqh>
#include <Trade/Trade.mqh>
#include <Generic\HashMap.mqh>

//--- input parameters
input color    Input3=clrYellow;
input datetime Input4=D'2022.02.13 08:03:21';
input long     Input5=1213;
input float    Input6=1324.0;


input bool        UseDefaultPairs=true;
input string      Pairs____="EURUSD,GBPUSD,USDJPY,AUDUSD";
input string      Prefix="";
input string      Surfix="";
input int         MagicNumber=88888888;

input double      LotSize____=0.01;
input double      LotStep____=0.01;
input uchar       MaxOrdersPerSymbol____ = 1;

input ushort      HoldMinutesSinceLastOpen____ = 15;

//input OrderMode   OrderMode____=Plural_Order_Mode;

input bool        ShowGridSets=true;
input bool        UseGrid____=true;
input ushort      GridPips____=10;
input uchar       GridMaxTimesPerSymbol____ = 20;

input bool        ShowRetraceSets=true;
input bool        UseRetrace____=true;
input ushort      RetracePips____=30;
input double      RetraceProfitCoefficient____ = 0.25;
input uchar       RetraceMaxTimesPerSymbol____ = 10;
input double      RetraceMultiple____ = 1.75;

input bool        ShowTakeProfitSets=true;
input bool        UseTakeProfit____=true;
input ushort      TakeProfitPips____=10;

input bool        ShowStopLossSets=true;
input bool        UseStopLoss____=true;
input ushort      StopLossPips____=10;

input bool        UseTrailingStop____=true;
input ushort      TrailingStopPips____=10;

input bool        ShowSwapSets=true;

input bool        FilterBySpread____=true;
input double      SpreadLimit____=4.0;

//input bool        FilterByADR____=false;
//input ushort      ADRMinLimitPips____=30;
//input ushort      ADRMaxLimitPips____=800;

input bool        FilterByCDR____=false;
input ushort      CDRMinLimitPips____=10;
input ushort      CDRMaxLimitPips____=100;

input bool        UsePIN1____=false;
input bool        UsePIN2____=false;
input bool        UsePIN3____=false;
input bool        UsePIN4____=false;
input bool        UsePIN5____=false;
input bool        UsePIN6____=false;
input bool        UsePIN7____=false;
input bool        UsePIN8____=false;
input bool        UsePIN9____=false;

input string      TemplateName="";

string Pairs[];
string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY","XAUUSD","XAGUSD"};



int      dataId[]             = { 1       , 2      , 3      , 4      , 5            , 6               , 7            , 8               , 9               , 10           , 11              , 12           , 13        , 14              , 15           , 16              , 17              , 18                 , 19              , 20              , 21              , 22              , 23           , 24           , 25        , 26              , 27           , 28        , 29              , 30        , 31              , 32           , 33        , 34              , 35        , 36              , 37           , 38           , 39        , 40              , 41           , 42              , 43           , 44              , 45              , 46              , 47              , 48              , 49           , 50              , 51           , 52        , 53              , 54           , 55              , 56              , 57                 , 58              , 59              , 60              , 61              , 62           , 63           , 64        , 65              , 66           , 67        , 68              , 69        , 70              , 71           , 72        , 73              , 74        , 75              , 76        , 77              , 78              , 79              , 80     , 81     , 82     , 83     , 84     , 85     , 86     , 87     , 88};
string   dataH1Text[]         = {"H"      ,"D"     ,"N"     ,"×"     ,"Select"      ,"MaxProfit"      ,"MinProfit"   ,"Si / Pl"        ,"T / D"          ,"G"           ,"R"              ,"O"           ,"+"        ,"L#"             ,"-"           ,"ProfitL-"       ,"-M"             ,"ProfitL-M"         ,"Lots"           ,"C+"             ,"ProfitL"        ,"C-"             ,"MaxProfit"   ,"MinProfit"   ,"CL"       ,"TPO"            ,"E"           ,"+"        ,"TPB"            ,"-"        ,"SLO"            ,"E"           ,"+"        ,"SLA"            ,"-"        ,"SwapL"          ,"Pair"        ,"G"           ,"+"        ,"Gr"             ,"-"           ,"R"              ,"+"           ,"Rt"             ,"-"              ,"SwapS"          ,"Si / Pl"        ,"T / D"          ,"G"           ,"R"              ,"O"           ,"+"        ,"S#"             ,"-"           ,"ProfitS-"       ,"-M"             ,"ProfitS-M"         ,"Lots"           ,"C+"             ,"ProfitS"        ,"C-"             ,"MaxProfit"   ,"MinProfit"   ,"CS"       ,"TPO"            ,"E"           ,"+"        ,"TPA"            ,"-"        ,"SLO"            ,"E"           ,"+"        ,"SLB"            ,"-"        ,"Profit"         ,"C"        ,"Sprd"           ,"ADR"            ,"CDR"            ,"1"     ,"2"     ,"3"     ,"4"     ,"5"     ,"6"     ,"7"     ,"8"     ,"9"};
string   dataH1ObjectType[]   = {"Btn"    ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"         ,"XXX"            ,"XXX"         ,"Btn"            ,"Btn"            ,"Btn"         ,"Btn"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Lbl"            ,"XXX"            ,"XXX"               ,"Lbl"            ,"Btn"            ,"Lbl"            ,"Btn"            ,"XXX"         ,"XXX"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"         ,"Btn"      ,"Btn"            ,"Btn"         ,"Btn"            ,"Btn"         ,"Btn"            ,"Btn"            ,"Lbl"            ,"Btn"            ,"Btn"            ,"Btn"         ,"Btn"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Lbl"            ,"XXX"            ,"XXX"               ,"Lbl"            ,"Btn"            ,"Lbl"            ,"Btn"            ,"XXX"         ,"XXX"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"      ,"Btn"            ,"Btn"            ,"Btn"            ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"};
int      dataH1Width[]        = {26       ,26      ,26      ,22      , 94           , 90              , 90           ,76               ,62               ,22            ,22               ,22            ,22         ,38               ,22            , 90              ,28               , 90                 ,62               ,42               , 92              ,42               , 90           , 90           ,42         ,56               ,22            ,22         ,56               ,22         ,56               ,22            ,22         ,56               ,22         ,68               ,98            ,22            ,22         ,38               ,22            ,22               ,22            ,38               ,22               ,68               ,76               ,62               ,22            ,22               ,22            ,22         ,38               ,22            , 90              ,28               , 90                 ,62               ,42               , 92              ,42               , 90           , 90           ,42         ,56               ,22            ,22         ,56               ,22         ,56               ,22            ,22         ,56               ,22         , 92              ,32         ,54               ,46               ,46               ,26      ,26      ,26      ,26      ,26      ,26      ,26      ,26      ,26};
int      dataH1WidthAdjust[]  = { 0       , 0      , 0      , 0      , 0            , 2               , 4            , 0               , 0               , 0            , 0               , 0            , 0         , 6               , 0            , 6               , 0               , 4                  ,10               , 0               ,14               , 0               , 2            , 4            , 0         , 9               , 0            , 0         , 9               , 0         , 9               , 0            , 0         , 9               , 0         , 2               , 0            , 0            , 0         , 0               , 0            , 0               , 0            , 0               , 0               , 2               , 0               , 0               , 0            , 0               , 0            , 0         , 5               , 0            , 6               , 0               , 2                  ,10               , 0               ,12               , 0               , 2            , 4            , 0         , 9               , 0            , 0         , 9               , 0         , 9               , 0            , 0         , 9               , 0         ,18               , 0         , 0               , 0               , 0               , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2 };
string   dataH1FontName[]     = {"Arial"  ,"Arial" ,"Arial" ,"Arial" ,"Arial"       ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"       ,"Arial"    ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"          ,"Arial"             ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial"       ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial"          ,"Arial"       ,"Arial"       ,"Arial"    ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"       ,"Arial"    ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"          ,"Arial"             ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial"       ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial"          ,"Arial"    ,"Arial"          ,"Arial"          ,"Arial"          ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial"};
int      dataH1FontSize[]     = { 7       , 7      , 7      , 7      , 7            , 6               , 6            , 7               , 7               , 7            , 7               , 7            , 7         , 7               , 7            , 7               , 7               , 6                  , 7               , 7               , 7               , 7               , 6            , 6            , 7         , 7               , 7            , 7         , 7               , 7         , 7               , 7            , 7         , 7               , 7         , 6               , 7            , 7            , 7         , 7               , 7            , 7               , 7            , 7               , 7               , 6               , 7               , 7               , 7            , 7               , 7            , 7         , 7               , 7            , 7               , 7               , 6                  , 7               , 7               , 7               , 7               , 6            , 6            , 7         , 7               , 7            , 7         , 7               , 7         , 7               , 7            , 7         , 7               , 7         , 7               , 7         , 6               , 0               , 6               , 7      , 7      , 7      , 7      , 7      , 7      , 7      , 7      , 7 };
color    dataH1BgColor[]      = {clrBlack ,clrBlack,clrBlack,clrBlack,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack            ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack            ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack};
color    dataH1FontColor[]    = {clrWhite ,clrWhite,clrWhite,clrWhite,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite};
color    dataH1BorderColor[]  = {clrWhite ,clrWhite,clrWhite,clrWhite,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite};

string   dataName[]           = {"H"      ,"D"     ,"N"     ,"Chart" ,"Pair"        ,"MaxProfit"      ,"MinProfit"   ,"SingularModeL"  ,"TradeModeL"     ,"GridModeL"   ,"RetraceModeL"   ,"OtherModeL"  ,"PlusOrdL" ,"OrdCntL"        ,"MinusOrdL"   ,"ProfitLMinus"   ,"MinusMaxOrdL"   ,"ProfitLMinusMax"   ,"LotsL"          ,"ClosePositiveL" ,"ProfitL"        ,"CloseNegativeL" ,"MaxProfitL"  ,"MinProfitL"  ,"CloseL"   ,"Tp2OPL"         ,"EnableTpL"   ,"AddTpL"   ,"Tp2Bid"         ,"MinusTpL" ,"Sl2OPL"         ,"EnableSlL"   ,"AddSlL"   ,"Sl2Ask"         ,"MinusSlL" ,"SwapL"          ,"SymbolN"     ,"EnableGrid"  ,"PlusGrid" ,"GridPips"       ,"MinusGrid"   ,"EnableRetrace"  ,"PlusRetrace" ,"RetracePips"    ,"MinusRetrace"   ,"SwapS"          ,"SingularModeS"  ,"TradeModeS"     ,"GridModeS"   ,"RetraceModeS"   ,"OtherModeS"  ,"PlusOrdS" ,"OrdCntS"        ,"MinusOrdS"   ,"ProfitSMinus"   ,"MinusMaxOrdS"   ,"ProfitSMinusMax"   ,"LotsS"          ,"ClosePositiveS" ,"ProfitS"        ,"CloseNegativeS" ,"MaxProfitS"  ,"MinProfitS"  ,"CloseS"   ,"Tp2OPS"         ,"EnableTpS"   ,"AddTpS"   ,"Tp2Ask"         ,"MinusTpS" ,"Sl2OPS"         ,"EnableSlS"   ,"AddSlS"   ,"Sl2Bid"         ,"MinusSlS" ,"Profit"         ,"CloseLS"  ,"Spread"         ,"ADR"            ,"CDR"            ,"PIN1"  ,"PIN2"  ,"PIN3"  ,"PIN4"  ,"PIN5"  ,"PIN6"  ,"PIN7"  ,"PIN8"  ,"PIN9"};
string   dataText[]           = {"H"      ,"D"     ,"N"     ,"~"     ,""            ,"-82345.78"      ,"-89999.99"   ,"Plural"         ,"Data"           ,"G"           ,"R"              ,"O"           ,"+"        ,"888"            ,"-"           ,"-99999.99"      ,"-M"             ,"-99999.99"         ,"999.99"         ,"C+"             ,"-99999.99"      ,"C-"             ,"-99999.99"   ,"-99999.99"   ,"CL"       ,"999.9"          ,"E"           ,"↑"        ,"999.9"          ,"↓"        ,"999.9"          ,"E"           ,"↑"        ,"999.9"          ,"↓"        ,"-99.99"         ,""            ,"G"           ,"+"        ,"999"            ,"-"           ,"R"              ,"+"           ,"999"            ,"-"              ,"-99.99"         ,"Plural"         ,"Data"           ,"G"           ,"R"              ,"O"           ,"+"        ,"999"            ,"-"           ,"-99999.99"      ,"-M"             ,"-99999.99"         ,"999.99"         ,"C+"             ,"-99999.99"      ,"C-"             ,"-99999.99"   ,"-99999.99"   ,"CS"       ,"999.9"          ,"E"           ,"↑"        ,"999.9"          ,"↓"        ,"999.9"          ,"E"           ,"↑"        ,"999.9"          ,"↓"        ,"-99999.99"      ,"C"        ,"999.9"          ,"999"            ,"999"            ,"▼"     ,"▲"     ,"▼"     ,"▲"     ,"▼"     ,"▲"     ,"▼"     ,"▲"     ,"▼"};
string   dataObjectType[]     = {"Btn"    ,"Btn"   ,"Btn"   ,"Btn"   ,"Btn"         ,"XXX"            ,"XXX"         ,"Btn"            ,"Btn"            ,"Btn"         ,"Btn"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Lbl"            ,"XXX"            ,"XXX"               ,"Lbl"            ,"Btn"            ,"Lbl"            ,"Btn"            ,"XXX"         ,"XXX"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"            ,"Btn"         ,"Lbl"            ,"Btn"            ,"Lbl"            ,"Btn"            ,"Btn"            ,"Btn"         ,"Btn"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Lbl"            ,"XXX"            ,"XXX"               ,"Lbl"            ,"Btn"            ,"Lbl"            ,"Btn"            ,"XXX"         ,"XXX"         ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"         ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Btn"      ,"Lbl"            ,"Lbl"            ,"Lbl"            ,"Lbl"   ,"Lbl"   ,"Lbl"   ,"Lbl"   ,"Lbl"   ,"Lbl"   ,"Lbl"   ,"Lbl"   ,"Lbl"};
int      dataWidth[]          = {26       ,26      ,26      ,22      , 94           , 90              , 90           ,76               ,62               ,22            ,22               ,22            ,22         ,38               ,22            , 90              ,28               , 90                 ,62               ,42               , 92              ,42               , 90           , 90           ,42         ,56               ,22            ,22         ,56               ,22         ,56               ,22            ,22         ,56               ,22         ,68               ,98            ,22            ,22         ,38               ,22            ,22               ,22            ,38               ,22               ,68               ,76               ,62               ,22            ,22               ,22            ,22         ,38               ,22            , 90              ,28               , 90                 ,62               ,42               , 92              ,42               , 90           , 90           ,42         ,56               ,22            ,22         ,56               ,22         ,56               ,22            ,22         ,56               ,22         , 92              ,32         ,54               ,46               ,46               ,26      ,26      ,26      ,26      ,26      ,26      ,26      ,26      ,26};
int      dataWidthAdjust[]    = { 0       , 0      , 0      , 0      , 0            , 2               , 2            , 0               , 0               , 0            , 0               , 0            , 0         , 4               , 0            , 2               , 0               , 2                  , 4               , 0               , 4               , 0               , 2            , 2            , 0         , 6               , 0            , 0         , 6               , 0         , 6               , 0            , 0         , 6               , 0         , 5               , 0            , 0            , 0         , 4               , 0            , 0               , 0            , 4               , 0               , 5               , 0               , 0               , 0            , 0               , 0            , 0         , 4               , 0            , 2               , 0               , 2                  , 4               , 0               , 4               , 0               , 2            , 2            , 0         , 6               , 0            , 0         , 6               , 0         , 6               , 0            , 0         , 6               , 0         , 4               , 0         , 4               , 8               , 2               , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2      , 2 };
string   dataFontName[]       = {"Arial"  ,"Arial" ,"Arial" ,"Arial" ,"Courier New" ,"Arial Narrow"   ,"Arial Narrow","Arial"          ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial Narrow"   ,"Arial"          ,"Arial Narrow"      ,"Arial Narrow"   ,"Arial"          ,"Arial Narrow"   ,"Arial"          ,"Arial Narrow","Arial Narrow","Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial Narrow"   ,"Courier New" ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"          ,"Arial"       ,"Arial Narrow"   ,"Arial"          ,"Arial Narrow"   ,"Arial"          ,"Arial"          ,"Arial"       ,"Arial"          ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial Narrow"   ,"Arial"          ,"Arial Narrow"      ,"Arial Narrow"   ,"Arial"          ,"Arial Narrow"   ,"Arial"          ,"Arial Narrow","Arial Narrow","Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial Narrow"   ,"Arial"       ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial Narrow"   ,"Arial"    ,"Arial Narrow"   ,"Arial Narrow"   ,"Arial Narrow"   ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial" ,"Arial"};
int      dataFontSize[]       = { 7       , 7      , 7      , 7      , 7            , 7               , 7            , 6               , 6               , 7            , 7               , 7            , 7         , 7               , 7            , 7               , 7               , 7                  , 7               , 7               , 7               , 7               , 7            , 7            , 7         , 7               , 7            , 7         , 7               , 7         , 7               , 7            , 7         , 7               , 7         , 7               , 7            , 7            , 7         , 7               , 7            , 7               , 7            , 7               , 7               , 7               , 6               , 6               , 7            , 7               , 7            , 7         , 7               , 7            , 7               , 7               , 7                  , 7               , 7               , 7               , 7               , 7            , 7            , 7         , 7               , 7            , 7         , 7               , 7         , 7               , 7            , 7         , 7               , 7         , 7               , 7         , 7               , 7               , 7               , 7      , 7      , 7      , 7      , 7      , 7      , 7      , 7      , 7 };
color    dataBgColor[]        = {clrBlack ,clrBlack,clrBlack,clrBlack,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack            ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack         ,clrBlack         ,clrBlack            ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack      ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack      ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack   ,clrBlack         ,clrBlack         ,clrBlack         ,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack,clrBlack};
color    dataFontColor[]      = {clrWhite ,clrWhite,clrWhite,clrWhite,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite};
color    dataBorderColor[]    = {clrWhite ,clrWhite,clrWhite,clrWhite,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite         ,clrWhite         ,clrWhite            ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite      ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite      ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite   ,clrWhite         ,clrWhite         ,clrWhite         ,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite,clrWhite};



      int                        dataRowHeight = 30;



      bool                       IsAutoTrade=false;
      int                        pairCount = 0;
      CList                      *RowInfos;
      CTrade                     trade;
      MqlTradeResult             TradeResult;
      CHashMap<string, int>      Pair2IndexMap();
      
      bool                       FilterBySpread = false;
      
const int                        PinsCount = 9;
const char                       Signal_None = 9;
const char                       Signal_Long = 1;
const char                       Signal_Swing = 0;
const char                       Signal_Short = -1;
      bool                       UsePins[];

const int                        StartX=4;
const int                        StartY=400;
const int                        DataH1RowHeight=36;
const string                     CommentM = "M";
const string                     CommentA = "A";
const string                     CommentAG = "AG";
const string                     CommentAR = "AR";
const string                     CommentMG = "MG";
const string                     CommentMR = "MR";
const string                     PanelNamePrefix = "Rec";
const string                     PanelNamePrefixH1 = "H1Rec";

   color bgTradeColor = clrDarkViolet;
   color bgSingularColor = clrBlue;
   color bgPluralColor = clrNavy;
   color bgNoDataColor = clrBlack;
   
   color bgGridModeColor = clrYellow;
   color bgRetraceModeColor = clrDeepPink;
   color bgOtherModeColor = clrGreen;
/*
const color                      clrBgBtnTrade = clrAliceBlue;
const color                      clrBgBtnNoDataHasSignal = clrAliceBlue;
const color                      clrBgBtnNoDataNoSignal = clrAliceBlue;
const color                      clrBgBtnSingular = clrAliceBlue;
const color                      clrBgBtnPlural = clrAliceBlue;

const color                      clrBgLblTrade = clrDarkViolet;
const color                      clrBgLblNoDataHasSignal = clrBlack;
const color                      clrBgLblNoDataNoSignal = clrBlack;
const color                      clrBgLblSingular = clrBlue;
const color                      clrBgLblPlural = clrNavy;

const color                      clrBtnTrade = clrAliceBlue;
const color                      clrBtnNoDataHasSignal = clrAliceBlue;
const color                      clrBtnNoDataNoSignal = clrAliceBlue;
const color                      clrBtnSingular = clrAliceBlue;
const color                      clrBtnPlural = clrAliceBlue;

const color                      clrLblTrade = clrWhite;
const color                      clrLblNoDataHasSignal = clrAliceBlue;
const color                      clrLblNoDataNoSignal = clrAliceBlue;
const color                      clrLblSingular = clrAliceBlue;
const color                      clrLblPlural = clrAliceBlue;
*/
const string                     Txt_Pin_Signal_Long  = "▲";
const string                     Txt_Pin_Signal_Swing = " ≡";
const string                     Txt_Pin_Signal_Short = "▼";
const string                     Txt_Pin_Signal_None  = " ";

const color                      clrLblPinBgSignalN = clrBlack;
const color                      clrLblPinBgSignalL = clrLime;
const color                      clrLblPinBgSignalS = clrRed;

const color                      clrLblPinFontSignalN = clrBlack;
const color                      clrLblPinFontSignalL = clrBlack;
const color                      clrLblPinFontSignalS = clrWhite;

const color                      clrLblPinBorderSignalN = clrWhite;
const color                      clrLblPinBorderSignalL = clrAqua;
const color                      clrLblPinBorderSignalS = clrBlueViolet;

void SetInitShows() {
   if (!ShowGridSets) {
      dataObjectType[EAX_COL_GridModeL] = "XXX";
      dataH1ObjectType[EAX_COL_GridModeL] = "XXX";
      dataObjectType[EAX_COL_GridModeS] = "XXX";
      dataH1ObjectType[EAX_COL_GridModeS] = "XXX";
      
      dataObjectType[EAX_COL_EnableGrid] = "XXX";
      dataH1ObjectType[EAX_COL_EnableGrid] = "XXX";
      
      dataObjectType[EAX_COL_PlusGrid] = "XXX";
      dataH1ObjectType[EAX_COL_PlusGrid] = "XXX";
      
      dataObjectType[EAX_COL_GridPips] = "XXX";
      dataH1ObjectType[EAX_COL_GridPips] = "XXX";
      
      dataObjectType[EAX_COL_MinusGrid] = "XXX";
      dataH1ObjectType[EAX_COL_MinusGrid] = "XXX";
   }
   
   if (!ShowRetraceSets) {
      dataObjectType[EAX_COL_RetraceModeL] = "XXX";
      dataH1ObjectType[EAX_COL_RetraceModeL] = "XXX";
      dataObjectType[EAX_COL_RetraceModeS] = "XXX";
      dataH1ObjectType[EAX_COL_RetraceModeS] = "XXX";
      
      dataObjectType[EAX_COL_ProfitLMinus] = "XXX";
      dataH1ObjectType[EAX_COL_ProfitLMinus] = "XXX";
      dataObjectType[EAX_COL_ProfitSMinus] = "XXX";
      dataH1ObjectType[EAX_COL_ProfitSMinus] = "XXX";
      
      dataObjectType[EAX_COL_EnableRetrace] = "XXX";
      dataH1ObjectType[EAX_COL_EnableRetrace] = "XXX";
      
      dataObjectType[EAX_COL_PlusRetrace] = "XXX";
      dataH1ObjectType[EAX_COL_PlusRetrace] = "XXX";
      
      dataObjectType[EAX_COL_RetracePips] = "XXX";
      dataH1ObjectType[EAX_COL_RetracePips] = "XXX";
      
      dataObjectType[EAX_COL_MinusRetrace] = "XXX";
      dataH1ObjectType[EAX_COL_MinusRetrace] = "XXX";
   }
   
   if (!ShowGridSets && !ShowRetraceSets) {
      dataObjectType[EAX_COL_OtherModeL] = "XXX";
      dataH1ObjectType[EAX_COL_OtherModeL] = "XXX";
      dataObjectType[EAX_COL_OtherModeS] = "XXX";
      dataH1ObjectType[EAX_COL_OtherModeS] = "XXX";
      if (MaxOrdersPerSymbol____ < 2) {
         dataObjectType[EAX_COL_SingularModeL] = "XXX";
         dataObjectType[EAX_COL_SingularModeS] = "XXX";
         dataObjectType[EAX_COL_TradeModeL] = "XXX";
         dataObjectType[EAX_COL_TradeModeS] = "XXX";
         dataObjectType[EAX_COL_MinusOrdL] = "XXX";
         dataObjectType[EAX_COL_MinusOrdS] = "XXX";
         dataObjectType[EAX_COL_ClosePositiveL] = "XXX";
         dataObjectType[EAX_COL_CloseNegativeL] = "XXX";
         dataObjectType[EAX_COL_ClosePositiveS] = "XXX";
         dataObjectType[EAX_COL_CloseNegativeS] = "XXX";
         
         dataH1ObjectType[EAX_COL_SingularModeL] = "XXX";
         dataH1ObjectType[EAX_COL_SingularModeS] = "XXX";
         dataH1ObjectType[EAX_COL_TradeModeL] = "XXX";
         dataH1ObjectType[EAX_COL_TradeModeS] = "XXX";
         dataH1ObjectType[EAX_COL_MinusOrdL] = "XXX";
         dataH1ObjectType[EAX_COL_MinusOrdS] = "XXX";
         dataH1ObjectType[EAX_COL_ClosePositiveL] = "XXX";
         dataH1ObjectType[EAX_COL_CloseNegativeL] = "XXX";
         dataH1ObjectType[EAX_COL_ClosePositiveS] = "XXX";
         dataH1ObjectType[EAX_COL_CloseNegativeS] = "XXX";
      }
   }
   
   if (!ShowTakeProfitSets) {
      dataObjectType[EAX_COL_Tp2OPL] = "XXX";
      dataObjectType[EAX_COL_EnableTpL] = "XXX";
      dataObjectType[EAX_COL_AddTpL] = "XXX";
      dataObjectType[EAX_COL_Tp2Bid] = "XXX";
      dataObjectType[EAX_COL_MinusTpL] = "XXX";
      
      dataH1ObjectType[EAX_COL_Tp2OPL] = "XXX";
      dataH1ObjectType[EAX_COL_EnableTpL] = "XXX";
      dataH1ObjectType[EAX_COL_AddTpL] = "XXX";
      dataH1ObjectType[EAX_COL_Tp2Bid] = "XXX";
      dataH1ObjectType[EAX_COL_MinusTpL] = "XXX";
      
      dataObjectType[EAX_COL_Tp2OPS] = "XXX";
      dataObjectType[EAX_COL_EnableTpS] = "XXX";
      dataObjectType[EAX_COL_AddTpS] = "XXX";
      dataObjectType[EAX_COL_Tp2Ask] = "XXX";
      dataObjectType[EAX_COL_MinusTpS] = "XXX";
      
      dataH1ObjectType[EAX_COL_Tp2OPS] = "XXX";
      dataH1ObjectType[EAX_COL_EnableTpS] = "XXX";
      dataH1ObjectType[EAX_COL_AddTpS] = "XXX";
      dataH1ObjectType[EAX_COL_Tp2Ask] = "XXX";
      dataH1ObjectType[EAX_COL_MinusTpS] = "XXX";
   }

   if (!ShowStopLossSets) {
      dataObjectType[EAX_COL_Sl2OPL] = "XXX";
      dataObjectType[EAX_COL_EnableSlL] = "XXX";
      dataObjectType[EAX_COL_AddSlL] = "XXX";
      dataObjectType[EAX_COL_Sl2Ask] = "XXX";
      dataObjectType[EAX_COL_MinusSlL] = "XXX";
      
      dataH1ObjectType[EAX_COL_Sl2OPL] = "XXX";
      dataH1ObjectType[EAX_COL_EnableSlL] = "XXX";
      dataH1ObjectType[EAX_COL_AddSlL] = "XXX";
      dataH1ObjectType[EAX_COL_Sl2Ask] = "XXX";
      dataH1ObjectType[EAX_COL_MinusSlL] = "XXX";
      
      dataObjectType[EAX_COL_Sl2OPS] = "XXX";
      dataObjectType[EAX_COL_EnableSlS] = "XXX";
      dataObjectType[EAX_COL_AddSlS] = "XXX";
      dataObjectType[EAX_COL_Sl2Bid] = "XXX";
      dataObjectType[EAX_COL_MinusSlS] = "XXX";
      
      dataH1ObjectType[EAX_COL_Sl2OPS] = "XXX";
      dataH1ObjectType[EAX_COL_EnableSlS] = "XXX";
      dataH1ObjectType[EAX_COL_AddSlS] = "XXX";
      dataH1ObjectType[EAX_COL_Sl2Bid] = "XXX";
      dataH1ObjectType[EAX_COL_MinusSlS] = "XXX";
   }
   
   if (!ShowSwapSets) {
      dataObjectType[EAX_COL_SwapL] = "XXX";
      dataH1ObjectType[EAX_COL_SwapL] = "XXX";
      dataObjectType[EAX_COL_SwapS] = "XXX";
      dataH1ObjectType[EAX_COL_SwapS] = "XXX";
   }
}

void setInput() {
   if (UseDefaultPairs) {
      ArrayCopy(Pairs, DefaultPairs);
   } else {
      StringSplit(Pairs____, StringGetCharacter(",",0), Pairs);
   }
   pairCount = ArraySize(Pairs);
   RowInfos = new CList;
   for (int i=0; i<pairCount; i++) {
      Pair2IndexMap.Add(Prefix+Pairs[i]+Surfix, i);
      CRowInfo *rowInfo = new CRowInfo(Pairs[i], Prefix, Surfix, PinsCount);
      RowInfos.Add(rowInfo);
      rowInfo.MaxOrders(MaxOrdersPerSymbol____);
      rowInfo.InitLotSize(LotSize____);
      rowInfo.LotStep(LotStep____);
      rowInfo.HoldMinutesSinceLastOpen(HoldMinutesSinceLastOpen____);
      rowInfo.OtherModeL(true);
      rowInfo.OtherModeS(true);
      rowInfo.SingularModeL(false);
      rowInfo.SingularModeS(false);
      rowInfo.TradeModeL(false);
      rowInfo.TradeModeS(false);
      if (MaxOrdersPerSymbol____<2 && !UseGrid____ && !UseRetrace____) {
         
      } else {

      }
      
      if (UseGrid____) {
         rowInfo.GridModeL(true);
         rowInfo.GridModeS(true);
         rowInfo.EnableGrid(true);
         rowInfo.GridPips(GridPips____);
         rowInfo.GridMaxTimes(GridMaxTimesPerSymbol____);
      } else {
         rowInfo.GridModeL(false);
         rowInfo.GridModeS(false);
         rowInfo.EnableGrid(false);
         rowInfo.GridPips(0);
         rowInfo.GridMaxTimes(0);
      }
      
      if (UseRetrace____) {
         rowInfo.RetraceModeL(true);
         rowInfo.RetraceModeS(true);
         rowInfo.EnableRetrace(true);
         rowInfo.RetracePips(RetracePips____);
         rowInfo.RetraceMaxTimes(RetraceMaxTimesPerSymbol____);
         rowInfo.RetraceMultiple(RetraceMultiple____);
         rowInfo.RetraceProfitCoefficient(RetraceProfitCoefficient____);
      } else {
         rowInfo.RetraceModeL(false);
         rowInfo.RetraceModeS(false);
         rowInfo.EnableRetrace(false);
         rowInfo.RetracePips(0);
         rowInfo.RetraceMaxTimes(0);
         rowInfo.RetraceMultiple(0.0);
         rowInfo.RetraceProfitCoefficient(0.0);
      }
      
      if (UseTakeProfit____) {
         rowInfo.EnableTpL(true);
         rowInfo.EnableTpS(true);
         rowInfo.TpPips(TakeProfitPips____);
      } else {
         rowInfo.EnableTpL(false);
         rowInfo.EnableTpS(false);
         rowInfo.TpPips(0);
      }
      
      if (UseStopLoss____) {
         rowInfo.EnableSlL(true);
         rowInfo.EnableSlS(true);
         rowInfo.SlPips(StopLossPips____);
      } else {
         rowInfo.EnableSlL(false);
         rowInfo.EnableSlS(false);
         rowInfo.SlPips(0);
      }
      
      if (UseTrailingStop____) {
         rowInfo.EnableTrailingStop(true);
         rowInfo.TrailingStopPips(TrailingStopPips____);
      } else {
         rowInfo.EnableTrailingStop(false);
         rowInfo.TrailingStopPips(0);
      }
      
      ArrayResize(UsePins, PinsCount);
      ArrayInitialize(UsePins, false);
      if (UsePIN1____) UsePins[0] = true;
      if (UsePIN2____) UsePins[1] = true;
      if (UsePIN3____) UsePins[2] = true;
      if (UsePIN4____) UsePins[3] = true;
      if (UsePIN5____) UsePins[4] = true;
      if (UsePIN6____) UsePins[5] = true;
      if (UsePIN7____) UsePins[6] = true;
      if (UsePIN8____) UsePins[7] = true;
      if (UsePIN9____) UsePins[8] = true;
      
      FilterBySpread = FilterBySpread____;
   }
}

void setRowShowL(int i) {
   CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(i);
   rowInfo.refreshL();
   string objName;
   bool isOnly1 = isOnly1Show();
   bool isOnlyO = isOnlyOther();
   
   if (!isOnly1) {
      objName = getObjectName(i, EAX_COL_SingularModeL);
      setBtnSingularMode(objName, rowInfo.SingularModeL(), rowInfo.TradeModeL(), rowInfo.OrdCntL(), rowInfo.HasSignalL());

      objName = getObjectName(i, EAX_COL_TradeModeL);
      setBtnTradeMode(objName, rowInfo.SingularModeL(), rowInfo.TradeModeL(), rowInfo.OrdCntL(), rowInfo.HasSignalL());
   }
   
   if (ShowGridSets) {
      objName = getObjectName(i, EAX_COL_GridModeL);
      //Print("rowInfo.HasSignalL()=", rowInfo.HasSignalL());
      setBtnGROMode(objName, rowInfo.GridModeL(), rowInfo.OrdCntL(), rowInfo.HasSignalL());
   }
   
   if (ShowRetraceSets) {
      objName = getObjectName(i, EAX_COL_RetraceModeL);
      setBtnGROMode(objName, rowInfo.RetraceModeL(), rowInfo.OrdCntL(), rowInfo.HasSignalL());
   }
   
   if (!isOnlyO) {
      objName = getObjectName(i, EAX_COL_OtherModeL);
      setBtnGROMode(objName, rowInfo.OtherModeL(), rowInfo.OrdCntL(), rowInfo.HasSignalL());
   }
   
   objName = getObjectName(i, EAX_COL_ClosePositiveL);
   setBtnClosePositive(objName, rowInfo.TradeModeL(), rowInfo.ProfitL());
   
   objName = getObjectName(i, EAX_COL_CloseNegativeL);
   setBtnCloseNegative(objName, rowInfo.TradeModeL(), rowInfo.ProfitL());
   
   objName = getObjectName(i, EAX_COL_EnableTpL);
   setBtnActivity(objName, rowInfo.EnableTpL());
   
   objName = getObjectName(i, EAX_COL_EnableSlL);
   setBtnActivity(objName, rowInfo.EnableSlL());
   
   objName = getObjectName(i, EAX_COL_OrdCntL);
   setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   
   if (ShowRetraceSets) {
      objName = getObjectName(i, EAX_COL_ProfitLMinus);
      setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
      if (rowInfo.TradeModeL()) {
         ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
      }
   }
   
   objName = getObjectName(i, EAX_COL_LotsL);
   setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   
   objName = getObjectName(i, EAX_COL_ClosePositiveL);
   setBtnClosePositive(objName, rowInfo.TradeModeL(), rowInfo.ProfitL());
   
   objName = getObjectName(i, EAX_COL_ProfitL);
   setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   
   objName = getObjectName(i, EAX_COL_CloseNegativeL);
   setBtnCloseNegative(objName, rowInfo.TradeModeL(), rowInfo.ProfitL());
   
   objName = getObjectName(i, EAX_COL_Tp2OPL);
   setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   if (rowInfo.TradeModeL()) {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   }
   
   objName = getObjectName(i, EAX_COL_Tp2Bid);
   setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   
   objName = getObjectName(i, EAX_COL_Sl2OPL);
   setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   if (rowInfo.TradeModeL()) {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   }
   
   objName = getObjectName(i, EAX_COL_Sl2Ask);
   setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   
   refreshRowDataShowL(i);
}

void setRowShowS(int i) {
   CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(i);
   rowInfo.refreshS();
   string objName;
   bool isOnly1 = isOnly1Show();
   bool isOnlyO = isOnlyOther();
   
   if (!isOnly1) {
      objName = getObjectName(i, EAX_COL_SingularModeS);
      setBtnSingularMode(objName, rowInfo.SingularModeS(), rowInfo.TradeModeS(), rowInfo.OrdCntS(), rowInfo.HasSignalS());

      objName = getObjectName(i, EAX_COL_TradeModeS);
      setBtnTradeMode(objName, rowInfo.SingularModeS(), rowInfo.TradeModeS(), rowInfo.OrdCntS(), rowInfo.HasSignalS());
   }
   
   if (ShowGridSets) {
      objName = getObjectName(i, EAX_COL_GridModeS);
      setBtnGROMode(objName, rowInfo.GridModeS(), rowInfo.OrdCntS(), rowInfo.HasSignalS());
   }
   
   if (ShowRetraceSets) {
      objName = getObjectName(i, EAX_COL_RetraceModeS);
      setBtnGROMode(objName, rowInfo.RetraceModeS(), rowInfo.OrdCntS(), rowInfo.HasSignalS());
   }
   
   if (!isOnlyO) {
      objName = getObjectName(i, EAX_COL_OtherModeS);
      setBtnGROMode(objName, rowInfo.OtherModeS(), rowInfo.OrdCntS(), rowInfo.HasSignalS());
   }
   
   objName = getObjectName(i, EAX_COL_ClosePositiveS);
   setBtnClosePositive(objName, rowInfo.TradeModeS(), rowInfo.ProfitS());
   
   objName = getObjectName(i, EAX_COL_CloseNegativeS);
   setBtnCloseNegative(objName, rowInfo.TradeModeS(), rowInfo.ProfitS());
   
   objName = getObjectName(i, EAX_COL_EnableTpS);
   setBtnActivity(objName, rowInfo.EnableTpS());
   
   objName = getObjectName(i, EAX_COL_EnableSlS);
   setBtnActivity(objName, rowInfo.EnableSlS());
   
   objName = getObjectName(i, EAX_COL_OrdCntS);
   setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
   
   if (ShowRetraceSets) {
      objName = getObjectName(i, EAX_COL_ProfitSMinus);
      setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
      if (rowInfo.TradeModeS()) {
         ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
      }
   }
   
   objName = getObjectName(i, EAX_COL_LotsS);
   setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
   
   objName = getObjectName(i, EAX_COL_ClosePositiveS);
   setBtnClosePositive(objName, rowInfo.TradeModeS(), rowInfo.ProfitS());
   
   objName = getObjectName(i, EAX_COL_ProfitS);
   setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
   
   objName = getObjectName(i, EAX_COL_CloseNegativeS);
   setBtnCloseNegative(objName, rowInfo.TradeModeS(), rowInfo.ProfitS());
   
   objName = getObjectName(i, EAX_COL_Tp2OPS);
   setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
   if (rowInfo.TradeModeS()) {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   }
   
   objName = getObjectName(i, EAX_COL_Tp2Ask);
   setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
   
   objName = getObjectName(i, EAX_COL_Sl2OPS);
   setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
   if (rowInfo.TradeModeS()) {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   }
   
   objName = getObjectName(i, EAX_COL_Sl2Bid);
   setLblDataShow(objName, rowInfo.TradeModeS(), rowInfo.SingularModeS(), rowInfo.OrdCntS());
   
   refreshRowDataShowS(i);

}
int OnInit() {
   ObjectsDeleteAll(0);
   SetInitShows();
   setInput();
   
   DrawDataH1(StartX, StartY);
   DrawData(StartX, StartY+DataH1RowHeight);
   //EventSetTimer(1);
   
   trade.SetExpertMagicNumber(MagicNumber);
   
   loadOrders();
   readPins();
   //setShowL();
   //setShowS();
   //setShowCommon();
   string objName;
   for (int i=0; i<pairCount; i++) {
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(i);
      setRowShowL(i);
      setRowShowS(i);
      objName = getObjectName(i, EAX_COL_EnableGrid);
      setBtnActivity(objName, rowInfo.EnableGrid());
      objName = getObjectName(i, EAX_COL_EnableRetrace);
      setBtnActivity(objName, rowInfo.EnableRetrace());
   }
   ChartRedraw();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   /*
   for (int i=0; i<pairCount; i++) {
      CSymbolInfo* symbol;
      PairList.TryGetValue(i, symbol);
      delete symbol;
   }
   
   for (int i=0; i<pairCount; i++) {
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(i);
      delete rowInfo;
   }
   */
   delete RowInfos;
   ObjectsDeleteAll(0);
   EventKillTimer();
   
}

void OnTick(){}

void OnTimer() {
   readPins();
   for (int i=0; i<pairCount; i++) {
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(i);
      rowInfo.refresh();
      refreshRow(i);
   }
}

void OnTrade() {
   //Print("OnTrade is Called");
}

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {
/*
   Print("OnTradeTransaction is Called");
   Print("交易单==", trans.deal);             // 交易单
   Print("订单标签==", trans.order);            // 订单标签
   Print("交易品种==", trans.symbol);           // 交易品种
   Print("交易事务类型==", trans.type);             // 交易事务类型
   Print("订单类型==", trans.order_type);       // 订单类型
   Print("订单状态==", trans.order_state);      // 订单状态
   Print("成交类型==", trans.deal_type);        // 成交类型
   Print("操作期的订单类型==", trans.time_type);        // 操作期的订单类型
   Print("订单到期时间==", trans.time_expiration);  // 订单到期时间
   Print("价格==",  trans.price);            // 价格 
   Print("限价止损订单激活价格==", trans.price_trigger);    // 限价止损订单激活价格
   Print("止损水平==", trans.price_sl);         // 止损水平
   Print("获利水平==", trans.price_tp);         // 获利水平
   Print("交易量手数==", trans.volume);           // 交易量手数
   Print("持仓价格==", trans.position);         // 持仓价格
   Print("反向持仓价格==", trans.position_by);      // 反向持仓价格
   
   
   Print("交易操作类型==", request.action);
   Print("EA交易 ID (幻数)==", request.magic);
   Print("订单号==", request.order);
   Print("交易的交易品种==", request.symbol);
   Print("一手需求的交易量==", request.volume);
   Print("价格==", request.price);
   Print("订单止损限价点位==", request.stoplimit);
   Print("订单止损价位点位==", request.sl);
   Print("订单盈利价位点位==", request.tp);
   Print("需求价格最可能的偏差==", request.deviation);
   Print("订单类型==", request.type);
   Print("订单执行类型==", request.type_filling);
   Print("订单执行时间==", request.type_time);
   Print("订单终止期 (为 ORDER_TIME_SPECIFIED 类型订单)==", request.expiration);
   Print("订单注释==", request.comment);
   Print("持仓编号==", request.position);
   Print("反向持仓编号==", request.position_by);

   Print("retcode==", result.retcode);
   Print("deal==", result.deal);
   Print("order==", result.order);
   Print("volume==", result.volume);
   Print("price==", result.price);
   Print("bid==", result.bid);
   Print("ask==", result.ask);
   Print("comment==", result.comment);
   Print("request_id==", result.request_id);
   Print("retcode_external==", result.retcode_external);
   */
   // 自动止损止盈时
   if (TRADE_TRANSACTION_HISTORY_ADD == trans.type && trans.price > 0.0) {
      ulong ticket = trans.position;
   } else
   
   // 修改止损止盈，开仓平仓时
   // 已收到服务器处理交易请求的通知和处理结果
   if (TRADE_TRANSACTION_REQUEST == trans.type && 10009 == result.retcode) {
      string symbolName = request.symbol;
      int index;
      if (!Pair2IndexMap.TryGetValue(symbolName, index)) return;
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
      // 修改止损止盈(MagicNumber获取不到)
      if (TRADE_ACTION_SLTP == request.action) {
         ulong ticket = request.position;
      // 开仓平仓
      } else if (TRADE_ACTION_DEAL == request.action) {
         
         ulong ticket = request.position;
         // 开仓时
         if (0 == ticket) {
            if (MagicNumber!=request.magic) return;
            // 不在此处理，在各个开仓点处理
            //ticket = result.order;
            //if () {
            //}
         // 平仓时(MagicNumber获取不到)
         } else {
         
         }
         
         
      }
   }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   long chartId = 0;
   int index = -1;
   if (id == CHARTEVENT_OBJECT_CLICK) {
      if ((0 <= StringFind(sparam, "BtnPIN"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnPIN")));
         index--;
         if (UsePins[index]) {
            UsePins[index] = false;
            disableButton(sparam, clrBlack, clrWhite);
         } else {
            UsePins[index] = true;
            enableButton(sparam);
         }
         readPins();
         for (int i=0; i<pairCount; i++) {
            setRowShowL(i);
            setRowShowS(i);
         }

      } else 
       // new Buy Order
      if ((0 <= StringFind(sparam, "BtnPlusOrdL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnPlusOrdL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            // 2个以上模式选择的时候
            if (  (rowInfo.GridModeL() && rowInfo.RetraceModeL())
               || (rowInfo.GridModeL() && rowInfo.OtherModeL())
               || (rowInfo.RetraceModeL() && rowInfo.OtherModeL())) {
               Alert("只能选一个");
            } else if (!rowInfo.GridModeL() && !rowInfo.RetraceModeL() && !rowInfo.OtherModeL()) {
               Alert("必须而且只能选一个");
            } else {
               string msg = "Are you sure to open a long position?";
               if (IDOK == MessageBox(msg, "Open a Long Position", MB_OKCANCEL)) {
                  double slPrice=0.0, tpPrice=0.0, openPrice=SymbolInfoDouble(rowInfo.SymbolNm(),SYMBOL_ASK);
                  if (rowInfo.EnableSlL()) slPrice = openPrice - rowInfo.SlPrice();
                  if (rowInfo.EnableTpL()) tpPrice = openPrice + rowInfo.TpPrice();
                  string comment = CommentM;
                  if (rowInfo.GridModeL()) comment = CommentMG; else if (rowInfo.RetraceModeL()) comment = CommentMR;
                  if (trade.Buy(rowInfo.LotsL(), rowInfo.SymbolNm(), openPrice, slPrice, tpPrice, comment)) {
                     trade.Result(TradeResult);
                     if (rowInfo.EnableGrid() && rowInfo.GridModeL()) {
                        rowInfo.Add2OrdersGridL(TradeResult.order, comment);
                     } else if (rowInfo.EnableRetrace() && rowInfo.RetraceModeL()) {
                        rowInfo.Add2OrdersRetraceL(TradeResult.order, comment);
                     } else {
                        rowInfo.Add2OrdersL(TradeResult.order, comment);
                     }
                  }
               }
            }
            
         } else if (rowInfo.SingularModeL()) {
            int cnt = rowInfo.OrdCntL()+1;
            rowInfo.OrdCntL(cnt);
         }
         setRowShowL(index);
         //ChartRedraw();
      } else 
      // new Sell Order
      if ((0 <= StringFind(sparam, "BtnPlusOrdS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnPlusOrdS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            // 2个以上模式选择的时候
            if (  (rowInfo.GridModeS() && rowInfo.RetraceModeS())
               || (rowInfo.GridModeS() && rowInfo.OtherModeS())
               || (rowInfo.RetraceModeS() && rowInfo.OtherModeS())) {
               Alert("只能选一个");
            } else if (!rowInfo.GridModeS() && !rowInfo.RetraceModeS() && !rowInfo.OtherModeS()) {
               Alert("必须而且只能选一个");
            } else {
               string msg = "Are you sure to open a short position?";
               if (IDOK == MessageBox(msg, "Open a Short Position", MB_OKCANCEL)) {
                  double slPrice=0.0, tpPrice=0.0, openPrice=SymbolInfoDouble(rowInfo.SymbolNm(),SYMBOL_BID);
                  if (rowInfo.EnableSlS()) slPrice = openPrice + rowInfo.SlPrice();
                  if (rowInfo.EnableTpS()) tpPrice = openPrice - rowInfo.TpPrice();
                  string comment = CommentM;
                  if (rowInfo.GridModeS()) comment = CommentMG; else if (rowInfo.RetraceModeS()) comment = CommentMR;
                  if (trade.Sell(rowInfo.LotsS(), rowInfo.SymbolNm(), openPrice, slPrice, tpPrice, comment)) {
                     trade.Result(TradeResult);
                     if (rowInfo.EnableGrid() && rowInfo.GridModeS()) {
                        rowInfo.Add2OrdersGridS(TradeResult.order, comment);
                     } else if (rowInfo.EnableRetrace() && rowInfo.RetraceModeS()) {
                        rowInfo.Add2OrdersRetraceS(TradeResult.order, comment);
                     } else {
                        rowInfo.Add2OrdersS(TradeResult.order, comment);
                     }
                  }
               }
            }
         } else if (rowInfo.SingularModeS()) {
            int cnt = rowInfo.OrdCntS()+1;
            rowInfo.OrdCntS(cnt);
         }
         
         setRowShowS(index);
         //ChartRedraw();
      } else 
      if ((0 <= StringFind(sparam, "BtnMinusOrdL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusOrdL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.SingularModeL()) {
            int cnt = rowInfo.OrdCntL()-1;
            if (0 <= cnt) {
               rowInfo.OrdCntL(cnt);
            }
            setRowShowL(index);
         }
      } else 
      if ((0 <= StringFind(sparam, "BtnMinusOrdS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusOrdS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.SingularModeS()) {
            int cnt = rowInfo.OrdCntS()-1;
            if (0 <= cnt) {
               rowInfo.OrdCntS(cnt);
            }
            setRowShowS(index);
         }
      } else 
      // Close Positive Buy Order(C+/L+)
      if ((0 <= StringFind(sparam, "BtnClosePositiveL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnClosePositiveL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            double lots = rowInfo.LotsL()+rowInfo.LotStep();
            rowInfo.LotsL(lots);
            rowInfo.refreshL();
            refreshRowDataShowL(index);
            //ObjectSetString(0,"LblLotsL"+IntegerToString(index),OBJPROP_TEXT,formatLot(lots, 1));
         } else {
            if (rowInfo.SingularModeL()) {
               ulong ticket = rowInfo.getTicketL();
               if (0.001 < rowInfo.ProfitL()) {
                  if (trade.PositionClose(ticket)) {
                     //rowInfo.DeleteOrderL(ticket);
                     Print("Long Positive profit position@", ticket, " is closed.");
                  }
               }
            } else {
               closeOrdersByProfit(true, rowInfo.SymbolNm(), POSITION_TYPE_BUY);
            }
         }
      } else
      // Close Positive Sell Order(C+/L+)
      if ((0 <= StringFind(sparam, "BtnClosePositiveS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnClosePositiveS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            double lots = rowInfo.LotsS()+rowInfo.LotStep();
            rowInfo.LotsS(lots);
            rowInfo.refreshS();
            refreshRowDataShowS(index);
            //ObjectSetString(0,"LblLotsS"+IntegerToString(index),OBJPROP_TEXT,formatLot(lots, 1));
         } else {
            if (rowInfo.SingularModeS()) {
               ulong ticket = rowInfo.getTicketS();
               if (0.001 < rowInfo.ProfitS()) {
                  if (trade.PositionClose(ticket)) {
                     //rowInfo.DeleteOrderL(ticket);
                     Print("Short Positive profit position@", ticket, " is closed.");
                  }
               }
            } else {
               closeOrdersByProfit(true, rowInfo.SymbolNm(), POSITION_TYPE_SELL);
            }
         }
      } else 
      // Close Negative Buy Order(C-/L-)
      if ((0 <= StringFind(sparam, "BtnCloseNegativeL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnCloseNegativeL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            double lots = rowInfo.LotsL()-rowInfo.LotStep();
            rowInfo.LotsL(lots);
            rowInfo.refreshL();
            refreshRowDataShowL(index);
            //ObjectSetString(0,"LblLotsL"+IntegerToString(index),OBJPROP_TEXT,formatLot(lots, 1));
         } else {
            if (rowInfo.SingularModeL()) {
               ulong ticket = rowInfo.getTicketL();
               if (rowInfo.ProfitL() < 0.01) {
                  if (trade.PositionClose(ticket)) {
                     //rowInfo.DeleteOrderL(ticket);
                     Print("Long Negative profit position@", ticket, " is closed.");
                  }
               }
            } else {
               closeOrdersByProfit(false, rowInfo.SymbolNm(), POSITION_TYPE_BUY);
            }
         }
      } else
      // Close Negative Sell Order(C-/L-)
      if ((0 <= StringFind(sparam, "BtnCloseNegativeS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnCloseNegativeS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            double lots = rowInfo.LotsS()-rowInfo.LotStep();
            rowInfo.LotsS(lots);
            rowInfo.refreshS();
            refreshRowDataShowS(index);
            //ObjectSetString(0,"LblLotsS"+IntegerToString(index),OBJPROP_TEXT,formatLot(lots, 1));
         } else {
            if (rowInfo.SingularModeS()) {
               ulong ticket = rowInfo.getTicketS();
               if (rowInfo.ProfitS() < 0.01) {
                  if (trade.PositionClose(ticket)) {
                     //rowInfo.DeleteOrderL(ticket);
                     Print("Short Negative profit position@", ticket, " is closed.");
                  }
               }
            } else {
               closeOrdersByProfit(false, rowInfo.SymbolNm(), POSITION_TYPE_SELL);
            }
         }
      } else 
      // Close Buy Order
      if ((0 <= StringFind(sparam, "BtnCloseL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnCloseL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.SingularModeL()) {
            ulong ticket = rowInfo.getTicketL();
            if (trade.PositionClose(ticket)) {
               //rowInfo.DeleteOrderL(ticket);
               Print("Long position@", ticket, " is closed.");
            }
         } else {
            closeOrders(rowInfo.SymbolNm(), POSITION_TYPE_BUY);
         }
         
      } else
      // Close Sell Order
      if ((0 <= StringFind(sparam, "BtnCloseS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnCloseS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.SingularModeS()) {
            ulong ticket = rowInfo.getTicketS();
            if (trade.PositionClose(ticket)) {
               //rowInfo.DeleteOrderS(ticket);
               Print("Short position@", ticket, " is closed.");
            }
         } else {
            closeOrders(rowInfo.SymbolNm(), POSITION_TYPE_SELL);
         }
      } else
      // Close Long and Short Order
      if ((0 <= StringFind(sparam, "BtnCloseLS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnCloseLS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         trade.PositionClose(rowInfo.SymbolNm());
      } else
      // Set EnableTpL
      if ((0 <= StringFind(sparam, "BtnEnableTpL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnEnableTpL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.EnableTpL()) {
            rowInfo.EnableTpL(false);
            disableButton(sparam);
         } else {
            rowInfo.EnableTpL(true);
            enableButton(sparam);
         }
         //ChartRedraw();
      } else
      // Set EnableTpS
      if ((0 <= StringFind(sparam, "BtnEnableTpS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnEnableTpS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.EnableTpS()) {
            rowInfo.EnableTpS(false);
            disableButton(sparam);
         } else {
            rowInfo.EnableTpS(true);
            enableButton(sparam);
         }
         //ChartRedraw();
      } else
      // Set EnableSlL
      if ((0 <= StringFind(sparam, "BtnEnableSlL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnEnableSlL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.EnableSlL()) {
            rowInfo.EnableSlL(false);
            disableButton(sparam);
         } else {
            rowInfo.EnableSlL(true);
            enableButton(sparam);
         }
         //ChartRedraw();
      } else
      // Set EnableSlS
      if ((0 <= StringFind(sparam, "BtnEnableSlS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnEnableSlS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.EnableSlS()) {
            rowInfo.EnableSlS(false);
            disableButton(sparam);
         } else {
            rowInfo.EnableSlS(true);
            enableButton(sparam);
         }
         //ChartRedraw();
      } else
      // Set SingularModeL
      if ((0 <= StringFind(sparam, "BtnSingularModeL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnSingularModeL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.SingularModeL()) {
            if (!rowInfo.TradeModeL()) {
               rowInfo.SingularModeL(false);
               rowInfo.GridModeS(true);
               rowInfo.RetraceModeS(true);
               rowInfo.OtherModeS(true);
            }
         } else {
            rowInfo.SingularModeL(true);
            rowInfo.GridModeL(false);
            rowInfo.RetraceModeL(false);
            rowInfo.OtherModeL(true);
            rowInfo.OrdCntL(rowInfo.getCountL());
         }
         //rowInfo.refreshL();
         setRowShowL(index);
         //ChartRedraw();
      } else
      // Set TradeModeL
      if ((0 <= StringFind(sparam, "BtnTradeModeL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnTradeModeL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            rowInfo.TradeModeL(false);
            rowInfo.OrdCntL(rowInfo.getCountL());
            Print("OrdCntL==", rowInfo.OrdCntL());
         } else {
            rowInfo.LotsL(rowInfo.InitLotSize());
            rowInfo.TradeModeL(true);
            rowInfo.SingularModeL(true);
            rowInfo.GridModeL(false);
            rowInfo.RetraceModeL(false);
            rowInfo.OtherModeL(true);
         }
         //rowInfo.refreshL();
         //Print("OrdCntL==", rowInfo.OrdCntL());
         //Print("LotsL==", rowInfo.LotsL());
         //Print("ProfitL==", rowInfo.ProfitL());
         setRowShowL(index);
         //ChartRedraw();
      } else
      // Set SingularModeS
      if ((0 <= StringFind(sparam, "BtnSingularModeS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnSingularModeS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.SingularModeS()) {
            if (!rowInfo.TradeModeS()) {
               rowInfo.SingularModeS(false);
               rowInfo.GridModeS(true);
               rowInfo.RetraceModeS(true);
               rowInfo.OtherModeS(true);
            }
            
         } else {
            rowInfo.SingularModeS(true);
            rowInfo.GridModeS(false);
            rowInfo.RetraceModeS(false);
            rowInfo.OtherModeS(true);
         }
         //rowInfo.refreshS();
         setRowShowS(index);
         //ChartRedraw();
      } else
      // Set TradeModeS
      if ((0 <= StringFind(sparam, "BtnTradeModeS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnTradeModeS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            rowInfo.TradeModeS(false);
            rowInfo.OrdCntS(rowInfo.getCountS());
         } else {
            rowInfo.LotsS(rowInfo.InitLotSize());
            rowInfo.TradeModeS(true);
            rowInfo.SingularModeS(true);
            rowInfo.GridModeS(false);
            rowInfo.RetraceModeS(false);
            rowInfo.OtherModeS(true);
         }
         //rowInfo.refreshS();
         setRowShowS(index);
         //ChartRedraw();;
         
      } else
      // Set GridModeL
      if ((0 <= StringFind(sparam, "BtnGridModeL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnGridModeL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         
         if (rowInfo.SingularModeL()) {
            rowInfo.GridModeL(true);
            rowInfo.RetraceModeL(false);
            rowInfo.OtherModeL(false);
            rowInfo.OrdCntL(rowInfo.getCountGridL());
         } else {
            if (rowInfo.GridModeL()) {
               rowInfo.GridModeL(false);
            } else {
               rowInfo.GridModeL(true);
            }
         }
         setRowShowL(index);
         //ChartRedraw();
      } else
      // Set RetraceModeL
      if ((0 <= StringFind(sparam, "BtnRetraceModeL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnRetraceModeL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         
         if (rowInfo.SingularModeL()) {
            rowInfo.RetraceModeL(true);
            rowInfo.GridModeL(false);
            rowInfo.OtherModeL(false);
            rowInfo.OrdCntL(rowInfo.getCountRetraceL());
         } else {
            if (rowInfo.RetraceModeL()) {
               rowInfo.RetraceModeL(false);
            } else {
               rowInfo.RetraceModeL(true);
            }
         }
         setRowShowL(index);
         //ChartRedraw();
      } else
      // Set OtherModeL
      if ((0 <= StringFind(sparam, "BtnOtherModeL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnOtherModeL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         
         if (rowInfo.SingularModeL()) {
            rowInfo.OtherModeL(true);
            rowInfo.RetraceModeL(false);
            rowInfo.GridModeL(false);
            rowInfo.OrdCntL(rowInfo.getCountL());
         } else {
            if (rowInfo.OtherModeL()) {
               rowInfo.OtherModeL(false);
            } else {
               rowInfo.OtherModeL(true);
            }
         }
         setRowShowL(index);
         //ChartRedraw();
      } else
      // Set GridModeS
      if ((0 <= StringFind(sparam, "BtnGridModeS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnGridModeS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         
         if (rowInfo.SingularModeS()) {
            rowInfo.GridModeS(true);
            rowInfo.RetraceModeS(false);
            rowInfo.OtherModeS(false);
         } else {
            if (rowInfo.GridModeS()) {
               rowInfo.GridModeS(false);
            } else {
               rowInfo.GridModeS(true);
            }
         }
         setRowShowS(index);
         //ChartRedraw();
      } else
      // Set RetraceModeS
      if ((0 <= StringFind(sparam, "BtnRetraceModeS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnRetraceModeS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         
         if (rowInfo.SingularModeS()) {
            rowInfo.RetraceModeS(true);
            rowInfo.GridModeS(false);
            rowInfo.OtherModeS(false);
         } else {
            if (rowInfo.RetraceModeS()) {
               rowInfo.RetraceModeS(false);
            } else {
               rowInfo.RetraceModeS(true);
            }
         }
         setRowShowS(index);
         //ChartRedraw();
      } else
      // Set OtherModeS
      if ((0 <= StringFind(sparam, "BtnOtherModeS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnOtherModeS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         
         if (rowInfo.SingularModeS()) {
            rowInfo.OtherModeS(true);
            rowInfo.RetraceModeS(false);
            rowInfo.GridModeS(false);
         } else {
            if (rowInfo.OtherModeS()) {
               rowInfo.OtherModeS(false);
            } else {
               rowInfo.OtherModeS(true);
            }
         }
         setRowShowS(index);
         //ChartRedraw();
      } else
      // Set EnableGrid
      if ((0 <= StringFind(sparam, "BtnEnableGrid"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnEnableGrid")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.EnableGrid()) {
            rowInfo.EnableGrid(false);
            disableButton(sparam);
         } else {
            rowInfo.EnableGrid(true);
            enableButton(sparam);
         }
         //ChartRedraw();
      } else
      // Set EnableRetrace
      if ((0 <= StringFind(sparam, "BtnEnableRetrace"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnEnableRetrace")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.EnableRetrace()) {
            rowInfo.EnableRetrace(false);
            disableButton(sparam);
         } else {
            rowInfo.EnableRetrace(true);
            enableButton(sparam);
         }
         //ChartRedraw();
      } else
      // Set AddTpL
      if ((0 <= StringFind(sparam, "BtnAddTpL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnAddTpL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            ushort pips = rowInfo.TpPips()+1;
            rowInfo.TpPips(pips);
            rowInfo.refreshL();
            refreshRowDataShowL(index);
            //ObjectSetString(0,"LblTp2Bid"+IntegerToString(index),OBJPROP_TEXT,formatPip(pips, 1));
         } else {
         
         }
      } else
      // Set AddTpS
      if ((0 <= StringFind(sparam, "BtnAddTpS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnAddTpS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            ushort pips = rowInfo.TpPips()+1;
            rowInfo.TpPips(pips);
            rowInfo.refreshS();
            refreshRowDataShowS(index);
         } else {
         
         }
      } else
      // Set MinusTpL
      if ((0 <= StringFind(sparam, "BtnMinusTpL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusTpL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            ushort pips = rowInfo.TpPips()-1;
            rowInfo.TpPips(pips);
            rowInfo.refreshL();
            refreshRowDataShowL(index);
            //ObjectSetString(0,"LblTp2Bid"+IntegerToString(index),OBJPROP_TEXT,formatPip(pips, 1));
         } else {
         
         }
      } else
      // Set MinusTpS
      if ((0 <= StringFind(sparam, "BtnMinusTpS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusTpS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            ushort pips = rowInfo.TpPips()-1;
            rowInfo.TpPips(pips);
            rowInfo.refreshS();
            refreshRowDataShowS(index);
         } else {
         
         }
      } else
      // Set AddSlL
      if ((0 <= StringFind(sparam, "BtnAddSlL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnAddSlL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            ushort pips = rowInfo.SlPips()+1;
            rowInfo.SlPips(pips);
            rowInfo.refreshL();
            refreshRowDataShowL(index);
            //ObjectSetString(0,"LblTp2Bid"+IntegerToString(index),OBJPROP_TEXT,formatPip(pips, 1));
         } else {
         
         }
      } else
      // Set AddSlS
      if ((0 <= StringFind(sparam, "BtnAddSlS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnAddSlS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            ushort pips = rowInfo.SlPips()+1;
            rowInfo.SlPips(pips);
            rowInfo.refreshS();
            refreshRowDataShowS(index);
            //ObjectSetString(0,"LblTp2Bid"+IntegerToString(index),OBJPROP_TEXT,formatPip(pips, 1));
         } else {
         
         }
      } else
      // Set MinusSlL
      if ((0 <= StringFind(sparam, "BtnMinusSlL"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusSlL")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeL()) {
            ushort pips = rowInfo.SlPips()-1;
            rowInfo.SlPips(pips);
            rowInfo.refreshL();
            refreshRowDataShowL(index);
            //ObjectSetString(0,"LblTp2Bid"+IntegerToString(index),OBJPROP_TEXT,formatPip(pips, 1));
         } else {
         
         }
      } else
      // Set MinusSlS
      if ((0 <= StringFind(sparam, "BtnMinusSlS"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusSlS")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         if (rowInfo.TradeModeS()) {
            ushort pips = rowInfo.SlPips()-1;
            rowInfo.SlPips(pips);
            rowInfo.refreshS();
            refreshRowDataShowS(index);
            //ObjectSetString(0,"LblTp2Bid"+IntegerToString(index),OBJPROP_TEXT,formatPip(pips, 1));
         } else {
         
         }
      } else
      // Set PlusGrid
      if ((0 <= StringFind(sparam, "BtnPlusGrid"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnPlusGrid")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         ushort pips = rowInfo.GridPips()+1;
         rowInfo.GridPips(pips);
         //rowInfo.refreshL();
         //refreshRowDataShowL(index);
         ObjectSetString(0,"LblGridPips"+IntegerToString(index),OBJPROP_TEXT,IntegerToString(pips, 3));
      } else
      // Set MinusGrid
      if ((0 <= StringFind(sparam, "BtnMinusGrid"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusGrid")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         ushort pips = rowInfo.GridPips()-1;
         rowInfo.GridPips(pips);
         //rowInfo.refreshL();
         //refreshRowDataShowL(index);
         ObjectSetString(0,"LblGridPips"+IntegerToString(index),OBJPROP_TEXT,IntegerToString(pips, 3));
      } else
      // Set PlusRetrace
      if ((0 <= StringFind(sparam, "BtnPlusRetrace"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnPlusRetrace")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         ushort pips = rowInfo.RetracePips()+1;
         rowInfo.RetracePips(pips);
         //rowInfo.refreshL();
         //refreshRowDataShowL(index);
         ObjectSetString(0,"LblRetracePips"+IntegerToString(index),OBJPROP_TEXT,IntegerToString(pips, 3));
      } else
      // Set MinusRetrace
      if ((0 <= StringFind(sparam, "BtnMinusRetrace"))) {
         index = (int) StringToInteger(StringSubstr(sparam, StringLen("BtnMinusRetrace")));
         CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
         ushort pips = rowInfo.RetracePips()-1;
         rowInfo.RetracePips(pips);
         //rowInfo.refreshL();
         //refreshRowDataShowL(index);
         ObjectSetString(0,"LblRetracePips"+IntegerToString(index),OBJPROP_TEXT,IntegerToString(pips, 3));
      }
      
      Print(sparam);
      //if (0 <= index) refreshRow(index);
      ChartRedraw();
   }
   
}

void OnBookEvent(const string &symbol) {

}
bool isOk4Filter(CRowInfo *rowInfo) {
   //Print("FilterBySpread=", FilterBySpread, " rowInfo.Spread()", rowInfo.Spread());
   if (FilterBySpread) {
      if (SpreadLimit____ < rowInfo.Spread()) {
         return false;
      }
   }
   
   return true;
}
/*
bool hasSignal(const char& pins[], const char signalType) {
   for (int i=0; i<PinsCount; i++) {
      if (UsePins[i] && signalType != pins[i]) return false;
   }
   return true;
}
*/
void setSignalShow(CRowInfo *rowInfo, int index) {
   color clrBgSignalL = clrGreen;
   color clrBgSignalS = clrCrimson;
   color clrBgSignalN = clrBlack;
   string objName;
   if (rowInfo.HasSignalL()) {
      objName = getObjectName(index, EAX_COL_SymbolN);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalL);
      objName = getObjectName(index, EAX_COL_PlusOrdL);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalL);
      objName = getObjectName(index, EAX_COL_PlusOrdS);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalN);
   } else if (rowInfo.HasSignalS()) {
      objName = getObjectName(index, EAX_COL_SymbolN);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalS);
      objName = getObjectName(index, EAX_COL_PlusOrdL);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalN);
      objName = getObjectName(index, EAX_COL_PlusOrdS);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalS);
   } else {
      objName = getObjectName(index, EAX_COL_SymbolN);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalN);
      objName = getObjectName(index, EAX_COL_PlusOrdL);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalN);
      objName = getObjectName(index, EAX_COL_PlusOrdS);
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBgSignalN);
   }
}
void setLblPinShow(string objName, char signalType) {
   if (Signal_Long == signalType) {
      ObjectSetString( 0,objName,OBJPROP_TEXT, Txt_Pin_Signal_Long);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrLblPinFontSignalL);
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_COLOR,  clrLblPinBorderSignalL);
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,clrLblPinBgSignalL);
   } else if (Signal_Short == signalType) {
      ObjectSetString( 0,objName,OBJPROP_TEXT, Txt_Pin_Signal_Short);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrLblPinFontSignalS);
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_COLOR,  clrLblPinBorderSignalS);
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,clrLblPinBgSignalS);
   } else {
      ObjectSetString( 0,objName,OBJPROP_TEXT, Txt_Pin_Signal_None);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrLblPinFontSignalN);
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_COLOR,  clrLblPinBorderSignalN);
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,clrLblPinBgSignalN);
   }
   
}
bool hasUseAnyPin() {
   for (int i=0; i<PinsCount; i++) {
      if (UsePins[i]) return true;
   }
   return false;
}
void readPins() {
   string gvName;
   string symbolName;
   char signalTypes[] = {Signal_Long, Signal_Swing, Signal_Short};
   int signalTypeCount = ArraySize(signalTypes);
   bool useAnyPin = hasUseAnyPin();
   for (int i=0; i<pairCount; i++) {
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(i);
      symbolName = rowInfo.SymbolN();
      bool hasSignalTypes[] = {true, true, true};
      for (int j=0; j<PinsCount; j++) {
         gvName = symbolName + "pin" + IntegerToString(j+1);
         if (GlobalVariableCheck(gvName)) rowInfo.SetPin(char (GlobalVariableGet(gvName)), j);
         else rowInfo.SetPin(Signal_None, j);
         setLblPinShow("LblPIN"+IntegerToString(j+1)+IntegerToString(i), rowInfo.GetPin(j));
         if (!useAnyPin) continue;
         for (int k=0; k<signalTypeCount; k++) {
            //Print(symbolName, " gvName=", gvName, " signalTypes[k]=", signalTypes[k], " rowInfo.GetPin(",j, ")=", rowInfo.GetPin(j), " UsePins[j]=", UsePins[j]);
            if (UsePins[j] && signalTypes[k] != rowInfo.GetPin(j)) hasSignalTypes[k]=false;
         }
      }
      //Print(hasSignalTypes[0], hasSignalTypes[1], hasSignalTypes[2]);
      rowInfo.HasSignalL(false);
      rowInfo.HasSignalS(false);
      if (useAnyPin) {
         //Print(symbolName, " isOk4Filter(rowInfo)==", isOk4Filter(rowInfo), " useAnyPin=", useAnyPin);
         if (isOk4Filter(rowInfo)) {
            rowInfo.HasSignalL(hasSignalTypes[0]);
            rowInfo.HasSignalS(hasSignalTypes[2]);
         }
      }
      setSignalShow(rowInfo, i);
      //Print(symbolName, " Pin1=", rowInfo.GetPin(0), " Pin2=", rowInfo.GetPin(1), " Pin3=", rowInfo.GetPin(2), " Pin4=", rowInfo.GetPin(3), " Pin5=", rowInfo.GetPin(4), " Pin6=", rowInfo.GetPin(5), " Pin7=", rowInfo.GetPin(6), " Pin8=", rowInfo.GetPin(7), " Pin9=", rowInfo.GetPin(8), " SignalL=", rowInfo.HasSignalL(), " SignalS=", rowInfo.HasSignalS());
   }
}

/*Position:有效单    Order:挂单*/
void loadOrders() {
   int total=PositionsTotal();
   //ulong ticket;
   ENUM_POSITION_TYPE orderType;
   //double openPrice,sl,tp,profit,lots,profitL=0.0,profitS=0.0,lotsL=0.0,lotsS=0.0;
   int index;
   string pairName, orderComment;
   //Print("total==", total);
   for(int i=0; i<total; i++) {
      ulong ticket = PositionGetTicket(i);
      //Print("ticket==", ticket);
      if (0 == ticket) continue;
      //Print("===2");
      if (MagicNumber != PositionGetInteger(POSITION_MAGIC)) continue;
      //Print("===3");
      pairName = PositionGetString(POSITION_SYMBOL);
      if (!Pair2IndexMap.TryGetValue(pairName, index)) continue;
      //Print("===4");
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
      //openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      orderType = ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));
      //lots = OrderGetDouble(ORDER_VOLUME_CURRENT);
      //if (!OrderCalcProfit(orderType, pairName, lots, openPrice, OrderGetDouble(ORDER_PRICE_CURRENT), profit)) continue;
      orderComment = PositionGetString(POSITION_COMMENT);

      //if (ORDER_TYPE_BUY  == orderType) rowInfo.Add2OrdersL(ticket, orderComment);
      //if (ORDER_TYPE_SELL == orderType) rowInfo.Add2OrdersS(ticket, orderComment);
      //Print("===5");
      if (CommentA == orderComment || CommentM == orderComment) {
         Print("ticket==", ticket, "||orderComment==", orderComment);
         if (POSITION_TYPE_BUY  == orderType) rowInfo.Add2OrdersL(ticket, orderComment);
         if (POSITION_TYPE_SELL == orderType) rowInfo.Add2OrdersS(ticket, orderComment);
      } else
      if (CommentAG == orderComment || CommentMG == orderComment) {
         if (POSITION_TYPE_BUY  == orderType) rowInfo.Add2OrdersGridL(ticket, orderComment);
         if (POSITION_TYPE_SELL == orderType) rowInfo.Add2OrdersGridS(ticket, orderComment);
      } else {
      //if (CommentAR == orderComment || CommentMR == orderComment) {
         if (POSITION_TYPE_BUY  == orderType) rowInfo.Add2OrdersRetraceL(ticket, orderComment);
         if (POSITION_TYPE_SELL == orderType) rowInfo.Add2OrdersRetraceS(ticket, orderComment);
      }
      //Print("===6");
      //sl = OrderGetDouble(ORDER_SL);
      //tp = OrderGetDouble(ORDER_TP);
   }

}

void setShow(string objName, string text="", color bgColor=clrNONE, color textColor=clrNONE) {
   if ("" != text) ObjectSetString( 0,objName,OBJPROP_TEXT,text);
   if (clrNONE != bgColor) ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,bgColor);
   if (clrNONE != textColor) ObjectSetInteger(0,objName,OBJPROP_COLOR,textColor);
}

bool isOnly1Show() {
   int cnt = MaxOrdersPerSymbol____;
   if (UseGrid____) cnt += GridMaxTimesPerSymbol____;
   if (UseRetrace____) cnt += RetraceMaxTimesPerSymbol____;
   if (1 < cnt) return false;
   return true;
}

bool isOnlyOther() {
   if (ShowGridSets) return false;
   if (UseGrid____) return false;
   if (ShowRetraceSets) return false;
   if (UseRetrace____) return false;
   return true;
}

void setBtnSingularMode(string objName, bool isSingularMode, bool isTradeMode, int OrdCnt, bool hasSignal) {
      if (isSingularMode) ObjectSetString(0,objName,OBJPROP_TEXT,"Singular");
      else ObjectSetString(0,objName,OBJPROP_TEXT,"Plural");
      
      if (isTradeMode) {
         enableButtonTradeMode(objName, clrBlue);
      } else if (OrdCnt < 1 && hasSignal) {
         disableButtonNoDataHasSignal(objName);
      } else if (OrdCnt < 1 && !hasSignal) {
         disableButtonNoDataNoSignal(objName);
      } else if (isSingularMode) {
         enableButtonSingularMode(objName);
      } else {
         enableButtonPluralMode(objName);
      }
}

void setBtnTradeMode(string objName, bool isSingularMode, bool isTradeMode, int OrdCnt, bool hasSignal) {
      if (isTradeMode) ObjectSetString(0,objName,OBJPROP_TEXT,"Trade");
      else ObjectSetString(0,objName,OBJPROP_TEXT,"Data");
      
      if (isTradeMode) {
         enableButtonTradeMode(objName);
      } else if (OrdCnt < 1 && hasSignal) {
         disableButtonNoDataHasSignal(objName);
      } else if (OrdCnt < 1 && !hasSignal) {
         disableButtonNoDataNoSignal(objName);
      } else if (isSingularMode) {
         enableButtonSingularMode(objName);
      } else {
         enableButtonPluralMode(objName);
      }
}

void setBtnGROMode(string objName, bool isGROMode, int OrdCnt, bool hasSignal) {
   if (OrdCnt < 1) {
      if (hasSignal) {
         disableButtonNoDataHasSignal(objName, clrYellow);
         ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrAqua);
      } else {
         disableButtonNoDataNoSignal(objName);
         ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrSilver);
      }
   } else {
      if (isGROMode) {
         enableButton(objName, clrAqua, clrBlack);
         ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrSilver);
      } else {
         disableButton(objName, clrDimGray, clrWhite);
         ObjectSetInteger(0,objName,OBJPROP_BORDER_COLOR,clrSilver);
      }
   }
}

void setBtnClosePositive(string objName, bool isTradeMode, double profit) {
   if (isTradeMode) {
      ObjectSetString(0,objName,OBJPROP_TEXT,"L+");
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,bgTradeColor);
   } else {
      ObjectSetString(0,objName,OBJPROP_TEXT,"C+");
      if (0.001 < profit) {
         ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrGreen);
      } else {
         ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,bgNoDataColor);
      }
   }
}

void setBtnCloseNegative(string objName, bool isTradeMode, double profit) {
   if (isTradeMode) {
      ObjectSetString(0,objName,OBJPROP_TEXT,"L-");
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,bgTradeColor);
   } else {
      ObjectSetString(0,objName,OBJPROP_TEXT,"C -");
      if (profit < 0.0) {
         ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrMaroon);
      } else {
         ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,bgNoDataColor);
      }
   }
}

void setBtnActivity(string objName, bool isActive) {
   if (isActive) {
      enableButton(objName);
   } else {
      disableButton(objName);
   }
}
void setLblDataShow(string objName, bool isTradeMode, bool isSingularMode, int OrdCnt) {
   //ObjectSetString(0,objName,OBJPROP_TEXT,text);
   if (isTradeMode) {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgTradeColor);
   } else if (OrdCnt < 1) {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   } else if (isSingularMode) {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgSingularColor);
   } else {
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgPluralColor);
   }
}
void refreshRowDataShowL(const int rowId) {
   string objName;
   CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(rowId);

   objName = getObjectName(rowId, EAX_COL_OrdCntL);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatOrderCount(rowInfo.OrdCntL()));
   /*
   if (!rowInfo.SingularModeL()) {
      if (rowInfo.GridModeL() && !rowInfo.RetraceModeL() && !rowInfo.OtherModeL()) {
         if (rowInfo.GridMaxTimes() <= rowInfo.getCountGridL()) {
            ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,clrOrangeRed);
         }
      } else if (!rowInfo.GridModeL() && rowInfo.RetraceModeL() && !rowInfo.OtherModeL()) {
         if (rowInfo.RetraceMaxTimes() <= rowInfo.getCountRetraceL()) {
            ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,clrOrangeRed);
         }
      } else if (!rowInfo.GridModeL() && !rowInfo.RetraceModeL() && rowInfo.OtherModeL()) {
         if (rowInfo.MaxOrders() <= rowInfo.getCountL()) {
            ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,clrOrangeRed);
         }
      } else {
         if (rowInfo.OrdCntL() < 1) {
            ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
         } else {
            ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgPluralColor);
         }
      }
   } else {
      setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL());
   }
   */
   /*
   if (rowInfo.TradeModeL()) {
      ObjectSetString(0,objName,OBJPROP_TEXT,"1");
   } else {
      ObjectSetString(0,objName,OBJPROP_TEXT,formatOrderCount(rowInfo.OrdCntL()));
   }
   */
   
   if (ShowRetraceSets) {
      objName = getObjectName(rowId, EAX_COL_ProfitLMinus);
      ObjectSetString(0,objName,OBJPROP_TEXT,formatProfit(rowInfo.ProfitLMinus(), rowInfo.OrdCntL()));
      /*
      if (rowInfo.TradeModeL()) {
         ObjectSetString(0,objName,OBJPROP_TEXT," ");
      } else {
         ObjectSetString(0,objName,OBJPROP_TEXT,formatProfit(rowInfo.ProfitLMinus(), rowInfo.OrdCntL()));
      }
      */
      //setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL(), formatProfit(rowInfo.ProfitLMinus(), rowInfo.OrdCntL()));
      /*
      if (rowInfo.TradeModeL()) {
         ObjectSetString(0,objName,OBJPROP_TEXT," ");
         ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
      }
      */
      /*
      if (rowInfo.TradeModeL()) {
         ObjectSetString(0,objName,OBJPROP_TEXT," ");
         ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
      } else if (rowInfo.OrdCntL() < 1) {
         ObjectSetString(0,objName,OBJPROP_TEXT," ");
         ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
      } else if (rowInfo.SingularModeL()) {
         ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgSingularColor);
      } else {
         ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgPluralColor);
      }
      */
   }
   
   objName = getObjectName(rowId, EAX_COL_LotsL);
   //setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL(), formatLot(rowInfo.LotsL(), rowInfo.OrdCntL()));
   ObjectSetString(0,objName,OBJPROP_TEXT,formatLot(rowInfo.LotsL(), rowInfo.OrdCntL()));
   
   objName = getObjectName(rowId, EAX_COL_ClosePositiveL);
   setBtnClosePositive(objName, rowInfo.TradeModeL(), rowInfo.ProfitL());
   
   objName = getObjectName(rowId, EAX_COL_ProfitL);
   //setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL(), formatProfit(rowInfo.ProfitL(), rowInfo.OrdCntL()));
   ObjectSetString(0,objName,OBJPROP_TEXT,formatProfit(rowInfo.ProfitL(), rowInfo.OrdCntL()));
   
   objName = getObjectName(rowId, EAX_COL_CloseNegativeL);
   setBtnCloseNegative(objName, rowInfo.TradeModeL(), rowInfo.ProfitL());
   
   objName = getObjectName(rowId, EAX_COL_Tp2OPL);
   //setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL(), formatPip(rowInfo.Tp2OPL(), rowInfo.OrdCntL()));
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Tp2OPL(), rowInfo.OrdCntL()));
   /*
   if (rowInfo.TradeModeL()) {
      ObjectSetString(0,objName,OBJPROP_TEXT," ");
      //ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   } else {
      ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Tp2OPL(), rowInfo.OrdCntL()));
   }
   */
   /*
   if (rowInfo.TradeModeL()) {
      ObjectSetString(0,objName,OBJPROP_TEXT," ");
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   } else if (rowInfo.OrdCntL() < 1) {
      ObjectSetString(0,objName,OBJPROP_TEXT," ");
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   } else if (rowInfo.SingularModeL()) {
      ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Tp2OPL(), rowInfo.OrdCntL()));
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgSingularColor);
   } else {
      ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Tp2OPL(), rowInfo.OrdCntL()));
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgPluralColor);
   }
   */
   
   objName = getObjectName(rowId, EAX_COL_Tp2Bid);
   //setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL(), formatPip(rowInfo.Tp2Bid(), rowInfo.OrdCntL()));
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Tp2Bid(), rowInfo.OrdCntL()));
   
   objName = getObjectName(rowId, EAX_COL_Sl2OPL);
   //setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL(), formatPip(rowInfo.Sl2OPL(), rowInfo.OrdCntL()));
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Sl2OPL(), rowInfo.OrdCntL()));
   /*
   if (rowInfo.TradeModeL()) {
      ObjectSetString(0,objName,OBJPROP_TEXT," ");
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   }
   /*
   if (rowInfo.TradeModeL()) {
      ObjectSetString(0,objName,OBJPROP_TEXT," ");
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   } else if (rowInfo.OrdCntL() < 1) {
      ObjectSetString(0,objName,OBJPROP_TEXT," ");
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgNoDataColor);
   } else if (rowInfo.SingularModeL()) {
      ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Sl2OPL(), rowInfo.OrdCntL()));
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgSingularColor);
   } else {
      ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Sl2OPL(), rowInfo.OrdCntL()));
      ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_BGCOLOR,bgPluralColor);
   }
   */
   
   objName = getObjectName(rowId, EAX_COL_Sl2Ask);
   //setLblDataShow(objName, rowInfo.TradeModeL(), rowInfo.SingularModeL(), rowInfo.OrdCntL(), formatPip(rowInfo.Sl2Ask(), rowInfo.OrdCntL()));
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Sl2Ask(), rowInfo.OrdCntL()));
   
}

void refreshRowDataShowS(const int rowId) {
   string objName;
   CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(rowId);

   objName = getObjectName(rowId, EAX_COL_OrdCntS);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatOrderCount(rowInfo.OrdCntS()));
   /*
   if (rowInfo.TradeModeS()) {
      ObjectSetString(0,objName,OBJPROP_TEXT,"1");
   } else {
      ObjectSetString(0,objName,OBJPROP_TEXT,formatOrderCount(rowInfo.OrdCntS()));
   }
   */
   
   if (ShowRetraceSets) {
      objName = getObjectName(rowId, EAX_COL_ProfitSMinus);
      ObjectSetString(0,objName,OBJPROP_TEXT,formatProfit(rowInfo.ProfitSMinus(), rowInfo.OrdCntS()));
   }
   
   objName = getObjectName(rowId, EAX_COL_LotsS);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatLot(rowInfo.LotsS(), rowInfo.OrdCntS()));
   
   objName = getObjectName(rowId, EAX_COL_ClosePositiveS);
   setBtnClosePositive(objName, rowInfo.TradeModeS(), rowInfo.ProfitS());
   
   objName = getObjectName(rowId, EAX_COL_ProfitS);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatProfit(rowInfo.ProfitS(), rowInfo.OrdCntS()));
   
   objName = getObjectName(rowId, EAX_COL_CloseNegativeS);
   setBtnCloseNegative(objName, rowInfo.TradeModeS(), rowInfo.ProfitS());
   
   objName = getObjectName(rowId, EAX_COL_Tp2OPS);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Tp2OPS(), rowInfo.OrdCntS()));
   
   objName = getObjectName(rowId, EAX_COL_Tp2Ask);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Tp2Ask(), rowInfo.OrdCntS()));
   
   objName = getObjectName(rowId, EAX_COL_Sl2OPS);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Sl2OPS(), rowInfo.OrdCntS()));
   
   objName = getObjectName(rowId, EAX_COL_Sl2Bid);
   ObjectSetString(0,objName,OBJPROP_TEXT,formatPip(rowInfo.Sl2Bid(), rowInfo.OrdCntS()));
   
}

void refreshRow(const int rowId) {
   string objName;
   CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(rowId);
   int chartId = 0;
   int cntOrderL = rowInfo.OrdCntL();
   int cntOrderS = rowInfo.OrdCntS();
   if (0 == cntOrderL && 0 == cntOrderS) {
      objName = getObjectName(rowId, EAX_COL_H);
      ObjectSetString(chartId, objName, OBJPROP_TEXT, "");
      
      objName = getObjectName(rowId, EAX_COL_D);
      ObjectSetString(chartId, objName, OBJPROP_TEXT, "");
      
      objName = getObjectName(rowId, EAX_COL_N);
      ObjectSetString(chartId, objName, OBJPROP_TEXT, "");
   }
   //int colId = 0;
   // H
   objName = getObjectName(rowId, EAX_COL_H);
   //ObjectSetString(chartId, objName, OBJPROP_TEXT, rowInfo.H());
   
   // D
   //colId++;
   objName = getObjectName(rowId, EAX_COL_D);
   
   // N
   //colId++;
   objName = getObjectName(rowId, EAX_COL_N);
   
   // Chart
   //colId++;
   
   // Pair
   //colId++;
   
   // MaxProfit
   //colId++;
   
   // MinProfit
   //colId++;
   refreshRowDataShowL(rowId);
   /*
   // SingularModeL
   objName = getObjectName(rowId, EAX_COL_SingularModeL);
   if (rowInfo.SingularModeL()) {enableButton(objName);} else {disableButton(objName);}
   
   // TradeModeL
   objName = getObjectName(rowId, EAX_COL_TradeModeL);
   if (rowInfo.TradeModeL()) {enableButton(objName);} else {disableButton(objName);}
   
   // GridModeL
   objName = getObjectName(rowId, EAX_COL_GridModeL);
   if (rowInfo.GridModeL()) {enableButton(objName);} else {disableButton(objName);}
   
   // RetraceModeL
   objName = getObjectName(rowId, EAX_COL_RetraceModeL);
   if (rowInfo.RetraceModeL()) {enableButton(objName);} else {disableButton(objName);}
   
   // OtherModeL
   objName = getObjectName(rowId, EAX_COL_OtherModeL);
   if (rowInfo.OtherModeL()) {enableButton(objName);} else {disableButton(objName);}
   
   // PlusOrdL
   //colId++;
   
   // OrdCntL
   //colId++;
   objName = getObjectName(rowId, EAX_COL_OrdCntL);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatOrderCount(cntOrderL));
   
   // MinusOrdL
   //colId++;
   
   // ProfitLMinus
   //colId++;
   
   // MinusMaxOrdL
   //colId++;
   
   // ProfitLMinusMax
   //colId++;
   
   // LotsL
   //colId++;
   objName = getObjectName(rowId, EAX_COL_LotsL);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatLot(rowInfo.LotsL(), cntOrderL));
   
   // ClosePositiveL
   //colId++;
   
   // ProfitL
   //colId++;
   objName = getObjectName(rowId, EAX_COL_ProfitL);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatProfit(rowInfo.ProfitL(), cntOrderL));
   
   // CloseNegativeL
   //colId++;
   
   // MaxProfitL
   //colId++;
   
   // MinProfitL
   //colId++;
   
   // CloseL
   //colId++;
   
   // Tp2OPL
   //colId++;
   objName = getObjectName(rowId, EAX_COL_Tp2OPL);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Tp2OPL(), cntOrderL));
   
   // EnableTpL
   //colId++;
   objName = getObjectName(rowId, EAX_COL_EnableTpL);
   if (rowInfo.EnableTpL()) {enableButton(objName);} else {disableButton(objName);}
   
   // AddTpL
   //colId++;
   
   // Tp2Bid
   objName = getObjectName(rowId, EAX_COL_Tp2Bid);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Tp2Bid(), cntOrderL));
   
   // MinusTpL
   //colId++;
   
   // Sl2OPL
   //colId++;
   objName = getObjectName(rowId, EAX_COL_Sl2OPL);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Sl2OPL(), cntOrderL));
   
   // EnableSlL
   //colId++;
   objName = getObjectName(rowId, EAX_COL_EnableSlL);
   if (rowInfo.EnableSlL()) {enableButton(objName);} else {disableButton(objName);}
   
   // AddSlL
   //colId++;
   
   // Sl2Ask
   objName = getObjectName(rowId, EAX_COL_Sl2Ask);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Sl2Ask(), cntOrderL));
   */
   // MinusSlL
   
   // SwapL
   objName = getObjectName(rowId, EAX_COL_SwapL);
   ObjectSetString(0, objName, OBJPROP_TEXT, formatSwap(rowInfo.SwapL()));
   if (rowInfo.SwapL() < 0.01) {
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrWhite);
   } else {
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrLime);
   }
   
   // Symbols
   

   
   
   // SwapS
   objName = getObjectName(rowId, EAX_COL_SwapS);
   ObjectSetString(0, objName, OBJPROP_TEXT, formatSwap(rowInfo.SwapS()));
   if (rowInfo.SwapS() < 0.01) {
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrWhite);
   } else {
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrLime);
   }
   refreshRowDataShowS(rowId);
   /*
   // SingularModeS
   objName = getObjectName(rowId, EAX_COL_SingularModeS);
   if (rowInfo.SingularModeS()) {enableButton(objName);} else {disableButton(objName);}
   
   // TradeModeS
   objName = getObjectName(rowId, EAX_COL_TradeModeS);
   if (rowInfo.TradeModeS()) {enableButton(objName);} else {disableButton(objName);}
   
   // GridModeS
   objName = getObjectName(rowId, EAX_COL_GridModeS);
   if (rowInfo.GridModeS()) {enableButton(objName);} else {disableButton(objName);}
   
   // RetraceModeS
   objName = getObjectName(rowId, EAX_COL_RetraceModeS);
   if (rowInfo.RetraceModeS()) {enableButton(objName);} else {disableButton(objName);}
   
   // OtherModeS
   objName = getObjectName(rowId, EAX_COL_OtherModeS);
   if (rowInfo.OtherModeS()) {enableButton(objName);} else {disableButton(objName);}
   
   // PlusOrdS
   // OrdCntS
   objName = getObjectName(rowId, EAX_COL_OrdCntS);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatOrderCount(cntOrderS));
   
   // MinusOrdS
   // ProfitSMinus
   // MinusMaxOrdS
   // ProfitSMinusMax
   // LotsS
   objName = getObjectName(rowId, EAX_COL_LotsS);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatLot(rowInfo.LotsS(), cntOrderS));
   // ClosePositiveS
   // ProfitS
   objName = getObjectName(rowId, EAX_COL_ProfitS);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatProfit(rowInfo.ProfitS(), cntOrderS));
   // CloseNegativeS
   // MaxProfitS
   // MinProfitS
   // CloseS
   // Tp2OPS
   objName = getObjectName(rowId, EAX_COL_Tp2OPS);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Tp2OPS(), cntOrderS));
   
   // EnableTpS
   objName = getObjectName(rowId, EAX_COL_EnableTpS);
   if (rowInfo.EnableTpS()) {enableButton(objName);} else {disableButton(objName);}
   
   // AddTpS
   // Tp2Ask
   objName = getObjectName(rowId, EAX_COL_Tp2Ask);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Tp2Ask(), cntOrderS));
   // MinusTpS
   // Sl2OPS
   objName = getObjectName(rowId, EAX_COL_Sl2OPS);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Sl2OPS(), cntOrderS));
   
   // EnableSlS
   objName = getObjectName(rowId, EAX_COL_EnableSlS);
   if (rowInfo.EnableSlS()) {enableButton(objName);} else {disableButton(objName);}
   
   // AddSlS
   // Sl2Bid
   objName = getObjectName(rowId, EAX_COL_Sl2Bid);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPip(rowInfo.Sl2Bid(), cntOrderS));
   // MinusSlS
   */
   // Profit
   objName = getObjectName(rowId, EAX_COL_Profit);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatProfit(rowInfo.Profit(), cntOrderS));
   // CloseLS
   // Spread
   objName = getObjectName(rowId, EAX_COL_Spread);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatSpread(rowInfo.Spread()));
   // ADR
   objName = getObjectName(rowId, EAX_COL_ADR);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, IntegerToString(rowInfo.ADR(), 4, ' '));
   // CDR
   objName = getObjectName(rowId, EAX_COL_CDR);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, IntegerToString(rowInfo.CDR(), 4, ' '));
   /*
   // PIN1
   objName = getObjectName(rowId, EAX_COL_PIN1);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(0)));
   // PIN2
   objName = getObjectName(rowId, EAX_COL_PIN2);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(1)));
   // PIN3
   objName = getObjectName(rowId, EAX_COL_PIN3);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(2)));
   // PIN4
   objName = getObjectName(rowId, EAX_COL_PIN4);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(3)));
   // PIN5
   objName = getObjectName(rowId, EAX_COL_PIN5);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(4)));
   // PIN6
   objName = getObjectName(rowId, EAX_COL_PIN6);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(5)));
   // PIN7
   objName = getObjectName(rowId, EAX_COL_PIN7);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(6)));
   // PIN8
   objName = getObjectName(rowId, EAX_COL_PIN8);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(7)));
   // PIN9
   objName = getObjectName(rowId, EAX_COL_PIN9);
   ObjectSetString(chartId, objName, OBJPROP_TEXT, formatPin(rowInfo.GetPin(8)));
   */
   ChartRedraw();
}
double calcLotSize() {
   return 0.01;
}
void closeOrders(const string symbolName="", const int orderType=9) {
   ulong ticket;
   ENUM_POSITION_TYPE ot;
   int index;
   string pairName, orderComment;
   for(int i=PositionsTotal()-1; 0<=i; i--) {
      ticket = PositionGetTicket(i);
      if (0 == ticket) continue;
      if (MagicNumber != PositionGetInteger(POSITION_MAGIC)) continue;
      pairName = PositionGetString(POSITION_SYMBOL);
      if ("" != symbolName && pairName != symbolName) continue;
      if (!Pair2IndexMap.TryGetValue(pairName, index)) continue;
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
      //openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      ot = ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));
      if (9 != orderType && orderType != ot) continue;
      //lots = OrderGetDouble(ORDER_VOLUME_CURRENT);
      //if (!OrderCalcProfit(orderType, pairName, lots, openPrice, OrderGetDouble(ORDER_PRICE_CURRENT), profit)) continue;
      orderComment = PositionGetString(POSITION_COMMENT);

      if (CommentA == orderComment || CommentM == orderComment) {
         if (rowInfo.OtherModeL()) trade.PositionClose(ticket);
         //if (ORDER_TYPE_BUY  == orderType) rowInfo.Add2OrdersL(ticket, orderComment);
         //if (ORDER_TYPE_SELL == orderType) rowInfo.Add2OrdersS(ticket, orderComment);
      } else
      if (CommentAG == orderComment || CommentMG == orderComment) {
         if (rowInfo.GridModeL()) trade.PositionClose(ticket);
         //if (ORDER_TYPE_BUY  == orderType) rowInfo.Add2OrdersGridL(ticket, orderComment);
         //if (ORDER_TYPE_SELL == orderType) rowInfo.Add2OrdersGridS(ticket, orderComment);
      } else if (CommentAR == orderComment || CommentMR == orderComment) {
         if (rowInfo.RetraceModeL()) trade.PositionClose(ticket);
      //if (CommentAR == orderComment || CommentMR == orderComment) {
         //if (ORDER_TYPE_BUY  == orderType) rowInfo.Add2OrdersRetraceL(ticket, orderComment);
         //if (ORDER_TYPE_SELL == orderType) rowInfo.Add2OrdersRetraceS(ticket, orderComment);
      }

   }

}

void closeOrdersByProfit(const bool isPositive, const string symbolName="", const int orderType=9) {
   ulong ticket;
   ENUM_POSITION_TYPE ot;
   int index;
   double profit;
   string pairName, orderComment;
   for(int i=PositionsTotal()-1; 0<=i; i--) {
      ticket = PositionGetTicket(i);
      if (0 == ticket) continue;
      if (MagicNumber != PositionGetInteger(POSITION_MAGIC)) continue;
      pairName = PositionGetString(POSITION_SYMBOL);
      if ("" != symbolName && pairName != symbolName) continue;
      if (!Pair2IndexMap.TryGetValue(pairName, index)) continue;
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(index);
      ot = ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));
      if (9 != orderType && orderType != ot) continue;
      profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + PositionGetDouble(POSITION_COMMISSION);
      orderComment = PositionGetString(POSITION_COMMENT);
      bool isClose = false;
      if (isPositive) {
         if (0.0 < profit) {
            if (CommentA == orderComment || CommentM == orderComment) {
               if (rowInfo.OtherModeL()) isClose = true;
            } else
            if (CommentAG == orderComment || CommentMG == orderComment) {
               if (rowInfo.GridModeL()) isClose = true;
            } else
            if (CommentAR == orderComment || CommentMR == orderComment) {
               if (rowInfo.RetraceModeL())  isClose = true;
            }
         }
      } else if (profit < 0.0) {
         if (CommentA == orderComment || CommentM == orderComment) {
            if (rowInfo.OtherModeL()) isClose = true;
         } else
         if (CommentAG == orderComment || CommentMG == orderComment) {
            if (rowInfo.GridModeL()) isClose = true;
         } else
         if (CommentAR == orderComment || CommentMR == orderComment) {
            if (rowInfo.RetraceModeL())  isClose = true;
         }
      
      }
      
      if (isClose) trade.PositionClose(ticket);
/*
      if (CommentA == orderComment || CommentM == orderComment) {
         if (rowInfo.OtherModeL()) trade.PositionClose(ticket);
         //if (ORDER_TYPE_BUY  == orderType) rowInfo.Add2OrdersL(ticket, orderComment);
         //if (ORDER_TYPE_SELL == orderType) rowInfo.Add2OrdersS(ticket, orderComment);
      } else
      if (CommentAG == orderComment || CommentMG == orderComment) {
         if (rowInfo.GridModeL()) trade.PositionClose(ticket);
         //if (ORDER_TYPE_BUY  == orderType) rowInfo.Add2OrdersGridL(ticket, orderComment);
         //if (ORDER_TYPE_SELL == orderType) rowInfo.Add2OrdersGridS(ticket, orderComment);
      } else if (CommentAR == orderComment || CommentMR == orderComment) {
         if (rowInfo.RetraceModeL()) trade.PositionClose(ticket);
      //if (CommentAR == orderComment || CommentMR == orderComment) {
         //if (ORDER_TYPE_BUY  == orderType) rowInfo.Add2OrdersRetraceL(ticket, orderComment);
         //if (ORDER_TYPE_SELL == orderType) rowInfo.Add2OrdersRetraceS(ticket, orderComment);
      }
*/
   }

}

void DrawDataH1(const int startXi, const int startYi) {
   int x = startXi;
   int y = startYi;
   //long chartId = 0;
   int Border_Width = 1;
   int ColumnInterval = 0;
   

   int columnCount = ArraySize(dataName);

   for (int colIndex=0; colIndex<columnCount; colIndex++) {
      string columnType = dataH1ObjectType[colIndex];
      if ("Lbl"==columnType) {
         RectLabelCreate(PanelNamePrefixH1+columnType+dataName[colIndex],x,y,dataH1Width[colIndex],DataH1RowHeight,dataH1BgColor[colIndex],dataH1BorderColor[colIndex],Border_Width);
         LabelCreate(columnType+dataName[colIndex],dataH1Text[colIndex],x+dataH1WidthAdjust[colIndex],y+Border_Width*2+4,dataH1FontColor[colIndex],dataH1FontSize[colIndex],dataH1FontName[colIndex]);
         x += dataH1Width[colIndex] + ColumnInterval;

      } else if ("Btn"==columnType) {
         ButtonCreate(columnType+dataName[colIndex],dataH1Text[colIndex],x,y,dataH1Width[colIndex],DataH1RowHeight,dataH1BgColor[colIndex],dataH1FontColor[colIndex],dataH1FontSize[colIndex],dataH1FontName[colIndex]);
         x += dataH1Width[colIndex] + ColumnInterval;

      } else if ("lbo"==columnType) {
         //CreatePanel(PanelNamePrefixH1+columnType+ColumnName[colIndex],x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
         //SetObjText(columnType+ColumnName[colIndex],ColumnShow[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColumnColor[colIndex]);
         //x += ColumnWidth[colIndex] + ColumnInterval;
      }
   }
}
void DrawData(const int startXi, const int startYi) {
   int x = startXi;
   int y = startYi;
   long chartId = 0;
   int Border_Width = 1;
   int ColumnInterval = 0;
   int RowInterval = 0;

   //int rowCnt = ArraySize(rowInfoArray);
   for (int i=0; i<pairCount; i++) {
      CRowInfo *rowInfo = RowInfos.GetNodeAtIndex(i);
      x = startXi;
      int columnCount = ArraySize(dataName);

      for (int colIndex=0; colIndex<columnCount; colIndex++) {
         string columnType = dataObjectType[colIndex];
         string objName = getObjectName(i, colIndex);
         if ("Lbl"==columnType) {
            RectLabelCreate(PanelNamePrefix+objName,x,y,dataWidth[colIndex],dataRowHeight,dataBgColor[colIndex],dataBorderColor[colIndex],Border_Width);
            LabelCreate(objName,dataText[colIndex],x+dataWidthAdjust[colIndex],y+RowInterval+Border_Width*2,dataFontColor[colIndex],dataFontSize[colIndex],dataFontName[colIndex]);
            x += dataWidth[colIndex] + ColumnInterval;
            //if(1==i%2) {
               //ObjectSetInteger(chartId,PanelNamePrefix+columnType+dataName[colIndex]+IntegerToString(i),OBJPROP_BGCOLOR,C'41,41,41');
            //}
            //ObjectSetInteger(0,PanelNamePrefix+objName,OBJPROP_WIDTH,10);

         } else if ("Btn"==columnType) {
            ButtonCreate(objName,dataText[colIndex],x,y,dataWidth[colIndex],dataRowHeight,dataBgColor[colIndex],dataFontColor[colIndex],dataFontSize[colIndex],dataFontName[colIndex]);
            x += dataWidth[colIndex] + ColumnInterval;
            //ObjectSetInteger(0,objName,OBJPROP_WIDTH,10);

         } else if ("lbo"==columnType) {
            //CreatePanel(PanelNamePrefix+columnType+ColumnName[colIndex]+IntegerToString(i),x,y,ColumnWidth[colIndex],RowHeight,ColumnColorBackground[colIndex],ColumnColorBorder[colIndex],Border_Width);
            //SetObjText(columnType+ColumnName[colIndex]+IntegerToString(i),ColumnShow[colIndex],x+ColumnWidthAdjust[colIndex],y+RowInterval+Border_Width*4,ColumnColor[colIndex]);
            //x += ColumnWidth[colIndex] + ColumnInterval;
         }
      }

      ObjectSetString(chartId,getObjectName(i, EAX_COL_Pair)         ,OBJPROP_TEXT,rowInfo.SymbolN());
      ObjectSetString(chartId,getObjectName(i, EAX_COL_SymbolN)      ,OBJPROP_TEXT,rowInfo.SymbolN());
      //ObjectSetString(chartId,getObjectName(i, EAX_COL_PlusOrdL)   ,OBJPROP_TEXT,"✜");
      ObjectSetString(chartId,getObjectName(i, EAX_COL_GridPips)     ,OBJPROP_TEXT,IntegerToString(rowInfo.GridPips(), 3));
      ObjectSetString(chartId,getObjectName(i, EAX_COL_RetracePips)  ,OBJPROP_TEXT,IntegerToString(rowInfo.RetracePips(), 3));
      ObjectSetString(chartId,getObjectName(i, EAX_COL_SwapL)        ,OBJPROP_TEXT,formatSwap(rowInfo.SwapL()));
      ObjectSetString(chartId,getObjectName(i, EAX_COL_SwapS)        ,OBJPROP_TEXT,formatSwap(rowInfo.SwapS()));
      //ObjectSetString(chartId,getObjectName(i, EAX_COL_Spread)     ,OBJPROP_TEXT,formatSpread(rowInfo.Spread()));
      //ObjectSetString(chartId,getObjectName(i, EAX_COL_CDR)        ,OBJPROP_TEXT,rowInfo.CDR());
      y += dataRowHeight + RowInterval;
   }

}




void disableButton(string btnName, color backgroundColor=clrDarkGray, color fontColor=clrBlack) {
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,backgroundColor);
}
void disableButtonNoDataHasSignal(string btnName, color backgroundColor=clrDarkGray, color fontColor=clrBlack) {
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,backgroundColor);
}
void disableButtonNoDataNoSignal(string btnName, color backgroundColor=clrDarkGray, color fontColor=clrBlack) {
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,backgroundColor);
}
void enableButton(string btnName, color backgroundColor=clrMediumSpringGreen, color fontColor=clrBlack) {
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,backgroundColor);
}
void enableButtonTradeMode(string btnName, color backgroundColor=clrDarkViolet, color fontColor=clrWhite) {
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,backgroundColor);
}
void enableButtonSingularMode(string btnName, color backgroundColor=clrBlue, color fontColor=clrWhite) {
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,backgroundColor);
}
void enableButtonPluralMode(string btnName, color backgroundColor=clrNavy, color fontColor=clrWhite) {
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,backgroundColor);
}
string getObjectName(const int rowIndex, const int columnIndex) {
   return dataObjectType[columnIndex]+dataName[columnIndex]+IntegerToString(rowIndex);
}
string formatOrderCount(const int countOrder) {
   if (0 == countOrder) return " ";
   return (IntegerToString(countOrder, 3));
}
string formatProfit(const double value, const int countOrder) {
   if (0 == countOrder) return " ";
   return formatDouble(value, 9, 2);
}
string formatSwap(const double value) {
   return formatDouble(value, 6, 2);
}
string formatSpread(const double value) {
   return formatDouble(value, 5, 1);
}
string formatPip(const double value, const int countOrder) {
   if (0 == countOrder) return " ";
   return formatDouble(value, 5, 1);
}
string formatLot(const double value, const int countOrder) {
   if (0 == countOrder) return " ";
   return formatDouble(value, 6, 2);
}
string formatPin(const char value) {
   if (-1 == value) return "▼";
   if ( 0 == value) return " ≡";
   if ( 1 == value) return "▲";
   return " ";
}
string formatDouble(const double value, const uchar maxLength, const uchar scale) {
   return PadLeft(DoubleToString(value, scale), maxLength);
}
string PadLeft(const string str, const int maxLength) {
   string rtn = str;
   int length = StringLen(str);
   if (maxLength <= length) return rtn;
   
   for(int i=length-1; i<maxLength; i++) rtn = " " + rtn;
   return rtn;
}
// 创建矩形标签
bool RectLabelCreate(const string           name="RectLabel",         // 标签名称
                     const int              x=0,                      // X 坐标
                     const int              y=0,                      // Y 坐标
                     const int              width=50,                 // 宽度
                     const int              height=18,                // 高度
                     const color            back_clr=C'236,233,216',  // 背景色
                     const color            clr=clrRed,               // 平面边框颜色 (Flat)
                     const int              line_width=1,             // 平面边框宽度
                     const ENUM_BORDER_TYPE border=BORDER_FLAT,       // 边框类型
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // 图表定位角
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // 平面边框风格
                     const long             chart_ID=0,               // 图表 ID
                     const int              sub_window=0,             // 子窗口指数
                     const bool             back=false,               // 在背景中
                     const bool             selection=false,          // 突出移动
                     const bool             hidden=true,              // 隐藏在对象列表
                     const long             z_order=0)                // 鼠标单击优先
{ 
//--- 重置错误的值 
   ResetLastError();
//--- 创建矩形标签 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) { 
      Print(__FUNCTION__, ": failed to create a rectangle label! Error code = ",GetLastError());
      return(false);
   } 
//--- 设置标签坐标 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- 设置标签大小 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- 设置背景颜色 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- 设置边框类型 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- 设置相对于定义点坐标的图表的角 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- 设置平面边框颜色 (在平面模式下) 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 设置平面边框线型风格 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- 设置平面边框宽度 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- 显示前景 (false) 或背景 (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- 启用 (true) 或禁用 (false) 通过鼠标移动标签的模式 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- 在对象列表隐藏(true) 或显示 (false) 图形对象名称 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- 设置在图表中优先接收鼠标点击事件 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 成功执行 
   return(true);
} 
// 创建按钮
bool ButtonCreate(const string            name="Button",            // 按钮名称
                  const string            text="Button",            // 文本
                  const int               x=0,                      // X 坐标
                  const int               y=0,                      // Y 坐标
                  const int               width=50,                 // 按钮宽度
                  const int               height=18,                // 按钮高度
                  const color             back_clr=C'236,233,216',  // 背景色
                  const color             clr=clrBlack,             // 文本颜色
                  const int               font_size=10,             // 字体大小
                  const string            font="Arial",             // 字体
                  const color             border_clr=clrNONE,       // 边界颜色
                  const long              chart_ID=0,               // 图表 ID
                  const int               sub_window=0,             // 子窗口指数
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // 图表定位角
                  const bool              state=false,              // 出版/发布
                  const bool              back=false,               // 在背景中
                  const bool              selection=false,          // 突出移动
                  const bool              hidden=true,              // 隐藏在对象列表
                  const long              z_order=0)                // 鼠标单击优先
{ 
//--- 重置错误的值
   ResetLastError();
//--- 创建按钮
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0)) {
      Print(__FUNCTION__, ": failed to create the button! Error code = ",GetLastError());
      return(false);
   } 
//--- 设置按钮坐标
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- 设置按钮大小
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- 设置相对于定义点坐标的图表的角
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- 设置文本
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- 设置文本字体
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- 设置字体大小
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- 设置文本颜色
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 设置背景颜色
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- 设置边界颜色
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- 显示前景 (false) 或背景 (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- 启用 (true) 或禁用 (false) 通过鼠标移动按钮的模式
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- 在对象列表隐藏(true) 或显示 (false) 图形对象名称
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- 设置在图表中优先接收鼠标点击事件
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 成功执行
   return(true);
} 
// 创建文本标签
bool LabelCreate(const string            name="Label",             // 标签名称
                 const string            text="Label",             // 文本
                 const int               x=0,                      // X 坐标
                 const int               y=0,                      // Y 坐标
                 const color             clr=clrRed,               // 颜色
                 const int               font_size=10,             // 字体大小
                 const string            font="Arial",             // 字体
                 const double            angle=0.0,                // 文本倾斜
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // 定位类型
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // 图表定位角
                 const long              chart_ID=0,               // 图表 ID
                 const int               sub_window=0,             // 子窗口指数
                 const bool              back=false,               // 在背景中
                 const bool              selection=false,          // 突出移动
                 const bool              hidden=true,              // 隐藏在对象列表
                 const long              z_order=0)                // 鼠标单击优先
{ 
//--- 重置错误的值
   ResetLastError();
//--- 创建文本标签
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) { 
      Print(__FUNCTION__, ": failed to create text label! Error code = ",GetLastError());
      return(false);
   } 
//--- 设置标签坐标
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- 设置相对于定义点坐标的图表的角
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- 设置文本
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- 设置文本字体
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- 设置字体大小
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- 设置文本的倾斜角
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- 设置定位类型
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- 设置颜色
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 显示前景 (false) 或背景 (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- 启用 (true) 或禁用 (false) 通过鼠标移动标签的模式
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- 在对象列表隐藏(true) 或显示 (false) 图形对象名称
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- 设置在图表中优先接收鼠标点击事件
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 成功执行
   return(true);
} 


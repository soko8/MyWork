//+------------------------------------------------------------------+
//|                                                        DB_4K.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
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
#define clrHBGC4                       C'255, 242, 226'
//#define COL_NO_STO3                                  29
//#define COL_NO_                                  30


/****************************RSI**********************************************/
input string ____________________RSI_SETTING_____________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableRSIFilter__=false;
input ENUM_TIMEFRAMES            Timeframe_RSI = PERIOD_H1;
input int                        Period_RSI = 14;
input ENUM_APPLIED_PRICE         Applied_Price_RSI = PRICE_CLOSE;
input int                        UpLimitRSI=75;
input int                        DnLimitRSI=25;
/****************************RSI**********************************************/

/****************************CCI**********************************************/
input string ____________________CCI_SETTING_____________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableCCIFilter__=false;
input ENUM_TIMEFRAMES            Timeframe_CCI = PERIOD_H1;
input int                        Period_CCI = 14;
input ENUM_APPLIED_PRICE         Applied_Price_CCI = PRICE_CLOSE;
input int                        UpLimitCCI=100;
input int                        DnLimitCCI=-100;
/****************************CCI**********************************************/

/****************************SAR**********************************************/
input string ____________________SAR_SETTING____________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableSARFilter__=true;
input ENUM_TIMEFRAMES            Timeframe_SAR = PERIOD_H1;
input double                     Step_SAR = 0.02;
input double                     Maximum_SAR = 0.2;
/****************************SAR**********************************************/

/****************************MA1**********************************************/
input string ____________________MA1_SETTING___________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableMA1Filter__=true;
input ENUM_TIMEFRAMES            Timeframe_MA1 = PERIOD_M5;
const int                        Period_MA1_Short  = 20;
const int                        Period_MA1_Medium = 50;
const int                        Period_MA1_Long   = 100;
const int                        Shift_MA1 = 0;
input ENUM_MA_METHOD             Method_MA1 = MODE_EMA;
input ENUM_APPLIED_PRICE         Applied_Price_MA1 = PRICE_CLOSE;
/****************************MA1**********************************************/

/****************************MA2**********************************************/
input string ____________________MA2_SETTING___________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableMA2Filter__=false;
input ENUM_TIMEFRAMES            Timeframe_MA2 = PERIOD_M15;
const int                        Period_MA2_Short  = 20;
const int                        Period_MA2_Medium = 50;
const int                        Period_MA2_Long   = 100;
const int                        Shift_MA2 = 0;
input ENUM_MA_METHOD             Method_MA2 = MODE_EMA;
input ENUM_APPLIED_PRICE         Applied_Price_MA2 = PRICE_CLOSE;
/****************************MA2**********************************************/

/****************************MA3**********************************************/
input string ____________________MA3_SETTING___________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableMA3Filter__=true;
input ENUM_TIMEFRAMES            Timeframe_MA3 = PERIOD_M30;
const int                        Period_MA3_Short  = 25;
const int                        Period_MA3_Medium = 50;
const int                        Period_MA3_Long   = 100;
const int                        Shift_MA3 = 0;
input ENUM_MA_METHOD             Method_MA3 = MODE_EMA;
input ENUM_APPLIED_PRICE         Applied_Price_MA3 = PRICE_CLOSE;
/****************************MA3**********************************************/

/****************************MA4**********************************************/
input string ____________________MA4_SETTING___________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableMA4Filter__=true;
input ENUM_TIMEFRAMES            Timeframe_MA4 = PERIOD_H1;
const int                        Period_MA4_Short  = 20;
const int                        Period_MA4_Medium = 50;
const int                        Period_MA4_Long   = 100;
const int                        Shift_MA4 = 0;
input ENUM_MA_METHOD             Method_MA4 = MODE_EMA;
input ENUM_APPLIED_PRICE         Applied_Price_MA4 = PRICE_CLOSE;
/****************************MA4**********************************************/

/****************************GAP**********************************************/
input string ____________________GAP_SETTING____________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input ENUM_TIMEFRAMES            Timeframe_GAP = PERIOD_H1;
// 计算30分钟前BidRatio用
input int                        Interval_GAP = 1800;
input bool                       EnableBidRatioFilter__=false;
input int                        UpLimitBidRatioBuy=90;
input int                        DnLimitBidRatioBuy=75;
input int                        UpLimitBidRatioSell=25;
input int                        DnLimitBidRatioSell=10;
input bool                       EnableRelativeStrengthFilter__=false;
input int                        UpLimitRelativeStrength=7;
input int                        DnLimitRelativeStrength=-7;
input bool                       EnableBuySellRatioFilter__=true;
input double                     UpLimitCurrency=6.1;
input double                     DnLimitCurrency=2.0;
input bool                       EnableGAPFilter__=false;
input double                     UpLimitGap=3.5;
input double                     DnLimitGap=-3.5;
/****************************GAP**********************************************/

/****************************Stochastic1**************************************/
input string ____________________Sto_SETTING_____________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       EnableStoFilter__=true;
input ENUM_TIMEFRAMES            Timeframe_STO = PERIOD_M15;
input int                        Period_STO_K = 5;
input int                        Period_STO_SLOW = 3;
input int                        Period_STO_D = 3;
input ENUM_MA_METHOD             Method_STO = MODE_EMA;
                                 // 0 - Low/High or 1 - Close/Close
input int                        Price_Field_STO = 1;
input int                        UpLimitSto=80;
input int                        DnLimitSto=20;
/****************************Stochastic1**************************************/

/****************************IchiMokuKinkoHyo**************************************/
input string ____________________IchiMokuKinkoHyo_SETTING_____________="↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓";
input bool                       Enable1KHFilter__=true;
input ENUM_TIMEFRAMES            Timeframe_1KH = PERIOD_H1;
input int                        Period_1KH_Tenkan = 9;
input int                        Period_1KH_Kijun = 26;
input int                        Period_1KH_Senkou = 52;
input int                        UpLimit1KH=80;
input int                        DnLimit1KH=20;
/****************************Stochastic1**************************************/



input int                  MagicNumber=888888;
input string               Prefix="";
input string               Suffix="";
input double               LotSize=0.1;
input double               Multiple=0.5;

input int                  SlPoints__=300;
input int                  InitTpPoints__=100;
input int                  TrailingStopPoints__=100;

input bool                 EnableSpreadFilter__=true;
input int                  LimitSpread=30;
input string               TemplateName__="My1mjh";



#import "DrawDashBoard.ex4"
   void DrawDashBoard(CList *symbolList);
   void refreshOrdersData(CList *symbolList, int Magic_Number, bool isAutoTrade, double coefficient);
   double GetAdrValues(string pairName, double point);
   int getRelativeStrength(double bidRatio);
   string getObjectName(int rowIndex, int columnIndex);
   void createOrderL(SymbolInfo *si, double lot, int MagicNumb, string comnt="", double slp=0.0, double tpp=0.0);
   void createOrderS(SymbolInfo *si, double lot, int MagicNumb, string comnt="", double slp=0.0, double tpp=0.0);
   void closeOrderL(SymbolInfo *si, int MagicNumb, double lots=0.0, string message="");
   void closeOrderS(SymbolInfo *si, int MagicNumb, double lots=0.0, string message="");
   void closeAllL(int MagicNumb, string message="");
   void closeAllS(int MagicNumb, string message="");
   void closePositiveProfitOrders(int MagicNumb, string message="", int slippagePerLot=0);
   void closeNegativeProfitOrders(int MagicNumb, string message="", int slippagePerLot=0);
   string getTimeFrame(ENUM_TIMEFRAMES tf);
   string getAppliedPrice(ENUM_APPLIED_PRICE appliedPrice);
   string getMaMethod(ENUM_MA_METHOD MaMethod);
   bool isExpire(datetime ExpireTime, bool EnableUseTimeControl=true);
#import


      int                  PairCount;
      string               TradePairs[];
//      double               BidRatios[];
      
      CList*               SymbolList;
      double               lotSize;
      bool                 isAutoMode=false;
      int                  SlPoints;
      int                  InitTpPoints;
      int                  TrailingStopPoints;
      
      bool                 EnableSpreadFilter,EnableRSIFilter,EnableCCIFilter,EnableSARFilter,EnableMA1Filter,EnableMA2Filter,EnableMA3Filter,EnableMA4Filter,EnableBidRatioFilter,EnableRelativeStrengthFilter,EnableBuySellRatioFilter,EnableGAPFilter,EnableStoFilter,Enable1KHFilter;

string Currencies[];
//string Currencies[] = {"USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "NZD"};
string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};

const int                  StartX=4;
const int                  StartY=4;
const int                  SLIPPAGE=20;
const string               COMMENT="DB_";


void setFilter(bool enableFilter, string objName) {
   if (enableFilter) {
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrHBGC1);
   } else {
      ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrHBGC4);
   }
}

void setHeader() {
   long chartId = 0;
   ObjectSetString(chartId,"H3lblBuyLot",OBJPROP_TEXT,DoubleToStr(lotSize,2));
   ObjectSetString(chartId,"H2lblBuyLot",OBJPROP_TEXT,IntegerToString(TrailingStopPoints));
   
   ObjectSetString(chartId,"H3lblSellProfit",OBJPROP_TEXT,IntegerToString(SlPoints));
   ObjectSetString(chartId,"H2lblSellProfit",OBJPROP_TEXT,IntegerToString(InitTpPoints));
   
   ObjectSetString(chartId,"H3lblRSI",OBJPROP_TEXT,getTimeFrame(Timeframe_RSI));
   ObjectSetString(chartId,"H2lblRSI",OBJPROP_TEXT,getAppliedPrice(Applied_Price_RSI)+IntegerToString(Period_RSI));
   
   ObjectSetString(chartId,"H3lblCCI",OBJPROP_TEXT,getTimeFrame(Timeframe_CCI));
   ObjectSetString(chartId,"H2lblCCI",OBJPROP_TEXT,getAppliedPrice(Applied_Price_CCI)+IntegerToString(Period_CCI));
   
   ObjectSetString(chartId,"H3lblSAR",OBJPROP_TEXT,getTimeFrame(Timeframe_SAR));
   ObjectSetString(chartId,"H2lblSAR",OBJPROP_TEXT,DoubleToStr(Step_SAR,2));
   
   ObjectSetString(chartId,"H2lblMA1",OBJPROP_TEXT,getMaMethod(Method_MA1)+getAppliedPrice(Applied_Price_MA1));
   ObjectSetString(chartId,"H2lblMA2",OBJPROP_TEXT,getMaMethod(Method_MA2)+getAppliedPrice(Applied_Price_MA2));
   ObjectSetString(chartId,"H2lblMA3",OBJPROP_TEXT,getMaMethod(Method_MA3)+getAppliedPrice(Applied_Price_MA3));
   ObjectSetString(chartId,"H2lblMA4",OBJPROP_TEXT,getMaMethod(Method_MA4)+getAppliedPrice(Applied_Price_MA4));
   
   ObjectSetString(chartId,"H1btnMA1",OBJPROP_TEXT,getTimeFrame(Timeframe_MA1));
   ObjectSetString(chartId,"H1btnMA2",OBJPROP_TEXT,getTimeFrame(Timeframe_MA2));
   ObjectSetString(chartId,"H1btnMA3",OBJPROP_TEXT,getTimeFrame(Timeframe_MA3));
   ObjectSetString(chartId,"H1btnMA4",OBJPROP_TEXT,getTimeFrame(Timeframe_MA4));
   
   ObjectSetString(chartId,"H3lblBidRatio",OBJPROP_TEXT,"Price Action "+IntegerToString(UpLimitBidRatioBuy)+"/"+IntegerToString(DnLimitBidRatioBuy)+"/"+IntegerToString(UpLimitBidRatioSell)+"/"+IntegerToString(DnLimitBidRatioSell));
   ObjectSetString(chartId,"H2lblBidRatio",OBJPROP_TEXT,getTimeFrame(Timeframe_GAP));
   ObjectSetString(chartId,"H2lblRelativeStrength",OBJPROP_TEXT,IntegerToString(UpLimitRelativeStrength)+"/"+IntegerToString(DnLimitRelativeStrength));
   ObjectSetString(chartId,"H2lblBSRatio",OBJPROP_TEXT,DoubleToStr(UpLimitCurrency,1)+"/"+DoubleToStr(DnLimitCurrency,1)+" "+DoubleToStr(UpLimitGap,1)+"/"+DoubleToStr(DnLimitGap,1));
   ObjectSetString(chartId,"H2lblGAP",OBJPROP_TEXT,IntegerToString(Interval_GAP));
   
   ObjectSetString(chartId,"H3lblStochastic1",OBJPROP_TEXT,getTimeFrame(Timeframe_STO)+" "+getMaMethod(Method_STO)+IntegerToString(Price_Field_STO));
   ObjectSetString(chartId,"H2lblStochastic1",OBJPROP_TEXT,IntegerToString(Period_STO_K)+"/"+IntegerToString(Period_STO_SLOW)+"/"+IntegerToString(Period_STO_D));
   
   setFilter(EnableRSIFilter, "H1btnRSI");
   setFilter(EnableCCIFilter, "H1btnCCI");
   setFilter(EnableSARFilter, "H1btnSAR");
   setFilter(EnableMA1Filter, "H1btnMA1");
   setFilter(EnableMA2Filter, "H1btnMA2");
   setFilter(EnableMA3Filter, "H1btnMA3");
   setFilter(EnableMA4Filter, "H1btnMA4");
   setFilter(EnableBidRatioFilter, "H1btnBidRatio");
   setFilter(EnableRelativeStrengthFilter, "H1btnRelativeStrength");
   setFilter(EnableBuySellRatioFilter, "H1btnBSRatio");
   setFilter(EnableGAPFilter, "H1btnGAP");
   setFilter(EnableStoFilter, "H1btnStochastic1");
   
   setFilter(Enable1KHFilter, "H1btn1muKinkoHyo");
   ObjectSetString(chartId,"H3lbl1muKinkoHyo",OBJPROP_TEXT,getTimeFrame(Timeframe_1KH));
   ObjectSetString(chartId,"H2lbl1muKinkoHyo",OBJPROP_TEXT,IntegerToString(Period_1KH_Tenkan)+"/"+IntegerToString(Period_1KH_Kijun)+"/"+IntegerToString(Period_1KH_Senkou));
   
}

void initSymbols() {
   SymbolList = new CList;
   int size = ArraySize(TradePairs);
   int currencySize = 0;
   for (int i=0; i<size; i++) {
      string pair = TradePairs[i];
      SymbolInfo *si = new SymbolInfo(pair, Prefix, Suffix);
      int vdigits = (int) MarketInfo(si.getRealName(), MODE_DIGITS);
      double vpoint  = MarketInfo(si.getRealName(), MODE_POINT);
      si.setStopLoss(NormalizeDouble(vpoint*SlPoints, vdigits));
      si.setTakeProfit(NormalizeDouble(vpoint*InitTpPoints, vdigits));
      si.setTrailingStop(NormalizeDouble(vpoint*TrailingStopPoints, vdigits));
      SymbolList.Add(si);
      
      bool foundBase = false;
      bool foundQuote = false;
      for (int j=0; j<currencySize; j++) {
         string currency = Currencies[j];
         if (currency == StringSubstr(pair, 0, 3)) {
            foundBase = true;
         }
         if (currency == StringSubstr(pair, 3, 3)) {
            foundQuote = true;
         }
      }
      if (!foundBase) {
         currencySize++;
         ArrayResize(Currencies, currencySize);
         Currencies[currencySize-1] = StringSubstr(pair, 0, 3);
      }
      if (!foundQuote) {
         currencySize++;
         ArrayResize(Currencies, currencySize);
         Currencies[currencySize-1] = StringSubstr(pair, 3, 3);
      }
   }
}

int OnInit() {
   //if(!IsDemo()) return(INIT_FAILED);
   
   datetime ExpireTime = D'2021.12.31 23:59:59';
   if (isExpire(ExpireTime, true)) return(INIT_FAILED);
   
   lotSize = LotSize;
   EnableSpreadFilter=EnableSpreadFilter__;
   EnableRSIFilter=EnableRSIFilter__;
   EnableCCIFilter=EnableCCIFilter__;
   EnableSARFilter=EnableSARFilter__;
   EnableMA1Filter=EnableMA1Filter__;
   EnableMA2Filter=EnableMA2Filter__;
   EnableMA3Filter=EnableMA3Filter__;
   EnableMA4Filter=EnableMA4Filter__;
   EnableBidRatioFilter=EnableBidRatioFilter__;
   EnableRelativeStrengthFilter=EnableRelativeStrengthFilter__;
   EnableBuySellRatioFilter=EnableBuySellRatioFilter__;
   EnableGAPFilter=EnableGAPFilter__;
   EnableStoFilter=EnableStoFilter__;
   Enable1KHFilter=Enable1KHFilter__;
   
   SlPoints=SlPoints__;
   InitTpPoints=InitTpPoints__;
   TrailingStopPoints=TrailingStopPoints__;
   
   ArrayCopy(TradePairs,DefaultPairs);
   PairCount = ArraySize(TradePairs);
   initSymbols();
   DrawDashBoard(SymbolList);
   
   setHeader();
   
   refreshOrdersData(SymbolList, MagicNumber, isAutoMode, Multiple);
   refreshIndicatorsData(SymbolList, Currencies);

   EventSetTimer(1);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();
   SymbolList.Clear();
   delete SymbolList;
}

void OnTick() {}

void OnTimer() {

   refreshIndicatorsData(SymbolList, Currencies);
   refreshOrdersData(SymbolList, MagicNumber, isAutoMode, Multiple);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   long chartId = 0;
   if (id == CHARTEVENT_OBJECT_CLICK) {
   
      if ("H3btnDisable" == sparam) {
         isAutoMode = !isAutoMode;
         if (isAutoMode) {
            ObjectSetString(chartId,sparam,OBJPROP_TEXT, "A");
            ObjectSetInteger(chartId,sparam,OBJPROP_BGCOLOR,clrLime);
         } else {
            ObjectSetString(chartId,sparam,OBJPROP_TEXT, "M");
            ObjectSetInteger(chartId,sparam,OBJPROP_BGCOLOR,clrRed);
         }
      } else
      
      if ((0 <= StringFind(sparam, "btnPairName"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnPairName")));
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
            ChartApplyTemplate(chartIdPair, TemplateName__);
         }
      } else
      
      if ("H2btnBuy" == sparam) {
         Print("1111111");
      } else
      
      if ("H3btnBuy" == sparam) {
         Print("222222");
      } else
      
      
      if ("H2btnCloseBuy" == sparam) {
         Print("333333");
      } else
      
      if ("H3btnCloseBuy" == sparam) {
         Print("4444444");
      } else
      
      
      if ("H2btnCloseSell" == sparam) {
         Print("555555");
      } else
      
      if ("H3btnCloseSell" == sparam) {
         Print("66666666");
      } else
      
      
      if ("H2btnSellNum" == sparam) {
         Print("7777777");
      } else
      
      if ("H3btnSellNum" == sparam) {
         Print("888888");
      } else
      
      if ("H1btnSpread" == sparam) {
         EnableSpreadFilter = !EnableSpreadFilter;
         setFilter(EnableSpreadFilter, "H1btnSpread");
      } else
      
      if ("H1btnRSI" == sparam) {
         EnableRSIFilter = !EnableRSIFilter;
         setFilter(EnableRSIFilter, "H1btnRSI");
      } else
      
      if ("H1btnCCI" == sparam) {
         EnableCCIFilter = !EnableCCIFilter;
         setFilter(EnableCCIFilter, "H1btnCCI");
      } else
      
      if ("H1btnSAR" == sparam) {
         EnableSARFilter = !EnableSARFilter;
         setFilter(EnableSARFilter, "H1btnSAR");
      } else
      
      if ("H1btnMA1" == sparam) {
         EnableMA1Filter = !EnableMA1Filter;
         setFilter(EnableMA1Filter, "H1btnMA1");
      } else
      
      if ("H1btnMA2" == sparam) {
         EnableMA2Filter = !EnableMA2Filter;
         setFilter(EnableMA2Filter, "H1btnMA2");
      } else
      
      if ("H1btnMA3" == sparam) {
         EnableMA3Filter = !EnableMA3Filter;
         setFilter(EnableMA3Filter, "H1btnMA3");
      } else
      
      if ("H1btnMA4" == sparam) {
         EnableMA4Filter = !EnableMA4Filter;
         setFilter(EnableMA4Filter, "H1btnMA4");
      } else
      
      if ("H1btnBidRatio" == sparam) {
         EnableBidRatioFilter = !EnableBidRatioFilter;
         setFilter(EnableBidRatioFilter, "H1btnBidRatio");
      } else
      
      if ("H1btnRelativeStrength" == sparam) {
         EnableRelativeStrengthFilter = !EnableRelativeStrengthFilter;
         setFilter(EnableRelativeStrengthFilter, "H1btnRelativeStrength");
      } else
      
      if ("H1btnBSRatio" == sparam) {
         EnableBuySellRatioFilter = !EnableBuySellRatioFilter;
         setFilter(EnableBuySellRatioFilter, "H1btnBSRatio");
      } else
      
      if ("H1btnGAP" == sparam) {
         EnableGAPFilter = !EnableGAPFilter;
         setFilter(EnableGAPFilter, "H1btnGAP");
      } else
      
      if ("H1btnStochastic1" == sparam) {
         EnableStoFilter = !EnableStoFilter;
         setFilter(EnableStoFilter, "H1btnStochastic1");
      } else

   
      // close all positive profit long orders
      if ("H1btnBuy" == sparam) {
         closePositiveProfitOrders(MagicNumber, "Manually Close All Positive Profit Orders", SLIPPAGE);
      } else
      
      // close all long orders
      if ("H1btnCloseBuy" == sparam) {
         closeAllL(MagicNumber, "Manually Close All Long Orders");
      } else
      
      // close all negative profit short orders
      if ("H1btnSell" == sparam) {
         closeNegativeProfitOrders(MagicNumber, "Manually Close All Negative Profit Orders", SLIPPAGE);
      } else
      
      // close all short orders
      if ("H1btnCloseSell" == sparam) {
         closeAllL(MagicNumber, "Manually Close All Short Orders");
      } else 
      
      // new Buy Order
      if ((0 <= StringFind(sparam, "btnBuy"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnBuy")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         createOrderL(si, lotSize, MagicNumber, COMMENT+"Manually");
         si.setOrderCountL(si.getOrderCountL()+1);
         
      } else 
      
      // close a Buy Order
      if ((0 <= StringFind(sparam, "btnCloseBuy"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnCloseBuy")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         closeOrderL(si, MagicNumber, 0.0, "Manually Close Buy Order.");
      } else 
      
      // new Sell Order
      if ((0 <= StringFind(sparam, "btnSell"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnSell")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         createOrderS(si, lotSize, MagicNumber, COMMENT+"Manually");
         si.setOrderCountS(si.getOrderCountS()+1);
         
      } else 
      
      // close a Sell Order
      if ((0 <= StringFind(sparam, "btnCloseSell"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnCloseSell")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         closeOrderS(si, MagicNumber, 0.0, "Manually Close Sell Order.");
         
      }
      
      else {
      
      }
      
   }
   
}



void refreshIndicatorsData(CList *symbolList, string &CurrencyArray[]) export {
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

   ArrayResize(CurrencyStrengths, currencySize);
   ArrayResize(CurrencyStrengthsPre, currencySize);
   ArrayInitialize(CurrencyStrengths, 0.0);
   ArrayInitialize(CurrencyStrengthsPre, 0.0);

   
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

   }

   
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);
      symbolName = si.getRealName();
      bool isLong = true;
      bool isShort = true;
      // Spread
      objName = getObjectName(i, COL_NO_SPREAD);
      int spread = (int)MarketInfo(symbolName,MODE_SPREAD);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,IntegerToString(spread, 3));
      if (LimitSpread < spread) {
         fontColor = clrGray;
         if (EnableSpreadFilter) {
            isLong = false;
            isShort = false;
         }
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
      if (UpLimitRSI <= Vrsi) {
         fontColor = clrRed;
         if (EnableRSIFilter) {
            isLong = false;
         }
      } else if (Vrsi <= DnLimitRSI) {
         fontColor = clrLime;
         if (EnableRSIFilter) {
            isShort = false;
         }
      } else {
         if (EnableRSIFilter) {
            isLong = false;
            isShort = false;
         }
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      // CCI
      objName = getObjectName(i, COL_NO_CCI);
      double Vcci  = iCCI(symbolName,Timeframe_CCI,Period_CCI,Applied_Price_CCI,BarShift);
      string cci = DoubleToStr(Vcci, 0);
      cci = IntegerToString(StrToInteger(cci), 4);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,cci);
      fontColor = clrGray;
      if (UpLimitCCI <= Vcci) {
         fontColor = clrRed;
         if (EnableCCIFilter) {
            isLong = false;
         }
      } else if (Vcci <= DnLimitCCI) {
         fontColor = clrLime;
         if (EnableCCIFilter) {
            isShort = false;
         }
      } else {
         if (EnableCCIFilter) {
            isLong = false;
            isShort = false;
         }
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
         if (EnableSARFilter) {
            isShort = false;
         }
      } else {
         if (EnableSARFilter) {
            isLong = false;
         }
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
         if (EnableMA1Filter) {
            isShort = false;
         }
      } else if (ma1Long>ma1Medium && ma1Medium>ma1Short) {
         ma1 = "▼";
         fontColor = clrRed;
         if (EnableMA1Filter) {
            isLong = false;
         }
      } else {
         if (EnableMA1Filter) {
            isLong = false;
            isShort = false;
         }
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
         if (EnableMA2Filter) {
            isShort = false;
         }
      } else if (ma2Long>ma2Medium && ma2Medium>ma2Short) {
         ma2 = "▼";
         fontColor = clrRed;
         if (EnableMA2Filter) {
            isLong = false;
         }
      } else {
         if (EnableMA2Filter) {
            isLong = false;
            isShort = false;
         }
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
         if (EnableMA3Filter) {
            isShort = false;
         }
      } else if (ma3Long>ma3Medium && ma3Medium>ma3Short) {
         ma3 = "▼";
         fontColor = clrRed;
         if (EnableMA3Filter) {
            isLong = false;
         }
      } else {
         if (EnableMA3Filter) {
            isLong = false;
            isShort = false;
         }
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
         if (EnableMA4Filter) {
            isShort = false;
         }
      } else if (ma4Long>ma4Medium && ma4Medium>ma4Short) {
         ma4 = "▼";
         fontColor = clrRed;
         if (EnableMA4Filter) {
            isLong = false;
         }
      } else {
         if (EnableMA4Filter) {
            isLong = false;
            isShort = false;
         }
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,ma4);
      
      // BidRatio
      objName = getObjectName(i, COL_NO_BID_RATIO);
      string bidRatio = DoubleToStr(BidRatios[i], 1);
      fontColor = clrGray;
      if (DnLimitBidRatioBuy<=BidRatios[i] && BidRatios[i]<=UpLimitBidRatioBuy) {
         fontColor = clrLime;
         if (EnableBidRatioFilter) {
            isShort = false;
         }
      } else if (DnLimitBidRatioSell<=BidRatios[i] && BidRatios[i]<=UpLimitBidRatioSell) {
         fontColor = clrRed;
         if (EnableBidRatioFilter) {
            isLong = false;
         }
      } else {
         if (EnableBidRatioFilter) {
            isLong = false;
            isShort = false;
         }
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,bidRatio);
      
      // RelativeStrength
      objName = getObjectName(i, COL_NO_REL_STRENGTH);
      int baseRelativeStrength = BaseRelativeStrengths[i];
      int quoteRelativeStrength = 9-baseRelativeStrength;
      int VRelativeStrength = baseRelativeStrength - quoteRelativeStrength;
      string relativeStrength = IntegerToString(VRelativeStrength, 2);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,relativeStrength);
      fontColor = clrGray;
      if (UpLimitRelativeStrength<=VRelativeStrength) {
         fontColor = clrLime;
         if (EnableRelativeStrengthFilter) {
            isShort = false;
         }
      } else if (VRelativeStrength<=DnLimitRelativeStrength) {
         fontColor = clrRed;
         if (EnableRelativeStrengthFilter) {
            isLong = false;
         }
      } else {
         if (EnableRelativeStrengthFilter) {
            isLong = false;
            isShort = false;
         }
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      // BuySellRatio
      objName = getObjectName(i, COL_NO_BS_RATIO);
      string BSRatio = DoubleToStr(BuyRatios[i], 1)+"－"+DoubleToStr(SellRatios[i], 1)+"＝"+DoubleToStr((BuyRatios[i]-SellRatios[i]), 1);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,BSRatio);
      fontColor = clrGray;
      if (UpLimitCurrency<=BuyRatios[i] && SellRatios[i]<=DnLimitCurrency) {
         fontColor = clrLime;
         if (EnableBuySellRatioFilter) {
            isShort = false;
         }
      } else if (UpLimitCurrency<=SellRatios[i] && BuyRatios[i]<=DnLimitCurrency) {
         fontColor = clrRed;
         if (EnableBuySellRatioFilter) {
            isLong = false;
         }
      } else {
         if (EnableBuySellRatioFilter) {
            isLong = false;
            isShort = false;
         }
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      // GAP
      objName = getObjectName(i, COL_NO_GAP);
      fontColor = clrGray;
      if (UpLimitGap<=GAPs[i]) {
         fontColor = clrLime;
         if (EnableGAPFilter) {
            isShort = false;
         }
      } else if (GAPs[i]<=DnLimitGap) {
         fontColor = clrRed;
         if (EnableGAPFilter) {
            isLong = false;
         }
      } else {
         if (EnableGAPFilter) {
            isLong = false;
            isShort = false;
         }
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      string GAP = DoubleToStr(GAPs[i], 1);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,GAP);
      
      
      // Stochastic
      objName = getObjectName(i, COL_NO_STO);
      double VstoMain   = iStochastic(symbolName,Timeframe_STO,Period_STO_K,Period_STO_D,Period_STO_SLOW,Method_STO,Price_Field_STO,MODE_MAIN,  BarShift);
      double VstoSignal = iStochastic(symbolName,Timeframe_STO,Period_STO_K,Period_STO_D,Period_STO_SLOW,Method_STO,Price_Field_STO,MODE_SIGNAL,BarShift);
      string sto = "M:" + DoubleToStr(VstoMain,0) + "／" + DoubleToStr(VstoSignal,0);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,sto);
      fontColor = clrGray;
      if (VstoMain<=DnLimitSto) {
         fontColor = clrLime;
         if (EnableStoFilter) {
            isShort = false;
         }
      } else if (UpLimitSto<=VstoMain) {
         fontColor = clrRed;
         if (EnableStoFilter) {
            isLong = false;
         }
      } else {
         if (EnableStoFilter) {
            isLong = false;
            isShort = false;
         }
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      /*
      // Ichimoku Kinko Hyo

      
      
      
      3、调整期一目均衡表的特征
      1）由上升转为下降的调整阶段，一目均衡表的表现：
      日K线开始由上方进入云层
      日K线下穿基准线
      转换线在基准线之下停留
      迟行线开始下穿日K线。
      
      2）由下降转为上升的调整阶段，一目均衡表的表现：
      日K线开始站在基准线的上方
      转换线上穿基准线
      迟行线上穿日K线
      日K线由下方进入云层，最终上穿云层
      迟行线由云的上方穿出。
      
      4、一目均衡表的其它特征
      市场呈强势之时，通常难以触及云的边线
      市场呈强势之时，通常不会穿透转换线，在穿透转换线时，一般意味着进入调整
      始终未穿透基准线的市势，当开始穿透基准线时，可能意味着较大调整的开始
      价位触及云的上边线后，未能上穿基准线，云层较易被穿透
      迟行线穿透日K线和云层的时候，容易出现暴跌
      在下降市中，通常难以触及基准线。
      
      */
      objName = getObjectName(i, COL_NO_1KH);
      // 1 - MODE_TENKANSEN ; 2 - MODE_KIJUNSEN ; 3 - MODE_SENKOUSPANA ; 4 - MODE_SENKOUSPANB ; 5 - MODE_CHIKOUSPAN
      // int Mode_1KH = 1;
      // 转换线
      double tenkan_sen=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_TENKANSEN,BarShift);
      // 基准线
      double kijun_sen=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_KIJUNSEN,BarShift);
      // 上先行线
      double senkouspana=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_SENKOUSPANA,BarShift);
      // 下先行线
      double senkouspanb=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_SENKOUSPANB,BarShift);
      // 迟行带
      double chikouspan=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_CHIKOUSPAN,Period_1KH_Kijun);
      
      /*
      1、升势（买入信号）
      日K线位于云的上方
      日K线在基准线之上推移（基准线成为下降阻力）
      转换线在基准线的上方推移（超强势的情况下，日K线在转换线上方推移）
      迟行线在日K线的上方
      */
      string IchimokuKinkoHyo = "";
      /*
      if (symbolName == "EURUSD") {
      Print(symbolName+"----iLow(symbolName, Timeframe_1KH, BarShift):" + iLow(symbolName, Timeframe_1KH, BarShift));
      Print(symbolName+"----senkouspana:" + senkouspana);
      Print(symbolName+"----kijun_sen:" + kijun_sen);
      Print(symbolName+"----tenkan_sen:" + tenkan_sen);
      Print(symbolName+"----chikouspan:" + chikouspan);
      Print(symbolName+"----iHigh(symbolName, Timeframe_1KH, Period_1KH_Kijun):" + iHigh(symbolName, Timeframe_1KH, Period_1KH_Kijun));
      if (senkouspana <= iLow(symbolName, Timeframe_1KH, BarShift)) {
         Print(symbolName+"----senkouspana <= iLow(symbolName, Timeframe_1KH, BarShift)");
      }
      if (kijun_sen <= iLow(symbolName, Timeframe_1KH, BarShift)) {
         Print(symbolName+"----kijun_sen <= iLow(symbolName, Timeframe_1KH, BarShift)");
      }
      if (kijun_sen <= tenkan_sen) {
         Print(symbolName+"----kijun_sen <= tenkan_sen");
      }
      if (iHigh(symbolName, Timeframe_1KH, Period_1KH_Kijun) <= chikouspan) {
         Print(symbolName+"----iHigh(symbolName, Timeframe_1KH, Period_1KH_Kijun) <= chikouspan");
      }
      }
      */
      
      if (MathMax(senkouspana, senkouspanb) <= iLow(symbolName, Timeframe_1KH, BarShift)
         && kijun_sen <= iLow(symbolName, Timeframe_1KH, BarShift)
         && kijun_sen <= tenkan_sen
         && iHigh(symbolName, Timeframe_1KH, Period_1KH_Kijun) <= chikouspan
         ) {
         
         if (tenkan_sen <= iLow(symbolName, Timeframe_1KH, BarShift)) {
            IchimokuKinkoHyo = "超多";
         } else {
            IchimokuKinkoHyo = "强多";
         }
      
      }
      /*
      2、降势（卖出信号）
      日K线在云的下方
      日K线在基准线的下方推移（反弹只到转换线的位置，难以反弹到基准线）
      转换线在基准线的下方推移（降势明显的情况下，日K线在转换线的下方推移）
      迟行线在日K线的下方
      */
      else if (iHigh(symbolName, Timeframe_1KH, BarShift) <= MathMin(senkouspana, senkouspanb)
         && iHigh(symbolName, Timeframe_1KH, BarShift) <= kijun_sen
         && tenkan_sen <= kijun_sen
         && chikouspan <= iLow(symbolName, Timeframe_1KH, Period_1KH_Kijun)
         ) {
         
         if (iHigh(symbolName, Timeframe_1KH, BarShift) <= tenkan_sen) {
            IchimokuKinkoHyo = "超空";
         } else {
            IchimokuKinkoHyo = "强空";
         }
      
      } else {
         IchimokuKinkoHyo = "调整";
      }
      
      // 转换线
      double tenkan_sen1=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_TENKANSEN,BarShift+1);
      // 基准线
      double kijun_sen1=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_KIJUNSEN,BarShift+1);
      
      // 转换线
      double tenkan_sen2=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_TENKANSEN,BarShift+2);
      // 基准线
      double kijun_sen2=iIchimoku(symbolName,Timeframe_1KH,Period_1KH_Tenkan,Period_1KH_Kijun,Period_1KH_Senkou,MODE_KIJUNSEN,BarShift+2);
      
      if ((tenkan_sen1 <= kijun_sen1 && kijun_sen < tenkan_sen) || (tenkan_sen2 <= kijun_sen2 && kijun_sen1 < tenkan_sen1)) {
         IchimokuKinkoHyo += " 入多";
      } else if ((kijun_sen1 <= tenkan_sen1 && tenkan_sen < kijun_sen) || (kijun_sen2 <= tenkan_sen2 && tenkan_sen1 < kijun_sen1)) {
         IchimokuKinkoHyo += " 入空";
      } else {
         IchimokuKinkoHyo += " 非入";
      }
      
      //string IchimokuKinkoHyo = "T:" + DoubleToStr(tenkan_sen,si.getDigits()) + "K:" + DoubleToStr(kijun_sen,si.getDigits());
      ObjectSetString(chartId,objName,OBJPROP_TEXT,IchimokuKinkoHyo);
      
      objName = getObjectName(i, COL_NO_BUY);
      if (isLong && !isShort) {
         ObjectSetInteger(chartId,objName,OBJPROP_BGCOLOR,clrGreen);
      } else {
         ObjectSetInteger(chartId,objName,OBJPROP_BGCOLOR,clrBlack);
      }
      
      objName = getObjectName(i, COL_NO_SELL);
      if (!isLong && isShort) {
         ObjectSetInteger(chartId,objName,OBJPROP_BGCOLOR,clrRed);
      } else {
         ObjectSetInteger(chartId,objName,OBJPROP_BGCOLOR,clrBlack);
      }
      
      objName = getObjectName(i, COL_NO_PAIR_NAME);
      if (isLong && !isShort) {
         ObjectSetInteger(chartId,objName,OBJPROP_BGCOLOR,clrGreen);
      } else if (!isLong && isShort) {
         ObjectSetInteger(chartId,objName,OBJPROP_BGCOLOR,clrRed);
      } else {
         ObjectSetInteger(chartId,objName,OBJPROP_BGCOLOR,clrBlack);
      }
      
      if (isAutoMode) {
         if (isLong && !isShort) {
            if (si.getOrderCountL() < 1 && si.getOrderCountS() < 1) {
               createOrderL(si, lotSize, MagicNumber, COMMENT+"Auto");
               si.setOrderCountL(si.getOrderCountL()+1);
            }
         } else if (!isLong && isShort) {
            if (si.getOrderCountS() < 1 && si.getOrderCountL() < 1) {
               createOrderS(si, lotSize, MagicNumber, COMMENT+"Auto");
               si.setOrderCountS(si.getOrderCountS()+1);
            }
         }
         
      }
   }

}

/*
国际各主要外汇市场开盘收盘时间（北京时间）：
新西兰惠灵顿外汇市场： 04：00-12：00（冬令时）； 05：00-13：00 （夏时制）。
澳大利亚悉尼外汇市场：06：00-14：00（冬令时）； 07：00-15：00 （夏时制）。
日 本东京外汇市场： 08：00-14：30（冬令时）； 08：00-14:30 （夏时制）
德国法兰克福外汇市场：：15:00-22:00（夏时制）； 16:00-23：00（冬令时）。
英国伦敦外汇市场： 16：30-23：30（夏时制）； 17：30-00：30（冬令时）。
美国纽约外汇市场： 20：00-03：00（夏时制）； 21：00-04：00（冬令时）
*/
bool isAsiaTradeTime() {
   datetime nowGMT8 = TimeGMT() + 8*60*60;
   // 04:00---15:00
   int h=TimeHour(nowGMT8);
   if (4<=h && h<=15) {
      return true;
   }
   return false;
}
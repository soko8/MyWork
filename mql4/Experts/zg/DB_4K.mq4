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
//#define COL_NO_STO2                                  28
//#define COL_NO_STO3                                  29
//#define COL_NO_                                  30

#define ROW_COUNT                                    28



input int                  MagicNumber=888888;
input ENUM_TIMEFRAMES      TimeFrame_CurrencyStrength=PERIOD_D1;
input string               Prefix="";
input string               Suffix="";
input double               LotSize=0.01;


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
const int                        Period_MA1_Short  = 20;
const int                        Period_MA1_Medium = 50;
const int                        Period_MA1_Long   = 75;
const int                        Shift_MA1 = 0;
const ENUM_MA_METHOD             Method_MA1 = MODE_EMA;
const ENUM_APPLIED_PRICE         Applied_Price_MA1 = PRICE_CLOSE;
/****************************MA1**********************************************/

/****************************MA2**********************************************/
const ENUM_TIMEFRAMES            Timeframe_MA2 = PERIOD_M30;
const int                        Period_MA2_Short  = 20;
const int                        Period_MA2_Medium = 50;
const int                        Period_MA2_Long   = 75;
const int                        Shift_MA2 = 0;
const ENUM_MA_METHOD             Method_MA2 = MODE_EMA;
const ENUM_APPLIED_PRICE         Applied_Price_MA2 = PRICE_CLOSE;
/****************************MA2**********************************************/

/****************************MA3**********************************************/
const ENUM_TIMEFRAMES            Timeframe_MA3 = PERIOD_H1;
const int                        Period_MA3_Short  = 25;
const int                        Period_MA3_Medium = 50;
const int                        Period_MA3_Long   = 75;
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






#import "DrawDashBoard.ex4"
   void DrawDashBoard(CList *symbolList);
   void refreshOrdersData(CList *symbolList, int Magic_Number);
   //void refreshIndicatorsData(CList *symbolList, string &CurrencyArray[]);
   double GetAdrValues(string pairName, double point);
   int getRelativeStrength(double bidRatio);
   string getObjectName(int rowIndex, int columnIndex);
#import


      int                  PairCount;
      string               TradePairs[];
//      double               BidRatios[];
      
      CList*               SymbolList;
      double               lotSize;

string Currencies[];
//string Currencies[] = {"USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "NZD"};
string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};

const int                  StartX=4;
const int                  StartY=4;
const int                  SLIPPAGE=20;
const string               COMMENT="DB_";


const int                  LimitSpread=30;
const int                  UpLimitRSI=75;
const int                  DnLimitRSI=25;
const int                  UpLimitCCI=100;
const int                  DnLimitCCI=-100;
const int                  UpLimitSto=80;
const int                  DnLimitSto=20;

const int                  UpLimitBidRatioBuy=90;
const int                  DnLimitBidRatioBuy=75;
const int                  UpLimitBidRatioSell=25;
const int                  DnLimitBidRatioSell=10;
const double               UpLimitGap=3.5;
const double               DnLimitGap=-3.5;
const double               UpLimitCurrency=6.0;
const double               DnLimitCurrency=2.0;


void initSymbols() {
   SymbolList = new CList;
   int size = ArraySize(TradePairs);
   int currencySize = 0;
   for (int i=0; i<size; i++) {
      string pair = TradePairs[i];
      SymbolInfo *si = new SymbolInfo(pair, Prefix, Suffix);
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
   lotSize = LotSize;
   ArrayCopy(TradePairs,DefaultPairs);
   PairCount = ArraySize(TradePairs);
   initSymbols();
   DrawDashBoard(SymbolList);
   
   refreshOrdersData(SymbolList, MagicNumber);
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

void OnTick() {

   
}

void OnTimer() {

   refreshIndicatorsData(SymbolList, Currencies);
   refreshOrdersData(SymbolList, MagicNumber);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   long chartId = 0;
   if (id == CHARTEVENT_OBJECT_CLICK) {
      // close all positive profit long orders
      if ("H1btnBuy" == sparam) {
         closeProfitL("Manually Close Profit Long Orders", SLIPPAGE);
      } else
      
      // close all long orders
      if ("H1btnCloseBuy" == sparam) {
         closeAllL("Manually Close All Long Orders");
      } else
      
      // close all positive profit short orders
      if ("H1btnSell" == sparam) {
         closeProfitS("Manually Close Profit Short Orders", SLIPPAGE);
      } else
      
      // close all short orders
      if ("H1btnCloseSell" == sparam) {
         closeAllL("Manually Close All Short Orders");
      } else 
      
      // new Buy Order
      if ((0 <= StringFind(sparam, "btnBuy"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnBuy")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         createOrderL(si, COMMENT+"Manually");
         
      } else 
      
      // close a Buy Order
      if ((0 <= StringFind(sparam, "btnCloseBuy"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnCloseBuy")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         closeOrderL(si, "Manually Close Buy Order.");
      } else 
      
      // new Sell Order
      if ((0 <= StringFind(sparam, "btnSell"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnSell")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         createOrderS(si, COMMENT+"Manually");
         
      } else 
      
      // close a Sell Order
      if ((0 <= StringFind(sparam, "btnCloseSell"))) {
         int index = StrToInteger(StringSubstr(sparam, StringLen("btnCloseSell")));
         SymbolInfo *si = SymbolList.GetNodeAtIndex(index);
         closeOrderS(si, "Manually Close Sell Order.");
         
      }
      
      else {
      
      }
      
   }
   
}

// TODO  SL AND TP
void createOrderL(SymbolInfo *si, string comnt="", double slp=0.0, double tpp=0.0) {
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
      // TODO refresh row
   }
}

void createOrderS(SymbolInfo *si, string comnt="", double slp=0.0, double tpp=0.0) {
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
      // TODO refresh row
   }
}

void closeOrderL(SymbolInfo *si, string message="") {
   int cnt = OrdersTotal();
   string symbolName = si.getRealName();
   for (int pos=0; pos<cnt; pos++) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OrderSymbol()!=symbolName) continue;
      if(OP_BUY!=OrderType()) continue;
      double closePrice = MarketInfo(symbolName, MODE_BID);
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
            msg += " Bid=" + DoubleToStr(closePrice, si.getDigits());
            Alert(msg);
         }
      }
   }
}

void closeOrderS(SymbolInfo *si, string message="") {
   int cnt = OrdersTotal();
   string symbolName = si.getRealName();
   for (int pos=0; pos<cnt; pos++) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OrderSymbol()!=symbolName) continue;
      if(OP_SELL!=OrderType()) continue;
      double closePrice = MarketInfo(symbolName, MODE_ASK);
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
            msg += " Ask=" + DoubleToStr(closePrice, si.getDigits());
            Alert(msg);
         }
      }
   }
}

void closeAllL(string message="") {
   int cnt = OrdersTotal();
   for (int pos=0; pos<cnt; pos++) {
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

void closeAllS(string message="") {
   int cnt = OrdersTotal();
   for (int pos=0; pos<cnt; pos++) {
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

void closeProfitL(string message="", int slippagePerLot=0) {
   int cnt = OrdersTotal();
   for (int pos=0; pos<cnt; pos++) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OP_BUY!=OrderType()) continue;
      if ((OrderProfit()+OrderCommission()+OrderSwap()) < (OrderLots()*slippagePerLot)) continue;
      
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

void closeProfitS(string message="", int slippagePerLot=0) {
   int cnt = OrdersTotal();
   for (int pos=0; pos<cnt; pos++) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OP_SELL!=OrderType()) continue;
      if ((OrderProfit()+OrderCommission()+OrderSwap()) < (OrderLots()*slippagePerLot)) continue;
      
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
      // Spread
      objName = getObjectName(i, COL_NO_SPREAD);
      int spread = (int)MarketInfo(symbolName,MODE_SPREAD);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,IntegerToString(spread, 3));
      if (LimitSpread < spread) {
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
      if (UpLimitRSI <= Vrsi) {
         fontColor = clrRed;
      } else if (Vrsi <= DnLimitRSI) {
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
      if (UpLimitCCI <= Vcci) {
         fontColor = clrRed;
      } else if (Vcci <= DnLimitCCI) {
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
      
      // BidRatio
      objName = getObjectName(i, COL_NO_BID_RATIO);
      string bidRatio = DoubleToStr(BidRatios[i], 1);
      fontColor = clrGray;
      if (DnLimitBidRatioBuy<=BidRatios[i] && BidRatios[i]<=UpLimitBidRatioBuy) {
         fontColor = clrLime;
      } else if (DnLimitBidRatioSell<=BidRatios[i] && BidRatios[i]<=UpLimitBidRatioSell) {
         fontColor = clrRed;
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
      
      // BuySellRatio
      objName = getObjectName(i, COL_NO_BS_RATIO);
      string BSRatio = DoubleToStr(BuyRatios[i], 1)+"－"+DoubleToStr(SellRatios[i], 1)+"＝"+DoubleToStr((BuyRatios[i]-SellRatios[i]), 1);
      ObjectSetString(chartId,objName,OBJPROP_TEXT,BSRatio);
      fontColor = clrGray;
      if (UpLimitCurrency<=BuyRatios[i] || SellRatios[i]<=DnLimitCurrency) {
         fontColor = clrLime;
      } else if (UpLimitCurrency<=SellRatios[i] || BuyRatios[i]<=DnLimitCurrency) {
         fontColor = clrRed;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
      
      // GAP
      objName = getObjectName(i, COL_NO_GAP);
      fontColor = clrGray;
      if (UpLimitGap<=GAPs[i]) {
         fontColor = clrLime;
      } else if (GAPs[i]<=DnLimitGap) {
         fontColor = clrRed;
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
      } else if (UpLimitSto<=VstoMain) {
         fontColor = clrRed;
      }
      ObjectSetInteger(chartId,objName,OBJPROP_COLOR,fontColor);
   }

}
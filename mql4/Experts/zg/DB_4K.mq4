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

input int                  MagicNumber=888888;
input ENUM_TIMEFRAMES      TimeFrame_CurrencyStrength=PERIOD_D1;
input string               Prefix="";
input string               Suffix="";

#import "DrawDashBoard.ex4"
   void DrawDashBoard(CList *symbolList);
   void refreshOrdersData(CList *symbolList, int MagicNumber);
   void refreshIndicatorsData(CList *symbolList);
#import

/*
#import "GAPUtils.ex4"
void getAllPairBidRatio(string &pairs[], ENUM_TIMEFRAMES timeframe, double &outBidRatios[]);
#import
*/



      int                  PairCount;
      string               TradePairs[];
      double               BidRatios[];
string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
CList* SymbolList;

const int StartX=4;
const int StartY=4;

string Currencies[] = {"USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "NZD"};

void initSymbols() {
   SymbolList = new CList;
   int size = ArraySize(TradePairs);
   for (int i=0; i<size; i++) {
      SymbolInfo *si = new SymbolInfo(TradePairs[i], Prefix, Suffix);
      SymbolList.Add(si);
   }
}

int OnInit() {
   ArrayCopy(TradePairs,DefaultPairs);
   PairCount = ArraySize(TradePairs);
   initSymbols();
   DrawDashBoard(SymbolList);
   
   refreshOrdersData(SymbolList, MagicNumber);
   refreshIndicatorsData(SymbolList);

//--- create timer
   EventSetTimer(1);
   
//---
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();
}

void OnTick() {

   
}

void OnTimer() {

   //refreshTable();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}


/*
void refreshTable() {
   long chartId = 0;
   getAllPairBidRatio(TradePairs, TimeFrame_CurrencyStrength, BidRatios);
   int BaseRelativeStrengths[];
   getAllPairBaseRelativeStrength(BidRatios, BaseRelativeStrengths);
   int RelativeStrengths[];
   getAllPairRelativeStrength(BaseRelativeStrengths, RelativeStrengths);
   double CurrencyStrengths[];
   getAllCurrencyStrength(TradePairs,BaseRelativeStrengths,Currencies,CurrencyStrengths);
   double BuyRatios[],SellRatios[];
   getAllPairBuySellRatio(TradePairs,Currencies,CurrencyStrengths,BuyRatios,SellRatios);
   double BSRatios[];
   getAllPairBSRatio(BuyRatios, SellRatios, BSRatios);
   for (int i=0; i<PairCount; i++) {
      string pairNm = TradePairs[i];
      //double rsi = iRSI(pairNm,0,14,PRICE_CLOSE,1);
      ObjectSetString(chartId,"lblBidRatio1"+pairNm,OBJPROP_TEXT,DoubleToStr(BidRatios[i],2));
      ObjectSetString(chartId,"lblRelativeStrength1"+pairNm,OBJPROP_TEXT,IntegerToString(RelativeStrengths[i]));
      ObjectSetString(chartId,"lblBSRatio1"+pairNm,OBJPROP_TEXT,DoubleToStr(BSRatios[i], 2));
      ObjectSetString(chartId,"lblRSI"+pairNm,OBJPROP_TEXT,BuyRatios[i]);
      ObjectSetString(chartId,"lblCCI"+pairNm,OBJPROP_TEXT,SellRatios[i]);
      //ObjectSetString(chartId,btnName,OBJPROP_TEXT,text);
      //ObjectSetInteger(chartId,name,OBJPROP_COLOR,fontColor);
      //ObjectSetInteger(chartId,btnName,OBJPROP_COLOR,textColor);
      //ObjectSetInteger(chartId,name,OBJPROP_BGCOLOR,backgroundColor);
   
   }
}

double getBidRatio(string symbol, ENUM_TIMEFRAMES timeframe=PERIOD_D1) export {
   double highValue = iHigh(symbol, timeframe, 0);
   double lowValue = iLow(symbol, timeframe, 0);
   double range = highValue - lowValue;
   if (NormalizeDouble(range, 5) < 0.00001) {
      return 0.0;
   }
   double bidRatio = 100.0 * ((MarketInfo(symbol, MODE_BID) - lowValue) / range );
   return bidRatio;
}

void getAllPairBidRatio(const string &pairs[], const ENUM_TIMEFRAMES timeframe, double &outBidRatios[]) export {
   int size = ArraySize(pairs);
   ArrayResize(outBidRatios, size);
   for (int i=0; i<size; i++) {
      double bidRatio = getBidRatio(pairs[i], timeframe);
      outBidRatios[i] = bidRatio;
   }
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

void getAllPairBaseRelativeStrength(const double &bidRatios[], int &outBaseRelativeStrengths[]) export {
   int size = ArraySize(bidRatios);
   ArrayResize(outBaseRelativeStrengths, size);
   for (int i=0; i<size; i++) {
      double bidRatio = bidRatios[i];
      int relativeStrength = getRelativeStrength(bidRatio);
      outBaseRelativeStrengths[i] = relativeStrength;
   }
}

void getAllPairRelativeStrength(const int &baseRelativeStrengths[], int &outRelativeStrengths[]) export {
   int size = ArraySize(baseRelativeStrengths);
   ArrayResize(outRelativeStrengths, size);
   for (int i=0; i<size; i++) {
      int baseRelativeStrength = baseRelativeStrengths[i];
      int quoteRelativeStrength = 9-baseRelativeStrength;
      int relativeStrength = baseRelativeStrength - quoteRelativeStrength;
      outRelativeStrengths[i] = relativeStrength;
   }
}

void getAllCurrencyStrength(const string &pairs[], const int &BaseRelativeStrengths[], const string &currencies[], double &outCurrencyStrengths[]) export {
   int pairSize = ArraySize(pairs);
   int currencySize = ArraySize(currencies);
   ArrayResize(outCurrencyStrengths, currencySize);
   for(int k=0; k<currencySize; k++) {
      outCurrencyStrengths[k] = 0;
   }
   for (int i=0; i<pairSize; i++) {
      string pair = pairs[i];
      int BaseRelativeStrength = BaseRelativeStrengths[i];
      int QuoteRelativeStrength = 9-BaseRelativeStrength;
      for (int j=0; j<currencySize; j++) {
         string currency = currencies[j];
         if (currency == StringSubstr(pair, 0, 3)) {
            outCurrencyStrengths[j] += BaseRelativeStrength;
         }
         if (currency == StringSubstr(pair, 3, 3)) {
            outCurrencyStrengths[j] += QuoteRelativeStrength;
         }
      }
      
   }
   
   for(int k=0; k<currencySize; k++) {
      outCurrencyStrengths[k] = outCurrencyStrengths[k]/(currencySize-1);
   }
}

void getAllPairBuySellRatio(const string &pairs[],const string &currencies[], const double &currencyStrengths[], double &outBuyRatios[], double &outSellRatios[]) export {
   int pairSize = ArraySize(pairs);
   int currencySize = ArraySize(currencies);
   ArrayResize(outBuyRatios, pairSize);
   ArrayResize(outSellRatios, pairSize);
   for (int i=0; i<pairSize; i++) {
      string pair = pairs[i];
      for (int j=0; j<currencySize; j++) {
         string currency = currencies[j];
         if (currency == StringSubstr(pair, 0, 3)) {
            outBuyRatios[i] = currencyStrengths[j];
         }
         if (currency == StringSubstr(pair, 3, 3)) {
            outSellRatios[i] = currencyStrengths[j];
         }
      }
   }

}

void getAllPairBSRatio(const double &buyRatios[], const double &sellRatios[], double &outBSRatios[]) export {
   int pairSize = ArraySize(buyRatios);
   ArrayResize(outBSRatios, pairSize);
   for (int i=0; i<pairSize; i++) {
      outBSRatios[i] = buyRatios[i] - sellRatios[i];
   }
}

void getAllPairGAP(const double &BSRatios[], const double &PreviousBSRatios[], double &outGAPs[]) export {
   int pairSize = ArraySize(BSRatios);
   ArrayResize(outGAPs, pairSize);
   for (int i=0; i<pairSize; i++) {
      outGAPs[i] = BSRatios[i] - PreviousBSRatios[i];
   }
}
*/
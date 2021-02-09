//+------------------------------------------------------------------+
//|                                                     GAPUtils.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+

double getBidRatio(string symbol, ENUM_TIMEFRAMES timeframe=PERIOD_D1) export {
   double highValue = iHigh(symbol, timeframe, 0);
   double lowValue = iLow(symbol, timeframe, 0);
   double range = highValue - lowValue;
   if (NormalizeDouble(range, 5) < 0.00001) {
      return 0.0;
   }
   double bidRatio = 100.0 * ((MarketInfo(symbol, MODE_BID) - lowValue) / range );
   return NormalizeDouble(bidRatio, 3);
}

void getAllPairBidRatio(const string &pairs[], const ENUM_TIMEFRAMES timeframe, double &outBidRatios[]) export {
   int size = ArraySize(pairs);
   ArrayResize(outBidRatios, size);
   for (int i=0; i<size; i++) {
      double bidRatio = getBidRatio(pairs[i], timeframe);
      outBidRatios[i] = bidRatio;
   }
}

/*
double getBidRatio(string symbol) export {
   double range = (MarketInfo(symbol, MODE_HIGH) - MarketInfo(symbol, MODE_LOW));
   double bidRatio = 100.0 * ((MarketInfo(symbol, MODE_BID) - MarketInfo(symbol, MODE_LOW)) / range );
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

/*
void getAllPairBidRatio(const string &pairs[], double &outBidRatios[]) export {
   int size = ArraySize(pairs);
   ArrayResize(outBidRatios, size);
   for (int i=0; i<size; i++) {
      double bidRatio = getBidRatio(pairs[i]);
      outBidRatios[i] = bidRatio;
   }
}
*/

void getAllPairBaseRelativeStrength(const double &bidRatios[], int &outBaseRelativeStrengths[]) export {
   int size = ArraySize(bidRatios);
   ArrayResize(outBaseRelativeStrengths, size);
   for (int i=0; i<size; i++) {
      double bidRatio = bidRatios[i];
      int relativeStrength = getRelativeStrength(bidRatio);
      outBaseRelativeStrengths[i] = relativeStrength;
   }
}

/*
void getAllPairBaseRelativeStrength(const string &pairs[], int &outBaseRelativeStrengths[]) export {
   int size = ArraySize(pairs);
   ArrayResize(outBaseRelativeStrengths, size);
   for (int i=0; i<size; i++) {
      double bidRatio = getBidRatio(pairs[i]);
      int relativeStrength = getRelativeStrength(bidRatio);
      outBaseRelativeStrengths[i] = relativeStrength;
   }
}
*/

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

void getAllCurrencyStrength(const string &pairs[], const int &BaseRelativeStrengths[], const string &currencies[], int &outCurrencyStrengths[]) export {
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

void getAllPairBuySellRatio(const string &pairs[],const string &currencies[], const int &currencyStrengths[], double &outBuyRatios[], double &outSellRatios[]) export {
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
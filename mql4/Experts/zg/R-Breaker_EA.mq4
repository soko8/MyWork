//+------------------------------------------------------------------+
//|                                                 R-Breaker_EA.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property strict
//--- input parameters
input ENUM_TIMEFRAMES            TimeFrame=PERIOD_D1;
input int                        MagicNumber=16888;

enum enSignalType {
   Break_Buy = 2,
   Setup_Buy = 1,
   None_Signal = 0,
   Setup_Sell = -1,
   Break_Sell = -2
};

datetime                         previousBarTime=0;
double                           values[7];
int                              ticketId=-1;
int                              takeProfitPips=10;
double                           tp;

int OnInit() {
   tp = pip2price(takeProfitPips);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   if (isNewBar(previousBarTime, iTime(NULL, TimeFrame, 0))) {
      previousBarTime = iTime(NULL, TimeFrame, 0);
      getRBreakerValues(iHigh(NULL, TimeFrame, 1), iLow(NULL, TimeFrame, 1), iClose(NULL, TimeFrame, 1), values);
   }
   
   enSignalType signal = getSignal();
   
   switch(signal) {
      case Break_Buy : {
         if (0 <= ticketId) {
            break;
         }
         double lotSize = getLot();
         double slPrice = values[1];
         double tpPrice = Ask + tp;
         RefreshRates();
         ticketId = OrderSend(_Symbol, OP_BUY , lotSize, Ask, 0, slPrice, tpPrice, "Break_Buy", MagicNumber, 0, clrBlue);
         break;
      }
      
      case Setup_Buy : {
         if (0 <= ticketId) {
            break;
         }
         double lotSize = getLot();
         double slPrice = values[6];
         double tpPrice = values[2];
         RefreshRates();
         ticketId = OrderSend(_Symbol, OP_BUY , lotSize, Ask, 0, slPrice, tpPrice, "Setup_Buy", MagicNumber, 0, clrBlue);
         break;
      }
      
      case Setup_Sell : {
         if (0 <= ticketId) {
            break;
         }
         double lotSize = getLot();
         double slPrice = values[0];
         double tpPrice = values[4];
         RefreshRates();
         ticketId = OrderSend(_Symbol, OP_SELL , lotSize, Bid, 0, slPrice, tpPrice, "Setup_Sell", MagicNumber, 0, clrRed);
         break;
      }
      
      case Break_Sell : {
         if (0 <= ticketId) {
            break;
         }
         double lotSize = getLot();
         double slPrice = values[5];
         double tpPrice = Bid - tp;
         RefreshRates();
         ticketId = OrderSend(_Symbol, OP_SELL , lotSize, Bid, 0, slPrice, tpPrice, "Break_Sell", MagicNumber, 0, clrRed);
         break;
      }
      case None_Signal : break;
      default: ;
   }
   
   if (0 <= ticketId) {
      if (OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY)) {
         if (0 < OrderCloseTime()) {
            ticketId = -1;
         }
      } else {
         //ticketId = -1;
      }
   }
}

double pip2price(double pips) {
   int vdigits = (int) MarketInfo(Symbol(), MODE_DIGITS);
   double vpoint = MarketInfo(Symbol(), MODE_POINT);
   double price = NormalizeDouble(10*vpoint*pips, vdigits);
   return price;
}

enSignalType getSignal() {
   if (values[0] < Bid) {
      return Break_Buy;
   }
   
   if (values[5] < Bid) {
      if ( values[5]<=iHigh(NULL, TimeFrame, 0) && (values[6]<=iLow(NULL, TimeFrame, 0) && iLow(NULL, TimeFrame, 0)<=values[5]) ) {
         return Setup_Buy;
      }
   }
   
   if (Ask < values[1]) {
      if ( iLow(NULL, TimeFrame, 0)<=values[1] && (values[1]<=iHigh(NULL, TimeFrame, 0) && iHigh(NULL, TimeFrame, 0)<=values[0]) ) {
         return Setup_Sell;
      }
   }
   
   if (Ask < values[6]) {
      return Break_Sell;
   }
   
   return None_Signal;
}

double getLot() {
   return 0.01;
}

bool isNewBar(datetime preBarTime, datetime curBarTime) {
   if (preBarTime == curBarTime) {
      return false;
   }
   return true;
}

void getRBreakerValues(double high, double low, double close, double& array[]) {
   double pivot = (high+low+close)/3;
   double breakBuy = high + (pivot-low)*2;
   double setupSell = pivot + (high - low);
   double revSell = pivot*2 - low;
   double revBuy = pivot*2 - high;
   double setupBuy = pivot - (high - low);
   double breakSell = low - (high-pivot)*2;
   
   array[0] = breakBuy;
   array[1] = setupSell;
   array[2] = revSell;
   array[3] = pivot;
   array[4] = revBuy;
   array[5] = setupBuy;
   array[6] = breakSell;
}
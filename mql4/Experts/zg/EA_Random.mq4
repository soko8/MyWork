//+------------------------------------------------------------------+
//|                                                    EA_Random.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input double            LotSize=1.0;
input ENUM_TIMEFRAMES   TimeFrame=PERIOD_CURRENT;
input bool              EnableTimeTrigger=false;
input string            StartOpenOrderTime_GMT="10:00:00";
input int               MagicNumber=111111;

      bool              isOpened=false;
      datetime          previousBarTime=0;
      
      int               startOpenTimeHour = 0;
      int               startOpenTimeMinute = 0;
      int               startOpenTimeSeconds = 0;

int OnInit() {
   if (EnableTimeTrigger) {
      startOpenTimeHour = StrToInteger(StringSubstr(StartOpenOrderTime_GMT, 0, 2));
      startOpenTimeMinute = StrToInteger(StringSubstr(StartOpenOrderTime_GMT, 3, 2));
      startOpenTimeSeconds = StrToInteger(StringSubstr(StartOpenOrderTime_GMT, 6, 2));
   }
   MathSrand(GetTickCount());
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
}

void OnTick() {
   if (isNewCycle(previousBarTime, iTime(NULL,TimeFrame,0))) {
      closeAll();
      isOpened=false;
      previousBarTime = iTime(NULL,TimeFrame,0);
   }
   
   if (isOpened) {
      return;
   }
   
   bool  doOpen = false;
   
   if (EnableTimeTrigger) {
      datetime now = TimeGMT();
      int nowHour = TimeHour(now);
      int nowMinute = TimeMinute(now);
      int nowSeconds = TimeSeconds(now);
      if (startOpenTimeHour<=nowHour && startOpenTimeMinute<=nowMinute && startOpenTimeSeconds<=nowSeconds) {
         doOpen = true;
      }
      
   } else {
      doOpen = true;
   }
   
   if (doOpen) {
      /*
      if (Open[1] < Close[1]) {
         if (-1 < OrderSend(_Symbol, OP_BUY , LotSize, Ask, 0, 0, 0, "", MagicNumber, 0, clrBlue)) {
            isOpened=true;
         }
      } else {
         if (-1 < OrderSend(_Symbol, OP_SELL , LotSize, Bid, 0, 0, 0, "", MagicNumber, 0, clrRed)) {
            isOpened=true;
         }
      }
      */
      int rand1 = MathRand();
      int rand2 = MathRand();
      if (rand1 < rand2) {
         if (-1 < OrderSend(_Symbol, OP_BUY , LotSize, Ask, 0, 0, 0, "", MagicNumber, 0, clrBlue)) {
            isOpened=true;
         }
      } else {
         if (-1 < OrderSend(_Symbol, OP_SELL , LotSize, Bid, 0, 0, 0, "", MagicNumber, 0, clrRed)) {
            isOpened=true;
         }
      }
   }
}

bool isNewCycle(datetime preTime, datetime curTime) {
   if (preTime == curTime) {
      return false;
   }
   
   return true;
}

void closeAll() {
   int total=OrdersTotal();
   for(int pos=0; pos<total; pos++) {
      if(OrderSelect(pos, SELECT_BY_POS)) {
         if (MagicNumber != OrderMagicNumber()) {
            continue;
         }
         if (OP_BUY == OrderType()) {
            if (!OrderClose(OrderTicket(), OrderLots(), Bid, 0)) {
               Print("Order Close Failed.");
            }
         } else if (OP_SELL == OrderType()) {
            if (!OrderClose(OrderTicket(), OrderLots(), Ask, 0)) {
               Print("Order Close Failed.");
            }
         }

      }
   }
}

/**
bool isNewDay() {
   return isNewCycle(previousBarTime, iTime(NULL,PERIOD_D1,0));
}
*/
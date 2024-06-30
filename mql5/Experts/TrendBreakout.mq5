//+------------------------------------------------------------------+
//|                                                   GodOfHands.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

#define COMMENT               "TrendBreakout"

enum TREND_TYPE {
  SHORT=-1,
  NONE=0,
  LONG=1,
};


//--- input parameters
input int               In_Stoploss_Points=100;
input int               In_TakeProfit_Points=200;
input int               In_TrailingStop_Points=100;
input bool              In_Lot_Fixed=true;
input double            In_Lots=0.1;
input double            In_Lots_Rate=10000/0.5;
input int               In_Offset_To_HighLow_Points=0;
input int               MagicNumber=168168;

bool                    isInitedOrderB = false;
bool                    isInitedOrderS = false;
datetime                timeNowBar = 0;
bool                    isFixedLot = false;
double                  lotsFixed = 0.0;
double                  lotsRisk = 0.0;
double                  _lots = 0.0;
double                  _sl = 0.0;
double                  _tp = 0.0;
double                  _ts = 0.0;
double                  _offset = 0.0;
double                  startTrailingStopPriceB = 0.0;
double                  startTrailingStopPriceS = 0.0;

CTrade                  trade;
MqlTradeResult          TradeResultB;
MqlTradeResult          TradeResultS;


const string            sTime = " 09:00:00";
const string            eTime = " 05:00:00";

int OnInit() {
   initWhenNewBar();
   timeNowBar = 0;
   isFixedLot = In_Lot_Fixed;
   lotsFixed = In_Lots;
   lotsRisk = In_Lots_Rate;
   _lots = getLots();
   _sl = In_Stoploss_Points * _Point;
   _tp = In_TakeProfit_Points * _Point;
   _ts = In_TrailingStop_Points * _Point;
   _offset = In_Offset_To_HighLow_Points * _Point;
   
   
   trade.SetExpertMagicNumber(MagicNumber);
   
   EventSetTimer(1);
   

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   EventKillTimer();
   
}

void OnTick() {

   
}

void OnTimer() {
   if (!isTradingTime()) return;

   if (isNewBar()) {
      initWhenNewBar();
      setBuy();
      setSell();
   } else {
      TrailingStop();
   }
}

void OnTrade() {

   
}

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {

   
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}

void OnBookEvent(const string &symbol) {

   
}

bool isTradingTime() {
   // ????????
   datetime now = TimeLocal();
   string ymd = TimeToString(now, TIME_DATE);

   datetime begin = StringToTime(ymd + sTime);
   datetime stop = StringToTime(ymd + eTime);
   
   if (stop <= begin) {
      if (begin <= now || now < stop) {
         return true;
      }
      return false;
   }
   
   if (begin <= now && now < stop) {
      return true;
   }
   return false;
}

bool isTrendLong() {
   return true;
}

bool isTrendShort() {
   return true;
}

bool isNewBar() {
   datetime currentBarTime = iTime(NULL, 0 , 0);
   if (timeNowBar == currentBarTime) {
      return false;
   }
   timeNowBar = currentBarTime;
   return true;
}

void initWhenNewBar() {
   clearActiveOrders();
   clearPendingOrders();
   isInitedOrderB = false;
   isInitedOrderS = false;
   startTrailingStopPriceB = 0.0;
   startTrailingStopPriceS = 0.0;
}

double getLots() {
   if (isFixedLot) return lotsFixed;
   double marginFree = AccountInfoDouble(ACCOUNT_EQUITY);
   double result = (int (marginFree / lotsRisk * 100)) / 100;
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   result = MathMax(result, minLot);
   return result;
}

bool hasActiveOrder() {
   ulong order_ticket;
   for(int i=0; i<PositionsTotal(); i++) {
      if((order_ticket=PositionGetTicket(i))>0)
         if(MagicNumber==PositionGetInteger(POSITION_MAGIC))
            if(_Symbol==PositionGetString(POSITION_SYMBOL))
               return true;
   }
   return false;
}

void clearActiveOrders() {
   ulong order_ticket;
   for(int i=PositionsTotal()-1; 0<=i; i--) {
      if((order_ticket=PositionGetTicket(i)) <= 0) continue;
      if(MagicNumber != PositionGetInteger(POSITION_MAGIC)) continue;
      if(_Symbol != PositionGetString(POSITION_SYMBOL)) continue;
      if (trade.PositionClose(order_ticket)) {
         Print("Position@", order_ticket, " is closed. Symbol(", _Symbol, ") Order Type==", EnumToString((ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE)));
      }
   }
}

void clearPendingOrders() {
   ulong order_ticket;
   for(int i=OrdersTotal()-1; 0<=i; i--) {
      if((order_ticket=OrderGetTicket(i)) <= 0) continue;
      if(MagicNumber != OrderGetInteger(ORDER_MAGIC)) continue;
      if(_Symbol != OrderGetString(ORDER_SYMBOL)) continue;
      if (trade.OrderDelete(order_ticket)) {
         Print("Pending Order@", order_ticket, " is closed. Symbol(", _Symbol, ") Order Type==", EnumToString((ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE)));
      }
   }
}

void setBuy() {
   if (isInitedOrderB) return;

   double slPrice = 0.0;
   double tpPrice = 0.0;
   double openPrice = iHigh(NULL, 0, 1) + _offset;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if (openPrice <= bid) {
      openPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      slPrice = openPrice - _sl;
      tpPrice = openPrice + _tp;
      if (trade.Buy(_lots, NULL, openPrice, slPrice, tpPrice, COMMENT)) {
         trade.Result(TradeResultB);
         startTrailingStopPriceB = openPrice + _ts;
         isInitedOrderB = true;
         MqlTradeResultPrint(TradeResultB);
      }
      return;
   }
   
   slPrice = openPrice - _sl;
   tpPrice = openPrice + _tp;
   if (trade.BuyStop(_lots, openPrice, NULL, slPrice, tpPrice, ORDER_TIME_GTC, 0, COMMENT)) {
      trade.Result(TradeResultB);
      startTrailingStopPriceB = openPrice + _ts;
      isInitedOrderB = true;
      MqlTradeResultPrint(TradeResultB);
   }
}


void setSell() {
   if (isInitedOrderS) return;

   double slPrice = 0.0;
   double tpPrice = 0.0;
   double openPrice = iLow(NULL, 0, 1) - _offset;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if (ask <= openPrice) {
      openPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      slPrice = openPrice + _sl;
      tpPrice = openPrice - _tp;
      if (trade.Sell(_lots, NULL, openPrice, slPrice, tpPrice, COMMENT)) {
         trade.Result(TradeResultS);
         startTrailingStopPriceS = openPrice - _ts;
         isInitedOrderS = true;
         MqlTradeResultPrint(TradeResultS);
      }
      return;
   }
   
   slPrice = openPrice + _sl;
   tpPrice = openPrice - _tp;
   if (trade.SellStop(_lots, openPrice, NULL, slPrice, tpPrice, ORDER_TIME_GTC, 0, COMMENT)) {
      trade.Result(TradeResultS);
      startTrailingStopPriceS = openPrice - _ts;
      isInitedOrderS = true;
      MqlTradeResultPrint(TradeResultS);
   }
}

void TrailingStop() {
   ulong order_ticket;
   for(int i=PositionsTotal()-1; 0<=i; i--) {
      if((order_ticket=PositionGetTicket(i)) <= 0) continue;
      if(MagicNumber != PositionGetInteger(POSITION_MAGIC)) continue;
      if(_Symbol != PositionGetString(POSITION_SYMBOL)) continue;
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double oldSl = PositionGetDouble(POSITION_SL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
      if (POSITION_TYPE_BUY == type) {
         if (startTrailingStopPriceB < bid) {
            double newSl = ask - _ts;
            if (oldSl < newSl) {
               double newTp = ask + _tp;
               if (trade.PositionModify(order_ticket, newSl, newTp)) {
                  trade.Result(TradeResultB);
                  MqlTradeResultPrint(TradeResultB);
               }
            }
         }
         
      } else {
         if (ask < startTrailingStopPriceS) {
            double newSl = bid + _ts;
            if (newSl < oldSl) {
               double newTp = bid - _tp;
               if (trade.PositionModify(order_ticket, newSl, newTp)) {
                  trade.Result(TradeResultS);
                  MqlTradeResultPrint(TradeResultS);
               }
            }
         }
      }
   }
}

void MqlTradeResultPrint(MqlTradeResult &tradeResult) {
   string text = " retcode=" + IntegerToString(tradeResult.retcode) + "\r\n";
   text += " deal=" + IntegerToString(tradeResult.deal) + "\r\n";
   text += " order=" + IntegerToString(tradeResult.order) + "\r\n";
   text += " volume=" + DoubleToString(tradeResult.volume, 2) + "\r\n";
   text += " price=" + DoubleToString(tradeResult.price, _Digits) + "\r\n";
   text += " bid=" + DoubleToString(tradeResult.bid, _Digits) + "\r\n";
   text += " ask=" + DoubleToString(tradeResult.ask, _Digits) + "\r\n";
   text += " comment=" + tradeResult.comment + "\r\n";
   text += " request_id=" + IntegerToString(tradeResult.request_id) + "\r\n";
   text += " retcode_external=" + IntegerToString(tradeResult.retcode_external);
   Print("MqlTradeResult data:\n", text);
}
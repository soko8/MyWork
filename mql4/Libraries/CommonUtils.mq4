//+------------------------------------------------------------------+
//|                                                  CommonUtils.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <Arrays\List.mqh>
#include <Infos\OrderInfo.mqh>

bool isExpire(datetime ExpireTime, bool EnableUseTimeControl=true) export {
   if (EnableUseTimeControl) {
      datetime now = TimeGMT();
      if (ExpireTime < now) {
         Alert("使用过期，请联系作者。邮箱：gao.zeng.8@gmail.com ");
         return true;
      }
   }
   
   return false;
}

string rightAlign (double varToAlign, int numChar, int decimalPoint) export {
   string textOut=DoubleToStr(varToAlign, decimalPoint);
   string blanks="";
   for(int f=0; f<=numChar-StringLen(textOut); f++) blanks=" "+blanks;
   textOut=blanks+textOut;
   return (textOut);
}

OrderInfo *createOrderLong(int MagicNumber, double lotSize, string comment="", double slPrice = 0.0, double tpPrice = 0.0) export {
   OrderInfo *oi = new OrderInfo;
   
   RefreshRates();
   int ticketId  = OrderSend(_Symbol, OP_BUY , lotSize, Ask, 0, slPrice, tpPrice, comment, MagicNumber, 0, clrBlue);
   
   if (ticketId < 0) {
      int errorCode = GetLastError();
      if (ERR_NO_CONNECTION == errorCode || ERR_MARKET_CLOSED == errorCode) {
         Print(ErrorDescription(errorCode));

      } else {
         string msg = "BUY OrderSend failed in createOrderLong. Error:【" + ErrorDescription(errorCode);
         msg += "】 Ask=" + DoubleToStr(Ask, Digits);
         msg += " lotSize=" + DoubleToStr(lotSize, 2);
         Alert(msg);
      }
      return oi;
   }
   
   oi.setValid(true);
   oi.setTicketId(ticketId);
   oi.setOperationType(OP_BUY);
   oi.setSymbolName(_Symbol);
   oi.setOpenPrice(Ask);
   
   if (OrderSelect(ticketId, SELECT_BY_TICKET)) {
      oi.setOpenPrice(OrderOpenPrice());
      oi.setLotSize(OrderLots());
      oi.setSlPrice(OrderStopLoss());
   } else {
      string msg = "OrderSelect failed in createOrderLong.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
   }
   
   return oi;
}

OrderInfo *createOrderShort(int MagicNumber, double lotSize, string comment="", double slPrice = 0.0, double tpPrice = 0.0) export {
   OrderInfo *oi = new OrderInfo;

   RefreshRates();
   int ticketId  = OrderSend(_Symbol, OP_SELL , lotSize, Bid, 0, slPrice, tpPrice, comment, MagicNumber, 0, clrRed);
   
   if (ticketId < 0) {
      int errorCode = GetLastError();
      if (ERR_NO_CONNECTION == errorCode || ERR_MARKET_CLOSED == errorCode) {
         Print(ErrorDescription(errorCode));

      } else {
         string msg = "Sell OrderSend failed in createOrderShort. Error:【" + ErrorDescription(GetLastError());
         msg += "】 Bid=" + DoubleToStr(Bid, Digits);
         msg += " lotSize=" + DoubleToStr(lotSize, 2);
         Alert(msg);
      }
      return oi;
   }
   
   oi.setValid(true);
   oi.setTicketId(ticketId);
   oi.setOperationType(OP_SELL);
   oi.setSymbolName(_Symbol);
   oi.setOpenPrice(Bid);
   
   if (OrderSelect(ticketId, SELECT_BY_TICKET)) {
      oi.setOpenPrice(OrderOpenPrice());
      oi.setLotSize(OrderLots());
      oi.setSlPrice(OrderStopLoss());
   } else {
      string msg = "OrderSelect failed in createOrderShort.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Sell Ticket = " + IntegerToString(ticketId);
      Alert(msg);
   }
   
   return oi;
}

bool closeOrderLong(OrderInfo *orderInfo, double lotSize=0.0) export {
   int ticketId = orderInfo.getTicketId();
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect(MODE_TRADES) failed in closeOrderLong.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      
      // 检查是否已经平仓(止损或者止盈时或者手动平仓时)
      isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
      if (isSelected) {
         if (0 < OrderCloseTime()) {
            return true;
         }
      }
      
      return false;
   }
   
   if (lotSize < 0.01) {
      lotSize = OrderLots();
   }
   RefreshRates();
   bool isClosed = OrderClose(OrderTicket(), lotSize, Bid, 0);
   if (!isClosed) {
      // Invalid ticket
      if (4108 == GetLastError()) {
         return true;
      }
      string msg = "OrderClose failed in closeOrderLong. Error:【" + ErrorDescription(GetLastError());
      msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
      msg += " Bid=" + DoubleToStr(Bid, Digits);
      Alert(msg);
   }
   
   return isClosed;
}

bool closeOrderShort(OrderInfo *orderInfo, double lotSize=0.0) export {
   int ticketId = orderInfo.getTicketId();
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect(MODE_TRADES) failed in closeOrderShort.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Sell Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      
      // 检查是否已经平仓(止损或者止盈时或者手动平仓时)
      isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
      if (isSelected) {
         if (0 < OrderCloseTime()) {
            return true;
         }
      }
      
      return false;
   }

   if (lotSize < 0.01) {
      lotSize = OrderLots();
   }
   RefreshRates();
   bool isClosed = OrderClose(OrderTicket(), lotSize, Ask, 0);
   if (!isClosed) {
      // Invalid ticket
      if (4108 == GetLastError()) {
         return true;
      }
      string msg = "OrderClose failed in closeOrderShort. Error:【" + ErrorDescription(GetLastError());
      msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
      msg += " Ask=" + DoubleToStr(Ask, Digits);
      Alert(msg);
   }
   
   return isClosed;
}

double calculateListTotalProfit(CList *orderList) export {
   double profit = 0.0;
   int listSize = orderList.Total();
   for(int i=0; i<listSize; i++) {
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
         profit += OrderProfit() + OrderCommission() + OrderSwap();
      } else {
         Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId) + ". Error:【" + ErrorDescription(GetLastError()));
      }
   }
   return profit;
}

bool closeAllOrdersList(CList *orderList) export {
   int listSize = orderList.Total();
   bool hasFail = false;
   for (int i = listSize-1; 0 <= i; i--) {
      bool isClosed = false;
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      if (OP_BUY == oi.getOperationType()) {
         isClosed = closeOrderLong(oi);
      } else if (OP_SELL == oi.getOperationType()) {
         isClosed = closeOrderShort(oi);
      }
      
      if (isClosed) {
         orderList.Delete(i);
         delete oi;
      } else {
         hasFail = true;
      }
   }
   
   return !hasFail;
}

double getListTotalLot(CList *orderList) export {
   double lots = 0.0;
   int listSize = orderList.Total();
   for(int i=0; i<listSize; i++) {
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
         lots += OrderLots();
      } else {
         Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId) + ". Error:【" + ErrorDescription(GetLastError()));
      }
   }
   return lots;
}

/**********************平仓列表中所有盈利单*************************************************/
int closeListPositiveProfitOrders(CList *orderList) export {
   int result = 0;
   int listSize = orderList.Total();
   for (int i=0; i<listSize; i++) {
      bool isClosed = false;
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId) + ". Error:【" + ErrorDescription(GetLastError()));
         continue;
      }
      if ((OrderProfit()+OrderCommission()+OrderSwap()) < 0) {
         continue;
      }
      if (OP_BUY == oi.getOperationType()) {
         isClosed = closeOrderLong(oi);
      } else if (OP_SELL == oi.getOperationType()) {
         isClosed = closeOrderShort(oi);
      }
      
      if (isClosed) {
         result++;
         orderList.Delete(i);
         delete oi;
      }
   }
   
   return result;
}

/**********************平仓列表中所有亏损单*************************************************/
int closeListNegativeProfitOrders(CList *orderList) export {
   int result = 0;
   int listSize = orderList.Total();
   for (int i=0; i<listSize; i++) {
      bool isClosed = false;
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId) + ". Error:【" + ErrorDescription(GetLastError()));
         continue;
      }
      if ((OrderProfit()+OrderCommission()+OrderSwap()) > 0) {
         continue;
      }
      if (OP_BUY == oi.getOperationType()) {
         isClosed = closeOrderLong(oi);
      } else if (OP_SELL == oi.getOperationType()) {
         isClosed = closeOrderShort(oi);
      }
      
      if (isClosed) {
         result++;
         orderList.Delete(i);
         delete oi;
      }
   }
   return result;
}

bool TP1Order(OrderInfo *oi, double targetProfit) export {
   int ticketId = oi.getTicketId();
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   if (!isSelected) {
      Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId) + ". Error:【" + ErrorDescription(GetLastError()));
      return false;
   }
   
   double profit = OrderProfit() + OrderCommission() + OrderSwap();
   
   if ( profit < targetProfit) {
      return false;
   }
   
   bool isClosed = false;
   if (OP_BUY == oi.getOperationType()) {
      isClosed = closeOrderLong(oi);
   } else if (OP_SELL == oi.getOperationType()) {
      isClosed = closeOrderShort(oi);
   }
      
   return isClosed;
}

//+------------------------------------------------------------------+
//|                                                        Utils.mq4 |
//|Copyright 2018～2019, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <OrderInfo.mqh>
#include <Arrays\List.mqh>

//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+
bool isEqualDouble(double num1, double num2) export {

   if( NormalizeDouble(num1-num2, 5) == 0 ) {
      return true;
   }
   
   return false;
}

double pips2Price(string symbolName, int pips) export {
   int vdigits = (int) MarketInfo(symbolName, MODE_DIGITS);
   double vpoint  = MarketInfo(symbolName, MODE_POINT);
   double price = NormalizeDouble(10*vpoint*pips, vdigits);
   return price;
}

bool isAuthorized(bool AccountCtrl, int& AuthorizeAccountList[]) export {
   if (!AccountCtrl) {
      return true;
   }
   int size = ArraySize(AuthorizeAccountList);
   int curAccount = AccountNumber();
   for (int i = 0; i < size; i++) {
      if (curAccount == AuthorizeAccountList[i]) {
         return true;
      }
   }
   Alert("你的交易账号未经授权！联系QQ:183947281！");
   return false;
}

bool isExpire(bool EnableUseTimeControl, datetime ExpireTime) export {
   if (EnableUseTimeControl) {
      datetime now = TimeGMT();
      if (ExpireTime < now) {
         Alert("使用过期，请联系作者。邮箱：soko8@sina.com  或者QQ:183947281");
         return true;
      }
   }
   
   return false;
}

int countOrders(int magicNumber=0, string symbolName=NULL) export {
   int orderNumber = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      if ( OrderSelect(i, SELECT_BY_POS) ) {
         if ((NULL!=symbolName && OrderSymbol()==symbolName) || (NULL==symbolName)) {
            if ((0!=magicNumber && magicNumber==OrderMagicNumber()) || (0==magicNumber)) {
               orderNumber++;
            }
         }
      }
   }
   
   return orderNumber;
}

int closeAllOrders(int magicNumber=0, string symbolName=NULL) export {
   int closedCount = 0;
   int count = OrdersTotal();
   for (int i = 0; i < count; i++) {
      if ( OrderSelect(i, SELECT_BY_POS) ) {
         if ((NULL!=symbolName && OrderSymbol()==symbolName) || (NULL==symbolName)) {
            if ((0!=magicNumber && magicNumber==OrderMagicNumber()) || (0==magicNumber)) {
               int order_type = OrderType();
               double closePrice = 0.0;
               RefreshRates();
               if (OP_BUY == order_type) {
                  closePrice = MarketInfo(OrderSymbol(), MODE_BID);
               } else if (OP_SELL == order_type) {
                  closePrice = MarketInfo(OrderSymbol(), MODE_ASK);
               }
               int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
               closePrice = NormalizeDouble(closePrice, vdigits);
               if (OrderClose(OrderTicket(), OrderLots(), closePrice, 0)) {
                  closedCount++;
               } else {
                  string msg = "Order close failed.";
                  msg = msg + " Error:" + ErrorDescription(GetLastError());
                  msg = msg + " i = " + IntegerToString(i);
                  msg = msg + " ticket id = " + IntegerToString(OrderTicket());
                  msg = msg + " close price = " + DoubleToStr(closePrice, vdigits);
                  Alert(msg);
               }
            }
         }
      }
   }
   
   return closedCount;
}


bool isNumber(string number) export {
   if (NULL == number) {
      return false;
   }

   int length = StringLen(number);
   
   if (0 == length) {
      return false;
   }
   
   if (1 == length) {
      ushort ch = StringGetChar(number, 0);
      if (isNumberChar(ch, false)) {
         return true;
      }
      return false;
   }
   
   for (int i = 0; i < length; i++) {
      ushort ch = StringGetChar(number, i);
      if (0 == i) {
         if (!isNumberChar(ch, true)) {
            return false;
         }
      } else {
         if (!isNumberChar(ch, false)) {
            return false;
         }
      }
   }
   
   return true;
}

bool isNumberChar(ushort ch, bool checkSignFlag) {
   if ('0' == ch) {
      return true;
   }
   
   if ('1' == ch) {
      return true;
   }
   
   if ('2' == ch) {
      return true;
   }
   
   if ('3' == ch) {
      return true;
   }
   
   if ('4' == ch) {
      return true;
   }
   
   if ('5' == ch) {
      return true;
   }
   
   if ('6' == ch) {
      return true;
   }
   
   if ('7' == ch) {
      return true;
   }
   
   if ('8' == ch) {
      return true;
   }
   
   if ('9' == ch) {
      return true;
   }
   
   if (checkSignFlag) {
      if ('-' == ch) {
         return true;
      }
   }
   
   return false;
}

void PressButton(string ctlName) export {
   bool selected = ObjectGetInteger(ChartID(), ctlName, OBJPROP_STATE);
   if (selected) {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, false);
   } else {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, true);
   }
}

bool closeOrderShort(OrderInfo *orderInfo, double lotSize_=0.0) export {
   int ticketId = orderInfo.getTicketId();
   // 检查是否已经平仓(止损或者止盈时或者手动平仓时)
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
   if (isSelected) {
      if (0 < OrderCloseTime()) {
         string msg = "The order(" + IntegerToString(ticketId) + ") has been closed.";
         Alert(msg);
         return true;
      }
   }
   isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect(MODE_TRADES) failed in closeOrderShort.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Sell Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      
      return false;
   }

   double lotSize = NormalizeDouble(lotSize_, 2);
   if (lotSize < 0.01) {
      lotSize = OrderLots();
   }
   RefreshRates();
   double ask_ = MarketInfo(OrderSymbol(), MODE_ASK);
   int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
   ask_ = NormalizeDouble(ask_, vdigits);
   bool isClosed = OrderClose(OrderTicket(), lotSize, ask_, 0);
   if (!isClosed) {
      string msg = "OrderClose failed in closeOrderShort. Error:【" + ErrorDescription(GetLastError());
      msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      msg += " Ask=" + DoubleToStr(ask_, vdigits);
      Alert(msg);
   }
   
   return isClosed;
}

bool closeOrderLong(OrderInfo *orderInfo, double lotSize_=0.0) export {
   int ticketId = orderInfo.getTicketId();
   // 检查是否已经平仓(止损或者止盈时或者手动平仓时)
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
   if (isSelected) {
      if (0 < OrderCloseTime()) {
         string msg = "The order(" + IntegerToString(ticketId) + ") has been closed.";
         Alert(msg);
         return true;
      }
   }
   isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect(MODE_TRADES) failed in closeOrderLong.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      
      return false;
   }
   
   double lotSize = NormalizeDouble(lotSize_, 2);
   if (lotSize < 0.01) {
      lotSize = OrderLots();
   }
   RefreshRates();
   double bid_ = MarketInfo(OrderSymbol(), MODE_BID);
   int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
   bid_ = NormalizeDouble(bid_, vdigits);
   bool isClosed = OrderClose(OrderTicket(), lotSize, bid_, 0);
   if (!isClosed) {
      string msg = "OrderClose failed in closeOrderLong. Error:【" + ErrorDescription(GetLastError());
      msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      msg += " Bid=" + DoubleToStr(bid_, vdigits);
      Alert(msg);
   }
   
   return isClosed;
}

OrderInfo *createOrderLong(string symbol, double lotSize_, int MagicNumber, double sl=0.0, double tp=0.0) export {
   int vdigits = (int) MarketInfo(symbol, MODE_DIGITS);
   double slPrice = NormalizeDouble(sl, vdigits);
   double tpPrice = NormalizeDouble(tp, vdigits);
   double ask_ = MarketInfo(symbol, MODE_ASK);
   double lotSize = NormalizeDouble(lotSize_, 2);
   
   RefreshRates();
   int ticketId  = OrderSend(symbol, OP_BUY , lotSize, ask_, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (-1 == ticketId) {
      string msg = symbol + " BUY OrderSend failed in createOrderLong. Error:【" + ErrorDescription(GetLastError());
      msg += "】 Ask=" + DoubleToStr(ask_, vdigits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return NULL;
   }
   OrderInfo *oi = new OrderInfo;
   oi.setValid(true);
   oi.setTicketId(ticketId);
   oi.setOperationType(OP_BUY);
   oi.setSymbolName(symbol);
   oi.setOpenPrice(ask_);
   
   if (OrderSelect(ticketId, SELECT_BY_TICKET)) {
      oi.setOpenPrice(OrderOpenPrice());
      oi.setLotSize(OrderLots());
      double tp_ = OrderTakeProfit();
      if (0.00001 < tp) oi.setTpPrice(tp_);
      double sl_ = OrderStopLoss();
      if (0.00001 < sl) oi.setSlPrice(sl_);
      oi.setOpenTime(OrderOpenTime());
   } else {
      string msg = symbol + " OrderSelect failed in createOrderLong.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
   }
   
   return oi;
}

OrderInfo *createOrderShort(string symbol, double lotSize_, int MagicNumber, double sl=0.0, double tp=0.0) export {
   int vdigits = (int) MarketInfo(symbol, MODE_DIGITS);
   double slPrice = NormalizeDouble(sl, vdigits);
   double tpPrice = NormalizeDouble(tp, vdigits);
   double bid_ = MarketInfo(symbol, MODE_BID);
   double lotSize = NormalizeDouble(lotSize_, 2);
   RefreshRates();
   int ticketId  = OrderSend(symbol, OP_SELL , lotSize, bid_, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (-1 == ticketId) {
      string msg = symbol + " Sell OrderSend failed in createOrderShort. Error:【" + ErrorDescription(GetLastError());
      msg += "】 Bid=" + DoubleToStr(bid_, vdigits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return NULL;
   }
   OrderInfo *oi = new OrderInfo;
   oi.setValid(true);
   oi.setTicketId(ticketId);
   oi.setOperationType(OP_SELL);
   oi.setSymbolName(symbol);
   oi.setOpenPrice(bid_);
   
   if (OrderSelect(ticketId, SELECT_BY_TICKET)) {
      oi.setOpenPrice(OrderOpenPrice());
      oi.setLotSize(OrderLots());
      double tp_ = OrderTakeProfit();
      if (0.00001 < tp) oi.setTpPrice(tp_);
      double sl_ = OrderStopLoss();
      if (0.00001 < sl) oi.setSlPrice(sl_);
      oi.setOpenTime(OrderOpenTime());
   } else {
      string msg = symbol + " OrderSelect failed in createOrderShort.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Sell Ticket = " + IntegerToString(ticketId);
      Alert(msg);
   }
   
   return oi;
}

void closeOrdersByList(CList *orderList) export {
   int listSize = orderList.Total();
   OrderInfo *oi = NULL;
   bool isClosed = false;
   for (int i = listSize-1; 0 <= i; i--) {
      oi = orderList.GetNodeAtIndex(i);
      isClosed = closeOrderLong(oi);
      if (isClosed) {
         orderList.Delete(i);
      }
   }
}

bool IsStringValidDouble(string str) export {
    string temp = str;
    StringTrimLeft(temp);
    StringTrimRight(temp);

    // 检查空字符串
    if(StringLen(temp) == 0) return false;

    // 特殊处理常见的零值表示
    if(temp == "0" || temp == "0.0" || temp == "0.00" || temp == "+0" || temp == "-0") {
        return true;
    }

    // 尝试转换
    double value = StringToDouble(temp);

    // 如果转换结果为0但原字符串不是零的某种形式，则转换失败
    if(value == 0.0) {
        // 检查是否真的是无效字符串
        bool hasNonZeroDigit = false;
        for(int i = 0; i < StringLen(temp); i++) {
            ushort ch = StringGetCharacter(temp, i);
            if(ch >= '1' && ch <= '9') {
                hasNonZeroDigit = true;
                break;
            }
        }

        // 包含非零数字但转换结果为0，说明转换失败
        if(hasNonZeroDigit) return false;
    }

    return true;
}
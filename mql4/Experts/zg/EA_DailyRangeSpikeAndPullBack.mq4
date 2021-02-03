//+------------------------------------------------------------------+
//|                                EA_DailyRangeSpikeAndPullBack.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int MagicNumber=168888;
input int TP=30;
input bool EnableRiskManage=false;
input double Risk=0.2;
input int MaxSpread=40;
input int PreviousBarRange=1;
//input int PeriodATR=20;
//input double GAPCoefficient=2.0;
input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;
// 10000:0.01
input int         MoneyManagePerLot=1000000;
input double BasketProfit = 20;


#include <stdlib.mqh>
#include <Object.mqh>
#include <Arrays\List.mqh>


enum enStatus {
   ToDoInitBuy = 10,
   ToDoInitSell = 11,
   InitedBuy = 20,
   InitedSell = 21,
   ToDoAddPositionBuy = 30,
   ToDoAddPositionSell = 31,
   AddedPositionBuy = 40,
   AddedPositionSell = 41,
   Skip = 50,
   SkipBuy = 51,
   SkipSell = 52,
   ToDoCloseBuy = 60,
   ToDoCloseSell = 61,
   Closed = 70
};

class OrderInfo : public CObject {
private:
protected:
   int               ticketId;
   double            openPrice;
   double            lotSize;
   double            tpPrice;
   double            slPrice;
   int               operationType;
   string            symbolName;
   bool              active;
   bool              closed;
   bool              valid;
public:
                     OrderInfo();
                    ~OrderInfo();
   void              setTicketId(int ticketNo) { ticketId = ticketNo; }
   int               getTicketId(void) const { return(ticketId); }
   void              setOpenPrice(double price) { openPrice = price; }
   double            getOpenPrice(void) const { return(openPrice); }
   void              setLotSize(double lots) { lotSize = lots; }
   double            getLotSize(void) const { return(lotSize); }
   void              setTpPrice(double price) { tpPrice = price; }
   double            getTpPrice(void) const { return(tpPrice); }
   void              setSlPrice(double price) { slPrice = price; }
   double            getSlPrice(void) const { return(slPrice); }
   void              setOperationType(int op) { operationType = op; }
   int               getOperationType(void) const { return(operationType);}
   void              setSymbolName(string symbolNm) { symbolName = symbolNm;}
   string            getSymbolName(void) const { return(symbolName); }
   void              setActive(bool actived) { this.active = actived;}
   bool              isActive(void) const { return(active); }
   void              setClosed(bool close) { this.closed = close; }
   bool              isClosed(void) const { return(closed); }
   void              setValid(bool valided) { this.valid = valided; }
   bool              isValid(void) const { return(valid); }
};

OrderInfo::OrderInfo() {
   active = false;
   closed = false;
   valid = false;
}

OrderInfo::~OrderInfo() {
}

/********************************************************************************************************/
      CList                *Orders;
      datetime             previousTime;
      enStatus             status;
      
      double               LotStepServer = 0.0;
      double               minLot = 0.0;
      
const int                  Min_Interval = 0;
const int                  Max_Interval = 50;
      
const int                  PIP_DIGIT=1;
/********************************************************************************************************/

int OnInit() {
   LotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);
   minLot = MarketInfo(_Symbol, MODE_MINLOT);
   previousTime = iTime(NULL, TimeFrame, 0);
   Orders = new CList;
   status = Closed;
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   Orders.Clear();
   delete Orders;
}


void OnTick() {
   status = getStatus();
   int vSpread = (int)MarketInfo(Symbol(), MODE_SPREAD);
   /** if spread at midnight is too high (more than 4.0 pips) – Don’t open a trade yet. 
       Wait with market order till spread narrows back.
   */
   
   switch(status) {
      
      case ToDoInitBuy : 
      case ToDoAddPositionBuy : {
         if(vSpread < MaxSpread) {
            double lot = calculateLot();
            OrderInfo *oi = createOrderLong(lot);
            if (oi.isValid()) {
               Orders.Add(oi);
               status = AddedPositionBuy;
            }
         }
         break;
      }
      
      case ToDoInitSell : 
      case ToDoAddPositionSell : {
         if(vSpread < MaxSpread) {
            double lot = calculateLot();
            OrderInfo *oi = createOrderShort(lot);
            if (oi.isValid()) {
               Orders.Add(oi);
               status = AddedPositionSell;
            }
         }
         break;
      }
      
      case ToDoCloseBuy : 
      case ToDoCloseSell : {
         if (closeAll()) {
            status = Closed;
         }
         break;
      }
      
      case InitedBuy : 
      case InitedSell : 
      case AddedPositionBuy : 
      case AddedPositionSell : 
      case Skip : 
      case SkipBuy : 
      case SkipSell : 
      case Closed : break;
      default: ;
   }
   
}

enStatus judgeStatusBuy() {
   if (!EnableRiskManage) {
      return status;
   }
   enStatus result;
   double profit = calculateProfit();
   if (EnableRiskManage && profit < 0 && Risk < MathAbs(profit)/AccountBalance()) {
      result = ToDoCloseBuy;
   } else {
      // If price goes from last entry against the direction of the trade
      if (iClose(NULL, TimeFrame, 1) < iOpen(NULL, TimeFrame, 1)) {
         double lotSize = getAllLotSize(Orders);
         // basket still negative
         if (profit < BasketProfit*lotSize) {
            OrderInfo *oi = Orders.GetNodeAtIndex(Orders.Total()-1);
            // - Check distance pips from last(not 1st) entry with Bid/Ask >= Yesterday Range/2 or at least 25 pips.
            double distancePips = price2pip((oi.getOpenPrice()-Ask));
            if (MathMax(25, price2pip(iHigh(NULL, TimeFrame, 1)-iLow(NULL, TimeFrame, 1))/2) < distancePips) {
               result = ToDoAddPositionBuy;
            } else {
               return status;
            }
            
         // basket turned positive
         } else {
            result = ToDoCloseBuy;
         }
         
      // avoid enter a trade when price goes from last entry with the same direction 
      } else {
         result = SkipBuy;
      }
   }
   return result;
}

enStatus judgeStatusSell() {
   if (!EnableRiskManage) {
      return status;
   }
   enStatus result;
   double profit = calculateProfit();
   if (EnableRiskManage && profit < 0 && Risk < MathAbs(profit)/AccountBalance()) {
      result = ToDoCloseSell;
   } else {
      // If price goes from last entry against the direction of the trade
      if (iOpen(NULL, TimeFrame, 1) < iClose(NULL, TimeFrame, 1)) {
         double lotSize = getAllLotSize(Orders);
         // basket still negative
         if (profit < BasketProfit*lotSize) {
         
            OrderInfo *oi = Orders.GetNodeAtIndex(Orders.Total()-1);
            // - Check distance pips from last(not 1st) entry with Bid/Ask >= Yesterday Range/2 or at least 25 pips.
            double distancePips = price2pip((Bid-oi.getOpenPrice()));
            if (MathMax(25, price2pip(iHigh(NULL, TimeFrame, 1)-iLow(NULL, TimeFrame, 1))/2) < distancePips) {
               result = ToDoAddPositionSell;
            } else {
               return status;
            }
            
         // basket turned positive
         } else {
            result = ToDoCloseSell;
         }
         
      // avoid enter a trade when price goes from last entry with the same direction 
      } else {
         result = SkipSell;
      }
   }
   return result;
}

enStatus getStatus() {
   if(isNewBar()) {
      
      switch(status) {
         /** 
         4/if the price goes against the direction of the trade
         - Check distance pips from 1st entry with Bid/Ask >= Yesterday Range/2 or at least 25 pips.
         - Open 2nd trade with same lot size (can martingale), no tp price.
         - Close all trades when Basket Profit >= 2 or more...
         */
         case InitedBuy : {
            if (isTP()) {
               status = ToDoCloseBuy;
            } else if (isSL(OP_BUY)) {
               status = ToDoCloseBuy;
            } else {
               status = judgeStatusBuy();
            }
            break;
         }
         
         case ToDoAddPositionBuy : 
         case AddedPositionBuy : 
         case SkipBuy : {
            status = judgeStatusBuy();
            break;
         }
         
         case InitedSell : {
            if (isTP()) {
               status = ToDoCloseSell;
            } else if (isSL(OP_SELL)) {
               status = ToDoCloseSell;
            } else {
               status = judgeStatusSell();
            }
            break;
         }
         
         case ToDoAddPositionSell : 
         case AddedPositionSell : 
         case SkipSell : {
            status = judgeStatusSell();
            break;
         }
         
         case ToDoCloseBuy : break;
         case ToDoCloseSell : break;
         
         case Skip : 
         case ToDoInitBuy : 
         case ToDoInitSell : 
         case Closed : {
            double gap = getGAP();
            double diff = MathAbs(iClose(NULL, TimeFrame, 1) - iOpen(NULL, TimeFrame, 1));
            Print("diff="+diff);
            Print("gap="+gap);
            Print("price2pip(diff)="+price2pip(diff));
            Print("gap <= price2pip(diff)="+(gap <= price2pip(diff)));
            Print("(iOpen(NULL, TimeFrame, 1) < iClose(NULL, TimeFrame, 1))="+(iOpen(NULL, TimeFrame, 1) < iClose(NULL, TimeFrame, 1)));
            Print("(Ask < iOpen(NULL, TimeFrame, 0))="+(Ask < iOpen(NULL, TimeFrame, 0)));
            Print("(iOpen(NULL, TimeFrame, 0) < Bid)="+(iOpen(NULL, TimeFrame, 0) < Bid));
            /**
            This is the rules:
            1/ Check Yesterday Range (Open-Close) from 80 pips above.
            
            2/ Check Today pips: Price from Daily Open to current price (Bid/Ask)
            + Min: 5 pips
            + Max: 50 pips
            3/ Open Trade:
            - SELL if yesterday is Bullish candle
            - BUY if yesterday is Bearish candle
            
            takeprofit: 20 -35 pips
            stoploss: 2 options
            option 1: 20-25% Account Equity, not stoploss by pips/price.
            option 2: check from 5-10 Daily candles, then put your stoploss above/below High/Low of it.
            */
            if(gap <= price2pip(diff)) {
               // yesterday is Bullish candle
               if (iOpen(NULL, TimeFrame, 1) < iClose(NULL, TimeFrame, 1)) {
                  //if (iHigh(NULL, TimeFrame, 0) <= iHigh(NULL, TimeFrame, 1)) {
                     if (Ask < iOpen(NULL, TimeFrame, 0)) {
                        double currentInterval = price2pip(iOpen(NULL, TimeFrame, 0)-Ask);
                        Print("currentInterval="+currentInterval);
                        if (Min_Interval<=currentInterval && currentInterval<=Max_Interval) {
                           status = ToDoInitSell;
                        } else {
                           //status = Skip;
                        }
                     } else {
                        //status = Skip;
                     }
                     
                     /*
                  } else {
                     status = Skip;
                  }
                  */
               
               // yesterday is Bearish candle
               } else {
                  //if (iLow(NULL, TimeFrame, 1) <= iLow(NULL, TimeFrame, 0)) {
                     if (iOpen(NULL, TimeFrame, 0) < Bid) {
                        double currentInterval = price2pip(Bid-iOpen(NULL, TimeFrame, 0));
                        Print("currentInterval="+currentInterval);
                        if (Min_Interval<=currentInterval && currentInterval<=Max_Interval) {
                           status = ToDoInitBuy;
                        } else {
                           //status = Skip;
                        }
                     } else {
                        //status = Skip;
                     }
                     
                     /*
                  } else {
                     status = Skip;
                  }
                  */
               
               }

            } else {
               status = Skip;
            }
            break;
         }
         default: ;
      }
      
   }
   return status;
}

double calculateProfit() {
   double profit = 0.0;
   int listSize = Orders.Total();
   for(int i=0; i<listSize; i++) {
      OrderInfo *oi = Orders.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
         profit = profit + OrderProfit() + OrderCommission() + OrderSwap();
      } else {
         Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId));
      }
   }
   return profit;
}

bool isTP() {
   double profit = calculateProfit();
   double pips = price2pip(profit);
   if (pips < TP) {
      return false;
   }
   return true;
}

double getGAP() {
   return PreviousBarRange;
}

bool isNewBar() {
   if(previousTime != iTime(NULL, TimeFrame, 0)) {
      previousTime = iTime(NULL, TimeFrame, 0);
      return true;
   }
   return false;

}

double price2pip(double price) {
   double vpoint = MarketInfo(Symbol(), MODE_POINT);
   double pips = price/vpoint/10;
   pips = NormalizeDouble(pips, PIP_DIGIT);
   return pips;
}

double calculateLot() {
   double lot = AccountBalance()/MoneyManagePerLot;
   lot = MathCeil(lot/LotStepServer)*LotStepServer;
   if (lot < minLot) {
      lot = minLot;
   }
   return lot;
}

OrderInfo *createOrderLong(double lotSize) {
   OrderInfo *oi = new OrderInfo;
   double slPrice = 0.0;
   double tpPrice = 0.0;
   
   RefreshRates();
   int ticketId  = OrderSend(_Symbol, OP_BUY , lotSize, Ask, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (ticketId < 0) {
      string msg = "BUY OrderSend failed in createOrderLong. Error:【" + ErrorDescription(GetLastError());
      msg += "】 Ask=" + DoubleToStr(Ask, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
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

OrderInfo *createOrderShort(double lotSize) {
   OrderInfo *oi = new OrderInfo;
   double slPrice = 0.0;
   double tpPrice = 0.0;
   RefreshRates();
   int ticketId  = OrderSend(_Symbol, OP_SELL , lotSize, Bid, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (ticketId < 0) {
      string msg = "Sell OrderSend failed in createOrderShort. Error:【" + ErrorDescription(GetLastError());
      msg += "】 Bid=" + DoubleToStr(Bid, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
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

bool closeOrderLong(OrderInfo *orderInfo, double lotSize=0.0) {
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

bool closeOrderShort(OrderInfo *orderInfo, double lotSize=0.0) {
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

bool closeAll() {
   int listSize = Orders.Total();
   bool hasFail = false;
   for (int i = listSize-1; 0 <= i; i--) {
      bool isClosed = false;
      OrderInfo *oi = Orders.GetNodeAtIndex(i);
      if (OP_SELL == oi.getOperationType()) {
         isClosed = closeOrderShort(oi);
      } else if (OP_BUY == oi.getOperationType()) {
         isClosed = closeOrderLong(oi);
      }
      
      if (isClosed) {
         Orders.Delete(i);
         delete oi;
      } else {
         hasFail = true;
      }
   }
   
   return !hasFail;
}

bool isSL(int OperationType) {
   if (EnableRiskManage) {
      return false;
   }
   int DailyCandlesCount = 7;
   if (OP_BUY == OperationType) {
      double slPrice = iLowest(NULL, TimeFrame, MODE_LOW, DailyCandlesCount);
      if (Ask <= slPrice) {
         return true;
      }
      
   } else if (OP_SELL == OperationType) {
      double slPrice = iHighest(NULL, TimeFrame, MODE_HIGH, DailyCandlesCount);
      if (slPrice <= Bid) {
         return true;
      }
   }
   return false;
}

double getAllLotSize(CList *orderList) {
   double lots = 0.0;
   int listSize = orderList.Total();
   for(int i=0; i<listSize; i++) {
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
         lots += OrderLots();
      } else {
         Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId));
      }
   }
   return lots;
}

/**
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
}

double OnTester() {
   double ret=0.0;
   return(ret);
}
*/

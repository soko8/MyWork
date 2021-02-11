//+------------------------------------------------------------------+
//| EA_HandOfGod.mq4 |
//| Copyright 2021, MetaQuotes Software Corp. |
//| https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

#import "DrawHandOfGod.ex4"
void draw(int rowCount);
#import

//--- input parameters
input int         MagicNumber=888888;

// 趋势间距
input int         IntervalTrendPips__=7;
// 最大趋势订单量
input int         MaxTrendOrderCount__=18;
// 回调间距
input int         IntervalRetracePips__=20;
// 最大回调订单量
input int         MaxRetraceOrderCount__=6;
// 加仓系数
input double      AddLotMultiple__=1.5;
// 止盈点数开关
input bool        EnableTakeProfitByPips__=true;
// 止盈点数
input int         TakeProfitPips__=200;
// 止盈美金开关
input bool        EnableTakeProfitByDollars__=false;
// 止盈美金
input double      TakeProfitDollars__=2000.0;
// 对冲止盈美金
input double      TakeProfitDollars4Hedge__=10.0;
// 10000:0.01
// 资金管理
input int         MoneyManagePerLot__=100000;
// 逆势最大持单量
input int         MaxReverseHoldOrders__=12;


#include <stdlib.mqh>
//#include <Object.mqh>
//#include <Arrays\List.mqh>
//#include <Infos\OrderInfo.mqh>
#include <CommonUtils.mqh>


enum enSignalType {
   ENTRY_Long = 1,
   Long_Type = 2,
   Long_Cross = 3,         // 多转空
   None_Type = 0,
   ENTRY_Short = -1,
   Short_Type = -2,
   Short_Cross = -3        // 空转多
};

/********************************************************************************************************/

      int         IntervalTrendPips;
      int         MaxTrendOrderCount;
      int         IntervalRetracePips;
      int         MaxRetraceOrderCount;
      double      AddLotMultiple;
      bool        EnableTakeProfitByPips;
      int         TakeProfitPips;
      bool        EnableTakeProfitByDollars;
      double      TakeProfitDollars;
      double      TakeProfitDollars4Hedge;
      int         MoneyManagePerLot;
      int         MaxReverseHoldOrders;


      CList                *LongOrders;
      CList                *ShortOrders;
      double               LotStepServer = 0.0;
      double               minLot = 0.0;
      enSignalType         SignalType;
      datetime             previousBarTime;
      double               IntervalPrice4Trend;
      double               IntervalPrice4Retrace;
      double               TargetProfit;
      
      double               initLotLong = 0.0;
      int                  nowOrderTotal4RetraceLong = 0;
      double               nextPrice4RetraceLong = 0.0;
      int                  nowOrderTotal4TrendLong = 0;
      double               nextPrice4TrendLong = 0.0;
      bool                 openedOrderInNewCycleLong=false;

      
      double               initLotShort = 0.0;
      int                  nowOrderTotal4RetraceShort = 0;
      double               nextPrice4RetraceShort = 0.0;
      int                  nowOrderTotal4TrendShort = 0;
      double               nextPrice4TrendShort = 0.0;
      bool                 openedOrderInNewCycleShort=false;
      
      bool                 isRunning = false;
      ENUM_TIMEFRAMES      Period_Small;
      

      
const int                  PIP_DIGIT=1;
const double               StepSAR=0.02;
const double               MaximumSAR=0.2;
const int                  PeriodMA=14;
const int                  ShiftMA=0;
const ENUM_MA_METHOD       MethodMA=MODE_SMA;
const ENUM_APPLIED_PRICE   AppliedPriceMA=PRICE_CLOSE;
/********************************************************************************************************/

int OnInit() {
   if(!IsDemo()) return(INIT_FAILED);
   
   datetime ExpireTime = D'2024.12.31 23:59:59';
   if (isExpire(ExpireTime, true)) return(INIT_FAILED);
   
   IntervalTrendPips=IntervalTrendPips__;
   MaxTrendOrderCount=MaxTrendOrderCount__;
   IntervalRetracePips=IntervalRetracePips__;
   MaxRetraceOrderCount=MaxRetraceOrderCount__;
   AddLotMultiple=AddLotMultiple__;
   EnableTakeProfitByPips=EnableTakeProfitByPips__;
   TakeProfitPips=TakeProfitPips__;
   EnableTakeProfitByDollars=EnableTakeProfitByDollars__;
   TakeProfitDollars=TakeProfitDollars__;
   TakeProfitDollars4Hedge=TakeProfitDollars4Hedge__;
   MoneyManagePerLot=MoneyManagePerLot__;
   MaxReverseHoldOrders=MaxReverseHoldOrders__;
   

   LotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);
   minLot = MarketInfo(_Symbol, MODE_MINLOT);
   LongOrders = new CList;
   ShortOrders = new CList;
   previousBarTime = 0;
   IntervalPrice4Trend = pip2price(IntervalTrendPips);
   IntervalPrice4Retrace = pip2price(IntervalRetracePips);
   TargetProfit = TakeProfitDollars;
   if (EnableTakeProfitByPips) {
      TargetProfit = TakeProfitPips*10;
   }
   
   Period_Small = getPeriod();
   
   draw(MaxTrendOrderCount+MaxRetraceOrderCount);
   
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
   LongOrders.Clear();
   delete LongOrders;
   ShortOrders.Clear();
   delete ShortOrders;
   ObjectsDeleteAll();
}

void OnTick() {
   if (!isRunning) {
      refreshData();
      return;
   }
   if (isNewBar()) {
      SignalType = getSignal();
      previousBarTime = Time[0];
      if (ENTRY_Long==SignalType || Long_Cross == SignalType || Long_Type == SignalType) {
         openedOrderInNewCycleShort = false;
      } else if (ENTRY_Short==SignalType || Short_Cross == SignalType || Short_Type == SignalType) {
         openedOrderInNewCycleLong = false;
      }
   }
   
   switch(SignalType) {
            // 多转空，锁仓
      case Long_Cross : 
      case Long_Type : 
      case ENTRY_Long : {
         // 平仓逆势订单列表中所有盈利单
         closePositiveProfitReverseOrders(ShortOrders);
         
         if (!openedOrderInNewCycleLong) {
            if (nowOrderTotal4TrendLong<=MaxTrendOrderCount) {
               Print("First Long Order.首次多单");
               double lot = calculateFirstLot();
               OrderInfo *oi = createOrderLong(MagicNumber, lot, "First Long Order");
               if (oi.isValid()) {
                  LongOrders.Add(oi);
                  initLotLong = lot;
                  nowOrderTotal4RetraceLong = 0;
                  nextPrice4RetraceLong = oi.getOpenPrice() - IntervalPrice4Retrace;
                  openedOrderInNewCycleLong = true;
                  nowOrderTotal4TrendLong++;
                  nextPrice4TrendLong = oi.getOpenPrice() + IntervalPrice4Trend;
               } else {
                  delete oi;
               }
            }
         }
         break;
      }
      

            // 空转多，锁仓
      case Short_Cross : 
      case Short_Type : 
      case ENTRY_Short : {
         // 平仓逆势订单列表中所有盈利单
         closePositiveProfitReverseOrders(LongOrders);
         
         if (!openedOrderInNewCycleShort) {
            if (nowOrderTotal4TrendShort<=MaxTrendOrderCount) {
            Print("First Short Order.首次空单");
               double lot = calculateFirstLot();
               OrderInfo *oi = createOrderShort(MagicNumber, lot, "First Short Order");
               if (oi.isValid()) {
                  ShortOrders.Add(oi);
                  initLotShort = lot;
                  nowOrderTotal4RetraceShort = 0;
                  nextPrice4RetraceShort = oi.getOpenPrice() + IntervalPrice4Retrace;
                  openedOrderInNewCycleShort = true;
                  nowOrderTotal4TrendShort++;
                  nextPrice4TrendShort = oi.getOpenPrice() - IntervalPrice4Trend;
               } else {
                  delete oi;
               }
            }
         }
         break;
      }
      
      case None_Type : {
         break;
      }
      default: ;
   }
   
   if (ENTRY_Long == SignalType || Long_Cross == SignalType || Long_Type == SignalType) {
      if (nowOrderTotal4RetraceShort < 1 && nowOrderTotal4TrendShort < 1) {
         isTpLong();
         
         
      // 对冲
      } else {
         hedge(ShortOrders, LongOrders);
      }
      isOverMaxReverseHoldOrdersLong();
      isTpLatestRetraceOrder(OP_BUY);
      
      if (nextPrice4TrendLong <= Bid && nowOrderTotal4TrendLong<MaxTrendOrderCount) {
         Print("Add trend Long Order.顺势加仓多单");
         int apCount = nowOrderTotal4TrendLong + 1;
         OrderInfo *oi = createOrderLong(MagicNumber, initLotLong, "Long Trend Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            LongOrders.Add(oi);
            nowOrderTotal4TrendLong = apCount;
            nextPrice4TrendLong = oi.getOpenPrice() + IntervalPrice4Trend;
            nextPrice4RetraceLong = oi.getOpenPrice() - IntervalPrice4Retrace;
         }
      } else if (Ask <= nextPrice4RetraceLong && nowOrderTotal4RetraceLong<MaxRetraceOrderCount) {
         Print("Add retrace Long Order.回调加仓多单");
         int apCount = nowOrderTotal4RetraceLong + 1;
         double lotSize = calculateAPLot(initLotLong, apCount, AddLotMultiple);
         OrderInfo *oi = createOrderLong(MagicNumber, lotSize, "Long Retrace Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            LongOrders.Add(oi);
            nowOrderTotal4RetraceLong = apCount;
            nextPrice4RetraceLong = oi.getOpenPrice() - IntervalPrice4Retrace;
            oi.setRetraceOrder(true);
         }
      }
   }
   
   
   
   if (ENTRY_Short == SignalType || Short_Cross == SignalType || Short_Type == SignalType) {
      if (nowOrderTotal4RetraceLong < 1 && nowOrderTotal4TrendLong < 1) {
         isTpShort();
         

      // 对冲
      } else {
         hedge(LongOrders, ShortOrders);
      }
      isOverMaxReverseHoldOrdersShort();
      isTpLatestRetraceOrder(OP_SELL);
      
      if (Ask <= nextPrice4TrendShort && nowOrderTotal4TrendShort < MaxTrendOrderCount) {
         Print("Add trend Short Order.顺势加仓空单");
         int apCount = nowOrderTotal4TrendShort + 1;
         OrderInfo *oi = createOrderShort(MagicNumber, initLotShort, "Short Trend Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            ShortOrders.Add(oi);
            nowOrderTotal4TrendShort = apCount;
            nextPrice4TrendShort = oi.getOpenPrice() - IntervalPrice4Trend;
            nextPrice4RetraceShort = oi.getOpenPrice() + IntervalPrice4Retrace;
         }
      } else if (nextPrice4RetraceShort <= Bid && nowOrderTotal4RetraceShort < MaxRetraceOrderCount) {
         Print("Add retrace Short Order.回调加仓空单");
         int apCount = nowOrderTotal4RetraceShort + 1;
         double lotSize = calculateAPLot(initLotShort, apCount, AddLotMultiple);
         OrderInfo *oi = createOrderShort(MagicNumber, lotSize, "Short Retrace Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            ShortOrders.Add(oi);
            nowOrderTotal4RetraceShort = apCount;
            nextPrice4RetraceShort = oi.getOpenPrice() + IntervalPrice4Retrace;
            oi.setRetraceOrder(true);
         }
      }
   }
   
   
   refreshData();

}

enSignalType getSignal() {
   HideTestIndicators(true);
   double sarVal1 = iSAR(NULL, 0, StepSAR, MaximumSAR, 1);
   double sarVal2 = iSAR(NULL, 0, StepSAR, MaximumSAR, 2);
   double maVal1 = iMA(NULL, 0, PeriodMA, ShiftMA, MethodMA, AppliedPriceMA, 1);
   double maVal2 = iMA(NULL, 0, PeriodMA, ShiftMA, MethodMA, AppliedPriceMA, 2);
   HideTestIndicators(false);
   if (sarVal2 > sarVal1 && maVal1 > sarVal1 && Close[1] > maVal1 && Close[1] > Open[1]) {
      return ENTRY_Long;
   }
   if (sarVal2 < sarVal1 && maVal1 > sarVal1 && Low[1] > sarVal1) {
      return Long_Type;
   }
   if (sarVal2 <= maVal2 && maVal1 <= sarVal1) {
      return Long_Cross;
   }
   if (sarVal2 < sarVal1 && maVal1 < sarVal1 && Close[1] < maVal1 && Close[1] < Open[1]) {
      return ENTRY_Short;
   }
   if (sarVal2 > sarVal1 && maVal1 < sarVal1 && Low[1] < sarVal1) {
      return Short_Type;
   }
   if (sarVal2 >= maVal2 && maVal1 >= sarVal1) {
      return Short_Cross;
   }
   return None_Type;
}


int getFirstOrderIndex(CList *orderList) {
   int listSize = orderList.Total();
   OrderInfo *oi0 = orderList.GetNodeAtIndex(0);
   int opType = oi0.getOperationType();
   double price = oi0.getOpenPrice();
   int result = 0;
   for (int i = 1; i < listSize; i++) {
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      if (oi.isValid() && !oi.isClosed() ) {
         if (OP_BUY == opType) {
            // max price
            if (price < oi.getOpenPrice()) {
               price = oi.getOpenPrice();
               result = i;
            }
            
         
         } else {
            // min price
            if (oi.getOpenPrice() < price) {
               price = oi.getOpenPrice();
               result = i;
            }
         }
      }
   }
   return result;
}



double calculateAllProfit(CList *orderList) {
   double profit = calculateListTotalProfit(LongOrders);
   profit += calculateListTotalProfit(ShortOrders);
   return profit;
}

void hedge(CList *HedgeOrderList, CList *orderList) {
   int theFurthestHedgeOrderIndex = getFirstOrderIndex(HedgeOrderList);
   if (theFurthestHedgeOrderIndex < 0) {
      return;
   }
   OrderInfo *theFurthestHedgeOrder = HedgeOrderList.GetNodeAtIndex(theFurthestHedgeOrderIndex);
   int endIndex = orderList.Total() - 1;
   int ticketId = theFurthestHedgeOrder.getTicketId();
   bool doHedge = false;
   if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
      double hedgeProfit = OrderProfit() + OrderCommission() + OrderSwap();
      double profit = 0;
      double lotHedge = 0;
      for(; 0 <= endIndex; endIndex--) {
         OrderInfo *oi = orderList.GetNodeAtIndex(endIndex);
         int ticketIdLoop = oi.getTicketId();
         if(OrderSelect(ticketIdLoop, SELECT_BY_TICKET)) {
            profit += OrderProfit() + OrderCommission() + OrderSwap();
            lotHedge += OrderLots();
            if (TakeProfitDollars4Hedge*lotHedge <= (profit+hedgeProfit)) {
               doHedge = true;
               break;
            }
         } else {
            Print("OrderSelect Error. Ticket:" + IntegerToString(ticketIdLoop));
         }
      }
   } else {
      Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId));
   }
   
   if (doHedge) {
      bool isClosedHedge = false;
      if (OP_BUY== theFurthestHedgeOrder.getOperationType()) {
         isClosedHedge = closeOrderLong(theFurthestHedgeOrder);
         if (isClosedHedge) {
            Print("Short trend Hedge Long Order.空趋势对冲多单");
            if (theFurthestHedgeOrder.isRetraceOrder()) {
               nowOrderTotal4RetraceLong--;
            } else {
               nowOrderTotal4TrendLong--;
            }
         }
      } else if (OP_SELL== theFurthestHedgeOrder.getOperationType()) {
      Print("Long trend Hedge Short Order.多趋势对冲空单");
         isClosedHedge = closeOrderShort(theFurthestHedgeOrder);
         if (isClosedHedge) {
            if (theFurthestHedgeOrder.isRetraceOrder()) {
               nowOrderTotal4RetraceShort--;
            } else {
               nowOrderTotal4TrendShort--;
            }
         }
      }
      
      if (!isClosedHedge) {
         return;
      }
   
      int size = orderList.Total();
      for(int i=size-1; endIndex <= i; i--) {
         bool isClosed = false;
         OrderInfo *oi = orderList.GetNodeAtIndex(i);
         if (OP_BUY== theFurthestHedgeOrder.getOperationType()) {
            isClosed = closeOrderShort(oi);
            if (!isClosed) {
               continue;
            }
            
            if (oi.isRetraceOrder()) {
               orderList.Delete(i);
               nowOrderTotal4RetraceShort--;
               if (0 < nowOrderTotal4RetraceShort) {
                  nextPrice4RetraceShort -= IntervalPrice4Retrace;
               } else if (0 < nowOrderTotal4TrendShort) {
                  OrderInfo *latestTrendOrder = orderList.GetLastNode();
                  nextPrice4RetraceShort = latestTrendOrder.getOpenPrice() + IntervalPrice4Retrace;
               } else {
                  nextPrice4RetraceShort = Low[0] + IntervalPrice4Retrace;
               }
            } else {
               orderList.Delete(i);
               nowOrderTotal4TrendShort--;
               if (0 < nowOrderTotal4TrendShort) {
                  nextPrice4TrendShort += IntervalPrice4Trend;
               } else {
                  openedOrderInNewCycleShort = false;
               }
            }
            
            
            
         } else if (OP_SELL== theFurthestHedgeOrder.getOperationType()) {
            isClosed = closeOrderLong(oi);
            if (!isClosed) {
               continue;
            }
            
            if (oi.isRetraceOrder()) {
               orderList.Delete(i);
               nowOrderTotal4RetraceLong--;
               if (0 < nowOrderTotal4RetraceLong) {
                  nextPrice4RetraceLong += IntervalPrice4Retrace;
               } else if (0 < nowOrderTotal4TrendLong) {
                  OrderInfo *latestTrendOrder = orderList.GetLastNode();
                  nextPrice4RetraceLong = latestTrendOrder.getOpenPrice() - IntervalPrice4Retrace;
               } else {
                  nextPrice4RetraceLong = High[0] - IntervalPrice4Retrace;
               }
               
            } else {
               orderList.Delete(i);
               nowOrderTotal4TrendLong--;
               if (0 < nowOrderTotal4TrendLong) {
                  nextPrice4TrendLong -= IntervalPrice4Trend;
               } else {
                  openedOrderInNewCycleLong = false;
               }
            }

         }
         //orderList.Delete(i);
         delete oi;
      }
      
      HedgeOrderList.Delete(theFurthestHedgeOrderIndex);
      delete theFurthestHedgeOrder;
   }
}


double pip2price(double pips) {
   int vdigits = (int) MarketInfo(Symbol(), MODE_DIGITS);
   double vpoint = MarketInfo(Symbol(), MODE_POINT);
   double price = NormalizeDouble(10*vpoint*pips, vdigits);
   return price;
}

bool isNewBar() {
   if(previousBarTime != iTime(NULL, 0, 0)) {
      previousBarTime = iTime(NULL, 0, 0);
      return true;
   }
   return false;
}

double calculateFirstLot() {
   double lot = AccountBalance()/MoneyManagePerLot;
   lot = MathCeil(lot/LotStepServer)*LotStepServer;
   if (lot < minLot) {
      lot = minLot;
   }
   return lot;
}

double calculateAPLot(double initLotSize, int apTimes, double lotMultiple) {
   double lot = initLotSize * MathPow(lotMultiple, apTimes);
   lot = MathCeil(lot/LotStepServer)*LotStepServer;
   if (lot < minLot) {
      lot = minLot;
   }
   return lot;
}



bool isTpLong() {
   double profit = calculateListTotalProfit(LongOrders);
   double lots = getListTotalLot(LongOrders);
   if (TargetProfit*lots <= profit) {
      closeAllOrdersList(LongOrders);
      initLotLong = 0;
      nowOrderTotal4RetraceLong = 0;
      nextPrice4RetraceLong = 0;
      openedOrderInNewCycleLong = false;
      nowOrderTotal4TrendLong=0;
      nextPrice4TrendLong = 0;
      Print("Take Profit Long Order.止盈多单");
      return true;
   }
   return false;
}

bool isTpShort() {
   double profit = calculateListTotalProfit(ShortOrders);
   double lots = getListTotalLot(ShortOrders);
   if (TargetProfit*lots <= profit) {
      closeAllOrdersList(ShortOrders);
      initLotShort = 0;
      nowOrderTotal4RetraceShort = 0;
      nextPrice4RetraceShort = 0;
      openedOrderInNewCycleShort = false;
      nowOrderTotal4TrendShort=0;
      nextPrice4TrendShort = 0;
      Print("Take Profit Short Order.止盈空单");
      return true;
   }
   return false;
}

bool isTpLatestRetraceOrder(int type) {
   if (OP_BUY == type) {
      if (0 < nowOrderTotal4RetraceLong) {
         int size = LongOrders.Total();
         int retraceIndex = size-1;
         for(; 0 <= retraceIndex; retraceIndex--) {
            OrderInfo *oi = LongOrders.GetNodeAtIndex(retraceIndex);
            if (oi.isRetraceOrder()) break;
         }
         if (retraceIndex < 0) {
            return false;
         }
         OrderInfo *oi = LongOrders.GetNodeAtIndex(retraceIndex);
         if ((oi.getOpenPrice()+IntervalPrice4Retrace) <= Bid) {
            bool isClosed = closeOrderLong(oi);
            if (isClosed) {
               LongOrders.Delete(retraceIndex);
               delete oi;
               Print("Take Profit The Latest Retrace Long Order.止盈最新回调多单");
               nowOrderTotal4RetraceLong--;
               if (0 < nowOrderTotal4RetraceLong) {
                  nextPrice4RetraceLong += IntervalPrice4Retrace;
               } else if (0 < nowOrderTotal4TrendLong) {
                  OrderInfo *latestTrendOrder = LongOrders.GetLastNode();
                  nextPrice4RetraceLong = latestTrendOrder.getOpenPrice() - IntervalPrice4Retrace;
               } else {
                  nextPrice4RetraceLong = High[0] - IntervalPrice4Retrace;
               }
               return true;
            }
         }
      }
      
      
      
   } else if (OP_SELL == type) {
      if (0 < nowOrderTotal4RetraceShort) {
         int size = ShortOrders.Total();
         int retraceIndex = size-1;
         for(; 0 <= retraceIndex; retraceIndex--) {
            OrderInfo *oi = ShortOrders.GetNodeAtIndex(retraceIndex);
            if (oi.isRetraceOrder()) break;
         }
         if (retraceIndex < 0) {
            return false;
         }
         OrderInfo *oi = ShortOrders.GetNodeAtIndex(retraceIndex);
         
         if ( Ask <= (oi.getOpenPrice()-IntervalPrice4Retrace) ) {
            bool isClosed = closeOrderShort(oi);
            if (isClosed) {
               ShortOrders.Delete(retraceIndex);
               delete oi;
               Print("Take Profit The Latest Retrace Short Order.止盈最新回调空单");
               nowOrderTotal4RetraceShort--;
               if (0 < nowOrderTotal4RetraceShort) {
                  nextPrice4RetraceShort -= IntervalPrice4Retrace;
               } else if (0 < nowOrderTotal4TrendShort) {
                  OrderInfo *latestTrendOrder = ShortOrders.GetLastNode();
                  nextPrice4RetraceShort = latestTrendOrder.getOpenPrice() + IntervalPrice4Retrace;
               } else {
                  nextPrice4RetraceShort = Low[0] + IntervalPrice4Retrace;
               }
               return true;
            }
         }
      }
   
   
   }
   return false;
}



/**********************平仓逆势订单列表中所有盈利单*************************************************/
int closePositiveProfitReverseOrders(CList *orderList) {
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
      
      if (!isClosed) {
         continue;
      }
      
      if (OP_BUY == oi.getOperationType()) {
         Print("Now Short Trend, Close Positive Profit Reverse Long Order.当前空头趋势中平仓逆势多头盈利订单");
         if (oi.isRetraceOrder()) {
            nowOrderTotal4RetraceLong--;
            
         } else {
            nowOrderTotal4TrendLong--;
            
         }
      } else if (OP_SELL == oi.getOperationType()) {
         Print("Now Long Trend, Close Positive Profit Reverse Short Order.当前多头趋势中平仓逆势空头盈利订单");
         if (oi.isRetraceOrder()) {
            nowOrderTotal4RetraceShort--;
         
         } else {
            nowOrderTotal4TrendShort--;
            
         }
      }
      
      result++;
      orderList.Delete(i);
      delete oi;

   }
   
   return result;
}

/**********************平仓顺势订单列表中所有盈利单*************************************************/
int closePositiveProfitTrendOrders(CList *orderList) {
   int result = 0;
   int listSize = orderList.Total();
   for (int i=listSize-1; 0<=i; i--) {
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
      
      if (!isClosed) {
         continue;
      }
      
      if (OP_BUY == oi.getOperationType()) {
         Print("Close Positive Profit Trend Long Order.平仓顺势多头盈利订单");
         if (oi.isRetraceOrder()) {
            orderList.Delete(i);
            nowOrderTotal4RetraceLong--;
            if (0 < nowOrderTotal4RetraceLong) {
               nextPrice4RetraceLong += IntervalPrice4Retrace;
            } else if (0 < nowOrderTotal4TrendLong) {
               OrderInfo *latestTrendOrder = orderList.GetLastNode();
               nextPrice4RetraceLong = latestTrendOrder.getOpenPrice() - IntervalPrice4Retrace;
            } else {
               nextPrice4RetraceLong = High[0] - IntervalPrice4Retrace;
            }
            
         } else {
            orderList.Delete(i);
            nowOrderTotal4TrendLong--;
            if (0 < nowOrderTotal4TrendLong) {
               nextPrice4TrendLong -= IntervalPrice4Trend;
            } else {
               openedOrderInNewCycleLong = false;
            }
         }
      } else if (OP_SELL == oi.getOperationType()) {
         Print("Close Positive Profit Trend Short Order.平仓顺势空头盈利订单");
         if (oi.isRetraceOrder()) {
            orderList.Delete(i);
            nowOrderTotal4RetraceShort--;
            if (0 < nowOrderTotal4RetraceShort) {
               nextPrice4RetraceShort -= IntervalPrice4Retrace;
            } else if (0 < nowOrderTotal4TrendShort) {
               OrderInfo *latestTrendOrder = orderList.GetLastNode();
               nextPrice4RetraceShort = latestTrendOrder.getOpenPrice() + IntervalPrice4Retrace;
            } else {
               nextPrice4RetraceShort = Low[0] + IntervalPrice4Retrace;
            }
         } else {
            orderList.Delete(i);
            nowOrderTotal4TrendShort--;
            if (0 < nowOrderTotal4TrendShort) {
               nextPrice4TrendShort += IntervalPrice4Trend;
            } else {
               openedOrderInNewCycleShort = false;
            }
         }
      }
      
      result++;
      delete oi;

   }
   
   return result;
}

bool isOverMaxReverseHoldOrdersLong() {
   if ((nowOrderTotal4RetraceLong + nowOrderTotal4TrendLong) <= MaxReverseHoldOrders) {
      return false;
   }
   
   HideTestIndicators(true);
   double sarVal = iSAR(NULL, Period_Small, StepSAR, MaximumSAR, 1);
   HideTestIndicators(false);
   double lowVal = iLow(NULL, Period_Small, 1);
   // 趋势相同，
   if (sarVal <= lowVal) {
      double basePrice = High[0]-IntervalPrice4Trend*4;
      // 不做处理
      if ( basePrice < Ask ) {
         return false;
      }
      
      // TODO
      int count = LongOrders.Total();
      for (int i=count-1; 0<=i; i--) {
         OrderInfo *oi = LongOrders.GetNodeAtIndex(i);
         if (basePrice <= oi.getOpenPrice()) {
            continue;
         }
         bool isClosed = closeOrderLong(oi);
         if (!isClosed) {
            continue;
         }
         Print("Retrace is Over 4 Interval,Close Positive Profit Trend Long Order.回调超过4个顺势间距，平仓顺势多头盈利订单");
         if (oi.isRetraceOrder()) {
            LongOrders.Delete(i);
            nowOrderTotal4RetraceLong--;
            if (0 < nowOrderTotal4RetraceLong) {
               nextPrice4RetraceLong += IntervalPrice4Retrace;
            } else if (0 < nowOrderTotal4TrendLong) {
               OrderInfo *latestTrendOrder = LongOrders.GetLastNode();
               nextPrice4RetraceLong = latestTrendOrder.getOpenPrice() - IntervalPrice4Retrace;
            } else {
               nextPrice4RetraceLong = High[0] - IntervalPrice4Retrace;
            }
            
         } else {
            LongOrders.Delete(i);
            nowOrderTotal4TrendLong--;
            if (0 < nowOrderTotal4TrendLong) {
               nextPrice4TrendLong -= IntervalPrice4Trend;
            } else {
               openedOrderInNewCycleLong = false;
            }
         }
         delete oi;
      }
      
      
   // 趋势不同
   } else {
      closePositiveProfitTrendOrders(LongOrders);
   }
   
   return true;
}

ENUM_TIMEFRAMES getPeriod() {
   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)Period();
   if (PERIOD_MN1 == tf) {
      return PERIOD_D1;
   }
   if (PERIOD_W1 == tf) {
      return PERIOD_H4;
   }
   if (PERIOD_D1 == tf) {
      return PERIOD_H1;
   }
   if (PERIOD_H4 == tf) {
      return PERIOD_M30;
   }
   if (PERIOD_H1 == tf) {
      return PERIOD_M15;
   }
   if (PERIOD_M30 == tf) {
      return PERIOD_M5;
   }
   return PERIOD_M1;
}



bool isOverMaxReverseHoldOrdersShort() {
   if ((nowOrderTotal4RetraceShort + nowOrderTotal4TrendShort) <= MaxReverseHoldOrders) {
      return false;
   }
   
   HideTestIndicators(true);
   double sarVal = iSAR(NULL, Period_Small, StepSAR, MaximumSAR, 1);
   HideTestIndicators(false);
   double highVal = iHigh(NULL, Period_Small, 1);
   // 趋势相同
   if (highVal <= sarVal) {
      double basePrice = Low[0]+IntervalPrice4Trend*4;
      // 不做处理
      if ( Bid < basePrice ) {
         return false;
      }
      
      // TODO
      int count = ShortOrders.Total();
      for (int i=count-1; 0<=i; i--) {
         OrderInfo *oi = ShortOrders.GetNodeAtIndex(i);
         if (oi.getOpenPrice() <= basePrice) {
            continue;
         }
         bool isClosed = closeOrderShort(oi);
         if (!isClosed) {
            continue;
         }
         Print("Retrace is Over 4 Interval,Close Positive Profit Trend Short Order.回调超过4个顺势间距，平仓顺势空头盈利订单");
         if (oi.isRetraceOrder()) {
            ShortOrders.Delete(i);
            nowOrderTotal4RetraceShort--;
            if (0 < nowOrderTotal4RetraceShort) {
               nextPrice4RetraceShort -= IntervalPrice4Retrace;
            } else if (0 < nowOrderTotal4TrendShort) {
               OrderInfo *latestTrendOrder = ShortOrders.GetLastNode();
               nextPrice4RetraceShort = latestTrendOrder.getOpenPrice() + IntervalPrice4Retrace;
            } else {
               nextPrice4RetraceShort = Low[0] + IntervalPrice4Retrace;
            }
         } else {
            ShortOrders.Delete(i);
            nowOrderTotal4TrendShort--;
            if (0 < nowOrderTotal4TrendShort) {
               nextPrice4TrendShort += IntervalPrice4Trend;
            } else {
               openedOrderInNewCycleShort = false;
            }
         }
         delete oi;
      }
      
   // 趋势不同
   } else {
      closePositiveProfitTrendOrders(ShortOrders);
   }
   
   return true;
}


/*
bool closeAll() {
   bool isClosedLong = closeAllOrdersList(LongOrders);
   bool isClosedShort = closeAllOrdersList(ShortOrders);
   return (isClosedLong && isClosedShort);
}
*/


void refreshData() {
                                          //  1              2              3              4          5             6             7          8             9              10         11          12            13
const string   ColumnName[13]             ={ "Num",         "ticketL",     "OpenPriceL",  "LotsL",   "ProfitL",    "OrderTypeL", "CloseL",  "ticketS",    "OpenPriceS",  "LotsS",   "ProfitS",  "OrderTypeS", "CloseS"   };
const string   ColumnType[13]             ={ "lbl",         "lbl",         "lbl",         "lbl",     "lbl",        "lbl",        "btn",     "lbl",        "lbl",         "lbl",     "lbl",      "lbl",        "btn"      };
   double sumLotL = 0.0;
   double sumProfitL = 0.0;
   double sumLotS = 0.0;
   double sumProfitS = 0.0;
   long chartId = 0;
   color fontColor;
   int listSize = LongOrders.Total();
   for (int i=0; i<listSize; i++) {
      OrderInfo *oi = LongOrders.GetNodeAtIndex(i);
      ObjectSetString(chartId,ColumnType[1]+ColumnName[1]+IntegerToString(i),OBJPROP_TEXT,IntegerToString(oi.getTicketId()));
      ObjectSetString(chartId,ColumnType[2]+ColumnName[2]+IntegerToString(i),OBJPROP_TEXT,DoubleToStr(oi.getOpenPrice(), Digits));
      ObjectSetString(chartId,ColumnType[3]+ColumnName[3]+IntegerToString(i),OBJPROP_TEXT,DoubleToStr(oi.getLotSize(), 2));
      double profit = 0.0;
      if (OrderSelect(oi.getTicketId(), SELECT_BY_TICKET)) {
         profit = OrderProfit()+OrderCommission()+OrderSwap();
         ObjectSetString(chartId,ColumnType[4]+ColumnName[4]+IntegerToString(i),OBJPROP_TEXT,DoubleToStr(profit, 2));
         fontColor = getProfitFontColor(profit);
      } else {
         ObjectSetString(chartId,ColumnType[4]+ColumnName[4]+IntegerToString(i),OBJPROP_TEXT,"N/A");
         fontColor = clrNONE;
      }
      ObjectSetInteger(chartId,ColumnType[4]+ColumnName[4]+IntegerToString(i),OBJPROP_COLOR,fontColor);
      if (oi.isRetraceOrder()) {
         ObjectSetString(chartId,ColumnType[5]+ColumnName[5]+IntegerToString(i),OBJPROP_TEXT,"Retrace");
      } else {
         ObjectSetString(chartId,ColumnType[5]+ColumnName[5]+IntegerToString(i),OBJPROP_TEXT,"Trend");
      }
      sumLotL += oi.getLotSize();
      sumProfitL += profit;
   }
   
   for (int i=listSize; i<(MaxTrendOrderCount+MaxRetraceOrderCount); i++) {
      ObjectSetString(chartId,ColumnType[1]+ColumnName[1]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[2]+ColumnName[2]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[3]+ColumnName[3]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[4]+ColumnName[4]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[5]+ColumnName[5]+IntegerToString(i),OBJPROP_TEXT,"");
   }
   
   listSize = ShortOrders.Total();
   for (int i=0; i<listSize; i++) {
      OrderInfo *oi = ShortOrders.GetNodeAtIndex(i);
      ObjectSetString(chartId,ColumnType[7]+ColumnName[7]+IntegerToString(i),OBJPROP_TEXT,IntegerToString(oi.getTicketId()));
      ObjectSetString(chartId,ColumnType[8]+ColumnName[8]+IntegerToString(i),OBJPROP_TEXT,DoubleToStr(oi.getOpenPrice(), Digits));
      ObjectSetString(chartId,ColumnType[9]+ColumnName[9]+IntegerToString(i),OBJPROP_TEXT,DoubleToStr(oi.getLotSize(), 2));
      double profit = 0.0;
      if (OrderSelect(oi.getTicketId(), SELECT_BY_TICKET)) {
         profit = OrderProfit()+OrderCommission()+OrderSwap();
         ObjectSetString(chartId,ColumnType[10]+ColumnName[10]+IntegerToString(i),OBJPROP_TEXT,DoubleToStr(profit, 2));
         fontColor = getProfitFontColor(profit);
      } else {
         ObjectSetString(chartId,ColumnType[10]+ColumnName[10]+IntegerToString(i),OBJPROP_TEXT,"N/A");
         fontColor = clrNONE;
      }
      ObjectSetInteger(chartId,ColumnType[10]+ColumnName[10]+IntegerToString(i),OBJPROP_COLOR,fontColor);
      if (oi.isRetraceOrder()) {
         ObjectSetString(chartId,ColumnType[11]+ColumnName[11]+IntegerToString(i),OBJPROP_TEXT,"Retrace");
      } else {
         ObjectSetString(chartId,ColumnType[11]+ColumnName[11]+IntegerToString(i),OBJPROP_TEXT,"Trend");
      }
      
      sumLotS += oi.getLotSize();
      sumProfitS += profit;
   }
   
   for (int i=listSize; i<(MaxTrendOrderCount+MaxRetraceOrderCount); i++) {
      ObjectSetString(chartId,ColumnType[7]+ColumnName[7]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[8]+ColumnName[8]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[9]+ColumnName[9]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[10]+ColumnName[10]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[11]+ColumnName[11]+IntegerToString(i),OBJPROP_TEXT,"");
   }
   
   ObjectSetString(chartId,"SumlblLotsL",OBJPROP_TEXT,DoubleToStr(sumLotL, 2));
   ObjectSetString(chartId,"SumlblProfitL",OBJPROP_TEXT,DoubleToStr(sumProfitL, 2));
   fontColor = getProfitFontColor(sumProfitL);
   ObjectSetInteger(chartId,"SumlblProfitL",OBJPROP_COLOR,fontColor);
   ObjectSetString(chartId,"SumlblLotsS",OBJPROP_TEXT,DoubleToStr(sumLotS, 2));
   ObjectSetString(chartId,"SumlblProfitS",OBJPROP_TEXT,DoubleToStr(sumProfitS, 2));
   fontColor = getProfitFontColor(sumProfitS);
   ObjectSetInteger(chartId,"SumlblProfitS",OBJPROP_COLOR,fontColor);
   
   
   
   ObjectSetString(chartId,"SumlblticketL",OBJPROP_TEXT,DoubleToStr(nextPrice4TrendLong, Digits));
   ObjectSetString(chartId,"SumlblOpenPriceL",OBJPROP_TEXT,DoubleToStr(nextPrice4RetraceLong, Digits));
   ObjectSetString(chartId,"SumlblticketS",OBJPROP_TEXT,DoubleToStr(nextPrice4TrendShort, Digits));
   ObjectSetString(chartId,"SumlblOpenPriceS",OBJPROP_TEXT,DoubleToStr(nextPrice4RetraceShort, Digits));
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (id == CHARTEVENT_OBJECT_CLICK) {
      if ("SumbtnNum" == sparam) {
         if (isRunning) {
            isRunning = false;
            ObjectSetString(0,"SumbtnNum",OBJPROP_TEXT,"E");
            ObjectSetInteger(0,"SumbtnNum",OBJPROP_COLOR,clrBlack);
            ObjectSetInteger(0,"SumbtnNum",OBJPROP_BGCOLOR,clrLime);
         } else {
            isRunning = true;
            ObjectSetString(0,"SumbtnNum",OBJPROP_TEXT,"D");
            ObjectSetInteger(0,"SumbtnNum",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,"SumbtnNum",OBJPROP_BGCOLOR,clrRed);
         }
      } else
      if ("H1btnCloseL" == sparam) {
         closeAllOrdersList(LongOrders);
         nowOrderTotal4RetraceLong=0;
         nowOrderTotal4TrendLong=0;
         openedOrderInNewCycleLong=false;
      } else
      if ("H1btnCloseS" == sparam) {
         closeAllOrdersList(ShortOrders);
         nowOrderTotal4RetraceShort=0;
         nowOrderTotal4TrendShort=0;
         openedOrderInNewCycleShort=false;
      } else
      if ("SumbtnCloseL" == sparam) {
         closePositiveProfitTrendOrders(LongOrders);
      } else
      if ("SumbtnCloseS" == sparam) {
         closePositiveProfitTrendOrders(ShortOrders);
      }
      else {
         string searchStr = "btnCloseL";
         if (0 <= StringFind(sparam, searchStr)) {
            string indexStr = StringSubstr(sparam, StringLen(searchStr));
            OrderInfo *oi = LongOrders.GetNodeAtIndex(StrToInteger(indexStr));
            bool isClosed = closeOrderLong(oi);
            if (isClosed) {
               if (oi.isRetraceOrder()) {
                  LongOrders.Delete(StrToInteger(indexStr));
                  nowOrderTotal4RetraceLong--;
                  if (0 < nowOrderTotal4RetraceLong) {
                     nextPrice4RetraceLong += IntervalPrice4Retrace;
                  } else if (0 < nowOrderTotal4TrendLong) {
                     OrderInfo *latestTrendOrder = LongOrders.GetLastNode();
                     nextPrice4RetraceLong = latestTrendOrder.getOpenPrice() - IntervalPrice4Retrace;
                  } else {
                     nextPrice4RetraceLong = High[0] - IntervalPrice4Retrace;
                  }
                  
               } else {
                  LongOrders.Delete(StrToInteger(indexStr));
                  nowOrderTotal4TrendLong--;
                  if (0 < nowOrderTotal4TrendLong) {
                     nextPrice4TrendLong -= IntervalPrice4Trend;
                  } else {
                     openedOrderInNewCycleLong = false;
                  }
               }
               delete oi;
            }
            
            
         } else {
            searchStr = "btnCloseS";
            if (0 <= StringFind(sparam, searchStr)) {
               string indexStr = StringSubstr(sparam, StringLen(searchStr));
               OrderInfo *oi = ShortOrders.GetNodeAtIndex(StrToInteger(indexStr));
               bool isClosed = closeOrderShort(oi);
               if (isClosed) {
                  if (oi.isRetraceOrder()) {
                     ShortOrders.Delete(StrToInteger(indexStr));
                     nowOrderTotal4RetraceShort--;
                     if (0 < nowOrderTotal4RetraceShort) {
                        nextPrice4RetraceShort -= IntervalPrice4Retrace;
                     } else if (0 < nowOrderTotal4TrendShort) {
                        OrderInfo *latestTrendOrder = ShortOrders.GetLastNode();
                        nextPrice4RetraceShort = latestTrendOrder.getOpenPrice() + IntervalPrice4Retrace;
                     } else {
                        nextPrice4RetraceShort = Low[0] + IntervalPrice4Retrace;
                     }
                  } else {
                     ShortOrders.Delete(StrToInteger(indexStr));
                     nowOrderTotal4TrendShort--;
                     if (0 < nowOrderTotal4TrendShort) {
                        nextPrice4TrendShort += IntervalPrice4Trend;
                     } else {
                        openedOrderInNewCycleShort = false;
                     }
                  }
                  delete oi;
               }
               
               
            }
         }
         
      }
   }
}

color getProfitFontColor(double profit) {
   color fontColor = clrWhite;
   if (profit<0) {
      fontColor=clrRed;
   } else if (0<profit) {
      fontColor=clrGreen;
   }
   return fontColor;
}
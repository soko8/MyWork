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

enum enumCalculateLotType {
   Fixed = 0,
   MoneyManage = 1
};

//--- input parameters
input int         MagicNumber=888888;

// 趋势间距
input int         IntervalTrendPips__=6;
// 最大趋势订单量
input int         MaxTrendOrderCount__=30;
// 回调间距
input int         IntervalRetracePips__=11;
// 最大回调订单量
input int         MaxRetraceOrderCount__=9;
// 加仓系数
input double      AddLotMultiple__=1.4;
// 止盈点数开关
input bool        EnableTakeProfitByPips__=true;
// 止盈点数
input int         TakeProfitPips__=300;
// 止盈美金开关
input bool        EnableTakeProfitByDollars__=false;
// 止盈美金
input double      TakeProfitDollars__=3000.0;
// 对冲止盈美金
input double      TakeProfitDollars4Hedge__=10.0;
// 10000:0.01
// 资金管理
input int         MoneyManagePerLot__=100000;
// 逆势最大持单量
input int         MaxReverseHoldOrders__=12;
// 计算手数类型
input enumCalculateLotType LotType__ = Fixed;
// 固定手数大小
input double      InitLotSize__ = 0.01;


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

      int                  IntervalTrendPips;
      int                  MaxTrendOrderCount;
      int                  IntervalRetracePips;
      int                  MaxRetraceOrderCount;
      double               AddLotMultiple;
      bool                 EnableTakeProfitByPips;
      int                  TakeProfitPips;
      bool                 EnableTakeProfitByDollars;
      double               TakeProfitDollars;
      double               TakeProfitDollars4Hedge;
      int                  MoneyManagePerLot;
      int                  MaxReverseHoldOrders;
enumCalculateLotType       LotType;
      double               InitLotSize;


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
      
      double               Slippage = 20.0;
      
const int                  PIP_DIGIT=1;
const double               StepSAR=0.02;
const double               MaximumSAR=0.2;
const int                  PeriodMA=14;
const int                  ShiftMA=0;
const ENUM_MA_METHOD       MethodMA=MODE_SMA;
const ENUM_APPLIED_PRICE   AppliedPriceMA=PRICE_CLOSE;
/********************************************************************************************************/

int OnInit() {
   //if(!IsDemo()) return(INIT_FAILED);
   
   datetime ExpireTime = D'2022.12.31 23:59:59';
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
   LotType = LotType__;
   InitLotSize = InitLotSize__;
   

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
   
   reloadData();
   
   string msg = "\nMagci:"+IntegerToString(MagicNumber);
   msg += "\n\nMaxCountT:"+IntegerToString(MaxTrendOrderCount__);
   msg += "\n\nIntervalPipT:"+IntegerToString(IntervalTrendPips__);
   msg += "\n\nMaxCountR:"+IntegerToString(MaxRetraceOrderCount__);
   msg += "\n\nIntervalPipR:"+IntegerToString(IntervalRetracePips__);
   msg += "\n\nMultiple:"+DoubleToStr(AddLotMultiple__,1);
   if (EnableTakeProfitByPips__) {
      msg += "\n\nTP(Pip):"+IntegerToString(TakeProfitPips__);
   } else {
      msg += "\n\nTP(Dollar):"+DoubleToStr(TakeProfitDollars__,1);
   }
   msg += "\n\nTP(Hedge):"+DoubleToStr(TakeProfitDollars4Hedge__,1);
   msg += "\n\nMaxHold:"+IntegerToString(MaxReverseHoldOrders__);
   if (Fixed == LotType) {
      msg += "\n\nInitLotSize:"+DoubleToStr(InitLotSize__, 2);
   } else {
      msg += "\n\nMoneyManage:"+IntegerToString(MoneyManagePerLot__);
   }

   Comment(msg);

Print("initLotShort===="+initLotShort);
Print("nowOrderTotal4RetraceShort==="+nowOrderTotal4RetraceShort);
Print("nextPrice4RetraceShort===="+nextPrice4RetraceShort);
Print("nowOrderTotal4TrendShort====="+nowOrderTotal4TrendShort);
Print("nextPrice4TrendShort====="+nextPrice4TrendShort);
Print("openedOrderInNewCycleShort===="+openedOrderInNewCycleShort);

Print("initLotLong===="+initLotLong);
Print("nowOrderTotal4RetraceLong==="+nowOrderTotal4RetraceLong);
Print("nextPrice4RetraceLong===="+nextPrice4RetraceLong);
Print("nowOrderTotal4TrendLong====="+nowOrderTotal4TrendLong);
Print("nextPrice4TrendLong====="+nextPrice4TrendLong);
Print("openedOrderInNewCycleLong===="+openedOrderInNewCycleLong);
   
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
   //Print("SignalType===" + SignalType);
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
         
         if (!openedOrderInNewCycleLong) {
            if (nowOrderTotal4TrendLong<=MaxTrendOrderCount) {
               double lot = calculateFirstLot();
               OrderInfo *oi = createOrderLong(MagicNumber, lot, "First Long Order");
               if (oi.isValid()) {
                  Print("First Long Order.首次多单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
         
         if (!openedOrderInNewCycleShort) {
            if (nowOrderTotal4TrendShort<=MaxTrendOrderCount) {
               double lot = calculateFirstLot();
               OrderInfo *oi = createOrderShort(MagicNumber, lot, "First Short Order");
               if (oi.isValid()) {
                  Print("First Short Order.首次空单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
   
      // 平仓逆势订单列表中所有盈利单
      closePositiveProfitReverseOrders(ShortOrders);
   
      if (nowOrderTotal4RetraceShort < 1 && nowOrderTotal4TrendShort < 1) {
         isTpLong();
         isTpLatestRetraceOrder(OP_BUY);
         
      // 对冲
      } else {
         hedge(ShortOrders, LongOrders);
      }
      isOverMaxReverseHoldOrdersLong();
      
      
      if (nextPrice4TrendLong <= Bid && nowOrderTotal4TrendLong<MaxTrendOrderCount) {
         int apCount = nowOrderTotal4TrendLong + 1;
         OrderInfo *oi = createOrderLong(MagicNumber, initLotLong, "Long Trend Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            Print("Add Trend Long Order.顺势加仓多单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
            LongOrders.Add(oi);
            nowOrderTotal4TrendLong = apCount;
            nextPrice4TrendLong = oi.getOpenPrice() + IntervalPrice4Trend;
            nextPrice4RetraceLong = oi.getOpenPrice() - IntervalPrice4Retrace;
         }
      } else if (Ask<=nextPrice4RetraceLong && nowOrderTotal4RetraceLong<MaxRetraceOrderCount && (nowOrderTotal4RetraceLong+nowOrderTotal4TrendLong)<MaxReverseHoldOrders) {
         int apCount = nowOrderTotal4RetraceLong + 1;
         double lotSize = calculateAPLot(initLotLong, apCount, AddLotMultiple);
         OrderInfo *oi = createOrderLong(MagicNumber, lotSize, "Long Retrace Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            Print("Add Retrace Long Order.回调加仓多单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
            LongOrders.Add(oi);
            nowOrderTotal4RetraceLong = apCount;
            nextPrice4RetraceLong = oi.getOpenPrice() - IntervalPrice4Retrace;
            oi.setRetraceOrder(true);
         }
      }
   }
   
   
   
   if (ENTRY_Short == SignalType || Short_Cross == SignalType || Short_Type == SignalType) {
   
      // 平仓逆势订单列表中所有盈利单
      closePositiveProfitReverseOrders(LongOrders);
   
      if (nowOrderTotal4RetraceLong < 1 && nowOrderTotal4TrendLong < 1) {
         isTpShort();
         isTpLatestRetraceOrder(OP_SELL);

      // 对冲
      } else {
         hedge(LongOrders, ShortOrders);
      }
      isOverMaxReverseHoldOrdersShort();
      
      
      if (Ask <= nextPrice4TrendShort && nowOrderTotal4TrendShort < MaxTrendOrderCount) {
         int apCount = nowOrderTotal4TrendShort + 1;
         OrderInfo *oi = createOrderShort(MagicNumber, initLotShort, "Short Trend Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            Print("Add Trend Short Order.顺势加仓空单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
            ShortOrders.Add(oi);
            nowOrderTotal4TrendShort = apCount;
            nextPrice4TrendShort = oi.getOpenPrice() - IntervalPrice4Trend;
            nextPrice4RetraceShort = oi.getOpenPrice() + IntervalPrice4Retrace;
         }
      } else if (nextPrice4RetraceShort<=Bid && nowOrderTotal4RetraceShort<MaxRetraceOrderCount && (nowOrderTotal4RetraceShort+nowOrderTotal4TrendShort)<MaxReverseHoldOrders) {
         int apCount = nowOrderTotal4RetraceShort + 1;
         double lotSize = calculateAPLot(initLotShort, apCount, AddLotMultiple);
         OrderInfo *oi = createOrderShort(MagicNumber, lotSize, "Short Retrace Order"+IntegerToString(apCount));
         if (oi.isValid()) {
            Print("Add Retrace Short Order.回调加仓空单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
   double sarVal0 = iSAR(NULL, 0, StepSAR, MaximumSAR, 0);
   double sarVal1 = iSAR(NULL, 0, StepSAR, MaximumSAR, 1);
   //double sarVal2 = iSAR(NULL, 0, StepSAR, MaximumSAR, 2);
   double maVal0 = iMA(NULL, 0, PeriodMA, ShiftMA, MethodMA, AppliedPriceMA, 0);
   double maVal1 = iMA(NULL, 0, PeriodMA, ShiftMA, MethodMA, AppliedPriceMA, 1);
   //double maVal2 = iMA(NULL, 0, PeriodMA, ShiftMA, MethodMA, AppliedPriceMA, 2);
   HideTestIndicators(false);
   // 多头
   if (sarVal0 <= Low[0]) {
      if (High[1] >= sarVal1) {
         return ENTRY_Long;
      }
      
      if (sarVal1 <= maVal1 && maVal0 <= sarVal0) {
         return Long_Cross;
      }
      
      return Long_Type;
   
   // 空头
   } else {
      if (sarVal1 <= Low[1]) {
         return ENTRY_Short;
      }
      
      if (sarVal1 >= maVal1 && maVal0 >= sarVal0) {
         return Short_Cross;
      }
   
      return Short_Type;
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
            Print("Short Trend Hedge Long Order.空趋势对冲多单"+"----Ticket:"+IntegerToString(theFurthestHedgeOrder.getTicketId()));
            if (theFurthestHedgeOrder.isRetraceOrder()) {
               nowOrderTotal4RetraceLong--;
            } else {
               nowOrderTotal4TrendLong--;
            }
         }
      } else if (OP_SELL== theFurthestHedgeOrder.getOperationType()) {
         isClosedHedge = closeOrderShort(theFurthestHedgeOrder);
         if (isClosedHedge) {
            Print("Long Trend Hedge Short Order.多趋势对冲空单"+"----Ticket:"+IntegerToString(theFurthestHedgeOrder.getTicketId()));
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
            Print("Short Trend Hedge Order.空趋势对冲单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
            Print("Long Trend Hedge Order.多趋势对冲单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
   if (Fixed == LotType) {
      return InitLotSize;
   }
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
               Print("Take Profit The Latest Retrace Long Order.止盈最新回调多单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
               LongOrders.Delete(retraceIndex);
               delete oi;
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
               Print("Take Profit The Latest Retrace Short Order.止盈最新回调空单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
               ShortOrders.Delete(retraceIndex);
               delete oi;
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
      if ((OrderProfit()+OrderCommission()+OrderSwap()) < Slippage*OrderLots()) {
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
         Print("Now Short Trend, Close Positive Profit Reverse Long Order.当前空头趋势中平仓逆势多头盈利订单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
         if (oi.isRetraceOrder()) {
            nowOrderTotal4RetraceLong--;
            
         } else {
            nowOrderTotal4TrendLong--;
            
         }
      } else if (OP_SELL == oi.getOperationType()) {
         Print("Now Long Trend, Close Positive Profit Reverse Short Order.当前多头趋势中平仓逆势空头盈利订单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
      if ((OrderProfit()+OrderCommission()+OrderSwap()) < Slippage*OrderLots()) {
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
         Print("Close Positive Profit Trend Long Order.平仓顺势多头盈利订单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
         Print("Close Positive Profit Trend Short Order.平仓顺势空头盈利订单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
   double sarVal = iSAR(NULL, Period_Small, StepSAR, MaximumSAR, 0);
   HideTestIndicators(false);
   double lowVal = iLow(NULL, Period_Small, 0);
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
         
         int ticketId = oi.getTicketId();
         bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
         if (!isSelected) {
            Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId) + ". Error:【" + ErrorDescription(GetLastError()));
            continue;
         }
         if ((OrderProfit()+OrderCommission()+OrderSwap()) < Slippage*OrderLots()) {
            continue;
         }
         
         bool isClosed = closeOrderLong(oi);
         if (!isClosed) {
            continue;
         }
         Print("Retrace is Over 4 Interval,Close Positive Profit Trend Long Order.回调超过4个顺势间距，平仓顺势多头盈利订单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
   double sarVal = iSAR(NULL, Period_Small, StepSAR, MaximumSAR, 0);
   HideTestIndicators(false);
   double highVal = iHigh(NULL, Period_Small, 0);
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
         int ticketId = oi.getTicketId();
         bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
         if (!isSelected) {
            Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId) + ". Error:【" + ErrorDescription(GetLastError()));
            continue;
         }
         if ((OrderProfit()+OrderCommission()+OrderSwap()) < Slippage*OrderLots()) {
            continue;
         }
         bool isClosed = closeOrderShort(oi);
         if (!isClosed) {
            continue;
         }
         Print("Retrace is Over 4 Interval,Close Positive Profit Trend Short Order.回调超过4个顺势间距，平仓顺势空头盈利订单"+"----Ticket:"+IntegerToString(oi.getTicketId()));
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
      ObjectSetInteger(chartId,"ReclblNum"+IntegerToString(i),OBJPROP_BGCOLOR,clrBlack);
   }
   
   
   for (int i=listSize; i<(MaxTrendOrderCount+MaxRetraceOrderCount); i++) {
      ObjectSetString(chartId,ColumnType[1]+ColumnName[1]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[2]+ColumnName[2]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[3]+ColumnName[3]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[4]+ColumnName[4]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[5]+ColumnName[5]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetInteger(chartId,"ReclblNum"+IntegerToString(i),OBJPROP_BGCOLOR,clrBlack);
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
      ObjectSetInteger(chartId,"ReclblNum"+IntegerToString(i),OBJPROP_BGCOLOR,clrBlack);
   }
   
   for (int i=listSize; i<(MaxTrendOrderCount+MaxRetraceOrderCount); i++) {
      ObjectSetString(chartId,ColumnType[7]+ColumnName[7]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[8]+ColumnName[8]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[9]+ColumnName[9]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[10]+ColumnName[10]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetString(chartId,ColumnType[11]+ColumnName[11]+IntegerToString(i),OBJPROP_TEXT,"");
      ObjectSetInteger(chartId,"ReclblNum"+IntegerToString(i),OBJPROP_BGCOLOR,clrBlack);
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
   
   if (0 < LongOrders.Total()) {
      ObjectSetInteger(chartId,"ReclblNum"+IntegerToString(LongOrders.Total()-1),OBJPROP_BGCOLOR,clrBlue);
   }
   if (0 < ShortOrders.Total()) {
      ObjectSetInteger(chartId,"ReclblNum"+IntegerToString(ShortOrders.Total()-1),OBJPROP_BGCOLOR,clrRed);
   }
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
         int cnt = closeAllOrdersList(LongOrders);
         if (0 < cnt) {
            Print("Manually close all long orders.手动平仓所有多单");
         }
         nowOrderTotal4RetraceLong=0;
         nowOrderTotal4TrendLong=0;
         openedOrderInNewCycleLong=false;
         refreshData();
      } else
      if ("H1btnCloseS" == sparam) {
         int cnt = closeAllOrdersList(ShortOrders);
         if (0 < cnt) {
            Print("Manually close all short orders.手动平仓所有空单");
         }
         nowOrderTotal4RetraceShort=0;
         nowOrderTotal4TrendShort=0;
         openedOrderInNewCycleShort=false;
         refreshData();
      } else
      if ("SumbtnCloseL" == sparam) {
         int cnt = closePositiveProfitTrendOrders(LongOrders);
         if (0 < cnt) {
            Print("Manually close all positive profit long orders.手动平仓所有盈利多单");
         }
         refreshData();
      } else
      if ("SumbtnCloseS" == sparam) {
         int cnt = closePositiveProfitTrendOrders(ShortOrders);
         if (0 < cnt) {
            Print("Manually close all positive profit short orders.手动平仓所有盈利空单");
         }
         refreshData();
      }
      else {
         string searchStr = "btnCloseL";
         if (0 <= StringFind(sparam, searchStr)) {
            string indexStr = StringSubstr(sparam, StringLen(searchStr));
            if (StrToInteger(indexStr) < nowOrderTotal4TrendLong+nowOrderTotal4RetraceLong) {
            OrderInfo *oi = LongOrders.GetNodeAtIndex(StrToInteger(indexStr));
            bool isClosed = closeOrderLong(oi);
            if (isClosed) {
               Print("Manually close a long order.手动平仓一个多单"+" ----Ticket:"+IntegerToString(oi.getTicketId()));
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
               refreshData();
            }
            }
            
         } else {
            searchStr = "btnCloseS";
            if (0 <= StringFind(sparam, searchStr)) {
               string indexStr = StringSubstr(sparam, StringLen(searchStr));
               if (StrToInteger(indexStr) < nowOrderTotal4TrendShort+nowOrderTotal4RetraceShort) {
               OrderInfo *oi = ShortOrders.GetNodeAtIndex(StrToInteger(indexStr));
               bool isClosed = closeOrderShort(oi);
               if (isClosed) {
                  Print("Manually close a short order.手动平仓一个空单"+" ----Ticket:"+IntegerToString(oi.getTicketId()));
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
                  refreshData();
               }
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

void reloadData() {
   int TradeListL[][2];
   int TradeListS[][2];
   int cntL = 0;
   int cntS = 0;
   int cnt = OrdersTotal();
   for (int pos=0; pos<cnt; pos++) {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderMagicNumber()!=MagicNumber) continue;
      if(OrderSymbol()!=_Symbol) continue;
      
      if (OP_BUY == OrderType()) {
         cntL++;
		   ArrayResize(TradeListL, cntL);
		   TradeListL[cntL-1][0] = OrderOpenTime();
		   TradeListL[cntL-1][1] = OrderTicket();
      
      } else
      if (OP_SELL == OrderType()) {
         cntS++;
		   ArrayResize(TradeListS, cntS);
		   TradeListS[cntS-1][0] = OrderOpenTime();
		   TradeListS[cntS-1][1] = OrderTicket();
      }
   }
   
   ArraySort(TradeListL,WHOLE_ARRAY,0,MODE_ASCEND);
   ArraySort(TradeListS,WHOLE_ARRAY,0,MODE_ASCEND);
   
   
   HideTestIndicators(true);
   double sarVal = iSAR(NULL, 0, StepSAR, MaximumSAR, 1);
   double val = iHigh(NULL, 0, 1);
   
   bool isLong = true;
   if (val <= sarVal) {
      isLong = false;
   }
   
   int barShift = 1;
   bool isReverse = false;
   if (isLong) {
      while (!isReverse && !IsStopped()) {
         barShift++;
         sarVal = iSAR(NULL, 0, StepSAR, MaximumSAR, barShift);
         val = iLow(NULL, 0, barShift);
         if (sarVal <= val) {
            continue;
         } else {
            isReverse = true;
         }
      }
   } else {
      while (!isReverse && !IsStopped()) {
         barShift++;
         sarVal = iSAR(NULL, 0, StepSAR, MaximumSAR, barShift);
         val = iHigh(NULL, 0, barShift);
         if (val <= sarVal) {
            continue;
         } else {
            isReverse = true;
         }
      }
   }
   HideTestIndicators(false);
   barShift--;
   datetime trendStartTime = iTime(NULL,0,barShift);
   
   datetime nowBarStartTime = Time[0];
   
   /************************************************/
   initLotLong = 0.0;
   
   nowOrderTotal4TrendLong = 0;
   nowOrderTotal4RetraceLong = 0;
   
   nextPrice4TrendLong = 0.0;
   nextPrice4RetraceLong = 0.0;
   
   openedOrderInNewCycleLong=false;
   
   for (int i=0; i<cntL; i++) {
      if (!OrderSelect(TradeListL[i][1], SELECT_BY_TICKET)) continue;
      
      OrderInfo *oi = new OrderInfo;
      oi.setValid(true);
      oi.setLotSize(OrderLots());
      oi.setOpenPrice(OrderOpenPrice());
      oi.setOperationType(OP_BUY);
      oi.setSymbolName(_Symbol);
      oi.setTicketId(TradeListL[i][1]);
      string comment = OrderComment();
      oi.setRetraceOrder(false);
      if (0 <= StringFind(comment, "Retrace")) {
         oi.setRetraceOrder(true);
         nowOrderTotal4RetraceLong++;
         if (isLong && trendStartTime<=OrderOpenTime()) {
            nextPrice4RetraceLong = oi.getOpenPrice() - IntervalPrice4Retrace;
         }
         
      } else {
         nowOrderTotal4TrendLong++;
         if (isLong && trendStartTime<=OrderOpenTime()) {
            initLotLong = oi.getLotSize();
            nextPrice4TrendLong = oi.getOpenPrice() + IntervalPrice4Trend;
         }
      }
      if (isLong && nowBarStartTime<=OrderOpenTime()) {
         openedOrderInNewCycleLong = true;
      }
      
      LongOrders.Add(oi);
   }
   
   // 当前趋势只有趋势单
   if (0.00001<nextPrice4TrendLong && nextPrice4RetraceLong<0.00001) {
      if (isLong) {
         nextPrice4RetraceLong = OrderOpenPrice() - IntervalPrice4Retrace;
      }
   }
   // 当前趋势只有回调单
   if (0.00001<nextPrice4RetraceLong && nextPrice4TrendLong<0.00001) {
      if (isLong) {
         initLotLong = calculateFirstLot();
         nextPrice4TrendLong = Ask;
      }
   }
   
   
   /*********************************************************************/
   
   /************************************************/
   initLotShort = 0.0;
   
   nowOrderTotal4TrendShort = 0;
   nowOrderTotal4RetraceShort = 0;
   
   nextPrice4TrendShort = 0.0;
   nextPrice4RetraceShort = 0.0;
   
   openedOrderInNewCycleShort=false;
   
   for (int i=0; i<cntS; i++) {
      if (!OrderSelect(TradeListS[i][1], SELECT_BY_TICKET)) continue;
      
      OrderInfo *oi = new OrderInfo;
      oi.setValid(true);
      oi.setLotSize(OrderLots());
      oi.setOpenPrice(OrderOpenPrice());
      oi.setOperationType(OP_BUY);
      oi.setSymbolName(_Symbol);
      oi.setTicketId(TradeListS[i][1]);
      string comment = OrderComment();
      oi.setRetraceOrder(false);
      if (0 <= StringFind(comment, "Retrace")) {
         oi.setRetraceOrder(true);
         nowOrderTotal4RetraceShort++;
         if (!isLong && trendStartTime<=OrderOpenTime()) {
            nextPrice4RetraceShort = oi.getOpenPrice() + IntervalPrice4Retrace;
         }
         
      } else {
         nowOrderTotal4TrendShort++;
         if (!isLong && trendStartTime<=OrderOpenTime()) {
            initLotShort = oi.getLotSize();
            nextPrice4TrendShort = oi.getOpenPrice() - IntervalPrice4Trend;
         }
      }
      if (!isLong && nowBarStartTime<=OrderOpenTime()) {
         openedOrderInNewCycleShort = true;
      }
      
      ShortOrders.Add(oi);
   }
   
   // 当前趋势只有趋势单
   if (0.00001<nextPrice4TrendShort && nextPrice4RetraceShort<0.00001) {
      if (!isLong) {
         nextPrice4RetraceShort = OrderOpenPrice() + IntervalPrice4Retrace;
      }
   }
   // 当前趋势只有回调单
   if (0.00001<nextPrice4RetraceShort && nextPrice4TrendShort<0.00001) {
      if (!isLong) {
         initLotShort = calculateFirstLot();
         nextPrice4TrendShort = Bid;
      }
   }
   
   
   /*********************************************************************/
   refreshData();
}
//+------------------------------------------------------------------+
//| EA_HandOfGod.mq4 |
//| Copyright 2021, MetaQuotes Software Corp. |
//| https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict
//--- input parameters
input int         MagicNumber=888888;
input int         GridPips=5;
input int         MaxGridOrders=12;
input int         GridPips4AP=15;
input int         MaxAPOrders=4;
input double      AddLotMultiple=2.0;
input bool        EnableTakeProfitByPips=true;
input int         TakeProfitPips=150;
input bool        EnableTakeProfitByDollars=false;
input double      TakeProfitDollars=2000.0;
input double      TakeProfitDollars4Hedge=20.0;
// 10000:0.01
input int         MoneyManagePerLot=1000000;

#include <stdlib.mqh>
#include <Object.mqh>
#include <Arrays\List.mqh>

enum enSignalType {
   ENTRY_Long = 1,
   Long_Type = 2,
   Long_Cross = 3,         // 多转空
   None_Type = 0,
   ENTRY_Short = -1,
   Short_Type = -2,
   Short_Cross = -3        // 空转多
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
   bool              apMode;
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
   void              setApMode(bool ap_) { this.apMode = ap_; }
   bool              isApMode(void) const { return(apMode); }
};

OrderInfo::OrderInfo() {
   active = false;
   closed = false;
   valid = false;
   apMode = false;
}

OrderInfo::~OrderInfo() {
}
/********************************************************************************************************/
      CList                *LongOrders;
      CList                *ShortOrders;
      double               LotStepServer = 0.0;
      double               minLot = 0.0;
      enSignalType         signal;
      datetime             timeFlag;
      double               gridPrice;
      double               gridPrice4Ap;
      double               targetProfit;
      
      double               initLotLong = 0.0;
      int                  addPositionTimesLong = 0;
      //double               slPriceLong = 0.0;
      //double               tpPriceLong = 0.0;
      double               apPriceLong = 0.0;
      int                  addPositionTimes4GridLong = 0;
      double               apPrice4GridLong = 0.0;
      bool                 openedOrderInNewCycleLong=false;

      
      double               initLotShort = 0.0;
      int                  addPositionTimesShort = 0;
      //double               slPriceShort = 0.0;
      //double               tpPriceShort = 0.0;
      double               apPriceShort = 0.0;
      int                  addPositionTimes4GridShort = 0;
      double               apPrice4GridShort = 0.0;
      bool                 openedOrderInNewCycleShort=false;

      
const int                  PIP_DIGIT=1;
const double               StepSAR=0.02;
const double               MaximumSAR=0.2;
const int                  PeriodMA=14;
const int                  ShiftMA=0;
const ENUM_MA_METHOD       MethodMA=MODE_SMA;
const ENUM_APPLIED_PRICE   AppliedPriceMA=PRICE_CLOSE;
/********************************************************************************************************/

int OnInit() {
   LotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);
   minLot = MarketInfo(_Symbol, MODE_MINLOT);
   LongOrders = new CList;
   ShortOrders = new CList;
   timeFlag = 0;
   gridPrice = pip2price(GridPips);
   gridPrice4Ap = pip2price(GridPips4AP);
   targetProfit = TakeProfitDollars;
   if (EnableTakeProfitByPips) {
      targetProfit = TakeProfitPips*10;
   }
   
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {
   LongOrders.Clear();
   delete LongOrders;
   ShortOrders.Clear();
   delete ShortOrders;
}

void OnTick() {
   if (isNewBar()) {
      signal = getSignal();
      timeFlag = Time[0];
   }
   
   switch(signal) {
            // 多转空，锁仓
      case Long_Cross : 
      case Long_Type : 
      case ENTRY_Long : {
         if (!openedOrderInNewCycleLong) {
            if (addPositionTimes4GridLong<=MaxGridOrders) {
               Print("111111111111111111111");
               double lot = calculateFirstLot();
               OrderInfo *oi = createOrderLong(lot);
               if (oi.isValid()) {
                  LongOrders.Add(oi);
                  initLotLong = lot;
                  addPositionTimesLong = 0;
                  apPriceLong = oi.getOpenPrice() - gridPrice4Ap;
                  openedOrderInNewCycleLong = true;
                  addPositionTimes4GridLong++;
                  apPrice4GridLong = oi.getOpenPrice() + gridPrice;
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
            if (addPositionTimes4GridShort<=MaxGridOrders) {
            Print("111111111111111111111");
               double lot = calculateFirstLot();
               OrderInfo *oi = createOrderShort(lot);
               if (oi.isValid()) {
                  ShortOrders.Add(oi);
                  initLotShort = lot;
                  addPositionTimesShort = 0;
                  apPriceShort = oi.getOpenPrice() + gridPrice4Ap;
                  openedOrderInNewCycleShort = true;
                  addPositionTimes4GridShort++;
                  apPrice4GridShort = oi.getOpenPrice() - gridPrice;
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
   
   if (ENTRY_Long == signal || Long_Cross == signal || Long_Type == signal) {
      if (addPositionTimesShort < 1 && addPositionTimes4GridShort < 1) {
         if (!isTpLong()) {
            if (apPrice4GridLong <= Bid && addPositionTimes4GridLong<MaxGridOrders) {
            Print("222222222222222222");
               int apCount = addPositionTimes4GridLong + 1;
               OrderInfo *oi = createOrderLong(initLotLong);
               if (oi.isValid()) {
                  LongOrders.Add(oi);
                  addPositionTimes4GridLong = apCount;
                  apPrice4GridLong = oi.getOpenPrice() + gridPrice4Ap;
               }
            } else if (Ask <= apPriceLong && addPositionTimesLong<MaxAPOrders) {
            Print("333333333333333333");
               int apCount = addPositionTimesLong + 1;
               double lotSize = calculateAPLot(initLotLong, apCount, AddLotMultiple);
               OrderInfo *oi = createOrderLong(lotSize);
               if (oi.isValid()) {
                  LongOrders.Add(oi);
                  addPositionTimesLong = apCount;
                  apPriceLong = oi.getOpenPrice() - gridPrice;
                  oi.setApMode(true);
               }
            }
         }
         
      // 对冲
      } else {
         hedge(ShortOrders, LongOrders);
      }
   }
   
   
   
   if (ENTRY_Short == signal || Short_Cross == signal || Short_Type == signal) {
      if (addPositionTimesLong < 1 && addPositionTimes4GridLong < 1) {
         if (!isTpShort()) {
            if (Ask <= apPrice4GridShort && addPositionTimes4GridShort < MaxGridOrders) {
            Print("222222222222222222");
               int apCount = addPositionTimes4GridShort + 1;
               OrderInfo *oi = createOrderShort(initLotShort);
               if (oi.isValid()) {
                  ShortOrders.Add(oi);
                  addPositionTimes4GridShort = apCount;
                  apPrice4GridShort = oi.getOpenPrice() - gridPrice4Ap;
               }
            } else if (apPriceShort <= Bid && addPositionTimesShort < MaxAPOrders) {
            Print("333333333333333333");
               int apCount = addPositionTimesShort + 1;
               double lotSize = calculateAPLot(initLotShort, apCount, AddLotMultiple);
               OrderInfo *oi = createOrderShort(lotSize);
               if (oi.isValid()) {
                  ShortOrders.Add(oi);
                  addPositionTimesShort = apCount;
                  apPriceShort = oi.getOpenPrice() + gridPrice;
                  oi.setApMode(true);
               }
            }
         }
      // 对冲
      } else {
         hedge(LongOrders, ShortOrders);
      }
   }
   
   
   

}

enSignalType getSignal() {
   //HideTestIndicators(true);
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

double calculateProfitUnilateral(CList *orderList) {
   double profit = 0.0;
   int listSize = orderList.Total();
   for(int i=0; i<listSize; i++) {
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      if(OrderSelect(ticketId, SELECT_BY_TICKET)) {
         profit += OrderProfit() + OrderCommission() + OrderSwap();
      } else {
         Print("OrderSelect Error. Ticket:" + IntegerToString(ticketId));
      }
   }
   return profit;
}

double calculateAllProfit(CList *orderList) {
   double profit = calculateProfitUnilateral(LongOrders);
   profit += calculateProfitUnilateral(ShortOrders);
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
      if (OP_BUY== theFurthestHedgeOrder.getOperationType()) {
         closeOrderLong(theFurthestHedgeOrder);
         if (theFurthestHedgeOrder.isApMode()) {
            addPositionTimesLong--;
         } else {
            addPositionTimes4GridLong--;
         }
      } else if (OP_SELL== theFurthestHedgeOrder.getOperationType()) {
         closeOrderShort(theFurthestHedgeOrder);
         if (theFurthestHedgeOrder.isApMode()) {
            addPositionTimesShort--;
         } else {
            addPositionTimes4GridShort--;
         }
      }
      
   
      int size = orderList.Total();
      for(int i=size-1; endIndex < i; i--) {
         OrderInfo *oi = orderList.GetNodeAtIndex(i);
         if (OP_BUY== theFurthestHedgeOrder.getOperationType()) {
            closeOrderShort(oi);
            if (oi.isApMode()) {
               addPositionTimesShort--;
               if (0 < i) {
                  apPriceShort -= gridPrice4Ap;
               }
            } else {
               addPositionTimes4GridShort--;
               if (0 < i) {
                  apPrice4GridShort += gridPrice;
               }
            }
            
            
            
         } else if (OP_SELL== theFurthestHedgeOrder.getOperationType()) {
            closeOrderLong(oi);
            
            if (oi.isApMode()) {
               addPositionTimesLong--;
               if (0 < i) {
                  apPriceLong += gridPrice4Ap;
               }
            } else {
               addPositionTimes4GridLong--;
               if (0 < i) {
                  apPrice4GridLong -= gridPrice;
               }
            }

         }
         orderList.Delete(i);
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
   if(timeFlag != iTime(NULL, 0, 0)) {
      timeFlag = iTime(NULL, 0, 0);
      return true;
   }
   return false;
}

double calculateFirstLot() {
   double lot = AccountBalance()/MoneyManagePerLot;
   lot = MathCeil(lot/LotStepServer)*LotStepServer;
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

double getAllLotsUnilateral(CList *orderList) {
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

bool isTpLong() {
   double profit = calculateProfitUnilateral(LongOrders);
   double lots = getAllLotsUnilateral(LongOrders);
   if (targetProfit*lots <= profit) {
      closeAllOrdersLong();
      initLotLong = 0;
      addPositionTimesLong = 0;
      apPriceLong = 0;
      openedOrderInNewCycleLong = false;
      addPositionTimes4GridLong=0;
      apPrice4GridLong = 0;
      
      return true;
   }
   return false;
}

bool isTpShort() {
   double profit = calculateProfitUnilateral(ShortOrders);
   double lots = getAllLotsUnilateral(ShortOrders);
   if (targetProfit*lots <= profit) {
      closeAllOrdersShort();
      initLotShort = 0;
      addPositionTimesShort = 0;
      apPriceShort = 0;
      openedOrderInNewCycleShort = false;
      addPositionTimes4GridShort=0;
      apPrice4GridShort = 0;
      
      return true;
   }
   return false;
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
   int ticketId  = OrderSend(_Symbol, OP_SELL , lotSize, Bid, 0, slPrice, tpPrice, "", MagicNumber, 0, clrRed);
   
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
      string msg = "OrderClose failed in closeOrderShort. Error:【" + ErrorDescription(GetLastError());
      msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
      msg += " Ask=" + DoubleToStr(Ask, Digits);
      Alert(msg);
   }
   
   return isClosed;
}

bool  closeAllOrdersLong() {
   int listSize = LongOrders.Total();
   bool hasFail = false;
   for (int i = listSize-1; 0 <= i; i--) {
      bool isClosed = false;
      OrderInfo *oi = LongOrders.GetNodeAtIndex(i);
      if (OP_BUY == oi.getOperationType()) {
         isClosed = closeOrderLong(oi);
      }
      
      if (isClosed) {
         LongOrders.Delete(i);
         delete oi;
      } else {
         hasFail = true;
      }
   }
   
   return !hasFail;
}

bool  closeAllOrdersShort() {
   int listSize = ShortOrders.Total();
   bool hasFail = false;
   for (int i = listSize-1; 0 <= i; i--) {
      bool isClosed = false;
      OrderInfo *oi = ShortOrders.GetNodeAtIndex(i);
      if (OP_SELL == oi.getOperationType()) {
         isClosed = closeOrderShort(oi);
      }
      
      if (isClosed) {
         ShortOrders.Delete(i);
         delete oi;
      } else {
         hasFail = true;
      }
   }

   return !hasFail;
}

bool closeAll() {
   bool isClosedLong = closeAllOrdersLong();
   bool isClosedShort = closeAllOrdersShort();
   return (isClosedLong && isClosedShort);
}



void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

}
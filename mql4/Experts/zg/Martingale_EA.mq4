//+------------------------------------------------------------------+
//|                                                Martingale_EA.mq4 |
//|                  Copyright 2018～2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <OrderInfo.mqh>
#include <Arrays\List.mqh>
#include <DrawObjects.mqh>
#include <Utils.mqh>

enum enCloseMode
{
   Close_All = 0,
   Close_Part = 1,
   Close_Part_All = 2
};

enum enAddPositionMode
{
   Fixed = 0,
   Multiplied = 1
};

enum enButtonMode
{
   Close_Order_Mode = 0,
   Create_Order_Mode = 1
};

//--- input parameters
input double               InitLotSize=0.01;
input int                  GridPoints=210;
input int                  TakeProfitPoints = 30;
input double               RetraceProfitCoefficient = 0.25;
input int                  MaxTimesAddPosition = 13;
input bool                 AddPositionByTrend = false;
input enCloseMode          CloseMode = Close_Part_All;
input enAddPositionMode    AddPositionMode = Multiplied;
input double               LotAddPositionStep = 0.01;
input double               LotAddPositionMultiple = 1.75;
input int                  MagicNumber=888888;
input double               MaxLots4AddPositionLimit=0.4;

      double               initLots;
      int                  grid;
      double               gridPrice;
      
      int                  tpPoints;
      double               tp;
      double               retraceProfitRatio;
      int                  maxTimes4AP;
      int                  times_Part2All;
      bool                 addPosition2Trend;
      
      enCloseMode          closePositionMode;
      enAddPositionMode    addPositionMode;
      
      double               lotStep;
      double               lotMultiple;

      CList               *OrderListL;
      CList               *OrderListS;

const string               nmLineClosePositionBuy = "ClosePositionBuy";
const string               nmLineClosePositionSell = "ClosePositionSell";


      enButtonMode         btnModeBuy;
      enButtonMode         btnModeSell;

/***************** stop resume button Begin **********/
const string      nmBtnStopResume         = "StopResume";
const string      txtBtnStop              = "Stop";
const string      txtBtnResume            = "Resume";
const color       color4BtnStop           = clrLightSalmon;
const color       color4BtnResume         = clrLime;
      bool        isActive                = false;
/***************** stop resume button End   **********/

/***************** Decrease Position long position button Begin **********/
const string      nmBtnDecreasePositionLong      = "DecreaseLong";
const string      txtBtnDecreasePositionLong     = "-Long";
/***************** close half long position button End   **********/

/***************** Decrease Position short position button Begin *********/
const string      nmBtnDecreasePositionShort     = "DecreaseShort";
const string      txtBtnDecreasePositionShort    = "-Short";
/***************** close half short position button End   *********/

/***************** Profit Status RectLabel Begin ******************/
const string      nmRectLabelProfitStatus = "ProfitStatusRectLabel";
const string      nmLabelProfitLong       = "LongProfit";
const string      nmLabelProfitShort      = "ShortProfit";
const string      nmLabelTotalProfitValue = "TotalProfit";

const string      nmLabelProfitDPLong = "ProfitDecreasePositionLong";
const string      nmLabelProfitDPShort = "ProfitDecreasePositionShort";
/***************** Profit Status RectLabel End   ******************/

/***************** close all long position button Begin ***********/
const string      nmBtnCloseLong      = "CloseLong";
const string      txtBtnCloseLong     = "CloseBuy";
const string      txtBtnCreateLong     = "CreateBuy";
/***************** close all long position button End   ***********/

/***************** close all short position button Begin **********/
const string      nmBtnCloseShort     = "CloseShort";
const string      txtBtnCloseShort    = "CloseSell";
const string      txtBtnCreateShort    = "CreateSell";
/***************** close all short position button End   **********/

/***************** forbid Create Order button Begin **********/
const string      nmBtnForbidCreateOrderManual           = "ForbidCreateOrder";
const string      txtBtnForbidCreateOrderManual          = "Forbid";
const string      txtBtnAllowCreateOrderManual           = "Allow";
const color       color4BtnForbidCreateOrderManual       = clrLightSalmon;
const color       color4BtnAllowCreateOrderManual        = clrLime;
      bool        isForbidCreateOrderManual              = false;
/***************** forbid Create Order button End   **********/

/**************************Input Parameters begin*****************************************************/
const color       btnColorEnable=clrBlueViolet;
const color       btnColorDisable=clrDimGray;

const string      btnNmInitLotUp="InitLotUp";
const string      lblNmInitLotValue="InitLotValue";
const string      btnNmInitLotDn="InitLotDn";

const string      btnNmGridPointsUp="GridPointsUp";
const string      lblNmGridPointsValue="GridPointsValue";
const string      btnNmGridPointsDn="GridPointsDn";

const string      btnNmTakeProfitPointsUp="TakeProfitPointsUp";
const string      lblNmTakeProfitPointsValue="TakeProfitPointsValue";
const string      btnNmTakeProfitPointsDn="TakeProfitPointsDn";

const string      btnNmRetraceProfitCoefficientUp="RetraceProfitCoefficientUp";
const string      lblNmRetraceProfitCoefficientValue="RetraceProfitCoefficientValue";
const string      btnNmRetraceProfitCoefficientDn="RetraceProfitCoefficientDn";

const string      btnNmMaxTimesAddPositionUp="MaxTimesAddPositionUp";
const string      lblNmMaxTimesAddPositionValue="MaxTimesAddPositionValue";
const string      btnNmMaxTimesAddPositionDn="MaxTimesAddPositionDn";

const string      btnNmAddOrderByTrend="AddOrderByTrend";
const string      btnTxtAddOrderByTrend="Add Order By Trend";
const string      btnTxtNotAddOrderByTrend="Don't Add Order By Trend";

const string      btnNmCMCloseAll="CloseMode_CloseAll";
const string      btnNmCMClosePart="CloseMode_ClosePart";
const string      btnNmCMClosePartAll="CloseMode_ClosePartAll";

const string      btnNmAPMFixed="AddOrder_Fixed";
const string      btnNmAPMMultiplied="AddOrder_Multiplied";

const string      lblNmLotAddPositionLabel="LotAddPositionLabel";
const string      lblTxtLotAddPositionStep="Lots Add Order Step";
const string      lblTxtLotAddPositionMultiple="Lots Add Order Multiple";
const string      btnNmLotAddPositionUp="LotAddPositionUp";
const string      lblNmLotAddPositionValue="LotAddPositionValue";
const string      btnNmLotAddPositionDn="LotAddPositionDn";

const string      btnNmMaxLots4AddPositionLimitUp="MaxLots4AddPositionLimitUp";
const string      lblNmMaxLots4AddPositionLimitValue="MaxLots4AddPositionLimitValue";
const string      btnNmMaxLots4AddPositionLimitDn="MaxLots4AddPositionLimitDn";
/**************************Input Parameters end  *****************************************************/

/**************************new 4 buttons begin*****************************************************/
const string      btnNmCloseMaxBuyOrder="CloseMaxBuyOrder";
const string      btnNmCloseMaxSellOrder="CloseMaxSellOrder";
const string      lblNmProfitMaxBuyOrder="ProfitMaxBuyOrder";
const string      lblNmProfitMaxSellOrder="ProfitMaxSellOrder";
const string      btnNmAdd1BuyOrder="Add1BuyOrder";
const string      btnNmAdd1SellOrder="Add1SellOrder";
/**************************new 4 buttons end  *****************************************************/


/***********************************Display Runtime Info begin**************************************/
const string      lblnmCloseBuyProfit = "CloseBuyProfit";
const string      lblnmCloseSellProfit = "CloseSellProfit";

const string      lblnmRetraceRatioBuy = "RetraceRatioBuy";
const string      lblnmRetraceRatioSell = "RetraceRatioSell";

const string      lblnmCountAPBuy = "CountAPBuy";
const string      lblnmCountAPSell = "CountAPSell";
/***********************************Display Runtime Info end  **************************************/

      bool        isStopedByNews          = false;
      datetime    stopedTimeByNews        = 0;
      bool        forbidCreateOrder       = false;
      bool        mustStopEAByNews        = false;
      int         hoursForbidCreateOrderBeforeNews = 24;
      int         minutesMustStopEABeforeNews = 10;
      int         minutesAfterNewsResume  = 180;


      bool        enableMaxLotControl = true;
      double      Max_Lot_AP = 0;
      
      bool        AccountCtrl = false;
      int         AuthorizeAccountList[4] = {  6154218
                                              ,7100152
                                             };
      bool        EnableUseTimeControl=true;
      datetime    ExpireTime = D'2019.12.31 23:59:59';

      int         TxtFontSize = 8;
      int         BtnFontSize = 8;
      
      int         APRule_Grid[];
      double      APRule_GridPrice[];
      double      APRule_LotL[];
      double      APRule_LotS[];
      double      APRule_RetraceRatio[];
      int         APRule_Retrace[];
      double      APRule_RetracePrice[];
      
      int         SL = 10;
      double      SL_Price = 0.0;
      double      LotStepServer = 0.0;

void initLotRule(double initLotSize, double& lotArray[]) {
   ArrayResize(lotArray, maxTimes4AP);
   double loti = initLotSize;
   lotArray[0] = loti;
   for (int i=1; i < maxTimes4AP; i++) {
      loti *= lotMultiple;
      lotArray[i] = MathCeil(loti/LotStepServer)*LotStepServer;
   }
}

void initGridRule() {
   ArrayResize(APRule_Grid, maxTimes4AP);
   ArrayResize(APRule_GridPrice, maxTimes4AP);
   APRule_Grid[0] = 0;
   APRule_GridPrice[0] = 0.0;
   for (int i=1; i < maxTimes4AP; i++) {
      APRule_Grid[i] = grid;
      APRule_GridPrice[i] = gridPrice;
   }
}

bool isCloseAllMode(int i) {
   if (Close_All == closePositionMode) {
      return true;
   }
   
   if (Close_Part_All == closePositionMode && times_Part2All <= i) {
      return true;
   }
   
   return false;
}

bool isClosePartMode(int i) {
   if (Close_Part == closePositionMode) {
      return true;
   }
   
   if (Close_Part_All == closePositionMode && i < times_Part2All) {
      return true;
   }
   
   return false;
}

void initRetraceRule() {
   ArrayResize(APRule_RetraceRatio, maxTimes4AP);
   ArrayResize(APRule_Retrace, maxTimes4AP);
   ArrayResize(APRule_RetracePrice, maxTimes4AP);
   APRule_RetraceRatio[0] = 0.0;
   APRule_Retrace[0] = tpPoints;
   APRule_RetracePrice[0] = tp;
   for (int i=1; i < maxTimes4AP; i++) {
      double retraceRatio = 0.0;
      if (Fixed == addPositionMode) {
         retraceRatio = calculateRetrace4Fixed(i, initLots) + retraceProfitRatio;
      } else {
         if ( isCloseAllMode(i) ) {
            retraceRatio = calculateRetraceAll(i, lotMultiple) + retraceProfitRatio;
         } else if ( isClosePartMode(i) ) {
            retraceRatio = calculateRetracePart(i, lotMultiple) + retraceProfitRatio;
         }
      }
      APRule_RetraceRatio[i] = retraceRatio;
      int retracePoint = (int) MathCeil(retraceRatio * APRule_Grid[i]);
      APRule_Retrace[i] = retracePoint;
      APRule_RetracePrice[i] = NormalizeDouble(Point * retracePoint, Digits);
   }
}

int OnInit() {

   if (!isAuthorized(AccountCtrl, AuthorizeAccountList)) {
		return INIT_FAILED;
	}
	
   if (isExpire(EnableUseTimeControl, ExpireTime)) {
      return INIT_FAILED;
   }

   if (0 < countOrders(MagicNumber, _Symbol)) {
      Alert("Order Exist。Please manually delete Order or modify input parameter MagicNumber.");
      return(INIT_FAILED);
   }

   double minLot = MarketInfo(_Symbol, MODE_MINLOT);
   if (InitLotSize < minLot) {
      initLots = minLot;
   } else {
      initLots = InitLotSize;
   }
   
   grid = GridPoints;
   gridPrice = NormalizeDouble(Point * grid, Digits);
   
   tpPoints = TakeProfitPoints;
   tp = NormalizeDouble(Point * tpPoints, Digits);
   retraceProfitRatio = RetraceProfitCoefficient;
   maxTimes4AP = MaxTimesAddPosition;
   times_Part2All = maxTimes4AP - 3;
   addPosition2Trend = AddPositionByTrend;
   
   closePositionMode = CloseMode;
   addPositionMode = AddPositionMode;
   
   lotStep = LotAddPositionStep;
   lotMultiple = LotAddPositionMultiple;
   
   Max_Lot_AP = MaxLots4AddPositionLimit;
   
   OrderListL = new CList;
   OrderListS = new CList;
   
   btnModeBuy = Create_Order_Mode;
   btnModeSell = Create_Order_Mode;
   
   drawTotal();
   drawLongShort();
   drawInputParameters();
   
   SL_Price = pips2Price(_Symbol, SL);
   LotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   initGridRule();
   initLotRule(initLots, APRule_LotL);
   initLotRule(initLots, APRule_LotS);
   initRetraceRule();
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll();
   OrderListL.Clear();
   OrderListS.Clear();
   delete OrderListL;
   delete OrderListS;
}

bool isOkBuy() {
   return true;
}

bool isOkSell() {
   return true;
}

void resetTicketId(CList *orderList) {
   int count = orderList.Total();
   OrderInfo *oi = NULL;
   int totalCnt = OrdersTotal();
   for (int i = 0; i < count; i++) {
      oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      for (int m =0; m < totalCnt; m++) {
         bool isSelected = OrderSelect(m, SELECT_BY_POS);
         if (isSelected && ("from #"+IntegerToString(ticketId)) == OrderComment()) {
            int newTicketId = OrderTicket();
            oi.setTicketId(newTicketId);
            break;
         }
      }
   }
}

void minusPositionL() {
   int count = OrderListL.Total();
   OrderInfo *order0 = NULL;
   OrderInfo *orderLast = NULL;
   double preOldOrderLot = 0.0;
   double curOrderLot = 0.0;
   OrderInfo *curOrder = NULL;
   for (int m = 0; m < count; m++) {
      curOrder = OrderListL.GetNodeAtIndex(m);
      if (0 == m) {
         order0 = curOrder;
         closeOrderLong(curOrder);
         preOldOrderLot = curOrder.getLotSize();
         
      } else if (count-1 == m) {
         orderLast = curOrder;
         closeOrderLong(curOrder);
      
      } else {
         closeOrderLong(curOrder, curOrder.getLotSize()-preOldOrderLot);
         OrderListL.MoveToIndex(m-1);
         curOrderLot = preOldOrderLot;
         preOldOrderLot = curOrder.getLotSize();
         curOrder.setLotSize(curOrderLot);
      }
      
   }
   
   
   OrderListL.Delete(count-1);
   OrderListL.Delete(count-2);
   delete order0;
   delete orderLast;
   
   resetTicketId(OrderListL);
   resetStateBuy();
}

void minusPositionS() {
   int count = OrderListS.Total();
   OrderInfo *order0 = NULL;
   OrderInfo *orderLast = NULL;
   double preOldOrderLot = 0.0;
   double curOrderLot = 0.0;
   OrderInfo *curOrder = NULL;
   for (int m = 0; m < count; m++) {
      curOrder = OrderListS.GetNodeAtIndex(m);
      if (0 == m) {
         order0 = curOrder;
         closeOrderShort(curOrder);
         preOldOrderLot = curOrder.getLotSize();
         
      } else if (count-1 == m) {
         orderLast = curOrder;
         closeOrderShort(curOrder);
      
      } else {
         closeOrderShort(curOrder, curOrder.getLotSize()-preOldOrderLot);
         OrderListS.MoveToIndex(m-1);
         curOrderLot = preOldOrderLot;
         preOldOrderLot = curOrder.getLotSize();
         curOrder.setLotSize(curOrderLot);
      }
      
   }
   
   
   OrderListS.Delete(count-1);
   OrderListS.Delete(count-2);
   delete order0;
   delete orderLast;
   
   resetTicketId(OrderListS);
   resetStateSell();
}

void closeAllBuy() {
   int apCount = OrderListL.Total();
   bool isClosed = false;
   for (int i = apCount-1; 0<=i; i--) {
      isClosed = closeOrderLong(OrderListL.GetNodeAtIndex(i));
      if (isClosed) {
         OrderListL.Delete(i);
      } else {
         Alert("OrderListL[" + IntegerToString(i) + "] Is Not Closed.");
      }
   }
   
   resetStateBuy();
   setCloseBuyButton(Create_Order_Mode);
}

bool hasTP_L() {
   int apCount = OrderListL.Total();
   OrderInfo *oi = OrderListL.GetNodeAtIndex(apCount-1);
   double tpPrice = oi.getTpPrice();
   if (tpPrice <= Bid) {
      //Alert("Long TP @" + vbid + " tpPrice=" + oi.getTpPrice());
      if (apCount<3 || isCloseAllMode(apCount)) {
         closeAllBuy();
         
      } else {
         minusPositionL();
      }
      
      return true;
   }
   
   return false;
}

void closeAllSell() {
   int apCount = OrderListS.Total();
   bool isClosed = false;
   for (int i = apCount-1; 0<=i; i--) {
      isClosed = closeOrderShort(OrderListS.GetNodeAtIndex(i));
      if (isClosed) {
         OrderListS.Delete(i);
      } else {
         Alert("OrderListS[" + IntegerToString(i) + "] Is Not Closed.");
      }
   }
   
   setCloseSellButton(Create_Order_Mode);
   resetStateSell();
}

bool hasTP_S() {
   int apCount = OrderListS.Total();
   OrderInfo *oi = OrderListS.GetNodeAtIndex(apCount-1);
   double tpPrice = oi.getTpPrice();
   if (Ask <= tpPrice) {
      if (apCount<3 || isCloseAllMode(apCount)) {
         closeAllSell();
         
      } else {
         minusPositionS();
      }
      
      return true;
   }
   
   return false;
}

double calculateAPLot(CList *orderList) {
   int apCount = orderList.Total();
   OrderInfo *oi = orderList.GetNodeAtIndex(0);
   double lot0 = oi.getLotSize();
   double lot = lot0 * MathPow(lotMultiple, apCount);
   lot = MathCeil(lot/LotStepServer)*LotStepServer;

   return lot;
}

bool doAP_L() {
   int apCount = OrderListL.Total();
   double lot = calculateAPLot(OrderListL);
   OrderInfo *oiNew = createOrderLong(lot, apCount);
   if (oiNew.isValid()) {
      OrderListL.Add(oiNew);
      resetStateBuy();
      return true;
   }
   return false;
}

bool hasAP_L() {
   int apCount = OrderListL.Total();
   if (apCount < maxTimes4AP) {
      OrderInfo *oi = OrderListL.GetNodeAtIndex(apCount-1);
      double apPrice = APRule_GridPrice[apCount];
      if (Ask <= oi.getOpenPrice()-apPrice) {
         if (doAP_L()) {
            return true;
         }
      }
      
   }
   return false;
}

bool doAP_S() {
   int apCount = OrderListS.Total();
   double lot = calculateAPLot(OrderListS);
   OrderInfo *oiNew = createOrderShort(lot, apCount);
   if (oiNew.isValid()) {
      OrderListS.Add(oiNew);
      resetStateSell();
      return true;
   }
   return false;
}

bool hasAP_S() {
   int apCount = OrderListS.Total();
   if (apCount < maxTimes4AP) {
      OrderInfo *oi = OrderListS.GetNodeAtIndex(apCount-1);
      double apPrice = APRule_GridPrice[apCount];
      if (oi.getOpenPrice()+apPrice <= Bid) {
         if (doAP_S()) {
            return true;
         }
      }
      
   }
   return false;
}

bool hasSL_L() {
   int apCount = OrderListL.Total();
   if (apCount == maxTimes4AP) {
      OrderInfo *oi = OrderListL.GetNodeAtIndex(apCount-1);
      double slPrice = SL_Price;
      if (Ask <= oi.getOpenPrice()-slPrice) {
         //Alert("Long SL @" + vask + " openPrice=" + oi.getOpenPrice() + " apPrice=" + apPrice + " oi.getOpenPrice()-apPrice=" + (oi.getOpenPrice()-apPrice));
         closeAllBuy();
         return true;
      
      }
   }
   return false;
}

bool hasSL_S() {
   int apCount = OrderListS.Total();
   if (apCount == maxTimes4AP) {
      OrderInfo *oi = OrderListS.GetNodeAtIndex(apCount-1);
      double slPrice = SL_Price;
      if (oi.getOpenPrice()+slPrice <= Bid) {
         closeAllSell();
         return true;
      
      }
   }
   return false;
}

void setCloseBuyButton(enButtonMode btnMode) {
   if (Close_Order_Mode == btnMode) {
      ObjectSetString(0, nmBtnCloseLong, OBJPROP_TEXT, txtBtnCloseLong);
   } else {
      ObjectSetString(0, nmBtnCloseLong, OBJPROP_TEXT, txtBtnCreateLong);
   }
   btnModeBuy = btnMode;
}

void setCloseSellButton(enButtonMode btnMode) {

   if (Close_Order_Mode == btnMode) {
      ObjectSetString(0, nmBtnCloseShort, OBJPROP_TEXT, txtBtnCloseShort);
   } else {
      ObjectSetString(0, nmBtnCloseShort, OBJPROP_TEXT, txtBtnCreateShort);
   }
               
   btnModeSell = btnMode;
}

void refreshProfit() {

   double profitLong = 0.0;
   double profitShort = 0.0;
   
   double profitDPLong = 0.0;
   double tmpOneProfit = 0.0;
   double preOrderLot = 0.0;
   int apTimesL = OrderListL.Total();
   OrderInfo *oi = NULL;
   for (int i = 0; i < apTimesL; i++) {
      oi = OrderListL.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         tmpOneProfit = OrderProfit();
         tmpOneProfit += OrderCommission();
         tmpOneProfit += OrderSwap();
         
         profitLong += tmpOneProfit;
         profitDPLong += tmpOneProfit;
         
         if (0 != i && (apTimesL-1) != i) {
            double minusProfit = OrderProfit()*(preOrderLot/oi.getLotSize());
            profitDPLong -= minusProfit;
         }
      } else {
         string msg = "OrderSelect failed in refreshProfit.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }
      
      preOrderLot = oi.getLotSize();

   }
   
   int apTimesS = OrderListS.Total();
   double profitDPShort = 0.0;
   for (int i = 0; i < apTimesS; i++) {
      oi = OrderListS.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         tmpOneProfit = OrderProfit();
         tmpOneProfit += OrderCommission();
         tmpOneProfit += OrderSwap();
         
         profitShort += tmpOneProfit;
         profitDPShort += tmpOneProfit;
         
         if (0 != i && (apTimesS-1) != i) {
            double minusProfit = OrderProfit()*(preOrderLot/oi.getLotSize());
            profitDPShort -= minusProfit;
         }
      } else {
         string msg = "OrderSelect failed in refreshProfit.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

      preOrderLot = oi.getLotSize();
   }
   
   ObjectSetString(0, nmLabelProfitLong, OBJPROP_TEXT, DoubleToStr(profitLong, 2));
   if (0 < profitLong) {
      ObjectSetInteger(0, nmLabelProfitLong, OBJPROP_COLOR, clrLime);
   } else if (profitLong < 0) {
      ObjectSetInteger(0, nmLabelProfitLong, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, nmLabelProfitLong, OBJPROP_COLOR, clrWhite);
   }
   
   ObjectSetString(0, nmLabelProfitShort, OBJPROP_TEXT, DoubleToStr(profitShort, 2));
   if (0 < profitShort) {
      ObjectSetInteger(0, nmLabelProfitShort, OBJPROP_COLOR, clrLime);
   } else if (profitShort < 0) {
      ObjectSetInteger(0, nmLabelProfitShort, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, nmLabelProfitShort, OBJPROP_COLOR, clrWhite);
   }
   
   double total = profitLong + profitShort;
   ObjectSetString(0, nmLabelTotalProfitValue, OBJPROP_TEXT, DoubleToStr(total, 2));
   if (0 < total) {
      ObjectSetInteger(0, nmLabelTotalProfitValue, OBJPROP_COLOR, clrLime);
   } else if (total < 0) {
      ObjectSetInteger(0, nmLabelTotalProfitValue, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, nmLabelTotalProfitValue, OBJPROP_COLOR, clrWhite);
   }
   
   
   ObjectSetString(0, nmLabelProfitDPLong, OBJPROP_TEXT, DoubleToStr(profitDPLong, 2));
   if (0 < profitDPLong) {
      ObjectSetInteger(0, nmLabelProfitDPLong, OBJPROP_COLOR, clrLime);
   } else if (profitDPLong < 0) {
      ObjectSetInteger(0, nmLabelProfitDPLong, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, nmLabelProfitDPLong, OBJPROP_COLOR, clrWhite);
   }
   
   ObjectSetString(0, nmLabelProfitDPShort, OBJPROP_TEXT, DoubleToStr(profitDPShort, 2));
   if (0 < profitDPShort) {
      ObjectSetInteger(0, nmLabelProfitDPShort, OBJPROP_COLOR, clrLime);
   } else if (profitDPShort < 0) {
      ObjectSetInteger(0, nmLabelProfitDPShort, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, nmLabelProfitDPShort, OBJPROP_COLOR, clrWhite);
   }
   
   
   double maxAPLongProfit = 0.0;
   if (0 < apTimesL) {
      OrderInfo *oi_ = OrderListL.GetNodeAtIndex(apTimesL-1);
      bool isSelected = OrderSelect(oi_.getTicketId(), SELECT_BY_TICKET);
      if (isSelected) {
         maxAPLongProfit = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   ObjectSetString(0, lblNmProfitMaxBuyOrder, OBJPROP_TEXT, DoubleToStr(maxAPLongProfit, 2));
   if (0 < maxAPLongProfit) {
      ObjectSetInteger(0, lblNmProfitMaxBuyOrder, OBJPROP_COLOR, clrLime);
   } else if (maxAPLongProfit < 0) {
      ObjectSetInteger(0, lblNmProfitMaxBuyOrder, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, lblNmProfitMaxBuyOrder, OBJPROP_COLOR, clrWhite);
   }
   
   double maxAPShortProfit = 0.0;
   if (0 < apTimesS) {
      OrderInfo *oi_ = OrderListS.GetNodeAtIndex(apTimesS-1);
      bool isSelected = OrderSelect(oi_.getTicketId(), SELECT_BY_TICKET);
      if (isSelected) {
         maxAPShortProfit = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   ObjectSetString(0, lblNmProfitMaxSellOrder, OBJPROP_TEXT, DoubleToStr(maxAPShortProfit, 2));
   if (0 < maxAPShortProfit) {
      ObjectSetInteger(0, lblNmProfitMaxSellOrder, OBJPROP_COLOR, clrLime);
   } else if (maxAPShortProfit < 0) {
      ObjectSetInteger(0, lblNmProfitMaxSellOrder, OBJPROP_COLOR, clrRed);
   } else {
      ObjectSetInteger(0, lblNmProfitMaxSellOrder, OBJPROP_COLOR, clrWhite);
   }
   
}

void OnTick() {
   
   refreshProfit();
   
   if (!isActive) {
   
      if (!isStopedByNews) {
         return;
      }

      datetime nowTime = TimeLocal();
      int diffTime = (int) (nowTime - stopedTimeByNews);
      if (minutesAfterNewsResume*60 < diffTime) {
         resumeEA();
      } else {
         return;
      }
   }
   
   updateNewsStatus();
   
   if (mustStopEAByNews) {
      
      closeAll();
      resetStateBuy();
      resetStateSell();

      stopEA();
      
      isStopedByNews = true;
      stopedTimeByNews = TimeLocal();
      
      return;
   }
   
   int listSize = OrderListL.Total();
   if (0 == listSize) {
      if (!forbidCreateOrder && !isForbidCreateOrderManual) {
         if (isOkBuy()) {
            double lotSize = calculateInitLot(OrderListS);
            OrderInfo *oi = createOrderLong(lotSize, 0);
            if (oi.isValid()) {
               OrderListL.Add(oi);
               setCloseBuyButton(Close_Order_Mode);
            }
         }
      }
      
   } else {
      bool hasChange = hasTP_L();
         
      if (!hasChange) {
         hasChange = hasAP_L();
      }
      
      if (!hasChange) {
         hasChange = hasSL_L();
      }
   
   }
   
   
   listSize = OrderListS.Total();
   if (0 == listSize) {
      if (!forbidCreateOrder && !isForbidCreateOrderManual) {
         if (isOkSell()) {
            double lotSize = calculateInitLot(OrderListL);
            OrderInfo *oi = createOrderShort(lotSize, 0);
            if (oi.isValid()) {
               OrderListS.Add(oi);
               setCloseSellButton(Close_Order_Mode);
            }
         }
      }
      
   } else {
      bool hasChange = hasTP_S();
         
      if (!hasChange) {
         hasChange = hasAP_S();
      }
      
      if (!hasChange) {
         hasChange = hasSL_S();
      }
   
   }


   resetStateBuy();
   resetStateSell();
}

void resetTpPrice() {
   int count = OrderListL.Total();
   OrderInfo *oi = NULL;
   for (int i = 0; i < count; i++) {
      oi = OrderListL.GetNodeAtIndex(i);
      oi.setTpPrice(oi.getOpenPrice()+APRule_RetracePrice[i]);
   }
   
   count = OrderListS.Total();
   for (int i = 0; i < count; i++) {
      oi = OrderListS.GetNodeAtIndex(i);
      oi.setTpPrice(oi.getOpenPrice()-APRule_RetracePrice[i]);
   }
   
   resetStateBuy();
   resetStateSell();
}


void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (id == CHARTEVENT_OBJECT_CLICK) {
      if (nmBtnStopResume == sparam) {
         if (isActive) {
            stopEA();
         } else {
            resumeEA();
         }
         PressButton(nmBtnStopResume);
      }
      
      else 
      if (nmBtnDecreasePositionLong == sparam) {
         int apTimes = OrderListL.Total();
         if (2 < apTimes) {
            minusPositionL();
            //resetStateBuy();
         }
         PressButton(nmBtnDecreasePositionLong);
      }
      
      else 
      if (nmBtnDecreasePositionShort == sparam) {
         int apTimes = OrderListS.Total();
         if (2 < apTimes) {
            minusPositionS();
            //resetStateSell();
         }
         PressButton(nmBtnDecreasePositionShort);
      }
      
      else 
      if (nmBtnCloseLong == sparam) {
      
         if (Close_Order_Mode == btnModeBuy) {
            closeAllBuy();
         } else {
            OrderInfo *oi = createOrderLong(initLots, 0);
            OrderListL.Add(oi);
            setCloseBuyButton(Close_Order_Mode);
            resetStateBuy();
         }

         PressButton(nmBtnCloseLong);
      }
      
      else 
      if (nmBtnCloseShort == sparam) {
         if (Close_Order_Mode == btnModeSell) {
            closeAllSell();
         } else {
            OrderInfo *oi = createOrderShort(initLots, 0);
            OrderListS.Add(oi);
            setCloseSellButton(Close_Order_Mode);
            resetStateSell();
         }
         PressButton(nmBtnCloseShort);
      }
      
      else if (nmBtnForbidCreateOrderManual == sparam) {
         if (isForbidCreateOrderManual) {
            isForbidCreateOrderManual = false;
            ObjectSetString(0, nmBtnForbidCreateOrderManual, OBJPROP_TEXT, txtBtnForbidCreateOrderManual);
            ObjectSetInteger(0,nmBtnForbidCreateOrderManual, OBJPROP_BGCOLOR, color4BtnForbidCreateOrderManual);
         } else {
            isForbidCreateOrderManual = true;
            ObjectSetString(0, nmBtnForbidCreateOrderManual, OBJPROP_TEXT, txtBtnAllowCreateOrderManual);
            ObjectSetInteger(0,nmBtnForbidCreateOrderManual, OBJPROP_BGCOLOR, color4BtnAllowCreateOrderManual);
         }
         PressButton(nmBtnForbidCreateOrderManual);
      }
      
      else 
      if (btnNmInitLotUp == sparam) {
         initLots += 0.01;
         ObjectSetString(0, lblNmInitLotValue, OBJPROP_TEXT, DoubleToStr(initLots, 2));
         //PressButton(btnNmInitLotUp);
      }
      else 
      if (btnNmInitLotDn == sparam) {
         initLots -= 0.01;
         ObjectSetString(0, lblNmInitLotValue, OBJPROP_TEXT, DoubleToStr(initLots, 2));
         //PressButton(btnNmInitLotDn);
      }
      
      else 
      if (btnNmGridPointsUp == sparam) {
         if (0 == countOrders(MagicNumber, _Symbol)) {
            grid += 1;
            gridPrice = NormalizeDouble(Point * grid, Digits);
            ObjectSetString(0, lblNmGridPointsValue, OBJPROP_TEXT, IntegerToString(grid));
            initGridRule();
            initRetraceRule();
            resetTpPrice();
         } else {
            Alert("Orders > 0, you can't change it.");
         }
         //PressButton(btnNmGridPointsUp);
      }
      else 
      if (btnNmGridPointsDn == sparam) {
         if (0 == countOrders(MagicNumber, _Symbol)) {
            grid -= 1;
            gridPrice = NormalizeDouble(Point * grid, Digits);
            ObjectSetString(0, lblNmGridPointsValue, OBJPROP_TEXT, IntegerToString(grid));
            initGridRule();
            initRetraceRule();
            resetTpPrice();
         } else {
            Alert("Orders > 0, you can't change it.");
         }
         //PressButton(btnNmGridPointsDn);
      }
      
      else 
      if (btnNmTakeProfitPointsUp == sparam) {
         tpPoints += 1;
         tp = NormalizeDouble(Point * tpPoints, Digits);
         ObjectSetString(0, lblNmTakeProfitPointsValue, OBJPROP_TEXT, IntegerToString(tpPoints));
         initGridRule();
         initRetraceRule();
         resetTpPrice();
         //PressButton(btnNmTakeProfitPointsUp);
      }
      else 
      if (btnNmTakeProfitPointsDn == sparam) {
         tpPoints -= 1;
         tp = NormalizeDouble(Point * tpPoints, Digits);
         ObjectSetString(0, lblNmTakeProfitPointsValue, OBJPROP_TEXT, IntegerToString(tpPoints));
         initGridRule();
         initRetraceRule();
         resetTpPrice();
         //PressButton(btnNmTakeProfitPointsDn);
      }
      
      else 
      if (btnNmRetraceProfitCoefficientUp == sparam) {
         retraceProfitRatio += 0.01;
         ObjectSetString(0, lblNmRetraceProfitCoefficientValue, OBJPROP_TEXT, DoubleToStr(retraceProfitRatio, 2));
         initRetraceRule();
         resetTpPrice();
         //resetStateBuy();
         //resetStateSell();
         //PressButton(btnNmRetraceProfitCoefficientUp);
      }
      else 
      if (btnNmRetraceProfitCoefficientDn == sparam) {
         retraceProfitRatio -= 0.01;
         ObjectSetString(0, lblNmRetraceProfitCoefficientValue, OBJPROP_TEXT, DoubleToStr(retraceProfitRatio, 2));
         initRetraceRule();
         resetTpPrice();
         //resetStateBuy();
         //resetStateSell();
         //PressButton(btnNmRetraceProfitCoefficientDn);
      }
      
      else 
      if (btnNmMaxTimesAddPositionUp == sparam) {
         maxTimes4AP += 1;
         times_Part2All = maxTimes4AP - 3;
         ObjectSetString(0, lblNmMaxTimesAddPositionValue, OBJPROP_TEXT, IntegerToString(maxTimes4AP));
         //PressButton(btnNmMaxTimesAddPositionUp);
      }
      else 
      if (btnNmMaxTimesAddPositionDn == sparam) {
         maxTimes4AP -= 1;
         times_Part2All = maxTimes4AP - 3;
         ObjectSetString(0, lblNmMaxTimesAddPositionValue, OBJPROP_TEXT, IntegerToString(maxTimes4AP));
         //PressButton(btnNmMaxTimesAddPositionDn);
      }
      
      else 
      if (btnNmAddOrderByTrend == sparam) {
         if (addPosition2Trend) {
            addPosition2Trend = false;
            ObjectSetString(0, btnNmAddOrderByTrend, OBJPROP_TEXT, btnTxtNotAddOrderByTrend);
            ObjectSetInteger(0,btnNmAddOrderByTrend, OBJPROP_BGCOLOR, btnColorDisable);
         } else {
            addPosition2Trend = true;
            ObjectSetString(0, btnNmAddOrderByTrend, OBJPROP_TEXT, btnTxtAddOrderByTrend);
            ObjectSetInteger(0,btnNmAddOrderByTrend, OBJPROP_BGCOLOR, btnColorEnable);
         }
         //PressButton(btnNmAddOrderByTrend);
      }
      
      else 
      if (btnNmCMCloseAll == sparam) {
         if (Close_All == closePositionMode) {
            
         } else {
            closePositionMode = Close_All;
            ObjectSetInteger(0,btnNmCMCloseAll, OBJPROP_BGCOLOR, btnColorEnable);
            ObjectSetInteger(0,btnNmCMClosePart, OBJPROP_BGCOLOR, btnColorDisable);
            ObjectSetInteger(0,btnNmCMClosePartAll, OBJPROP_BGCOLOR, btnColorDisable);
            initRetraceRule();
            resetTpPrice();
            //resetStateBuy();
            //resetStateSell();
         }
         //PressButton(btnNmCMCloseAll);
      }
      else 
      if (btnNmCMClosePart == sparam) {
         if (Close_Part == closePositionMode) {
            
         } else {
            closePositionMode = Close_Part;
            ObjectSetInteger(0,btnNmCMCloseAll, OBJPROP_BGCOLOR, btnColorDisable);
            ObjectSetInteger(0,btnNmCMClosePart, OBJPROP_BGCOLOR, btnColorEnable);
            ObjectSetInteger(0,btnNmCMClosePartAll, OBJPROP_BGCOLOR, btnColorDisable);
            initRetraceRule();
            resetTpPrice();
            //resetRetrace4Buy();
            //resetRetrace4Sell();
         }
         //PressButton(btnNmCMClosePart);
      }
      else 
      if (btnNmCMClosePartAll == sparam) {
         if (Close_Part_All == closePositionMode) {
            
         } else {
            closePositionMode = Close_Part_All;
            ObjectSetInteger(0,btnNmCMCloseAll, OBJPROP_BGCOLOR, btnColorDisable);
            ObjectSetInteger(0,btnNmCMClosePart, OBJPROP_BGCOLOR, btnColorDisable);
            ObjectSetInteger(0,btnNmCMClosePartAll, OBJPROP_BGCOLOR, btnColorEnable);
            initRetraceRule();
            resetTpPrice();
            //resetRetrace4Buy();
            //resetRetrace4Sell();
         }
         //PressButton(btnNmCMClosePartAll);
      }
      
      else 
      if (btnNmAPMFixed == sparam) {
         if (Fixed == addPositionMode) {
            
         } else {
            if (0 == countOrders(MagicNumber, _Symbol)) {
               addPositionMode = Fixed;
               ObjectSetInteger(0,btnNmAPMFixed, OBJPROP_BGCOLOR, btnColorEnable);
               ObjectSetInteger(0,btnNmAPMMultiplied, OBJPROP_BGCOLOR, btnColorDisable);
               
               ObjectSetString(0, lblNmLotAddPositionLabel, OBJPROP_TEXT, lblTxtLotAddPositionStep);
               ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotStep, 2));
               // TBD TODO
               /*
               initGridRule();
               initLotRule();
               initRetraceRule();
               resetTpPrice();
               */
               //resetRetrace4Buy();
               //resetRetrace4Sell();
            } else {
               Alert("Orders > 0, you can't change it.");
            }
         }
         //PressButton(btnNmAPMFixed);
      }
      else 
      if (btnNmAPMMultiplied == sparam) {
         if (Multiplied == addPositionMode) {
            
         } else {
            if (0 == countOrders(MagicNumber, _Symbol)) {
               addPositionMode = Multiplied;
               ObjectSetInteger(0,btnNmAPMFixed, OBJPROP_BGCOLOR, btnColorDisable);
               ObjectSetInteger(0,btnNmAPMMultiplied, OBJPROP_BGCOLOR, btnColorEnable);
               
               ObjectSetString(0, lblNmLotAddPositionLabel, OBJPROP_TEXT, lblTxtLotAddPositionMultiple);
               ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotMultiple, 2));
               // TBD TODO
               initGridRule();
               //initLotRule();
               initRetraceRule();
               resetTpPrice();
               
            } else {
               Alert("Orders > 0, you can't change it.");
            }
         }
         //PressButton(btnNmAPMMultiplied);
      }
      
      else 
      if (btnNmLotAddPositionUp == sparam) {
         if (0 == countOrders(MagicNumber, _Symbol)) {
            if (Multiplied == addPositionMode) {
               lotMultiple += 0.01;
               // TODO reset ?
               ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotMultiple, 2));
            } else {
               lotStep += 0.01;
               // TODO reset ?
               ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotStep, 2));
            }
            initRetraceRule();
            resetTpPrice();
            //resetRetrace4Buy();
            //resetRetrace4Sell();
         } else {
            Alert("Orders > 0, you can't change it.");
         }
         
         //PressButton(btnNmLotAddPositionUp);
      }
      else 
      if (btnNmLotAddPositionDn == sparam) {
         if (0 == countOrders(MagicNumber, _Symbol)) {
            if (Multiplied == addPositionMode) {
               lotMultiple -= 0.01;
               // TODO reset ?
               ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotMultiple, 2));
            } else {
               lotStep -= 0.01;
               // TODO reset ?
               ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotStep, 2));
            }
            initRetraceRule();
            resetTpPrice();
         //resetRetrace4Buy();
         //resetRetrace4Sell();
         } else {
            Alert("Orders > 0, you can't change it.");
         }
         //PressButton(btnNmLotAddPositionDn);
      }
      
      else 
      if (btnNmMaxLots4AddPositionLimitUp == sparam) {
         Max_Lot_AP += 0.01;
         ObjectSetString(0, lblNmMaxLots4AddPositionLimitValue, OBJPROP_TEXT, DoubleToStr(Max_Lot_AP, 2));
         //PressButton(btnNmMaxLots4AddPositionLimitUp);
      }
      else 
      if (btnNmMaxLots4AddPositionLimitDn == sparam) {
         Max_Lot_AP -= 0.01;
         ObjectSetString(0, lblNmMaxLots4AddPositionLimitValue, OBJPROP_TEXT, DoubleToStr(Max_Lot_AP, 2));
         //PressButton(btnNmMaxLots4AddPositionLimitDn);
      }
      
      
      else 
      if (btnNmCloseMaxBuyOrder == sparam) {
         int count = OrderListL.Total();
         if (1 < count) {
            string msg = "Are you sure to close the maximum long position?";
            if (IDOK == MessageBox(msg, "Close Maximum Long Position", MB_OKCANCEL)) {
               OrderInfo *oi = OrderListL.GetNodeAtIndex(count-1);
               bool isClosed = closeOrderLong(oi);
               if (isClosed) {
                  OrderListL.Delete(count-1);
                  resetStateBuy();
               }
            }
         }
         //PressButton(btnNmCloseMaxBuyOrder);
      }
      
      else 
      if (btnNmCloseMaxSellOrder == sparam) {
         int count = OrderListS.Total();
         if (1 < count) {
            string msg = "Are you sure to close the maximum short position?";
            if (IDOK == MessageBox(msg, "Close Maximum Short Position", MB_OKCANCEL)) {
               OrderInfo *oi = OrderListS.GetNodeAtIndex(count-1);
               bool isClosed = closeOrderShort(oi);
               if (isClosed) {
                  OrderListS.Delete(count-1);
                  resetStateSell();
               }
            }
         }
         //PressButton(btnNmCloseMaxSellOrder);
      }
      
      else 
      if (btnNmAdd1BuyOrder == sparam) {
         int apCount = OrderListL.Total();
         if (0 < apCount && apCount < maxTimes4AP) {
            string msg = "Are you sure to add 1 buy position?";
            if (IDOK == MessageBox(msg, "Add One Long Position", MB_OKCANCEL)) {
               doAP_L();
               //resetStateBuy();
            }
         }
         //PressButton(btnNmAdd1BuyOrder);
      }
      
      else 
      if (btnNmAdd1SellOrder == sparam) {
         int apCount = OrderListS.Total();
         if (0 < apCount && apCount < maxTimes4AP) {
            string msg = "Are you sure to add 1 sell position?";
            if (IDOK == MessageBox(msg, "Add One Short Position", MB_OKCANCEL)) {
               doAP_S();
               //resetStateSell();
            }
         }
         //PressButton(btnNmAdd1SellOrder);
      }
   }  
   
   else if (id == CHARTEVENT_OBJECT_DRAG) {
      string objectName = sparam;
      if (nmLineClosePositionBuy == objectName) {
         double retracePriceBuy = ObjectGet(nmLineClosePositionBuy, OBJPROP_PRICE1);
         int listSize = OrderListL.Total();
         OrderInfo *oi = OrderListL.GetNodeAtIndex(listSize-1);
         oi.setTpPrice(retracePriceBuy);
         resetStateBuy();

      } else if (nmLineClosePositionSell == objectName) {
         double retracePriceSell = ObjectGet(nmLineClosePositionSell, OBJPROP_PRICE1);
         int listSize = OrderListS.Total();
         OrderInfo *oi = OrderListS.GetNodeAtIndex(listSize-1);
         oi.setTpPrice(retracePriceSell);
         resetStateSell();
      }
   }
   
}

double calculateTargetCloseProfit(CList *orderList) {
   
   double closeProfit = 0.0;

   int listSize = orderList.Total();
   
   if (0 == listSize) {
      return closeProfit;
   }
   
   OrderInfo *oi = orderList.GetNodeAtIndex(listSize-1);
   if (1 == listSize) {
      closeProfit = oi.getLotSize() * 30;
      return closeProfit;
   }
   
   double retracePrice = oi.getTpPrice();
   
   for (int i = 0; i < listSize; i++) {
      oi = orderList.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      if ( OrderSelect(ticketId, SELECT_BY_TICKET) ) {

         double diffPrice = MathAbs(retracePrice - OrderOpenPrice());
         double profiti = OrderLots()*diffPrice/Point;
         closeProfit += profiti;
         
         if ( isClosePartMode(i) ) {
            if (listSize-1 != i && 0 != i) {
               closeProfit -= profiti/lotMultiple;
            }
         }
         
         closeProfit += OrderCommission();
         closeProfit += OrderSwap(); 

      }
   }
   
   return closeProfit;
}

double calculateLot(double lotSize, double coefficient) {

   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double lotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   double lot = MathCeil(lotSize*coefficient/lotStepServer)*lotStepServer;
   
   if (lot < minLot) {
      lot = minLot;
   }
   
   return lot;
}

double calculateInitLot(CList *orderList) {
   double lots = initLots;
   if (addPosition2Trend) {
      int count = orderList.Total() - 1;
      if (Fixed == addPositionMode) {
         lots = (initLots + lotStep*count);
      } else {
         lots = calculateLot(initLots, MathPow(lotMultiple, count));
      }
   }
   if (enableMaxLotControl) {
      if (Max_Lot_AP < lots) {
         lots = Max_Lot_AP;
      }
   }
   return lots;
}


void resetStateBuy() {

   double closeProfitBuy = calculateTargetCloseProfit(OrderListL);
   ObjectSetString(0, lblnmCloseBuyProfit, OBJPROP_TEXT, DoubleToStr(closeProfitBuy, 2));
   int listSize = OrderListL.Total();
   OrderInfo *oi = OrderListL.GetNodeAtIndex(listSize-1);
   double retraceRatioBuy = 0.0;
   double targetTpPrice = 0.0;
   if (1 < listSize) {
      targetTpPrice = oi.getTpPrice();
      retraceRatioBuy = NormalizeDouble((targetTpPrice-oi.getOpenPrice())/Point/APRule_Grid[listSize-1]*100, 3);
   }
   ObjectSetString(0, lblnmRetraceRatioBuy, OBJPROP_TEXT, DoubleToStr(retraceRatioBuy, Digits));
   ObjectSetString(0, lblnmCountAPBuy, OBJPROP_TEXT, IntegerToString(listSize));
   ObjectMove(nmLineClosePositionBuy, 0, 0, targetTpPrice);
}

void resetStateSell() {

   double closeProfitSell = calculateTargetCloseProfit(OrderListS);
   ObjectSetString(0, lblnmCloseSellProfit, OBJPROP_TEXT, DoubleToStr(closeProfitSell, 2));
   int listSize = OrderListS.Total();
   OrderInfo *oi = OrderListS.GetNodeAtIndex(listSize-1);
   double retraceRatioSell = 0.0;
   double targetTpPrice = 0.0;
   if (1 < listSize) {
      targetTpPrice = oi.getTpPrice();
      retraceRatioSell = NormalizeDouble((oi.getOpenPrice()-targetTpPrice)/Point/APRule_Grid[listSize-1]*100, 3);
   }
   ObjectSetString(0, lblnmRetraceRatioSell, OBJPROP_TEXT, DoubleToStr(retraceRatioSell, Digits));
   ObjectSetString(0, lblnmCountAPSell, OBJPROP_TEXT, IntegerToString(listSize));
   ObjectMove(nmLineClosePositionSell, 0, 0, targetTpPrice);
}


void stopEA() {
   isActive = false;
   resetStateBuy();
   resetStateSell();
   ObjectSetString(0, nmBtnStopResume, OBJPROP_TEXT, txtBtnResume);
   ObjectSetInteger(0,nmBtnStopResume, OBJPROP_BGCOLOR, color4BtnResume);
}

void resumeEA() {
   isActive = true;
   ObjectSetString(0, nmBtnStopResume, OBJPROP_TEXT, txtBtnStop);
   ObjectSetInteger(0,nmBtnStopResume, OBJPROP_BGCOLOR, color4BtnStop);
}

/*
       3M+NS-S
  X = ---------N
       3NS+6M
       
  M:初始手数
  S:加仓手数
  N:第几次加仓
*/

double calculateRetrace4Fixed(int N, double lotInit) {
   
   double M = lotInit/initLots;
   double S = lotStep/initLots;
   double ret = (M*3+S*N-S)*N/(S*N*3+M*6);
   return ret;
}

/*** 以(a-1)/a 倍系数减仓****/
double calculateRetracePart(int n, double a) {
   
   // 分子
   double numerator = 0;
   
   // 分母
   double denominator = 0;
   
   // a的i次幂
   double aMi = 1;
   
   // [0～n] n+1次
   for (int i = 1; i < n; i++) {
      aMi = a*aMi;
   }
   
   numerator = a*aMi - 1;
   denominator = (a*a-1)*aMi;
   
   return (numerator/denominator);
}

double calculateRetraceAll(int n, double a) {
   
   // 分子
   double numerator = 0;
   
   // 分母
   double denominator = 0;
   
   // a的i次幂
   double aMi = 1;
   
   // [0～n] n+1次
   for (int i = 0; i <= n; i++) {
      aMi = a*aMi;
   }
   
   numerator = aMi + n - a*(n+1);
   denominator = (a-1)*(aMi -1);
   
   return (numerator/denominator);
}

void drawTotal() {
   DrawLine(nmLineClosePositionBuy, 0, clrGold, STYLE_DOT);
   DrawLine(nmLineClosePositionSell, 0, clrGold, STYLE_DOT);
   string fontName = "Lucida Bright";
   RectLabelCreate("rl_bg_tf", 75, 0, 266, 20);
   SetText("TotalProfitLabel", "Total Profit :", 98, 1);
   SetText(nmLabelTotalProfitValue, "0.0", 200, 1, TxtFontSize);

   ButtonCreate(nmBtnStopResume, txtBtnResume, 342, 0, 88, 28, color4BtnResume, BtnFontSize+2, clrBlack, fontName, clrGold);

   ButtonCreate(nmBtnForbidCreateOrderManual, txtBtnForbidCreateOrderManual, 523, 1, 88, 28, color4BtnForbidCreateOrderManual, BtnFontSize+2, clrBlack, fontName, clrGold);
}

void drawLongShort() {
   int X_START = 1;
   int Y_START = 20;
   string fontName = "Lucida Bright";
   int X = X_START;
   int Y = Y_START;
   int Width = 170;
   int Height = 209;
   int interval = 94;
   RectLabelCreate("rl_bg_Long", X, Y, Width, Height);
   SetText("LongWords", "Long", X+60, Y+1, TxtFontSize+2);
   Y += 24;
   ButtonCreate(nmBtnCloseLong, txtBtnCreateLong, X, Y, 80, 28, clrDarkGreen, BtnFontSize, clrWhite, fontName, clrWhite);
   SetText(nmLabelProfitLong, "0.0", X+interval, Y+4, TxtFontSize);
   Y += 30;
   SetText("CloseProfitWordsLong", "Close Profit :", X+2, Y, TxtFontSize);
   SetText(lblnmCloseBuyProfit, "0.0", X+interval, Y, TxtFontSize);
   Y += 22;
   ButtonCreate(nmBtnDecreasePositionLong, txtBtnDecreasePositionLong, X, Y, 80, 28, clrDarkGreen, BtnFontSize, clrWhite, fontName, clrWhite);
   SetText(nmLabelProfitDPLong, "0.0", X+interval, Y+4, TxtFontSize);
   Y += 30;
   SetText("RetraceRatioWordsLong", "Retrace :", X+2, Y, TxtFontSize);
   SetText(lblnmRetraceRatioBuy, "0.0", X+interval, Y, TxtFontSize);
   Y += 22;
   ButtonCreate(btnNmCloseMaxBuyOrder, "CloseMaxL", X, Y, 85, 28, clrDarkGreen, BtnFontSize, clrWhite);
   SetText(lblNmProfitMaxBuyOrder, "0.0", X+interval, Y+4, TxtFontSize);
   Y += 30;
   SetText("CountAPWordsLong", "Add Order Times :", X+2, Y, TxtFontSize);
   SetText(lblnmCountAPBuy, "0", X+134, Y, TxtFontSize);
   Y += 22;
   ButtonCreate(btnNmAdd1BuyOrder, "+Long", X, Y, 58, 28, clrDarkGreen, BtnFontSize, clrWhite);

   
   X = X_START+Width;
   Y = Y_START;
   RectLabelCreate("rl_bg_Short", X, Y, Width, Height);
   SetText("ShortWords", "Short", X+60, Y+1, TxtFontSize+2);
   Y += 24;
   ButtonCreate(nmBtnCloseShort, txtBtnCreateShort, X, Y, 80, 28, clrMaroon, BtnFontSize, clrWhite, fontName, clrWhite);
   SetText(nmLabelProfitShort, "0.0", X+interval, Y+4, TxtFontSize);
   Y += 30;
   SetText("CloseProfitWordsShort", "Close Profit :", X+2, Y, TxtFontSize);
   SetText(lblnmCloseSellProfit, "0.0", X+interval, Y, TxtFontSize);
   Y += 22;
   ButtonCreate(nmBtnDecreasePositionShort, txtBtnDecreasePositionShort, X, Y, 80, 28, clrMaroon, BtnFontSize, clrWhite, fontName, clrWhite);
   SetText(nmLabelProfitDPShort, "0.0", X+interval, Y+4, TxtFontSize);
   Y += 30;
   SetText("RetraceRatioWordsShort", "Retrace :", X, Y, TxtFontSize);
   SetText(lblnmRetraceRatioSell, "0.0", X+interval, Y+4, TxtFontSize);
   Y += 22;
   ButtonCreate(btnNmCloseMaxSellOrder, "CloseMaxS", X, Y, 87, 28, clrMaroon, BtnFontSize, clrWhite);
   SetText(lblNmProfitMaxSellOrder, "0.0", X+interval, Y+4, TxtFontSize);
   Y += 30;
   SetText("CountAPWordsShort", "Add Order Times :", X+2, Y, TxtFontSize);
   SetText(lblnmCountAPSell, "0", X+134, Y, TxtFontSize);
   Y += 22;
   ButtonCreate(btnNmAdd1SellOrder, "+Short", X, Y, 60, 28, clrMaroon, BtnFontSize, clrWhite);
}

void drawInputParameters() {
   color       colorBtnUp=clrGreen;
   //string      btnTxtUp=CharToStr(225);
   string      btnTxtUp=CharToStr('p');
   color       colorBtnDn=clrRed;
   //string      btnTxtDn=CharToStr(226);
   string      btnTxtDn=CharToStr('q');

   int x_start = 170*2+1;
   int y_start = 30;
   int x = x_start;
   int y = y_start;
   RectLabelCreate("InputParametersRectLabel", x, y, 342, 244);
   
   color backgroundColor = C'35,35,35';
   string fontName = "Wingdings 3";
   //string fontName = "Webdings";
   int fontSize = 7;
   int btnWidth = 19;
   int btnHeight = 20;
   
   int interval = 200;
   int widthValue = 100;
   int rowInterval = 2;
   
   SetText("InitLotLabel", "Init Lot :", x+4, y+2, fontSize+1);
   ButtonCreate(btnNmInitLotDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("InitLotValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmInitLotValue, DoubleToStr(initLots, 2), x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmInitLotUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);
   
   y += btnHeight+rowInterval;
   SetText("GridPointsLabel", "Grid Points :", x+4, y+2, fontSize+1);
   ButtonCreate(btnNmGridPointsDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("GridPointsValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmGridPointsValue, IntegerToString(grid), x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmGridPointsUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);

   y += btnHeight+rowInterval;
   SetText("TakeProfitPointsLabel", "Take Profit Points :", x+4, y+2, fontSize+1);
   ButtonCreate(btnNmTakeProfitPointsDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("TakeProfitPointsValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmTakeProfitPointsValue, IntegerToString(tpPoints), x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmTakeProfitPointsUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);

   y += btnHeight+rowInterval;
   SetText("RetraceProfitCoefficientLabel", "Retrace Profit Coefficient :", x+4, y+2, fontSize+1);
   ButtonCreate(btnNmRetraceProfitCoefficientDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("RetraceProfitCoefficientValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmRetraceProfitCoefficientValue, DoubleToStr(retraceProfitRatio, 2), x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmRetraceProfitCoefficientUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);

   y += btnHeight+rowInterval;
   SetText("MaxTimesAddOrderLabel", "Max Add Order Times :", x+4, y+2, fontSize+1);
   ButtonCreate(btnNmMaxTimesAddPositionDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("MaxTimesAddOrderValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmMaxTimesAddPositionValue, IntegerToString(maxTimes4AP), x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmMaxTimesAddPositionUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);

   y += btnHeight+rowInterval;
   string btnText = btnTxtNotAddOrderByTrend;
   color btnColor = btnColorDisable;
   if (addPosition2Trend) {
      btnText = btnTxtAddOrderByTrend;
      btnColor = btnColorEnable;
   }
   ButtonCreate(btnNmAddOrderByTrend, btnText, x+interval-40, y+2, 180, btnHeight, btnColor, fontSize, clrWhite);
   
   y += btnHeight+rowInterval;
   SetText("CloseModeLabel", "Close Mode :", x+4, y+2, fontSize+1);
   btnColor = btnColorDisable;
   if (Close_All == closePositionMode) {
      btnColor = btnColorEnable;
   }
   ButtonCreate(btnNmCMCloseAll, "CloseAll", x+interval-100, y+2, 60, btnHeight, btnColor, fontSize, clrWhite);
   btnColor = btnColorDisable;
   if (Close_Part == closePositionMode) {
      btnColor = btnColorEnable;
   }
   ButtonCreate(btnNmCMClosePart, "ClosePart", x+interval-30, y+2, 70, btnHeight, btnColor, fontSize, clrWhite);
   btnColor = btnColorDisable;
   if (Close_Part_All == closePositionMode) {
      btnColor = btnColorEnable;
   }
   ButtonCreate(btnNmCMClosePartAll, "ClosePartAll", x+interval+50, y+2, 90, btnHeight, btnColor, fontSize, clrWhite);
   
   
   y += btnHeight+rowInterval;
   SetText("AddOrderModeLabel", "Add Order Mode :", x+4, y+2, fontSize+1);
   btnColor = btnColorDisable;
   if (Fixed == addPositionMode) {
      btnColor = btnColorEnable;
   }
   ButtonCreate(btnNmAPMFixed, "Fixed", x+interval-30, y+2, 60, btnHeight, btnColor, fontSize, clrWhite);
   btnColor = btnColorDisable;
   if (Multiplied == addPositionMode) {
      btnColor = btnColorEnable;
   }
   ButtonCreate(btnNmAPMMultiplied, "Multiplied", x+interval+50, y+2, 70, btnHeight, btnColor, fontSize, clrWhite);
   
   y += btnHeight+rowInterval;
   string lblText = "Add Order Lot Multiple :";
   string lblValue = DoubleToStr(lotMultiple, 2);
   if (Fixed == addPositionMode) {
      lblText = "Add Order Lot Step :";
      lblValue = DoubleToStr(lotStep, 2);
   }
   SetText(lblNmLotAddPositionLabel, lblText, x+4, y+2, fontSize+1);
   ButtonCreate(btnNmLotAddPositionDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("LotAddPositionValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmLotAddPositionValue, lblValue, x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmLotAddPositionUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);

   y += btnHeight+rowInterval;
   SetText("MagicNumberLabel", "Magic Number :", x+4, y+2, fontSize+1);
   RectLabelCreate("MagicNumberValueRectLabel", x+interval, y+2, 140, btnHeight);
   SetText("MagicNumberValue", IntegerToString(MagicNumber), x+interval+4, y+3, fontSize);

   y += btnHeight+rowInterval;
   SetText("MaxLots4AddPositionLimitLabel", "Max Add Order Lots Limit :", x+4, y+2, fontSize+1);
   ButtonCreate(btnNmMaxLots4AddPositionLimitDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("MaxLots4AddPositionLimitValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmMaxLots4AddPositionLimitValue, DoubleToStr(Max_Lot_AP, 2), x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmMaxLots4AddPositionLimitUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);
}

OrderInfo *createOrderLong(double lotSize, int index) {
   OrderInfo *oi = new OrderInfo;
   double slPrice = 0.0;
   double tpPrice = 0.0;
   
   RefreshRates();
   int ticketId  = OrderSend(_Symbol, OP_BUY , lotSize, Ask, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (-1 == ticketId) {
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
      //oi.setTpPrice(OrderTakeProfit());
      oi.setSlPrice(OrderStopLoss());
   } else {
      string msg = "OrderSelect failed in createOrderLong.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
   }
   
   oi.setTpPrice(oi.getOpenPrice()+APRule_RetracePrice[index]);
   
   return oi;
}

OrderInfo *createOrderShort(double lotSize, int index) {
   OrderInfo *oi = new OrderInfo;
   double slPrice = 0.0;
   double tpPrice = 0.0;
   RefreshRates();
   int ticketId  = OrderSend(_Symbol, OP_SELL , lotSize, Bid, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (-1 == ticketId) {
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
      //oi.setTpPrice(OrderTakeProfit());
      oi.setSlPrice(OrderStopLoss());
   } else {
      string msg = "OrderSelect failed in createOrderShort.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Sell Ticket = " + IntegerToString(ticketId);
      Alert(msg);
   }
   
   oi.setTpPrice(oi.getOpenPrice()-APRule_RetracePrice[index]);
   
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

void closeAll() {
   int listSize = OrderListL.Total();
   OrderInfo *oi = NULL;
   bool isClosed = false;
   for (int i = listSize-1; 0 <= i; i--) {
      oi = OrderListL.GetNodeAtIndex(i);
      isClosed = closeOrderLong(oi);
      if (isClosed) {
         OrderListL.Delete(i);
      }
   }

   listSize = OrderListS.Total();
   for (int i = listSize-1; 0 <= i; i--) {
      oi = OrderListS.GetNodeAtIndex(i);
      isClosed = closeOrderLong(oi);
      if (isClosed) {
         OrderListL.Delete(i);
      }
   }
}

void PressButton(string ctlName) {
   bool selected = ObjectGetInteger(ChartID(), ctlName, OBJPROP_STATE);
   if (selected) {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, false);
   } else {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, true);
   }
}

void updateNewsStatus() {

   string lblRemainTime = "Remain_Time";
   if (ObjectFind(0, lblRemainTime) < 0) {
      mustStopEAByNews = false;
      forbidCreateOrder = false;
      return;
   }
   
   string remainTime = "";
   ObjectGetString(0, lblRemainTime, OBJPROP_TEXT, 0, remainTime);
   
   int hours = StrToInteger(StringSubstr(remainTime, 0, 2));
   int minutes = StrToInteger(StringSubstr(remainTime, 3, 2));
   //int seconds = StrToInteger(StringSubstr(remainTime, 6, 2));
   
   if (0 == hours && minutes <= 1) {
      stopedTimeByNews = TimeLocal();
   }
   
   if (0 == hours && minutes <= minutesMustStopEABeforeNews) {
      mustStopEAByNews = true;
      //return;
   } else {
      mustStopEAByNews = false;
   }
   
   if (hours < hoursForbidCreateOrderBeforeNews) {
      forbidCreateOrder = true;
   } else {
      forbidCreateOrder = false;
   }

}

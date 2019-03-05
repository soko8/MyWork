//+------------------------------------------------------------------+
//|             Deprecated                MartingaleFixedEA_v1.0.mq4 |
//|                  Copyright 2016～2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Gao Zeng.QQ--183947281,mail--soko8@sina.com."
#property link      "https://www.mql5.com"
#property version   "1.08"
#property strict

#include <stdlib.mqh>

struct OrderInfo {
   double   lotSize;
   double   openPrice;
   double   slPrice;
   double   tpPrice;
   int      ticketId;
   int      operationType;
};

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
input int                  GridPoints=170;
input int                  TakeProfitPoints = 30;
input double               RetraceProfitCoefficient = 0.25;
input int                  MaxTimesAddPosition = 10;
input bool                 AddPositionByTrend = false;
input enCloseMode          CloseMode = Close_Part_All;
input enAddPositionMode    AddPositionMode = Multiplied;
input double               LotAddPositionStep = 0.01;
input double               LotAddPositionMultiple = 2.0;
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

      OrderInfo            arrOrdersBuy[];
      OrderInfo            arrOrdersSell[];
      
      double               initLotSize4Buy;
      double               initLotSize4Sell;
      double               curInitLotSize4Buy;
      double               curInitLotSize4Sell;
      
      int                  countAPBuy = -1;
      int                  countAPSell = -1;
      
      double               retracePriceBuy = 0.0;
      double               retracePriceSell = 0.0;
      
      double               retraceRatioBuy = 0.0;
      double               retraceRatioSell = 0.0;
      
      double               closeProfitBuy = 0.0;
      double               closeProfitSell = 0.0;
      
      int                  arraySize;
      double               reduceFactor;

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
      bool        isActive                = true;
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
const string      nmLabelProfitStatus     = "ProfitStatusLabel";
const string      txtLabelProfitStatus    = "Profit:";
const string      nmLabelProfitLong       = "LongProfit";
const string      nmLabelProfitShort      = "ShortProfit";
const string      nmLabelTotalProfit      = "TotalProfitLabel";
const string      txtLabelTotalProfit     = "Total:";
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
      
      bool        AccountCtrl = true;
const int         AuthorizeAccountList[4] = {  6154218
                                              ,7100152
                                              ,5015177
                                              ,5330172
                                             };
      bool        enableUseLimit=true;
      datetime    expireTime = D'2017.12.31 23:59:59';

bool isAuthorized() {
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

int countOrders() {
   int orderNumber = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      if ( OrderSelect(i, SELECT_BY_POS) ) {
         if ( OrderSymbol() == _Symbol && MagicNumber == OrderMagicNumber() ) {
            orderNumber++;
         }
      }
   }
   
   return orderNumber;
}

int OnInit() {

   if (!isAuthorized()) {
		return INIT_FAILED;
	}
	
   if (enableUseLimit) {
      datetime now = TimeGMT();
      if (expireTime < now) {
         return INIT_FAILED;
      }
   }

   if (0 < countOrders()) {
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
   reduceFactor = (lotMultiple-1)/lotMultiple;
   
   initLotSize4Buy = initLots;
   initLotSize4Sell = initLots;
   curInitLotSize4Buy = initLots;
   curInitLotSize4Sell = initLots;
   
   arraySize = maxTimes4AP+1;
   
   ArrayResize(arrOrdersBuy, arraySize);
   ArrayResize(arrOrdersSell, arraySize);
   
   DrawLine(nmLineClosePositionBuy, 0, clrGold, STYLE_DOT);
   DrawLine(nmLineClosePositionSell, 0, clrGold, STYLE_DOT);
   
   btnModeBuy = Close_Order_Mode;
   btnModeSell = Close_Order_Mode;
   
   //RectLabelCreate(nmRectLabelProfitStatus, 75, 0, 528);
   RectLabelCreate(nmRectLabelProfitStatus, 75, 0, 724);
   string fontName = "Lucida Bright";
   SetText(nmLabelProfitStatus, txtLabelProfitStatus, 77, 1);
   SetText(nmLabelProfitLong, "0.0", 110, 0, 11);
   SetText(nmLabelProfitShort, "0.0", 206, 0, 11);
   SetText(nmLabelProfitDPLong, "0.0", 312, 0, 11);
   SetText(nmLabelProfitDPShort, "0.0", 406, 0, 11);
   SetText(nmLabelTotalProfit, txtLabelTotalProfit, 500, 1);
   SetText(nmLabelTotalProfitValue, "0.0", 528, 0, 11);
   
   ButtonCreate(nmBtnStopResume, txtBtnStop, 3, 20, 80, 28, color4BtnStop, 14, clrBlack, fontName, clrGold);
   
   ButtonCreate(nmBtnCloseLong, txtBtnCloseLong, 104, 20, 80, 28, clrDarkGreen, 12, clrWhite, fontName, clrWhite);
   ButtonCreate(nmBtnCloseShort, txtBtnCloseShort, 200, 20, 80, 28, clrMaroon, 12, clrWhite, fontName, clrWhite);
   
   ButtonCreate(nmBtnDecreasePositionLong, txtBtnDecreasePositionLong, 306, 20, 80, 28, clrDarkGreen, 16, clrWhite, fontName, clrWhite);
   ButtonCreate(nmBtnDecreasePositionShort, txtBtnDecreasePositionShort, 400, 20, 80, 28, clrMaroon, 16, clrWhite, fontName, clrWhite);

   ButtonCreate(nmBtnForbidCreateOrderManual, txtBtnForbidCreateOrderManual, 523, 20, 80, 28, color4BtnForbidCreateOrderManual, 14, clrBlack, fontName, clrGold);
   
   /*
   if (Fixed == addPositionMode) {
      Max_Lot_AP = initLots*(maxTimes4AP-4);
   } else {
      double lotCoefficient = MathPow(lotMultiple, maxTimes4AP-4);
      Max_Lot_AP = calculateLot(initLots, lotCoefficient);
   }
   */
   Max_Lot_AP = MaxLots4AddPositionLimit;
   
   drawInputParameters();
   
   drawNew4Buttons();
   
   return(INIT_SUCCEEDED);
}

void drawNew4Buttons() {
   int x = 620;
   int y = 20;
   SetText(lblNmProfitMaxBuyOrder, "0.0", x+2, 0, 11);
   SetText(lblNmProfitMaxSellOrder, "0.0", x+85+5+2, 0, 11);
   ButtonCreate(btnNmCloseMaxBuyOrder, "CloseMaxBuy", x, y, 85, 28, clrDarkGreen, 10, clrWhite);
   ButtonCreate(btnNmCloseMaxSellOrder, "CloseMaxSell", x+85+5, y, 87, 28, clrMaroon, 10, clrWhite);
   ButtonCreate(btnNmAdd1BuyOrder, "Add1Buy", x+85+5+87+10, y, 58, 28, clrDarkGreen, 10, clrWhite);
   ButtonCreate(btnNmAdd1SellOrder, "Add1Sell", x+85+5+87+10+58+5, y, 60, 28, clrMaroon, 10, clrWhite);
}

void drawInputParameters() {
   color       colorBtnUp=clrGreen;
   //string      btnTxtUp=CharToStr(225);
   string      btnTxtUp=CharToStr('p');
   color       colorBtnDn=clrRed;
   //string      btnTxtDn=CharToStr(226);
   string      btnTxtDn=CharToStr('q');

   int x_start = 120;
   int y_start = 51;
   int x = x_start;
   int y = y_start;
   RectLabelCreate("InputParametersRectLabel", x, y, 584, 244);
   
   color backgroundColor = C'35,35,35';
   string fontName = "Wingdings 3";
   //string fontName = "Webdings";
   int fontSize = 11;
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
   SetText("MaxTimesAddOrderLabel", "Max Times Add Order :", x+4, y+2, fontSize+1);
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
   string lblText = "Lot Add Order Multiple :";
   string lblValue = DoubleToStr(lotMultiple, 2);
   if (Fixed == addPositionMode) {
      lblText = "Lot Add Order Step :";
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
   SetText("MagicNumberValue", IntegerToString(MagicNumber), x+interval+1, y+3, fontSize);

   y += btnHeight+rowInterval;
   SetText("MaxLots4AddPositionLimitLabel", "Max Lots Add Order Limit :", x+4, y+2, fontSize+1);
   ButtonCreate(btnNmMaxLots4AddPositionLimitDn, btnTxtDn, x+interval, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnDn, fontName);
   RectLabelCreate("MaxLots4AddPositionLimitValueRectLabel", x+interval+btnWidth+1, y+2, widthValue, btnHeight);
   SetText(lblNmMaxLots4AddPositionLimitValue, DoubleToStr(Max_Lot_AP, 2), x+interval+btnWidth+18, y+3, fontSize);
   ButtonCreate(btnNmMaxLots4AddPositionLimitUp, btnTxtUp, x+interval+btnWidth+widthValue+2, y+2, btnWidth, btnHeight, backgroundColor, fontSize, colorBtnUp, fontName);

   x = x_start + 445;
   y = y_start;
   SetText("LongWords", "Long", x, y+2, fontSize+1);
   SetText("ShortWords", "Short", x+70, y+2, fontSize+1);

   x = x_start + 350;
   y += btnHeight+rowInterval;
   SetText("CloseProfitWords", "Close Profit:", x+4, y+2, fontSize-1);
   SetText(lblnmCloseBuyProfit, "0.0", x+84, y+2, fontSize-1);
   SetText(lblnmCloseSellProfit, "0.0", x+159, y+2, fontSize-1);
   
   y += btnHeight+rowInterval;
   SetText("RetraceRatioWords", "Retrace :", x+4, y+2, fontSize-1);
   SetText(lblnmRetraceRatioBuy, "0.0", x+84, y+2, fontSize-1);
   SetText(lblnmRetraceRatioSell, "0.0", x+159, y+2, fontSize-1);
   
   y += btnHeight+rowInterval;
   SetText("CountAPWords", "Add Order Times:", x+4, y+2, fontSize-1);
   SetText(lblnmCountAPBuy, "0", x+114, y+2, fontSize-1);
   SetText(lblnmCountAPSell, "0", x+179, y+2, fontSize-1);
}

void OnDeinit(const int reason) {

   /*
   ObjectDelete(nmLineClosePositionBuy);
   ObjectDelete(nmLineClosePositionSell);
   
   ObjectDelete(nmBtnStopResume);
   
   ObjectDelete(nmBtnDecreasePositionLong);
   ObjectDelete(nmBtnDecreasePositionShort);
   
   ObjectDelete(nmRectLabelProfitStatus);
   ObjectDelete(nmLabelProfitStatus);
   ObjectDelete(nmLabelProfitLong);
   ObjectDelete(nmLabelProfitShort);
   ObjectDelete(nmLabelTotalProfit);
   ObjectDelete(nmLabelTotalProfitValue);
   
   ObjectDelete(nmLabelProfitDPLong);
   ObjectDelete(nmLabelProfitDPShort);
   
   ObjectDelete(nmBtnCloseLong);
   ObjectDelete(nmBtnCloseShort);
   
   ObjectDelete(nmBtnForbidCreateOrderManual);
   
   */
   ObjectsDeleteAll();
}


bool isNewBegin(int orderType) {
   int countAP = -2;
   switch(orderType) {
      case OP_BUY:
         countAP = countAPBuy;
         break;
      case OP_SELL:
         countAP = countAPSell;
         break;
      default:
         return false;
   }

   if (-1 == countAP) {
      return true;
   }
   return false;
}

bool isCloseAllMode(int orderType) {

   if (Close_All == closePositionMode) {
      return true;
   }
   
   int countAP = countAPSell;
   if (OP_BUY == orderType) {
      countAP = countAPBuy;
   }
   
   if (Close_Part_All == closePositionMode && times_Part2All <= countAP) {
      return true;
   }
   
   return false;

}

bool isClosePartMode(int orderType) {
   if (Close_Part == closePositionMode) {
      return true;
   }
   
   int countAP = countAPSell;
   if (OP_BUY == orderType) {
      countAP = countAPBuy;
   }
   
   if (Close_Part_All == closePositionMode && countAP < times_Part2All) {
      return true;
   }
   
   return false;
}

void resetRetrace4Buy() {
   if (countAPBuy < 1) {
      return;
   }
   if (Fixed == addPositionMode) {
      retraceRatioBuy = calculateRetrace4Fixed(countAPBuy, initLotSize4Buy) + retraceProfitRatio;
   } else {
      if ( isCloseAllMode(OP_BUY) ) {
         retraceRatioBuy = calculateRetraceAll(countAPBuy, lotMultiple) + retraceProfitRatio;
      } else if ( isClosePartMode(OP_BUY) ) {
         retraceRatioBuy = calculateRetracePart(countAPBuy, lotMultiple) + retraceProfitRatio;
      }
   }
   
   int retracePoints = (int) (grid * retraceRatioBuy);
   double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
   retracePriceBuy = NormalizeDouble(Point * retracePoints, Digits) + minOpenPrice;
   ObjectMove(nmLineClosePositionBuy, 0, 0, retracePriceBuy);
   calculateCloseProfit4Buy();
}

void resetRetrace4Sell() {
   if (countAPSell < 1) {
      return;
   }
   if (Fixed == addPositionMode) {
      retraceRatioSell = calculateRetrace4Fixed(countAPSell, initLotSize4Sell) + retraceProfitRatio;
   } else {
      if ( isCloseAllMode(OP_SELL) ) {
         retraceRatioSell = calculateRetraceAll(countAPSell, lotMultiple) + retraceProfitRatio;
      } else if ( isClosePartMode(OP_SELL) ) {
         retraceRatioSell = calculateRetracePart(countAPSell, lotMultiple) + retraceProfitRatio;
      }
   }
   
   int retracePoints = (int) (grid * retraceRatioSell);
   double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
   retracePriceSell = maxOpenPrice - NormalizeDouble(Point * retracePoints, Digits);
   ObjectMove(nmLineClosePositionSell, 0, 0, retracePriceSell);
   calculateCloseProfit4Sell();
}

double calculateLot(double lotSize, double coefficient) {

   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double lotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   //double lot = MathFloor(lotSize*coefficient/lotStepServer)*lotStepServer;
   //double lot = MathCeil(lotSize*coefficient/lotStepServer)*lotStepServer;
   double lot = MathRound(lotSize*coefficient/lotStepServer)*lotStepServer;
   
   if (lot < minLot) {
      lot = minLot;
   }
   
   return lot;
}

double calculateLot4AP(int orderType) {
   double lotsize;
   int countAP = -2;
   double curInitLotSize;

   switch(orderType) {
      case OP_BUY:
         countAP = countAPBuy;
         curInitLotSize = curInitLotSize4Buy;
         break;
      case OP_SELL:
         countAP = countAPSell;
         curInitLotSize = curInitLotSize4Sell;
         break;
      default:
         return 0;
   }
   
   if (Fixed == addPositionMode) {
      lotsize = initLots + lotStep*(countAP+1);
   } else {
      double lotCoefficient = MathPow(lotMultiple, countAP+1);
      lotsize = calculateLot(curInitLotSize, lotCoefficient);
   }

   return lotsize;
}

double calculateInitLot(int orderType) {
   int countAP = -2;
   switch(orderType) {
      case OP_BUY:
         countAP = countAPSell;
         break;
      case OP_SELL:
         countAP = countAPBuy;
         break;
      default:
         return 0;
   }
   /*
   if (addPosition2Trend) {
      if (Fixed == addPositionMode) {
         return (initLots + lotStep*countAP);
      }
      return calculateLot(initLots, MathPow(lotMultiple, countAP));
   }
   return initLots;
   */
   double lots = initLots;
   if (addPosition2Trend) {
      if (Fixed == addPositionMode) {
         lots = (initLots + lotStep*countAP);
      } else {
         lots = calculateLot(initLots, MathPow(lotMultiple, countAP));
      }
   }
   if (enableMaxLotControl) {
      if (Max_Lot_AP < lots) {
         lots = Max_Lot_AP;
      }
   }
   return lots;
}

bool addPosition4Buy() {

   if (countAPBuy < 0) {
      return false;
   }
   
   if (maxTimes4AP <= countAPBuy) {
      return false;
   }

   double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
   
   double addPositionPrice = minOpenPrice - gridPrice;
   
   RefreshRates();
   if (Ask < addPositionPrice) {
      double lotsize = calculateLot4AP(OP_BUY);
      createOrderBuy(lotsize);
      resetRetrace4Buy();
      return true;
   }
   
   return false;
}

bool addPosition4Sell() {

   if (countAPSell < 0) {
      return false;
   }
   
   if (maxTimes4AP <= countAPSell) {
      return false;
   }
   
   double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
   
   double addPositionPrice = maxOpenPrice + gridPrice;
   
   RefreshRates();
   if (addPositionPrice < Bid) {
      double lotsize = calculateLot4AP(OP_SELL);
      createOrderSell(lotsize);
      resetRetrace4Sell();
      return true;
   }
   
   return false;
}

void resetStateBuy() {
   
   countAPBuy = -1;

   ArrayResize(arrOrdersBuy, arraySize);
   
   retraceRatioBuy = 0.0;
   retracePriceBuy = 0.0;
   
   closeProfitBuy = 0.0;

   ObjectMove(nmLineClosePositionBuy, 0, 0, 0.0);
}

void resetStateSell() {
   
   countAPSell = -1;

   ArrayResize(arrOrdersSell, arraySize);
   
   retraceRatioSell = 0.0;
   retracePriceSell = 0.0;
   
   closeProfitSell = 0.0;

   ObjectMove(nmLineClosePositionSell, 0, 0, 0.0);
}

void resetTicket(int orderType) {

   int addPositionCount;
   double orderLot;
   
   for (int i = OrdersTotal()-1; 0 <= i; i--) {
   
      bool isSelected = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSelected) {
         string msg = "OrderSelect failed in resetTicket.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      if (_Symbol != OrderSymbol()) {
         continue;
      }
      
      if (MagicNumber != OrderMagicNumber()) {
         continue;
      }

      if (orderType != OrderType()) {
         continue;
      }
      
      orderLot = OrderLots();
      
      if (OP_BUY == orderType) {
         //addPositionCount = (int) (MathLog10(orderLot/curInitLotSize4Buy)/MathLog10(lotMultiple));
         for (int k = 0; k <= countAPBuy; k++) {
            if (isEqualDouble(arrOrdersBuy[k].openPrice, OrderOpenPrice())) {
               addPositionCount = k;
            }
         }
         arrOrdersBuy[addPositionCount].ticketId = OrderTicket();
         arrOrdersBuy[addPositionCount].lotSize = orderLot;
      } else if (OP_SELL == orderType) {
         //addPositionCount = (int) (MathLog10(orderLot/curInitLotSize4Sell)/MathLog10(lotMultiple));
         for (int k = 0; k <= countAPSell; k++) {
            if (isEqualDouble(arrOrdersSell[k].openPrice, OrderOpenPrice())) {
               addPositionCount = k;
            }
         }
         arrOrdersSell[addPositionCount].ticketId = OrderTicket();
         arrOrdersSell[addPositionCount].lotSize = orderLot;
      }

   }
}

void DecreaseLongPosition() {

   int maxShiftIndex = countAPBuy-1;
   
   double preLot = 0;
   
   for (int i = 0; i <= countAPBuy; i++) {
   
      int ticketId = arrOrdersBuy[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         string msg = "OrderSelect failed in DecreaseLongPosition.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
         continue;
      }

      double lot = OrderLots();
      double closeLot = lot;

      // 非最小单，并且非最大单时（即中间单时）
      if (0 != i && countAPBuy != i) {
         closeLot = lot - preLot;
      }
      
      bool isClosed = OrderClose(OrderTicket(), closeLot, Bid, 0);
      
      if (i < maxShiftIndex) {
         arrOrdersBuy[i] = arrOrdersBuy[i+1];
      }

      preLot = lot;
 
      if (!isClosed) {
         string msg = "Buy OrderClose failed in DecreaseLongPosition. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lot=" + DoubleToStr(closeLot, 2);
         msg += " Bid=" + DoubleToStr(Bid, Digits);
         Alert(msg);
         continue;
      }

   }
   
   countAPBuy = countAPBuy - 2;
   ArrayResize(arrOrdersBuy, arraySize, countAPBuy+1);
   
   resetTicket(OP_BUY);

   if (0 < countAPBuy) {
      resetRetrace4Buy();
      if (addPosition2Trend) {
         initLotSize4Sell = calculateLot(initLots, MathPow(lotMultiple, countAPBuy));
      }
   } else if (0 == countAPBuy) {
      retraceRatioBuy = 0.0;
      retracePriceBuy = 0.0;
      closeProfitBuy = 0.0;
      ObjectMove(nmLineClosePositionBuy, 0, 0, 0.0);
      initLotSize4Sell = initLots;

   } else {
      resetStateBuy();
      initLotSize4Sell = initLots;
   }

}

void DecreaseShortPosition() {

   int maxShiftIndex = countAPSell-1;

   double preLot = 0;
   
   for (int i = 0; i <= countAPSell; i++) {
   
      int ticketId = arrOrdersSell[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         string msg = "OrderSelect failed in DecreaseShortPosition.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
         continue;
      }
      
      double lot = OrderLots();
      double closeLot = lot;
      
      // 非最小单，并且非最大单时（即中间单时）
      if (0 != i && countAPSell != i) {
         closeLot = lot - preLot;
      }
      
      bool isClosed = OrderClose(OrderTicket(), closeLot, Ask, 0);
      
      if (i < maxShiftIndex) {
         arrOrdersSell[i] = arrOrdersSell[i+1];
      }

      preLot = lot;

      if (!isClosed) {
         string msg = "Sell OrderClose failed in DecreaseShortPosition. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lot=" + DoubleToStr(closeLot, 2);
         msg += " Ask=" + DoubleToStr(Ask, Digits);
         Alert(msg);
         continue;
      }

   }
   
   countAPSell = countAPSell - 2;
   ArrayResize(arrOrdersSell, arraySize, countAPSell+1);
   
   resetTicket(OP_SELL);

   if (0 < countAPSell) {
      resetRetrace4Sell();
      if (addPosition2Trend) {
         initLotSize4Buy = calculateLot(initLots, MathPow(lotMultiple, countAPSell));
      }
   } else if (0 == countAPSell) {
      retraceRatioSell = 0.0;
      retracePriceSell = 0.0;
      closeProfitSell = 0.0;
      ObjectMove(nmLineClosePositionSell, 0, 0, 0.0);
      initLotSize4Buy = initLots;
      
   } else {
      resetStateSell();
      initLotSize4Buy = initLots;
   }

}

bool doRetrace4Buy() {

   if (countAPBuy < 1) {
      return false;
   }

   RefreshRates();
   if (retracePriceBuy <= Bid) {
      if (Fixed == addPositionMode || isCloseAllMode(OP_BUY)) {
         CloseAllBuy();
         resetStateBuy();
         return true;
      } else if ( isClosePartMode(OP_BUY) ) {
         DecreaseLongPosition();
         return true;
      }

   }
   
   return false;
}

bool doRetrace4Sell() {

   if (countAPSell < 1) {
      return false;
   }
   
   RefreshRates();
   if (Ask <= retracePriceSell) {
      if (Fixed == addPositionMode || isCloseAllMode(OP_SELL)) {
         CloseAllSell();
         resetStateSell();
         return true;
      } else if ( isClosePartMode(OP_SELL) ) {
         DecreaseShortPosition();
         return true;
      }
   }
   
   return false;
}

bool takeProfit4Buy() {
   if (0 != countAPBuy) {
      return false;
   }
   
   int ticketId = arrOrdersBuy[0].ticketId;
   
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect failed in takeProfit4Buy.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   
   double tpPrice = OrderOpenPrice() + tp;
   RefreshRates();
   // 止赢时
   if (tpPrice <= Bid) {
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), Bid, 0);

      if (!isClosed) {
         string msg = "Buy OrderClose failed in takeProfit4Buy. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
         msg += " Bid=" + DoubleToStr(Bid, Digits);
         Alert(msg);
         return false;
      }
      countAPBuy--;
      ArrayResize(arrOrdersBuy, arraySize);
      
      return true;
   }

   return false;
}

bool takeProfit4Sell() {
   if (0 != countAPSell) {
      return false;
   }
   
   int ticketId = arrOrdersSell[0].ticketId;
   
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect failed in takeProfit4Sell.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   
   double tpPrice = OrderOpenPrice() - tp;
   RefreshRates();
   // 止赢时
   if (Ask <= tpPrice) {
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), Ask, 0);

      if (!isClosed) {
         string msg = "Sell OrderClose failed in takeProfit4Sell. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
         msg += " Ask=" + DoubleToStr(Ask, Digits);
         Alert(msg);
         return false;
      }
      countAPSell--;
      ArrayResize(arrOrdersSell, arraySize);
      
      return true;
   }

   return false;
}

void checkBuyOrder() {

   if (takeProfit4Buy()) {
      return;
   }
   
   if (doRetrace4Buy()) {
      return;
   }
   
   addPosition4Buy();
}

void checkSellOrder() {
   if (takeProfit4Sell()) {
      return;
   }
   
   if (doRetrace4Sell()) {
      return;
   }
   
   addPosition4Sell();
}

void resetState() {

   resetStateBuy();
   resetStateSell();
   
   //isStopedByNews          = false;
   //stopedTimeByNews        = 0;

}

void OnTick() {

   if (enableUseLimit) {
      datetime now = TimeGMT();
      if (expireTime < now) {
         Alert("使用过期，请联系作者。邮箱：soko8@sina.com  或者QQ:183947281");
         return;
      }
   }

   calculateProfit();
   
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
      resetState();

      stopEA();
      
      isStopedByNews = true;
      stopedTimeByNews = TimeLocal();
      
      return;
   }

   checkBuyOrder();
   checkSellOrder();
   
   if (isNewBegin(OP_BUY)) {
      if (!forbidCreateOrder && !isForbidCreateOrderManual) {
         curInitLotSize4Buy = calculateInitLot(OP_BUY);
         createOrderBuy(curInitLotSize4Buy);
         setCloseBuyButton(Close_Order_Mode);
      }
   }
   
   if (isNewBegin(OP_SELL)) {
      if (!forbidCreateOrder && !isForbidCreateOrderManual) {
         curInitLotSize4Sell = calculateInitLot(OP_SELL);
         createOrderSell(curInitLotSize4Sell);
         setCloseSellButton(Close_Order_Mode);
      }
   }
   
   calculateProfit();
   SetComments();
}

void CloseAllBuy() {

   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSuccess) {
         string msg = "Order Select failed in CloseAllBuy.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      if (_Symbol != OrderSymbol()) {
         continue;
      }
      
      if (MagicNumber != OrderMagicNumber()) {
         continue;
      }
      
      if (OP_BUY != OrderType()) {
         continue;
      }

      isSuccess = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
      
      if (!isSuccess) {
         string msg = "Buy Order Close failed in CloseAllBuy.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());
         Alert(msg);
      }

   }

}

void CloseAllSell() {

   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSuccess) {
         string msg = "Order Select failed in CloseAllSell.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      if (_Symbol != OrderSymbol()) {
         continue;
      }
      
      if (MagicNumber != OrderMagicNumber()) {
         continue;
      }
      
      if (OP_SELL != OrderType()) {
         continue;
      }

      isSuccess = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
      
      if (!isSuccess) {
         string msg = "Sell Order Close failed in CloseAllSell.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());
         Alert(msg);
      }

   }

}


void CloseOrDeleteOrder() {
   
   if (_Symbol != OrderSymbol()) {
      return;
   }
   
   if (MagicNumber != OrderMagicNumber()) {
      return;
   }

   bool isSuccess = true;
   string kbn = "";
   switch(OrderType()) {
      case OP_BUY:
         kbn = "Buy";
         isSuccess = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
         break;
      case OP_SELL:
         kbn = "Sell";
         isSuccess = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
         break;
      case OP_BUYSTOP:
      case OP_BUYLIMIT:
      case OP_SELLSTOP:
      case OP_SELLLIMIT:
         kbn = "Pending";
         isSuccess = OrderDelete(OrderTicket());
         break;
   }

   if (!isSuccess) {
      string msg = kbn + " Order Close failed.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());
      Alert(msg);
   }

}

void closeAll() {

   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSuccess) {
         string msg = "Order Select failed.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      CloseOrDeleteOrder();

   }

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

void stopEA() {
/*
   closeAll();
   resetState();
*/
   isActive = false;
   SetComments();
   ObjectSetString(0, nmBtnStopResume, OBJPROP_TEXT, txtBtnResume);
   //ObjectSetInteger(0,namePauseBtn, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0,nmBtnStopResume, OBJPROP_BGCOLOR, color4BtnResume);
}

void resumeEA() {
   isActive = true;
   
   ObjectSetString(0, nmBtnStopResume, OBJPROP_TEXT, txtBtnStop);
   //ObjectSetInteger(0,namePauseBtn, OBJPROP_COLOR, clrRed);
   ObjectSetInteger(0,nmBtnStopResume, OBJPROP_BGCOLOR, color4BtnStop);
   
   //isStopedByNews = false;
   //stopedTimeByNews = 0;
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
         if (0 < countAPBuy) {
            DecreaseLongPosition();
            SetComments();
         }
         PressButton(nmBtnDecreasePositionLong);
      }
      
      else 
      if (nmBtnDecreasePositionShort == sparam) {
         if (0 < countAPSell) {
            DecreaseShortPosition();
            SetComments();
         }
         PressButton(nmBtnDecreasePositionShort);
      }
      
      else 
      if (nmBtnCloseLong == sparam) {
      
         if (Close_Order_Mode == btnModeBuy) {
            if (0 <= countAPBuy) {
               CloseAllBuy();
               resetStateBuy();
               setCloseBuyButton(Create_Order_Mode);
               SetComments();
            }
         } else {
            createOrderBuy(initLotSize4Buy);
            setCloseBuyButton(Close_Order_Mode);
            SetComments();
         }

         PressButton(nmBtnCloseLong);
      }
      
      else 
      if (nmBtnCloseShort == sparam) {
         if (Close_Order_Mode == btnModeSell) {
            if (0 <= countAPSell) {
               CloseAllSell();
               resetStateSell();
               setCloseSellButton(Create_Order_Mode);
               SetComments();
            }
         } else {
            createOrderSell(initLotSize4Sell);
            setCloseSellButton(Close_Order_Mode);
            SetComments();
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
         if (0 == countOrders()) {
         grid += 1;
         gridPrice = NormalizeDouble(Point * grid, Digits);
         ObjectSetString(0, lblNmGridPointsValue, OBJPROP_TEXT, IntegerToString(grid));
         resetRetrace4Buy();
         resetRetrace4Sell();
         } else {
            Alert("Orders > 0, you can't change it.");
         }
         //PressButton(btnNmGridPointsUp);
      }
      else 
      if (btnNmGridPointsDn == sparam) {
         if (0 == countOrders()) {
         grid -= 1;
         gridPrice = NormalizeDouble(Point * grid, Digits);
         ObjectSetString(0, lblNmGridPointsValue, OBJPROP_TEXT, IntegerToString(grid));
         resetRetrace4Buy();
         resetRetrace4Sell();
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
         //PressButton(btnNmTakeProfitPointsUp);
      }
      else 
      if (btnNmTakeProfitPointsDn == sparam) {
         tpPoints -= 1;
         tp = NormalizeDouble(Point * tpPoints, Digits);
         ObjectSetString(0, lblNmTakeProfitPointsValue, OBJPROP_TEXT, IntegerToString(tpPoints));
         //PressButton(btnNmTakeProfitPointsDn);
      }
      
      else 
      if (btnNmRetraceProfitCoefficientUp == sparam) {
         retraceProfitRatio += 0.01;
         ObjectSetString(0, lblNmRetraceProfitCoefficientValue, OBJPROP_TEXT, DoubleToStr(retraceProfitRatio, 2));
         resetRetrace4Buy();
         resetRetrace4Sell();
         //PressButton(btnNmRetraceProfitCoefficientUp);
      }
      else 
      if (btnNmRetraceProfitCoefficientDn == sparam) {
         retraceProfitRatio -= 0.01;
         ObjectSetString(0, lblNmRetraceProfitCoefficientValue, OBJPROP_TEXT, DoubleToStr(retraceProfitRatio, 2));
         resetRetrace4Buy();
         resetRetrace4Sell();
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
            resetRetrace4Buy();
            resetRetrace4Sell();
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
            resetRetrace4Buy();
            resetRetrace4Sell();
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
            resetRetrace4Buy();
            resetRetrace4Sell();
         }
         //PressButton(btnNmCMClosePartAll);
      }
      
      else 
      if (btnNmAPMFixed == sparam) {
         if (Fixed == addPositionMode) {
            
         } else {
            if (0 == countOrders()) {
            addPositionMode = Fixed;
            ObjectSetInteger(0,btnNmAPMFixed, OBJPROP_BGCOLOR, btnColorEnable);
            ObjectSetInteger(0,btnNmAPMMultiplied, OBJPROP_BGCOLOR, btnColorDisable);
            
            ObjectSetString(0, lblNmLotAddPositionLabel, OBJPROP_TEXT, lblTxtLotAddPositionStep);
            ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotStep, 2));
            resetRetrace4Buy();
            resetRetrace4Sell();
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
            if (0 == countOrders()) {
            addPositionMode = Multiplied;
            ObjectSetInteger(0,btnNmAPMFixed, OBJPROP_BGCOLOR, btnColorDisable);
            ObjectSetInteger(0,btnNmAPMMultiplied, OBJPROP_BGCOLOR, btnColorEnable);
            
            ObjectSetString(0, lblNmLotAddPositionLabel, OBJPROP_TEXT, lblTxtLotAddPositionMultiple);
            ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotMultiple, 2));
            resetRetrace4Buy();
            resetRetrace4Sell();
            } else {
               Alert("Orders > 0, you can't change it.");
            }
         }
         //PressButton(btnNmAPMMultiplied);
      }
      
      else 
      if (btnNmLotAddPositionUp == sparam) {
         if (0 == countOrders()) {
         if (Multiplied == addPositionMode) {
            lotMultiple += 0.01;
            // TODO reset ?
            ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotMultiple, 2));
         } else {
            lotStep += 0.01;
            // TODO reset ?
            ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotStep, 2));
         }
         resetRetrace4Buy();
         resetRetrace4Sell();
         } else {
            Alert("Orders > 0, you can't change it.");
         }
         
         //PressButton(btnNmLotAddPositionUp);
      }
      else 
      if (btnNmLotAddPositionDn == sparam) {
         if (0 == countOrders()) {
         if (Multiplied == addPositionMode) {
            lotMultiple -= 0.01;
            // TODO reset ?
            ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotMultiple, 2));
         } else {
            lotStep -= 0.01;
            // TODO reset ?
            ObjectSetString(0, lblNmLotAddPositionValue, OBJPROP_TEXT, DoubleToStr(lotStep, 2));
         }
         resetRetrace4Buy();
         resetRetrace4Sell();
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
         closeMaxAPLongOrder();
         //PressButton(btnNmCloseMaxBuyOrder);
      }
      
      else 
      if (btnNmCloseMaxSellOrder == sparam) {
         closeMaxAPShortOrder();
         //PressButton(btnNmCloseMaxSellOrder);
      }
      
      else 
      if (btnNmAdd1BuyOrder == sparam) {
         doAP4LongByManual();
         //PressButton(btnNmAdd1BuyOrder);
      }
      
      else 
      if (btnNmAdd1SellOrder == sparam) {
         doAP4ShortByManual();
         //PressButton(btnNmAdd1SellOrder);
      }
   }  
   
   else if (id == CHARTEVENT_OBJECT_DRAG) {
      string objectName = sparam;
      if (nmLineClosePositionBuy == objectName) {
         retracePriceBuy = ObjectGet(nmLineClosePositionBuy, OBJPROP_PRICE1);
         double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
         retraceRatioBuy = (retracePriceBuy-minOpenPrice)/Point/grid;
         calculateCloseProfit4Buy();
         SetComments();
      } else if (nmLineClosePositionSell == objectName) {
         retracePriceSell = ObjectGet(nmLineClosePositionSell, OBJPROP_PRICE1);
         double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
         retraceRatioSell = (maxOpenPrice-retracePriceSell)/Point/grid;
         calculateCloseProfit4Sell();
         SetComments();
      }
   }
}

void calculateCloseProfit4Buy() {
   
   closeProfitBuy = 0.0;

   if (retracePriceBuy <= 0.0) {
      return;
   }
   
   for (int i = 0; i <= countAPBuy; i++) {
      if ( OrderSelect(arrOrdersBuy[i].ticketId, SELECT_BY_TICKET) ) {

         double diffPrice = retracePriceBuy - OrderOpenPrice();
         double profiti = OrderLots()*diffPrice/Point;
         closeProfitBuy += profiti;
         if ( isClosePartMode(OP_BUY) ) {
            if (countAPBuy != i && 0 != i) {
               closeProfitBuy -= profiti/lotMultiple;
            }
         }
         closeProfitBuy += OrderCommission();
         closeProfitBuy += OrderSwap(); 

      }
   }
   
}

void calculateCloseProfit4Sell() {
   
   closeProfitSell = 0.0;

   if (retracePriceSell <= 0.0) {
      return;
   }
   
   for (int i = 0; i <= countAPSell; i++) {
      if ( OrderSelect(arrOrdersSell[i].ticketId, SELECT_BY_TICKET) ) {

         double diffPrice = OrderOpenPrice() - retracePriceSell;
         double profiti = OrderLots()*diffPrice/Point;
         closeProfitSell += profiti;
         if ( isClosePartMode(OP_SELL) ) {
            if (countAPSell != i && 0 != i) {
               closeProfitSell -= profiti/lotMultiple;
            }
         }
         closeProfitSell += OrderCommission();
         closeProfitSell += OrderSwap();

      }
   }
   
}

void calculateProfit() {

   double profitLong = 0.0;
   double profitShort = 0.0;
   
   double profitDPLong = 0.0;
   double tmpOneProfit = 0.0;
   for (int i = 0; i <= countAPBuy; i++) {

      int ticketId = arrOrdersBuy[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         tmpOneProfit = OrderProfit();
         tmpOneProfit += OrderCommission();
         tmpOneProfit += OrderSwap();
         
         profitLong += tmpOneProfit;
         profitDPLong += tmpOneProfit;
         
         if (0 != i && countAPBuy != i) {
            double minusProfit = OrderProfit()*(1-reduceFactor);
            profitDPLong -= minusProfit;
         }
      } else {
         string msg = "OrderSelect failed in calculateProfit.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

   }
   
   double profitDPShort = 0.0;
   for (int i = 0; i <= countAPSell; i++) {

      int ticketId = arrOrdersSell[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         tmpOneProfit = OrderProfit();
         tmpOneProfit += OrderCommission();
         tmpOneProfit += OrderSwap();
         
         profitShort += tmpOneProfit;
         profitDPShort += tmpOneProfit;
         
         if (0 != i && countAPSell != i) {
            double minusProfit = OrderProfit()*(1-reduceFactor);
            profitDPShort -= minusProfit;
         }
      } else {
         string msg = "OrderSelect failed in calculateProfit.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

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
   if (0 <= countAPBuy) {
      bool isSelected = OrderSelect(arrOrdersBuy[countAPBuy].ticketId, SELECT_BY_TICKET);
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
   if (0 <= countAPSell) {
      bool isSelected = OrderSelect(arrOrdersSell[countAPSell].ticketId, SELECT_BY_TICKET);
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

int createOrderBuy(double lotSize) {

   int chkBuy  = OrderSend(Symbol(), OP_BUY , lotSize, Ask, 0, 0, 0, "", MagicNumber, 0, clrBlue);
   
   if (-1 == chkBuy) {
      string msg = "BUY OrderSend failed in createOrderBuy. Error:" + ErrorDescription(GetLastError());
      msg += " Ask=" + DoubleToStr(Ask, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return chkBuy;
   }
   
   if (0 == countAPBuy && isEqualDouble(lotSize, initLots)) {
      
   } else {
      countAPBuy++;
   }
   
   double openPrice = Ask;
   
   if (OrderSelect(chkBuy, SELECT_BY_TICKET)) {
      openPrice = OrderOpenPrice();
   } else {
      string msg = "OrderSelect failed in createOrderBuy.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(chkBuy);
      Alert(msg);
   }
   
   OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_BUY};
   orderInfo.lotSize = lotSize;
   orderInfo.openPrice = openPrice;
   orderInfo.ticketId = chkBuy;
   arrOrdersBuy[countAPBuy] = orderInfo;
   
   return chkBuy;
}

int createOrderSell(double lotSize) {

   int chkSell = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, 0, 0, "", MagicNumber, 0, clrRed);
   
   if (-1 == chkSell) {
      string msg = "SELL OrderSend failed in createOrderSell. Error:" + ErrorDescription(GetLastError());
      msg += " Bid=" + DoubleToStr(Bid, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return chkSell;
   }
   
   if (0 == countAPSell && isEqualDouble(lotSize, initLots)) {
   } else {
      countAPSell++;
   }
   
   double openPrice = Bid;
   
   if (OrderSelect(chkSell, SELECT_BY_TICKET)) {
      openPrice = OrderOpenPrice();
   } else {
      string msg = "OrderSelect failed in createOrderSell.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Sell Ticket = " + IntegerToString(chkSell);
      Alert(msg);
   }
   
   OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_SELL};
   orderInfo.lotSize = lotSize;
   orderInfo.openPrice = openPrice;
   orderInfo.ticketId = chkSell;
   arrOrdersSell[countAPSell] = orderInfo;
   
   return chkSell;
}

bool isEqualDouble(double num1, double num2) {

   if( NormalizeDouble(num1-num2,8) == 0 ) {
      return true;
   }
   
   return false;
}


/*
void SetComments() {
   string space = "                                                                                                                         ";
   string CrLf = "\n";
   string Cmt = "";
   
   Cmt += CrLf;
   Cmt += CrLf;
   Cmt += CrLf;

   Cmt += space + "Buy Close Profit = " + DoubleToStr(closeProfitBuy, 2);
   Cmt += "     " + "Sell Close Profit = " + DoubleToStr(closeProfitSell, 2) + CrLf;
   
   Cmt += CrLf;
   Cmt += space + "Buy Retrace = " + DoubleToStr(retraceRatioBuy, Digits);
   Cmt += "     " + "Sell Retrace = " + DoubleToStr(retraceRatioSell, Digits) + CrLf;
   
   Cmt += CrLf;
   Cmt += space + "Buy AP Times = " + IntegerToString(countAPBuy);
   Cmt += "     " + "Sell AP Times = " + IntegerToString(countAPSell);

   Comment(Cmt);
}
*/

void SetComments() {
   ObjectSetString(0, lblnmCloseBuyProfit, OBJPROP_TEXT, DoubleToStr(closeProfitBuy, 2));
   ObjectSetString(0, lblnmCloseSellProfit, OBJPROP_TEXT, DoubleToStr(closeProfitSell, 2));
   ObjectSetString(0, lblnmRetraceRatioBuy, OBJPROP_TEXT, DoubleToStr(retraceRatioBuy, Digits));
   ObjectSetString(0, lblnmRetraceRatioSell, OBJPROP_TEXT, DoubleToStr(retraceRatioSell, Digits));
   ObjectSetString(0, lblnmCountAPBuy, OBJPROP_TEXT, IntegerToString(countAPBuy));
   ObjectSetString(0, lblnmCountAPSell, OBJPROP_TEXT, IntegerToString(countAPSell));
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

void PressButton(string ctlName) {
   bool selected = ObjectGetInteger(ChartID(), ctlName, OBJPROP_STATE);
   if (selected) {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, false);
   } else {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, true);
   }
}

void RectLabelCreate(string            name,                         // label name
                     int               x=0,                          // X coordinate
                     int               y=0,                          // Y coordinate
                     int               width=50,                     // width
                     int               height=18,                    // height
                     color             backgroundColor=clrBlack,     // background color
                     color             borderColor=clrWhite,         // flat border color (Flat)
                     ENUM_LINE_STYLE   style=STYLE_SOLID,            // flat border style
                     int               line_width=1,                 // flat border width
                     ENUM_BORDER_TYPE  border=BORDER_FLAT,           // border type
                     ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,     // chart corner for anchoring
                     bool              back=false,                   // in the background
                     bool              selection=false,              // highlight to move
                     bool              hidden=true,                  // hidden in the object list
                     long              z_order=0)                    // priority for mouse click
{

   ResetLastError();

   long chart_ID = ChartID();

   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,0,0,0)) {
      Print(__FUNCTION__, ": failed to create a rectangle label! Error code = ",GetLastError());
   }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set label size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,backgroundColor);
//--- set border type
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set flat border color (in Flat mode)
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,borderColor);
//--- set flat border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set flat border width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
}

void DrawLine(string ctlName, 
               double Price = 0, 
               color LineColor = clrGold, 
               ENUM_LINE_STYLE LineStyle = STYLE_SOLID,
               int LineWidth = 1) 
{
   string FullCtlName = ctlName;
   
   if (-1 < ObjectFind(ChartID(), FullCtlName))
   {
         ObjectMove(FullCtlName, 0, 0, Price);
         ObjectSet(FullCtlName, OBJPROP_STYLE, LineStyle);
         ObjectSet(FullCtlName, OBJPROP_WIDTH, LineWidth);
         ObjectSet(FullCtlName, OBJPROP_COLOR, LineColor);
   }
   else
   {
      ObjectCreate(ChartID(), FullCtlName, OBJ_HLINE, 0, 0, Price);
      ObjectSet(FullCtlName, OBJPROP_STYLE, LineStyle);
      ObjectSet(FullCtlName, OBJPROP_WIDTH, LineWidth);
      ObjectSet(FullCtlName, OBJPROP_COLOR, LineColor);
   }
}

void ButtonCreate(string            name,                      // button name
                  string            text,                      // text
                  int               x=0,                       // X coordinate
                  int               y=0,                       // Y coordinate
                  int               width=50,                  // button width
                  int               height=18,                 // button height
                  color             backgroundColor=clrAzure,  // background color
                  int               fontSize=8,                // font size
                  color             textColor=clrBlack,        // text color
                  string            fontName="Arial",          // font
                  color             borderColor=clrWhite,      // border color
                  ENUM_BORDER_TYPE  border=BORDER_RAISED,      // border type
                  ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,  // chart corner for anchoring
                  bool              state=false,               // pressed/released
                  bool              back=false,                // in the background
                  bool              selection=false,           // highlight to move
                  bool              hidden=true,               // hidden in the object list
                  long              z_order=0)                 // priority for mouse click
{ 

   ResetLastError(); 
   long chart_ID = 0;
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,0,0,0)) {
      Print(__FUNCTION__, ": failed to create the button! Error code = ",GetLastError());
   }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,fontName);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,fontSize);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,textColor);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,backgroundColor);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
}



void SetText(  string            name,
               string            text,
               int               x=0,
               int               y=0,
               int               fontSize=8,
               color             fontColor=clrWhite,
               string            fontName="Arial",
               ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER) 
{
   if (ObjectFind(0,name) < 0) {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSet(name, OBJPROP_BACK, false);
   ObjectSetText(name, text, fontSize, fontName, fontColor);
}

bool closeMaxAPLongOrder() {
   if (countAPBuy < 1) {
      return false;
   }
   int ticketId = arrOrdersBuy[countAPBuy].ticketId;
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   if (!isSelected) {
      string msg = "OrderSelect failed in closeMaxAPLongOrder.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   bool isSuccess = OrderClose(ticketId, OrderLots(), Bid, 0);
   if (!isSuccess) {
      printf("Buy Order Close failure in closeMaxAPLongOrder. tickedId = " + IntegerToString(ticketId) + " Error:" + ErrorDescription(GetLastError()));
   } else {
      OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_BUY};
      arrOrdersBuy[countAPBuy] = orderInfo;
      countAPBuy--;
      resetRetrace4Buy();
   }
   return isSuccess;
}

bool closeMaxAPShortOrder() {
   if (countAPSell < 1) {
      return false;
   }
   int ticketId = arrOrdersSell[countAPSell].ticketId;
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   if (!isSelected) {
      string msg = "OrderSelect failed in closeMaxAPShortOrder.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   bool isSuccess = OrderClose(ticketId, OrderLots(), Ask, 0);
   if (!isSuccess) {
      printf("Sell Order Close failure in closeMaxAPShortOrder. tickedId = " + IntegerToString(ticketId) + " Error:" + ErrorDescription(GetLastError()));
   } else {
      OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_SELL};
      arrOrdersSell[countAPSell] = orderInfo;
      countAPSell--;
      resetRetrace4Sell();
   }
   return isSuccess;
}

bool doAP4LongByManual() {
   if (countAPBuy < 0) {
      return false;
   }
   
   if (maxTimes4AP <= countAPBuy) {
      return false;
   }

   double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
   double addPositionPrice = minOpenPrice - gridPrice;

   RefreshRates();
   double lotsize = calculateLot4AP(OP_BUY);
   createOrderBuy(lotsize);
   resetRetrace4Buy();
   return true;
}

bool doAP4ShortByManual() {
   if (countAPSell < 0) {
      return false;
   }

   if (maxTimes4AP <= countAPSell) {
      return false;
   }

   double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
   double addPositionPrice = maxOpenPrice + gridPrice;

   RefreshRates();
   double lotsize = calculateLot4AP(OP_SELL);
   createOrderSell(lotsize);
   resetRetrace4Sell();
   return true;
}
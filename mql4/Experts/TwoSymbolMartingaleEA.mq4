//+------------------------------------------------------------------+
//|                                   TwoSymbolMartingaleEA_v1.0.mq4 |
//|      Copyright 2016, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Gao Zeng.QQ--183947281,mail--soko8@sina.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define SIZE_DIMENSION_1   2
#define SIZE_DIMENSION_2   33

#include <stdlib.mqh>

enum enSymbol {
   EURUSD = 0,
   USDJPY = 1,
   GBPUSD = 2,
   AUDUSD = 3,
   USDCHF = 4,
   USDCAD = 5,
   NZDUSD = 6,
   XAGUSD = 7,
   XAUUSD = 8,
   EURJPY = 9,
   EURGBP = 10,
   EURAUD = 11,
   EURCHF = 12,
   EURCAD = 13,
   EURNZD = 14,
   GBPJPY = 15,
   AUDJPY = 16,
   CHFJPY = 17,
   CADJPY = 18,
   NZDJPY = 19,
   GBPAUD = 20,
   GBPCHF = 21,
   GBPCAD = 22,
   GBPNZD = 23,
   AUDCHF = 24,
   AUDCAD = 25,
   AUDNZD = 26,
   CADCHF = 27,
   NZDCHF = 28,
   NZDCAD = 29,
   USDCNH = 30
};

enum enAPMode
{
   Fixed = 0,
   Multiplied = 1
};

//--- input parameters
input enSymbol       Master_Symbol=EURUSD;
input enSymbol       Slave_Symbol=GBPUSD;
input double         Init_Lots=0.01;
input int            Grid_Points=100;

input double         Take_Profit_Dollar=10.0;
input int            Max_AP_Times=10;
input enAPMode       Add_Position_Type=Multiplied;
input double         Multiplier=2.0;
input double         Add_Position_Steps = 0.01;
input int            MagicNumber=586;
input string         SymbolPrifix="";
input string         SymbolSuffix="";

const int            INIT_TICKET_VALUE = -2;
/***************** stop resume button Begin **********/
const string      nmBtnStopResume         = "StopResume";
const string      txtBtnStop              = "Stop";
const string      txtBtnResume            = "Resume";
const color       color4BtnStop           = clrLightSalmon;
const color       color4BtnResume         = clrLime;
      bool        isActive                = true;
      string      font_Name                = "Lucida Bright";
/***************** stop resume button End   **********/

      string         masterSymbol;
      string         slaveSymbol;
      double         initLots;
      int            gridPoints;
      double         multiplier;
      double         tpDollar;
      int            maxAPtimes;

      double         gridPrice;

      int            ticketsMaster[SIZE_DIMENSION_1][SIZE_DIMENSION_2];
      int            ticketsSlave[SIZE_DIMENSION_1][SIZE_DIMENSION_2];
      
      int            countAPLongMaster;
      int            countAPShortSlave;
      
      int            countAPShortMaster;
      int            countAPLongSlave;
      
      datetime       expireTime = D'2017.05.31 23:59:59';


int OnInit() {

   datetime now = TimeGMT();
   if (expireTime < now) {
      return INIT_FAILED;
   }

   masterSymbol = symbolEnum2String(Master_Symbol);
   slaveSymbol = symbolEnum2String(Slave_Symbol);
   double minLot = MarketInfo(_Symbol, MODE_MINLOT);
   if (Init_Lots < minLot) {
      initLots = minLot;
   } else {
      initLots = Init_Lots;
   }
   gridPoints = Grid_Points;
   multiplier = Multiplier;
   tpDollar = Take_Profit_Dollar;
   maxAPtimes = Max_AP_Times;
   
   gridPrice = NormalizeDouble(Point * gridPoints, Digits);

   ArrayInitialize(ticketsMaster, INIT_TICKET_VALUE);
   ArrayInitialize(ticketsSlave, INIT_TICKET_VALUE);

   countAPLongMaster = -1;
   countAPShortSlave = -1;
   countAPShortMaster = -1;
   countAPLongSlave = -1;
   isActive = true;
   
   ButtonCreate(nmBtnStopResume, txtBtnStop, 3, 20, 80, 28, color4BtnStop, 14, clrBlack, font_Name, clrGold);
   //EventSetTimer(60);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   ObjectDelete(nmBtnStopResume);
   //EventKillTimer();
}

void OnTick() {

   datetime now = TimeGMT();
   if (expireTime < now) {
      return ;
   }

   SetComments();

   if (!isActive) {
      return;
   }
   
   if (isEntryMaster(OP_BUY)) {
      int ticketMaster = createOrderBuy(masterSymbol, initLots);
      ticketsMaster[0][0] = ticketMaster;
      if (-1 < ticketMaster) {
         countAPLongMaster = 0;
      }
   }
   if (isEntrySlave(OP_BUY)) {
      int ticketSlave = createOrderSell(slaveSymbol, initLots);
      ticketsSlave[0][0] = ticketSlave;
      if (-1 < ticketSlave) {
         countAPShortSlave = 0;
      }
   }
   
   if (isEntryMaster(OP_SELL)) {
      int ticketMaster = createOrderSell(masterSymbol, initLots);
      ticketsMaster[1][0] = ticketMaster;
      if (-1 < ticketMaster) {
         countAPShortMaster = 0;
      }
   }
   if (isEntrySlave(OP_SELL)) {
      int ticketSlave = createOrderBuy(slaveSymbol, initLots);
      ticketsSlave[1][0] = ticketSlave;
      if (-1 < ticketSlave) {
         countAPLongSlave = 0;
      }
   }
   
   addPosition4BuyMaster();
   addPosition4BuySlave();
   addPosition4SellMaster();
   addPosition4SellSlave();
   
   double profitLong = calculateProfitBuy();
   if (tpDollar <= profitLong) {
      closeBuy();
   }
   
   double profitShort = calculateProfitSell();
   if (tpDollar <= profitShort) {
      closeSell();
   }
   
   SetComments();
}

void closeBuy() {
   for (int i = 0; i <= countAPLongMaster; i++) {
      int ticketId = ticketsMaster[0][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      bool isClosed = OrderClose(ticketId, OrderLots(), Bid, 0);
      if (!isClosed) {
         string msg = "Buy OrderClose failed in closeBuy. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(ticketId);
         msg += " Bid=" + DoubleToStr(Bid, Digits);
         Alert(msg);
         continue;
      }
   }
   
   for (int i = 0; i <= countAPShortSlave; i++) {

      int ticketId = ticketsSlave[0][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      bool isClosed = OrderClose(ticketId, OrderLots(), Ask, 0);
      if (!isClosed) {
         string msg = "Sell OrderClose failed in closeBuy. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(ticketId);
         msg += " Ask=" + DoubleToStr(Ask, Digits);
         Alert(msg);
         continue;
      }
   }
   
   countAPLongMaster = -1;
   countAPShortSlave = -1;
}

void closeSell() {
   for (int i = 0; i <= countAPShortMaster; i++) {
      int ticketId = ticketsMaster[1][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      bool isClosed = OrderClose(ticketId, OrderLots(), Ask, 0);
      if (!isClosed) {
         string msg = "Sell OrderClose failed in closeSell. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(ticketId);
         msg += " Ask=" + DoubleToStr(Ask, Digits);
         Alert(msg);
         continue;
      }
   }
   
   for (int i = 0; i <= countAPLongSlave; i++) {

      int ticketId = ticketsSlave[1][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      bool isClosed = OrderClose(ticketId, OrderLots(), Bid, 0);
      if (!isClosed) {
         string msg = "Buy OrderClose failed in closeSell. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(ticketId);
         msg += " Bid=" + DoubleToStr(Bid, Digits);
         Alert(msg);
         continue;
      }
   }
   
   countAPShortMaster = -1;
   countAPLongSlave = -1;
}

double calculateProfitBuy() {

   double profit = 0.0;
   for (int i = 0; i <= countAPLongMaster; i++) {

      int ticketId = ticketsMaster[0][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         profit += OrderProfit();
         profit += OrderCommission();
         profit += OrderSwap();
      } else {
         string msg = "OrderSelect failed in calculateProfitBuy.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

   }
   
   for (int i = 0; i <= countAPShortSlave; i++) {

      int ticketId = ticketsSlave[0][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         profit += OrderProfit();
         profit += OrderCommission();
         profit += OrderSwap();
      } else {
         string msg = "OrderSelect failed in calculateProfitBuy.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

   }
   
   return profit;
}

double calculateProfitSell() {

   double profit = 0.0;
   for (int i = 0; i <= countAPShortMaster; i++) {

      int ticketId = ticketsMaster[1][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);

      if (isSelected) {
         profit += OrderProfit();
         profit += OrderCommission();
         profit += OrderSwap();
      } else {
         string msg = "OrderSelect failed in calculateProfitSell.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

   }
   
   for (int i = 0; i <= countAPLongSlave; i++) {

      int ticketId = ticketsSlave[1][i];
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         profit += OrderProfit();
         profit += OrderCommission();
         profit += OrderSwap();
      } else {
         string msg = "OrderSelect failed in calculateProfitSell.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

   }
   
   return profit;
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

double calculateLot4AP(int countAP) {
   double lotsize;
   
   if (Fixed == Add_Position_Type) {
      lotsize = initLots + Add_Position_Steps*(countAP+1);
   } else {
      double lotCoefficient = MathPow(multiplier, countAP+1);
      lotsize = calculateLot(initLots, lotCoefficient);
   }

   return lotsize;
}

bool addPosition4BuyMaster() {
   if (countAPLongMaster < 0) {
      return false;
   }
   
   if (maxAPtimes <= countAPLongMaster) {
      return false;
   }
   
   int ticketId = ticketsMaster[0][countAPLongMaster];
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   if (!isSelected) {
      return false;
   }
   double minOpenPrice = OrderOpenPrice();
   
   double addPositionPrice = minOpenPrice - gridPrice;
   
   RefreshRates();
   if (Ask < addPositionPrice) {
      double lotsize = calculateLot4AP(countAPLongMaster);
      int newTicket = createOrderBuy(masterSymbol, lotsize);
      if (-1 < newTicket) {
         countAPLongMaster++;
         ticketsMaster[0][countAPLongMaster] = newTicket;
         return true;
      }
      return true;
   }
   
   return false;
}

bool addPosition4SellMaster() {
   if (countAPShortMaster < 0) {
      return false;
   }
   
   if (maxAPtimes <= countAPShortMaster) {
      return false;
   }
   
   int ticketId = ticketsMaster[1][countAPShortMaster];
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   if (!isSelected) {
      return false;
   }
   double maxOpenPrice = OrderOpenPrice();
   
   double addPositionPrice = maxOpenPrice + gridPrice;
   
   RefreshRates();
   if (addPositionPrice < Bid) {
      double lotsize = calculateLot4AP(countAPShortMaster);
      int newTicket = createOrderSell(masterSymbol, lotsize);
      if (-1 < newTicket) {
         countAPShortMaster++;
         ticketsMaster[1][countAPShortMaster] = newTicket;
         return true;
      }
      
   }
   
   return false;
}

bool addPosition4BuySlave() {
   if (countAPShortSlave < 0) {
      return false;
   }
   
   if (maxAPtimes <= countAPShortSlave) {
      return false;
   }
   if (countAPShortSlave < countAPLongMaster) {
      double lotsize = calculateLot4AP(countAPShortSlave);
      int newTicket = createOrderSell(slaveSymbol, lotsize);
      if (-1 < newTicket) {
         countAPShortSlave++;
         ticketsSlave[0][countAPShortSlave] = newTicket;
         return true;
      }
   }

   return false;
}

bool addPosition4SellSlave() {
   if (countAPLongSlave < 0) {
      return false;
   }
   
   if (maxAPtimes <= countAPLongSlave) {
      return false;
   }
   if (countAPLongSlave < countAPShortMaster) {
      double lotsize = calculateLot4AP(countAPLongSlave);
      int newTicket = createOrderBuy(slaveSymbol, lotsize);
      if (-1 < newTicket) {
         countAPLongSlave++;
         ticketsSlave[1][countAPLongSlave] = newTicket;
         return true;
      }
   }

   return false;
}

bool isEntryMaster(int orderType) {
   if (!isActive) {
      return false;
   }
   
   int ticketIdMaster;
   int ticketIdSlave;
   
   if (OP_BUY == orderType) {
      ticketIdMaster = ticketsMaster[0][0];
      ticketIdSlave = ticketsSlave[0][0];
   } else if (OP_SELL == orderType) {
      ticketIdMaster = ticketsMaster[1][0];
      ticketIdSlave = ticketsSlave[1][0];
   } else {
      return false;
   }
   if (ticketIdMaster < 0) {
   
      if (ticketIdSlave < 0) {
         return true;
      }
      
      bool isSelected = OrderSelect(ticketIdSlave, SELECT_BY_TICKET);
      if (isSelected) {
         datetime ctm = OrderCloseTime();
         if (0 < ctm) {
            return true;
         }
      }
      
   } else {
      bool isSelected = OrderSelect(ticketIdMaster, SELECT_BY_TICKET);
      if (isSelected) {
         datetime ctm = OrderCloseTime();
         if (0 < ctm) {
            if (ticketIdSlave < 0) {
               return true;   
            }
            
            isSelected = OrderSelect(ticketIdSlave, SELECT_BY_TICKET);
            if (isSelected) {
               ctm = OrderCloseTime();
               if (0 < ctm) {
                  return true;
               }
            }
         }
      }
   }
   
   
   return false;
}

bool isEntrySlave(int orderType) {
   if (!isActive) {
      return false;
   }
   
   int ticketIdMaster;
   int ticketIdSlave;
   
   if (OP_BUY == orderType) {
      ticketIdMaster = ticketsMaster[0][0];
      ticketIdSlave = ticketsSlave[0][0];
   } else if (OP_SELL == orderType) {
      ticketIdMaster = ticketsMaster[1][0];
      ticketIdSlave = ticketsSlave[1][0];
   } else {
      return false;
   }
   
   if (ticketIdMaster < 0) {
      return false;
   }
   
   bool isSelected = OrderSelect(ticketIdMaster, SELECT_BY_TICKET);
   if (isSelected) {
      datetime ctm = OrderCloseTime();
      if (0 < ctm) {
         return false;
      }
      if (ticketIdSlave < 0) {
         return true;
      }
      isSelected = OrderSelect(ticketIdSlave, SELECT_BY_TICKET);
      if (isSelected) {
         ctm = OrderCloseTime();
         if (0 < ctm) {
            return true;
         }
      }
   }

   return false;
}


int createOrderBuy(string symbol, double lotSize) {
   
   int chkBuy  = OrderSend(symbol, OP_BUY , lotSize, Ask, 0, 0, 0, "", MagicNumber, 0, clrBlue);
   
   if (-1 == chkBuy) {
      string msg = "BUY " + symbol + " OrderSend failed in createOrderBuy. Error:" + ErrorDescription(GetLastError());
      msg += " Ask=" + DoubleToStr(Ask, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
   }
   
   return chkBuy;
}

int createOrderSell(string symbol, double lotSize) {
   
   int chkSell = OrderSend(symbol, OP_SELL, lotSize, Bid, 0, 0, 0, "", MagicNumber, 0, clrRed);
   
   if (-1 == chkSell) {
      string msg = "SELL " + symbol + " OrderSend failed in createOrderSell. Error:" + ErrorDescription(GetLastError());
      msg += " Bid=" + DoubleToStr(Bid, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
   }
   
   return chkSell;
}

void OnTimer() {

}

double OnTester() {

   double ret=0.0;

   return(ret);
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
      
   }
}

string symbolEnum2String(enSymbol symbolName) {
   switch(symbolName) {
      case EURUSD : return SymbolPrifix+"EURUSD"+SymbolSuffix;
      case USDJPY : return SymbolPrifix+"USDJPY"+SymbolSuffix;
      case GBPUSD : return SymbolPrifix+"GBPUSD"+SymbolSuffix;
      case AUDUSD : return SymbolPrifix+"AUDUSD"+SymbolSuffix;
      case USDCHF : return SymbolPrifix+"USDCHF"+SymbolSuffix;
      case USDCAD : return SymbolPrifix+"USDCAD"+SymbolSuffix;
      case NZDUSD : return SymbolPrifix+"NZDUSD"+SymbolSuffix;
      case XAGUSD : return SymbolPrifix+"XAGUSD"+SymbolSuffix;
      case XAUUSD : return SymbolPrifix+"XAUUSD"+SymbolSuffix;
      case EURJPY : return SymbolPrifix+"EURJPY"+SymbolSuffix;
      case EURGBP : return SymbolPrifix+"EURGBP"+SymbolSuffix;
      case EURAUD : return SymbolPrifix+"EURAUD"+SymbolSuffix;
      case EURCHF : return SymbolPrifix+"EURCHF"+SymbolSuffix;
      case EURCAD : return SymbolPrifix+"EURCAD"+SymbolSuffix;
      case EURNZD : return SymbolPrifix+"EURNZD"+SymbolSuffix;
      case GBPJPY : return SymbolPrifix+"GBPJPY"+SymbolSuffix;
      case AUDJPY : return SymbolPrifix+"AUDJPY"+SymbolSuffix;
      case CHFJPY : return SymbolPrifix+"CHFJPY"+SymbolSuffix;
      case CADJPY : return SymbolPrifix+"CADJPY"+SymbolSuffix;
      case NZDJPY : return SymbolPrifix+"NZDJPY"+SymbolSuffix;
      case GBPAUD : return SymbolPrifix+"GBPAUD"+SymbolSuffix;
      case GBPCHF : return SymbolPrifix+"GBPCHF"+SymbolSuffix;
      case GBPCAD : return SymbolPrifix+"GBPCAD"+SymbolSuffix;
      case GBPNZD : return SymbolPrifix+"GBPNZD"+SymbolSuffix;
      case AUDCHF : return SymbolPrifix+"AUDCHF"+SymbolSuffix;
      case AUDCAD : return SymbolPrifix+"AUDCAD"+SymbolSuffix;
      case AUDNZD : return SymbolPrifix+"AUDNZD"+SymbolSuffix;
      case CADCHF : return SymbolPrifix+"CADCHF"+SymbolSuffix;
      case NZDCHF : return SymbolPrifix+"NZDCHF"+SymbolSuffix;
      case NZDCAD : return SymbolPrifix+"NZDCAD"+SymbolSuffix;
      case USDCNH : return SymbolPrifix+"USDCNH"+SymbolSuffix;
      default : return "";
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
                  long              z_order=0)   export        // priority for mouse click
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

void PressButton(string ctlName) {
   bool selected = ObjectGetInteger(ChartID(), ctlName, OBJPROP_STATE);
   if (selected) {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, false);
   } else {
      ObjectSetInteger(ChartID(), ctlName, OBJPROP_STATE, true);
   }
}

void stopEA() {
   closeBuy();
   closeSell();
   isActive = false;
   ObjectSetString(0, nmBtnStopResume, OBJPROP_TEXT, txtBtnResume);
   ObjectSetInteger(0,nmBtnStopResume, OBJPROP_BGCOLOR, color4BtnResume);
}

void resumeEA() {
   isActive = true;
   
   ObjectSetString(0, nmBtnStopResume, OBJPROP_TEXT, txtBtnStop);
   ObjectSetInteger(0,nmBtnStopResume, OBJPROP_BGCOLOR, color4BtnStop);
}

void SetComments() {
   string space = "                             ";
   string CrLf = "\n";
   string Cmt = "";
   
   //Cmt += CrLf;
   //Cmt += CrLf;
   Cmt += CrLf;

   Cmt += space + "Buy Profit = " + DoubleToStr(calculateProfitBuy(), 2);
   Cmt += "     " + "Sell Profit = " + DoubleToStr(calculateProfitSell(), 2) + CrLf;
   
   //Cmt += CrLf;
   Cmt += space + "Buy AP Times = " + IntegerToString(countAPLongMaster);
   Cmt += "     " + "Sell AP Times = " + IntegerToString(countAPShortMaster);

   Comment(Cmt);
}
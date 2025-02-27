//+------------------------------------------------------------------+
//|                                             Dashboard_EA_1.0.mq4 |
//|Copyright 2018～2019, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Gao Zeng.QQ--183947281,mail--soko8@sina.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <OrderInfo.mqh>
#include <Arrays\List.mqh>
#include <DrawObjects.mqh>
#include <Utils.mqh>


//--- input parameters
input int      Input1=2;
input bool     Input2=false;
input string   Input3;
input float    Input4=1.0;
input datetime Input5=D'2017.03.31 11:33:50';
input color    Input6=clrMediumOrchid;

input int            TP_Pips = 0;
input int            SL_Pips = 0;
input int            MagicNumber=586;
input string         SymbolPrefix="";
input string         SymbolSuffix="";
input string         Symbols = "";

      int      TP = 0;
      int      SL = 0;

      bool     IsAutoTrade = false;
      int      SymbolCount = 0;
      int      ColumnCount = 0;
      CList   *OrdersLong[];
      CList   *OrdersShort[];

//const string   L = "l";
//const string   S = "s";

const int      IndexH         = 0;
const int      IndexD         = 1;
const int      IndexSymbol    = 2;
const int      IndexLLots     = 3;
const int      IndexLOUp      = 4;
const int      IndexLOrders   = 5;
const int      IndexLODn      = 6;
const int      IndexLProfit   = 7;
const int      IndexLC        = 8;
const int      IndexTotal     = 9;
const int      IndexSLots     = 10;
const int      IndexSOUp      = 11;
const int      IndexSOrders   = 12;
const int      IndexSODn      = 13;
const int      IndexSProfit   = 14;
const int      IndexSC        = 15;

const string   defaultSymbols = "EURUSD,USDJPY,GBPUSD,AUDUSD,USDCHF,USDCAD,NZDUSD,EURJPY,EURGBP,EURAUD,EURCHF,EURCAD,EURNZD,GBPJPY,AUDJPY,CHFJPY,CADJPY,NZDJPY,GBPAUD,GBPCHF,GBPCAD,GBPNZD,AUDCHF,AUDCAD,AUDNZD,CADCHF,NZDCHF,NZDCAD";
      string   SymbolArray[] = {};
/*
const string         SymbolArray[] = {"EURUSD"
                                    , "USDJPY"
                                    , "GBPUSD"
                                    , "AUDUSD"
                                    , "USDCHF"
                                    , "USDCAD"
                                    , "NZDUSD"
                                    , "EURJPY"
                                    , "EURGBP"
                                    , "EURAUD"
                                    , "EURCHF"
                                    , "EURCAD"
                                    , "EURNZD"
                                    , "GBPJPY"
                                    , "AUDJPY"
                                    , "CHFJPY"
                                    , "CADJPY"
                                    , "NZDJPY"
                                    , "GBPAUD"
                                    , "GBPCHF"
                                    , "GBPCAD"
                                    , "GBPNZD"
                                    , "AUDCHF"
                                    , "AUDCAD"
                                    , "AUDNZD"
                                    , "CADCHF"
                                    , "NZDCHF"
                                    , "NZDCAD"
                                     };
*/

const string         header1_text[] = {};

const string         ColumnText[] = {     "H"            // 0
                                       ,  "D"            // 1
                                       ,  "Symbol"       // 2
                                       ,  "LotL"         // 3
                                       ,  "O+"           // 4
                                       ,  "OrderL"       // 5
                                       ,  "O-"           // 6
                                       ,  "ProfitL"       // 7
                                       ,  "CL"           // 8
                                       ,  "Total"        // 9
                                       ,  "LotS"         // 10
                                       ,  "O+"           // 11
                                       ,  "OrderS"       // 12
                                       ,  "O-"           // 13
                                       ,  "ProfitS"       // 14
                                       ,  "CS"           // 15
                                    };
const int            ColumnWidth[] = {    13             // 0
                                       ,  13             // 1
                                       ,  55             // 2
                                       ,  36             // 3
                                       ,  15             // 4
                                       ,  19             // 5
                                       ,  15             // 6
                                       ,  50             // 7
                                       ,  21             // 8
                                       ,  57             // 9
                                       ,  36             // 10
                                       ,  15             // 11
                                       ,  19             // 12
                                       ,  15             // 13
                                       ,  50             // 14
                                       ,  21             // 15
                                     };


/***************** Auto Manual Control button Begin **********/
const string      nmBtnAutoControl        = "AutoControl";
const string      txtBtnAuto              = "Auto";
const string      txtBtnManual            = "Manual";
const color       color4BtnAuto           = clrLightSalmon;
const color       color4BtnManual         = clrLime;
/***************** Auto Manual Control button End   **********/

/*****************  Use Limit Control         Begin **********/
      bool        AccountCtrl = false;
      int         AuthorizeAccountList[4] = {  6154218
                                              ,7100152
                                              ,5015177
                                              ,5330172
                                             };
      bool        EnableUseTimeControl=true;
      datetime    ExpireTime = D'2019.12.31 23:59:59';
/*****************  Use Limit Control         End   **********/

void initSymbols() {
   string symbols_ = Symbols;
   if ("" == symbols_) {
      symbols_ = defaultSymbols;
   }
   ushort u_sep = StringGetCharacter(",", 0);
   SymbolCount = StringSplit(symbols_, u_sep, SymbolArray);
   
}

int OnInit() {
   if (!isAuthorized(AccountCtrl, AuthorizeAccountList)) {
		return INIT_FAILED;
	}
	
   if (isExpire(EnableUseTimeControl, ExpireTime)) {
      return INIT_FAILED;
   }

   TP = TP_Pips;
   SL = SL_Pips;

   initSymbols();
   //SymbolCount = ArraySize(SymbolArray);
   ColumnCount = ArraySize(ColumnText);
   
   RectLabelCreate("rl_bg", 0, 0, 800, 700);
   
   ButtonCreate(nmBtnAutoControl, txtBtnAuto, 7, 2, 80, 18, color4BtnAuto, 10, clrBlack, "Lucida Bright", clrGold);
   createHead();
   createData();
   
   initOrders();

   EventSetTimer(1);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll();
   for (int i = 0; i < SymbolCount; i++) {
      //Orders[i].Clear();
      delete OrdersLong[i];
      delete OrdersShort[i];
   }
}

void OnTick() {}

double calculateCloseLot(CList *orderList, int index) {

   return 0.01;
}

bool isConditionCloseBuy(OrderInfo *orderInfo) {

   return false;
}

bool isConditionCloseSell(OrderInfo *orderInfo) {

   return false;
}

bool isOkCloseBuy(OrderInfo *orderInfo) {
   // 止盈时
   if (0 < TP) {
      double vbid = MarketInfo(orderInfo.getSymbolName(), MODE_BID);
      if (orderInfo.getTpPrice() <= vbid) {
         return true;
      }
   }
   
   // 止损时
   if (0 < SL) {
      double vask = MarketInfo(orderInfo.getSymbolName(), MODE_ASK);
      if (vask <= orderInfo.getSlPrice()) {
         return true;
      }
   }
   
   // 满足条件平仓时
   return isConditionCloseBuy(orderInfo);
}

bool isOkCloseSell(OrderInfo *orderInfo) {
   // 止盈时
   if (0 < TP) {
      double vask = MarketInfo(orderInfo.getSymbolName(), MODE_ASK);
      if (vask <= orderInfo.getTpPrice()) {
         return true;
      }
   }
   
   // 止损时
   if (0 < SL) {
      double vbid = MarketInfo(orderInfo.getSymbolName(), MODE_BID);
      if (orderInfo.getSlPrice() <= vbid) {
         return true;
      }
   }
   
   // 满足条件平仓时
   return isConditionCloseSell(orderInfo);
}

void checkOrderLong(CList *orderList) {
   int count = orderList.Total();
   for (int i = count - 1; 0 <= i; i--) {
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      if (isOkCloseBuy(oi)) {
         double lotSize = calculateCloseLot(orderList, i);
         bool isClosed = closeOrderLong(oi, lotSize);
         if (isClosed) {
            orderList.Delete(i);
         }
      }
   }
}

void checkOrderShort(CList *orderList) {
   int count = orderList.Total();
   for (int i = count - 1; 0 <= i; i--) {
      OrderInfo *oi = orderList.GetNodeAtIndex(i);
      if (isOkCloseSell(oi)) {
         double lotSize = calculateCloseLot(orderList, i);
         bool isClosed = closeOrderShort(oi, lotSize);
         if (isClosed) {
            orderList.Delete(i);
         }
      }
   }
}

bool isOkBuy(string symbolName) {

   return true;
}

bool isOkSell(string symbolName) {

   return true;
}

double calculateLot(int index, CList *orderList) {

   return 0.01;
}

void OnTimer() {
   if (!IsAutoTrade) {
      return;
   }

   
   string symbolNm = NULL;
   for (int i = 0; i < SymbolCount; i++) {
      symbolNm = SymbolPrefix+SymbolArray[i]+SymbolSuffix;
      
      CList *ordersL = OrdersLong[i];
      // 检查是否满足开仓条件，满足条件就开仓
      if (0 == ordersL.Total()) {
         if (isOkBuy(symbolNm)) {
            double lotSize = calculateLot(i, OrdersLong[i]);
            OrderInfo *oi = createOrderLong(symbolNm, lotSize);
            if (oi.isValid()) {
               OrdersLong[i].Add(oi);
            }
         }
      } else {
         // 检查止损，止盈，平仓条件
         checkOrderLong(OrdersLong[i]);
      }
      
      CList *ordersS = OrdersShort[i];
      if (0 == ordersS.Total()) {
         if (isOkSell(symbolNm)) {
            double lotSize = calculateLot(i, OrdersShort[i]);
            OrderInfo *oi = createOrderShort(symbolNm, lotSize);
            if (oi.isValid()) {
               OrdersShort[i].Add(oi);
            }
         }
      } else {
         // 检查止损，止盈，平仓条件
         checkOrderShort(OrdersShort[i]);
      }
      
      refreshRow(i);
   }
   
   refreshSumRow();
   
}

void refreshRow(int index) {
   /*********************** Calculate Long Begin  **********************************/
   CList *listL = OrdersLong[index];
   double lotsL = 0.0;
   double profitL = 0.0;
   int orderCntL = listL.Total();
   bool isSelected = false;
   for (int i = orderCntL - 1; 0 <= i; i--) {
      OrderInfo *oi = listL.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();
      
      isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         string msg = "OrderSelect failed in refreshRow.";
         msg = msg + " Error:【" + ErrorDescription(GetLastError());
         msg = msg + "】 Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
         
         // 检查是否已经平仓(止损或者止盈时)
         isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
         if (isSelected) {
            if (0 < OrderCloseTime()) {
               listL.Delete(i);
            }
         }
         continue;
      }
      
      lotsL += OrderLots();
      
      profitL += OrderProfit();
      profitL += OrderCommission();
      profitL += OrderSwap();
      
   }
   /*********************** Calculate Long End    **********************************/
   
   /*********************** Calculate Short Begin **********************************/
   CList *listS = OrdersShort[index];
   double lotsS = 0.0;
   double profitS = 0.0;
   int orderCntS = listS.Total();
   isSelected = false;
   for (int i = orderCntS - 1; 0 <= i; i--) {
      OrderInfo *oi = listS.GetNodeAtIndex(i);
      int ticketId = oi.getTicketId();

      isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         string msg = "OrderSelect failed in refreshRow.";
         msg = msg + " Error:【" + ErrorDescription(GetLastError());
         msg = msg + "】 Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
         
         // 检查是否已经平仓(止损或者止盈时)
         isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
         if (isSelected) {
            if (0 < OrderCloseTime()) {
               listS.Delete(i);
            }
         }
         continue;
      }
      
      lotsS += OrderLots();
      
      profitS += OrderProfit();
      profitS += OrderCommission();
      profitS += OrderSwap();
      
   }
   /*********************** Calculate Short End   **********************************/
   string symbolNm = SymbolArray[index];
   int fontSize = 6;
   string fontName = "Arial";
   color bgColor = clrBlack;
   color fontColor = clrWhite;
   
   if (0 < orderCntL) {
      if (0 < profitL) {
         bgColor = clrLime;
         fontColor = clrBlack;
      } else if (profitL < 0) {
         bgColor = clrMaroon;
         fontColor = clrWhite;
      }
      ObjectSetText(symbolNm+ColumnText[IndexLLots], DoubleToStr(lotsL, 2), fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexLOrders], IntegerToString(orderCntL), fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexLProfit], DoubleToStr(profitL, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText(symbolNm+ColumnText[IndexLLots], "", fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexLOrders], "", fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexLProfit], "", fontSize, fontName, fontColor);
   }
   
   ObjectSetInteger(0, "rl"+symbolNm+ColumnText[IndexLLots], OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, symbolNm+ColumnText[IndexLLots], OBJPROP_COLOR, fontColor);
   ObjectSetInteger(0, "rl"+symbolNm+ColumnText[IndexLOrders], OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, symbolNm+ColumnText[IndexLOrders], OBJPROP_COLOR, fontColor);
   ObjectSetInteger(0, "rl"+symbolNm+ColumnText[IndexLProfit], OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, symbolNm+ColumnText[IndexLProfit], OBJPROP_COLOR, fontColor);

   
   bgColor = clrBlack;
   fontColor = clrWhite;
   if (0 < orderCntS) {
      if (0 < profitS) {
         bgColor = clrLime;
         fontColor = clrBlack;
      } else if (profitS < 0) {
         bgColor = clrMaroon;
         fontColor = clrWhite;
      }
      ObjectSetText(symbolNm+ColumnText[IndexSLots], DoubleToStr(lotsS, 2), fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexSOrders], IntegerToString(orderCntS), fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexSProfit], DoubleToStr(profitS, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText(symbolNm+ColumnText[IndexSLots], "", fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexSOrders], "", fontSize, fontName, fontColor);
      ObjectSetText(symbolNm+ColumnText[IndexSProfit], "", fontSize, fontName, fontColor);
   }
   
   ObjectSetInteger(0, "rl"+symbolNm+ColumnText[IndexSLots], OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, symbolNm+ColumnText[IndexSLots], OBJPROP_COLOR, fontColor);
   ObjectSetInteger(0, "rl"+symbolNm+ColumnText[IndexSOrders], OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, symbolNm+ColumnText[IndexSOrders], OBJPROP_COLOR, fontColor);
   ObjectSetInteger(0, "rl"+symbolNm+ColumnText[IndexSProfit], OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, symbolNm+ColumnText[IndexSProfit], OBJPROP_COLOR, fontColor);


   bgColor = clrBlack;
   fontColor = clrWhite;
   if (0 < (orderCntL+orderCntS)) {
      double totalProfit = profitL + profitS;
      if (0 < totalProfit) {
         fontColor = clrLime;
      } else if (totalProfit < 0) {
         fontColor = clrLightPink;
      }
      ObjectSetText(symbolNm+ColumnText[IndexTotal], DoubleToStr(totalProfit, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText(symbolNm+ColumnText[IndexTotal], "", fontSize, fontName, fontColor);
   }

}

void refreshSumRow() {
   double sumLotL = 0.0;
   long sumOrderL = 0;
   double sumProfitL = 0.0;
   double sumTotal = 0.0;
   double sumLotS = 0.0;
   long sumOrderS = 0;
   double sumProfitS = 0.0;
   
   string symbolNm = NULL;
   string temp = NULL;
   for (int i = 0; i < SymbolCount; i++) {
      symbolNm = SymbolArray[i];
      temp = ObjectGetString(0, symbolNm+ColumnText[IndexLLots], OBJPROP_TEXT);
      if ("" != temp) {
         sumLotL += StringToDouble(temp);
      }
      
      temp = ObjectGetString(0, symbolNm+ColumnText[IndexLOrders], OBJPROP_TEXT);
      if ("" != temp) {
         sumOrderL += StringToInteger(temp);
      }
      
      temp = ObjectGetString(0, symbolNm+ColumnText[IndexLProfit], OBJPROP_TEXT);
      if ("" != temp) {
         sumProfitL += StringToDouble(temp);
      }
      
      /*
      temp = ObjectGetString(0, symbolNm+ColumnText[IndexTotal], OBJPROP_TEXT);
      if ("" != temp) {
         sumTotal += DoubleToStr(temp);
      }
      */
      
      temp = ObjectGetString(0, symbolNm+ColumnText[IndexSLots], OBJPROP_TEXT);
      if ("" != temp) {
         sumLotS += StringToDouble(temp);
      }
      
      temp = ObjectGetString(0, symbolNm+ColumnText[IndexSOrders], OBJPROP_TEXT);
      if ("" != temp) {
         sumOrderS += StringToInteger(temp);
      }
      
      temp = ObjectGetString(0, symbolNm+ColumnText[IndexSProfit], OBJPROP_TEXT);
      if ("" != temp) {
         sumProfitS += StringToDouble(temp);
      }
   }
   
   int fontSize = 8;
   string fontName = "Arial";
   color fontColor = clrBlack;
   if (0 < (sumOrderL)) {
      if (0 < sumProfitL) {
         fontColor = clrLime;
      } else if (sumProfitL < 0) {
         fontColor = clrRed;
      }
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexLLots], DoubleToStr(sumLotL, 2), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexLOrders], IntegerToString(sumOrderL), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexLProfit], DoubleToStr(sumProfitL, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexLLots], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexLOrders], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexLProfit], "", fontSize, fontName, fontColor);
   }
   
   fontColor = clrBlack;
   if (0 < (sumOrderS)) {
      if (0 < sumProfitS) {
         fontColor = clrLime;
      } else if (sumProfitS < 0) {
         fontColor = clrRed;
      }
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexSLots], DoubleToStr(sumLotS, 2), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexSOrders], IntegerToString(sumOrderS), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexSProfit], DoubleToStr(sumProfitS, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexSLots], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexSOrders], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexSProfit], "", fontSize, fontName, fontColor);
   }
   
   fontColor = clrBlack;
   if (0 < (sumOrderL+sumOrderS)) {
      sumTotal = sumProfitL + sumProfitS;
      if (0 < sumTotal) {
         fontColor = clrLime;
      } else if (sumTotal < 0) {
         fontColor = clrRed;
      }
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexTotal], DoubleToStr(sumTotal, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText("sum_"+symbolNm+ColumnText[IndexTotal], "", fontSize, fontName, fontColor);
   }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string btnNm = NULL;
      if (nmBtnAutoControl == sparam) {
         printf("手动自动控制按钮被按下");
         if (IsAutoTrade) {
            IsAutoTrade = false;
            //SetComments();
            ObjectSetString(0, nmBtnAutoControl, OBJPROP_TEXT, txtBtnAuto);
            //ObjectSetInteger(0,nmBtnAutoControl, OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0,nmBtnAutoControl, OBJPROP_BGCOLOR, color4BtnAuto);
         } else {
            IsAutoTrade = true;
            ObjectSetString(0, nmBtnAutoControl, OBJPROP_TEXT, txtBtnManual);
            //ObjectSetInteger(0,nmBtnAutoControl, OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0,nmBtnAutoControl, OBJPROP_BGCOLOR, color4BtnManual);
         }
         //PressButton(nmBtnAutoControl);
         btnNm = nmBtnAutoControl;
      } else {
         
         string symbolNm = NULL;
         for (int i = 0; i < SymbolCount; i++) {
            symbolNm = SymbolArray[i];
            // H按钮被按下时
            if ((symbolNm+ColumnText[IndexH]) == sparam) {
               // TODO
               printf("货币对"+ symbolNm + "的H按钮被按下");
               btnNm = symbolNm+ColumnText[IndexH];
            }
            
            // D按钮被按下时
            else if ((symbolNm+ColumnText[IndexD]) == sparam) {
               printf("货币对"+ symbolNm + "的D按钮被按下");
               btnNm = symbolNm+ColumnText[IndexD];
            }
            
            // 货币对按钮被按下时
            else if ((symbolNm+ColumnText[IndexSymbol]) == sparam) {
               // TODO
               printf("货币对"+ symbolNm + "按钮被按下");
               long chartId = ChartOpen(SymbolPrefix+symbolNm+SymbolSuffix, PERIOD_H1);
               if (0 == chartId) {
                  string msg = "Failed in ChartOpen. Error:【" + ErrorDescription(GetLastError()) + "】";
                  Alert(msg);
               } else {
                  ChartApplyTemplate(chartId, "Clean");
               }
               btnNm = symbolNm+ColumnText[IndexSymbol];
            }
            
            // 多头加仓按钮被按下时
            else if ((symbolNm+"L"+ColumnText[IndexLOUp]) == sparam) {
               printf("货币对"+ symbolNm + "的多头加仓按钮被按下");
               btnNm = symbolNm+"L"+ColumnText[IndexLOUp];
            }
            
            // 多头减仓按钮被按下时
            else if ((symbolNm+"L"+ColumnText[IndexLODn]) == sparam) {
               printf("货币对"+ symbolNm + "的多头减仓按钮被按下");
               btnNm = symbolNm+"L"+ColumnText[IndexLODn];
            }
            
            // 多头清仓按钮被按下时
            else if ((symbolNm+ColumnText[IndexLC]) == sparam) {
               printf("货币对"+ symbolNm + "的多头清仓按钮被按下");
               btnNm = symbolNm+ColumnText[IndexLC];
               CList *orderList = OrdersLong[i];
               int count = orderList.Total();
               for (int m = count - 1; 0 <= m; m--) {
                  closeOrderLong(orderList.GetNodeAtIndex(m));
               }
               orderList.Clear();
            }
            
            // 空头加仓按钮被按下时
            else if ((symbolNm+"S"+ColumnText[IndexSOUp]) == sparam) {
               printf("货币对"+ symbolNm + "的空头加仓按钮被按下");
               btnNm = symbolNm+"S"+ColumnText[IndexSOUp];
            }
            
            // 空头减仓按钮被按下时
            else if ((symbolNm+"S"+ColumnText[IndexSODn]) == sparam) {
               printf("货币对"+ symbolNm + "的空头减仓按钮被按下");
               btnNm = symbolNm+"S"+ColumnText[IndexSODn];
            }
            
            // 空头清仓按钮被按下时
            else if ((symbolNm+ColumnText[IndexSC]) == sparam) {
               printf("货币对"+ symbolNm + "的空头清仓按钮被按下");
               btnNm = symbolNm+ColumnText[IndexSC];
               CList *orderList = OrdersShort[i];
               int count = orderList.Total();
               for (int m = count - 1; 0 <= m; m--) {
                  closeOrderShort(orderList.GetNodeAtIndex(m));
               }
               orderList.Clear();
            }
         }// end for
      }// end else
   }// end CHARTEVENT_OBJECT_CLICK
   
}

OrderInfo *createOrderLong(string symbolName, double lotSize) {
   OrderInfo *oi = new OrderInfo;
   
   RefreshRates();
   int vdigits = (int) MarketInfo(symbolName, MODE_DIGITS);
   double vpoint  = MarketInfo(symbolName, MODE_POINT);
   double vask = MarketInfo(symbolName, MODE_ASK);
   
   double slPrice = 0.0;
   if (0 < SL) {
      slPrice = NormalizeDouble(10*vpoint*SL, vdigits);
      slPrice = vask - slPrice;
   }
   
   double tpPrice = 0.0;
   if (0 < TP) {
      tpPrice = NormalizeDouble(10*vpoint*TP, vdigits);
      tpPrice = vask + tpPrice;
   }
   
   int ticketId  = OrderSend(symbolName, OP_BUY , lotSize, vask, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (-1 == ticketId) {
      string msg = "BUY OrderSend failed in createOrderLong. Error:【" + ErrorDescription(GetLastError());
      msg += "】 Ask=" + DoubleToStr(vask, vdigits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return oi;
   }
   
   oi.setValid(true);
   oi.setTicketId(ticketId);
   oi.setOperationType(OP_BUY);
   oi.setSymbolName(symbolName);
   
   if (OrderSelect(ticketId, SELECT_BY_TICKET)) {
      oi.setOpenPrice(OrderOpenPrice());
      oi.setLotSize(OrderLots());
      oi.setTpPrice(OrderTakeProfit());
      oi.setSlPrice(OrderStopLoss());
   } else {
      string msg = "OrderSelect failed in createOrderLong.";
      msg = msg + " Error:【" + ErrorDescription(GetLastError());
      msg = msg + "】 Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
   }
   
   return oi;
}

OrderInfo *createOrderShort(string symbolName, double lotSize) {
   OrderInfo *oi = new OrderInfo;
   
   RefreshRates();
   int vdigits = (int) MarketInfo(symbolName, MODE_DIGITS);
   double vpoint  = MarketInfo(symbolName, MODE_POINT);
   double vbid = MarketInfo(symbolName, MODE_BID);
   
   double slPrice = 0.0;
   if (0 < SL) {
      slPrice = NormalizeDouble(10*vpoint*SL, vdigits);
      slPrice = vbid + slPrice;
   }
   
   double tpPrice = 0.0;
   if (0 < TP) {
      tpPrice = NormalizeDouble(10*vpoint*TP, vdigits);
      tpPrice = vbid - tpPrice;
   }
   
   int ticketId  = OrderSend(symbolName, OP_SELL , lotSize, vbid, 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
   
   if (-1 == ticketId) {
      string msg = "Sell OrderSend failed in createOrderShort. Error:【" + ErrorDescription(GetLastError());
      msg += "】 Bid=" + DoubleToStr(vbid, vdigits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return oi;
   }
   
   oi.setValid(true);
   oi.setTicketId(ticketId);
   oi.setOperationType(OP_SELL);
   oi.setSymbolName(symbolName);
   
   if (OrderSelect(ticketId, SELECT_BY_TICKET)) {
      oi.setOpenPrice(OrderOpenPrice());
      oi.setLotSize(OrderLots());
      oi.setTpPrice(OrderTakeProfit());
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
      
      // 检查是否已经平仓(止损或者止盈时)
      isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
      if (isSelected) {
         if (0 < OrderCloseTime()) {
            return true;
         }
      }
      
      return false;
   }
   
   RefreshRates();
   double vbid = MarketInfo(OrderSymbol(), MODE_BID);
   if (lotSize < 0.01) {
      lotSize = OrderLots();
   }
   bool isClosed = OrderClose(OrderTicket(), lotSize, vbid, 0);
   if (!isClosed) {
      string msg = "OrderClose failed in closeOrderLong. Error:【" + ErrorDescription(GetLastError());
      msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
      msg += " Bid=" + DoubleToStr(vbid, vdigits);
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
      
      // 检查是否已经平仓(止损或者止盈时)
      isSelected = OrderSelect(ticketId, SELECT_BY_TICKET, MODE_HISTORY);
      if (isSelected) {
         if (0 < OrderCloseTime()) {
            return true;
         }
      }
      
      return false;
   }
   
   RefreshRates();
   double vask = MarketInfo(OrderSymbol(), MODE_ASK);
   if (lotSize < 0.01) {
      lotSize = OrderLots();
   }
   bool isClosed = OrderClose(OrderTicket(), lotSize, vask, 0);
   if (!isClosed) {
      string msg = "OrderClose failed in closeOrderShort. Error:【" + ErrorDescription(GetLastError());
      msg += "】 OrderTicket=" + IntegerToString(OrderTicket());
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      int vdigits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
      msg += " Ask=" + DoubleToStr(vask, vdigits);
      Alert(msg);
   }
   
   return isClosed;
}

void initOrders() {
   ArrayResize(OrdersLong, SymbolCount);
   ArrayResize(OrdersShort, SymbolCount);
   for (int i = 0; i < SymbolCount; i++) {
      OrdersLong[i] = new CList;
      OrdersShort[i] = new CList;
   }
}

void createHead() {
   int paddingX = 2;
   int x = 1;
   int y = 1;
   int height = 20;
   int txtFontSize = 8;
   color bgColor = clrHoneydew;
   color fontColor = clrBlack;
   
   // Lots
   x += 87;
   RectLabelCreate("rl_H_"+ColumnText[3], x, y, ColumnWidth[3], height, bgColor);
   SetText("H_"+ColumnText[3], ColumnText[3], x+3, y+1, txtFontSize, fontColor);
   
   // Orders
   x += ColumnWidth[3]+paddingX;
   RectLabelCreate("rl_H_"+ColumnText[5], x, y, ColumnWidth[4]+ColumnWidth[5]+ColumnWidth[6]+2*paddingX, height, bgColor);
   SetText("H_"+ColumnText[5], ColumnText[5], x+3, y+1, txtFontSize, fontColor);
   
   // ProfitL
   x += ColumnWidth[4]+ColumnWidth[5]+ColumnWidth[6]+2*paddingX+paddingX;
   RectLabelCreate("rl_H_"+ColumnText[7], x, y, ColumnWidth[7]+ColumnWidth[8]+paddingX, height, bgColor);
   SetText("H_"+ColumnText[7], ColumnText[7], x+3, y+1, txtFontSize, fontColor);
   
   
   // Total
   x += ColumnWidth[7]+ColumnWidth[8]+paddingX+paddingX+paddingX*4;
   RectLabelCreate("rl_H_"+ColumnText[9], x, y, ColumnWidth[9], height, bgColor);
   SetText("H_"+ColumnText[9], ColumnText[9], x+3, y+1, txtFontSize, fontColor);
   
   // Lots
   x += ColumnWidth[9]+paddingX+paddingX*4;
   RectLabelCreate("rl_H_"+ColumnText[10], x, y, ColumnWidth[10], height, bgColor);
   SetText("H_"+ColumnText[10], ColumnText[10], x+3, y+1, txtFontSize, fontColor);
   
   // Orders
   x += ColumnWidth[10]+paddingX;
   RectLabelCreate("rl_H_"+ColumnText[12], x, y, ColumnWidth[11]+ColumnWidth[12]+ColumnWidth[13]+2*paddingX, height, bgColor);
   SetText("H_"+ColumnText[12], ColumnText[12], x+3, y+1, txtFontSize, fontColor);
   
   // ProfitS
   x += ColumnWidth[11]+ColumnWidth[12]+ColumnWidth[13]+2*paddingX+paddingX;
   RectLabelCreate("rl_H_"+ColumnText[14], x, y, ColumnWidth[14]+ColumnWidth[15]+paddingX, height, bgColor);
   SetText("H_"+ColumnText[14], ColumnText[14], x+3, y+1, txtFontSize, fontColor);
   
   /***************sum row**************************/
   x = 1;
   x += 87;
   y += height + 4;
   bgColor = clrSnow;
   // Long Lots
   RectLabelCreate("rl_sum_"+ColumnText[3], x, y, ColumnWidth[3]+ColumnWidth[4]+paddingX, height, bgColor);
   SetText("sum_"+ColumnText[3], "999.99", x+2, y+1, txtFontSize);
   
   // Long Orders
   x += ColumnWidth[3]+ColumnWidth[4]+2*paddingX;
   RectLabelCreate("rl_sum_"+ColumnText[5], x, y, ColumnWidth[5]+ColumnWidth[6]+paddingX, height, bgColor);
   SetText("sum_"+ColumnText[5], "999", x+4, y+1, txtFontSize);
   
   // Long Profit
   x += ColumnWidth[5]+ColumnWidth[6]+2*paddingX;
   RectLabelCreate("rl_sum_"+ColumnText[7], x, y, ColumnWidth[7]+ColumnWidth[8]+paddingX, height, bgColor);
   SetText("sum_"+ColumnText[7], "99999.99", x+3, y+1, txtFontSize);
   
   // Total
   x += ColumnWidth[7]+ColumnWidth[8]+2*paddingX;
   RectLabelCreate("rl_sum_"+ColumnText[9], x, y, ColumnWidth[9]+8*paddingX, height, bgColor);
   SetText("sum_"+ColumnText[9], "99999.99", x+4, y+1, txtFontSize);
   
   // Short Lots
   x += ColumnWidth[9]+9*paddingX;
   RectLabelCreate("rl_sum_"+ColumnText[10], x, y, ColumnWidth[10]+ColumnWidth[11]+paddingX, height, bgColor);
   SetText("sum_"+ColumnText[10], "999.99", x+2, y+1, txtFontSize);
   
   // Short Orders
   x += ColumnWidth[10]+ColumnWidth[11]+2*paddingX;
   RectLabelCreate("rl_sum_"+ColumnText[12], x, y, ColumnWidth[12]+ColumnWidth[13]+paddingX, height, bgColor);
   SetText("sum_"+ColumnText[12], "999", x+4, y+1, txtFontSize);
   
   // Short Profit
   x += ColumnWidth[12]+ColumnWidth[13]+2*paddingX;
   RectLabelCreate("rl_sum_"+ColumnText[14], x, y, ColumnWidth[14]+ColumnWidth[15]+paddingX, height, bgColor);
   SetText("sum_"+ColumnText[14], "99999.99", x+3, y+1, txtFontSize);
}

void createData() {
   int paddingX = 2;
   int paddingY = 18;
   int x = 1;
   int y = 29 + paddingY;
   
   int height = 16;

   int btnFontSize = 6;
   int txtFontSize = 6;

   string symbolNm = "";
   for (int i = 0; i < SymbolCount; i++) {
      int j = 0;
      symbolNm = SymbolArray[i];
      // 0 H
      x = 1;
      ButtonCreate(symbolNm+ColumnText[j], "H", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 1 D
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+ColumnText[j], "D", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 2 Symbol
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+ColumnText[j], symbolNm, x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 3 Lots
      x += ColumnWidth[j] + paddingX;
      j++;
      RectLabelCreate("rl"+symbolNm+ColumnText[j], x, y+i*paddingY, ColumnWidth[j], height);
      SetText(symbolNm+ColumnText[j], "99.99", x+2, y+i*paddingY, txtFontSize);
      // 4 O+
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+"L"+ColumnText[j], "＋", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 5 Orders
      x += ColumnWidth[j] + paddingX;
      j++;
      RectLabelCreate("rl"+symbolNm+ColumnText[j], x, y+i*paddingY, ColumnWidth[j], height);
      SetText(symbolNm+ColumnText[j], "99", x+2, y+i*paddingY, txtFontSize);
      // 6 O-
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+"L"+ColumnText[j], "－", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 7 Profit
      x += ColumnWidth[j] + paddingX;
      j++;
      RectLabelCreate("rl"+symbolNm+ColumnText[j], x, y+i*paddingY, ColumnWidth[j], height);
      SetText(symbolNm+ColumnText[j], "9999.99", x+2, y+i*paddingY, txtFontSize);
      // 8 CL
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+ColumnText[j], "CL", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 9 Total
      x += ColumnWidth[j] + paddingX + paddingX*4;
      j++;
      RectLabelCreate("rl"+symbolNm+ColumnText[j], x, y+i*paddingY, ColumnWidth[j], height);
      SetText(symbolNm+ColumnText[j], "99999.99", x+2, y+i*paddingY, txtFontSize);
      
      // 10 Lots
      x += ColumnWidth[j] + paddingX + paddingX*4;
      j++;
      RectLabelCreate("rl"+symbolNm+ColumnText[j], x, y+i*paddingY, ColumnWidth[j], height);
      SetText(symbolNm+ColumnText[j], "99.99", x+2, y+i*paddingY, txtFontSize);
      // 11 O+
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+"S"+ColumnText[j], "＋", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 12 Orders
      x += ColumnWidth[j] + paddingX;
      j++;
      RectLabelCreate("rl"+symbolNm+ColumnText[j], x, y+i*paddingY, ColumnWidth[j], height);
      SetText(symbolNm+ColumnText[j], "99", x+2, y+i*paddingY, txtFontSize);
      // 13 O-
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+"S"+ColumnText[j], "－", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      // 14 Profit
      x += ColumnWidth[j] + paddingX;
      j++;
      RectLabelCreate("rl"+symbolNm+ColumnText[j], x, y+i*paddingY, ColumnWidth[j], height);
      SetText(symbolNm+ColumnText[j], "9999.99", x+2, y+i*paddingY, txtFontSize);
      // 15 CS
      x += ColumnWidth[j] + paddingX;
      j++;
      ButtonCreate(symbolNm+ColumnText[j], "CS", x, y+i*paddingY, ColumnWidth[j], height, clrLavender, btnFontSize, clrBlack);
      
   }
}


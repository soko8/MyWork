//+------------------------------------------------------------------+
//|                                               SuperSkyNet_EA.mq4 |
//|                  Copyright 2018～2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Zeng Gao(QQ:183947281). 电脑配置-->OS: Windows10  分辨率: 1920X1080"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <OrderInfo.mqh>
#include <Arrays\List.mqh>
#include <DrawObjects.mqh>
#include <Utils.mqh>

class SymbolInfo : public CObject {
private:

protected:
   string            symbolName;          // 货币对名
   bool              disabled;            // 禁用启用标志
   int               grid;                // 距离点数       未使用
   double            gridPrice;           // 距离价         未使用
   int               retrace;             // 回调点数       未使用
   double            retracePrice;        // 回调价         未使用
   int               apGrid;              // 加仓距离点数   未使用
   double            apGridPrice;         // 加仓距离价     未使用
   int               tp;                  // 止盈点数       未使用
   double            tpPrice;             // 止盈价         未使用
   int               sl;                  // 止损点数       未使用
   double            slPrice;             // 止损价         未使用

public:
                     SymbolInfo() {disabled = false;}
                    ~SymbolInfo() {}

   void              setSymbolName(string symbolNm)   { symbolName = symbolNm;}
   string            getSymbolName(void)        const { return(symbolName);   }
   
   void              setDisabled(bool disable)        { disabled = disable;   }
   bool              isDisabled(void)           const { return(disabled);     }
   
   void              setGrid(int pips)                { grid = pips;          }
   int               getGrid(void)              const { return(grid);         }

   void              setGridPrice(double price)       { gridPrice = price;    }
   double            getGridPrice(void)         const { return(gridPrice);    }

   void              setRetrace(int pips)             { retrace = pips;       }
   int               getretrace(void)           const { return(retrace);      }

   void              setRetracePrice(double price)    { retracePrice = price; }
   double            getRetracePrice(void)      const { return(retracePrice); }

   void              setApGrid(int pips)              { apGrid = pips;        }
   int               getApGrid(void)            const { return(apGrid);       }

   void              setApGridPrice(double price)     { apGridPrice = price;  }
   double            getApGridPrice(void)       const { return(apGridPrice);  }

   void              setTp(int pips)                  { tp = pips;            }
   int               getTp(void)                const { return(tp);           }

   void              setTpPrice(double price)         { tpPrice = price;      }
   double            getTpPrice(void)           const { return(tpPrice);      }

   void              setSl(int pips)                  { sl = pips;            }
   int               getSl(void)                const { return(sl);           }
   
   void              setSlPrice(double price)         { slPrice = price;      }
   double            getSlPrice(void)           const { return(slPrice);      }

};

input double         Init_Lot = 0.01;
input int            Grid_Pips = 180;
input int            Retrace_Pips = 60;
input int            TP_Pips = 60;
input int            MagicNumber=586;
input string         SymbolPrefix="";
input string         SymbolSuffix="";
input string         Symbols = "";
input int InpDepth=22;     // Depth
input int InpDeviation=5;  // Deviation
input int InpBackstep=3;   // Backstep

      int      Grid = 0;
      int      Retrace = 0;
      int      TP = 0;
      bool     IsAutoTrade = false;
      int      SymbolCount = 0;
      int      ColumnCount = 0;
      CList   *OrdersLong[];
      CList   *OrdersShort[];
      //double   RuleRetracePrices[];
SymbolInfo    *SymbolArray[] = {};
      int      MaxAPTimes = 0;   // 最大加仓次数
      
// 同一个时间柱不进行开单判断
datetime       timeFlag = 0;

      double   initLot = 0.0;

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

const double         APRuleLot[] = {      0.01           // 0
                                       ,  0.01           // 1
                                       ,  0.03           // 2
                                       ,  0.04           // 3
                                       ,  0.06           // 4
                                       ,  0.12           // 5
                                       ,  0.14           // 6
                                       ,  0.2            // 7
                                       ,  0.25           // 8
                                       ,  0.25           // 9
                                       ,  0.25           // 10
                                       ,  0.34           // 11
                                       ,  0.42           // 12
                                       ,  0.6            // 13
                                       ,  0.00           // 14
                                     };

const int            APRuleGrid[] = {     0              // 0
                                       ,  30             // 1
                                       ,  30             // 2
                                       ,  30             // 3
                                       ,  30             // 4
                                       ,  25             // 5
                                       ,  25             // 6
                                       ,  20             // 7
                                       ,  20             // 8
                                       ,  15             // 9
                                       ,  15             // 10
                                       ,  15             // 11
                                       ,  15             // 12
                                       ,  15             // 13
                                       ,  15             // 14
                                     };
                                     
const int            RuleRetrace[] = {    60             // 0
                                       ,  60             // 1
                                       ,  60             // 2
                                       ,  60             // 3
                                       ,  60             // 4
                                       ,  60             // 5
                                       ,  60             // 6
                                       ,  60             // 7
                                       ,  60             // 8
                                       ,  60             // 9
                                       ,  60             // 10
                                       ,  60             // 11
                                       ,  60             // 12
                                       ,  60             // 13
                                       ,  60             // 14
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
                                              ,5330172
                                             };
      bool        EnableUseTimeControl=true;
      datetime    ExpireTime = D'2019.12.31 23:59:59';
/*****************  Use Limit Control         End   **********/

const string      nmBtnCloseAll           = "CloseAll";

/*
void initRetracePrice() {
   int count = ArraySize(RuleRetrace);
   ArrayResize(RuleRetracePrices, count);
   for (int i = 0; i < count; i++) {
      Alert(SymbolArray[i].getSymbolName() + "     " + RuleRetrace[i]);
      RuleRetracePrices[i] = pips2Price(SymbolArray[i].getSymbolName(), RuleRetrace[i]);
   }
}
*/

void initSymbols() {
   string symbols_ = Symbols;
   if ("" == symbols_) {
      symbols_ = defaultSymbols;
   }
   ushort u_sep = StringGetCharacter(",", 0);
   string symArr[];
   SymbolCount = StringSplit(symbols_, u_sep, symArr);
   ArrayResize(SymbolArray, SymbolCount);
   //Alert("SymbolCount = " + SymbolCount);
   for (int i = 0; i < SymbolCount; i++) {
      SymbolInfo *si = new SymbolInfo;
      si.setSymbolName(SymbolPrefix+symArr[i]+SymbolSuffix);
      si.setDisabled(false);
      si.setGrid(Grid);
      si.setGridPrice(pips2Price(si.getSymbolName() ,Grid));
      si.setRetrace(Retrace);
      si.setRetracePrice(pips2Price(si.getSymbolName(), Retrace));
      si.setTpPrice(pips2Price(si.getSymbolName(), TP));
      //Alert(si.getSymbolName() + "   " + pips2Price(si.getSymbolName(), TP));
      SymbolArray[i] = si;
   }
   
}

int OnInit() {
   if (!isAuthorized(AccountCtrl, AuthorizeAccountList)) {
		return INIT_FAILED;
	}
	
   if (isExpire(EnableUseTimeControl, ExpireTime)) {
      return INIT_FAILED;
   }

   initLot = Init_Lot;
   Grid = Grid_Pips;
   Retrace = Retrace_Pips;
   TP = TP_Pips;
   
   MaxAPTimes = ArraySize(APRuleGrid) - 1;

   initSymbols();
   //initRetracePrice();
   ColumnCount = ArraySize(ColumnText);
   
   RectLabelCreate("rl_bg", 0, 0, 800, 700);
   ButtonCreate(nmBtnAutoControl, txtBtnAuto, 7, 2, 80, 18, color4BtnAuto, 10, clrBlack, "Lucida Bright", clrGold);
   ButtonCreate(nmBtnCloseAll, "Close All", 1, 27, 86, 18, clrMediumBlue, 8, clrWhite, "Lucida Bright", clrGold);
   createHead();
   createData();
   
   initOrders();

   EventSetTimer(1);

   return(INIT_SUCCEEDED);
}

void OnTimer() {
   /*
   if (!IsAutoTrade) {
      return;
   }
   */

   string symbolNm = NULL;
   for (int i = 0; i < SymbolCount; i++) {
   if (IsAutoTrade) {
      bool hasChange = false;
      symbolNm = SymbolArray[i].getSymbolName();
      CList *ordersL = OrdersLong[i];
      RefreshRates();
      if (0 == ordersL.Total()) {
         if (timeFlag != Time[0]) {
            double lotSize = calculateLot();
            if (0.0 < lotSize) {
               if (isOkBuy(symbolNm, i)) {
                  OrderInfo *oi = createOrderLong(symbolNm, lotSize, i);
                  if (oi.isValid()) {
                     OrdersLong[i].Add(oi);
                     hasChange = true;
                  }
               }
            }
         }

      } else {
         hasChange = hasTP_L(symbolNm, ordersL);
         
         if (!hasChange) {
            hasChange = hasAP_L(symbolNm, ordersL, i);
         }
         
         if (!hasChange) {
            hasChange = hasSL_L(symbolNm, ordersL);
         }
      
      }
      
      
      CList *ordersS = OrdersShort[i];
      RefreshRates();
      if (0 == ordersS.Total()) {
         if (timeFlag != Time[0]) {
            double lotSize = calculateLot();
            if (0.0 < lotSize) {
               if (isOkSell(symbolNm, i)) {
                  OrderInfo *oi = createOrderShort(symbolNm, lotSize, i);
                  if (oi.isValid()) {
                     OrdersShort[i].Add(oi);
                     hasChange = true;
                  }
               }
            }
         }

      } else {
      
         hasChange = hasTP_S(symbolNm, ordersS);
         
         if (!hasChange) {
            hasChange = hasAP_S(symbolNm, ordersS, i);
         }
         
         if (!hasChange) {
            hasChange = hasSL_S(symbolNm, ordersS);
         }
      }
   }
      refreshRow(i);
   }
   
   refreshSumRow();
   
   timeFlag = Time[0];
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll();
   for (int i = 0; i < SymbolCount; i++) {
      delete OrdersLong[i];
      delete OrdersShort[i];
      delete SymbolArray[i];
   }
}

void OnTick() {}

bool isOkBuy(string symbolName, int index) {
   if (SymbolArray[index].isDisabled()) {
      return false;
   }
   double val = iCustom(symbolName, 0, "icSuperSkyNet", Grid_Pips, Retrace_Pips, InpDepth, InpDeviation, InpBackstep, 4, 1);
   if (0.0 < val) {
      return true;
   }
   
   return false;
}

bool isOkSell(string symbolName, int index) {
   if (SymbolArray[index].isDisabled()) {
      return false;
   }
   double val = iCustom(symbolName, 0, "icSuperSkyNet", Grid_Pips, Retrace_Pips, InpDepth, InpDeviation, InpBackstep, 5, 1);
   if (0.0 < val) {
      return true;
   }
   
   return false;
}

bool hasTP_L(string symbolNm, CList *orderList) {
   int apCount = orderList.Total();
   OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
   double tpPrice = oi.getTpPrice();
   double vbid = MarketInfo(symbolNm, MODE_BID);
   if (oi.getTpPrice() <= vbid) {
      //Alert("Long TP @" + vbid + " tpPrice=" + oi.getTpPrice());
      bool isClosed = false;
      for (int i = apCount-1; 0<=i; i--) {
         isClosed = closeOrderLong(orderList.GetNodeAtIndex(i));
         if (isClosed) {
            orderList.Delete(i);
         } else {
            Alert("OrdersLong[" + IntegerToString(i) + "] Is Not Closed.");
         }
      }
      return true;
   }
   
   return false;
}

bool hasTP_S(string symbolNm, CList *orderList) {
   int apCount = orderList.Total();
   OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
   double tpPrice = oi.getTpPrice();
   double vask = MarketInfo(symbolNm, MODE_ASK);
   if (vask <= oi.getTpPrice()) {
      //Alert("Short TP @" + vask + " tpPrice=" + oi.getTpPrice());
      bool isClosed = false;
      for (int i = apCount-1; 0<=i; i--) {
         isClosed = closeOrderShort(orderList.GetNodeAtIndex(i));
         if (isClosed) {
            orderList.Delete(i);
         } else {
            Alert("OrdersShort[" + IntegerToString(i) + "] Is Not Closed.");
         }
      }
      return true;
   }
   
   return false;
}

bool hasAP_L(string symbolNm, CList *orderList, int index) {
   int apCount = orderList.Total();
   if (apCount < MaxAPTimes) {
      OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
      double vask = MarketInfo(symbolNm, MODE_ASK);
      double apPrice = pips2Price(symbolNm, APRuleGrid[apCount]);
      if (vask <= oi.getOpenPrice()-apPrice) {
         double lot = calculateAPLot(orderList);
         OrderInfo *oiNew = createOrderLong(symbolNm, lot, index);
         if (oiNew.isValid()) {
            orderList.Add(oiNew);
            return true;
         }
      }
      
   }
   return false;
}

bool hasAP_S(string symbolNm, CList *orderList, int index) {
   int apCount = orderList.Total();
   if (apCount < MaxAPTimes) {
      OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
      double vbid = MarketInfo(symbolNm, MODE_BID);
      double apPrice = pips2Price(symbolNm, APRuleGrid[apCount]);
      if (oi.getOpenPrice()+apPrice <= vbid) {
         double lot = calculateAPLot(orderList);
         OrderInfo *oiNew = createOrderShort(symbolNm, lot, index);
         if (oiNew.isValid()) {
            orderList.Add(oiNew);
            return true;
         }
      }
      
   }
   return false;
}

bool hasSL_L(string symbolNm, CList *orderList) {
   int apCount = orderList.Total();
   if (apCount == MaxAPTimes) {
      OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
      double vask = MarketInfo(symbolNm, MODE_ASK);
      double apPrice = pips2Price(symbolNm, APRuleGrid[apCount]);
      if (vask <= oi.getOpenPrice()-apPrice) {
         //Alert("Long SL @" + vask + " openPrice=" + oi.getOpenPrice() + " apPrice=" + apPrice + " oi.getOpenPrice()-apPrice=" + (oi.getOpenPrice()-apPrice));
         bool isClosed = false;
         for (int i = apCount-1; 0<=i; i--) {
            isClosed = closeOrderLong(orderList.GetNodeAtIndex(i));
            if (isClosed) {
               orderList.Delete(i);
            } else {
               Alert("OrdersLong[" + IntegerToString(i) + "] Is Not Closed.");
            }
         }
         return true;
      
      }
   }
   return false;
}

bool hasSL_S(string symbolNm, CList *orderList) {
   int apCount = orderList.Total();
   if (apCount == MaxAPTimes) {
      OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
      double vbid = MarketInfo(symbolNm, MODE_BID);
      double apPrice = pips2Price(symbolNm, APRuleGrid[apCount]);
      if (oi.getOpenPrice()+apPrice <= vbid) {
         //Alert("Short SL @" + vbid + " openPrice=" + oi.getOpenPrice() + " apPrice=" + apPrice + " oi.getOpenPrice()-apPrice=" + (oi.getOpenPrice()-apPrice));
         bool isClosed = false;
         for (int i = apCount-1; 0<=i; i--) {
            isClosed = closeOrderShort(orderList.GetNodeAtIndex(i));
            if (isClosed) {
               orderList.Delete(i);
            } else {
               Alert("OrdersShort[" + IntegerToString(i) + "] Is Not Closed.");
            }
         }
         return true;
      
      }
   }
   return false;
}

double calculateLot() {
   int count = 0;
   for (int i = 0; i < SymbolCount; i++) {
      CList *ordersL = OrdersLong[i];
      if (0 < ordersL.Total()) {
         count++;
      }
      
      CList *ordersS = OrdersShort[i];
      if (0 < ordersS.Total()) {
         count++;
      }
   }
   
   double balance1 = 5000 * (initLot/0.01);
   
   double usedBalance = count * balance1;
   
   double balance = AccountBalance();
   
   if (balance1 < (balance - usedBalance)) {
      return initLot;
   }
   
   return 0.0;
}

double calculateAPLot(CList *orderList) {
   int apCount = orderList.Total();
   double lot = APRuleLot[apCount];
   OrderInfo *oi = orderList.GetNodeAtIndex(0);
   lot = 100 * lot * oi.getLotSize();
   return lot;
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
   string symbolNm = SymbolArray[index].getSymbolName();
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
      symbolNm = SymbolArray[i].getSymbolName();
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
         fontColor = clrDarkGreen;
      } else if (sumProfitL < 0) {
         fontColor = clrRed;
      }
      ObjectSetText("sum_"+ColumnText[IndexLLots], DoubleToStr(sumLotL, 2), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexLOrders], IntegerToString(sumOrderL), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexLProfit], DoubleToStr(sumProfitL, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText("sum_"+ColumnText[IndexLLots], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexLOrders], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexLProfit], "", fontSize, fontName, fontColor);
   }
   
   fontColor = clrBlack;
   if (0 < (sumOrderS)) {
      if (0 < sumProfitS) {
         fontColor = clrDarkGreen;
      } else if (sumProfitS < 0) {
         fontColor = clrRed;
      }
      ObjectSetText("sum_"+ColumnText[IndexSLots], DoubleToStr(sumLotS, 2), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexSOrders], IntegerToString(sumOrderS), fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexSProfit], DoubleToStr(sumProfitS, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText("sum_"+ColumnText[IndexSLots], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexSOrders], "", fontSize, fontName, fontColor);
      ObjectSetText("sum_"+ColumnText[IndexSProfit], "", fontSize, fontName, fontColor);
   }
   
   fontColor = clrBlack;
   if (0 < (sumOrderL+sumOrderS)) {
      sumTotal = sumProfitL + sumProfitS;
      if (0 < sumTotal) {
         fontColor = clrDarkGreen;
      } else if (sumTotal < 0) {
         fontColor = clrRed;
      }
      ObjectSetText("sum_"+ColumnText[IndexTotal], DoubleToStr(sumTotal, 2), fontSize, fontName, fontColor);
   } else {
      ObjectSetText("sum_"+ColumnText[IndexTotal], "", fontSize, fontName, fontColor);
   }
}

double OnTester() {
   double ret=0.0;
   return(ret);
}

double calculateDPProfit(CList *orderList) {
   double profit = 0.0;
   int count = orderList.Total();
   double preOldOrderLot = 0.0;
   OrderInfo *curOrder = NULL;
   for (int m = 0; m < count; m++) {
      curOrder = orderList.GetNodeAtIndex(m);
      int ticketId = curOrder.getTicketId();
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      double tmpOneProfit = 0.0;
      if (isSelected) {
         tmpOneProfit = OrderProfit();
         tmpOneProfit += OrderCommission();
         tmpOneProfit += OrderSwap();
         
         if (0 == m) {
            
            
         } else if (count-1 == m) {

         
         } else {
            tmpOneProfit = tmpOneProfit*((curOrder.getLotSize()-preOldOrderLot)/curOrder.getLotSize());
            
         }
         
         profit += tmpOneProfit;
         
      } else {
         string msg = "OrderSelect failed in calculateDPProfit.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }
      
      preOldOrderLot = curOrder.getLotSize();
   }
   
   
   return NormalizeDouble(profit, 2);
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

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string btnNm = NULL;
      if (nmBtnCloseAll == sparam) {
         closeAllOrders(MagicNumber);
         for (int i = 0; i < SymbolCount; i++) {
            OrdersLong[i].Clear();
            OrdersShort[i].Clear();
         }
      }
      
      else 
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
            symbolNm = SymbolArray[i].getSymbolName();
            // H按钮被按下时
            if ((symbolNm+ColumnText[IndexH]) == sparam) {
               // TODO
               printf("货币对"+ symbolNm + "的H按钮被按下");
               btnNm = symbolNm+ColumnText[IndexH];
            }
            
            // D按钮被按下时
            else if ((symbolNm+ColumnText[IndexD]) == sparam) {
               printf("货币对"+ symbolNm + "的D按钮被按下");
               //printf("disabled=" + SymbolArray[i].isDisabled());
               if (SymbolArray[i].isDisabled()) {
                  SymbolArray[i].setDisabled(false);
                  ObjectSetString(0, symbolNm+ColumnText[IndexD], OBJPROP_TEXT, "D");
                  ObjectSetInteger(0, symbolNm+ColumnText[IndexD], OBJPROP_BGCOLOR, clrSilver);
               } else {
                  SymbolArray[i].setDisabled(true);
                  ObjectSetString(0, symbolNm+ColumnText[IndexD], OBJPROP_TEXT, "E");
                  ObjectSetInteger(0, symbolNm+ColumnText[IndexD], OBJPROP_BGCOLOR, clrGreen);
               }
               btnNm = symbolNm+ColumnText[IndexD];
            }
            
            // 货币对按钮被按下时
            else if ((symbolNm+ColumnText[IndexSymbol]) == sparam) {
               // TODO
               printf("货币对"+ symbolNm + "按钮被按下");
               
               long chartId = ChartOpen(symbolNm, _Period);
               if (0 == chartId) {
                  string msg = "Failed in ChartOpen. Error:【" + ErrorDescription(GetLastError()) + "】";
                  Alert(msg);
               } else {
                  ChartApplyTemplate(chartId, "template_SuperSkyNet");
               }
               
               /*
               string symbolName = SymbolPrefix+symbolNm+SymbolSuffix;
               long currChart=-1, prevChart=ChartFirst();
               //int j=0, limit=100;
               bool foundChart = false;
               while(true) {
                  currChart=ChartNext(prevChart);
                  if(currChart < 0) break;
                  if (symbolName == ChartSymbol(currChart)) {
                     foundChart = true;
                     break;
                  }
                  prevChart = currChart;
                  //j++;
               }
               
               long chartId = currChart;
               if (!foundChart) {
                  chartId = ChartOpen(symbolName, PERIOD_H1);
               } else {
                  ChartNavigate(chartId, CHART_END, 150);
               }
               
               ChartApplyTemplate(chartId, "Clean");
               */
               
               btnNm = symbolNm+ColumnText[IndexSymbol];
            }
            
            // 多头加仓按钮被按下时
            else if ((symbolNm+"L"+ColumnText[IndexLOUp]) == sparam) {
               printf("货币对"+ symbolNm + "的多头加仓按钮被按下");
               btnNm = symbolNm+"L"+ColumnText[IndexLOUp];
               
               CList *orderList = OrdersLong[i];
               bool hasChange = false;
               int apCount = orderList.Total();
               if (apCount < MaxAPTimes) {
                  string msg = "Are you sure to add position?";
                  if (IDOK == MessageBox(msg, "Add Position", MB_OKCANCEL)) {
                     if (0 < apCount) {
                        OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
                        double lot = calculateAPLot(orderList);
                        OrderInfo *oiNew = createOrderLong(symbolNm, lot, i);
                        if (oiNew.isValid()) {
                           orderList.Add(oiNew);
                           hasChange = true;
                        }
                        
                     } else {
                     
                     
                     }
                  }
               }
               
               if (hasChange) {
                  refreshRow(i);
                  refreshSumRow();
               }
            }
            
            // 多头减仓按钮被按下时
            else if ((symbolNm+"L"+ColumnText[IndexLODn]) == sparam) {
               printf("货币对"+ symbolNm + "的多头减仓按钮被按下");
               btnNm = symbolNm+"L"+ColumnText[IndexLODn];
               
               CList *orderList = OrdersLong[i];
               int count = orderList.Total();
               
               if (2 < count) {
                  double dpProfit = calculateDPProfit(orderList);
                  string msg = "Minus Position Profit = " + DoubleToStr(dpProfit, 2);
                  msg += "\n\nAre you sure to minus position?";
                  
                  if (IDOK == MessageBox(msg, "Minus Position", MB_OKCANCEL)) {
                     OrderInfo *order0 = NULL;
                     OrderInfo *orderLast = NULL;
                     double preOldOrderLot = 0.0;
                     double curOrderLot = 0.0;
                     OrderInfo *curOrder = NULL;
                     for (int m = 0; m < count; m++) {
                        curOrder = orderList.GetNodeAtIndex(m);
                        if (0 == m) {
                           order0 = curOrder;
                           closeOrderLong(curOrder);
                           preOldOrderLot = curOrder.getLotSize();
                           
                        } else if (count-1 == m) {
                           orderLast = curOrder;
                           closeOrderLong(curOrder);
                        
                        } else {
                           closeOrderLong(curOrder, curOrder.getLotSize()-preOldOrderLot);
                           //orderList.Insert(curOrder, m-1);
                           orderList.MoveToIndex(m-1);
                           curOrderLot = preOldOrderLot;
                           preOldOrderLot = curOrder.getLotSize();
                           curOrder.setLotSize(curOrderLot);
                        }
                        
                        
                     }
                     
                     
                     orderList.Delete(count-1);
                     orderList.Delete(count-2);
                     delete order0;
                     delete orderLast;
                     
                     resetTicketId(orderList);
                     
                     /*
                     count = orderList.Total();
                     printf("new count=" + count);
                     for (int k=0; k < count; k++) {
                        OrderInfo *curOrder = orderList.GetNodeAtIndex(k);
                        printf("new TicketId=" + curOrder.getTicketId());
                        printf("new OpenPrice=" + curOrder.getOpenPrice());
                        printf("new LotSize=" + curOrder.getLotSize());
                        printf("new TpPrice=" + curOrder.getTpPrice());
                     }
                     */
                     
                     refreshRow(i);
                     refreshSumRow();
                  }
               } else {
                  Alert("You don't need to minus position. Because the Orders < 3.");
               }
               
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
               refreshRow(i);
               refreshSumRow();
            }
            
            // 空头加仓按钮被按下时
            else if ((symbolNm+"S"+ColumnText[IndexSOUp]) == sparam) {
               printf("货币对"+ symbolNm + "的空头加仓按钮被按下");
               btnNm = symbolNm+"S"+ColumnText[IndexSOUp];
               
               CList *orderList = OrdersShort[i];
               bool hasChange = false;
               int apCount = orderList.Total();
               if (apCount < MaxAPTimes) {
                  string msg = "Are you sure to add position?";
                  if (IDOK == MessageBox(msg, "Add Position", MB_OKCANCEL)) {
                     if (0 < apCount) {
                        OrderInfo *oi = orderList.GetNodeAtIndex(apCount-1);
                        double lot = calculateAPLot(orderList);
                        OrderInfo *oiNew = createOrderShort(symbolNm, lot, i);
                        if (oiNew.isValid()) {
                           orderList.Add(oiNew);
                           hasChange = true;
                        }
                        
                     } else {
                        
                     }
                  }
               }
               
               if (hasChange) {
                  refreshRow(i);
                  refreshSumRow();
               }
            }
            
            // 空头减仓按钮被按下时
            else if ((symbolNm+"S"+ColumnText[IndexSODn]) == sparam) {
               printf("货币对"+ symbolNm + "的空头减仓按钮被按下");
               btnNm = symbolNm+"S"+ColumnText[IndexSODn];
               
               CList *orderList = OrdersShort[i];
               int count = orderList.Total();
               
               if (2 < count) {
                  double dpProfit = calculateDPProfit(orderList);
                  string msg = "Minus Position Profit = " + DoubleToStr(dpProfit, 2);
                  msg += "\n\nAre you sure to minus position?";
                  
                  if (IDOK == MessageBox(msg, "Minus Position", MB_OKCANCEL)) {
                     OrderInfo *order0 = NULL;
                     OrderInfo *orderLast = NULL;
                     double preOldOrderLot = 0.0;
                     double curOrderLot = 0.0;
                     OrderInfo *curOrder = NULL;
                     for (int m = 0; m < count; m++) {
                        curOrder = orderList.GetNodeAtIndex(m);
                        if (0 == m) {
                           order0 = curOrder;
                           closeOrderShort(curOrder);
                           preOldOrderLot = curOrder.getLotSize();
                           
                        } else if (count-1 == m) {
                           orderLast = curOrder;
                           closeOrderShort(curOrder);
                        
                        } else {
                           closeOrderShort(curOrder, curOrder.getLotSize()-preOldOrderLot);
                           //orderList.Insert(curOrder, m-1);
                           orderList.MoveToIndex(m-1);
                           curOrderLot = preOldOrderLot;
                           preOldOrderLot = curOrder.getLotSize();
                           curOrder.setLotSize(curOrderLot);
                        }
                        
                        
                     }
                     
                     
                     
                     orderList.Delete(count-1);
                     orderList.Delete(count-2);
                     delete order0;
                     delete orderLast;
                     
                     resetTicketId(orderList);
                     
                     
                     /*
                     count = orderList.Total();
                     printf("new count=" + count);
                     for (int k=0; k < count; k++) {
                        OrderInfo *curOrder = orderList.GetNodeAtIndex(k);
                        printf("new TicketId=" + curOrder.getTicketId());
                        printf("new OpenPrice=" + curOrder.getOpenPrice());
                        printf("new LotSize=" + curOrder.getLotSize());
                        printf("new TpPrice=" + curOrder.getTpPrice());
                     }
                     */
                     
                     refreshRow(i);
                     refreshSumRow();
                  }
               } else {
                  Alert("You don't need to minus position. Because the Orders < 3.");
               }
               
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
               refreshRow(i);
               refreshSumRow();
            }
         }// end for
      }// end else
   }// end CHARTEVENT_OBJECT_CLICK
   
}

OrderInfo *createOrderLong(string symbolName, double lotSize, int index) {
   OrderInfo *oi = new OrderInfo;
   
   RefreshRates();
   int vdigits = (int) MarketInfo(symbolName, MODE_DIGITS);
   double vpoint  = MarketInfo(symbolName, MODE_POINT);
   double vask = MarketInfo(symbolName, MODE_ASK);
   
   double slPrice = 0.0;
   
   double tpPrice = 0.0;
   /*
   if (0 < TP) {
      tpPrice = NormalizeDouble(10*vpoint*TP, vdigits);
      tpPrice = vask + tpPrice;
   }
   */
   
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
   oi.setOpenPrice(vask);
   
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
   
   //Alert("index=" + index + " symbol name = " + SymbolArray[index].getSymbolName() + " " +  oi.getOpenPrice() + "  " + SymbolArray[index].getTpPrice());
   oi.setTpPrice(oi.getOpenPrice()+SymbolArray[index].getTpPrice());
   
   return oi;
}

OrderInfo *createOrderShort(string symbolName, double lotSize, int index) {
   OrderInfo *oi = new OrderInfo;
   
   RefreshRates();
   int vdigits = (int) MarketInfo(symbolName, MODE_DIGITS);
   double vpoint  = MarketInfo(symbolName, MODE_POINT);
   double vbid = MarketInfo(symbolName, MODE_BID);
   
   double slPrice = 0.0;
   
   double tpPrice = 0.0;
   /*
   if (0 < TP) {
      tpPrice = NormalizeDouble(10*vpoint*TP, vdigits);
      tpPrice = vbid - tpPrice;
   }
   */
   
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
   oi.setOpenPrice(vbid);
   
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
   //Alert("index=" + index + " symbol name = " + SymbolArray[index].getSymbolName() + " " +  oi.getOpenPrice() + "  " + SymbolArray[index].getTpPrice());
   oi.setTpPrice(oi.getOpenPrice()-SymbolArray[index].getTpPrice());
   
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
      symbolNm = SymbolArray[i].getSymbolName();
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


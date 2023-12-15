//+------------------------------------------------------------------+
//|                                              EA_TrailingStop.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

enum Operate_Mode
{
    OPM_MagicNumber,
    OPM_CurrentWindowSymbol,
    OPM_MagicNumber_And_CurrentWindowSymbol,
    OPM_ALL
};
enum Trailing_Stop_Method
{
    TSM_Fix,
    TSM_MA,
    TSM_Sar,
    TSM_ATR,
    TSM_BollingerBands
};
input ENUM_TIMEFRAMES            Timeframe            = PERIOD_CURRENT;
input Operate_Mode               OperateMode          = OPM_ALL;
input Trailing_Stop_Method       TrailingStopMethod     = TSM_Fix;
input int                        TargetMagicNumber    = 168168;
input int                        OffsetPoint          = -20;
input string ____TSM_Fix_Set = "================";
input int                  TSM_Fix_Point              = 200;
input string ____TSM_MA_Set = "================";
input int                  TSM_MA_Period              = 55;
input ENUM_MA_METHOD       TSM_MA_Method              = MODE_EMA;
input ENUM_APPLIED_PRICE   TSM_MA_Applied_Price       = PRICE_WEIGHTED;
input string ____TSM_Sar_Set = "================";
input double               TSM_Sar_Step               = 0.02;
input double               TSM_Sar_Maximum            = 0.2;
input string ____TSM_ATR_Set = "================";
input int                  TSM_ATR_Period             = 34;
input string ____TSM_BollingerBands_Set = "================";
input int                  TSM_BollingerBands_Period        = 55;
input double               TSM_BollingerBands_Deviation     = 2;
input ENUM_APPLIED_PRICE   TSM_BollingerBands_Applied_Price = PRICE_WEIGHTED;
input int                  TSM_BollingerBands_LineIndex     = MODE_MAIN;

input string ____Display_Set = "================";
input int                        Coordinates_X    = 10;
input int                        Coordinates_Y    = 30;
input bool                       In_4Kdisplay     = false;

Operate_Mode _operateMode;
Trailing_Stop_Method _trailingStopMethod;
int _targetMagicNumber, _offsetPoint, _tsmFixPoint, _tsmMaPeriod, _tsmAtrPeriod, _tsmBBPeriod, _tsmBBLineIndex;
ENUM_TIMEFRAMES _tfTsmMa, _tfTsmSar, _tfTsmAtr, _tfTsmBB;
ENUM_MA_METHOD _tsmMaMethod;
ENUM_APPLIED_PRICE _tsmMaAppliedPrice, _tsmBBAppliedPrice;
double _tsmSarStep, _tsmSarMaximum, _tsmBBDeviation;
//int _period;

datetime barTime = 0;
bool     Stop_EA = true;


const string TxtStatusStop = "Stopped";
const string TxtStatusRun  = "Running";

const color ClrBtnBgSelected     = clrGreen;
const color ClrBtnFtSelected     = clrBlack;
const color ClrBtnBgUnselected   = clrGray;
const color ClrBtnFtUnselected   = clrWhiteSmoke;

const color ShowFontColor = clrWhite;
const color HiddenFontColor = clrBlack;
const color ShowEditBgColor = clrWhite;
const color HiddenEditBgColor = clrBlack;
const color HiddenButtonBgColor = clrBlack;

int OnInit() {
   _operateMode = OperateMode;
   _trailingStopMethod = TrailingStopMethod;
   _targetMagicNumber = TargetMagicNumber;
   _offsetPoint = OffsetPoint;
   _tsmFixPoint = TSM_Fix_Point;
   _tfTsmMa = Timeframe;
   _tfTsmSar = Timeframe;
   _tfTsmAtr = Timeframe;
   _tfTsmBB = Timeframe;
   _tsmMaPeriod = TSM_MA_Period;
   _tsmMaMethod = TSM_MA_Method;
   _tsmMaAppliedPrice = TSM_MA_Applied_Price;
   _tsmSarStep = TSM_Sar_Step;
   _tsmSarMaximum = TSM_Sar_Maximum;
   _tsmAtrPeriod = TSM_ATR_Period;
   _tsmBBPeriod = TSM_BollingerBands_Period;
   _tsmBBDeviation = TSM_BollingerBands_Deviation;
   _tsmBBAppliedPrice = TSM_BollingerBands_Applied_Price;
   _tsmBBLineIndex = TSM_BollingerBands_LineIndex;
   
   if (In_4Kdisplay) {
      draw4K();
   } else {
      draw();
   }
   
//--- create timer
   EventSetTimer(1);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll(0, ObjNamePrefix);
}

void OnTick() {}

void OnTimer() {
   if (Stop_EA) return;
   if (TSM_Fix != _trailingStopMethod) {
      datetime nowBarTime = iTime(NULL, Timeframe, 0);
      // not new bar
      if (barTime == nowBarTime) return;

      // new bar then go on
      barTime = nowBarTime;
   }
   for (int i=OrdersTotal()-1; 0<=i; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (!isTargetOrder()) continue;
         int orderType = OrderType();
         string symbolName = OrderSymbol();
         double sl = 0.0;
         double slOrder = OrderStopLoss();
         if (OP_BUY == orderType) {
            sl = getSl4Buy(symbolName);
            if (slOrder < sl) modify(sl);

         /*****************************************************************************************************************/
         } else if (OP_SELL == orderType) {
            sl = getSl4Sell(symbolName);
            if (sl < slOrder) modify(sl);
         }
      } else {
         Print("Failed to call OrderSelect() method for position #", i, " Error code=", ErrorDescription(GetLastError()));
      }
   }

}


bool isTargetOrder() {
   if (OPM_ALL == _operateMode) return true;
   if (OPM_MagicNumber == _operateMode && OrderMagicNumber() == _targetMagicNumber) return true;
   if (OPM_CurrentWindowSymbol == _operateMode && OrderSymbol() == _Symbol) return true;
   if (OPM_MagicNumber_And_CurrentWindowSymbol == _operateMode && OrderMagicNumber() == _targetMagicNumber && OrderSymbol() == _Symbol) return true;
   return false;
}

double getSlByIndicator(string symbolName) {
   double sl = 0.0;
   
   switch (_trailingStopMethod) {
      case TSM_MA:
         sl = iMA(symbolName, _tfTsmMa, _tsmMaPeriod, 0, _tsmMaMethod, _tsmMaAppliedPrice, 1);
         break;
      case TSM_Sar:
         sl = iSAR(symbolName, _tfTsmSar, _tsmSarStep, _tsmSarMaximum, 1);
         break;
      case TSM_ATR:
         sl = iATR(symbolName, _tfTsmAtr, _tsmAtrPeriod, 1);
         break;
      case TSM_BollingerBands:
         sl = iBands(symbolName, _tfTsmBB, _tsmBBPeriod, _tsmBBDeviation, 0, _tsmBBAppliedPrice, _tsmBBLineIndex, 1);
         break;
      default: break;
   }

   return sl;
}

double getSl4Buy(string symbolName) {
   double sl = 0.0;
   double vpoint = MarketInfo(symbolName, MODE_POINT);
   switch (_trailingStopMethod) {
      case TSM_Fix:
         sl = MarketInfo(symbolName, MODE_BID) - _tsmFixPoint*vpoint;
         break;
      case TSM_MA:
      case TSM_Sar:
      case TSM_ATR:
      case TSM_BollingerBands:
         sl = getSlByIndicator(symbolName);
         sl += _offsetPoint*vpoint;
         break;
      default: break;
   }

   return NormalizeDouble(sl, (int) MarketInfo(symbolName, MODE_DIGITS));
}

double getSl4Sell(string symbolName) {
   double sl = 0.0;
   double vpoint = MarketInfo(symbolName, MODE_POINT);
   switch (_trailingStopMethod) {
      case TSM_Fix:
         sl = MarketInfo(symbolName, MODE_ASK) + _tsmFixPoint*vpoint;
         break;
      case TSM_MA:
      case TSM_Sar:
      case TSM_ATR:
      case TSM_BollingerBands:
         sl = getSlByIndicator(symbolName);
         sl -= _offsetPoint*vpoint;
         break;
      default: break;
   }

   return NormalizeDouble(sl, (int) MarketInfo(symbolName, MODE_DIGITS));
}


void modify(double sl) {
   if (OrderModify(OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), 0, clrNONE)) {
      Print("Order modified successfully.", "Ticket ID=", OrderTicket());
   } else {
      Print("Error in OrderModify.", "Ticket ID=", OrderTicket(), " Symbol=", OrderSymbol(), " Error code=", ErrorDescription(GetLastError()));
   }
}

bool isValidDouble(const string str) {
   int strLength = StringLen(str);
   for (int i=0; i<strLength; i++) {
      ushort charCd = StringGetChar(str, i);
      // -
      if (45 == charCd) {
         // only - 
         if (1 == strLength) return false;
         // not first
         if ((strLength-1) != i) return false;
         continue;
      }

      // .
      if (46 == charCd) {
         // first
         if (0 == i) return false;
         // last
         if ((strLength-1) == i) return false;
         continue;
      }

      // 0123456789
      if (48 <= charCd && charCd <= 57) continue;
      return false;
   }
   
   return true;
}

bool isValidInteger(const string str) {
   int strLength = StringLen(str);
   for (int i=0; i<strLength; i++) {
      ushort charCd = StringGetChar(str, i);
      // -
      if (45 == charCd) continue;

      // 0123456789
      if (48 <= charCd && charCd <= 57) continue;
      return false;
   }
   
   return true;
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (CHARTEVENT_OBJECT_CLICK == id) {
      if (ObjNamePrefix+"btn_"+"EA_Status" == sparam) {
         if (Stop_EA) {
            // check TODO
            Stop_EA = false;
            setBtnSelected(sparam);
            ObjectSetString(0, sparam, OBJPROP_TEXT, TxtStatusRun);
            
         } else {
            Stop_EA = true;
            setBtnUnselected(sparam);
            ObjectSetString(0, sparam, OBJPROP_TEXT, TxtStatusStop);
         }
      } else
      if (ObjNamePrefix+"btn_"+"OPM_ALL" == sparam) {
         setBtnOperateMode(OPM_ALL);
      } else
      if (ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol" == sparam) {
         setBtnOperateMode(OPM_CurrentWindowSymbol);
      } else
      if (ObjNamePrefix+"btn_"+"OPM_MagicNumber" == sparam) {
         setBtnOperateMode(OPM_MagicNumber);
      } else
      if (ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol" == sparam) {
         setBtnOperateMode(OPM_MagicNumber_And_CurrentWindowSymbol);
      } else
      if (ObjNamePrefix+"btn_"+"TSM_Fix" == sparam) {
         setBtnTrailingStopMethod(TSM_Fix);
      } else
      if (ObjNamePrefix+"btn_"+"TSM_MA" == sparam) {
         setBtnTrailingStopMethod(TSM_MA);
      } else
      if (ObjNamePrefix+"btn_"+"TSM_Sar" == sparam) {
         setBtnTrailingStopMethod(TSM_Sar);
      } else
      if (ObjNamePrefix+"btn_"+"TSM_ATR" == sparam) {
         setBtnTrailingStopMethod(TSM_ATR);
      } else
      if (ObjNamePrefix+"btn_"+"TSM_BollingerBands" == sparam) {
         setBtnTrailingStopMethod(TSM_BollingerBands);
      } else
      if (ObjNamePrefix+"btn_"+"AP_CLOSE" == sparam) {
         if (TSM_MA != _trailingStopMethod && TSM_BollingerBands != _trailingStopMethod) return;
         setBtnAppliedPrice(PRICE_CLOSE);
      } else
      if (ObjNamePrefix+"btn_"+"AP_OPEN" == sparam) {
         if (TSM_MA != _trailingStopMethod && TSM_BollingerBands != _trailingStopMethod) return;
         setBtnAppliedPrice(PRICE_OPEN);
      } else
      if (ObjNamePrefix+"btn_"+"AP_HIGH" == sparam) {
         if (TSM_MA != _trailingStopMethod && TSM_BollingerBands != _trailingStopMethod) return;
         setBtnAppliedPrice(PRICE_HIGH);
      } else
      if (ObjNamePrefix+"btn_"+"AP_LOW" == sparam) {
         if (TSM_MA != _trailingStopMethod && TSM_BollingerBands != _trailingStopMethod) return;
         setBtnAppliedPrice(PRICE_LOW);
      } else
      if (ObjNamePrefix+"btn_"+"AP_MEDIAN" == sparam) {
         if (TSM_MA != _trailingStopMethod && TSM_BollingerBands != _trailingStopMethod) return;
         setBtnAppliedPrice(PRICE_MEDIAN);
      } else
      if (ObjNamePrefix+"btn_"+"AP_TYPICAL" == sparam) {
         if (TSM_MA != _trailingStopMethod && TSM_BollingerBands != _trailingStopMethod) return;
         setBtnAppliedPrice(PRICE_TYPICAL);
      } else
      if (ObjNamePrefix+"btn_"+"AP_WEIGHTED" == sparam) {
         if (TSM_MA != _trailingStopMethod && TSM_BollingerBands != _trailingStopMethod) return;
         setBtnAppliedPrice(PRICE_WEIGHTED);
      } else
      if (ObjNamePrefix+"btn_"+"MM_SMA" == sparam) {
         if (TSM_MA != _trailingStopMethod) return;
         setBtnMaMethod(MODE_SMA);
      } else
      if (ObjNamePrefix+"btn_"+"MM_EMA" == sparam) {
         if (TSM_MA != _trailingStopMethod) return;
         setBtnMaMethod(MODE_EMA);
      } else
      if (ObjNamePrefix+"btn_"+"MM_SMMA" == sparam) {
         if (TSM_MA != _trailingStopMethod) return;
         setBtnMaMethod(MODE_SMMA);
      } else
      if (ObjNamePrefix+"btn_"+"MM_LWMA" == sparam) {
         if (TSM_MA != _trailingStopMethod) return;
         setBtnMaMethod(MODE_LWMA);
      } else
      if (ObjNamePrefix+"btn_"+"BB_MAIN" == sparam) {
         if (TSM_BollingerBands != _trailingStopMethod) return;
         setBtnBBLineIndex(MODE_MAIN);
      } else
      if (ObjNamePrefix+"btn_"+"BB_UPPER" == sparam) {
         if (TSM_BollingerBands != _trailingStopMethod) return;
         setBtnBBLineIndex(MODE_UPPER);
      } else
      if (ObjNamePrefix+"btn_"+"BB_LOWER" == sparam) {
         if (TSM_BollingerBands != _trailingStopMethod) return;
         setBtnBBLineIndex(MODE_LOWER);
      }
   }
   
   else
   if (CHARTEVENT_OBJECT_ENDEDIT == id) {
      if (ObjNamePrefix+"edt_"+"OPM_MagicNumber" == sparam) {
         if (OPM_ALL == _operateMode || OPM_CurrentWindowSymbol == _operateMode) return;
         string inputText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (isValidInteger(inputText)) {
            _targetMagicNumber = StrToInteger(inputText);
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);
         } else {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            Alert("Not Valid Number");
         }
      } else
      if (ObjNamePrefix+"edt_"+"FixPoint" == sparam) {
         if (TSM_Fix != _trailingStopMethod) return;
         string inputText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (isValidInteger(inputText)) {
            _tsmFixPoint = StrToInteger(inputText);
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);
         } else {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            Alert("Not Valid Number");
         }
      } else
      if (ObjNamePrefix+"edt_"+"Offset" == sparam) {
         if (TSM_Fix == _trailingStopMethod) return;
         string inputText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (isValidInteger(inputText)) {
            _offsetPoint = StrToInteger(inputText);
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);
         } else {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            Alert("Not Valid Number");
         }
      } else
      if (ObjNamePrefix+"edt_"+"Period" == sparam) {
         if (TSM_Fix == _trailingStopMethod || TSM_Sar == _trailingStopMethod) return;
         string inputText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (isValidInteger(inputText)) {
            _tsmMaPeriod = StrToInteger(inputText);
            _tsmAtrPeriod = _tsmMaPeriod;
            _tsmBBPeriod = _tsmMaPeriod;
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);
         } else {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            Alert("Not Valid Number");
         }
      } else
      if (ObjNamePrefix+"edt_"+"SarStep" == sparam) {
         if (TSM_Sar != _trailingStopMethod) return;
         string inputText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (isValidDouble(inputText)) {
            _tsmSarStep = StrToDouble(inputText);
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);
         } else {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            Alert("Not Valid Double");
         }
      } else
      if (ObjNamePrefix+"edt_"+"SarMaximum" == sparam) {
         if (TSM_Sar != _trailingStopMethod) return;
         string inputText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (isValidDouble(inputText)) {
            _tsmSarMaximum = StrToDouble(inputText);
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);
         } else {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            Alert("Not Valid Double");
         }
      } else
      if (ObjNamePrefix+"edt_"+"BB_Deviation" == sparam) {
         if (TSM_BollingerBands != _trailingStopMethod) return;
         string inputText = ObjectGetString(0, sparam, OBJPROP_TEXT);
         if (isValidDouble(inputText)) {
            _tsmBBDeviation = StrToDouble(inputText);
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrWhite);
         } else {
            ObjectSetInteger(0,sparam,OBJPROP_BGCOLOR,clrRed);
            Alert("Not Valid Double");
         }
      }
   }
}


const string         ObjNamePrefix     = "TS_";

void setBtnSelected(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,ClrBtnBgSelected);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,ClrBtnFtSelected);
}

void setBtnUnselected(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,ClrBtnFtUnselected);
}


void setBtnOperateMode(Operate_Mode opm) {
   _operateMode = opm;
   if (OPM_ALL == opm) {
      setBtnSelected(  ObjNamePrefix+"btn_"+"OPM_ALL");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_MagicNumber");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol");
      hiddenMagic();
   } else
   if (OPM_CurrentWindowSymbol == opm) {
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_ALL");
      setBtnSelected(  ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_MagicNumber");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol");
      hiddenMagic();
   } else
   if (OPM_MagicNumber == opm) {
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_ALL");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol");
      setBtnSelected(  ObjNamePrefix+"btn_"+"OPM_MagicNumber");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol");
      showMagic();
   } else
   if (OPM_MagicNumber_And_CurrentWindowSymbol == opm) {
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_ALL");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol");
      setBtnUnselected(ObjNamePrefix+"btn_"+"OPM_MagicNumber");
      setBtnSelected(  ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol");
      showMagic();
   }
}

void setBtnTrailingStopMethod(Trailing_Stop_Method tsm) {
   _trailingStopMethod = tsm;
   switch (tsm) {
      case TSM_Fix:
         setBtnSelected(  ObjNamePrefix+"btn_"+"TSM_Fix");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_MA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Sar");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_ATR");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_BollingerBands");
         setObjShow4Fix();
         break;
      case TSM_MA:
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Fix");
         setBtnSelected(  ObjNamePrefix+"btn_"+"TSM_MA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Sar");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_ATR");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_BollingerBands");
         setObjShow4MA();
         break;
      case TSM_Sar:
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Fix");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_MA");
         setBtnSelected(  ObjNamePrefix+"btn_"+"TSM_Sar");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_ATR");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_BollingerBands");
         setObjShow4Sar();
         break;
      case TSM_ATR:
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Fix");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_MA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Sar");
         setBtnSelected(  ObjNamePrefix+"btn_"+"TSM_ATR");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_BollingerBands");
         setObjShow4ATR();
         break;
      case TSM_BollingerBands:
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Fix");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_MA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_Sar");
         setBtnUnselected(ObjNamePrefix+"btn_"+"TSM_ATR");
         setBtnSelected(  ObjNamePrefix+"btn_"+"TSM_BollingerBands");
         setObjShow4BB();
         break;
      default: break;
   }
}

void setBtnAppliedPrice(ENUM_APPLIED_PRICE ap) {
   switch (_trailingStopMethod) {
      case TSM_BollingerBands:
         _tsmBBAppliedPrice = ap;
         break;
      case TSM_MA:
         _tsmMaAppliedPrice = ap;
         break;
      case TSM_Sar:
      case TSM_ATR:
      case TSM_Fix:
      default:
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         return;
   }

   switch (ap) {
      case PRICE_CLOSE:
         setBtnSelected(  ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         break;
      case PRICE_OPEN:
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnSelected(  ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         break;
      case PRICE_HIGH:
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnSelected(  ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         break;
      case PRICE_LOW:
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnSelected(  ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         break;
      case PRICE_MEDIAN:
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnSelected(  ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         break;
      case PRICE_TYPICAL:
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnSelected(  ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         break;
      case PRICE_WEIGHTED:
         setBtnUnselected(  ObjNamePrefix+"btn_"+"AP_CLOSE");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_OPEN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_HIGH");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_LOW");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_MEDIAN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"AP_TYPICAL");
         setBtnSelected(  ObjNamePrefix+"btn_"+"AP_WEIGHTED");
         break;
      default: break;
   }
}

void setBtnMaMethod(ENUM_MA_METHOD mm) {
   _tsmMaMethod = mm;
   switch (mm) {
      case MODE_SMA:
         setBtnSelected(  ObjNamePrefix+"btn_"+"MM_SMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_EMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_SMMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_LWMA");
         break;
      case MODE_EMA:
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_SMA");
         setBtnSelected(  ObjNamePrefix+"btn_"+"MM_EMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_SMMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_LWMA");
         break;
      case MODE_SMMA:
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_SMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_EMA");
         setBtnSelected(  ObjNamePrefix+"btn_"+"MM_SMMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_LWMA");
         break;
      case MODE_LWMA:
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_SMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_EMA");
         setBtnUnselected(ObjNamePrefix+"btn_"+"MM_SMMA");
         setBtnSelected(  ObjNamePrefix+"btn_"+"MM_LWMA");
         break;
      default: break;
   }
}

void setBtnBBLineIndex(int lineIndex) {
   _tsmBBLineIndex = lineIndex;
   switch (lineIndex) {
      case MODE_MAIN:
         setBtnSelected(  ObjNamePrefix+"btn_"+"BB_MAIN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"BB_UPPER");
         setBtnUnselected(ObjNamePrefix+"btn_"+"BB_LOWER");
         break;
      case MODE_UPPER:
         setBtnUnselected(ObjNamePrefix+"btn_"+"BB_MAIN");
         setBtnSelected(  ObjNamePrefix+"btn_"+"BB_UPPER");
         setBtnUnselected(ObjNamePrefix+"btn_"+"BB_LOWER");
         break;
      case MODE_LOWER:
         setBtnUnselected(ObjNamePrefix+"btn_"+"BB_MAIN");
         setBtnUnselected(ObjNamePrefix+"btn_"+"BB_UPPER");
         setBtnSelected(  ObjNamePrefix+"btn_"+"BB_LOWER");
         break;
      default: break;
   }
}

void draw4K() {
   const int            PanelWidth        = 830;
   const int            PanelHeight       = 400;
   const int            RowHeight         = 35;
   int x = Coordinates_X;
   int y = Coordinates_Y;
   int btnFontSize = 6;
   int lblFontSize = 7;
   color lblFontColor = clrWhite;
   CreatePanel(ObjNamePrefix+"Panel",x,y,PanelWidth,PanelHeight);
   SetText(ObjNamePrefix+"lbl_"+"OPM", "Operate Mode :", x+3, y+1, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_ALL",                                 "ALL",                          x+15,               y+RowHeight-4,  50, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol",                 "CurrentSymbol",                x+15+50+10,         y+RowHeight-4, 140, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_MagicNumber",                         "MagicNumber",                  x+15+50+140+20,     y+RowHeight-4, 130, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol", "MagicNumber & CurrentSymbol", x+15+50+140+130+30, y+RowHeight-4, 294, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   SetText(ObjNamePrefix+"lbl_"+"OPM_MagicNumber", "Magic Number :", x+15, y+2*RowHeight, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"OPM_MagicNumber", x+15+170, y+2*RowHeight-4, 474, RowHeight, lblFontSize, "1234567890");
   
   CreateButton(ObjNamePrefix+"btn_"+"EA_Status", "Stopped", x+690, y+RowHeight-4, 130, 4*RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, 9);
   
   SetText(ObjNamePrefix+"lbl_"+"TSM", "Trailing Stop Method :", x+3, y+4*RowHeight, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_Fix",             "Fix",            x+10,       y+5*RowHeight-4,   50, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_MA",              "MA",             x+20+50,    y+5*RowHeight-4,   50, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_Sar",             "Sar",            x+30+100,   y+5*RowHeight-4,   50, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_ATR",             "ATR",            x+40+150,   y+5*RowHeight-4,   50, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"TSM_BollingerBands",  "BollingerBands", x+50+200,   y+5*RowHeight-4,  140, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   
   SetText(ObjNamePrefix+"lbl_"+"FixPoint", "Fix Point :", x+460, y+5*RowHeight-4, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"FixPoint", x+570, y+5*RowHeight-4, 80, RowHeight, lblFontSize, "12345");
   
   SetText(ObjNamePrefix+"lbl_"+"Offset", "Offset Point   :", x+50, y+6*RowHeight+2, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"Offset", x+210, y+6*RowHeight, 80, RowHeight, lblFontSize, "12345");
   SetText(ObjNamePrefix+"lbl_"+"Period", "Period :", x+370, y+6*RowHeight+2, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"Period", x+460, y+6*RowHeight, 80, RowHeight, lblFontSize, "123");
   
   SetText(ObjNamePrefix+"lbl_"+"AppliedPrice", "Applied Price :", x+50, y+7*RowHeight+4, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_CLOSE",      "CLOSE",    x+210,       y+7*RowHeight+4,  78, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_OPEN",       "OPEN",     x+296,       y+7*RowHeight+4,  68, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_HIGH",       "HIGH",     x+372,       y+7*RowHeight+4,  62, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_LOW",        "LOW",      x+442,       y+7*RowHeight+4,  60, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_MEDIAN",     "MEDIAN",   x+510,       y+7*RowHeight+4,  86, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_TYPICAL",    "TYPICAL",  x+604,       y+7*RowHeight+4,  94, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"AP_WEIGHTED",   "WEIGHTED", x+706,       y+7*RowHeight+4,  120, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   
   SetText(ObjNamePrefix+"lbl_"+"Ma_Method", "MA Method    :", x+50, y+8*RowHeight+4, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_SMA",  "SMA",   x+210,       y+8*RowHeight+4,  78, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_EMA",  "EMA",   x+310,       y+8*RowHeight+4,  78, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_SMMA", "SMMA",  x+410,       y+8*RowHeight+4,  78, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"MM_LWMA", "LWMA",  x+510,       y+8*RowHeight+4,  78, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);

   SetText(ObjNamePrefix+"lbl_"+"SarStep", "Sar Step        :", x+50, y+9*RowHeight+5, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"SarStep", x+210, y+9*RowHeight+6, 80, RowHeight, lblFontSize, "12345");
   SetText(ObjNamePrefix+"lbl_"+"SarMaximum", "Sar Maximum :", x+370, y+9*RowHeight+5, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"SarMaximum", x+530, y+9*RowHeight+6, 80, RowHeight, lblFontSize, "123");
   
   SetText(ObjNamePrefix+"lbl_"+"BB_Deviation", "BB Deviation :", x+50, y+10*RowHeight+8, lblFontColor, lblFontSize);
   CreateEdit(ObjNamePrefix+"edt_"+"BB_Deviation", x+210, y+10*RowHeight+9, 80, RowHeight, lblFontSize, "12345");
   SetText(ObjNamePrefix+"lbl_"+"BB_LineIndex", "BB LineIndex  :", x+370, y+10*RowHeight+8, lblFontColor, lblFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"BB_MAIN",  "MAIN",   x+530,       y+10*RowHeight+9,  82, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"BB_UPPER",  "UPPER",   x+620,       y+10*RowHeight+9,  82, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
   CreateButton(ObjNamePrefix+"btn_"+"BB_LOWER", "LOWER",  x+710,       y+10*RowHeight+9,  82, RowHeight-4, ClrBtnBgUnselected, ClrBtnFtUnselected, btnFontSize);
}

void draw() {
   const int PanelWidth       = 830;
   const int PanelHeight      = 400;
   const int RowHeight        = 23;
   const int MarginLeft       = 6;
   const int MarginTop        = 6;
   const int Interval         = 4;
   const int BtnFontSize      = 6;
   const int LblFontSize      = 7;
   const int EdtFontSize      = 8;
   const color LblFontColor   = clrWhite;
   
   string objName = ObjNamePrefix+"Panel";
   int x = Coordinates_X;
   int y = Coordinates_Y;
   CreatePanel(objName, x, y, PanelWidth, PanelHeight);
   
   objName = ObjNamePrefix+"lbl_"+"OPM";
   x += MarginLeft;
   y += MarginTop;
   SetText(objName, "Operate Mode :", x, y, LblFontColor, LblFontSize);
   
   objName = ObjNamePrefix+"btn_"+"OPM_ALL";
   y += 18;
   CreateButton(objName, "ALL",                          x, y, 30, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"OPM_CurrentWindowSymbol";
   x += 30 + Interval;
   CreateButton(objName, "CurrentSymbol",                x, y, 96, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"OPM_MagicNumber";
   x += 96 + Interval;
   CreateButton(objName, "MagicNumber",                  x, y, 90, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"OPM_MagicNumber_And_CurrentWindowSymbol";
   x += 90 + Interval;
   CreateButton(objName, "MagicNumber & CurrentSymbol",  x, y, 184,RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"EA_Status";
   x += 184 + Interval;
   CreateButton(objName, TxtStatusStop, x, y, 130, 4*RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, 14);
   
   objName = ObjNamePrefix+"lbl_"+"OPM_MagicNumber";
   x = Coordinates_X + MarginLeft;
   y += RowHeight;
   SetText(objName, "Magic Number :", x, y+2, LblFontColor, LblFontSize);
   
   objName = ObjNamePrefix+"edt_"+"OPM_MagicNumber";
   x += 100;
   CreateEdit(objName, x, y, 313, RowHeight, LblFontSize, "1234567890");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(TargetMagicNumber));
   
   
   objName = ObjNamePrefix+"lbl_"+"TSM";
   x = Coordinates_X + MarginLeft;
   y += 2*RowHeight;
   SetText(objName, "Trailing Stop Method :", x, y, LblFontColor, LblFontSize);
   
   objName = ObjNamePrefix+"btn_"+"TSM_Fix";
   y += 18;
   CreateButton(objName, "FIX",            x, y, 25, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"TSM_MA";
   x += 25 + Interval;
   CreateButton(objName, "MA",             x, y, 25, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"TSM_Sar";
   x += 25 + Interval;
   CreateButton(objName, "Sar",            x, y, 30, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"TSM_ATR";
   x += 30 + Interval;
   CreateButton(objName, "ATR",            x, y, 30, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"btn_"+"TSM_BollingerBands";
   x += 30 + Interval;
   CreateButton(objName, "BollingerBands", x, y, 96, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"lbl_"+"FixPoint";
   x += 96 + 8*Interval;
   SetText(objName, "Fix Point :", x, y+2, LblFontColor, LblFontSize);
   
   objName = ObjNamePrefix+"edt_"+"FixPoint";
   x += 65;
   CreateEdit(objName, x, y, 60, RowHeight, LblFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(TSM_Fix_Point));
   
   objName = ObjNamePrefix+"lbl_"+"Offset";
   x = Coordinates_X + MarginLeft + Interval;
   y += RowHeight;
   SetText(objName, "Offset Point   :", x, y+3, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"edt_"+"Offset";
   x += 95;
   CreateEdit(objName, x, y, 60, RowHeight, LblFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(OffsetPoint));
   objName = ObjNamePrefix+"lbl_"+"Period";
   x += 60 + 10*Interval;
   SetText(objName, "Period :", x, y+3, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"edt_"+"Period";
   x += 54;
   CreateEdit(objName, x, y, 60, RowHeight, LblFontSize, "123");
   ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(TSM_MA_Period));
   if (TSM_ATR == _trailingStopMethod) ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(TSM_ATR_Period));
   else if (TSM_BollingerBands == _trailingStopMethod) ObjectSetString(0, objName, OBJPROP_TEXT, IntegerToString(TSM_BollingerBands_Period));
   
   objName = ObjNamePrefix+"lbl_"+"AppliedPrice";
   x = Coordinates_X + MarginLeft + Interval;
   y += RowHeight;
   SetText(objName, "Applied Price :", x, y+2, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"btn_"+"AP_CLOSE";
   x += 95;
   CreateButton(objName, "CLOSE",    x, y, 50, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"AP_OPEN";
   x += 50 + Interval;
   CreateButton(objName, "OPEN",     x, y, 50, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"AP_HIGH";
   x += 50 + Interval;
   CreateButton(objName, "HIGH",     x, y, 40, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"AP_LOW";
   x += 40 + Interval;
   CreateButton(objName, "LOW",      x, y, 40, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"AP_MEDIAN";
   x += 40 + Interval;
   CreateButton(objName, "MEDIAN",   x, y, 60, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"AP_TYPICAL";
   x += 60 + Interval;
   CreateButton(objName, "TYPICAL",  x, y, 60, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"AP_WEIGHTED";
   x += 60 + Interval;
   CreateButton(objName, "WEIGHTED", x, y, 74, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   objName = ObjNamePrefix+"lbl_"+"Ma_Method";
   x = Coordinates_X + MarginLeft + Interval;
   y += RowHeight + Interval;
   SetText(objName, "MA Method    :", x, y+3, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"btn_"+"MM_SMA";
   x += 95;
   CreateButton(objName, "SMA",   x, y, 40, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"MM_EMA";
   x += 40 + Interval;
   CreateButton(objName, "EMA",   x, y, 40, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"MM_SMMA";
   x += 40 + Interval;
   CreateButton(objName, "SMMA",  x, y, 40, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"MM_LWMA";
   x += 40 + Interval;
   CreateButton(objName, "LWMA",  x, y, 40, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);

   objName = ObjNamePrefix+"lbl_"+"SarStep";
   x = Coordinates_X + MarginLeft + Interval;
   y += RowHeight;
   SetText(objName, "Sar Step        :", x, y, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"edt_"+"SarStep";
   x += 95;
   CreateEdit(objName, x, y, 60, RowHeight, LblFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToStr(TSM_Sar_Step, 2));
   objName = ObjNamePrefix+"lbl_"+"SarMaximum";
   x += 60 + 10*Interval;
   SetText(objName, "Sar Maximum :", x, y, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"edt_"+"SarMaximum";
   x += 94;
   CreateEdit(objName, x, y, 60, RowHeight, LblFontSize, "123");
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToStr(TSM_Sar_Maximum, 1));
   
   objName = ObjNamePrefix+"lbl_"+"BB_Deviation";
   x = Coordinates_X + MarginLeft + Interval;
   y += RowHeight;
   SetText(objName, "BB Deviation :", x, y+3, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"edt_"+"BB_Deviation";
   x += 95;
   CreateEdit(objName, x, y, 60, RowHeight, LblFontSize, "12345");
   ObjectSetString(0, objName, OBJPROP_TEXT, DoubleToStr(TSM_BollingerBands_Deviation, 0));
   objName = ObjNamePrefix+"lbl_"+"BB_LineIndex";
   x += 60 + 10*Interval;
   SetText(objName, "BB LineIndex :", x, y+3, LblFontColor, LblFontSize);
   objName = ObjNamePrefix+"btn_"+"BB_MAIN";
   x += 94;
   CreateButton(objName, "MAIN",  x, y, 50, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"BB_UPPER";
   x += 50 + Interval;
   CreateButton(objName, "UPPER", x, y, 50, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   objName = ObjNamePrefix+"btn_"+"BB_LOWER";
   x += 50 + Interval;
   CreateButton(objName, "LOWER", x, y, 50, RowHeight, ClrBtnBgUnselected, ClrBtnFtUnselected, BtnFontSize);
   
   setBtnOperateMode(_operateMode);
   setBtnTrailingStopMethod(_trailingStopMethod);
   
   if (TSM_MA == _trailingStopMethod) setBtnAppliedPrice(TSM_MA_Applied_Price);
   else if (TSM_BollingerBands == _trailingStopMethod) setBtnAppliedPrice(TSM_BollingerBands_Applied_Price);
   
   //setBtnMaMethod(TSM_MA_Method);
   //setBtnBBLineIndex(TSM_BollingerBands_LineIndex);
}



void SetText(string name,string text,int x,int y,color fontColor,int fontSize=8) {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,fontColor);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetString(chartId,name,OBJPROP_TEXT,text);
}

void SetObjText(string name,string str,int x,int y,color colour,string fontName="Wingdings 3",int fontsize=12) {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,colour);
   ObjectSetInteger(chartId,name,OBJPROP_BACK,false);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(chartId,name,OBJPROP_TEXT,str);
   ObjectSetString(chartId,name,OBJPROP_FONT,fontName);
}

void CreatePanel(string name,int x,int y,int width,int height,color backgroundColor=clrBlack,color borderColor=clrWhite,int borderWidth=1)
  {
   long chartId = 0;
   if(0 < ObjectFind(chartId,name)) ObjectDelete(chartId, name);
   if(ObjectCreate(chartId,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chartId,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chartId,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chartId,name,OBJPROP_COLOR,borderColor);
      ObjectSetInteger(chartId,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(chartId,name,OBJPROP_WIDTH,borderWidth);
      ObjectSetInteger(chartId,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(chartId,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(chartId,name,OBJPROP_BACK,false);
      ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(chartId,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(chartId,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(chartId,name,OBJPROP_ZORDER,0);
      ObjectSetInteger(chartId,name,OBJPROP_BGCOLOR,backgroundColor);
     }
  }

void CreateButton(string btnName,string text,int x,int y,int width,int height,int backgroundColor=clrBlack,int textColor=clrWhite, int fontSize = 8, ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) {
   ResetLastError();
   long chartId = 0;
   if(ObjectFind(chartId,btnName)<0) {
      if(!ObjectCreate(chartId,btnName,OBJ_BUTTON,0,0,0)) {
         Print(__FUNCTION__, ": failed to create the button! Error code = ",ErrorDescription(GetLastError()));
         return;
      }
   }
   ObjectSetString(chartId,btnName,OBJPROP_TEXT,text);
   ObjectSetInteger(chartId,btnName,OBJPROP_XSIZE,width);
   ObjectSetInteger(chartId,btnName,OBJPROP_YSIZE,height);
   ObjectSetInteger(chartId,btnName,OBJPROP_CORNER,corner);
   ObjectSetInteger(chartId,btnName,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,btnName,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,btnName,OBJPROP_BGCOLOR,backgroundColor);
   ObjectSetInteger(chartId,btnName,OBJPROP_COLOR,textColor);
   ObjectSetInteger(chartId,btnName,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,btnName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartId,btnName,OBJPROP_BORDER_TYPE,BORDER_RAISED);

   //ChartRedraw();
}

void CreateEdit(const string           name="Edit",              // object name
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const int              font_size=10,             // font size
                const string           text="Text",              // text
                const string           font="Arial",             // font
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE)       // border color
{
//--- reset the error value
   ResetLastError();
   long chart_ID=0;
   int sub_window=0;
   if(ObjectFind(chart_ID, name)<0) {
//--- create edit field
      if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0)) {
         Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ", ErrorDescription(GetLastError()));
         return;
      }
   }
//--- set object coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK, false);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED, false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN, true);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER, 0);
}

void hiddenMagic() {
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"OPM_MagicNumber",OBJPROP_COLOR,    HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"OPM_MagicNumber",OBJPROP_BGCOLOR,  HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"OPM_MagicNumber",OBJPROP_READONLY, true);
}

void showMagic() {
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"OPM_MagicNumber",OBJPROP_COLOR,    ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"OPM_MagicNumber",OBJPROP_BGCOLOR,  ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"OPM_MagicNumber",OBJPROP_READONLY, false);
}

void setObjShow4Fix() {
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"FixPoint",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",OBJPROP_BGCOLOR,ShowEditBgColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Offset",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Period",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"AppliedPrice",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Ma_Method",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarStep",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarMaximum",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_Deviation",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_LineIndex",OBJPROP_COLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_COLOR,HiddenButtonBgColor);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_COLOR,HiddenButtonBgColor);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",      OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",        OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",        OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",       OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",    OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",  OBJPROP_READONLY,true);
}

void setObjShow4MA() {
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"FixPoint",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",OBJPROP_BGCOLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Offset",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Period",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"AppliedPrice",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Ma_Method",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarStep",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarMaximum",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_Deviation",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_LineIndex",OBJPROP_COLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_COLOR,ClrBtnFtUnselected);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_COLOR,ClrBtnFtUnselected);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",      OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",        OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",        OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",       OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",    OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",  OBJPROP_READONLY,true);
}

void setObjShow4Sar() {
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"FixPoint",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",OBJPROP_BGCOLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Offset",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Period",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"AppliedPrice",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Ma_Method",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarStep",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarMaximum",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_Deviation",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_LineIndex",OBJPROP_COLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_COLOR,HiddenFontColor);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_COLOR,HiddenFontColor);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",      OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",        OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",        OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",       OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",    OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",  OBJPROP_READONLY,true);
}

void setObjShow4ATR() {
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"FixPoint",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",OBJPROP_BGCOLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Offset",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Period",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"AppliedPrice",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Ma_Method",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarStep",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarMaximum",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_Deviation",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_LineIndex",OBJPROP_COLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_COLOR,HiddenFontColor);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_COLOR,HiddenFontColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BGCOLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BORDER_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_COLOR,HiddenFontColor);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",      OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",        OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",        OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",       OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",    OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",  OBJPROP_READONLY,true);
}

void setObjShow4BB() {
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"FixPoint",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",OBJPROP_BGCOLOR,HiddenFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Offset",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Period",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"AppliedPrice",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"Ma_Method",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarStep",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"SarMaximum",OBJPROP_COLOR,HiddenFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",OBJPROP_BGCOLOR,HiddenEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_Deviation",OBJPROP_COLOR,ShowFontColor);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",OBJPROP_BGCOLOR,ShowEditBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"lbl_"+"BB_LineIndex",OBJPROP_COLOR,ShowFontColor);
   
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_CLOSE",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_OPEN",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_HIGH",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_LOW",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_MEDIAN",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_TYPICAL",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"AP_WEIGHTED",OBJPROP_COLOR,ClrBtnFtUnselected);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMA",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_EMA",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_SMMA",OBJPROP_COLOR,HiddenButtonBgColor);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BGCOLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_BORDER_COLOR,HiddenButtonBgColor);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"MM_LWMA",OBJPROP_COLOR,HiddenButtonBgColor);


   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_MAIN",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_UPPER",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BGCOLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_BORDER_COLOR,ClrBtnBgUnselected);
   ObjectSetInteger(0,ObjNamePrefix+"btn_"+"BB_LOWER",OBJPROP_COLOR,ClrBtnFtUnselected);

   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"FixPoint",      OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Offset",        OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"Period",        OBJPROP_READONLY,false);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarStep",       OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"SarMaximum",    OBJPROP_READONLY,true);
   ObjectSetInteger(0,ObjNamePrefix+"edt_"+"BB_Deviation",  OBJPROP_READONLY,false);
}
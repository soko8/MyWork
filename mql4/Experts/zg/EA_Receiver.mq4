//+------------------------------------------------------------------+
//|                                                  EA_Receiver.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <FileUtils.mqh>

enum enumCalculateLotType {
   Fix = 0,
   Balance = 1,
   Equity = 2
};

input string                  SaveSendResultFilePath="D:\\temp\\Result.txt";
input enumCalculateLotType    CalculateLotType=Fix;
input double                  LotSize=1;
input int                     CapitalPerLot=5000;
input int                     MagicNumber=168888;



int OnInit() {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   
}

void OnTick() {}

void OnTimer() {
   if (DoesFileExist(SaveSendResultFilePath)) {
      int fileHandle = OpenExistingFileForReading(SaveSendResultFilePath);
      string msg = ReadWholeFile(fileHandle);
      dealMsg(msg);
      CloseFile(fileHandle);
      DeleteFile(SaveSendResultFilePath);
   }
   
}
double getLotSize(string symbolName) {
   if (Fix == CalculateLotType) {
      return LotSize;
   }
   
   double capital = AccountBalance();
   if (Equity == CalculateLotType) {
      capital = AccountEquity();
   }
   double lot = capital/CapitalPerLot;
   double LotStepServer = MarketInfo(symbolName, MODE_LOTSTEP);
   lot = MathCeil(lot/LotStepServer)*LotStepServer;
   double minLot = MarketInfo(symbolName, MODE_MINLOT);
   if (lot < minLot) {
      lot = minLot;
   }
   
   return lot;
}

void dealMsg(string msg) {
   double slPrice = 0.0;
   double tpPrice = 0.0;
   ushort u_sep = StringGetCharacter(";", 0);
   string result[];
   int k = StringSplit(msg, u_sep, result);
   u_sep = StringGetCharacter(":", 0);
   for (int i=0; i<k-1; i++) {
      string signal[];
      StringSplit(result[i], u_sep, signal);
      int ticket = -1;
      double lotSize = getLotSize(signal[0]);
      if ("Buy" == signal[1]) {
         ticket = OrderSend(signal[0], OP_BUY , lotSize, MarketInfo(signal[0], MODE_ASK), 0, slPrice, tpPrice, "", MagicNumber, 0, clrBlue);
      } else if ("Sell" == signal[1]) {
         ticket = OrderSend(signal[0], OP_SELL , lotSize, MarketInfo(signal[0], MODE_BID), 0, slPrice, tpPrice, "", MagicNumber, 0, clrRed);
      }
      if (ticket < 0) {
         Print("OrderSend failed with error #", GetLastError());
      }
   }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}


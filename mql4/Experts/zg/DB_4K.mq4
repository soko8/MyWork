//+------------------------------------------------------------------+
//|                                                        DB_4K.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#import "DrawDashBoard.ex4"
void DrawDashBoard();
#import

#include <stdlib.mqh>

      int                  PairCount;
      string               TradePairs[];
string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};

const int StartX=4;
const int StartY=4;





int OnInit() {
   ArrayCopy(TradePairs,DefaultPairs);
   PairCount = ArraySize(TradePairs);
   //DrawHeader();
   DrawDashBoard();

//--- create timer
   EventSetTimer(1);
   
//---
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();
}

void OnTick() {

   
}

void OnTimer() {

   
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}


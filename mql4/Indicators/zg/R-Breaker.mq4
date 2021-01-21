//+------------------------------------------------------------------+
//|                                                    R-Breaker.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property strict
#property indicator_chart_window
#include <stdlib.mqh>
//--- input parameters
input ENUM_TIMEFRAMES            TimeFrame=PERIOD_CURRENT;

long                             currentChartId=0;
datetime                         previousBarTime=0;
double                           values[7];
string                           objNameBreakBuy="BreakBuy";
string                           objNameSetupSell="SetupSell";
string                           objNameRevSell="RevSell";
string                           objNamePivot="Pivot";
string                           objNameRevBuy="RevBuy";
string                           objNameSetupBuy="SetupBuy";
string                           objNameBreakSell="BreakSell";

int OnInit() {
   currentChartId=ChartID();
   if(!ObjectCreate(currentChartId,objNameBreakBuy,OBJ_TREND,0,0,0.0,0,0.0)) return(INIT_FAILED);
   if(!ObjectCreate(currentChartId,objNameSetupSell,OBJ_TREND,0,0,0.0,0,0.0)) return(INIT_FAILED);
   if(!ObjectCreate(currentChartId,objNameRevSell,OBJ_TREND,0,0,0.0,0,0.0)) return(INIT_FAILED);
   if(!ObjectCreate(currentChartId,objNamePivot,OBJ_TREND,0,0,0.0,0,0.0)) return(INIT_FAILED);
   if(!ObjectCreate(currentChartId,objNameRevBuy,OBJ_TREND,0,0,0.0,0,0.0)) return(INIT_FAILED);
   if(!ObjectCreate(currentChartId,objNameSetupBuy,OBJ_TREND,0,0,0.0,0,0.0)) return(INIT_FAILED);
   if(!ObjectCreate(currentChartId,objNameBreakSell,OBJ_TREND,0,0,0.0,0,0.0)) return(INIT_FAILED);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll();
}

int OnCalculate(const int rates_total,
                  const int prev_calculated,
                  const datetime &time[],
                  const double &open[],
                  const double &high[],
                  const double &low[],
                  const double &close[],
                  const long &tick_volume[],
                  const long &volume[],
                  const int &spread[])
{
   if (isNewBar(previousBarTime, iTime(NULL, TimeFrame, 0))) {
      previousBarTime = iTime(NULL, TimeFrame, 0);
      getRBreakerValues(iHigh(NULL, TimeFrame, 1), iLow(NULL, TimeFrame, 1), iClose(NULL, TimeFrame, 1), values);
      if(!ObjectMove(currentChartId, objNameBreakBuy, 0, iTime(NULL, TimeFrame, 1), values[0])) Print("Failed to move the anchor point! " + objNameBreakBuy + " Error code = " + ErrorDescription(GetLastError()));
      if(!ObjectMove(currentChartId, objNameBreakBuy, 1, iTime(NULL, TimeFrame, 0), values[0])) Print("Failed to move the anchor point! " + objNameBreakBuy + " Error code = " + ErrorDescription(GetLastError()));
      
      if(!ObjectMove(currentChartId, objNameSetupSell, 0, iTime(NULL, TimeFrame, 1), values[1])) Print("Failed to move the anchor point! " + objNameSetupSell + " Error code = " + ErrorDescription(GetLastError()));
      if(!ObjectMove(currentChartId, objNameSetupSell, 1, iTime(NULL, TimeFrame, 0), values[1])) Print("Failed to move the anchor point! " + objNameSetupSell + " Error code = " + ErrorDescription(GetLastError()));
      
      if(!ObjectMove(currentChartId, objNameRevSell, 0, iTime(NULL, TimeFrame, 1), values[2])) Print("Failed to move the anchor point! " + objNameRevSell + " Error code = " + ErrorDescription(GetLastError()));
      if(!ObjectMove(currentChartId, objNameRevSell, 1, iTime(NULL, TimeFrame, 0), values[2])) Print("Failed to move the anchor point! " + objNameRevSell + " Error code = " + ErrorDescription(GetLastError()));
      
      if(!ObjectMove(currentChartId, objNamePivot, 0, iTime(NULL, TimeFrame, 1), values[3])) Print("Failed to move the anchor point! " + objNamePivot + " Error code = " + ErrorDescription(GetLastError()));
      if(!ObjectMove(currentChartId, objNamePivot, 1, iTime(NULL, TimeFrame, 0), values[3])) Print("Failed to move the anchor point! " + objNamePivot + " Error code = " + ErrorDescription(GetLastError()));
      
      if(!ObjectMove(currentChartId, objNameRevBuy, 0, iTime(NULL, TimeFrame, 1), values[4])) Print("Failed to move the anchor point! " + objNameRevBuy + " Error code = " + ErrorDescription(GetLastError()));
      if(!ObjectMove(currentChartId, objNameRevBuy, 1, iTime(NULL, TimeFrame, 0), values[4])) Print("Failed to move the anchor point! " + objNameRevBuy + " Error code = " + ErrorDescription(GetLastError()));
      
      if(!ObjectMove(currentChartId, objNameSetupBuy, 0, iTime(NULL, TimeFrame, 1), values[5])) Print("Failed to move the anchor point! " + objNameSetupBuy + " Error code = " + ErrorDescription(GetLastError()));
      if(!ObjectMove(currentChartId, objNameSetupBuy, 1, iTime(NULL, TimeFrame, 0), values[5])) Print("Failed to move the anchor point! " + objNameSetupBuy + " Error code = " + ErrorDescription(GetLastError()));
      
      if(!ObjectMove(currentChartId, objNameBreakSell, 0, iTime(NULL, TimeFrame, 1), values[6])) Print("Failed to move the anchor point! " + objNameBreakSell + " Error code = " + ErrorDescription(GetLastError()));
      if(!ObjectMove(currentChartId, objNameBreakSell, 1, iTime(NULL, TimeFrame, 0), values[6])) Print("Failed to move the anchor point! " + objNameBreakSell + " Error code = " + ErrorDescription(GetLastError()));
   }
   
   //--- return value of prev_calculated for next call
   return(rates_total);
}

bool isNewBar(datetime preBarTime, datetime curBarTime) {
   if (preBarTime == curBarTime) {
      return false;
   }
   return true;
}

void getRBreakerValues(double high, double low, double close, double& array[]) {
   double pivot = (high+low+close)/3;
   double breakBuy = high + (pivot-low)*2;
   double setupSell = pivot + (high - low);
   double revSell = pivot*2 - low;
   double revBuy = pivot*2 - high;
   double setupBuy = pivot - (high - low);
   double breakSell = low - (high-pivot)*2;
   
   array[0] = breakBuy;
   array[1] = setupSell;
   array[2] = revSell;
   array[3] = pivot;
   array[4] = revBuy;
   array[5] = setupBuy;
   array[6] = breakSell;
}
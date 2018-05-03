//+------------------------------------------------------------------+
//|                                                icSuperSkyNet.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot crest
#property indicator_label1  "crest"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  4
//--- plot trough
#property indicator_label2  "trough"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  4
//--- plot highLine
#property indicator_label3  "highLine"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot lowLine
#property indicator_label4  "lowLine"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLime
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- plot targetLineLow
#property indicator_label5  "targetLineLow"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLime
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot targetLineHigh
#property indicator_label6  "targetLineHigh"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1

#include <Utils.mqh>

input int Grid_Pips = 180;
input int Retrace_Pips = 60;
input int InpDepth=22;     // Depth
input int InpDeviation=5;  // Deviation
input int InpBackstep=3;   // Backstep

//--- indicator buffers
double         crestBuffer[];
double         troughBuffer[];
double         highLineBuffer[];
double         lowLineBuffer[];
double         targetLineLowBuffer[];
double         targetLineHighBuffer[];

datetime       timeFlag = 0;
double         retracePrice = 0.0;
double         gridPrice = 0.0;
double         deviationPrice = 0.0;

int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0,crestBuffer);
   SetIndexBuffer(1,troughBuffer);
   SetIndexBuffer(2,highLineBuffer);
   SetIndexBuffer(3,lowLineBuffer);
   SetIndexBuffer(4,targetLineLowBuffer);
   SetIndexBuffer(5,targetLineHighBuffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexEmptyValue(3, 0.0);
   SetIndexEmptyValue(4, 0.0);
   SetIndexEmptyValue(5, 0.0);
   
   retracePrice = pips2Price(_Symbol, Retrace_Pips);
   gridPrice = pips2Price(_Symbol, Grid_Pips);
   deviationPrice = pips2Price(_Symbol, 20);
   
//---
   return(INIT_SUCCEEDED);
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
                const int &spread[]) {
   if (rates_total < InpDepth) {
      return rates_total;
   }
   
   if (timeFlag == Time[0]) {
      return rates_total;
   }
   
   timeFlag = Time[0];
   
   int limit = rates_total - prev_calculated;
   
   // 第一次时，所有的柱子，已经计算过时，最近的100根柱子
   if (prev_calculated > 0) {
      //limit++;
      limit = 200;
   } else {
      limit--;
   }
   
   //printf(limit);
   
   for (int i=1; i <= limit; i++) {
      crestBuffer[i] = 0.0;
      troughBuffer[i] = 0.0;
   }
   
   double zz = 0.0;
   for (int i=1; i < limit; i++) {
      zz = iCustom(NULL, 0, "ZigZag", InpDepth, InpDeviation, InpBackstep, 0, i);
      if (isEqualDouble(zz, High[i])) {
         crestBuffer[i] = zz;
      } else if (isEqualDouble(zz, Low[i])) {
         troughBuffer[i] = zz;
      }
      
   }
   
   limit = 1000;
   for (int i = 1; i <= limit; i++) {
      highLineBuffer[i] = 0.0;
      lowLineBuffer[i] = 0.0;
   }
   
   double priceHigh = 0.0;
   double priceLow = 0.0;
   int barHigh = -1;
   int barLow = -1;
   bool foundHigh = false;
   bool foundLow = false;
   double preHigh = 0.0;
   double preLow = 0.0;
   double curHigh = 0.0;
   double curLow = 0.0;
   for (int i = 0; i < limit; i++) {
      if (0.0 < crestBuffer[i]) {
         curHigh = crestBuffer[i];
         // 未找到低点，并且，相邻前一个低点存在
         if (!foundLow && 0.0 < preLow) {
            // 当前高点跟相邻前一个低点的距离>=60点时(第一次往下回调超过60点)
            if (retracePrice <= (curHigh-preLow)) {
               priceLow = preLow;
               barLow = i;
               foundLow = true;
            }
         }
         preHigh = curHigh;
         
      } else if (0.0 < troughBuffer[i]) {
         curLow = troughBuffer[i];
         // 未找到高点，并且，相邻前一个高点存在
         if (!foundHigh && 0.0 < preHigh) {
            // 当前低点跟相邻前一个高点的距离>=60点时(第一次往上回调超过60点)
            if (retracePrice <= (preHigh-curLow)) {
               priceHigh = preHigh;
               barHigh = i;
               foundHigh = true;
            }
         }
         preLow = curLow;
      }
      
      if (foundHigh && foundLow) {
         break;
      }
   }
   
   
   limit = 100;
   
   /*
   printf("foundLow = " + foundLow);
   printf("foundHigh = " + foundHigh);
   printf("priceHigh = " + priceHigh);
   printf("priceLow = " + priceLow);
   printf("barHigh = " + barHigh);
   printf("barLow = " + barLow);
   
   */
   
   if (foundLow && priceLow < Bid) {
      for (int i = 1; i <= limit; i++) {
         lowLineBuffer[i] = 0.0;
      }
      
      int lowestBar = iLowest(NULL, 0, MODE_LOW, barLow, 0);
      double lowestPrice = Low[lowestBar];
      for (int i = 0; i < limit; i++) {
         lowLineBuffer[i] = lowestPrice;
      }

   
   } else if (foundHigh && Ask < priceHigh) {
      for (int i = 1; i <= limit; i++) {
         highLineBuffer[i] = 0.0;
      }
      
      int highestBar = iHighest(NULL, 0, MODE_HIGH, barHigh, 0);
      double highestPrice = High[highestBar];
      for (int i = 0; i < limit; i++) {
         highLineBuffer[i] = highestPrice;
      }
   }
   
   
   for (int i = 1; i <= limit; i++) {
      targetLineLowBuffer[i] = 0.0;
      targetLineHighBuffer[i] = 0.0;
   }
   
   if (0.0 < lowLineBuffer[0]) {
      double targetPrice = lowLineBuffer[0] + gridPrice;
      if (fabs((targetPrice-(Bid+Ask)/2)) <= deviationPrice) {
         for (int i = 0; i < limit; i++) {
            targetLineHighBuffer[i] = targetPrice;
         }
      }
   }
   
   if (0.0 < highLineBuffer[0]) {
      double targetPrice = highLineBuffer[0] - gridPrice;
      if (fabs((targetPrice-(Bid+Ask)/2)) <= deviationPrice) {
         for (int i = 0; i < limit; i++) {
            targetLineLowBuffer[i] = targetPrice;
         }
      }
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}


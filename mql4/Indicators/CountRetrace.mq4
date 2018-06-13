//+------------------------------------------------------------------+
//|                                                 CountRetrace.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <Utils.mqh>

input int InpDepth=22;     // Depth
input int InpDeviation=5;  // Deviation
input int InpBackstep=3;   // Backstep

bool inited = false;
double buff[];

int OnInit() {
   inited = false;
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
                const int &spread[])
{
   if (inited) {
      return(rates_total);
   }
   
   ArrayResize(buff, rates_total);
   
   int count = 0;
   double zz = 0.0;
   for (int i = 0; i < rates_total; i++) {
      zz = iCustom(NULL, 0, "ZigZag", InpDepth, InpDeviation, InpBackstep, 0, i);
      if (isEqualDouble(zz, High[i])) {
         buff[count] = zz;
         count++;
      } else if (isEqualDouble(zz, Low[i])) {
         buff[count] = zz;
         count++;
      }
   }
   
   ArrayResize(buff, count, count);
   
   int diff[];
   int size = count-1;
   ArrayResize(diff, size);
   
   for (int i = 0; i < size; i++) {
      diff[i] = MathAbs(buff[i]-buff[i+1])/Point;
   }
   
   int maxBar = ArrayMaximum(diff);
   int minBar = ArrayMinimum(diff);
   
   printf("max = " + diff[maxBar] + " @" + maxBar);
   
   printf("min = " + diff[minBar] + " @" + minBar);
   
   int total = 0;
   int countOver50 = 0;
   int countOver100 = 0;
   int countOver200 = 0;
   int countOver300 = 0;
   for (int i = 0; i < size; i++) {
      total+= diff[i];
      if (3000 <= diff[i]) {
         countOver300++;
      } else if (2000 <= diff[i]) {
         countOver200++;
      } else if (1000 <= diff[i]) {
         countOver100++;
      } else if (500 <= diff[i]) {
         countOver50++;
      }
   }
   
   double avg = total/size;
   printf("avrage = " + avg);
   printf("count = " + size);
   printf("count Over 50 = " + countOver50);
   printf("count Over 100 = " + countOver100);
   printf("count Over 200 = " + countOver200);
   printf("count Over 300 = " + countOver300);

   return(rates_total);
}


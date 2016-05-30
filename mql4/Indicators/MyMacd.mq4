//+------------------------------------------------------------------+
//|                                                       MyMacd.mq4 |
//|                                        Copyright 2016, Gao Zeng. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Gao Zeng."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot DIF
#property indicator_label1  "DIF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MACD
#property indicator_label2  "MACD"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot OSC
#property indicator_label3  "OSC"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrMistyRose
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- input parameters
input int                     FastEMA=12;
input int                     SlowEMA=26;
input int                     MACD_SMA=9;
input ENUM_APPLIED_PRICE      AppliedPrice = PRICE_CLOSE;
//--- indicator buffers
double         DIFBuffer[];
double         MACDBuffer[];
double         OSCBuffer[];

int OnInit() {

   if(FastEMA<=1 || SlowEMA<=1 || MACD_SMA<=1 || FastEMA>=SlowEMA) {
      Print("Wrong input parameters");
      //ExtParameters=false;
      return(INIT_FAILED);
   }
     
   IndicatorDigits(Digits+1);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexDrawBegin(1,MACD_SMA);
   
//--- indicator buffers mapping
   SetIndexBuffer(0,DIFBuffer);
   SetIndexBuffer(1,MACDBuffer);
   SetIndexBuffer(2,OSCBuffer);
   
   IndicatorShortName("MACD("+IntegerToString(FastEMA)+","+IntegerToString(SlowEMA)+","+IntegerToString(MACD_SMA)+")");
   SetIndexLabel(0,"DIF");
   SetIndexLabel(1,"MACD");
   SetIndexLabel(2,"OSC");
   
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
//---
   if(rates_total <= MACD_SMA) return(0);
   
   //--- last counted bar will be recounted
   int limit = rates_total-prev_calculated;
   
   if (prev_calculated>0) limit++;
   
   //--- macd counted in the 1-st buffer
   for (int i=0; i < limit; i++) {
      DIFBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,AppliedPrice,i) - iMA(NULL,0,SlowEMA,0,MODE_EMA,AppliedPrice,i);             
   }
   
   ExponentialMAOnBuffer(rates_total, prev_calculated, 0, MACD_SMA, DIFBuffer, MACDBuffer);
   
   for (int i=0; i < limit; i++) {
      OSCBuffer[i] = DIFBuffer[i] - MACDBuffer[i];
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//|  Exponential moving average on price array                       |
//+------------------------------------------------------------------+
int ExponentialMAOnBuffer( const int rates_total,
                           const int prev_calculated,
                           const int begin,
                           const int period,
                           const double& price[],
                           double& buffer[]) {

//--- check for data
   if(period <= 1 || rates_total-begin < period) return(0);
   
   double dSmoothFactor = 2.0/(1.0+period);
   
//--- save as_series flags
   bool as_series_price = ArrayGetAsSeries(price);
   bool as_series_buffer = ArrayGetAsSeries(buffer);
   if (as_series_price) ArraySetAsSeries(price, false);
   if (as_series_buffer) ArraySetAsSeries(buffer, false);
   
   int i,limit;
   
//--- first calculation or number of bars was changed
   if(prev_calculated==0) {
      limit=period+begin;
      //--- set empty value for first bars
      for (i=0; i<begin; i++) {
         buffer[i]=0.0;
      }
      
      //--- calculate first visible value
      buffer[begin] = price[begin];
      for (i=begin+1;i<limit;i++) {
         buffer[i]=price[i]*dSmoothFactor+buffer[i-1]*(1.0-dSmoothFactor);
      }
      
   } else {
      limit=prev_calculated-1;
   }
      
//--- main loop
   for(i=limit;i<rates_total;i++) {
      buffer[i]=price[i]*dSmoothFactor+buffer[i-1]*(1.0-dSmoothFactor);
   }
//--- restore as_series flags
   if(as_series_price)  ArraySetAsSeries(price,true);
   if(as_series_buffer) ArraySetAsSeries(buffer,true);

   return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                    MACDColor.mq4 |
//|                                        Copyright 2016, Gao Zeng. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Gao Zeng."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot DIF
#property indicator_label1  "DIF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MACD
#property indicator_label2  "MACD"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot OSCAbove
#property indicator_label3  "OSCAbove"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrSpringGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot OSCZero
#property indicator_label4  "OSCZero"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot OSCBelow
#property indicator_label5  "OSCBelow"
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_color5  clrFireBrick
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input int                     FastEMA=12;
input int                     SlowEMA=26;
input int                     MACD_EMA=9;
input ENUM_APPLIED_PRICE      AppliedPrice = PRICE_CLOSE;
input color                   ColorDIF=clrLime;
input color                   ColorMACD=clrRed;
input color                   ColorOSC4Above=clrSpringGreen;
input color                   ColorOSC4Zero=clrYellow;
input color                   ColorOSC4Below=clrFireBrick;
//--- indicator buffers
double         DIFBuffer[];
double         MACDBuffer[];
double         OSCAboveBuffer[];
double         OSCZeroBuffer[];
double         OSCBelowBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   if(FastEMA<=1 || SlowEMA<=1 || MACD_EMA<=1 || FastEMA>=SlowEMA) {
      Print("Wrong input parameters");
      //ExtParameters=false;
      return(INIT_FAILED);
   }
     
   IndicatorDigits(Digits+1);
   
   SetIndexStyle(0,DRAW_LINE, STYLE_SOLID, 1, ColorDIF);
   SetIndexStyle(1,DRAW_LINE, STYLE_SOLID, 1, ColorMACD);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID, 2, ColorOSC4Above);
   SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_SOLID, 2, ColorOSC4Zero);
   SetIndexStyle(4,DRAW_HISTOGRAM, STYLE_SOLID, 2, ColorOSC4Below);
   SetIndexDrawBegin(1,MACD_EMA);
   
//--- indicator buffers mapping
   SetIndexBuffer(0,DIFBuffer);
   SetIndexBuffer(1,MACDBuffer);
   SetIndexBuffer(2,OSCAboveBuffer);
   SetIndexBuffer(3,OSCZeroBuffer);
   SetIndexBuffer(4,OSCBelowBuffer);
   
   IndicatorShortName("MACD("+IntegerToString(FastEMA)+","+IntegerToString(SlowEMA)+","+IntegerToString(MACD_EMA)+")");
   SetIndexLabel(0,"DIF");
   SetIndexLabel(1,"MACD");
   SetIndexLabel(2,"OSCAbove");
   SetIndexLabel(3,"OSCZero");
   SetIndexLabel(4,"OSCBelow");
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
                
   if(rates_total <= MACD_EMA) return(0);
   
   //--- last counted bar will be recounted
   int limit = rates_total-prev_calculated;
   
   if (prev_calculated>0) limit++;
   
   //--- macd counted in the 1-st buffer
   for (int i=0; i < limit; i++) {
      DIFBuffer[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,AppliedPrice,i) - iMA(NULL,0,SlowEMA,0,MODE_EMA,AppliedPrice,i);             
   }
   
   ExponentialMAOnBuffer(rates_total, prev_calculated, 0, MACD_EMA, DIFBuffer, MACDBuffer);
   
   double osc = 0.0;
   int maxIndex = limit-1;
   for (int i=maxIndex; 0 <= i; i--) {
   
      osc = DIFBuffer[i] - MACDBuffer[i];

      if (0 <  osc) {
         OSCAboveBuffer[i] = osc;
         OSCZeroBuffer[i] = EMPTY_VALUE;
         OSCBelowBuffer[i] = EMPTY_VALUE;
      } else if (0 > osc) {
         OSCAboveBuffer[i] = EMPTY_VALUE;
         OSCZeroBuffer[i] = EMPTY_VALUE;
         OSCBelowBuffer[i] = osc;
      } else {
         OSCAboveBuffer[i] = EMPTY_VALUE;
         OSCZeroBuffer[i] = osc;
         OSCBelowBuffer[i] = EMPTY_VALUE;
      }

      
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
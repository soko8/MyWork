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
#property indicator_width1  1
//--- plot trough
#property indicator_label2  "trough"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot highLine
#property indicator_label3  "highLine"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot lowLine
#property indicator_label4  "lowLine"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLime
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
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
   
//--- return value of prev_calculated for next call
   return(rates_total);
}


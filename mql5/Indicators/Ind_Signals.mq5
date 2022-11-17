//+------------------------------------------------------------------+
//|                                                  Ind_Signals.mq5 |
//|                                        Copyright 2022, Zeng Gao. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Zeng Gao."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4
//--- plot SignalTrendUp
#property indicator_label1  "SignalTrendUp"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrNONE,clrSpringGreen,clrLimeGreen,clrChartreuse,clrLawnGreen,clrGreenYellow,clrMediumSpringGreen,clrPaleGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot SignalTrendDown
#property indicator_label2  "SignalTrendDown"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrNONE,clrCrimson,clrOrangeRed,clrTomato,clrCoral,clrFireBrick,clrIndianRed,clrMaroon
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5
//--- plot SignalOscillatorsUp
#property indicator_label3  "SignalOscillatorsUp"
#property indicator_type3   DRAW_COLOR_ARROW
#property indicator_color3  clrNONE,clrAqua,clrDarkTurquoise,clrTeal,clrMediumSeaGreen,clrDeepSkyBlue,clrCornflowerBlue,clrAquamarine
#property indicator_style3  STYLE_SOLID
#property indicator_width3  4
//--- plot SignalOscillatorsDown
#property indicator_label4  "SignalOscillatorsDown"
#property indicator_type4   DRAW_COLOR_ARROW
#property indicator_color4  clrNONE,clrDeepPink,clrMediumVioletRed,clrPaleVioletRed,clrMagenta,clrMediumVioletRed,clrBlueViolet,clrOrchid
#property indicator_style4  STYLE_SOLID
#property indicator_width4  5
//--- input parameters
#include <ErrorDescription.mqh>

input ENUM_TIMEFRAMES      Applied_TimeFrame=PERIOD_CURRENT;            // 时间帧

input int                  MA_Slow_Period=34;                           // ma周期
input int                  MA_Slow_Shift=0;                             // 移动
input ENUM_MA_METHOD       MA_Slow_Method=MODE_SMA;                     // 平滑类型
input ENUM_APPLIED_PRICE   MA_Slow_Applied_Price=PRICE_CLOSE;           // 价格类型

input int                  MA_Fast_Period=8;                            // ma周期
input int                  MA_Fast_Shift=0;                             // 移动
input ENUM_MA_METHOD       MA_Fast_Method=MODE_EMA;                     // 平滑类型
input ENUM_APPLIED_PRICE   MA_Fast_Applied_Price=PRICE_WEIGHTED;        // 价格类型

input int                  Rsi_Period=14;                               // Rsi周期
input ENUM_APPLIED_PRICE   Rsi_Applied_Price=PRICE_CLOSE;               // Rsi价格类型

input int                  BollingerBands_Period=20;                    // 平均移动周期
input int                  BollingerBands_Shift=0;                      // 移动
input double               BollingerBands_Deviation=2.0;                // 标准偏差数
input ENUM_APPLIED_PRICE   BollingerBands_Applied_Price=PRICE_CLOSE;    // 价格类型

input double               Sar_Step=0.02;                               // Sar停止水平增量
input double               Sar_Maximum=0.2;                             // Sar最大停止水平

input int                  MACD_Fast_Period=12;                         // 快速移动平均数周期
input int                  MACD_Slow_Period=26;                         // 慢速移动平均数周期
input int                  MACD_Signal_Period=9;                        // 不同点的平均周期 
input ENUM_APPLIED_PRICE   MACD_Applied_Price=PRICE_CLOSE;           // 价格类型

input bool                 Alerts_On         =true;
input bool                 Alert_Message     =true;
input bool                 Alert_Sound       =false;
input bool                 Alert_Email       =false;
//--- indicator buffers
double         SignalTrendUpBuffer[];
double         SignalTrendUpColors[];
double         SignalTrendDownBuffer[];
double         SignalTrendDownColors[];
double         SignalOscillatorsUpBuffer[];
double         SignalOscillatorsUpColors[];
double         SignalOscillatorsDownBuffer[];
double         SignalOscillatorsDownColors[];

int            handleMaSlow;
int            handleMaFast;
int            handleRsi;
int            handleBollinger;
int            handleSar;
int            handleMacd;

double         max_period;

int OnInit() {
   handleMaSlow=iMA(_Symbol,Applied_TimeFrame,MA_Slow_Period,MA_Slow_Shift,MA_Slow_Method,MA_Slow_Applied_Price);
   if(handleMaSlow==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d:%s",Symbol(), EnumToString(Period()), GetLastError(), ErrorDescription(GetLastError()));
      return(INIT_FAILED);
   }
   handleMaFast=iMA(_Symbol,Applied_TimeFrame,MA_Fast_Period,MA_Fast_Shift,MA_Fast_Method,MA_Fast_Applied_Price);
   if(handleMaFast==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d:%s",Symbol(), EnumToString(Period()), GetLastError(), ErrorDescription(GetLastError()));
      return(INIT_FAILED);
   }
   handleRsi=iRSI(_Symbol,Applied_TimeFrame,Rsi_Period,Rsi_Applied_Price);
   if(handleRsi==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d:%s",Symbol(), EnumToString(Period()), GetLastError(), ErrorDescription(GetLastError()));
      return(INIT_FAILED);
   }
   handleBollinger=iBands(_Symbol,Applied_TimeFrame,BollingerBands_Period,BollingerBands_Shift,BollingerBands_Deviation,BollingerBands_Applied_Price);
   if(handleBollinger==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d:%s",Symbol(), EnumToString(Period()), GetLastError(), ErrorDescription(GetLastError()));
      return(INIT_FAILED);
   }
   handleSar=iSAR(_Symbol,Applied_TimeFrame,Sar_Step,Sar_Maximum);
   if(handleSar==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d:%s",Symbol(), EnumToString(Period()), GetLastError(), ErrorDescription(GetLastError()));
      return(INIT_FAILED);
   }
   handleMacd=iMACD(_Symbol,Applied_TimeFrame,MACD_Fast_Period,MACD_Slow_Period,MACD_Signal_Period,MACD_Applied_Price);
   if(handleMacd==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d:%s",Symbol(), EnumToString(Period()), GetLastError(), ErrorDescription(GetLastError()));
      return(INIT_FAILED);
   }

//--- indicator buffers mapping
   SetIndexBuffer(0,SignalTrendUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SignalTrendUpColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,SignalTrendDownBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,SignalTrendDownColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,SignalOscillatorsUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,SignalOscillatorsUpColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,SignalOscillatorsDownBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,SignalOscillatorsDownColors,INDICATOR_COLOR_INDEX);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,204);
   PlotIndexSetInteger(1,PLOT_ARROW,122);
   PlotIndexSetInteger(2,PLOT_ARROW,203);
   PlotIndexSetInteger(3,PLOT_ARROW,84);
   
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,5);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,5);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   
   PlotIndexSetInteger(4,PLOT_ARROW_SHIFT,5);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   
   PlotIndexSetInteger(6,PLOT_ARROW_SHIFT,5);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   
   ArraySetAsSeries(SignalTrendUpBuffer,true);
   ArraySetAsSeries(SignalTrendUpColors,true);
   ArraySetAsSeries(SignalTrendDownBuffer,true);
   ArraySetAsSeries(SignalTrendDownColors,true);
   ArraySetAsSeries(SignalOscillatorsUpBuffer,true);
   ArraySetAsSeries(SignalOscillatorsUpColors,true);
   ArraySetAsSeries(SignalOscillatorsDownBuffer,true);
   ArraySetAsSeries(SignalOscillatorsDownColors,true);
//---
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   int limit = rates_total - prev_calculated + 1;
   if(prev_calculated==0) {
      limit = rates_total - 1;
   }
   
   for(int i=limit-1;i>=0;i--) {
      SignalTrendUpBuffer[i]           = EMPTY_VALUE;
      SignalTrendDownBuffer[i]         = EMPTY_VALUE;
      SignalOscillatorsUpBuffer[i]     = EMPTY_VALUE;
      SignalOscillatorsDownBuffer[i]   = EMPTY_VALUE;
      SignalTrendUpColors[i]           = 0;
      SignalTrendDownColors[i]         = 0;
      SignalOscillatorsUpColors[i]     = 0;
      SignalOscillatorsDownColors[i]   = 0;
      //--- 指标缓冲区 
      double         iMASlowBuffer[];
      double         iMAFastBuffer[];
      double         iRsiBuffer[];
      double         iBandsUpperBuffer[];
      double         iBandsLowerBuffer[];
      double         iBandsMiddleBuffer[];
      double         iSarBuffer[];
      double         iMacdMacdBuffer[];
      double         iMacdSignalBuffer[];

      
      ArraySetAsSeries(iMASlowBuffer,true);
      ArraySetAsSeries(iMAFastBuffer,true);
      ArraySetAsSeries(iRsiBuffer,true);
      ArraySetAsSeries(iBandsUpperBuffer,true);
      ArraySetAsSeries(iBandsLowerBuffer,true);
      ArraySetAsSeries(iBandsMiddleBuffer,true);
      ArraySetAsSeries(iSarBuffer,true);
      ArraySetAsSeries(iMacdMacdBuffer,true);
      ArraySetAsSeries(iMacdSignalBuffer,true);
      
      int      start_pos=i;            // start position
      int      count=2;                // amount to copy
      bool get_indicator = true;
      get_indicator = get_indicator && indicatorGet(handleMaSlow,    0,start_pos,count,iMASlowBuffer);
      get_indicator = get_indicator && indicatorGet(handleMaFast,    0,start_pos,count,iMAFastBuffer);
      //get_indicator = get_indicator && indicatorGet(handleRsi,       0,start_pos,count,iRsiBuffer);
      //get_indicator = get_indicator && indicatorGet(handleBollinger, 0,start_pos,count,iBandsUpperBuffer);
      //get_indicator = get_indicator && indicatorGet(handleBollinger, 1,start_pos,count,iBandsLowerBuffer);
      //get_indicator = get_indicator && indicatorGet(handleBollinger, 2,start_pos,count,iBandsMiddleBuffer);
      //get_indicator = get_indicator && indicatorGet(handleSar,       0,start_pos,count,iSarBuffer);
      get_indicator = get_indicator && indicatorGet(handleMacd,      0,start_pos,count,iMacdMacdBuffer);
      get_indicator = get_indicator && indicatorGet(handleMacd,      1,start_pos,count,iMacdSignalBuffer);
      if (!get_indicator) continue;

      /*************************************MA Cross*************************************************************/
      if (iMASlowBuffer[0]<=iMAFastBuffer[0] && iMASlowBuffer[1]>=iMAFastBuffer[1]) {
         SignalTrendUpBuffer[i]  =  low[i]-30*_Point;
         SignalTrendUpColors[i]  =  1;
         if (Alerts_On) doAlert(" MA Cross Long Signal.", time[i], close[i]);
      }
      
      if (iMAFastBuffer[0]<=iMASlowBuffer[0] && iMAFastBuffer[1]>=iMASlowBuffer[1]) {
         SignalTrendDownBuffer[i]   =  high[i]+30*_Point;
         SignalTrendDownColors[i]   =  1;
         if (Alerts_On) doAlert(" MA Cross Short Signal.", time[i], close[i]);
      }
      
      /*************************************MACD Cross***********************************************************/
      if (iMacdMacdBuffer[0]<=iMacdSignalBuffer[0] && iMacdMacdBuffer[1]>=iMacdSignalBuffer[1]) {
         SignalOscillatorsUpBuffer[i]  =  low[i];
         SignalOscillatorsUpColors[i]  =  1;
         if (Alerts_On) doAlert(" MACD Cross Long Signal.", time[i], close[i]);
      }
      
      if (iMacdSignalBuffer[0]<=iMacdMacdBuffer[0] && iMacdSignalBuffer[1]>=iMacdMacdBuffer[1]) {
         SignalOscillatorsDownBuffer[i]   =  high[i];
         SignalOscillatorsDownColors[i]   =  1;
         if (Alerts_On) doAlert(" MACD Cross Short Signal.", time[i], close[i]);
      }
      
      if (0<=iMacdSignalBuffer[0] && 0>=iMacdSignalBuffer[1]) {
         SignalOscillatorsUpBuffer[i]  =  low[i];
         SignalOscillatorsUpColors[i]  =  1;
         if (Alerts_On) doAlert(" MACD Cross 0 Long Signal.", time[i], close[i]);
      }
      
      if (iMacdSignalBuffer[0]<=0 && iMacdSignalBuffer[1]>=0) {
         SignalOscillatorsDownBuffer[i]   =  high[i];
         SignalOscillatorsDownColors[i]   =  1;
         if (Alerts_On) doAlert(" MACD Cross 0 Short Signal.", time[i], close[i]);
      }
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
//---
   
}

bool indicatorGet(int    handle,          // indicator handle
                  int    buffer_num,      // indicator buffer number
                  int    start_pos,       // start position
                  int    count,           // amount to copy
                  double &buffer[]        // target array to copy
                 ) {
   ResetLastError();
   //--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index
   int copiedCount = CopyBuffer(handle,buffer_num,start_pos,count,buffer);
   if(copiedCount != count) {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the indicator, error code %d, error message: %s",GetLastError(),ErrorDescription(GetLastError()));
      PrintFormat("CopyBuffer Parameters: buffer_num=(%d), start_pos=(%d), count=(%d). Copy Result:(%d)",buffer_num,start_pos,count,copiedCount);
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
   return(true);
}

void doAlert(string doWhat, datetime time_last_bar, double close) {
   static string   previousAlert="nothing";
   static datetime previousTime=0;
   string message;
   if(previousAlert!=doWhat || previousTime!=time_last_bar) {
      previousAlert  = doWhat;
      previousTime   = time_last_bar;
      message        = Symbol() + " at " + DoubleToString(close,Digits()) + " " + doWhat;
      if(Alert_Message) Alert(message);
      if(Alert_Email)   SendMail(Symbol()+" 2MACross:"+" M"+EnumToString(Period()),message);
      if(Alert_Sound)   PlaySound("alert2.wav");
   }
}
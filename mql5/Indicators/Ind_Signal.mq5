//+------------------------------------------------------------------+
//|                                                   Ind_Signal.mq5 |
//|                                        Copyright 2022, Zeng Gao. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Zeng Gao."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot LongSignal
#property indicator_label1  "LongSignal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  9
//--- plot ShortSignal
#property indicator_label2  "ShortSignal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  9

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

input bool                 Alerts_On         =true;
input bool                 Alert_Message     =true;
input bool                 Alert_Sound       =false;
input bool                 Alert_Email       =false;

//--- indicator buffers
double         LongSignalBuffer[];
double         ShortSignalBuffer[];

int            handleMaSlow;
int            handleMaFast;
int            handleRsi;
int            handleBollinger;

double         max_period;

int OnInit() {
   handleMaSlow=iMA(_Symbol,Applied_TimeFrame,MA_Slow_Period,MA_Slow_Shift,MA_Slow_Method,MA_Slow_Applied_Price);
   if(handleMaSlow==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",Symbol(), EnumToString(Period()), GetLastError());
      return(INIT_FAILED);
   }
   handleMaFast=iMA(_Symbol,Applied_TimeFrame,MA_Fast_Period,MA_Fast_Shift,MA_Fast_Method,MA_Fast_Applied_Price);
   if(handleMaFast==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",Symbol(), EnumToString(Period()), GetLastError());
      return(INIT_FAILED);
   }
   handleRsi=iRSI(_Symbol,Applied_TimeFrame,Rsi_Period,Rsi_Applied_Price);
   if(handleRsi==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",Symbol(), EnumToString(Period()), GetLastError());
      return(INIT_FAILED);
   }
   handleBollinger=iBands(_Symbol,Applied_TimeFrame,BollingerBands_Period,BollingerBands_Shift,BollingerBands_Deviation,BollingerBands_Applied_Price);
   if(handleBollinger==INVALID_HANDLE) {
      PrintFormat("Failed to create handle of the iBands indicator for the symbol %s/%s, error code %d",Symbol(), EnumToString(Period()), GetLastError());
      return(INIT_FAILED);
   }

//--- indicator buffers mapping
   SetIndexBuffer(0,LongSignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ShortSignalBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
   
   //PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,5);
   //PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-5);
   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
   ArraySetAsSeries(LongSignalBuffer,true);
   ArraySetAsSeries(ShortSignalBuffer,true);
   
   
   max_period = MathMax(MathMax(MathMax(MA_Slow_Period, MA_Fast_Period), Rsi_Period), BollingerBands_Period);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   if(handleMaSlow!=INVALID_HANDLE) IndicatorRelease(handleMaSlow);
   if(handleMaFast!=INVALID_HANDLE) IndicatorRelease(handleMaFast);
   if(handleRsi!=INVALID_HANDLE) IndicatorRelease(handleRsi);
   if(handleBollinger!=INVALID_HANDLE) IndicatorRelease(handleBollinger);
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {

   // very few bars
   if(rates_total < max_period) return(0);
   int limit = rates_total - prev_calculated + 1;
   if(prev_calculated==0) limit = rates_total - 1;

   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   //ArraySetAsSeries(close,true);
   //ArraySetAsSeries(time,true);

   for(int i=limit;i>0;i--) {
      //--- 指标缓冲区 
      double         iMASlowBuffer[];
      double         iMAFastBuffer[];
      double         iRsiBuffer[];
      double         iBandsUpperBuffer[];
      double         iBandsLowerBuffer[];
      double         iBandsMiddleBuffer[];
      
      ArraySetAsSeries(iMASlowBuffer,true);
      ArraySetAsSeries(iMAFastBuffer,true);
      ArraySetAsSeries(iRsiBuffer,true);
      ArraySetAsSeries(iBandsUpperBuffer,true);
      ArraySetAsSeries(iBandsLowerBuffer,true);
      ArraySetAsSeries(iBandsMiddleBuffer,true);
      
      int      start_pos=i;            // start position
      int      count=2;                // amount to copy
      bool get_indicator = true;
      get_indicator = get_indicator && indicatorGet(handleMaSlow,    0,start_pos,count,iMASlowBuffer);
      get_indicator = get_indicator && indicatorGet(handleMaFast,    0,start_pos,count,iMAFastBuffer);
      get_indicator = get_indicator && indicatorGet(handleRsi,       0,start_pos,count,iRsiBuffer);
      get_indicator = get_indicator && indicatorGet(handleBollinger, 0,start_pos,count,iBandsUpperBuffer);
      get_indicator = get_indicator && indicatorGet(handleBollinger, 1,start_pos,count,iBandsLowerBuffer);
      get_indicator = get_indicator && indicatorGet(handleBollinger, 2,start_pos,count,iBandsMiddleBuffer);
      if (!get_indicator) continue;
      
      LongSignalBuffer[i]     = EMPTY_VALUE;
      ShortSignalBuffer[i]    = EMPTY_VALUE;
      
      if (iMASlowBuffer[0]<=iMAFastBuffer[0] && iMASlowBuffer[1]>=iMAFastBuffer[1]) {
         LongSignalBuffer[i] = low[i];
      }
      
      if (iMAFastBuffer[0]<=iMASlowBuffer[0] && iMAFastBuffer[1]>=iMASlowBuffer[1]) {
         ShortSignalBuffer[i] = high[i];
      }
   }

   return(rates_total);
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

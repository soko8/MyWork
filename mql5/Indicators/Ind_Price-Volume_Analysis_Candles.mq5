//+------------------------------------------------------------------+
//|                            Ind_Price-Volume_Analysis_Candles.mq5 |
//|                                        Copyright 2022, Zeng Gao. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Zeng Gao."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

//#define COLOR_Normal       C'102,099,163'
#define COLOR_Normal       clrNONE
#define COLOR_Bull_Rising  C'017,136,255'
//#define COLOR_Bear_Rising  C'173,051,255'
#define COLOR_Bear_Rising  clrGold
#define COLOR_Bull_Climax  C'031,192,071'
#define COLOR_Bear_Climax  C'224,001,006'

#define INDEX_Normal       0
#define INDEX_Bull_Rising  1
#define INDEX_Bear_Rising  2
#define INDEX_Bull_Climax  3
#define INDEX_Bear_Climax  4

//--- plot Candlestick
#property indicator_label1  "Candlestick"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  COLOR_Normal,COLOR_Bull_Rising,COLOR_Bear_Rising,COLOR_Bull_Climax,COLOR_Bear_Climax
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input bool                 Alerts_On         =true;
input bool                 Alert_Message     =true;
input bool                 Alert_Sound       =false;
input bool                 Alert_Email       =false;
input string   Show_Color="Show Candle Color Set";
input color    Candle_Color_Normal=COLOR_Normal;
input color    Candle_Color_Bull_Rising=COLOR_Bull_Rising;
input color    Candle_Color_Bear_Rising=COLOR_Bear_Rising;
input color    Candle_Color_Bull_Climax=COLOR_Bull_Climax;
input color    Candle_Color_Bear_Climax=COLOR_Bear_Climax;


//--- indicator buffers
double         CandlestickBuffer1[];
double         CandlestickBuffer2[];
double         CandlestickBuffer3[];
double         CandlestickBuffer4[];
double         CandlestickColors[];

int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0,CandlestickBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,CandlestickBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,CandlestickBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,CandlestickBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,CandlestickColors,INDICATOR_COLOR_INDEX);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   ArraySetAsSeries(CandlestickBuffer1,true);
   ArraySetAsSeries(CandlestickBuffer2,true);
   ArraySetAsSeries(CandlestickBuffer3,true);
   ArraySetAsSeries(CandlestickBuffer4,true);
   ArraySetAsSeries(CandlestickColors,true);
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Price-Volume_Analysis:");

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
//---
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   

   int limit = rates_total - prev_calculated + 1;
   int count = limit + 10;
   if(prev_calculated==0) {
      limit = rates_total - 1;
      count = rates_total;
   }
   
   long volumes[];
   ArrayResize(volumes, count);
   ArraySetAsSeries(volumes,true);
   int tries=0;
   while (!CopyToBuffers(count, volumes) && tries<5) {
      tries++;
   }
   
   for(int i=limit-1;i>=0;i--) {
      long volumeValue = volumes[i];
      CandlestickBuffer1[i] = open[i];
      CandlestickBuffer2[i] = high[i];
      CandlestickBuffer3[i] = low[i];
      CandlestickBuffer4[i] = close[i];
      CandlestickColors[i] = INDEX_Normal;
      
      if (ArraySize(time) <= i+10) continue;
      
      long av = 0;
      int va = 0;
      for(int j = i+1; j <= i+10; j++) {
         av += volumes[j];
      }
      av = av / 10;
      
      //Climax Volume
      double Range = (high[i]-low[i]);
      double Value2 = volumeValue*Range;
      double HiValue2 = 0;

      for(int j = i+1; j <= i+10; j++) {
         double tempv2 = volumes[j]*((high[j]-low[j]));
         if (tempv2 >= HiValue2) HiValue2 = tempv2;
      }
      if((Value2 >= HiValue2) || (volumeValue >= av * 2)) {va = 1;}
      
      //Rising Volume
      if (va == 0) {
         if(volumeValue >= av * 1.5) {va= 2;}
      }

      //Apply Correct Color to bars
      if(va==1) {
         if (open[i] < close[i]) {
            CandlestickColors[i]=INDEX_Bull_Climax;
            if (Alerts_On) doAlert(" Price-Volume_Analysis Bull_Climax.", time[i], close[i]);
         }
         else {
            CandlestickColors[i]=INDEX_Bear_Climax;
            if (Alerts_On) doAlert(" Price-Volume_Analysis Bear_Climax.", time[i], close[i]);
         }
      }
      else if(va==2) {
         if (open[i] < close[i]) {
            CandlestickColors[i]=INDEX_Bull_Rising;
            if (Alerts_On) doAlert(" Price-Volume_Analysis Bull_Rising.", time[i], close[i]);
         }
         else {
            CandlestickColors[i]=INDEX_Bear_Rising;
            if (Alerts_On) doAlert(" Price-Volume_Analysis Bear_Rising.", time[i], close[i]);
         }
      }
      else {
      /*
         if (open[i] < close[i]) {
            PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, clrWhite);
         }
      */
      }
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}

bool CopyToBuffers(int total, long &volumes[]) {
   int attempts=0;
   int copied=0;
   while(attempts<25 && (copied=CopyTickVolume(NULL,0,0,total,volumes))<0) {
      Sleep(100);
      attempts++;
      PrintFormat("%s CopyTickVolume(%d) attempts=%d",__FUNCTION__,total,attempts);
   }
   if(copied!=total) {
      Print("For the symbol %s, managed to receive only %d bars of %d requested ones", _Symbol, copied, total);
      return false;
   }
   return true;
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
      if(Alert_Email)   SendMail(Symbol()+" PVA:"+" M"+EnumToString(Period()),message);
      if(Alert_Sound)   PlaySound("alert2.wav");
   }
}
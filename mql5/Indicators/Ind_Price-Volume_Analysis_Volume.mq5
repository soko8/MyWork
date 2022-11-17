//+------------------------------------------------------------------+
//|                             Ind_Price-Volume_Analysis_Volume.mq5 |
//|                                        Copyright 2022, Zeng Gao. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Zeng Gao."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_minimum 0

//#define COLOR_Normal       C'102,099,163'
#define COLOR_Normal       clrDimGray
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

//--- plot Volume
#property indicator_label1  "Volume"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  COLOR_Normal,COLOR_Bull_Rising,COLOR_Bear_Rising,COLOR_Bull_Climax,COLOR_Bear_Climax,clrWhite,clrWhite,clrWhite
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1



//--- input parameters
input string   Show_Color="Show Bar Color Set";
input color    Histogram_Color_Normal=COLOR_Normal;
input color    Histogram_Color_Bull_Rising=COLOR_Bull_Rising;
input color    Histogram_Color_Bear_Rising=COLOR_Bear_Rising;
input color    Histogram_Color_Bull_Climax=COLOR_Bull_Climax;
input color    Histogram_Color_Bear_Climax=COLOR_Bear_Climax;
//--- indicator buffers
double         VolumeBuffer[];
double         VolumeColors[];

int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0,VolumeBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,VolumeColors,INDICATOR_COLOR_INDEX);
   
   ArraySetAsSeries(VolumeBuffer,true);
   ArraySetAsSeries(VolumeColors,true);
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Price-Volume_Analysis:");
   //PlotIndexSetString(0,PLOT_LABEL,"Main");
   //PlotIndexSetString(1,PLOT_LABEL,"Signal");
   setBarWidth();
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
   ArraySetAsSeries(tick_volume,true);

   /*int bars=Bars(Symbol(),0); 
   Print("Bars = ",bars,", rates_total = ",rates_total,",  prev_calculated = ",prev_calculated); 
   Print("time[0] = ",time[0]," time[rates_total-1] = ",time[rates_total-1]); 
*/
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
      VolumeBuffer[i] = int(volumeValue);
      VolumeColors[i] = INDEX_Normal;
      //Print("tick_volume[i] = ",tick_volume[i],", volume[] = ",volume[i],",  iVolume = ",iVolume(Symbol(),0,i), ",  iTickVolume = ",iTickVolume(Symbol(),0,i), ",  iRealVolume = ",iRealVolume(Symbol(),0,i));
      if (ArraySize(time) <= i+10) continue;
      //if (limit<10) Print("open[" + i +"]=" + open[i] + ", close:=" + close[i] + ", @" + time[i]);
      long av = 0;
      int va = 0;
      //Rising Volume
      for(int j = i+1; j <= i+10; j++) {
         //Print("volumeValue==", volumeValue, ", count===",count,",limit==",limit,"  ,i=",i,"  ,volume[",j,"]=",volumes[j]);
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
            //if (20 < i && i< 100) Print("INDEX_Bull_Climax==" + INDEX_Bull_Climax);
            VolumeColors[i]=INDEX_Bull_Climax;
         }
         else {
            //if (20 < i && i< 100) Print("INDEX_Bear_Climax==" + INDEX_Bear_Climax);
            VolumeColors[i]=INDEX_Bear_Climax;
         }
      }
      else if(va==2) {
         if (open[i] < close[i]) {
            VolumeColors[i]=INDEX_Bull_Rising;
         }
         else {
            VolumeColors[i]=INDEX_Bear_Rising;
         }
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}

/*
long iVolume_(const int shift){
   long timeseries[1];
   if(CopyTickVolume(NULL,0,shift,1,timeseries)==1)
      return timeseries[0];
   return -1;
}
*/
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   //Print("id==",id,",  lparam==", lparam, ",  dparam==", dparam, ", sparam==", sparam);
   setBarWidth();
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

void setBarWidth() {
   long Chart_Scale = -1;
   ChartGetInteger(0,CHART_SCALE,0,Chart_Scale);
   
   int Bar_Width = 0;
   //Set bar widths
         if(Chart_Scale == 0) {Bar_Width = 1;}
   else {if(Chart_Scale == 1) {Bar_Width = 2;}
   else {if(Chart_Scale == 2) {Bar_Width = 2;}
   else {if(Chart_Scale == 3) {Bar_Width = 3;}
   else {if(Chart_Scale == 4) {Bar_Width = 6;}
   else {Bar_Width = 13;} }}}}
   
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,Bar_Width);
}
//+------------------------------------------------------------------+
//|                                                       Spread.mq4 |
//|                                 Copyright ?2014,   Tickmill Ltd |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2014, Tickmill Ltd"

#property indicator_chart_window

extern color font_color = White;
extern int font_size = 14;
extern string font_face = "Arial";
extern int corner = 1; //0 - for top-left corner, 1 - top-right, 2 - bottom-left, 3 - bottom-right
extern int spread_distance_x = 1;
extern int spread_distance_y = 1;
extern bool normalize = false; //If true then the spread is normalized to traditional pips

double Poin;
int n_digits = 1;
double divider = 10;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   //Checking for unconvetional Point digits number
   if (Point == 0.00001) Poin = 0.0001; //5 digits
   else if (Point == 0.0001) Poin = 0.001; //3 digits
   else Poin = Point; //Normal
   
   ObjectCreate("Spread", OBJ_LABEL, 0, 0, 0);
   ObjectSet("Spread", OBJPROP_CORNER, corner);
   ObjectSet("Spread", OBJPROP_XDISTANCE, spread_distance_x);
   ObjectSet("Spread", OBJPROP_YDISTANCE, spread_distance_y);
   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   
   if ((Poin > Point) && (normalize))
   {
      divider = 10.0;
      n_digits = 2;
   }
   
   ObjectSetText("Spread", "Spread: " + DoubleToStr(NormalizeDouble(spread / divider, 1), n_digits) + " points.", font_size, font_face, font_color);



   ObjectCreate("SwapLong", OBJ_LABEL, 0, 0, 0);
   ObjectSet("SwapLong", OBJPROP_CORNER, corner);
   ObjectSet("SwapLong", OBJPROP_XDISTANCE, 110);
   ObjectSet("SwapLong", OBJPROP_YDISTANCE, spread_distance_y);
   double swapLong = NormalizeDouble(MarketInfo(Symbol(), MODE_SWAPLONG), 2);
   printf("swapLong:" + swapLong);
   ObjectSetText("SwapLong", "SwapL: " + DoubleToStr(swapLong, 2) + "", font_size, font_face, font_color);
   
   ObjectCreate("SwapShort", OBJ_LABEL, 0, 0, 0);
   ObjectSet("SwapShort", OBJPROP_CORNER, corner);
   ObjectSet("SwapShort", OBJPROP_XDISTANCE, 250);
   ObjectSet("SwapShort", OBJPROP_YDISTANCE, spread_distance_y);
   double swapShort = NormalizeDouble(MarketInfo(Symbol(), MODE_SWAPSHORT), 2);
   ObjectSetText("SwapShort", "SwapS: " + DoubleToStr(swapShort, 2) + "", font_size, font_face, font_color);
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete("Spread");
   ObjectDelete("SwapLong");
   ObjectDelete("SwapShort");
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   RefreshRates();
   
   double spread = (Ask - Bid) / Point;
   ObjectSetText("Spread", "Sprd: " + DoubleToStr(NormalizeDouble(spread / divider, 1), n_digits) + "", font_size, font_face, font_color);
    
    //double swapLong = NormalizeDouble(MarketInfo(Symbol(), MODE_SWAPLONG), 3);
    //ObjectSetText("Long:", " " + DoubleToStr(swapLong, 3) + "", font_size, font_face, font_color);
    //double swapShort = NormalizeDouble(MarketInfo(Symbol(), MODE_SWAPSHORT), 3);
   //ObjectSetText("Short:", " " + DoubleToStr(swapShort, 3) + "", font_size, font_face, font_color);
    
   return(0);
}
//+------------------------------------------------------------------+
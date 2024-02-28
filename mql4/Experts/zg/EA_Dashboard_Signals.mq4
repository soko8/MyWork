//+------------------------------------------------------------------+
//|                                         EA_Dashboard_Signals.mq4 |
//|                                        Copyright 2024, Zeng Gao. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Zeng Gao."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <stdlib.mqh>
#include <Arrays\List.mqh>


struct sign_settings {
   int      xAdjust;
   int      yAdjust;
   int      fontSize;
   string   sign;
   string   fontName;
   color    fontColor;
   color    bgColor;
   color    bdColor;
};

enum ENUM_INDICATOR
  {
   IND_AC,           // Accelerator Oscillator
   IND_AD,           // Accumulation/Distribution
   IND_ADX,          // Average Directional Index
   IND_ADXW,         // ADX by Welles Wilder
   IND_ALLIGATOR,    // Alligator
   IND_AMA,          // Adaptive Moving Average
   IND_AO,           // Awesome Oscillator
   IND_ATR,          // Average True Range
   IND_BANDS,        // Bollinger Bandsｮ
   IND_BEARS,        // Bears Power
   IND_BULLS,        // Bulls Power
   IND_BWMFI,        // Market Facilitation Index
   IND_CCI,          // Commodity Channel Index
   IND_CHAIKIN,      // Chaikin Oscillator
   IND_CUSTOM,       // Custom indicator
   IND_DEMA,         // Double Exponential Moving Average
   IND_DEMARKER,     // DeMarker
   IND_ENVELOPES,    // Envelopes
   IND_FORCE,        // Force Index
   IND_FRACTALS,     // Fractals
   IND_FRAMA,        // Fractal Adaptive Moving Average
   IND_GATOR,        // Gator Oscillator
   IND_ICHIMOKU,     // Ichimoku Kinko Hyo
   IND_MA,           // Moving Average
   IND_MACD,         // MACD
   IND_MFI,          // Money Flow Index
   IND_MOMENTUM,     // Momentum
   IND_OBV,          // On Balance Volume
   IND_OSMA,         // OsMA
   IND_RSI,          // Relative Strength Index
   IND_RVI,          // Relative Vigor Index
   IND_SAR,          // Parabolic SAR
   IND_STDDEV,       // Standard Deviation
   IND_STOCHASTIC,   // Stochastic Oscillator
   IND_TEMA,         // Triple Exponential Moving Average
   IND_TRIX,         // Triple Exponential Moving Averages Oscillator
   IND_VIDYA,        // Variable Index Dynamic Average
   IND_VOLUMES,      // Volumes
   IND_WPR           // Williams' Percent Range
  };


enum ENUM_TREND {
   TREND_LONG_STRONG,
   TREND_LONG,
   TREND_LONG_WEAK,
   TREND_SHORT_STRONG,
   TREND_SHORT,
   TREND_SHORT_WEAK,
   TREND_NONE
};

enum ENUM_CROSS {
   CROSS_MA_LONG,
   CROSS_MA_SHORT,
   CROSS_MACD_BELOW0_LONG,                // 0轴下面金叉
   CROSS_MACD_OVER0_LONG,                 // 0轴上面金叉
   CROSS_MACD_BELOW0_SHORT,               // 0轴下面死叉
   CROSS_MACD_OVER0_SHORT,                // 0轴上面死叉
   CROSS_MACD_0AXIS_BOTTOM2TOP_MAIN,      // 快线上穿0轴
   CROSS_MACD_0AXIS_BOTTOM2TOP_SIGNAL,    // 慢线上穿0轴
   CROSS_MACD_0AXIS_TOP2BOTTOM_MAIN,      // 快线下穿0轴
   CROSS_MACD_0AXIS_TOP2BOTTOM_SIGNAL,    // 慢线下穿0轴
   CROSS_ADX_LONG,
   CROSS_ADX_SHORT,
   CROSS_ADX_DIPLUS_BOTTOM2TOP,           // ADX线从下往上穿过DI+
   CROSS_ADX_DIPLUS_TOP2BOTTOM,           // ADX线从上往下穿过DI+
   CROSS_ADX_DIMINUS_BOTTOM2TOP,          // ADX线从下往上穿过DI-
   CROSS_ADX_DIMINUS_TOP2BOTTOM,          // ADX线从上往下穿过DI-
   CROSS_RSI_LONG,
   CROSS_RSI_SHORT,
   CROSS_KDJ_LONG,
   CROSS_KDJ_SHORT,
   CROSS_KDJ_OVER_100,
   CROSS_KDJ_BELOW_0,
   CROSS_KDJ_OVERBOUGHT,
   CROSS_KDJ_OVERSOLD,
   CROSS_NONE
};

enum ENUM_INDICATOR_CUSTOM {
   IND_MA_CROSS,
   IND_MACD_CROSS,
   IND_RSI_CROSS,
   IND_KDJ_CROSS,
   IND_BANDS_CROSS,
   IND_ICHIMOKU_CROSS,
   IND_ADX_CROSS
};

#define TIMEFRAME_COUNT                         7
#define INDICATOR_TYPE_COUNT                    5
#define BAR_INDEX                               1
#define WIDTH_MV                                18
#define WIDTH_MV_4K                             25
#define WIDTH_NEW_ORDER                         18
#define WIDTH_NEW_ORDER_4K                      25
#define WIDTH_SYMBOL                            60
#define WIDTH_SYMBOL_4K                         108
#define WIDTH_SIGNAL                            40
#define WIDTH_SIGNAL_4K                         60
#define HEIGHT_ROW                              19
#define HEIGHT_ROW_4K                           36
#define HEIGHT_ROW_MA                           19
#define HEIGHT_ROW_MA_4K                        35
#define HEIGHT_ROW_ADX                          24
#define HEIGHT_ROW_ADX_4K                       30
#define HEIGHT_ROW_HEADER                       14
#define HEIGHT_ROW_HEADER_4K                    26


class CIndicatorBase : public CObject {
private:
protected:
   string            symbol;
   ENUM_TIMEFRAMES   timeframe;
   int               type;
   string            name;
public:
                     CIndicatorBase(void) {}
                    ~CIndicatorBase(void) {}
   string            getSymbol(void)                     const { return(symbol);    }
   ENUM_TIMEFRAMES   getTimeframe(void)                  const { return(timeframe); }
   void              setSymbol(const string v)                 { this.symbol=v;     }
   void              setTimeframe(const ENUM_TIMEFRAMES v)     { this.timeframe=v;  }
   virtual double    GetData(const int index, const int buffer_num=0)   const { return 0.0;}
};

class CiMAStandard : public CIndicatorBase {
private:
protected:
   int                  period;
   ENUM_MA_METHOD       method;
   ENUM_APPLIED_PRICE   applied_price;
   int                  shift;
public:
                        CiMAStandard(const string pair, const ENUM_TIMEFRAMES tf, const int p, const ENUM_MA_METHOD m, const ENUM_APPLIED_PRICE ap, const int s=0) {
                           this.type = IND_MA; this.name = "MA";
                           this.symbol = pair; this.timeframe = tf; this.period = p; this.method = m; this.applied_price = ap; this.shift = s;
                        }
                       ~CiMAStandard(void) {}
   int                  getPeriod(void)                        const { return(period);          }
   ENUM_MA_METHOD       getMethod(void)                        const { return(method);          }
   ENUM_APPLIED_PRICE   getAppliedPrice(void)                  const { return(applied_price);   }
   int                  getShift(void)                         const { return(shift);           }
   void                 setPeriod(const int v)                       { this.period=v;           }
   void                 setMethod(const ENUM_MA_METHOD v)            { this.method=v;           }
   void                 setAppliedPrice(const ENUM_APPLIED_PRICE v)  { this.applied_price=v;    }
   void                 setShift(const int v)                        { this.shift=v;            }
   virtual double       GetData(const int index, const int buffer_num=0)  const {
                           return(iMA(symbol,timeframe,period,shift,method,applied_price,index));
                        }
};

class CiMACDStandard : public CIndicatorBase {
private:
protected:
   int                  fast_ema_period;
   int                  slow_ema_period;
   int                  signal_period;
   ENUM_APPLIED_PRICE   applied_price;
public:
                        CiMACDStandard(const string pair, const ENUM_TIMEFRAMES tf, const int fep, const int sep, const int sp, const ENUM_APPLIED_PRICE ap) {
                           this.type = IND_MACD; this.name = "MACD";
                           this.symbol = pair; this.timeframe = tf; this.fast_ema_period = fep; this.slow_ema_period = sep; this.signal_period = sp; this.applied_price = ap;
                        }
                       ~CiMACDStandard(void) {}
   int                  getFastEmaPeriod(void)                 const { return(fast_ema_period); }
   int                  getSlowEmaPeriod(void)                 const { return(slow_ema_period); }
   int                  getSignalPeriod(void)                  const { return(signal_period);   }
   ENUM_APPLIED_PRICE   getAppliedPrice(void)                  const { return(applied_price);   }
   
   void                 setFastEmaPeriod(const int v)                { this.fast_ema_period=v;  }
   void                 setSlowEmaPeriod(const int v)                { this.slow_ema_period=v;  }
   void                 setSignalPeriod(const int v)                 { this.signal_period=v;    }
   void                 setAppliedPrice(const ENUM_APPLIED_PRICE v)  { this.applied_price=v;    }
   
   virtual double       GetData(const int index, const int buffer_num=0)  const {
                           return(iMACD(symbol,timeframe,fast_ema_period,slow_ema_period,signal_period,applied_price,buffer_num,index));
                        }
};

class CiRSIStandard : public CIndicatorBase {
private:
protected:
   int                  period;
   ENUM_APPLIED_PRICE   applied_price;
public:
                        CiRSIStandard(const string pair, const ENUM_TIMEFRAMES tf, const int p, const ENUM_APPLIED_PRICE ap) {
                           this.type = IND_RSI; this.name = "RSI";
                           this.symbol = pair; this.timeframe = tf; this.period = p; this.applied_price = ap;
                        }
                       ~CiRSIStandard(void) {}
   int                  getPeriod(void)                        const { return(period);          }
   ENUM_APPLIED_PRICE   getAppliedPrice(void)                  const { return(applied_price);   }
   void                 setPeriod(const int v)                       { this.period=v;           }
   void                 setAppliedPrice(const ENUM_APPLIED_PRICE v)  { this.applied_price=v;    }
   virtual double       GetData(const int index, const int buffer_num=0) const {
                           return(iRSI(symbol,timeframe,period,applied_price,index));
                        }
};

class CiADXStandard : public CIndicatorBase {
private:
protected:
   int                  period;
   ENUM_APPLIED_PRICE   applied_price;
public:
                        CiADXStandard(const string pair, const ENUM_TIMEFRAMES tf, const int p, const ENUM_APPLIED_PRICE ap) {
                           this.type = IND_ADX; this.name = "ADX";
                           this.symbol = pair; this.timeframe = tf; this.period = p; this.applied_price = ap;
                        }
                       ~CiADXStandard(void) {}
   int                  getPeriod(void)                        const { return(period);          }
   ENUM_APPLIED_PRICE   getAppliedPrice(void)                  const { return(applied_price);   }
   void                 setPeriod(const int v)                       { this.period=v;           }
   void                 setAppliedPrice(const ENUM_APPLIED_PRICE v)  { this.applied_price=v;    }
   virtual double       GetData(const int index, const int buffer_num=0) const {
                           return(iADX(symbol,timeframe,period,applied_price,buffer_num,index));
                        }
};

class CiKDJStandard : public CIndicatorBase {
private:
protected:
   int                  Kperiod;
   int                  Dperiod;
   int                  slowing;
   ENUM_MA_METHOD       method;
   int                  price_field;    // price (0 - Low/High or 1 - Close/Close)
public:
                        CiKDJStandard(const string pair, const ENUM_TIMEFRAMES tf, const int kp, const int dp, const int jp, const ENUM_MA_METHOD m, const int pf=0) {
                           this.type = IND_STOCHASTIC; this.name = "KDJ";
                           this.symbol = pair; this.timeframe = tf; this.Kperiod = kp; this.method = m; this.price_field = pf; this.Dperiod = dp; this.slowing = jp;
                        }
                       ~CiKDJStandard(void) {}
   int                  getPeriodK(void)                       const { return(Kperiod);         }
   int                  getPeriodD(void)                       const { return(Dperiod);         }
   int                  getPeriodJ(void)                       const { return(slowing);         }
   ENUM_MA_METHOD       getMethod(void)                        const { return(method);          }
   int                  getPriceField(void)                    const { return(price_field);     }
   void                 setPeriodK(const int v)                      { this.Kperiod=v;          }
   void                 setPeriodD(const int v)                      { this.Dperiod=v;          }
   void                 setPeriodJ(const int v)                      { this.slowing=v;          }
   void                 setMethod(const ENUM_MA_METHOD v)            { this.method=v;           }
   void                 setPriceField(const int v)                   { this.price_field=v;      }
   virtual double       GetData(const int index, const int buffer_num=0)  const {
                           return(iStochastic(symbol,timeframe,Kperiod,Dperiod,slowing,method,price_field,buffer_num,index));
                        }
};

bool isCrossUp(double v11, double v12, double v21, double v22) {
   if (v12<v11 && v22>=v21) return true;
   
   return false;
}

bool isCrossDown(double v11, double v12, double v21, double v22) {
   if (v12>v11 && v22<=v21) return true;
   
   return false;
}
/***********************************************Start*********************************************************************/
class CIndicatorCustom : public CObject {
private:
protected:
   string            symbol;
   ENUM_TIMEFRAMES   timeframe;
   CList            *indicators;
   int               indicatorType;
   string            indicatorName;
   bool              enable;
public:
                     CIndicatorCustom(void) { indicators = new CList(); }
                    ~CIndicatorCustom(void) { delete indicators; }
   CIndicatorBase      *GetInicatorAtIndex(const int i) const { return this.indicators.GetNodeAtIndex(i); }
   int                  getType(void)                       const { return this.indicatorType; }
   string               getName(void)                       const { return this.indicatorName; }
   string               getSymbol(void)                     const { return(symbol);    }
   ENUM_TIMEFRAMES      getTimeframe(void)                  const { return(timeframe); }
   void                 setSymbol(const string v)                 { this.symbol=v;     }
   void                 setTimeframe(const ENUM_TIMEFRAMES v)     { this.timeframe=v;  }
   void                 setEnable(bool v)                         { this.enable=v;     }
   bool                 isEnable(void)                      const { return this.enable;}
   virtual bool         Create(const MqlParam &params[])    const { return true;       }
   virtual ENUM_TREND   GetTrend(const int index)           const { return TREND_NONE; }
   virtual ENUM_CROSS   GetCross(const int index)           const { return CROSS_NONE; }

};

/*********************************************** End *********************************************************************/

/***********************************************Start*********************************************************************/
class CMACross : public CIndicatorCustom {
protected:

public:
                        CMACross(const string pair, const ENUM_TIMEFRAMES tf) {
                           this.symbol = pair; this.timeframe = tf; this.indicatorType = IND_MA_CROSS; this.indicatorName = "MA";
                        }
                       ~CMACross(void) {}
   virtual bool         Create(const MqlParam &params[]) const;
   virtual ENUM_TREND   GetTrend(const int index) const;
   virtual ENUM_CROSS   GetCross(const int index) const;
};
bool CMACross::Create(const MqlParam &params[]) const {
   CiMAStandard *ma = new CiMAStandard(symbol, timeframe, (int) params[0].integer_value, (ENUM_MA_METHOD) params[1].integer_value, (ENUM_APPLIED_PRICE) params[2].integer_value, (int) params[3].integer_value);
   int countIndicator = this.indicators.Total();
   this.indicators.Add(ma);
   int newCount = this.indicators.Total();
   //Print("row====", 1096, " newCount=", newCount, " countIndicator==", countIndicator);
   return (newCount==(countIndicator+1));
}
ENUM_TREND CMACross::GetTrend(const int index) const {
   ENUM_TREND result = TREND_NONE;
   int countIndicators = this.indicators.Total();
   double values[];
   ArrayResize(values, countIndicators);
   bool isL=true, isS=true;
//Print("countIndicators ==", countIndicators);
   for (int i=0; i<countIndicators; i++) {
      CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(i);
      values[i] = indicator.GetData(index);
      if (0 < i) {
//Print("values[", i, "]=", values[i]," values[", i-1, "]=", values[i-1], " isL=", isL, " isS=", isS);
         if (values[i] < values[i-1]) isS=false;
         else if (values[i] > values[i-1]) isL=false;
      }
   }

   if (isL) return TREND_LONG;
   if (isS) return TREND_SHORT;
   return result;
}

ENUM_CROSS CMACross::GetCross(const int index) const {
   ENUM_CROSS result = CROSS_NONE;
   int countIndicators = this.indicators.Total();
   double values[4];
   //ArrayResize(values, countIndicators);
   bool isUp=false, isDown=false;
   for (int i=0; i<countIndicators-1; i++) {
      CIndicatorBase *indicatorI = this.indicators.GetNodeAtIndex(i);
      values[0] = indicatorI.GetData(index);
      values[2] = indicatorI.GetData(index+1);
      for (int j=i+1; j<countIndicators; j++) {
         CIndicatorBase *indicatorJ = this.indicators.GetNodeAtIndex(j);
         values[1] = indicatorJ.GetData(index);
         values[3] = indicatorJ.GetData(index+1);
         if (isCrossUp(values[0], values[1], values[2], values[3])) return CROSS_MA_LONG;
         if (isCrossDown(values[0], values[1], values[2], values[3])) return CROSS_MA_SHORT;
      }
   }
   return result;
}
/*********************************************** End *********************************************************************/

/***********************************************Start*********************************************************************/
class CMACDCross : public CIndicatorCustom {
protected:

public:
                        CMACDCross(const string pair, const ENUM_TIMEFRAMES tf) {
                           this.symbol = pair; this.timeframe = tf; this.indicatorType = IND_MACD_CROSS; this.indicatorName = "MACD";
                        }
                       ~CMACDCross(void) {}
   virtual bool         Create(const MqlParam &params[]) const;
   virtual ENUM_TREND   GetTrend(const int index) const;
   virtual ENUM_CROSS   GetCross(const int index) const;
};
bool CMACDCross::Create(const MqlParam &params[]) const {
   CiMACDStandard *macd = new CiMACDStandard(symbol, timeframe, (int) params[0].integer_value, (int) params[1].integer_value, (int) params[2].integer_value, (ENUM_APPLIED_PRICE) params[3].integer_value);
   int countIndicator = this.indicators.Total();
   this.indicators.Add(macd);
   int newCount = this.indicators.Total();
   return (newCount==(countIndicator+1));
}
ENUM_TREND CMACDCross::GetTrend(const int index) const {
   ENUM_TREND result = TREND_NONE;
   CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(0);
   double macdVal = indicator.GetData(index, MODE_MAIN);
   double signalVal = indicator.GetData(index, MODE_SIGNAL);

   if (0 < macdVal) {
      if (0 <= signalVal) {
         if (signalVal < macdVal) result=TREND_LONG_STRONG; else result=TREND_LONG;
      }
      else {
         result=TREND_LONG_WEAK;
      }
   } else {
      if (signalVal <= 0) {
         if (macdVal < signalVal) result=TREND_SHORT_STRONG; else result=TREND_SHORT;
      } else {
         result=TREND_SHORT_WEAK;
      }
   }
//Print("macdVal=", macdVal, " signalVal=", signalVal, " trend=", EnumToString(result));
   return result;
}

ENUM_CROSS CMACDCross::GetCross(const int index) const {
   CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(0);
   double macdVal1 = indicator.GetData(index, MODE_MAIN);
   double signalVal1 = indicator.GetData(index, MODE_SIGNAL);
   double macdVal2 = indicator.GetData(index+1, MODE_MAIN);
   double signalVal2 = indicator.GetData(index+1, MODE_SIGNAL);
   if (signalVal2<=0 && 0<signalVal1) return CROSS_MACD_0AXIS_BOTTOM2TOP_SIGNAL;
   if (0<=signalVal2 && signalVal1<0) return CROSS_MACD_0AXIS_TOP2BOTTOM_SIGNAL;
   if (macdVal2<=0 && 0<macdVal1) return CROSS_MACD_0AXIS_BOTTOM2TOP_MAIN;
   if (0<=macdVal2 && macdVal1<0) return CROSS_MACD_0AXIS_TOP2BOTTOM_MAIN;
   
   if (isCrossUp(macdVal1, signalVal1, macdVal2, signalVal2)) {
      if (0 <= signalVal1) return CROSS_MACD_OVER0_LONG; else return CROSS_MACD_BELOW0_LONG;
   }
   
   if (isCrossDown(macdVal1, signalVal1, macdVal2, signalVal2)) {
      if (signalVal1 <= 0) return CROSS_MACD_BELOW0_SHORT; else return CROSS_MACD_OVER0_SHORT;
   }
   
   return CROSS_NONE;
}
/*********************************************** End *********************************************************************/

/***********************************************Start*********************************************************************/
/*
平均趋向指标的交易法则：
　　1、当＋DI13大于－DI13时，仅由多方进行交易。当－DI13大于＋DI13时，仅由空方进行交易。
　　最适合进场做多的时机是：＋DI13与ADX都位在－DI13的上方，而且ADX上升，这代表上升趋势正在转强，建立多头部位之后，停损设定在最近次要低点的下侧。
　　最适合进场做空的时机是：－DI13与ADX都位在＋DI13的上方，而且ADX上升，这代表下降趋势正在转强，建立空头部位之后，停损设定在最近次要高点的上侧。
　　2、当ADX下降时，代表市场逐渐丧失方向感。这就如同涨、退潮之间的水流方向变幻莫测。
　　当ADX下降时，最好不要采用顺势交易方法，因为经常发生反复的讯号。
　　3、当ADX下降而同时低于两条趋向线，这代表沉闷的横向走势。不可采用顺势交易方法，但应该开始准备，因为这相当于是暴风雨之前的宁静，主要的趋势经常由此发动。
　　4、当ADX下降而同时低于两条趋向线，这是趋向系统发出最佳讯号的位置。这种情况维持愈久，下一波走势的基础愈稳固。
　　当ADX由两条趋向线的下侧位置开始翻升，代表行情已经惊醒过来。
　　在这种情况下，如果ADX由底部向上翻升四点（例如：由9到13），相当于宣告新趋势的诞生，代表热腾腾的多头市场或空头市场已经出炉。
　　当时，如果＋DI13位在上方，则买进而停损设定在最近次要低点的下侧；如果－DI13位在上方，则放空而停损设定在最近次要高点的上侧。
　　举例来说，假定两条趋向线都位在读数12之上，而且＋DI13高于－DI13，如果ADX的读数由8上升到12，代表新上升趋势的开始。
　　在另一方面，假定两条趋向线都位在读数13之上，而且－DI13高于＋DI13，如果ADX的读数由9上升到13，代表新下降趋势的开始。
　　趋向系统的讯号：趋向线可以显示趋势。当＋DI位于上侧，应该由多方进行交易，当－DI位于上侧，应该由空方进行交易。
　　当ADX上升而介于两条趋向线之间，这最适合采用顺势交易的方法，当时的趋势是处于最动态的阶段。
　　当ADX跌落到两条趋向线的下侧，并停留数个星期之久，这代表平静而沉闷的行情。
　　趋向系统可能在此发出最佳的讯号。一旦ADX“惊醒”而翻升四点（举例来说，由10到14），这代表最强烈的讯号。应该顺着最上方趋向线的方向交易。
　　这类的讯号经常发生在主要趋势的初期，就目前的走势图来说，在日圆涨势即将发动之前，ADX于九月份由9上升到13,由于＋DI位在上方，这是一个买进讯号。
　　趋向系统具有一个独特的功能，它可以告诉你，主要的新趋势何时可能开始，对于特定的市场，这类的讯号可能每年发生一、二次，宣告小牛或小熊的诞生。
　　当时，金额上的风险通常有限，因为趋势才刚形成，价格波动很低。
　　5、当ADX上升而同时高于两条趋向线，代表行情过热。
　　在这种情况下，当ADX向下反转，代表主要的趋势可能发生突变，部位应该获利了结。
　　如果你同时交易数口契约，至少应该了结一部分。
　　市场指标可能提供明确或模糊的讯号。举例来说，价格跌破低点或移动平均转变方向，这都属于明确的讯号。
　　ADX向下反转，则是属于模糊的讯号。当你察觉ADX由上翻下时，加码必须非常非常谨慎，你应该开始获利了结，寻找出场的机会而不应该再加码。

ADX数值在判断趋势强弱中，通常将20作为中间值，也就是被看作行情横盘中的没有趋势。
当ADX大于30的时候，表示趋势运行强度比较大，行情仍然会沿着当前趋势发展;
当ADX小于10的时候，往往预示着价格走势的趋势比较弱，需要警惕行情出现反转。
同时，还可以利用ADX和DI相互关系预测行情走势，
一般来看：
	当-DI向上突破+DI时是黄金交叉，被认为是买入时机，
	当+DI向下突破-DI时是死亡交叉，被认为是卖出时机。
许多交易者会使用高于25的ADX读数来表明趋势足够强劲。相反，当ADX低于25时，很多人会回避趋势交易策略。
ADX线的方向对于解读趋势强度非常重要。
当ADX的线上上升时，趋势强度增加，价格向趋势方向移动。
当ADX的线下下跌时，趋势强度在减弱，价格进入回撤或盘整期。
*/
class CADXCross : public CIndicatorCustom {
protected:

public:
                        CADXCross(const string pair, const ENUM_TIMEFRAMES tf) {
                           this.symbol = pair; this.timeframe = tf; this.indicatorType = IND_ADX_CROSS; this.indicatorName = "ADX";
                        }
                       ~CADXCross(void) {}
   virtual bool         Create(const MqlParam &params[]) const;
   virtual ENUM_TREND   GetTrend(const int index) const;
   virtual ENUM_CROSS   GetCross(const int index) const;
};
bool CADXCross::Create(const MqlParam &params[]) const {
   CiADXStandard *adx = new CiADXStandard(symbol, timeframe, (int) params[0].integer_value, (ENUM_APPLIED_PRICE) params[1].integer_value);
   int countIndicator = this.indicators.Total();
   this.indicators.Add(adx);
   int newCount = this.indicators.Total();
   return (newCount==(countIndicator+1));
}
ENUM_TREND CADXCross::GetTrend(const int index) const {
   ENUM_TREND result = TREND_NONE;
   CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(0);
   double adxVal = indicator.GetData(index, MODE_MAIN);
   double diPlusVal = indicator.GetData(index, MODE_PLUSDI);
   double diMinusVal = indicator.GetData(index, MODE_MINUSDI);

   if (diMinusVal < adxVal && adxVal < diPlusVal) {
      result=TREND_LONG;
   } else if (diPlusVal < adxVal && adxVal < diMinusVal) {
      result=TREND_SHORT;
   }

   return result;
}

ENUM_CROSS CADXCross::GetCross(const int index) const {
   CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(0);
   double adxVal1 = indicator.GetData(index, MODE_MAIN);
   double diPlusVal1 = indicator.GetData(index, MODE_PLUSDI);
   double diMinusVal1 = indicator.GetData(index, MODE_MINUSDI);
   double adxVal2 = indicator.GetData(index+1, MODE_MAIN);
   double diPlusVal2 = indicator.GetData(index+1, MODE_PLUSDI);
   double diMinusVal2 = indicator.GetData(index+1, MODE_MINUSDI);
   
   if (isCrossUp(diPlusVal1, diMinusVal1, diPlusVal2, diMinusVal2)) {
      return CROSS_ADX_LONG;
   }
   
   if (isCrossDown(diPlusVal1, diMinusVal1, diPlusVal2, diMinusVal2)) {
      return CROSS_ADX_SHORT;
   }
   
   if (isCrossUp(adxVal1, diPlusVal1, adxVal2, diPlusVal2)) {
      return CROSS_ADX_DIPLUS_BOTTOM2TOP;
   }
   
   if (isCrossDown(adxVal1, diPlusVal1, adxVal2, diPlusVal2)) {
      return CROSS_ADX_DIPLUS_TOP2BOTTOM;
   }
   
   if (isCrossUp(adxVal1, diMinusVal1, adxVal2, diMinusVal2)) {
      return CROSS_ADX_DIMINUS_BOTTOM2TOP;
   }
   
   if (isCrossDown(adxVal1, diMinusVal1, adxVal2, diMinusVal2)) {
      return CROSS_ADX_DIMINUS_TOP2BOTTOM;
   }
   return CROSS_NONE;
}
/*********************************************** End *********************************************************************/

/***********************************************Start*********************************************************************/
class CRSICross : public CIndicatorCustom {
protected:

public:
                        CRSICross(const string pair, const ENUM_TIMEFRAMES tf) {
                           this.symbol = pair; this.timeframe = tf; this.indicatorType = IND_RSI_CROSS; this.indicatorName = "RSI";
                        }
                       ~CRSICross(void) {}
   virtual bool         Create(const MqlParam &params[]) const;
   virtual ENUM_TREND   GetTrend(const int index) const;
   virtual ENUM_CROSS   GetCross(const int index) const;
};
bool CRSICross::Create(const MqlParam &params[]) const {
   CiRSIStandard *rsi = new CiRSIStandard(symbol, timeframe, (int) params[0].integer_value, (ENUM_APPLIED_PRICE) params[1].integer_value);
   int countIndicator = this.indicators.Total();
   this.indicators.Add(rsi);
   int newCount = this.indicators.Total();
   return (newCount==(countIndicator+1));
}
ENUM_TREND CRSICross::GetTrend(const int index) const {
   ENUM_TREND result = TREND_NONE;
   int countIndicators = this.indicators.Total();
   CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(countIndicators-1);
   double rsi = indicator.GetData(index);
   if (50 < rsi) return TREND_LONG;
   if (rsi < 50) return TREND_SHORT;
   return result;
}

ENUM_CROSS CRSICross::GetCross(const int index) const {
   ENUM_CROSS result = CROSS_NONE;
   int countIndicators = this.indicators.Total();
   double values[4];
   //ArrayResize(values, countIndicators);
   bool isUp=false, isDown=false;
   for (int i=0; i<countIndicators-1; i++) {
      CIndicatorBase *indicatorI = this.indicators.GetNodeAtIndex(i);
      values[0] = indicatorI.GetData(index);
      values[2] = indicatorI.GetData(index+1);
      for (int j=i+1; j<countIndicators; j++) {
         CIndicatorBase *indicatorJ = this.indicators.GetNodeAtIndex(j);
         values[1] = indicatorJ.GetData(index);
         values[3] = indicatorJ.GetData(index+1);
         if (isCrossUp(values[0], values[1], values[2], values[3])) return CROSS_RSI_LONG;
         if (isCrossDown(values[0], values[1], values[2], values[3])) return CROSS_RSI_SHORT;
      }
   }
   return result;
}
/*********************************************** End *********************************************************************/


/***********************************************Start*********************************************************************/
/*
   J的实质是反映K值和D值的乖离程度，从而领先KD值显示头部或底部。J值范围可超过100和低于0。
   随机指标的应用原则：
   1、当白色的K值在50以下的低水平，形成一底比一底高的现象，并且K值由下向上连续两次交叉黄色的D值时，股价会产生较大的涨幅。
   2、当白色的K值在50以上的高水平，形成一顶比一顶低的现象，并且K值由上向下连续两次交叉黄色的D值时，股价会产生较大的跌幅。
   3、白色的K线由下向上交叉黄色的D线失败转而向下探底后，K线再次向上交叉D线，两线所夹的空间叫做向上反转风洞。如上图所示，当出现向上反转风洞时股价将上涨。如下图所示，反之叫做向下反转风洞。出现向下反转风洞时股价将下跌。
   4、K值大于80，短期内股价容易向下出现回档；K值小于20，短期内股价容易向上出现反弹；但在极强、极弱行情中K、D指标会在超买、超卖区内徘徊，此时应参考VR、ROC指标以确定走势的强弱。
   5、在常态行情中，D值大于80后股价经常向下回跌；D值小于20后股价易于回升。
     在极端行情中，D值大于90，股价易产生瞬间回档；D值小于15，股价易产生瞬间反弹（见下图）。这种瞬间回档或反弹不代表行情已经反转。
   6、J值信号不常出现，可是一旦出现，可靠性相当高。当J值大于100时，股价会形成头部而出现回落；J值小于0时，股价会形成底部而产生反弹。
   （1）随机指数是一种较短期，敏感指标，分析比较全面，但比强弱指数复杂
   （2）随机指数的典型背驰准确性颇高，看典型背驰区注意D线，而K线的作用只在发出买卖讯号。
   （3）在使用中，常有J线的指标，即3乘以K值减2乘以D值（3K－2D＝J），其目的是求出K值与D值的最大乖离程度，以领先KD值找出底部和头部。J大于100时为超买，小于10时为超卖。
   1.超买超卖现象
    KDJ的取值范围在0-100之间(J线有时有所超越)。将这0-100之间按区域，按流行的，常用的判研标准，可划分为超买区、超卖区、徘徊区。
      超买区：K值在80以上，D值在70以上，J值大于90时为超买。一般情况下，股价有可能下跌。投资者应谨慎行事，局外人不应再追涨，局内人应适时卖出。
      超卖区：K值在20以下，D值在30以下为超卖区。一般情况下，股价有可能上涨，反弹的可能性增大。局内人不应轻易抛出股票，局外人可寻机入场。
      徘徊区：KD值处于50左右分三种情况。如在多头市场，50是回挡支撑线；如是空头市场，50是反弹压力线；如果在50左右徘徊，说明行情还在整理，应以观望为主，不宜匆忙决定买卖。
    需要说明的是，由于J线反应较为敏感，比K线.D线的变动速度快，振幅高。一般仅为参考依据。
   2.背弛现象
    当股价走势一峰比一峰高时，随机指标的J线却一峰比一峰低，或股价走势一波谷比一波谷低时，J线却一波谷比一波谷高，这种现象称之为背驰。
    随机指标与股价走势产生背驰时，一般为市场转势的信号，表明中期或短期走势已经到顶或已经见底。此时是买卖股票的时机。
   3.K 线与D 线的交叉突破
    当K值大于D值时，表明股价当前正处于上升趋势之中，因此，当K线从下向上交叉突破D线时，正是买进股票的时机。
    反之，当K值小于D值时，表明股市当前处于下降趋势。因此，当K线从上向下交叉突破D线时，正是卖出股票的时机。
*/
class CKDJCross : public CIndicatorCustom {
protected:

public:
                        CKDJCross(const string pair, const ENUM_TIMEFRAMES tf) {
                           this.symbol = pair; this.timeframe = tf; this.indicatorType = IND_KDJ_CROSS; this.indicatorName = "KDJ";
                        }
                       ~CKDJCross(void) {}
   virtual bool         Create(const MqlParam &params[]) const;
   virtual ENUM_TREND   GetTrend(const int index) const;
   virtual ENUM_CROSS   GetCross(const int index) const;
};
bool CKDJCross::Create(const MqlParam &params[]) const {
   CiKDJStandard *kdj = new CiKDJStandard(symbol, timeframe, (int) params[0].integer_value, (int) params[1].integer_value, (int) params[2].integer_value, (ENUM_MA_METHOD) params[3].integer_value, (int) params[4].integer_value);
   int countIndicator = this.indicators.Total();
   this.indicators.Add(kdj);
   int newCount = this.indicators.Total();
   return (newCount==(countIndicator+1));
}
ENUM_TREND CKDJCross::GetTrend(const int index) const {
   ENUM_TREND result = TREND_NONE;
   CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(0);
   double kVal = indicator.GetData(index, MODE_MAIN);
   double dVal = indicator.GetData(index, MODE_SIGNAL);
   //double jVal = 3*kVal - 2*dVal;

   if (dVal < kVal) {
      result=TREND_LONG;
   } else if (dVal > kVal) {
      result=TREND_SHORT;
   }

   return result;
}

ENUM_CROSS CKDJCross::GetCross(const int index) const {
   CIndicatorBase *indicator = this.indicators.GetNodeAtIndex(0);
   double kVal1 = indicator.GetData(index, MODE_MAIN);
   double dVal1 = indicator.GetData(index, MODE_SIGNAL);
   double jVal1 = 3*kVal1 - 2*dVal1;
   //double jVal0 = 3*indicator.GetData(0, MODE_MAIN) - 2*indicator.GetData(0, MODE_SIGNAL);
   
   double kVal2 = indicator.GetData(index+1, MODE_MAIN);
   double dVal2 = indicator.GetData(index+1, MODE_SIGNAL);
   //double jVal2 = 3*kVal2 - 2*dVal2;
   
   if (isCrossUp(kVal1, dVal1, kVal2, dVal2)) {
      return CROSS_KDJ_LONG;
   }
   
   if (isCrossDown(kVal1, dVal1, kVal2, dVal2)) {
      return CROSS_KDJ_SHORT;
   }
   
   if (100 <= jVal1) {
      return CROSS_KDJ_OVER_100;
   }
   
   if (jVal1 <= 0) {
      return CROSS_KDJ_BELOW_0;
   }
   
   // 超买区：K值在80以上，D值在70以上，J值大于90时为超买
   if (80<=kVal1 && 70<=dVal1 && 90<=jVal1) {
      return CROSS_KDJ_OVERBOUGHT;
   }
   
   // 超卖区：K值在20以下，D值在30以下为超卖区。
   if (kVal1<=20 && dVal1<=30 && jVal1<=10) {
      return CROSS_KDJ_OVERSOLD;
   }
   return CROSS_NONE;
}
/*********************************************** End *********************************************************************/


class SymbolInfo : public CObject {
private:
protected:
   string            name;
   string            realName;
   string            prefix;
   string            suffix;
   CList             *indicators;
   int               index;
   bool              enabled;

   double            multipleAtr;
   double            atrValue;

   
public:
                     SymbolInfo(string SymbolShortName, string SymbolPrefix="", string SymbolSuffix="", int Index=0);
                    ~SymbolInfo() { delete indicators; }
   void              setName(string symbolNm)                     { name = symbolNm;            }
   string            getName(void)                          const { return(name);               }
   
   void              setPrefix(string SymbolPrefix)               { prefix = SymbolPrefix;      }
   string            getPrefix(void)                        const { return(prefix);             }
   
   void              setSuffix(string SymbolSuffix)               { suffix = SymbolSuffix;      }
   string            getSuffix(void)                        const { return(suffix);             }
   string            getRealName(void)                      const { return(this.realName);      }
   
   int               spread()                               const { return((int) MarketInfo(realName,MODE_SPREAD));  }
   double            getPoint(void)                         const { return(      MarketInfo(realName,MODE_POINT));   }
   int               getDigits(void)                        const { return((int) MarketInfo(realName,MODE_DIGITS));  }

   
   void              setIndex(int vIndex)                         { index = vIndex;             }
   int               getIndex(void)                         const { return(index);              }
   

   
   void              setEnabled(bool vEnabled)                    { this.enabled = vEnabled;    }
   bool              isEnabled(void)                        const { return(enabled);            }
   
   void              add2Indicators(CIndicatorCustom *indi) const { this.indicators.Add(indi);           }
   int               getIndicatorCount()                    const { return indicators.Total();           }
   CIndicatorCustom *getIndicatorAtIndex(int i)             const { return indicators.GetNodeAtIndex(i); }
   
   void              setMultipleAtr(double multiple)              { multipleAtr = multiple;              }
   double            getMultipleAtr(void)                   const { return(multipleAtr);                 }
   
   void              setAtrValue(double atr)                      { atrValue = atr;                      }
   double            getAtrValue(void)                      const { return(atrValue);                    }

};

SymbolInfo::SymbolInfo(string SymbolShortName, string SymbolPrefix="", string SymbolSuffix="", int Index=0) {
   this.name = SymbolShortName;
   this.prefix = SymbolPrefix;
   this.suffix = SymbolSuffix;
   this.realName = SymbolPrefix + SymbolShortName + SymbolSuffix;
   this.index = Index;
   indicators = new CList();
}

input bool                 In_Use_Timeframe1          = false;
input ENUM_TIMEFRAMES      In_Timeframe1              = PERIOD_M5;
input bool                 In_Use_Timeframe2          = false;
input ENUM_TIMEFRAMES      In_Timeframe2              = PERIOD_M15;
input bool                 In_Use_Timeframe3          = false;
input ENUM_TIMEFRAMES      In_Timeframe3              = PERIOD_M30;
input bool                 In_Use_Timeframe4          = false;
input ENUM_TIMEFRAMES      In_Timeframe4              = PERIOD_H1;
input bool                 In_Use_Timeframe5          = false;
input ENUM_TIMEFRAMES      In_Timeframe5              = PERIOD_H4;
input bool                 In_Use_Timeframe6          = false;
input ENUM_TIMEFRAMES      In_Timeframe6              = PERIOD_D1;
input bool                 In_Use_Timeframe7          = false;
input ENUM_TIMEFRAMES      In_Timeframe7              = PERIOD_W1;

input bool                 In_Use_MA                  = false;
input bool                 In_Use_MACD                = false;
input bool                 In_Use_RSI                 = false;
input bool                 In_Use_KDJ                 = false;
input bool                 In_Use_ADX                 = false;

input int                  In_MACD_Fast_EMA_Period_TF1         = 12;
input int                  In_MACD_Slow_EMA_Period_TF1         = 26;
input int                  In_MACD_Signal_Period_TF1           = 9;
input ENUM_APPLIED_PRICE   In_MACD_Applied_Price_TF1           = PRICE_CLOSE;

input int                  In_MACD_Fast_EMA_Period_TF2         = 12;
input int                  In_MACD_Slow_EMA_Period_TF2         = 26;
input int                  In_MACD_Signal_Period_TF2           = 9;
input ENUM_APPLIED_PRICE   In_MACD_Applied_Price_TF2           = PRICE_CLOSE;

input int                  In_MACD_Fast_EMA_Period_TF3         = 12;
input int                  In_MACD_Slow_EMA_Period_TF3         = 26;
input int                  In_MACD_Signal_Period_TF3           = 9;
input ENUM_APPLIED_PRICE   In_MACD_Applied_Price_TF3           = PRICE_CLOSE;

input int                  In_MACD_Fast_EMA_Period_TF4         = 12;
input int                  In_MACD_Slow_EMA_Period_TF4         = 26;
input int                  In_MACD_Signal_Period_TF4           = 9;
input ENUM_APPLIED_PRICE   In_MACD_Applied_Price_TF4           = PRICE_CLOSE;

input int                  In_MACD_Fast_EMA_Period_TF5         = 12;
input int                  In_MACD_Slow_EMA_Period_TF5         = 26;
input int                  In_MACD_Signal_Period_TF5           = 9;
input ENUM_APPLIED_PRICE   In_MACD_Applied_Price_TF5           = PRICE_CLOSE;

input int                  In_MACD_Fast_EMA_Period_TF6         = 12;
input int                  In_MACD_Slow_EMA_Period_TF6         = 26;
input int                  In_MACD_Signal_Period_TF6           = 9;
input ENUM_APPLIED_PRICE   In_MACD_Applied_Price_TF6           = PRICE_CLOSE;

input int                  In_MACD_Fast_EMA_Period_TF7         = 12;
input int                  In_MACD_Slow_EMA_Period_TF7         = 26;
input int                  In_MACD_Signal_Period_TF7           = 9;
input ENUM_APPLIED_PRICE   In_MACD_Applied_Price_TF7           = PRICE_CLOSE;

input int                  In_short_term_MA_period_TF1         = 8;
input ENUM_MA_METHOD       In_short_term_MA_method_TF1         = MODE_EMA;
input int                  In_short_term_MA_shift_TF1          = 0;
input ENUM_APPLIED_PRICE   In_short_term_MA_applied_price_TF1  = PRICE_CLOSE;
input int                  In_medium_term_MA_period_TF1        = 55;
input ENUM_MA_METHOD       In_medium_term_MA_method_TF1        = MODE_EMA;
input int                  In_medium_term_MA_shift_TF1         = 0;
input ENUM_APPLIED_PRICE   In_medium_term_MA_applied_price_TF1 = PRICE_CLOSE;
input int                  In_long_term_MA_period_TF1          = 144;
input ENUM_MA_METHOD       In_long_term_MA_method_TF1          = MODE_EMA;
input int                  In_long_term_MA_shift_TF1           = 0;
input ENUM_APPLIED_PRICE   In_long_term_MA_applied_price_TF1   = PRICE_CLOSE;

input int                  In_short_term_MA_period_TF2         = 8;
input ENUM_MA_METHOD       In_short_term_MA_method_TF2         = MODE_EMA;
input int                  In_short_term_MA_shift_TF2          = 0;
input ENUM_APPLIED_PRICE   In_short_term_MA_applied_price_TF2  = PRICE_CLOSE;
input int                  In_medium_term_MA_period_TF2        = 55;
input ENUM_MA_METHOD       In_medium_term_MA_method_TF2        = MODE_EMA;
input int                  In_medium_term_MA_shift_TF2         = 0;
input ENUM_APPLIED_PRICE   In_medium_term_MA_applied_price_TF2 = PRICE_CLOSE;
input int                  In_long_term_MA_period_TF2          = 144;
input ENUM_MA_METHOD       In_long_term_MA_method_TF2          = MODE_EMA;
input int                  In_long_term_MA_shift_TF2           = 0;
input ENUM_APPLIED_PRICE   In_long_term_MA_applied_price_TF2   = PRICE_CLOSE;

input int                  In_short_term_MA_period_TF3         = 8;
input ENUM_MA_METHOD       In_short_term_MA_method_TF3         = MODE_EMA;
input int                  In_short_term_MA_shift_TF3          = 0;
input ENUM_APPLIED_PRICE   In_short_term_MA_applied_price_TF3  = PRICE_CLOSE;
input int                  In_medium_term_MA_period_TF3        = 55;
input ENUM_MA_METHOD       In_medium_term_MA_method_TF3        = MODE_EMA;
input int                  In_medium_term_MA_shift_TF3         = 0;
input ENUM_APPLIED_PRICE   In_medium_term_MA_applied_price_TF3 = PRICE_CLOSE;
input int                  In_long_term_MA_period_TF3          = 144;
input ENUM_MA_METHOD       In_long_term_MA_method_TF3          = MODE_EMA;
input int                  In_long_term_MA_shift_TF3           = 0;
input ENUM_APPLIED_PRICE   In_long_term_MA_applied_price_TF3   = PRICE_CLOSE;

input int                  In_short_term_MA_period_TF4         = 8;
input ENUM_MA_METHOD       In_short_term_MA_method_TF4         = MODE_EMA;
input int                  In_short_term_MA_shift_TF4          = 0;
input ENUM_APPLIED_PRICE   In_short_term_MA_applied_price_TF4  = PRICE_CLOSE;
input int                  In_medium_term_MA_period_TF4        = 55;
input ENUM_MA_METHOD       In_medium_term_MA_method_TF4        = MODE_EMA;
input int                  In_medium_term_MA_shift_TF4         = 0;
input ENUM_APPLIED_PRICE   In_medium_term_MA_applied_price_TF4 = PRICE_CLOSE;
input int                  In_long_term_MA_period_TF4          = 144;
input ENUM_MA_METHOD       In_long_term_MA_method_TF4          = MODE_EMA;
input int                  In_long_term_MA_shift_TF4           = 0;
input ENUM_APPLIED_PRICE   In_long_term_MA_applied_price_TF4   = PRICE_CLOSE;

input int                  In_short_term_MA_period_TF5         = 8;
input ENUM_MA_METHOD       In_short_term_MA_method_TF5         = MODE_EMA;
input int                  In_short_term_MA_shift_TF5          = 0;
input ENUM_APPLIED_PRICE   In_short_term_MA_applied_price_TF5  = PRICE_CLOSE;
input int                  In_medium_term_MA_period_TF5        = 55;
input ENUM_MA_METHOD       In_medium_term_MA_method_TF5        = MODE_EMA;
input int                  In_medium_term_MA_shift_TF5         = 0;
input ENUM_APPLIED_PRICE   In_medium_term_MA_applied_price_TF5 = PRICE_CLOSE;
input int                  In_long_term_MA_period_TF5          = 144;
input ENUM_MA_METHOD       In_long_term_MA_method_TF5          = MODE_EMA;
input int                  In_long_term_MA_shift_TF5           = 0;
input ENUM_APPLIED_PRICE   In_long_term_MA_applied_price_TF5   = PRICE_CLOSE;

input int                  In_short_term_MA_period_TF6         = 8;
input ENUM_MA_METHOD       In_short_term_MA_method_TF6         = MODE_EMA;
input int                  In_short_term_MA_shift_TF6          = 0;
input ENUM_APPLIED_PRICE   In_short_term_MA_applied_price_TF6  = PRICE_CLOSE;
input int                  In_medium_term_MA_period_TF6        = 55;
input ENUM_MA_METHOD       In_medium_term_MA_method_TF6        = MODE_EMA;
input int                  In_medium_term_MA_shift_TF6         = 0;
input ENUM_APPLIED_PRICE   In_medium_term_MA_applied_price_TF6 = PRICE_CLOSE;
input int                  In_long_term_MA_period_TF6          = 144;
input ENUM_MA_METHOD       In_long_term_MA_method_TF6          = MODE_EMA;
input int                  In_long_term_MA_shift_TF6           = 0;
input ENUM_APPLIED_PRICE   In_long_term_MA_applied_price_TF6   = PRICE_CLOSE;

input int                  In_short_term_MA_period_TF7         = 8;
input ENUM_MA_METHOD       In_short_term_MA_method_TF7         = MODE_EMA;
input int                  In_short_term_MA_shift_TF7          = 0;
input ENUM_APPLIED_PRICE   In_short_term_MA_applied_price_TF7  = PRICE_CLOSE;
input int                  In_medium_term_MA_period_TF7        = 55;
input ENUM_MA_METHOD       In_medium_term_MA_method_TF7        = MODE_EMA;
input int                  In_medium_term_MA_shift_TF7         = 0;
input ENUM_APPLIED_PRICE   In_medium_term_MA_applied_price_TF7 = PRICE_CLOSE;
input int                  In_long_term_MA_period_TF7          = 144;
input ENUM_MA_METHOD       In_long_term_MA_method_TF7          = MODE_EMA;
input int                  In_long_term_MA_shift_TF7           = 0;
input ENUM_APPLIED_PRICE   In_long_term_MA_applied_price_TF7   = PRICE_CLOSE;


input int                  In_short_term_RSI_period_TF1        = 5;
input ENUM_APPLIED_PRICE   In_short_term_RSI_applied_price_TF1 = PRICE_CLOSE;
input int                  In_long_term_RSI_period_TF1         = 13;
input ENUM_APPLIED_PRICE   In_long_term_RSI_applied_price_TF1  = PRICE_CLOSE;

input int                  In_short_term_RSI_period_TF2        = 5;
input ENUM_APPLIED_PRICE   In_short_term_RSI_applied_price_TF2 = PRICE_CLOSE;
input int                  In_long_term_RSI_period_TF2         = 13;
input ENUM_APPLIED_PRICE   In_long_term_RSI_applied_price_TF2  = PRICE_CLOSE;

input int                  In_short_term_RSI_period_TF3        = 5;
input ENUM_APPLIED_PRICE   In_short_term_RSI_applied_price_TF3 = PRICE_CLOSE;
input int                  In_long_term_RSI_period_TF3         = 13;
input ENUM_APPLIED_PRICE   In_long_term_RSI_applied_price_TF3  = PRICE_CLOSE;

input int                  In_short_term_RSI_period_TF4        = 5;
input ENUM_APPLIED_PRICE   In_short_term_RSI_applied_price_TF4 = PRICE_CLOSE;
input int                  In_long_term_RSI_period_TF4         = 13;
input ENUM_APPLIED_PRICE   In_long_term_RSI_applied_price_TF4  = PRICE_CLOSE;

input int                  In_short_term_RSI_period_TF5        = 5;
input ENUM_APPLIED_PRICE   In_short_term_RSI_applied_price_TF5 = PRICE_CLOSE;
input int                  In_long_term_RSI_period_TF5         = 13;
input ENUM_APPLIED_PRICE   In_long_term_RSI_applied_price_TF5  = PRICE_CLOSE;

input int                  In_short_term_RSI_period_TF6        = 5;
input ENUM_APPLIED_PRICE   In_short_term_RSI_applied_price_TF6 = PRICE_CLOSE;
input int                  In_long_term_RSI_period_TF6         = 13;
input ENUM_APPLIED_PRICE   In_long_term_RSI_applied_price_TF6  = PRICE_CLOSE;

input int                  In_short_term_RSI_period_TF7        = 5;
input ENUM_APPLIED_PRICE   In_short_term_RSI_applied_price_TF7 = PRICE_CLOSE;
input int                  In_long_term_RSI_period_TF7         = 13;
input ENUM_APPLIED_PRICE   In_long_term_RSI_applied_price_TF7  = PRICE_CLOSE;


input int                  In_ADX_period_TF1                   = 14;
input ENUM_APPLIED_PRICE   In_ADX_applied_price_TF1            = PRICE_CLOSE;
input int                  In_ADX_period_TF2                   = 14;
input ENUM_APPLIED_PRICE   In_ADX_applied_price_TF2            = PRICE_CLOSE;
input int                  In_ADX_period_TF3                   = 14;
input ENUM_APPLIED_PRICE   In_ADX_applied_price_TF3            = PRICE_CLOSE;
input int                  In_ADX_period_TF4                   = 14;
input ENUM_APPLIED_PRICE   In_ADX_applied_price_TF4            = PRICE_CLOSE;
input int                  In_ADX_period_TF5                   = 14;
input ENUM_APPLIED_PRICE   In_ADX_applied_price_TF5            = PRICE_CLOSE;
input int                  In_ADX_period_TF6                   = 14;
input ENUM_APPLIED_PRICE   In_ADX_applied_price_TF6            = PRICE_CLOSE;
input int                  In_ADX_period_TF7                   = 14;
input ENUM_APPLIED_PRICE   In_ADX_applied_price_TF7            = PRICE_CLOSE;


input int                  In_KDJ_Kperiod_TF1                  = 5;
input int                  In_KDJ_Dperiod_TF1                  = 3;
input int                  In_KDJ_slowing_TF1                  = 3;
input ENUM_MA_METHOD       In_KDJ_method_TF1                   = MODE_SMA;
input int                  In_KDJ_price_field_TF1              = 0;           // 0 - Low/High or 1 - Close/Close

input int                  In_KDJ_Kperiod_TF2                  = 5;
input int                  In_KDJ_Dperiod_TF2                  = 3;
input int                  In_KDJ_slowing_TF2                  = 3;
input ENUM_MA_METHOD       In_KDJ_method_TF2                   = MODE_SMA;
input int                  In_KDJ_price_field_TF2              = 0;           // 0 - Low/High or 1 - Close/Close

input int                  In_KDJ_Kperiod_TF3                  = 5;
input int                  In_KDJ_Dperiod_TF3                  = 3;
input int                  In_KDJ_slowing_TF3                  = 3;
input ENUM_MA_METHOD       In_KDJ_method_TF3                   = MODE_SMA;
input int                  In_KDJ_price_field_TF3              = 0;           // 0 - Low/High or 1 - Close/Close

input int                  In_KDJ_Kperiod_TF4                  = 5;
input int                  In_KDJ_Dperiod_TF4                  = 3;
input int                  In_KDJ_slowing_TF4                  = 3;
input ENUM_MA_METHOD       In_KDJ_method_TF4                   = MODE_SMA;
input int                  In_KDJ_price_field_TF4              = 0;           // 0 - Low/High or 1 - Close/Close

input int                  In_KDJ_Kperiod_TF5                  = 5;
input int                  In_KDJ_Dperiod_TF5                  = 3;
input int                  In_KDJ_slowing_TF5                  = 3;
input ENUM_MA_METHOD       In_KDJ_method_TF5                   = MODE_SMA;
input int                  In_KDJ_price_field_TF5              = 0;           // 0 - Low/High or 1 - Close/Close

input int                  In_KDJ_Kperiod_TF6                  = 5;
input int                  In_KDJ_Dperiod_TF6                  = 3;
input int                  In_KDJ_slowing_TF6                  = 3;
input ENUM_MA_METHOD       In_KDJ_method_TF6                   = MODE_SMA;
input int                  In_KDJ_price_field_TF6              = 0;           // 0 - Low/High or 1 - Close/Close

input int                  In_KDJ_Kperiod_TF7                  = 5;
input int                  In_KDJ_Dperiod_TF7                  = 3;
input int                  In_KDJ_slowing_TF7                  = 3;
input ENUM_MA_METHOD       In_KDJ_method_TF7                   = MODE_SMA;
input int                  In_KDJ_price_field_TF7              = 0;           // 0 - Low/High or 1 - Close/Close

input string               In_Template_Name           = "MyTemplate";
input double               In_Lots                    = 0.01;
input int                  Magic_Number               = 88888;
input string               Prefix                     = "";
input string               Surfix                     = "";
input bool                 UseDefaultPairs            = true;
input string               In_Pairs                   = "";
input int                  Coordinates_X              = 1;
input int                  Coordinates_Y              = 1;
input bool                 In_4Kdisplay               = false;

const string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY", "CNHJPY", "USDCNH", "XAGUSD", "XAUUSD", "XNGUSD", "XTIUSD", "ETHUSD", "JP225"};
//const string DefaultPairs[] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};
//const string DefaultPairs[] = {"GBPUSD","EURUSD","USDJPY"};
const string   ObjNamePrefix     = "DB_Signals_";
const string   panelNamePrefix   = "Rec_";
const string   COMMENT           = "DB_Signals";
const int      ColumnInterval = 0;
const int      RowInterval    = 0;
const int      Border_Width   = 2;

const int      FONT_SIZE_LBL   = 8;
const int      FONT_SIZE_SIGN   = 10;

const color    ClrColBgBtn          = clrBlack;
const color    ClrColFtBtn          = clrWhite;

const color    COLOR_BD_USED        = clrGold;
const color    COLOR_BD_UNUSE       = clrBlack;

const color    ClrColBgLbl_N        = clrBlack;
const color    ClrColBdLbl_N        = clrWhite;
const color    ClrColFtLbl_N        = clrWhite;

const color    ClrBgTrend_L_P       = clrMidnightBlue;
const color    ClrBdTrend_L_P       = clrBlack;
const color    ClrFtTrend_L_P       = clrWhite;
const color    ClrBgTrend_L         = clrRoyalBlue;
const color    ClrBdTrend_L         = clrBlack;
const color    ClrFtTrend_L         = clrWhite;
const color    ClrBgTrend_L_M       = clrMediumSeaGreen;
const color    ClrBdTrend_L_M       = clrBlack;
const color    ClrFtTrend_L_M       = clrWhite;

const color    ClrBgTrend_S_P       = clrMaroon;
const color    ClrBdTrend_S_P       = clrWhite;
const color    ClrFtTrend_S_P       = clrWhite;
const color    ClrBgTrend_S         = clrCrimson;
const color    ClrBdTrend_S         = clrWhite;
const color    ClrFtTrend_S         = clrWhite;
const color    ClrBgTrend_S_M       = clrCoral;
const color    ClrBdTrend_S_M       = clrWhite;
const color    ClrFtTrend_S_M       = clrWhite;

ENUM_TIMEFRAMES tfs[TIMEFRAME_COUNT];
CList *SymbolList;
string SymbolArray[], gvTemplateName;
int gvCountSymbol;
bool gvUseTfs[INDICATOR_TYPE_COUNT][TIMEFRAME_COUNT];//, gvUseIndicators[INDICATOR_TYPE_COUNT];
bool gvSymbolSelected[];
double gvLots;

int OnInit() {

   bool initFlag = initSymbols();
   if (!initFlag) {
      return(INIT_FAILED);
   }
   ArrayResize(gvSymbolSelected, gvCountSymbol);
   ArrayInitialize(gvSymbolSelected, false);
   gvLots = In_Lots;
   gvTemplateName = In_Template_Name;
   Draw(Coordinates_X, Coordinates_Y, SymbolList);
   EventSetTimer(1);
   

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   delete SymbolList;
   EventKillTimer();
   ObjectsDeleteAll(0, ObjNamePrefix);
}

void OnTick() {
   
}

void OnTimer() {
   int rowCnt = SymbolList.Total();
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = SymbolList.GetNodeAtIndex(i);

      int cnt = si.getIndicatorCount();
      string ColName = NULL;
      for (int j=0; j<cnt; j++) {
         CIndicatorCustom *ic = si.getIndicatorAtIndex(j);
         sign_settings signSettings={0,0,0,"","",clrNONE,clrNONE,clrNONE};
         getCrossSignSet(ic, signSettings);
         ColName = ic.getName() + getTimeframeStr(ic.getTimeframe());
         resetSign(ColName, si.getName(), signSettings);
      }
      setRowHighlight(si);
   }
}

SymbolInfo *getSymbolInfoByName(CList *list, const string symbolName) {
   int cnt = list.Total();
   for (int i=0; i<cnt; i++) {
      SymbolInfo *si = list.GetNodeAtIndex(i);
      //Print(" symbolName=", symbolName, " si.getName()=", si.getName());
      if (symbolName == si.getName()) return si;
   }
   return NULL;
}

void resetTimeframe(string indicatorName, int indexIndicator, int indexTF, string btnName) {
   /*
   for(int i=0; i<INDICATOR_TYPE_COUNT; i++) {
      for(int j=0; j<TIMEFRAME_COUNT; j++) {
         Print("gvUseTfs[",i,"][",j,"]==",gvUseTfs[i][j]);
      }
   }
   Print(" indicatorName=", indicatorName, " indexTF=", indexTF, " btnName=", btnName, " gvUseTfs[", indexIndicator, "][", indexTF, "]=", gvUseTfs[indexIndicator][indexTF]);
   */
   gvUseTfs[indexIndicator][indexTF] = !gvUseTfs[indexIndicator][indexTF];
   //Print(" gvUseTfs[", indexIndicator, "][", indexTF, "]=", gvUseTfs[indexIndicator][indexTF]);
   int rowCnt = SymbolList.Total();
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = SymbolList.GetNodeAtIndex(i);
      int cnt = si.getIndicatorCount();
      
      for (int j=0; j<cnt; j++) {
         CIndicatorCustom *ic = si.getIndicatorAtIndex(j);
         if (indicatorName==ic.getName()) {
            if (tfs[indexTF] == ic.getTimeframe()) ic.setEnable(gvUseTfs[indexIndicator][indexTF]);
         }
      }
   }
   
   string objNm = ObjNamePrefix + "indi_" + indicatorName;
   if (isUsedIndicator(indexIndicator)) setBtnSelected(objNm); else setBtnUnselected(objNm);
   if (gvUseTfs[indexIndicator][indexTF]) setBtnSelected(btnName); else setBtnUnselected(btnName);
}

int getIndexByTimeframeName(const string timeframeName) {
   for (int i=0; i<TIMEFRAME_COUNT; i++) {
      if (timeframeName == getTimeframeStr(tfs[i])) return i;
   }
   return -1;
}

void setRowHighlight(SymbolInfo *si ) {
   int index = si.getIndex();
   bool isSelected = gvSymbolSelected[index];
   color bdColor;
   string btnName = ObjNamePrefix+"Symbol"+si.getName();
   if (isSelected) {
      setBtnSelected(btnName);
      bdColor = COLOR_BD_USED;
   } else {
      setBtnUnselected(btnName);
      bdColor = COLOR_BD_UNUSE;
   }
   int obj_total = ObjectsTotal();
   string name = NULL;
   string symbolNameI = NULL;
   string Search = ObjNamePrefix + panelNamePrefix;
   for(int i=0;i<obj_total;i++) {
      name=ObjectName(i);
      symbolNameI = StringSubstr(name, StringLen(name)-6, 6);
      if (0 == StringFind(name, Search) && symbolNameI == si.getName()) {
         if (isSelected) ObjectSetInteger(0,name,OBJPROP_COLOR,bdColor);
         else {
            int indicatorIndex, timeframeIndex;
            string tfStr;
            if       (0 == StringFind(name, Search+"MACD")) {indicatorIndex = 1; tfStr = StringSubstr(name, StringLen(name)-8, 2);}
            else if  (0 == StringFind(name, Search+"MA"))   {indicatorIndex = 0; tfStr = StringSubstr(name, StringLen(name)-8, 2);}
            else if  (0 == StringFind(name, Search+"RSI"))  {indicatorIndex = 2; tfStr = StringSubstr(name, StringLen(name)-8, 2);}
            else if  (0 == StringFind(name, Search+"KDJ"))  {indicatorIndex = 3; tfStr = StringSubstr(name, StringLen(name)-8, 2);}
            else if  (0 == StringFind(name, Search+"ADX"))  {indicatorIndex = 4; tfStr = StringSubstr(name, StringLen(name)-8, 2);}
            
            timeframeIndex = getIndexByTimeframeName(tfStr);
            if (!gvUseTfs[indicatorIndex][timeframeIndex]) ObjectSetInteger(0,name,OBJPROP_COLOR,bdColor);
         }
      }
   }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if (CHARTEVENT_OBJECT_CLICK != id) return;
   string objName = ObjNamePrefix+"MV";
   string symbolName = NULL;
   Print("sparam==", sparam);
   if ((0 == StringFind(sparam, objName))) {
      symbolName = StringSubstr(sparam, StringLen(sparam)-6, 6);
      SymbolInfo *si = getSymbolInfoByName(SymbolList, symbolName);
      long curChartId = ChartID();
      long prevChart = ChartFirst();
      bool found = false;
      while(!found) {
         if(prevChart < 0) break;
         if (si.getRealName() == ChartSymbol(prevChart)) {
            if (curChartId != prevChart) {
               found = true;
               break;
            }
         }
         prevChart = ChartNext(prevChart);
      }
      
      if (found) {
         ChartSetInteger(prevChart,CHART_BRING_TO_TOP,0,true);
      } else {
         long chartIdPair = ChartOpen(si.getRealName(), PERIOD_H1);
         ChartApplyTemplate(chartIdPair, gvTemplateName);
      }
      return;
   }
   
   objName = ObjNamePrefix+"Symbol";
   if ((0 == StringFind(sparam, objName))) {
      symbolName = StringSubstr(sparam, StringLen(sparam)-6, 6);
      SymbolInfo *si = getSymbolInfoByName(SymbolList, symbolName);
      int index = si.getIndex();
      gvSymbolSelected[index] = !gvSymbolSelected[index];
      setRowHighlight(si);return;
   }

   objName = ObjNamePrefix+"NewL";
   if ((0 == StringFind(sparam, objName))) {
      symbolName = StringSubstr(sparam, StringLen(sparam)-6, 6);
      SymbolInfo *si = getSymbolInfoByName(SymbolList, symbolName);
      createOrder(si, OP_BUY);return;
   }
   
   objName = ObjNamePrefix+"NewS";
   if ((0 == StringFind(sparam, objName))) {
      symbolName = StringSubstr(sparam, StringLen(sparam)-6, 6);
      SymbolInfo *si = getSymbolInfoByName(SymbolList, symbolName);
      createOrder(si, OP_SELL);return;
   }

   objName = ObjNamePrefix+"MA_TF0";
   if (sparam == objName) {
      resetTimeframe("MA", 0, 0, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MA_TF1";
   if (sparam == objName) {
      resetTimeframe("MA", 0, 1, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MA_TF2";
   if (sparam == objName) {
      resetTimeframe("MA", 0, 2, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MA_TF3";
   if (sparam == objName) {
      resetTimeframe("MA", 0, 3, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MA_TF4";
   if (sparam == objName) {
      resetTimeframe("MA", 0, 4, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MA_TF5";
   if (sparam == objName) {
      resetTimeframe("MA", 0, 5, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MA_TF6";
   if (sparam == objName) {
      resetTimeframe("MA", 0, 6, sparam);
      OnTimer();return;
   }

   objName = ObjNamePrefix+"MACD_TF0";
   if (sparam == objName) {
      resetTimeframe("MACD", 1, 0, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MACD_TF1";
   if (sparam == objName) {
      resetTimeframe("MACD", 1, 1, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MACD_TF2";
   if (sparam == objName) {
      resetTimeframe("MACD", 1, 2, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MACD_TF3";
   if (sparam == objName) {
      resetTimeframe("MACD", 1, 3, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MACD_TF4";
   if (sparam == objName) {
      resetTimeframe("MACD", 1, 4, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MACD_TF5";
   if (sparam == objName) {
      resetTimeframe("MACD", 1, 5, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"MACD_TF6";
   if (sparam == objName) {
      resetTimeframe("MACD", 1, 6, sparam);
      OnTimer();return;
   }

   objName = ObjNamePrefix+"RSI_TF0";
   if (sparam == objName) {
      resetTimeframe("RSI", 2, 0, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"RSI_TF1";
   if (sparam == objName) {
      resetTimeframe("RSI", 2, 1, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"RSI_TF2";
   if (sparam == objName) {
      resetTimeframe("RSI", 2, 2, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"RSI_TF3";
   if (sparam == objName) {
      resetTimeframe("RSI", 2, 3, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"RSI_TF4";
   if (sparam == objName) {
      resetTimeframe("RSI", 2, 4, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"RSI_TF5";
   if (sparam == objName) {
      resetTimeframe("RSI", 2, 5, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"RSI_TF6";
   if (sparam == objName) {
      resetTimeframe("RSI", 2, 6, sparam);
      OnTimer();return;
   }

   objName = ObjNamePrefix+"KDJ_TF0";
   if (sparam == objName) {
      resetTimeframe("KDJ", 3, 0, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"KDJ_TF1";
   if (sparam == objName) {
      resetTimeframe("KDJ", 3, 1, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"KDJ_TF2";
   if (sparam == objName) {
      resetTimeframe("KDJ", 3, 2, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"KDJ_TF3";
   if (sparam == objName) {
      resetTimeframe("KDJ", 3, 3, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"KDJ_TF4";
   if (sparam == objName) {
      resetTimeframe("KDJ", 3, 4, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"KDJ_TF5";
   if (sparam == objName) {
      resetTimeframe("KDJ", 3, 5, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"KDJ_TF6";
   if (sparam == objName) {
      resetTimeframe("KDJ", 3, 6, sparam);
      OnTimer();return;
   }

   objName = ObjNamePrefix+"ADX_TF0";
   if (sparam == objName) {
      resetTimeframe("ADX", 4, 0, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"ADX_TF1";
   if (sparam == objName) {
      resetTimeframe("ADX", 4, 1, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"ADX_TF2";
   if (sparam == objName) {
      resetTimeframe("ADX", 4, 2, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"ADX_TF3";
   if (sparam == objName) {
      resetTimeframe("ADX", 4, 3, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"ADX_TF4";
   if (sparam == objName) {
      resetTimeframe("ADX", 4, 4, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"ADX_TF5";
   if (sparam == objName) {
      resetTimeframe("ADX", 4, 5, sparam);
      OnTimer();return;
   }
   objName = ObjNamePrefix+"ADX_TF6";
   if (sparam == objName) {
      resetTimeframe("ADX", 4, 6, sparam);
      OnTimer();return;
   }


}

int createOrder(SymbolInfo *si, const int trade_operation) {
   double openPrice = 0.0, slPrice = 0.0, tpPrice = 0.0;
   double askPrice = MarketInfo(si.getRealName(), MODE_ASK);
   double bidPrice = MarketInfo(si.getRealName(), MODE_BID);
   string op_type = NULL;
   switch (trade_operation) {
      case OP_BUY:
         openPrice = askPrice;op_type="Buy";
         break;
      case OP_SELL:
         openPrice = bidPrice;op_type="Sell";
         break;
      default: return -1;
   }
   
   openPrice = NormalizeDouble(openPrice, si.getDigits());

   int ticket = OrderSend(si.getRealName(), trade_operation, gvLots, openPrice, 0, slPrice, tpPrice, COMMENT, Magic_Number, 0, clrNONE);
   
   if (ticket < 0) Print("OrderSend failed with error #", ErrorDescription(GetLastError()), " Symbol=", si.getRealName(), " Operation=", op_type);
   else Print("OrderSend placed successfully. Ticket ID=", ticket, " Symbol=", si.getRealName(), " Operation=", op_type);
   
   return ticket;
}

bool initSymbols() {
   tfs[0] = In_Timeframe1;
   tfs[1] = In_Timeframe2;
   tfs[2] = In_Timeframe3;
   tfs[3] = In_Timeframe4;
   tfs[4] = In_Timeframe5;
   tfs[5] = In_Timeframe6;
   tfs[6] = In_Timeframe7;
   /*
   gvUseTfs[0] = In_Use_Timeframe1;
   gvUseTfs[1] = In_Use_Timeframe2;
   gvUseTfs[2] = In_Use_Timeframe3;
   gvUseTfs[3] = In_Use_Timeframe4;
   gvUseTfs[4] = In_Use_Timeframe5;
   gvUseTfs[5] = In_Use_Timeframe6;
   gvUseTfs[6] = In_Use_Timeframe7;
   gvUseIndicators[0] = In_Use_MA;
   gvUseIndicators[1] = In_Use_MACD;
   gvUseIndicators[2] = In_Use_RSI;
   gvUseIndicators[3] = In_Use_KDJ;
   gvUseIndicators[4] = In_Use_ADX;
   */
   gvUseTfs[0][0] = In_Use_MA && In_Use_Timeframe1;
   gvUseTfs[0][1] = In_Use_MA && In_Use_Timeframe2;
   gvUseTfs[0][2] = In_Use_MA && In_Use_Timeframe3;
   gvUseTfs[0][3] = In_Use_MA && In_Use_Timeframe4;
   gvUseTfs[0][4] = In_Use_MA && In_Use_Timeframe5;
   gvUseTfs[0][5] = In_Use_MA && In_Use_Timeframe6;
   gvUseTfs[0][6] = In_Use_MA && In_Use_Timeframe7;
   
   gvUseTfs[1][0] = In_Use_MACD && In_Use_Timeframe1;
   gvUseTfs[1][1] = In_Use_MACD && In_Use_Timeframe2;
   gvUseTfs[1][2] = In_Use_MACD && In_Use_Timeframe3;
   gvUseTfs[1][3] = In_Use_MACD && In_Use_Timeframe4;
   gvUseTfs[1][4] = In_Use_MACD && In_Use_Timeframe5;
   gvUseTfs[1][5] = In_Use_MACD && In_Use_Timeframe6;
   gvUseTfs[1][6] = In_Use_MACD && In_Use_Timeframe7;

   gvUseTfs[2][0] = In_Use_RSI && In_Use_Timeframe1;
   gvUseTfs[2][1] = In_Use_RSI && In_Use_Timeframe2;
   gvUseTfs[2][2] = In_Use_RSI && In_Use_Timeframe3;
   gvUseTfs[2][3] = In_Use_RSI && In_Use_Timeframe4;
   gvUseTfs[2][4] = In_Use_RSI && In_Use_Timeframe5;
   gvUseTfs[2][5] = In_Use_RSI && In_Use_Timeframe6;
   gvUseTfs[2][6] = In_Use_RSI && In_Use_Timeframe7;

   gvUseTfs[3][0] = In_Use_KDJ && In_Use_Timeframe1;
   gvUseTfs[3][1] = In_Use_KDJ && In_Use_Timeframe2;
   gvUseTfs[3][2] = In_Use_KDJ && In_Use_Timeframe3;
   gvUseTfs[3][3] = In_Use_KDJ && In_Use_Timeframe4;
   gvUseTfs[3][4] = In_Use_KDJ && In_Use_Timeframe5;
   gvUseTfs[3][5] = In_Use_KDJ && In_Use_Timeframe6;
   gvUseTfs[3][6] = In_Use_KDJ && In_Use_Timeframe7;

   gvUseTfs[4][0] = In_Use_ADX && In_Use_Timeframe1;
   gvUseTfs[4][1] = In_Use_ADX && In_Use_Timeframe2;
   gvUseTfs[4][2] = In_Use_ADX && In_Use_Timeframe3;
   gvUseTfs[4][3] = In_Use_ADX && In_Use_Timeframe4;
   gvUseTfs[4][4] = In_Use_ADX && In_Use_Timeframe5;
   gvUseTfs[4][5] = In_Use_ADX && In_Use_Timeframe6;
   gvUseTfs[4][6] = In_Use_ADX && In_Use_Timeframe7;

   SymbolList = new CList();
   if (UseDefaultPairs) {
      gvCountSymbol = ArraySize(DefaultPairs);
      ArrayCopy(SymbolArray, DefaultPairs);

   } else {
      ushort u_sep = StringGetCharacter(",", 0);
      gvCountSymbol = StringSplit(In_Pairs, u_sep, SymbolArray);
   }

   for (int i=0; i<gvCountSymbol; i++) {
      SymbolInfo *si = new SymbolInfo(SymbolArray[i], Prefix, Surfix, i);
      SymbolList.Add(si);
      // MA Cross
      MqlParam params[5];
      // Timeframe 1
      CMACross *indiMACrossTF1 = new CMACross(si.getRealName(), In_Timeframe1);
      si.add2Indicators(indiMACrossTF1);
      params[0].type = TYPE_INT;
      params[0].integer_value = In_short_term_MA_period_TF1;
      params[1].type = TYPE_INT;
      params[1].integer_value = In_short_term_MA_method_TF1;
      params[2].type = TYPE_INT;
      params[2].integer_value = In_short_term_MA_shift_TF1;
      params[3].type = TYPE_INT;
      params[3].integer_value = In_short_term_MA_applied_price_TF1;
      if (!indiMACrossTF1.Create(params)) return false;

      params[0].integer_value = In_medium_term_MA_period_TF1;
      params[1].integer_value = In_medium_term_MA_method_TF1;
      params[2].integer_value = In_medium_term_MA_shift_TF1;
      params[3].integer_value = In_medium_term_MA_applied_price_TF1;
      if (!indiMACrossTF1.Create(params)) return false;

      params[0].integer_value = In_long_term_MA_period_TF1;
      params[1].integer_value = In_long_term_MA_method_TF1;
      params[2].integer_value = In_long_term_MA_shift_TF1;
      params[3].integer_value = In_long_term_MA_applied_price_TF1;
      if (!indiMACrossTF1.Create(params)) return false;
      if (gvUseTfs[0][0]) indiMACrossTF1.setEnable(true); else indiMACrossTF1.setEnable(false);

      // Timeframe 2
      CMACross *indiMACrossTF2 = new CMACross(si.getRealName(), In_Timeframe2);
      si.add2Indicators(indiMACrossTF2);
      params[0].integer_value = In_short_term_MA_period_TF2;
      params[1].integer_value = In_short_term_MA_method_TF2;
      params[2].integer_value = In_short_term_MA_shift_TF2;
      params[3].integer_value = In_short_term_MA_applied_price_TF2;
      if (!indiMACrossTF2.Create(params)) return false;

      params[0].integer_value = In_medium_term_MA_period_TF2;
      params[1].integer_value = In_medium_term_MA_method_TF2;
      params[2].integer_value = In_medium_term_MA_shift_TF2;
      params[3].integer_value = In_medium_term_MA_applied_price_TF2;
      if (!indiMACrossTF2.Create(params)) return false;

      params[0].integer_value = In_long_term_MA_period_TF2;
      params[1].integer_value = In_long_term_MA_method_TF2;
      params[2].integer_value = In_long_term_MA_shift_TF2;
      params[3].integer_value = In_long_term_MA_applied_price_TF2;
      if (!indiMACrossTF2.Create(params)) return false;
      if (gvUseTfs[0][1]) indiMACrossTF2.setEnable(true); else indiMACrossTF2.setEnable(false);
      // Timeframe 3
      CMACross *indiMACrossTF3 = new CMACross(si.getRealName(), In_Timeframe3);
      si.add2Indicators(indiMACrossTF3);
      params[0].integer_value = In_short_term_MA_period_TF3;
      params[1].integer_value = In_short_term_MA_method_TF3;
      params[2].integer_value = In_short_term_MA_shift_TF3;
      params[3].integer_value = In_short_term_MA_applied_price_TF3;
      if (!indiMACrossTF3.Create(params)) return false;

      params[0].integer_value = In_medium_term_MA_period_TF3;
      params[1].integer_value = In_medium_term_MA_method_TF3;
      params[2].integer_value = In_medium_term_MA_shift_TF3;
      params[3].integer_value = In_medium_term_MA_applied_price_TF3;
      if (!indiMACrossTF3.Create(params)) return false;

      params[0].integer_value = In_long_term_MA_period_TF3;
      params[1].integer_value = In_long_term_MA_method_TF3;
      params[2].integer_value = In_long_term_MA_shift_TF3;
      params[3].integer_value = In_long_term_MA_applied_price_TF3;
      if (!indiMACrossTF3.Create(params)) return false;
      if (gvUseTfs[0][2]) indiMACrossTF3.setEnable(true); else indiMACrossTF3.setEnable(false);
      // Timeframe 4
      CMACross *indiMACrossTF4 = new CMACross(si.getRealName(), In_Timeframe4);
      si.add2Indicators(indiMACrossTF4);
      params[0].integer_value = In_short_term_MA_period_TF4;
      params[1].integer_value = In_short_term_MA_method_TF4;
      params[2].integer_value = In_short_term_MA_shift_TF4;
      params[3].integer_value = In_short_term_MA_applied_price_TF4;
      if (!indiMACrossTF4.Create(params)) return false;

      params[0].integer_value = In_medium_term_MA_period_TF4;
      params[1].integer_value = In_medium_term_MA_method_TF4;
      params[2].integer_value = In_medium_term_MA_shift_TF4;
      params[3].integer_value = In_medium_term_MA_applied_price_TF4;
      if (!indiMACrossTF4.Create(params)) return false;

      params[0].integer_value = In_long_term_MA_period_TF4;
      params[1].integer_value = In_long_term_MA_method_TF4;
      params[2].integer_value = In_long_term_MA_shift_TF4;
      params[3].integer_value = In_long_term_MA_applied_price_TF4;
      if (!indiMACrossTF4.Create(params)) return false;
      if (gvUseTfs[0][3]) indiMACrossTF4.setEnable(true); else indiMACrossTF4.setEnable(false);

      // Timeframe 5
      CMACross *indiMACrossTF5 = new CMACross(si.getRealName(), In_Timeframe5);
      si.add2Indicators(indiMACrossTF5);
      params[0].integer_value = In_short_term_MA_period_TF5;
      params[1].integer_value = In_short_term_MA_method_TF5;
      params[2].integer_value = In_short_term_MA_shift_TF5;
      params[3].integer_value = In_short_term_MA_applied_price_TF5;
      if (!indiMACrossTF5.Create(params)) return false;

      params[0].integer_value = In_medium_term_MA_period_TF5;
      params[1].integer_value = In_medium_term_MA_method_TF5;
      params[2].integer_value = In_medium_term_MA_shift_TF5;
      params[3].integer_value = In_medium_term_MA_applied_price_TF5;
      if (!indiMACrossTF5.Create(params)) return false;

      params[0].integer_value = In_long_term_MA_period_TF5;
      params[1].integer_value = In_long_term_MA_method_TF5;
      params[2].integer_value = In_long_term_MA_shift_TF5;
      params[3].integer_value = In_long_term_MA_applied_price_TF5;
      if (!indiMACrossTF5.Create(params)) return false;
      if (gvUseTfs[0][4]) indiMACrossTF5.setEnable(true); else indiMACrossTF5.setEnable(false);

      // Timeframe 6
      CMACross *indiMACrossTF6 = new CMACross(si.getRealName(), In_Timeframe6);
      si.add2Indicators(indiMACrossTF6);
      params[0].integer_value = In_short_term_MA_period_TF6;
      params[1].integer_value = In_short_term_MA_method_TF6;
      params[2].integer_value = In_short_term_MA_shift_TF6;
      params[3].integer_value = In_short_term_MA_applied_price_TF6;
      if (!indiMACrossTF6.Create(params)) return false;

      params[0].integer_value = In_medium_term_MA_period_TF6;
      params[1].integer_value = In_medium_term_MA_method_TF6;
      params[2].integer_value = In_medium_term_MA_shift_TF6;
      params[3].integer_value = In_medium_term_MA_applied_price_TF6;
      if (!indiMACrossTF6.Create(params)) return false;

      params[0].integer_value = In_long_term_MA_period_TF6;
      params[1].integer_value = In_long_term_MA_method_TF6;
      params[2].integer_value = In_long_term_MA_shift_TF6;
      params[3].integer_value = In_long_term_MA_applied_price_TF6;
      if (!indiMACrossTF6.Create(params)) return false;
      if (gvUseTfs[0][5]) indiMACrossTF6.setEnable(true); else indiMACrossTF6.setEnable(false);

      // Timeframe 7
      CMACross *indiMACrossTF7 = new CMACross(si.getRealName(), In_Timeframe7);
      si.add2Indicators(indiMACrossTF7);
      params[0].integer_value = In_short_term_MA_period_TF7;
      params[1].integer_value = In_short_term_MA_method_TF7;
      params[2].integer_value = In_short_term_MA_shift_TF7;
      params[3].integer_value = In_short_term_MA_applied_price_TF7;
      if (!indiMACrossTF7.Create(params)) return false;

      params[0].integer_value = In_medium_term_MA_period_TF7;
      params[1].integer_value = In_medium_term_MA_method_TF7;
      params[2].integer_value = In_medium_term_MA_shift_TF7;
      params[3].integer_value = In_medium_term_MA_applied_price_TF7;
      if (!indiMACrossTF7.Create(params)) return false;

      params[0].integer_value = In_long_term_MA_period_TF7;
      params[1].integer_value = In_long_term_MA_method_TF7;
      params[2].integer_value = In_long_term_MA_shift_TF7;
      params[3].integer_value = In_long_term_MA_applied_price_TF7;
      if (!indiMACrossTF7.Create(params)) return false;
      if (gvUseTfs[0][6]) indiMACrossTF7.setEnable(true); else indiMACrossTF7.setEnable(false);

      // MACD Cross
      // Timeframe 1
      CMACDCross *indiMACDCrossTF1 = new CMACDCross(si.getRealName(), In_Timeframe1);
      si.add2Indicators(indiMACDCrossTF1);
      params[0].integer_value = In_MACD_Fast_EMA_Period_TF1;
      params[1].integer_value = In_MACD_Slow_EMA_Period_TF1;
      params[2].integer_value = In_MACD_Signal_Period_TF1;
      params[3].integer_value = In_MACD_Applied_Price_TF1;
      if (!indiMACDCrossTF1.Create(params)) return false;
      if (gvUseTfs[1][0]) indiMACDCrossTF1.setEnable(true); else indiMACDCrossTF1.setEnable(false);

      // Timeframe 2
      CMACDCross *indiMACDCrossTF2 = new CMACDCross(si.getRealName(), In_Timeframe2);
      si.add2Indicators(indiMACDCrossTF2);
      params[0].integer_value = In_MACD_Fast_EMA_Period_TF2;
      params[1].integer_value = In_MACD_Slow_EMA_Period_TF2;
      params[2].integer_value = In_MACD_Signal_Period_TF2;
      params[3].integer_value = In_MACD_Applied_Price_TF2;
      if (!indiMACDCrossTF2.Create(params)) return false;
      if (gvUseTfs[1][1]) indiMACDCrossTF2.setEnable(true); else indiMACDCrossTF2.setEnable(false);

      // Timeframe 3
      CMACDCross *indiMACDCrossTF3 = new CMACDCross(si.getRealName(), In_Timeframe3);
      si.add2Indicators(indiMACDCrossTF3);
      params[0].integer_value = In_MACD_Fast_EMA_Period_TF3;
      params[1].integer_value = In_MACD_Slow_EMA_Period_TF3;
      params[2].integer_value = In_MACD_Signal_Period_TF3;
      params[3].integer_value = In_MACD_Applied_Price_TF3;
      if (!indiMACDCrossTF3.Create(params)) return false;
      if (gvUseTfs[1][2]) indiMACDCrossTF3.setEnable(true); else indiMACDCrossTF3.setEnable(false);

      // Timeframe 4
      CMACDCross *indiMACDCrossTF4 = new CMACDCross(si.getRealName(), In_Timeframe4);
      si.add2Indicators(indiMACDCrossTF4);
      params[0].integer_value = In_MACD_Fast_EMA_Period_TF4;
      params[1].integer_value = In_MACD_Slow_EMA_Period_TF4;
      params[2].integer_value = In_MACD_Signal_Period_TF4;
      params[3].integer_value = In_MACD_Applied_Price_TF4;
      if (!indiMACDCrossTF4.Create(params)) return false;
      if (gvUseTfs[1][3]) indiMACDCrossTF4.setEnable(true); else indiMACDCrossTF4.setEnable(false);

      // Timeframe 5
      CMACDCross *indiMACDCrossTF5 = new CMACDCross(si.getRealName(), In_Timeframe5);
      si.add2Indicators(indiMACDCrossTF5);
      params[0].integer_value = In_MACD_Fast_EMA_Period_TF5;
      params[1].integer_value = In_MACD_Slow_EMA_Period_TF5;
      params[2].integer_value = In_MACD_Signal_Period_TF5;
      params[3].integer_value = In_MACD_Applied_Price_TF5;
      if (!indiMACDCrossTF5.Create(params)) return false;
      if (gvUseTfs[1][4]) indiMACDCrossTF5.setEnable(true); else indiMACDCrossTF5.setEnable(false);

      // Timeframe 6
      CMACDCross *indiMACDCrossTF6 = new CMACDCross(si.getRealName(), In_Timeframe6);
      si.add2Indicators(indiMACDCrossTF6);
      params[0].integer_value = In_MACD_Fast_EMA_Period_TF6;
      params[1].integer_value = In_MACD_Slow_EMA_Period_TF6;
      params[2].integer_value = In_MACD_Signal_Period_TF6;
      params[3].integer_value = In_MACD_Applied_Price_TF6;
      if (!indiMACDCrossTF6.Create(params)) return false;
      if (gvUseTfs[1][5]) indiMACDCrossTF6.setEnable(true); else indiMACDCrossTF6.setEnable(false);

      // Timeframe 7
      CMACDCross *indiMACDCrossTF7 = new CMACDCross(si.getRealName(), In_Timeframe7);
      si.add2Indicators(indiMACDCrossTF7);
      params[0].integer_value = In_MACD_Fast_EMA_Period_TF7;
      params[1].integer_value = In_MACD_Slow_EMA_Period_TF7;
      params[2].integer_value = In_MACD_Signal_Period_TF7;
      params[3].integer_value = In_MACD_Applied_Price_TF7;
      if (!indiMACDCrossTF7.Create(params)) return false;
      if (gvUseTfs[1][6]) indiMACDCrossTF7.setEnable(true); else indiMACDCrossTF7.setEnable(false);

      // RSI Cross
      // Timeframe 1
      CRSICross *indiRSICrossTF1 = new CRSICross(si.getRealName(), In_Timeframe1);
      si.add2Indicators(indiRSICrossTF1);
      params[0].integer_value = In_short_term_RSI_period_TF1;
      params[1].integer_value = In_short_term_RSI_applied_price_TF1;
      if (!indiRSICrossTF1.Create(params)) return false;
      params[0].integer_value = In_long_term_RSI_period_TF1;
      params[1].integer_value = In_long_term_RSI_applied_price_TF1;
      if (!indiRSICrossTF1.Create(params)) return false;
      if (gvUseTfs[2][0]) indiRSICrossTF1.setEnable(true); else indiRSICrossTF1.setEnable(false);

      // Timeframe 2
      CRSICross *indiRSICrossTF2 = new CRSICross(si.getRealName(), In_Timeframe2);
      si.add2Indicators(indiRSICrossTF2);
      params[0].integer_value = In_short_term_RSI_period_TF2;
      params[1].integer_value = In_short_term_RSI_applied_price_TF2;
      if (!indiRSICrossTF2.Create(params)) return false;
      params[0].integer_value = In_long_term_RSI_period_TF2;
      params[1].integer_value = In_long_term_RSI_applied_price_TF2;
      if (!indiRSICrossTF2.Create(params)) return false;
      if (gvUseTfs[2][1]) indiRSICrossTF2.setEnable(true); else indiRSICrossTF2.setEnable(false);

      // Timeframe 3
      CRSICross *indiRSICrossTF3 = new CRSICross(si.getRealName(), In_Timeframe3);
      si.add2Indicators(indiRSICrossTF3);
      params[0].integer_value = In_short_term_RSI_period_TF3;
      params[1].integer_value = In_short_term_RSI_applied_price_TF3;
      if (!indiRSICrossTF3.Create(params)) return false;
      params[0].integer_value = In_long_term_RSI_period_TF3;
      params[1].integer_value = In_long_term_RSI_applied_price_TF3;
      if (!indiRSICrossTF3.Create(params)) return false;
      if (gvUseTfs[2][2]) indiRSICrossTF3.setEnable(true); else indiRSICrossTF3.setEnable(false);

      // Timeframe 4
      CRSICross *indiRSICrossTF4 = new CRSICross(si.getRealName(), In_Timeframe4);
      si.add2Indicators(indiRSICrossTF4);
      params[0].integer_value = In_short_term_RSI_period_TF4;
      params[1].integer_value = In_short_term_RSI_applied_price_TF4;
      if (!indiRSICrossTF4.Create(params)) return false;
      params[0].integer_value = In_long_term_RSI_period_TF4;
      params[1].integer_value = In_long_term_RSI_applied_price_TF4;
      if (!indiRSICrossTF4.Create(params)) return false;
      if (gvUseTfs[2][3]) indiRSICrossTF4.setEnable(true); else indiRSICrossTF4.setEnable(false);

      // Timeframe 5
      CRSICross *indiRSICrossTF5 = new CRSICross(si.getRealName(), In_Timeframe5);
      si.add2Indicators(indiRSICrossTF5);
      params[0].integer_value = In_short_term_RSI_period_TF5;
      params[1].integer_value = In_short_term_RSI_applied_price_TF5;
      if (!indiRSICrossTF5.Create(params)) return false;
      params[0].integer_value = In_long_term_RSI_period_TF5;
      params[1].integer_value = In_long_term_RSI_applied_price_TF5;
      if (!indiRSICrossTF5.Create(params)) return false;
      if (gvUseTfs[2][4]) indiRSICrossTF5.setEnable(true); else indiRSICrossTF5.setEnable(false);

      // Timeframe 6
      CRSICross *indiRSICrossTF6 = new CRSICross(si.getRealName(), In_Timeframe6);
      si.add2Indicators(indiRSICrossTF6);
      params[0].integer_value = In_short_term_RSI_period_TF6;
      params[1].integer_value = In_short_term_RSI_applied_price_TF6;
      if (!indiRSICrossTF6.Create(params)) return false;
      params[0].integer_value = In_long_term_RSI_period_TF6;
      params[1].integer_value = In_long_term_RSI_applied_price_TF6;
      if (!indiRSICrossTF6.Create(params)) return false;
      if (gvUseTfs[2][5]) indiRSICrossTF6.setEnable(true); else indiRSICrossTF6.setEnable(false);

      // Timeframe 7
      CRSICross *indiRSICrossTF7 = new CRSICross(si.getRealName(), In_Timeframe7);
      si.add2Indicators(indiRSICrossTF7);
      params[0].integer_value = In_short_term_RSI_period_TF7;
      params[1].integer_value = In_short_term_RSI_applied_price_TF7;
      if (!indiRSICrossTF7.Create(params)) return false;
      params[0].integer_value = In_long_term_RSI_period_TF7;
      params[1].integer_value = In_long_term_RSI_applied_price_TF7;
      if (!indiRSICrossTF7.Create(params)) return false;
      if (gvUseTfs[2][6]) indiRSICrossTF7.setEnable(true); else indiRSICrossTF7.setEnable(false);
      
      // KDJ Cross
      // Timeframe 1
      CKDJCross *indiKDJCrossTF1 = new CKDJCross(si.getRealName(), In_Timeframe1);
      si.add2Indicators(indiKDJCrossTF1);
      params[0].integer_value = In_KDJ_Kperiod_TF1;
      params[1].integer_value = In_KDJ_Dperiod_TF1;
      params[2].integer_value = In_KDJ_slowing_TF1;
      params[3].integer_value = In_KDJ_method_TF1;
      params[4].type = TYPE_INT;
      params[4].integer_value = In_KDJ_price_field_TF1;
      if (!indiKDJCrossTF1.Create(params)) return false;
      if (gvUseTfs[3][0]) indiKDJCrossTF1.setEnable(true); else indiKDJCrossTF1.setEnable(false);

      // Timeframe 2
      CKDJCross *indiKDJCrossTF2 = new CKDJCross(si.getRealName(), In_Timeframe2);
      si.add2Indicators(indiKDJCrossTF2);
      params[0].integer_value = In_KDJ_Kperiod_TF2;
      params[1].integer_value = In_KDJ_Dperiod_TF2;
      params[2].integer_value = In_KDJ_slowing_TF2;
      params[3].integer_value = In_KDJ_method_TF2;
      params[4].integer_value = In_KDJ_price_field_TF2;
      if (!indiKDJCrossTF2.Create(params)) return false;
      if (gvUseTfs[3][1]) indiKDJCrossTF2.setEnable(true); else indiKDJCrossTF2.setEnable(false);

      // Timeframe 3
      CKDJCross *indiKDJCrossTF3 = new CKDJCross(si.getRealName(), In_Timeframe3);
      si.add2Indicators(indiKDJCrossTF3);
      params[0].integer_value = In_KDJ_Kperiod_TF3;
      params[1].integer_value = In_KDJ_Dperiod_TF3;
      params[2].integer_value = In_KDJ_slowing_TF3;
      params[3].integer_value = In_KDJ_method_TF3;
      params[4].integer_value = In_KDJ_price_field_TF3;
      if (!indiKDJCrossTF3.Create(params)) return false;
      if (gvUseTfs[3][2]) indiKDJCrossTF3.setEnable(true); else indiKDJCrossTF3.setEnable(false);

      // Timeframe 4
      CKDJCross *indiKDJCrossTF4 = new CKDJCross(si.getRealName(), In_Timeframe4);
      si.add2Indicators(indiKDJCrossTF4);
      params[0].integer_value = In_KDJ_Kperiod_TF4;
      params[1].integer_value = In_KDJ_Dperiod_TF4;
      params[2].integer_value = In_KDJ_slowing_TF4;
      params[3].integer_value = In_KDJ_method_TF4;
      params[4].integer_value = In_KDJ_price_field_TF4;
      if (!indiKDJCrossTF4.Create(params)) return false;
      if (gvUseTfs[3][3]) indiKDJCrossTF4.setEnable(true); else indiKDJCrossTF4.setEnable(false);

      // Timeframe 5
      CKDJCross *indiKDJCrossTF5 = new CKDJCross(si.getRealName(), In_Timeframe5);
      si.add2Indicators(indiKDJCrossTF5);
      params[0].integer_value = In_KDJ_Kperiod_TF5;
      params[1].integer_value = In_KDJ_Dperiod_TF5;
      params[2].integer_value = In_KDJ_slowing_TF5;
      params[3].integer_value = In_KDJ_method_TF5;
      params[4].integer_value = In_KDJ_price_field_TF5;
      if (!indiKDJCrossTF5.Create(params)) return false;
      if (gvUseTfs[3][4]) indiKDJCrossTF5.setEnable(true); else indiKDJCrossTF5.setEnable(false);

      // Timeframe 6
      CKDJCross *indiKDJCrossTF6 = new CKDJCross(si.getRealName(), In_Timeframe6);
      si.add2Indicators(indiKDJCrossTF6);
      params[0].integer_value = In_KDJ_Kperiod_TF6;
      params[1].integer_value = In_KDJ_Dperiod_TF6;
      params[2].integer_value = In_KDJ_slowing_TF6;
      params[3].integer_value = In_KDJ_method_TF6;
      params[4].integer_value = In_KDJ_price_field_TF6;
      if (!indiKDJCrossTF6.Create(params)) return false;
      if (gvUseTfs[3][5]) indiKDJCrossTF6.setEnable(true); else indiKDJCrossTF6.setEnable(false);

      // Timeframe 7
      CKDJCross *indiKDJCrossTF7 = new CKDJCross(si.getRealName(), In_Timeframe7);
      si.add2Indicators(indiKDJCrossTF7);
      params[0].integer_value = In_KDJ_Kperiod_TF7;
      params[1].integer_value = In_KDJ_Dperiod_TF7;
      params[2].integer_value = In_KDJ_slowing_TF7;
      params[3].integer_value = In_KDJ_method_TF7;
      params[4].integer_value = In_KDJ_price_field_TF7;
      if (!indiKDJCrossTF7.Create(params)) return false;
      if (gvUseTfs[3][6]) indiKDJCrossTF7.setEnable(true); else indiKDJCrossTF7.setEnable(false);

      // ADX Cross
      // Timeframe 1
      CADXCross *indiADXCrossTF1 = new CADXCross(si.getRealName(), In_Timeframe1);
      si.add2Indicators(indiADXCrossTF1);
      params[0].integer_value = In_ADX_period_TF1;
      params[1].integer_value = In_ADX_applied_price_TF1;
      if (!indiADXCrossTF1.Create(params)) return false;
      if (gvUseTfs[4][0]) indiADXCrossTF1.setEnable(true); else indiADXCrossTF1.setEnable(false);
      // Timeframe 2
      CADXCross *indiADXCrossTF2 = new CADXCross(si.getRealName(), In_Timeframe2);
      si.add2Indicators(indiADXCrossTF2);
      params[0].integer_value = In_ADX_period_TF2;
      params[1].integer_value = In_ADX_applied_price_TF2;
      if (!indiADXCrossTF2.Create(params)) return false;
      if (gvUseTfs[4][1]) indiADXCrossTF2.setEnable(true); else indiADXCrossTF2.setEnable(false);
      // Timeframe 3
      CADXCross *indiADXCrossTF3 = new CADXCross(si.getRealName(), In_Timeframe3);
      si.add2Indicators(indiADXCrossTF3);
      params[0].integer_value = In_ADX_period_TF3;
      params[1].integer_value = In_ADX_applied_price_TF3;
      if (!indiADXCrossTF3.Create(params)) return false;
      if (gvUseTfs[4][2]) indiADXCrossTF3.setEnable(true); else indiADXCrossTF3.setEnable(false);
      // Timeframe 4
      CADXCross *indiADXCrossTF4 = new CADXCross(si.getRealName(), In_Timeframe4);
      si.add2Indicators(indiADXCrossTF4);
      params[0].integer_value = In_ADX_period_TF4;
      params[1].integer_value = In_ADX_applied_price_TF4;
      if (!indiADXCrossTF4.Create(params)) return false;
      if (gvUseTfs[4][3]) indiADXCrossTF4.setEnable(true); else indiADXCrossTF4.setEnable(false);
      // Timeframe 5
      CADXCross *indiADXCrossTF5 = new CADXCross(si.getRealName(), In_Timeframe5);
      si.add2Indicators(indiADXCrossTF5);
      params[0].integer_value = In_ADX_period_TF5;
      params[1].integer_value = In_ADX_applied_price_TF5;
      if (!indiADXCrossTF5.Create(params)) return false;
      if (gvUseTfs[4][4]) indiADXCrossTF5.setEnable(true); else indiADXCrossTF5.setEnable(false);
      // Timeframe 6
      CADXCross *indiADXCrossTF6 = new CADXCross(si.getRealName(), In_Timeframe6);
      si.add2Indicators(indiADXCrossTF6);
      params[0].integer_value = In_ADX_period_TF6;
      params[1].integer_value = In_ADX_applied_price_TF6;
      if (!indiADXCrossTF6.Create(params)) return false;
      if (gvUseTfs[4][5]) indiADXCrossTF6.setEnable(true); else indiADXCrossTF6.setEnable(false);
      // Timeframe 7
      CADXCross *indiADXCrossTF7 = new CADXCross(si.getRealName(), In_Timeframe7);
      si.add2Indicators(indiADXCrossTF7);
      params[0].integer_value = In_ADX_period_TF7;
      params[1].integer_value = In_ADX_applied_price_TF7;
      if (!indiADXCrossTF7.Create(params)) return false;
      if (gvUseTfs[4][6]) indiADXCrossTF7.setEnable(true); else indiADXCrossTF7.setEnable(false);

      si.setEnabled(true);
   }
   return true;
}

string getTimeframeStr(ENUM_TIMEFRAMES tf) {
   if (PERIOD_M1 == tf) return "M1";
   if (PERIOD_M5 == tf) return "M5";
   if (PERIOD_M15 == tf) return "15";
   if (PERIOD_M30 == tf) return "30";
   if (PERIOD_H1 == tf) return "H1";
   if (PERIOD_H4 == tf) return "H4";
   if (PERIOD_D1 == tf) return "D1";
   if (PERIOD_W1 == tf) return "W1";
   if (PERIOD_MN1 == tf) return "N1";
   return "";
}

string getAppliedPriceStr(ENUM_APPLIED_PRICE ap) {
   if (PRICE_CLOSE == ap) return "C";
   if (PRICE_OPEN == ap) return "O";
   if (PRICE_HIGH == ap) return "H";
   if (PRICE_LOW == ap) return "L";
   if (PRICE_MEDIAN == ap) return "M";
   if (PRICE_TYPICAL == ap) return "T";
   if (PRICE_WEIGHTED == ap) return "W";
   return "";
}

string getMaMethodStr(ENUM_MA_METHOD mm) {
   if (MODE_SMA == mm) return "S";
   if (MODE_EMA == mm) return "E";
   if (MODE_SMMA == mm) return "M";
   if (MODE_LWMA == mm) return "L";
   return "";
}

bool isUsedIndicator(int indexIndicator) {
   return gvUseTfs[indexIndicator][0]||gvUseTfs[indexIndicator][1]||gvUseTfs[indexIndicator][2]||gvUseTfs[indexIndicator][3]||gvUseTfs[indexIndicator][4]||gvUseTfs[indexIndicator][5]||gvUseTfs[indexIndicator][6];
}

void Draw(int startXi, int startYi, CList *symbolList) {
   int x = startXi;
   int y = startYi;
   long chartId = 0;

   string ColName = "";
   int width=0, xAdjust=0, height=HEIGHT_ROW;
   if (In_4Kdisplay) height=HEIGHT_ROW_4K;

   /*******************************indicator name row start*******************************************************************/
   int FontSizeHeaderIndicatorName = 5;
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x = startXi;
   width = WIDTH_MV;
   if (In_4Kdisplay) { width=WIDTH_MV_4K; }
   x += width + ColumnInterval;
   width = WIDTH_SYMBOL;
   if (In_4Kdisplay) { width=WIDTH_SYMBOL_4K; }
   x += width + ColumnInterval;
   width = WIDTH_NEW_ORDER;
   if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
   x += (width + ColumnInterval)*2;
   width = (WIDTH_SIGNAL + ColumnInterval)*7;
   if (In_4Kdisplay) { width=(WIDTH_SIGNAL_4K + ColumnInterval)*7; }
   
   ColName = "indi_MA";
   CreateButton(ObjNamePrefix+ColName,"MA",x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderIndicatorName);
   if (isUsedIndicator(0)) setBtnSelected(ObjNamePrefix+ColName); else setBtnUnselected(ObjNamePrefix+ColName);
   
   x += width + ColumnInterval;
   ColName = "indi_MACD";
   CreateButton(ObjNamePrefix+ColName,"MACD",x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderIndicatorName);
   if (isUsedIndicator(1)) setBtnSelected(ObjNamePrefix+ColName); else setBtnUnselected(ObjNamePrefix+ColName);
   
   x += width + ColumnInterval;
   ColName = "indi_RSI";
   CreateButton(ObjNamePrefix+ColName,"RSI",x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderIndicatorName);
   if (isUsedIndicator(2)) setBtnSelected(ObjNamePrefix+ColName); else setBtnUnselected(ObjNamePrefix+ColName);
   
   x += width + ColumnInterval;
   ColName = "indi_KDJ";
   CreateButton(ObjNamePrefix+ColName,"KDJ",x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderIndicatorName);
   if (isUsedIndicator(3)) setBtnSelected(ObjNamePrefix+ColName); else setBtnUnselected(ObjNamePrefix+ColName);
   
   x += width + ColumnInterval;
   ColName = "indi_ADX";
   CreateButton(ObjNamePrefix+ColName,"ADX",x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderIndicatorName);
   if (isUsedIndicator(4)) setBtnSelected(ObjNamePrefix+ColName); else setBtnUnselected(ObjNamePrefix+ColName);
   /*******************************indicator name row end  *******************************************************************/

   // header row1 start
   y += height + RowInterval;
   // header parameter MA row1 start
   height=HEIGHT_ROW_MA;
   if (In_4Kdisplay) height=HEIGHT_ROW_MA_4K;
   int FontSizeHeaderParam = 5;
   xAdjust = 0;
   x = startXi;
   width = WIDTH_MV;
   if (In_4Kdisplay) { width=WIDTH_MV_4K; }
   x += width + ColumnInterval;
   width = WIDTH_SYMBOL;
   if (In_4Kdisplay) { width=WIDTH_SYMBOL_4K; }
   x += width + ColumnInterval;
   width = WIDTH_NEW_ORDER;
   if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
   x += (width + ColumnInterval)*2;
   width = WIDTH_SIGNAL;
   if (In_4Kdisplay) { width=WIDTH_SIGNAL_4K; }
   ColName = "MA_PSTF1";
   string paramHeader = getMaMethodStr(In_short_term_MA_method_TF1);
   paramHeader += IntegerToString(In_short_term_MA_shift_TF1);
   paramHeader += getAppliedPriceStr(In_short_term_MA_applied_price_TF1);
   paramHeader += IntegerToString(In_short_term_MA_period_TF1, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PSTF2";
   paramHeader = getMaMethodStr(In_short_term_MA_method_TF2);
   paramHeader += IntegerToString(In_short_term_MA_shift_TF2);
   paramHeader += getAppliedPriceStr(In_short_term_MA_applied_price_TF2);
   paramHeader += IntegerToString(In_short_term_MA_period_TF2, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PSTF3";
   paramHeader = getMaMethodStr(In_short_term_MA_method_TF3);
   paramHeader += IntegerToString(In_short_term_MA_shift_TF3);
   paramHeader += getAppliedPriceStr(In_short_term_MA_applied_price_TF3);
   paramHeader += IntegerToString(In_short_term_MA_period_TF3, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);

   x += width + ColumnInterval;
   ColName = "MA_PSTF4";
   paramHeader = getMaMethodStr(In_short_term_MA_method_TF4);
   paramHeader += IntegerToString(In_short_term_MA_shift_TF4);
   paramHeader += getAppliedPriceStr(In_short_term_MA_applied_price_TF4);
   paramHeader += IntegerToString(In_short_term_MA_period_TF4, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PSTF5";
   paramHeader = getMaMethodStr(In_short_term_MA_method_TF5);
   paramHeader += IntegerToString(In_short_term_MA_shift_TF5);
   paramHeader += getAppliedPriceStr(In_short_term_MA_applied_price_TF5);
   paramHeader += IntegerToString(In_short_term_MA_period_TF5, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PSTF6";
   paramHeader = getMaMethodStr(In_short_term_MA_method_TF6);
   paramHeader += IntegerToString(In_short_term_MA_shift_TF6);
   paramHeader += getAppliedPriceStr(In_short_term_MA_applied_price_TF6);
   paramHeader += IntegerToString(In_short_term_MA_period_TF6, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PSTF7";
   paramHeader = getMaMethodStr(In_short_term_MA_method_TF7);
   paramHeader += IntegerToString(In_short_term_MA_shift_TF7);
   paramHeader += getAppliedPriceStr(In_short_term_MA_applied_price_TF7);
   paramHeader += IntegerToString(In_short_term_MA_period_TF7, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   // header parameter MA row1 end
   /*******************************MACD parameter row1 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "MACD_FPTF1";
   paramHeader = IntegerToString(In_MACD_Fast_EMA_Period_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_FPTF2";
   paramHeader = IntegerToString(In_MACD_Fast_EMA_Period_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_FPTF3";
   paramHeader = IntegerToString(In_MACD_Fast_EMA_Period_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_FPTF4";
   paramHeader = IntegerToString(In_MACD_Fast_EMA_Period_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_FPTF5";
   paramHeader = IntegerToString(In_MACD_Fast_EMA_Period_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_FPTF6";
   paramHeader = IntegerToString(In_MACD_Fast_EMA_Period_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_FPTF7";
   paramHeader = IntegerToString(In_MACD_Fast_EMA_Period_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /*******************************MACD parameter row1 end  *******************************************************************/
   /******************************* RSI parameter row1 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "RSI_FPTF1";
   paramHeader = IntegerToString(In_short_term_RSI_period_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FPTF2";
   paramHeader = IntegerToString(In_short_term_RSI_period_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FPTF3";
   paramHeader = IntegerToString(In_short_term_RSI_period_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FPTF4";
   paramHeader = IntegerToString(In_short_term_RSI_period_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FPTF5";
   paramHeader = IntegerToString(In_short_term_RSI_period_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FPTF6";
   paramHeader = IntegerToString(In_short_term_RSI_period_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FPTF7";
   paramHeader = IntegerToString(In_short_term_RSI_period_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* RSI parameter row1 end  *******************************************************************/
   /******************************* KDJ parameter row1 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "KDJ_KPTF1";
   paramHeader = IntegerToString(In_KDJ_Kperiod_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_KPTF2";
   paramHeader = IntegerToString(In_KDJ_Kperiod_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_KPTF3";
   paramHeader = IntegerToString(In_KDJ_Kperiod_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_KPTF4";
   paramHeader = IntegerToString(In_KDJ_Kperiod_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_KPTF5";
   paramHeader = IntegerToString(In_KDJ_Kperiod_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_KPTF6";
   paramHeader = IntegerToString(In_KDJ_Kperiod_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_KPTF7";
   paramHeader = IntegerToString(In_KDJ_Kperiod_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* KDJ parameter row1 end  *******************************************************************/
   /******************************* ADX parameter row1 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "ADX_PTF1";
   paramHeader = IntegerToString(In_ADX_period_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_PTF2";
   paramHeader = IntegerToString(In_ADX_period_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_PTF3";
   paramHeader = IntegerToString(In_ADX_period_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_PTF4";
   paramHeader = IntegerToString(In_ADX_period_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_PTF5";
   paramHeader = IntegerToString(In_ADX_period_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_PTF6";
   paramHeader = IntegerToString(In_ADX_period_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_PTF7";
   paramHeader = IntegerToString(In_ADX_period_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* ADX parameter row1 end  *******************************************************************/
   // row1 end
   // row2 start
   // header parameter MA row2 start
   height=HEIGHT_ROW_MA;
   if (In_4Kdisplay) height=HEIGHT_ROW_MA_4K;
   y += height + RowInterval;
   ColName = "MA_PMTF1";
   x = startXi;
   width = WIDTH_MV;
   if (In_4Kdisplay) { width=WIDTH_MV_4K; }
   x += width + ColumnInterval;
   width = WIDTH_SYMBOL;
   if (In_4Kdisplay) { width=WIDTH_SYMBOL_4K; }
   x += width + ColumnInterval;
   width = WIDTH_NEW_ORDER;
   if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
   x += (width + ColumnInterval)*2;
   width = WIDTH_SIGNAL;
   if (In_4Kdisplay) { width=WIDTH_SIGNAL_4K; }
   paramHeader = getMaMethodStr(In_medium_term_MA_method_TF1);
   paramHeader += IntegerToString(In_medium_term_MA_shift_TF1);
   paramHeader += getAppliedPriceStr(In_medium_term_MA_applied_price_TF1);
   paramHeader += IntegerToString(In_medium_term_MA_period_TF1, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);

   x += width + ColumnInterval;
   ColName = "MA_PMTF2";
   paramHeader = getMaMethodStr(In_medium_term_MA_method_TF2);
   paramHeader += IntegerToString(In_medium_term_MA_shift_TF2);
   paramHeader += getAppliedPriceStr(In_medium_term_MA_applied_price_TF2);
   paramHeader += IntegerToString(In_medium_term_MA_period_TF2, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PMTF3";
   paramHeader = getMaMethodStr(In_medium_term_MA_method_TF3);
   paramHeader += IntegerToString(In_medium_term_MA_shift_TF3);
   paramHeader += getAppliedPriceStr(In_medium_term_MA_applied_price_TF3);
   paramHeader += IntegerToString(In_medium_term_MA_period_TF3, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PMTF4";
   paramHeader = getMaMethodStr(In_medium_term_MA_method_TF4);
   paramHeader += IntegerToString(In_medium_term_MA_shift_TF4);
   paramHeader += getAppliedPriceStr(In_medium_term_MA_applied_price_TF4);
   paramHeader += IntegerToString(In_medium_term_MA_period_TF4, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PMTF5";
   paramHeader = getMaMethodStr(In_medium_term_MA_method_TF5);
   paramHeader += IntegerToString(In_medium_term_MA_shift_TF5);
   paramHeader += getAppliedPriceStr(In_medium_term_MA_applied_price_TF5);
   paramHeader += IntegerToString(In_medium_term_MA_period_TF5, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PMTF6";
   paramHeader = getMaMethodStr(In_medium_term_MA_method_TF6);
   paramHeader += IntegerToString(In_medium_term_MA_shift_TF6);
   paramHeader += getAppliedPriceStr(In_medium_term_MA_applied_price_TF6);
   paramHeader += IntegerToString(In_medium_term_MA_period_TF6, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PMTF7";
   paramHeader = getMaMethodStr(In_medium_term_MA_method_TF7);
   paramHeader += IntegerToString(In_medium_term_MA_shift_TF7);
   paramHeader += getAppliedPriceStr(In_medium_term_MA_applied_price_TF7);
   paramHeader += IntegerToString(In_medium_term_MA_period_TF7, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   // header parameter MA row2 end
   /*******************************MACD parameter row2 start*******************************************************************/
   y -= height + RowInterval;
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   y += height + RowInterval;
   x += width + ColumnInterval;
   ColName = "MACD_SPTF1";
   paramHeader = IntegerToString(In_MACD_Slow_EMA_Period_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SPTF2";
   paramHeader = IntegerToString(In_MACD_Slow_EMA_Period_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SPTF3";
   paramHeader = IntegerToString(In_MACD_Slow_EMA_Period_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SPTF4";
   paramHeader = IntegerToString(In_MACD_Slow_EMA_Period_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SPTF5";
   paramHeader = IntegerToString(In_MACD_Slow_EMA_Period_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SPTF6";
   paramHeader = IntegerToString(In_MACD_Slow_EMA_Period_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SPTF7";
   paramHeader = IntegerToString(In_MACD_Slow_EMA_Period_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /*******************************MACD parameter row2 end  *******************************************************************/
   /******************************* RSI parameter row2 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "RSI_FAPTF1";
   paramHeader = getAppliedPriceStr(In_short_term_RSI_applied_price_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FAPTF2";
   paramHeader = getAppliedPriceStr(In_short_term_RSI_applied_price_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FAPTF3";
   paramHeader = getAppliedPriceStr(In_short_term_RSI_applied_price_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FAPTF4";
   paramHeader = getAppliedPriceStr(In_short_term_RSI_applied_price_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FAPTF5";
   paramHeader = getAppliedPriceStr(In_short_term_RSI_applied_price_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FAPTF6";
   paramHeader = getAppliedPriceStr(In_short_term_RSI_applied_price_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_FAPTF7";
   paramHeader = getAppliedPriceStr(In_short_term_RSI_applied_price_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* RSI parameter row2 end  *******************************************************************/
   /******************************* KDJ parameter row2 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "KDJ_DPTF1";
   paramHeader = IntegerToString(In_KDJ_Dperiod_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_DPTF2";
   paramHeader = IntegerToString(In_KDJ_Dperiod_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_DPTF3";
   paramHeader = IntegerToString(In_KDJ_Dperiod_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_DPTF4";
   paramHeader = IntegerToString(In_KDJ_Dperiod_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_DPTF5";
   paramHeader = IntegerToString(In_KDJ_Dperiod_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_DPTF6";
   paramHeader = IntegerToString(In_KDJ_Dperiod_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_DPTF7";
   paramHeader = IntegerToString(In_KDJ_Dperiod_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* KDJ parameter row2 end  *******************************************************************/
   /******************************* ADX parameter row2 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "ADX_APTF1";
   paramHeader = getAppliedPriceStr(In_ADX_applied_price_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_APTF2";
   paramHeader = getAppliedPriceStr(In_ADX_applied_price_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_APTF3";
   paramHeader = getAppliedPriceStr(In_ADX_applied_price_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_APTF4";
   paramHeader = getAppliedPriceStr(In_ADX_applied_price_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_APTF5";
   paramHeader = getAppliedPriceStr(In_ADX_applied_price_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_APTF6";
   paramHeader = getAppliedPriceStr(In_ADX_applied_price_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "ADX_APTF7";
   paramHeader = getAppliedPriceStr(In_ADX_applied_price_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* ADX parameter row2 end  *******************************************************************/
   // row2 end
   // row3 start
   // header parameter MA row3 start
   y -= height + RowInterval;
   height=HEIGHT_ROW_MA;
   if (In_4Kdisplay) height=HEIGHT_ROW_MA_4K;
   y += (height + RowInterval)*2;
   ColName = "MA_PLTF1";
   x = startXi;
   width = WIDTH_MV;
   if (In_4Kdisplay) { width=WIDTH_MV_4K; }
   x += width + ColumnInterval;
   width = WIDTH_SYMBOL;
   if (In_4Kdisplay) { width=WIDTH_SYMBOL_4K; }
   x += width + ColumnInterval;
   width = WIDTH_NEW_ORDER;
   if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
   x += (width + ColumnInterval)*2;
   width = WIDTH_SIGNAL;
   if (In_4Kdisplay) { width=WIDTH_SIGNAL_4K; }
   paramHeader = getMaMethodStr(In_long_term_MA_method_TF1);
   paramHeader += IntegerToString(In_long_term_MA_shift_TF1);
   paramHeader += getAppliedPriceStr(In_long_term_MA_applied_price_TF1);
   paramHeader += IntegerToString(In_long_term_MA_period_TF1, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);

   x += width + ColumnInterval;
   ColName = "MA_PLTF2";
   paramHeader = getMaMethodStr(In_long_term_MA_method_TF2);
   paramHeader += IntegerToString(In_long_term_MA_shift_TF2);
   paramHeader += getAppliedPriceStr(In_long_term_MA_applied_price_TF2);
   paramHeader += IntegerToString(In_long_term_MA_period_TF2, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PLTF3";
   paramHeader = getMaMethodStr(In_long_term_MA_method_TF3);
   paramHeader += IntegerToString(In_long_term_MA_shift_TF3);
   paramHeader += getAppliedPriceStr(In_long_term_MA_applied_price_TF3);
   paramHeader += IntegerToString(In_long_term_MA_period_TF3, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PLTF4";
   paramHeader = getMaMethodStr(In_long_term_MA_method_TF4);
   paramHeader += IntegerToString(In_long_term_MA_shift_TF4);
   paramHeader += getAppliedPriceStr(In_long_term_MA_applied_price_TF4);
   paramHeader += IntegerToString(In_long_term_MA_period_TF4, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PLTF5";
   paramHeader = getMaMethodStr(In_long_term_MA_method_TF5);
   paramHeader += IntegerToString(In_long_term_MA_shift_TF5);
   paramHeader += getAppliedPriceStr(In_long_term_MA_applied_price_TF5);
   paramHeader += IntegerToString(In_long_term_MA_period_TF5, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PLTF6";
   paramHeader = getMaMethodStr(In_long_term_MA_method_TF6);
   paramHeader += IntegerToString(In_long_term_MA_shift_TF6);
   paramHeader += getAppliedPriceStr(In_long_term_MA_applied_price_TF6);
   paramHeader += IntegerToString(In_long_term_MA_period_TF6, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MA_PLTF7";
   paramHeader = getMaMethodStr(In_long_term_MA_method_TF7);
   paramHeader += IntegerToString(In_long_term_MA_shift_TF7);
   paramHeader += getAppliedPriceStr(In_long_term_MA_applied_price_TF7);
   paramHeader += IntegerToString(In_long_term_MA_period_TF7, 3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   // header parameter MA row3 end
   /*******************************MACD parameter row3 start*******************************************************************/
   y -= (height + RowInterval)*2;
   //y -= height + RowInterval;
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   y += (height + RowInterval)*2;
   x += width + ColumnInterval;
   ColName = "MACD_SgPTF1";
   paramHeader = IntegerToString(In_MACD_Signal_Period_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SgPTF2";
   paramHeader = IntegerToString(In_MACD_Signal_Period_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SgPTF3";
   paramHeader = IntegerToString(In_MACD_Signal_Period_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SgPTF4";
   paramHeader = IntegerToString(In_MACD_Signal_Period_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SgPTF5";
   paramHeader = IntegerToString(In_MACD_Signal_Period_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SgPTF6";
   paramHeader = IntegerToString(In_MACD_Signal_Period_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_SgPTF7";
   paramHeader = IntegerToString(In_MACD_Signal_Period_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /*******************************MACD parameter row3 end  *******************************************************************/
   /******************************* RSI parameter row3 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "RSI_SPTF1";
   paramHeader = IntegerToString(In_long_term_RSI_period_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SPTF2";
   paramHeader = IntegerToString(In_long_term_RSI_period_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SPTF3";
   paramHeader = IntegerToString(In_long_term_RSI_period_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SPTF4";
   paramHeader = IntegerToString(In_long_term_RSI_period_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SPTF5";
   paramHeader = IntegerToString(In_long_term_RSI_period_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SPTF6";
   paramHeader = IntegerToString(In_long_term_RSI_period_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SPTF7";
   paramHeader = IntegerToString(In_long_term_RSI_period_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* RSI parameter row3 end  *******************************************************************/
   /******************************* KDJ parameter row3 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "KDJ_SPTF1";
   paramHeader = IntegerToString(In_KDJ_slowing_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_SPTF2";
   paramHeader = IntegerToString(In_KDJ_slowing_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_SPTF3";
   paramHeader = IntegerToString(In_KDJ_slowing_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_SPTF4";
   paramHeader = IntegerToString(In_KDJ_slowing_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_SPTF5";
   paramHeader = IntegerToString(In_KDJ_slowing_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_SPTF6";
   paramHeader = IntegerToString(In_KDJ_slowing_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_SPTF7";
   paramHeader = IntegerToString(In_KDJ_slowing_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* KDJ parameter row3 end  *******************************************************************/
   
   // row3 end
   // row4 start
   y += height + RowInterval;
   /*******************************MACD parameter row4 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x = startXi;
   width = WIDTH_MV;
   if (In_4Kdisplay) { width=WIDTH_MV_4K; }
   x += width + ColumnInterval;
   width = WIDTH_SYMBOL;
   if (In_4Kdisplay) { width=WIDTH_SYMBOL_4K; }
   x += width + ColumnInterval;
   width = WIDTH_NEW_ORDER;
   if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
   x += (width + ColumnInterval)*2;
   width = WIDTH_SIGNAL;
   if (In_4Kdisplay) { width=WIDTH_SIGNAL_4K; }
   x += (width + ColumnInterval)*7;
   ColName = "MACD_APTF1";
   paramHeader = getAppliedPriceStr(In_MACD_Applied_Price_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_APTF2";
   paramHeader = getAppliedPriceStr(In_MACD_Applied_Price_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_APTF3";
   paramHeader = getAppliedPriceStr(In_MACD_Applied_Price_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_APTF4";
   paramHeader = getAppliedPriceStr(In_MACD_Applied_Price_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_APTF5";
   paramHeader = getAppliedPriceStr(In_MACD_Applied_Price_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_APTF6";
   paramHeader = getAppliedPriceStr(In_MACD_Applied_Price_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "MACD_APTF7";
   paramHeader = getAppliedPriceStr(In_MACD_Applied_Price_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /*******************************MACD parameter row4 end  *******************************************************************/
   /******************************* RSI parameter row4 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "RSI_SAPTF1";
   paramHeader = getAppliedPriceStr(In_long_term_RSI_applied_price_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SAPTF2";
   paramHeader = getAppliedPriceStr(In_long_term_RSI_applied_price_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SAPTF3";
   paramHeader = getAppliedPriceStr(In_long_term_RSI_applied_price_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SAPTF4";
   paramHeader = getAppliedPriceStr(In_long_term_RSI_applied_price_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SAPTF5";
   paramHeader = getAppliedPriceStr(In_long_term_RSI_applied_price_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SAPTF6";
   paramHeader = getAppliedPriceStr(In_long_term_RSI_applied_price_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "RSI_SAPTF7";
   paramHeader = getAppliedPriceStr(In_long_term_RSI_applied_price_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* RSI parameter row4 end  *******************************************************************/
   /******************************* KDJ parameter row4 start*******************************************************************/
   height=HEIGHT_ROW_HEADER;
   if (In_4Kdisplay) height=HEIGHT_ROW_HEADER_4K;
   x += width + ColumnInterval;
   ColName = "KDJ_MTF1";
   paramHeader = getMaMethodStr(In_KDJ_method_TF1);
   paramHeader += IntegerToString(In_KDJ_price_field_TF1);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_MTF2";
   paramHeader = getMaMethodStr(In_KDJ_method_TF2);
   paramHeader += IntegerToString(In_KDJ_price_field_TF2);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_MTF3";
   paramHeader = getMaMethodStr(In_KDJ_method_TF3);
   paramHeader += IntegerToString(In_KDJ_price_field_TF3);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_MTF4";
   paramHeader = getMaMethodStr(In_KDJ_method_TF4);
   paramHeader += IntegerToString(In_KDJ_price_field_TF4);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_MTF5";
   paramHeader = getMaMethodStr(In_KDJ_method_TF5);
   paramHeader += IntegerToString(In_KDJ_price_field_TF5);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_MTF6";
   paramHeader = getMaMethodStr(In_KDJ_method_TF6);
   paramHeader += IntegerToString(In_KDJ_price_field_TF6);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   
   x += width + ColumnInterval;
   ColName = "KDJ_MTF7";
   paramHeader = getMaMethodStr(In_KDJ_method_TF7);
   paramHeader += IntegerToString(In_KDJ_price_field_TF7);
   CreateButton(ObjNamePrefix+ColName,paramHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderParam);
   /******************************* KDJ parameter row4 end  *******************************************************************/
   // row4 end
   y += height + RowInterval;
   height=HEIGHT_ROW;
   if (In_4Kdisplay) { height=HEIGHT_ROW_4K; }
   // header timeframe row start
   int FontSizeHeaderTF = 6;
   x = startXi;
   width = WIDTH_MV;
   if (In_4Kdisplay) { width=WIDTH_MV_4K; }
   ColName = "Auto";
   xAdjust = 0;
   CreateButton(ObjNamePrefix+ColName,"M",x,y,width,height,ClrColBgBtn,ClrColFtBtn);
   
   x += width + ColumnInterval;
   width = WIDTH_NEW_ORDER;
   if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
   ColName = "NewL";
   xAdjust = 0;
   CreateButton(ObjNamePrefix+ColName, "L",x,y,width,height,ClrColBgBtn,ClrColFtBtn);
   
   x += width + ColumnInterval;
   width = WIDTH_SYMBOL;
   if (In_4Kdisplay) { width=WIDTH_SYMBOL_4K; }
   ColName = "SymbolName";
   xAdjust = 0;
   CreateButton(ObjNamePrefix+ColName,"Symbol",x,y,width,height,ClrColBgBtn,ClrColFtBtn);
   
   x += width + ColumnInterval;
   width = WIDTH_NEW_ORDER;
   if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
   ColName = "NewS";
   xAdjust = 0;
   CreateButton(ObjNamePrefix+ColName, "S",x,y,width,height,ClrColBgBtn,ClrColFtBtn);
   
   x += width + ColumnInterval;
   width = WIDTH_SIGNAL;
   if (In_4Kdisplay) { width=WIDTH_SIGNAL_4K; }
   ColName = "MA_TF";
   xAdjust = 0;
   string tfHeader = "";
   string btnName = "";
   for (int i=0; i<TIMEFRAME_COUNT; i++) {
      tfHeader = getTimeframeStr(tfs[i]);
      btnName = ObjNamePrefix+ColName+IntegerToString(i);
      CreateButton(btnName,tfHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderTF);
      if (gvUseTfs[0][i]) setBtnSelected(btnName); else setBtnUnselected(btnName);
      x += width + ColumnInterval;
   }
   
   ColName = "MACD_TF";
   for (int i=0; i<TIMEFRAME_COUNT; i++) {
      tfHeader = getTimeframeStr(tfs[i]);
      btnName = ObjNamePrefix+ColName+IntegerToString(i);
      CreateButton(btnName,tfHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderTF);
      if (gvUseTfs[1][i]) setBtnSelected(btnName); else setBtnUnselected(btnName);
      x += width + ColumnInterval;
   }
   
   ColName = "RSI_TF";
   for (int i=0; i<TIMEFRAME_COUNT; i++) {
      tfHeader = getTimeframeStr(tfs[i]);
      btnName = ObjNamePrefix+ColName+IntegerToString(i);
      CreateButton(btnName,tfHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderTF);
      if (gvUseTfs[2][i]) setBtnSelected(btnName); else setBtnUnselected(btnName);
      x += width + ColumnInterval;
   }
   
   ColName = "KDJ_TF";
   for (int i=0; i<TIMEFRAME_COUNT; i++) {
      tfHeader = getTimeframeStr(tfs[i]);
      btnName = ObjNamePrefix+ColName+IntegerToString(i);
      CreateButton(btnName,tfHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderTF);
      if (gvUseTfs[3][i]) setBtnSelected(btnName); else setBtnUnselected(btnName);
      x += width + ColumnInterval;
   }

   ColName = "ADX_TF";
   for (int i=0; i<TIMEFRAME_COUNT; i++) {
      tfHeader = getTimeframeStr(tfs[i]);
      btnName = ObjNamePrefix+ColName+IntegerToString(i);
      CreateButton(btnName,tfHeader,x,y,width,height,ClrColBgBtn,ClrColFtBtn, FontSizeHeaderTF);
      if (gvUseTfs[4][i]) setBtnSelected(btnName); else setBtnUnselected(btnName);
      x += width + ColumnInterval;
   }

   // header timeframe row end
   y += height + RowInterval;
   
   // data rows
   int rowCnt = symbolList.Total();
   for (int i=0; i<rowCnt; i++) {
      SymbolInfo *si = symbolList.GetNodeAtIndex(i);

      x = startXi;
      width = WIDTH_MV;
      if (In_4Kdisplay) { width=WIDTH_MV_4K; }
      ColName = "MV";
      xAdjust = 0;
      CreateButton(ObjNamePrefix+ColName+si.getName(),"~",x,y,width,height,ClrColBgBtn,ClrColFtBtn);
      x += width + ColumnInterval;
      
      width = WIDTH_NEW_ORDER;
      if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
      ColName = "NewL";
      xAdjust = 0;
      CreateButton(ObjNamePrefix+ColName+si.getName(), "L",x,y,width,height,ClrColBgBtn,ClrColFtBtn);
      x += width + ColumnInterval;
      
      width = WIDTH_SYMBOL;
      if (In_4Kdisplay) { width=WIDTH_SYMBOL_4K; }
      ColName = "Symbol";
      xAdjust = 0;
      CreateButton(ObjNamePrefix+ColName+si.getName(), si.getName(),x,y,width,height,ClrColBgBtn,ClrColFtBtn);
      x += width + ColumnInterval;
      
      width = WIDTH_NEW_ORDER;
      if (In_4Kdisplay) { width=WIDTH_NEW_ORDER_4K; }
      ColName = "NewS";
      xAdjust = 0;
      CreateButton(ObjNamePrefix+ColName+si.getName(), "S",x,y,width,height,ClrColBgBtn,ClrColFtBtn);
      x += width + ColumnInterval;

      width = WIDTH_SIGNAL;
      if (In_4Kdisplay) { width=WIDTH_SIGNAL_4K; }
      xAdjust = 2;
      int cnt = si.getIndicatorCount();
      for (int j=0; j<cnt; j++) {
         CIndicatorCustom *ic = si.getIndicatorAtIndex(j);
         ColName = ic.getName() + getTimeframeStr(ic.getTimeframe());
         CreatePanel(ObjNamePrefix+panelNamePrefix+ColName+si.getName(),x,y,width,height,ClrColBgLbl_N,ClrColBdLbl_N,Border_Width);
 
         SetText(ObjNamePrefix+ColName+si.getName(),"",x+xAdjust,y+RowInterval+Border_Width*4,FONT_SIZE_SIGN,ClrColFtLbl_N);
         sign_settings signSettings={0,0,0,"","",clrNONE,clrNONE,clrNONE};
         getCrossSignSet(ic, signSettings);
         resetSign(ColName, si.getName(), signSettings);
         
         x += width + ColumnInterval;

      }
      
      y += height + RowInterval;
   }

}

void resetSign(const string colName, const string pairName, const sign_settings &signSettings) {
   string objNamePanel = ObjNamePrefix+panelNamePrefix+colName+pairName;
   string objNameText = ObjNamePrefix+colName+pairName;
   long x = ObjectGetInteger(0, objNamePanel, OBJPROP_XDISTANCE);
   long y = ObjectGetInteger(0, objNamePanel, OBJPROP_YDISTANCE);
   ObjectSetInteger(0,objNamePanel,OBJPROP_BGCOLOR,signSettings.bgColor);
   ObjectSetInteger(0,objNamePanel,OBJPROP_COLOR,signSettings.bdColor);
   //if (result) Print("success"); else Print(objNamePanel,"  ", ErrorDescription(GetLastError()));
   ObjectSetInteger(0,objNameText,OBJPROP_COLOR,signSettings.fontColor);
   ObjectSetInteger(0,objNameText,OBJPROP_XDISTANCE,x+signSettings.xAdjust);
   ObjectSetInteger(0,objNameText,OBJPROP_YDISTANCE,y+signSettings.yAdjust);
   ObjectSetInteger(0,objNameText,OBJPROP_FONTSIZE,signSettings.fontSize);
   ObjectSetString(0,objNameText,OBJPROP_FONT,signSettings.fontName);
   ObjectSetString(0,objNameText,OBJPROP_TEXT,signSettings.sign);
}

void getCrossSignSet(const CIndicatorCustom *ic, sign_settings &signSettings) {
   ENUM_CROSS cross = ic.GetCross(BAR_INDEX);
   //Print("Cross ===========" + EnumToString(cross));
   switch (cross) {
      case CROSS_MA_LONG:                             {signSettings.sign="●";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_MA_SHORT:                            {signSettings.sign="○";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_MACD_BELOW0_LONG:                    {signSettings.sign=CharToStr(88);   signSettings.fontName="Wingdings";           break;} //
      case CROSS_MACD_OVER0_LONG:                     {signSettings.sign=CharToStr(124);  signSettings.fontName="Wingdings";           break;} //
      case CROSS_MACD_BELOW0_SHORT:                   {signSettings.sign=CharToStr(123);  signSettings.fontName="Wingdings";           break;} //
      case CROSS_MACD_OVER0_SHORT:                    {signSettings.sign=CharToStr(84);   signSettings.fontName="Wingdings";           break;} //
      case CROSS_MACD_0AXIS_BOTTOM2TOP_MAIN:          {signSettings.sign=CharToStr(117);  signSettings.fontName="Wingdings 2";         break;} //❶
      case CROSS_MACD_0AXIS_BOTTOM2TOP_SIGNAL:        {signSettings.sign=CharToStr(118);  signSettings.fontName="Wingdings 2";         break;} //❷
      case CROSS_MACD_0AXIS_TOP2BOTTOM_MAIN:          {signSettings.sign="①";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_MACD_0AXIS_TOP2BOTTOM_SIGNAL:        {signSettings.sign="②";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_ADX_LONG:                            {signSettings.sign="●";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_ADX_SHORT:                           {signSettings.sign="○";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_ADX_DIPLUS_BOTTOM2TOP:               {signSettings.sign=CharToStr(32);   signSettings.fontName="Wingdings";           break;}
      case CROSS_ADX_DIPLUS_TOP2BOTTOM:               {signSettings.sign=CharToStr(32);   signSettings.fontName="Wingdings";           break;}
      case CROSS_ADX_DIMINUS_BOTTOM2TOP:              {signSettings.sign=CharToStr(32);   signSettings.fontName="Wingdings";           break;}
      case CROSS_ADX_DIMINUS_TOP2BOTTOM:              {signSettings.sign=CharToStr(32);   signSettings.fontName="Wingdings";           break;}
      case CROSS_RSI_LONG:                            {signSettings.sign="●";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_RSI_SHORT:                           {signSettings.sign="○";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_KDJ_LONG:                            {signSettings.sign="●";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_KDJ_SHORT:                           {signSettings.sign="○";             signSettings.fontName="Lucida Sans Unicode"; break;}
      case CROSS_KDJ_BELOW_0:                         {signSettings.sign=CharToStr(112);  signSettings.fontName="Wingdings 3";         break;} //
      case CROSS_KDJ_OVER_100:                        {signSettings.sign=CharToStr(113);  signSettings.fontName="Wingdings 3";         break;} //
      case CROSS_KDJ_OVERBOUGHT:                      {signSettings.sign=CharToStr(90);   signSettings.fontName="Wingdings";           break;} //☪
      case CROSS_KDJ_OVERSOLD:                        {signSettings.sign=CharToStr(82);   signSettings.fontName="Wingdings";           break;} //☼
      default:                                        {signSettings.sign=CharToStr(32);   signSettings.fontName="Wingdings";           break;}
   }
   
   if (In_4Kdisplay) {
      switch (cross) {
         case CROSS_MA_LONG:                             {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_MA_SHORT:                            {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_MACD_BELOW0_LONG:                    {signSettings.xAdjust=12;signSettings.yAdjust=-9 ;signSettings.fontSize=16;break;}
         case CROSS_MACD_OVER0_LONG:                     {signSettings.xAdjust=14;signSettings.yAdjust=0  ;signSettings.fontSize=11;break;}
         case CROSS_MACD_BELOW0_SHORT:                   {signSettings.xAdjust=14;signSettings.yAdjust=-1 ;signSettings.fontSize=11;break;}
         case CROSS_MACD_OVER0_SHORT:                    {signSettings.xAdjust=14;signSettings.yAdjust=-1 ;signSettings.fontSize=11;break;}
         case CROSS_MACD_0AXIS_BOTTOM2TOP_MAIN:          {signSettings.xAdjust=10;signSettings.yAdjust=-2 ;signSettings.fontSize=13;break;}
         case CROSS_MACD_0AXIS_BOTTOM2TOP_SIGNAL:        {signSettings.xAdjust=10;signSettings.yAdjust=-2 ;signSettings.fontSize=13;break;}
         case CROSS_MACD_0AXIS_TOP2BOTTOM_MAIN:          {signSettings.xAdjust=10;signSettings.yAdjust=-12;signSettings.fontSize=14;break;}
         case CROSS_MACD_0AXIS_TOP2BOTTOM_SIGNAL:        {signSettings.xAdjust=10;signSettings.yAdjust=-12;signSettings.fontSize=14;break;}
         case CROSS_ADX_LONG:                            {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_ADX_SHORT:                           {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_ADX_DIPLUS_BOTTOM2TOP:               {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_ADX_DIPLUS_TOP2BOTTOM:               {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_ADX_DIMINUS_BOTTOM2TOP:              {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_ADX_DIMINUS_TOP2BOTTOM:              {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_RSI_LONG:                            {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_RSI_SHORT:                           {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_KDJ_LONG:                            {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_KDJ_SHORT:                           {signSettings.xAdjust=14;signSettings.yAdjust=-10;signSettings.fontSize=12;break;}
         case CROSS_KDJ_BELOW_0:                         {signSettings.xAdjust=14;signSettings.yAdjust=0  ;signSettings.fontSize=10;break;}
         case CROSS_KDJ_OVER_100:                        {signSettings.xAdjust=14;signSettings.yAdjust=0  ;signSettings.fontSize=10;break;}
         case CROSS_KDJ_OVERBOUGHT:                      {signSettings.xAdjust=14;signSettings.yAdjust=-4 ;signSettings.fontSize=12;break;}
         case CROSS_KDJ_OVERSOLD:                        {signSettings.xAdjust=13;signSettings.yAdjust=-4 ;signSettings.fontSize=12;break;}
         default:                                        {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=8 ;break;}
      }
   } else {
      switch (cross) {
         case CROSS_MA_LONG:                             {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_MA_SHORT:                            {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_MACD_BELOW0_LONG:                    {signSettings.xAdjust=10;signSettings.yAdjust=-5 ;signSettings.fontSize=14;break;}
         case CROSS_MACD_OVER0_LONG:                     {signSettings.xAdjust=10;signSettings.yAdjust=-2 ;signSettings.fontSize=12;break;}
         case CROSS_MACD_BELOW0_SHORT:                   {signSettings.xAdjust=10;signSettings.yAdjust=-3 ;signSettings.fontSize=11;break;}
         case CROSS_MACD_OVER0_SHORT:                    {signSettings.xAdjust=11;signSettings.yAdjust=-3 ;signSettings.fontSize=11;break;}
         case CROSS_MACD_0AXIS_BOTTOM2TOP_MAIN:          {signSettings.xAdjust=10;signSettings.yAdjust=-1 ;signSettings.fontSize=11;break;}
         case CROSS_MACD_0AXIS_BOTTOM2TOP_SIGNAL:        {signSettings.xAdjust=10;signSettings.yAdjust=-1 ;signSettings.fontSize=11;break;}
         case CROSS_MACD_0AXIS_TOP2BOTTOM_MAIN:          {signSettings.xAdjust=11;signSettings.yAdjust=-11;signSettings.fontSize=13;break;}
         case CROSS_MACD_0AXIS_TOP2BOTTOM_SIGNAL:        {signSettings.xAdjust=11;signSettings.yAdjust=-11;signSettings.fontSize=13;break;}
         case CROSS_ADX_LONG:                            {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_ADX_SHORT:                           {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_ADX_DIPLUS_BOTTOM2TOP:               {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_ADX_DIPLUS_TOP2BOTTOM:               {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_ADX_DIMINUS_BOTTOM2TOP:              {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_ADX_DIMINUS_TOP2BOTTOM:              {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=7 ;break;}
         case CROSS_RSI_LONG:                            {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_RSI_SHORT:                           {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_KDJ_LONG:                            {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_KDJ_SHORT:                           {signSettings.xAdjust=11;signSettings.yAdjust=-6 ;signSettings.fontSize=11;break;}
         case CROSS_KDJ_BELOW_0:                         {signSettings.xAdjust=12;signSettings.yAdjust=1  ;signSettings.fontSize=8 ;break;}
         case CROSS_KDJ_OVER_100:                        {signSettings.xAdjust=12;signSettings.yAdjust=2  ;signSettings.fontSize=8 ;break;}
         case CROSS_KDJ_OVERBOUGHT:                      {signSettings.xAdjust=12;signSettings.yAdjust=0  ;signSettings.fontSize=9 ;break;}
         case CROSS_KDJ_OVERSOLD:                        {signSettings.xAdjust=10;signSettings.yAdjust=-3 ;signSettings.fontSize=11;break;}
         default:                                        {signSettings.xAdjust=0 ;signSettings.yAdjust=0  ;signSettings.fontSize=8 ;break;}
      }
   }
   
   ENUM_TREND trend = ic.GetTrend(BAR_INDEX);
   switch (trend) {
      case TREND_LONG_STRONG: signSettings.bgColor=ClrBgTrend_L_P;signSettings.bdColor=ClrBdTrend_L_P;signSettings.fontColor=ClrFtTrend_L_P; break;
      case TREND_LONG:        signSettings.bgColor=ClrBgTrend_L;  signSettings.bdColor=ClrBdTrend_L;  signSettings.fontColor=ClrFtTrend_L;   break;
      case TREND_LONG_WEAK:   signSettings.bgColor=ClrBgTrend_L_M;signSettings.bdColor=ClrBdTrend_L_M;signSettings.fontColor=ClrFtTrend_L_M; break;
      case TREND_SHORT_STRONG:signSettings.bgColor=ClrBgTrend_S_P;signSettings.bdColor=ClrBdTrend_S_P;signSettings.fontColor=ClrFtTrend_S_P; break;
      case TREND_SHORT:       signSettings.bgColor=ClrBgTrend_S;  signSettings.bdColor=ClrBdTrend_S;  signSettings.fontColor=ClrFtTrend_S;   break;
      case TREND_SHORT_WEAK:  signSettings.bgColor=ClrBgTrend_S_M;signSettings.bdColor=ClrBdTrend_S_M;signSettings.fontColor=ClrFtTrend_S_M; break;
      default:                signSettings.bgColor=ClrColBgLbl_N; signSettings.bdColor=ClrColBdLbl_N; signSettings.fontColor=ClrColFtLbl_N;  break;
   }
   if (ic.isEnable()) signSettings.bdColor=COLOR_BD_USED; else signSettings.bdColor=COLOR_BD_UNUSE;
}

const color ClrBtnBgSelected     = clrGreenYellow;
const color ClrBtnFtSelected     = clrBlack;
const color ClrBtnBgUnselected   = clrGray;
const color ClrBtnFtUnselected   = clrWhiteSmoke;
void setBtnSelected(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,  ClrBtnBgSelected);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,    ClrBtnFtSelected);
}

void setBtnUnselected(string btnName) {
   ObjectSetInteger(0,btnName,OBJPROP_BGCOLOR,  ClrBtnBgUnselected);
   ObjectSetInteger(0,btnName,OBJPROP_COLOR,    ClrBtnFtUnselected);
}

/**
 * link:   https://en.wikipedia.org/wiki/List_of_typefaces_included_with_Microsoft_Windows
 * monospace fonts:
 *   Courier New
 *   Lucida Sans Typewriter
 *   Cascadia Code
 *   Consolas
 *   Lucida Console
 *   Fixedsys
 */
/*
void SetUnicodeText(const string name, const ushort unicode, const int x, const int y, const int fontsize=12, const color colour=clrBlack, const string fontName="Microsoft JhengHei", const double angle=0.0, const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,name,OBJPROP_CORNER,corner);
   ObjectSetString(chartId,name,OBJPROP_FONT,fontName);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,colour);
   ObjectSetDouble(chartId,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chartId,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chartId,name,OBJPROP_BACK,false);
   ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartId,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chartId,name,OBJPROP_HIDDEN,true);
   ObjectSetString(chartId,name,OBJPROP_TEXT, ShortToString(unicode));
}
*/
void SetText(const string name, const string text, const int x, const int y, const int fontsize=12, const color colour=clrBlack, const string fontName="Lucida Sans Typewriter", const double angle=0.0, const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) {
   long chartId = 0;
   if(ObjectFind(chartId,name)<0)
      ObjectCreate(chartId,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,name,OBJPROP_CORNER,corner);
   ObjectSetString(chartId,name,OBJPROP_FONT,fontName);
   ObjectSetInteger(chartId,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(chartId,name,OBJPROP_COLOR,colour);
   ObjectSetDouble(chartId,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chartId,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chartId,name,OBJPROP_BACK,false);
   ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chartId,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chartId,name,OBJPROP_HIDDEN,true);
   ObjectSetString(chartId,name,OBJPROP_TEXT, text);
}

void CreatePanel(string name,int x,int y,int width,int height,color backgroundColor=clrBlack,color borderColor=clrWhite,int borderWidth=1)
  {
   long chartId = 0;
   if(0 < ObjectFind(chartId,name)) ObjectDelete(chartId, name);
   if(ObjectCreate(chartId,name,OBJ_RECTANGLE_LABEL,0,0,0))
     {
      ObjectSetInteger(chartId,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chartId,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(chartId,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chartId,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(chartId,name,OBJPROP_COLOR,borderColor);
      ObjectSetInteger(chartId,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(chartId,name,OBJPROP_WIDTH,borderWidth);
      ObjectSetInteger(chartId,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(chartId,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(chartId,name,OBJPROP_BACK,false);
      ObjectSetInteger(chartId,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(chartId,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(chartId,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(chartId,name,OBJPROP_ZORDER,0);
      ObjectSetInteger(chartId,name,OBJPROP_BGCOLOR,backgroundColor);
     }
  }

/*
   font : "Times New Roman"  "Microsoft Sans Serif"  "Cambria"  "Georgia"  "Impact"   "Tahoma"
*/
void CreateButton(string btnName,string text,int x,int y,int width,int height,int backgroundColor=clrBlack
                  ,int textColor=clrWhite, int fontSize = 7, string font="Tahoma", ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) {
   ResetLastError();
   long chartId = 0;
   if(ObjectFind(chartId,btnName)<0) {
      if(!ObjectCreate(chartId,btnName,OBJ_BUTTON,0,0,0)) {
         Print(__FUNCTION__, ": failed to create the button! Error code = ",ErrorDescription(GetLastError()));
         return;
      }
   }
   ObjectSetString(chartId,btnName,OBJPROP_TEXT,text);
   ObjectSetInteger(chartId,btnName,OBJPROP_XSIZE,width);
   ObjectSetInteger(chartId,btnName,OBJPROP_YSIZE,height);
   ObjectSetInteger(chartId,btnName,OBJPROP_CORNER,corner);
   ObjectSetInteger(chartId,btnName,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartId,btnName,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chartId,btnName,OBJPROP_BGCOLOR,backgroundColor);
   ObjectSetInteger(chartId,btnName,OBJPROP_COLOR,textColor);
   ObjectSetInteger(chartId,btnName,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(chartId,btnName,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chartId,btnName,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetString(chartId,btnName,OBJPROP_FONT,font);
}


void CreateEdit(const string           name="Edit",              // object name
                const int              x=0,                      // X coordinate
                const int              y=0,                      // Y coordinate
                const int              width=50,                 // width
                const int              height=18,                // height
                const int              font_size=10,             // font size
                const string           text="Text",              // text
                const string           font="Fixedsys",          // font
                const ENUM_ALIGN_MODE  align=ALIGN_CENTER,       // alignment type
                const bool             read_only=false,          // ability to edit
                const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr=clrBlack,             // text color
                const color            back_clr=clrWhite,        // background color
                const color            border_clr=clrNONE)       // border color
{
//--- reset the error value
   ResetLastError();
   long chart_ID=0;
   int sub_window=0;
   if(ObjectFind(chart_ID, name)<0) {
//--- create edit field
      if(!ObjectCreate(chart_ID,name,OBJ_EDIT,sub_window,0,0)) {
         Print(__FUNCTION__, ": failed to create \"Edit\" object! Error code = ", ErrorDescription(GetLastError()));
         return;
      }
   }
//--- set object coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set object size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the type of text alignment in the object
   ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,align);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(chart_ID,name,OBJPROP_READONLY,read_only);
//--- set the chart's corner, relative to which object coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK, false);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED, false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN, true);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER, 0);
}



//+------------------------------------------------------------------+
//|                                                PreciseSwings.mq4 |
//|                                                                  |
//| 红色箭头 - 弱势摆动高点                                               |
//|    条件：识别为摆动高点，但实体大小不够显著                                  |
//|    strength = "weak"                                             |
//|    表示可能的波峰，需要进一步确认                                        |
//|                                                                  |
//| 蓝色箭头 - 弱势摆动低点                                               |
//|    条件：识别为摆动低点，但实体大小不够显著                                  |
//|    strength = "weak"                                             |
//|    表示可能的波谷，需要进一步确认                                        |
//|                                                                  |
//| 绿色箭头 - 确认的摆动点                                               |
//|    条件：识别为摆动点，且实体大小显著                                      |
//|    strength = "confirmed"                                        |
//|    currentBody > avgBody * minBodyRatio                          |
//|    表示高可信度的波峰或波谷                                            |
//+------------------------------------------------------------------+

/*
交易意义
🟢 绿色箭头（确认的）
  可信度高：实体足够大，表明动能强劲
  适合作为：支撑阻力位、入场点、止损位
  交易价值：高

🔴🔵 红蓝箭头（弱势的）
  需要确认：可能只是小幅回调或噪音
  适合作为：观察点，需要其他指标确认
  交易价值：中等偏低

使用建议
   重点关注绿色箭头 - 作为主要交易依据
   结合红蓝箭头 - 识别潜在的反转区域
   多时间框架验证 - 绿色箭头在多个时间框架出现时更可靠
   配合其他指标 - 用成交量、MACD等进一步确认
简单说：绿色箭头是"主力部队"，红蓝箭头是"侦察兵" 🎯
*/

#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

// 输入参数
input int    LookbackPeriod = 3;
input double MinDeviation = 0.0005;
input int    ZigZagDepth = 12;
input bool   ShowMultiTimeframe = true;
input color  ColorHigh = clrRed;
input color  ColorLow = clrBlue;
input color  ColorConfirmed = clrAqua;

// 缓冲区
double HighSwingBuffer[];
double LowSwingBuffer[];
double ConfirmedHighBuffer[];
double ConfirmedLowBuffer[];

// 只计算最近3000根K线
const int calc_limit = 500;

//+------------------------------------------------------------------+
//| 自定义指标初始化函数                                              |
//+------------------------------------------------------------------+
int OnInit() {
   SetIndexBuffer(0, HighSwingBuffer);
   SetIndexBuffer(1, LowSwingBuffer);
   SetIndexBuffer(2, ConfirmedHighBuffer);
   SetIndexBuffer(3, ConfirmedLowBuffer);
   
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 2, ColorHigh);
   SetIndexArrow(0, 234); // 向下箭头
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 2, ColorLow);
   SetIndexArrow(1, 233); // 向上箭头
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 3, ColorConfirmed);
   SetIndexArrow(2, 234);
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 3, ColorConfirmed);
   SetIndexArrow(3, 233);
   
   ArraySetAsSeries(HighSwingBuffer, true);
   ArraySetAsSeries(LowSwingBuffer, true);
   ArraySetAsSeries(ConfirmedHighBuffer, true);
   ArraySetAsSeries(ConfirmedLowBuffer, true);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 自定义指标迭代函数                                                |
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
   
   if(rates_total < LookbackPeriod * 2 + 10) return 0;
   
   // 设置数组为时间序列
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);
   
   // 初始化缓冲区
   int start = MathMax(prev_calculated - 1, LookbackPeriod);
   // 限制最大处理范围为最近3000根
   int end = MathMin(rates_total, calc_limit);
   for(int i = start; i < end; i++) {
      HighSwingBuffer[i] = EMPTY_VALUE;
      LowSwingBuffer[i] = EMPTY_VALUE;
      ConfirmedHighBuffer[i] = EMPTY_VALUE;
      ConfirmedLowBuffer[i] = EMPTY_VALUE;
   }
   
   // 1. 使用精确方法找摆动点
   FindPreciseSwings(high, low, close, LookbackPeriod, 0.6, start, end);
   
   // 2. 使用ZigZag方法
   FindZigZagSwings(close, ZigZagDepth, MinDeviation, 3, start, end);
   
   // 3. 多时间框架验证
   if(ShowMultiTimeframe) {
      FindMultiTimeframeSwings(Symbol(), Period(), 200);
   }
   
   // 绘制摆动点
   DrawSwingPoints();
   
   return(rates_total);
}

void DrawSwingPoints() {
   // 绘制精确方法找到的摆动点
   for(int i = 0; i < swingsCount; i++) {
      int barIndex = preciseSwingPoints[i].barIndex;
      if(preciseSwingPoints[i].isHigh) {
         if(preciseSwingPoints[i].strength == "confirmed") {
            ConfirmedHighBuffer[barIndex] = preciseSwingPoints[i].price;
         } else {
            HighSwingBuffer[barIndex] = preciseSwingPoints[i].price;
         }
      } else {
         if(preciseSwingPoints[i].strength == "confirmed") {
            ConfirmedLowBuffer[barIndex] = preciseSwingPoints[i].price;
         } else {
            LowSwingBuffer[barIndex] = preciseSwingPoints[i].price;
         }
      }
   }
   
   // 在图表上显示信息
   Comment(StringFormat("精确摆动点: %d, ZigZag摆动点: %d, 多时间框架: %d", swingsCount, zigzagCount, mtfCount));
}



/*********1. 多条件联合判定法*****************/
// 摆动点结构体
struct SwingPoint {
   int barIndex;
   double price;
   bool isHigh;
   string strength; // "confirmed", "weak"
   datetime time;
};

// 精准摆动点识别
SwingPoint preciseSwingPoints[];
int swingsCount = 0;

void FindPreciseSwings(const double &high[], const double &low[], const double &close[], int lookback = 3, double minBodyRatio = 0.6, int begin=0, int end=0) {
   swingsCount = 0;
   ArrayResize(preciseSwingPoints, 1000); // 预分配空间
   
   // for(int i = lookback; i < ArraySize(high) - lookback; i++) {
   for(int i = begin; i <= end; i++) {
      bool isHighPeak = true;
      bool isLowValley = true;
      
      // 基础摆动点条件
      for(int j = 1; j <= lookback; j++) {
         if(high[i] <= high[i-j] || high[i] <= high[i+j]) isHighPeak = false;
         if(low[i] >= low[i-j] || low[i] >= low[i+j]) isLowValley = false;
      }
      
      // 动态扩展数组
      if(swingsCount >= ArraySize(preciseSwingPoints)) {
         int newSize = ArraySize(preciseSwingPoints) + 50;
         ArrayResize(preciseSwingPoints, newSize);
      }
      // 实体大小确认
      double currentBody = MathAbs(close[i] - (high[i] + low[i]) / 2.0);
      double avgBody = CalculateAverageBody(i, close, high, low, 5);
      bool hasSignificantBody = currentBody > avgBody * minBodyRatio;
      
      // 记录摆动点
      if(isHighPeak) {
         preciseSwingPoints[swingsCount].barIndex = i;
         preciseSwingPoints[swingsCount].price = high[i];
         preciseSwingPoints[swingsCount].isHigh = true;
         preciseSwingPoints[swingsCount].strength = hasSignificantBody ? "confirmed" : "weak";
         preciseSwingPoints[swingsCount].time = Time[i];
         swingsCount++;
      }
      else if(isLowValley) {
         preciseSwingPoints[swingsCount].barIndex = i;
         preciseSwingPoints[swingsCount].price = low[i];
         preciseSwingPoints[swingsCount].isHigh = false;
         preciseSwingPoints[swingsCount].strength = hasSignificantBody ? "confirmed" : "weak";
         preciseSwingPoints[swingsCount].time = Time[i];
         swingsCount++;
      }
   }
   
   ArrayResize(preciseSwingPoints, swingsCount);
}

double CalculateAverageBody(int currentIndex, const double &close[], const double &high[], const double &low[], int period) {
   double sum = 0;
   int count = 0;
   for(int k = MathMax(0, currentIndex - period); k < currentIndex; k++) {
      double body = MathAbs(close[k] - (high[k] + low[k]) / 2.0);
      sum += body;
      count++;
   }
   return count > 0 ? sum / count : 0;
}


/*****************2. 改进的ZigZag算法**********************/
// ZigZag摆动点检测
SwingPoint zigzagSwings[];
int zigzagCount = 0;

void FindZigZagSwings(const double &price[], int depth = 12, double deviation = 0.0005, int backstep = 3, int begin=0, int end=0) {
   zigzagCount = 0;
   ArrayResize(zigzagSwings, 1000);
   
   if(ArraySize(price) < depth * 2) return;
   
   double lastPivot = price[0];
   int lastPivotIndex = 0;
   int trend = 0; // 0: initial, 1: uptrend, -1: downtrend
   
   // for(int i = depth; i < ArraySize(price) - depth; i++) {
   // for(int i = begin; i <= end; i++) {
   for(int i = MathMax(depth, begin); i <= end; i++) {
      bool isHigh = true;
      bool isLow = true;
      
      // 检查深度范围内的点
      for(int j = 1; j <= depth; j++) {
         if(price[i] <= price[i-j] || price[i] <= price[i+j]) isHigh = false;
         if(price[i] >= price[i-j] || price[i] >= price[i+j]) isLow = false;
      }
      
      // 动态扩展数组
      if(zigzagCount >= ArraySize(zigzagSwings)) {
         int newSize = ArraySize(zigzagSwings) + 50;
         ArrayResize(zigzagSwings, newSize);
      }
      
      // 偏差过滤
      if(isHigh) {
         double deviationPct = (price[i] - lastPivot) / lastPivot * 100;
         if(deviationPct >= deviation && (i - lastPivotIndex) >= backstep) {
            zigzagSwings[zigzagCount].barIndex = i;
            zigzagSwings[zigzagCount].price = price[i];
            zigzagSwings[zigzagCount].isHigh = true;
            zigzagSwings[zigzagCount].time = Time[i];
            zigzagCount++;
            
            lastPivot = price[i];
            lastPivotIndex = i;
            trend = -1;
         }
      }
      else if(isLow) {
         double deviationPct = (lastPivot - price[i]) / lastPivot * 100;
         if(deviationPct >= deviation && (i - lastPivotIndex) >= backstep) {
            zigzagSwings[zigzagCount].barIndex = i;
            zigzagSwings[zigzagCount].price = price[i];
            zigzagSwings[zigzagCount].isHigh = false;
            zigzagSwings[zigzagCount].time = Time[i];
            zigzagCount++;
            
            lastPivot = price[i];
            lastPivotIndex = i;
            trend = 1;
         }
      }
   }
   
   ArrayResize(zigzagSwings, zigzagCount);
}

/*********************3. 多时间框架验证************************/
// 多时间框架摆动点
struct MultiTimeframeSwing {
   int barIndex;
   double price;
   bool isHigh;
   string timeframe;
   datetime time;
};

MultiTimeframeSwing mtfSwings[];
int mtfCount = 0;

void FindMultiTimeframeSwings(string symbol, int currentTimeframe, int lookback = 100) {
   mtfCount = 0;
   ArrayResize(mtfSwings, 1000);
   
   // 定义要分析的时间框架数组
   int timeframes[4] = {PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_H4};
   string tfNames[4] = {"M5", "M15", "H1", "H4"};
   
   for(int t = 0; t < 4; t++) {
      // 获取不同时间框架数据
      double highs[], lows[], closes[];
      datetime times[];
      
      int copied = CopyHigh(symbol, timeframes[t], 0, lookback, highs);
      CopyLow(symbol, timeframes[t], 0, lookback, lows);
      CopyClose(symbol, timeframes[t], 0, lookback, closes);
      CopyTime(symbol, timeframes[t], 0, lookback, times);
      
      if(copied > 0) {
         // 在当前时间框架找摆动点
         SwingPoint tempSwings[];
         int tempCount = FindSwingsInTimeframe(highs, lows, closes, times, tempSwings);
         
         // 添加到多时间框架数组
         for(int s = 0; s < tempCount; s++) {
            mtfSwings[mtfCount].barIndex = tempSwings[s].barIndex;
            mtfSwings[mtfCount].price = tempSwings[s].price;
            mtfSwings[mtfCount].isHigh = tempSwings[s].isHigh;
            mtfSwings[mtfCount].time = tempSwings[s].time;
            mtfSwings[mtfCount].timeframe = tfNames[t];
            mtfCount++;
         }
      }
   }
   
   ArrayResize(mtfSwings, mtfCount);
}

int FindSwingsInTimeframe(const double &high[], const double &low[], const double &close[], const datetime &time[], SwingPoint &output[]) {
   int count = 0;
   ArrayResize(output, 100);
   
   int lookback = 3;
   for(int i = lookback; i < ArraySize(high) - lookback; i++) {
      bool isHigh = true;
      bool isLow = true;
      
      for(int j = 1; j <= lookback; j++) {
         if(high[i] <= high[i-j] || high[i] <= high[i+j]) isHigh = false;
         if(low[i] >= low[i-j] || low[i] >= low[i+j]) isLow = false;
      }
      
      if(isHigh) {
         output[count].barIndex = i;
         output[count].price = high[i];
         output[count].isHigh = true;
         output[count].time = time[i];
         count++;
      }
      else if(isLow) {
         output[count].barIndex = i;
         output[count].price = low[i];
         output[count].isHigh = false;
         output[count].time = time[i];
         count++;
      }
   }
   
   ArrayResize(output, count);
   return count;
}

// 寻找共识摆动点
void FindConsensusSwings(MultiTimeframeSwing &consensusSwings[]) {
   int consensusCount = 0;
   ArrayResize(consensusSwings, 100);
   
   double tolerance = 0.001; // 0.1%的价格容忍度
   
   for(int i = 0; i < mtfCount; i++) {
      bool foundMatch = false;
      
      for(int j = 0; j < consensusCount; j++) {
         if(MathAbs(mtfSwings[i].price - consensusSwings[j].price) / consensusSwings[j].price <= tolerance) {
            foundMatch = true;
            break;
         }
      }
      
      if(!foundMatch) {
         // 检查这个价格水平在多少个时间框架中出现
         int timeframeCount = CountTimeframeOccurrences(mtfSwings[i].price, tolerance);
         
         if(timeframeCount >= 2) { // 至少2个时间框架确认
            consensusSwings[consensusCount] = mtfSwings[i];
            consensusCount++;
         }
      }
   }
   
   ArrayResize(consensusSwings, consensusCount);
}

int CountTimeframeOccurrences(double price, double tolerance) {
   int count = 0;
   string checkedTimeframes[];
   ArrayResize(checkedTimeframes, 0);
   
   for(int i = 0; i < mtfCount; i++) {
      if(MathAbs(mtfSwings[i].price - price) / price <= tolerance) {
         bool alreadyCounted = false;
         for(int j = 0; j < ArraySize(checkedTimeframes); j++) {
            if(checkedTimeframes[j] == mtfSwings[i].timeframe) {
               alreadyCounted = true;
               break;
            }
         }
         
         if(!alreadyCounted) {
            count++;
            ArrayResize(checkedTimeframes, ArraySize(checkedTimeframes) + 1);
            checkedTimeframes[ArraySize(checkedTimeframes) - 1] = mtfSwings[i].timeframe;
         }
      }
   }
   
   return count;
}
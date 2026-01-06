/*
   1.波浪检测：通过SMA和LWMA的交叉来识别市场的高点和低点
   2.趋势线绘制：自动连接相同类型的波浪点形成支撑线和阻力线
   3.信号旗标记：在检测到的枢轴点位置绘制箭头标记
   4.预测趋势线：基于当前波浪预测未来的趋势方向
   5.警报功能：在检测到新的枢轴点时发出声音和文本警报
   使用多重时间周期分析

*/
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define LOWEST_PERIOD_SMA 2
#define LOWEST_PERIOD_LWMA 5
#define LOWEST_SEMAFOR_OFFSET 3

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 DarkGoldenrod
#property indicator_color3 BlueViolet

input int High_period = 70;
input int Low_period = 21;
//input int Trigger_Sens = 2;
input double Trigger_Multiplier = 1.0;
input string Note0 = "***** Semafor Drawing Adjustment";
input bool DrawHighPivotSemafor = TRUE;
input bool DrawLowPivotSemafor = TRUE;
input bool DrawLowestPivotSemafor = TRUE;

input string Note3 = "***** High Semafor Adjustment";
input bool HighPivotTextAlarm = TRUE;
input string HighPivotSoundAlarm = "alert.wav";
input int HighPivotSemaforDrawOffset = 28;
input int HighSemaforSymbol = 204;
input string Note4 = "***** High Semafor Adjustment";
input bool LowPivotTextAlarm = FALSE;
input string LowPivotSoundAlarm = "";
input int LowPivotSemaforDrawOffset = 18;
input int LowSemaforSymbol = 175;
input string Note5 = "***** Lowest Semafor Adjustment";
input int LowestSemaforSymbol = 181;

// ==================== 波浪信息结构体 ====================
struct SWaveInfo {
    int waveType;           // 波浪类型
    datetime timeFirstZero; // 第一个零点时间
    datetime timeSecondZero;// 第二个零点时间
    double pivotPrice;      // 枢轴点价格
    int pivotBarIndex;      // 枢轴点索引
    datetime pivotTime;     // 枢轴点时间
};

// 波浪信息数组
SWaveInfo arrayWavesInfoBigPeriod[];
SWaveInfo arrayWavesInfoSmallPeriod[];
SWaveInfo arrayWavesInfo25Period[];

// 波浪状态结构体
struct SWaveState {
    datetime timeFirstZero;
    datetime timeSecondZero;
    int waveType;
    bool foundWave;
};
// 各周期的波浪状态
SWaveState stateHigh, stateLow, stateLowest;

// ==================== MA缓存结构体 ====================
struct SMACache {
    double sma[];      // SMA缓存数组
    double lwma[];     // LWMA缓存数组
    double atr[];      // ATR缓存数组
    int lastCalculated; // 最后计算的bar位置
};
// MA缓存对象
SMACache cacheHigh, cacheLow, cacheLowest;

double HighSemaBuffer[];
double LowSemaBuffer[];
double LowestSemaBuffer[];
int periodHigh, periodHigh7, periodLow, periodLow5;
datetime timeBar0 = 0;

const int Period_ATR = 14;

// ==================== 初始化MA缓存 ====================
void InitMACache(SMACache &cache, int size) {
    ArrayResize(cache.sma, size);
    ArrayResize(cache.lwma, size);
    ArrayResize(cache.atr, size);

    // 设置为时间序列模式，自动处理shift
    ArraySetAsSeries(cache.sma, true);
    ArraySetAsSeries(cache.lwma, true);
    ArraySetAsSeries(cache.atr, true);

    ArrayInitialize(cache.sma, 0);
    ArrayInitialize(cache.lwma, 0);
    ArrayInitialize(cache.atr, 0);
    cache.lastCalculated = -1;
}

// ==================== 更新MA缓存 ====================
void UpdateMACache(SMACache &cache, int periodSMA, int periodLWMA, int startBar, int endBar) {
    for (int i = startBar; i >= endBar; i--) {
        cache.sma[i] = iMA(NULL, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, i);
        cache.lwma[i] = iMA(NULL, 0, periodLWMA, 0, MODE_LWMA, PRICE_WEIGHTED, i);
        cache.atr[i] = iATR(NULL, 0, Period_ATR, i);
    }
    cache.lastCalculated = endBar;
}

// ==================== 获取缓存的MA值 ====================
double GetCachedSMA(SMACache &cache, int index) {
    if (index < 0 || index >= ArraySize(cache.sma)) return 0;
    return cache.sma[index];
}

double GetCachedLWMA(SMACache &cache, int index) {
    if (index < 0 || index >= ArraySize(cache.lwma)) return 0;
    return cache.lwma[index];
}

double GetCachedATR(SMACache &cache, int index) {
    if (index < 0 || index >= ArraySize(cache.atr)) return 0;
    return cache.atr[index];
}

int OnInit() {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, HighSemaforSymbol);
   SetIndexBuffer(0, HighSemaBuffer);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, LowSemaforSymbol);
   SetIndexBuffer(1, LowSemaBuffer);
   SetIndexEmptyValue(1, 0.0);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, LowestSemaforSymbol);
   SetIndexBuffer(2, LowestSemaBuffer);
   SetIndexEmptyValue(2, 0.0);
   
   if (High_period == 0 && Low_period == 0) {
      Alert("High_period == 0 && Low_period == 0");
      OnDeinit(0);
      return (INIT_FAILED);
   }
   
   periodHigh = High_period;
   periodHigh7 = MathMax(1, (int)MathRound(High_period / 7.0));
   periodLow = Low_period;
   periodLow5 = MathMax(1, (int)MathRound(Low_period / 5.0));

   // 初始化MA缓存
   int bars = Bars;
   InitMACache(cacheHigh, bars);
   InitMACache(cacheLow, bars);
   InitMACache(cacheLowest, bars);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   ArrayFree(arrayWavesInfoBigPeriod);
   ArrayFree(arrayWavesInfoSmallPeriod);
   ArrayFree(arrayWavesInfo25Period);
   ArrayInitialize(HighSemaBuffer, EMPTY_VALUE);
   ArrayInitialize(LowSemaBuffer, EMPTY_VALUE);
   ArrayInitialize(LowestSemaBuffer, EMPTY_VALUE);

   // 释放缓存
   ArrayFree(cacheHigh.sma);
   ArrayFree(cacheHigh.lwma);
   ArrayFree(cacheHigh.atr);
   ArrayFree(cacheLow.sma);
   ArrayFree(cacheLow.lwma);
   ArrayFree(cacheLow.atr);
   ArrayFree(cacheLowest.sma);
   ArrayFree(cacheLowest.lwma);
   ArrayFree(cacheLowest.atr);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
   // 新K线检测
   if (timeBar0 == time[0]) return(prev_calculated);

   timeBar0 = time[0];

   // 计算需要处理的K线数量
   int limit = rates_total - prev_calculated;
   if (prev_calculated == 0) {
       limit = rates_total - 1;
   }

   // 确保缓存数组大小足够
   if (ArraySize(cacheHigh.sma) < rates_total) {
       ArrayResize(cacheHigh.sma, rates_total);
       ArrayResize(cacheHigh.lwma, rates_total);
       ArrayResize(cacheHigh.atr, rates_total);
   }
   if (ArraySize(cacheLow.sma) < rates_total) {
       ArrayResize(cacheLow.sma, rates_total);
       ArrayResize(cacheLow.lwma, rates_total);
       ArrayResize(cacheLow.atr, rates_total);
   }
   if (ArraySize(cacheLowest.sma) < rates_total) {
       ArrayResize(cacheLowest.sma, rates_total);
       ArrayResize(cacheLowest.lwma, rates_total);
       ArrayResize(cacheLowest.atr, rates_total);
   }

   // 更新MA缓存（只计算新的bar）
   UpdateMACache(cacheHigh, periodHigh7, periodHigh, limit, 0);
   UpdateMACache(cacheLow, periodLow5, periodLow, limit, 0);
   UpdateMACache(cacheLowest, LOWEST_PERIOD_SMA, LOWEST_PERIOD_LWMA, limit, 0);

   // 处理每根K线
   for (int i = limit; i >= 0; i--) {

      // 1 高点波浪管理（大周期检测）
      NewWave_Manager(i, periodHigh7, periodHigh, cacheHigh, arrayWavesInfoBigPeriod, HighSemaBuffer, stateHigh, 
                     DrawHighPivotSemafor, HighPivotSemaforDrawOffset, HighPivotTextAlarm, HighPivotSoundAlarm);

      // 2 低点波浪管理（小周期检测）
      NewWave_Manager(i, periodLow5, periodLow, cacheLow, arrayWavesInfoSmallPeriod, LowSemaBuffer, stateLow, 
                     DrawLowPivotSemafor, LowPivotSemaforDrawOffset, LowPivotTextAlarm, LowPivotSoundAlarm);

      // 3 最低点波浪管理（极值检测）
      NewWave_Manager(i, LOWEST_PERIOD_SMA, LOWEST_PERIOD_LWMA, cacheLowest, arrayWavesInfo25Period, LowestSemaBuffer, stateLowest, 
                     DrawLowestPivotSemafor, LOWEST_SEMAFOR_OFFSET, 0, "");
   }

   // 返回已计算的K线数量
   return(rates_total);
}

/**
 * 新波浪管理器 - 波浪识别和管理的核心函数
 * 该函数负责协调整个波浪识别流程，包括波浪检测、信号绘制、警报触发和趋势线预测
 * 是波浪分析系统的总调度中心
 */
void NewWave_Manager(int indexBar
                  , int periodSMA
                  , int periodLWMA
                  , SMACache &cache
                  , SWaveInfo &arrayAllWavesInfo[]
                  , double &SemaBuffer[]
                  , SWaveState &waveState
                  , bool drawPivotSemafor
                  , int pivotSemaforDrawOffset
                  , bool pivotTextAlarm
                  , string pivotSoundAlarm) {

	// 第一步：检查是否已找到第一个零点（波浪起点）
	// 如果未找到，尝试寻找第一个零点
	if (waveState.timeFirstZero == 0) {
		FindFirstZeroCrossing(periodSMA, periodLWMA, indexBar, cache, waveState);
		waveState.foundWave = false;  // 标记未找到完整波浪
		return;  // 直接返回，等待下一个周期
	}

	// 第二步：检查是否已找到第二个零点（波浪终点）
	// 如果未找到，尝试寻找第二个零点
	if (waveState.timeSecondZero == 0) {
		FindSecondZeroCrossing(periodSMA, periodLWMA, indexBar, cache, waveState);
		// 如果仍未找到第二个零点，标记未找到完整波浪
		if (waveState.timeSecondZero == 0) {
			waveState.foundWave = false;
			return;
		}
	}

	// 第三步：将完整的波浪信息添加到波浪数组
	// 此时已找到波浪的起点和终点
	Add_Wave(waveState, arrayAllWavesInfo);

	// 第四步：标记已找到完整波浪
	waveState.foundWave = true;

	// 第五步：获取波浪总数和最新波浪的枢轴点信息
	int wavesCount = ArraySize(arrayAllWavesInfo);
	int iBarPivot = arrayAllWavesInfo[wavesCount - 1].pivotBarIndex;  // 枢轴点Bar索引
	datetime timePivot = arrayAllWavesInfo[wavesCount - 1].pivotTime;  // 枢轴点时间

	// 第六步：绘制枢轴点信号旗（如果启用）
	if (drawPivotSemafor) {
		int iPivot = iBarPivot;
		int iBar_F_S_Zero = iBarShift(NULL, 0, waveState.timeSecondZero, FALSE);

		// 清空信号旗缓冲区中相关区域
		for (int i = iBar_F_S_Zero - 1; i > iPivot; i++)
			SemaBuffer[i] = EMPTY_VALUE;

		// 设置枢轴点位置的信号旗值
		SemaBuffer[iBarPivot] = arrayAllWavesInfo[wavesCount - 1].pivotPrice;  // 枢轴点价格

		// 根据波浪类型调整信号旗的绘制位置
		if (waveState.waveType == 1) {
			// 波峰信号旗：在价格上方偏移绘制，避免遮挡价格线
			SemaBuffer[iBarPivot] += pivotSemaforDrawOffset * Point;
		} else if (waveState.waveType == 2) {
			// 波谷信号旗：在价格下方偏移绘制，避免遮挡价格线
			SemaBuffer[iBarPivot] = SemaBuffer[iBarPivot] - pivotSemaforDrawOffset * Point;
		}

		// 第七步：触发警报（如果启用且在当前K线附近）
		if (indexBar < 50) {
			if (pivotSoundAlarm != "") {
				PlaySound(pivotSoundAlarm);  // 播放声音警报
			}

			if (pivotTextAlarm) {
				// 显示文本警报
				Alert(PrepareTextAlarm(Time[0], waveState.waveType, arrayAllWavesInfo[wavesCount - 1].pivotPrice, timePivot));
			}
		}
	}

	// 第八步：为下一个波浪准备状态
	// 将当前波浪的终点作为下一个波浪的起点
	waveState.timeFirstZero = waveState.timeSecondZero;

	// 切换波浪类型（波峰↔波谷交替）
	if (waveState.waveType == 1) {
		waveState.waveType = 2;  // 波峰后应该是波谷
	} else if (waveState.waveType == 2) {
		waveState.waveType = 1;  // 波谷后应该是波峰
	} else {
		waveState.waveType = -1; // 错误状态
	}

	// 重置第二个零点，开始寻找新波浪的终点
	waveState.timeSecondZero = 0;
}

/**
 * 寻找第一个零点（F_F_Zero） - 波浪起点检测函数
 */
void FindFirstZeroCrossing(int periodSMA, int periodLWMA, int shiftBarIndex, SMACache &cache, SWaveState &waveState) {

   // 数据充足性检查：确保有足够的K线数据来计算移动平均线
   if ((Bars - shiftBarIndex) < (periodLWMA << 1)) return;

   // 获取当前K线位置的波浪类型
   int currentWaveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, shiftBarIndex, cache);

   // 初始化全局变量，准备寻找新的零点
   waveState.timeFirstZero = 0;  // 重置第一个零点时间
   waveState.waveType = 0;       // 重置波浪类型
   
   datetime timeFindZeroFromShift = 0;  // 存储找到的零点时间
   int index2ShiftBar = shiftBarIndex; // 保存当前搜索位置索引
   
   // 情况1：当前K线已有明确的波浪类型（上涨或下跌）
   if (currentWaveType > 0) {
      // 从当前K线开始向后搜索，寻找趋势的转折点（零点）
      timeFindZeroFromShift = ChMnr_FindZeroFromShift(periodSMA, periodLWMA, index2ShiftBar, cache);
      // 如果没有找到有效的零点，直接返回
      if (timeFindZeroFromShift <= 0) return;
   } 
   // 情况2：当前K线处于零点区域或没有明确趋势
   else {
      // 从当前K线开始向后搜索，寻找第一个明确的波浪
      currentWaveType = ChMnr_FirstWaveFromShift(periodSMA, periodLWMA, index2ShiftBar, cache);
      // 如果没有找到有效的波浪，直接返回
      if (currentWaveType <= 0) return;
   
      // 找到波浪后，继续向后搜索该波浪的结束点（零点）
      timeFindZeroFromShift = ChMnr_FindZeroFromShift(periodSMA, periodLWMA, index2ShiftBar, cache);
      // 如果没有找到有效的零点，直接返回
      if (timeFindZeroFromShift <= 0) return;
   }

   // 成功找到第一个零点，更新全局变量
   waveState.timeFirstZero = Time[index2ShiftBar];  // 记录零点时间
   waveState.waveType = currentWaveType;            // 记录波浪类型
}

/**
 * 寻找第二个零点（F_S_Zero）
 */
void FindSecondZeroCrossing(int periodSMA, int periodLWMA, int index2ShiftBar, SMACache &cache, SWaveState &waveState) {

    // 获取当前K线位置的波浪类型
    int waveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, index2ShiftBar, cache);

    // 前置条件检查：确保第一个零点已找到且波浪类型有效
    if (waveState.timeFirstZero == 0 || waveState.waveType <= 0)
        return;

    // 情况1：当前处于零点区域（趋势转折点）
    if (waveType == 0) {
        waveState.timeSecondZero = 0;  // 重置第二个零点时间
        return;
    }

    // 情况2：当前波浪类型与全局波浪类型相同
    if (waveType == waveState.waveType) {
        waveState.timeSecondZero = 0;  // 重置第二个零点时间
        return;
    }

    // 情况3：找到有效的第二个零点
    waveState.timeSecondZero = Time[index2ShiftBar];
}

/**
 * 从指定K线位置开始向后搜索零点（趋势转折点）
 */
datetime ChMnr_FindZeroFromShift(int periodSMA, int periodLWMA, int &startIndexShiftBar, SMACache &cache) {
    int count = 0;                          // 搜索计数器，记录向后搜索的K线数量
    datetime timeFindZeroFromShift = 0;     // 存储找到的零点时间
    bool found = FALSE;                     // 搜索完成标志

    // 开始循环搜索，直到找到零点或超出数据范围
    while (found == FALSE) {
        // 检查当前K线位置是否为零点区域
        if (ChMnr_IfZero(periodSMA, periodLWMA, startIndexShiftBar + count, cache)) {
            found = TRUE;  // 找到零点，设置完成标志
            timeFindZeroFromShift = Time[startIndexShiftBar + count];
            startIndexShiftBar += count;
        }

        // 移动到下一根K线继续搜索
        count++;

        // 边界检查：防止搜索超出可用数据范围
        if (startIndexShiftBar + count >= Bars) {
            found = TRUE;  // 强制结束搜索
            timeFindZeroFromShift = 0;
        }
    }

    // 返回搜索结果：找到的零点时间或0
    return (timeFindZeroFromShift);
}

/**
 * 从指定K线位置开始向后搜索第一个明确的波浪类型
 */
int ChMnr_FirstWaveFromShift(int periodSMA, int periodLWMA, int &startIndexShiftBar, SMACache &cache) {
    int count = 0;                          // 搜索计数器，记录向后搜索的K线数量
    int returnValueWaveType = -1;           // 存储找到的波浪类型，初始化为错误值
    int waveType = 0;                       // 临时存储当前K线的波浪类型
    bool found = FALSE;                     // 搜索完成标志

    // 开始循环搜索，直到找到明确波浪或超出数据范围
    while (found == FALSE) {
        // 获取当前K线位置的波浪类型
        waveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, startIndexShiftBar + count, cache);

        // 检查是否找到明确波浪类型（1=上涨，2=下跌）
        if (waveType > 0) {
            returnValueWaveType = waveType;  // 记录找到的波浪类型
            found = TRUE;                    // 设置完成标志
            startIndexShiftBar += count;
        }

        // 移动到下一根K线继续搜索
        count++;

        // 边界检查：防止搜索超出可用数据范围
        if (startIndexShiftBar + count >= Bars) {
            found = TRUE;  // 强制结束搜索
            returnValueWaveType = -1;
        }
    }

    // 返回搜索结果：找到的波浪类型或-1
    return (returnValueWaveType);
}

/**
 * 检查移动平均线是否处于"零点"状态（即交叉点附近）
 */
bool ChMnr_IfZero(int periodSMA, int periodLWMA, int bufferIndex4MA, SMACache &cache) {
    //double valueSMA = NormalizeToDigit(iMA(NULL, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, bufferIndex4MA));
    //double valueLWMA = NormalizeToDigit(iMA(NULL, 0, periodLWMA, 0, MODE_LWMA, PRICE_WEIGHTED, bufferIndex4MA));
    double valueSMA = GetCachedSMA(cache, bufferIndex4MA);
    double valueLWMA = GetCachedLWMA(cache, bufferIndex4MA);
    double diff = NormalizeToDigit(valueSMA) - NormalizeToDigit(valueLWMA);
    //return (IsInChanel(diff, 0, Trigger_Sens));
    //return (IsInATRChannel(diff, bufferIndex4MA));
    return (IsInATRChannel(diff, bufferIndex4MA, cache));
}

/**
 * 确定当前K线位置的波浪类型
 */
int ChMnr_CurrentWaveType(int periodSMA, int periodLWMA, int bufferIndex4MA, SMACache &cache) {
    //double valueSMA = iMA(NULL, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, bufferIndex4MA);
    //double valueLWMA = iMA(NULL, 0, periodLWMA, 0, MODE_LWMA, PRICE_WEIGHTED, bufferIndex4MA);
    double valueSMA = GetCachedSMA(cache, bufferIndex4MA);
    double valueLWMA = GetCachedLWMA(cache, bufferIndex4MA);
    double diff = valueSMA - valueLWMA;

    //if (ChMnr_IfZero(periodSMA, periodLWMA, bufferIndex4MA))
    if (ChMnr_IfZero(periodSMA, periodLWMA, bufferIndex4MA, cache))
        return (0);  // 返回0表示处于零点/转折区域

    if (diff > 0.0)
        return (1);  // 返回1表示上涨波浪（波峰形成阶段）

    if (diff < 0.0)
        return (2);  // 返回2表示下跌波浪（波谷形成阶段）

    return (-1);
}

/**
 * 添加新波浪信息到波浪数组
 */
void Add_Wave(SWaveState &waveState, SWaveInfo &arrayAllWavesInfo[]) {
    // 获取当前波浪数组的大小（即已存储的波浪数量）
    int dimension1 = ArraySize(arrayAllWavesInfo);

    // 增加数组大小以容纳新波浪
    dimension1++;
    ArrayResize(arrayAllWavesInfo, dimension1);

    // 存储波浪的基本信息到新数组位置
    arrayAllWavesInfo[dimension1 - 1].waveType = waveState.waveType;             // 波浪类型 (1=波峰, 2=波谷)
    arrayAllWavesInfo[dimension1 - 1].timeFirstZero = waveState.timeFirstZero;   // 第一个零点时间（波浪开始）
    arrayAllWavesInfo[dimension1 - 1].timeSecondZero = waveState.timeSecondZero; // 第二个零点时间（波浪结束）

    // 获取前一个波浪的枢轴点时间，用于优化当前波浪的枢轴点搜索范围
    datetime timePrePivot = 0;
    if (dimension1 - 2 >= 0)  // 确保存在前一个波浪
        timePrePivot = arrayAllWavesInfo[dimension1 - 2].pivotTime;  // 前一个波浪的枢轴时间

    // 寻找当前波浪的枢轴点（波峰或波谷的时间）
    datetime timePivot = FindPivot(waveState, timePrePivot);

    // 如果成功找到枢轴点
    if (timePivot != 0) {
        // 存储枢轴点的K线索引位置
        arrayAllWavesInfo[dimension1 - 1].pivotBarIndex = iBarShift(NULL, 0, timePivot, FALSE);  // 枢轴点Bar索引

        // 存储枢轴点的时间戳
        arrayAllWavesInfo[dimension1 - 1].pivotTime = timePivot;  // 枢轴点时间

        // 根据波浪类型存储枢轴点价格
        if (waveState.waveType == 1) {
            // 波峰类型：存储最高价
            arrayAllWavesInfo[dimension1 - 1].pivotPrice = High[iBarShift(NULL, 0, timePivot, FALSE)];  // 枢轴点价格
        }
        else if (waveState.waveType == 2) {
            // 波谷类型：存储最低价  
            arrayAllWavesInfo[dimension1 - 1].pivotPrice = Low[iBarShift(NULL, 0, timePivot, FALSE)];   // 枢轴点价格
        }
    }
}

/**
 * 寻找枢轴点（波峰或波谷）的时间
 */
datetime FindPivot(SWaveState &waveState, datetime timePrePivot) {
    // 参数有效性检查
    if (waveState.waveType < 1 || waveState.timeFirstZero == 0 || waveState.timeSecondZero == 0)
        return (0);

    // 将时间转换为对应的K线索引位置（bar index）
    int endBar = iBarShift(NULL, 0, waveState.timeFirstZero, TRUE);
    int startBar = iBarShift(NULL, 0, waveState.timeSecondZero, TRUE);

    // 检查时间转换是否成功
    if (endBar == -1 || startBar == -1) return (0);

    // 计算前一个枢轴点的K线索引位置（如果有的话）
    int iBarShiftPrePivot = 0;
    if (timePrePivot > 0)
        iBarShiftPrePivot = iBarShift(NULL, 0, timePrePivot, TRUE);

    // 计算需要搜索的K线数量
    int count = 0;
    if (iBarShiftPrePivot > 0) {
        count = iBarShiftPrePivot - startBar + 1;
    } else {
        count = endBar - startBar + 1;
    }

    // 根据波浪类型寻找不同类型的枢轴点
    if (waveState.waveType == 1) {
        // 寻找波峰（高点枢轴）
        int barIndexHighest = iHighest(NULL, 0, MODE_HIGH, count, startBar);
        return (Time[barIndexHighest]);
    }

    if (waveState.waveType == 2) {
        // 寻找波谷（低点枢轴）
        int barIndexLowest = iLowest(NULL, 0, MODE_LOW, count, startBar);
        return (Time[barIndexLowest]);
    }

    // 如果波浪类型不是1或2，返回0
    return (0);
}

/**
 * 检查数值是否在指定的通道范围内
 */
/*
int IsInChanel(double value, double baseLine, double range) {
    double limitAbove = baseLine + range;
    double limitBelow = baseLine - range;
    
    if (limitBelow <= value && value <= limitAbove) {
        return 1;
    }

    return 0;
}
*/
bool IsInATRChannel(double diff, int indexBar, SMACache &cache) {
    //double ATRVal = NormalizeToDigit(iATR(NULL, 0, Period_ATR, indexBar));
    //double ATRVal = iATR(NULL, 0, Period_ATR, indexBar);
    double ATRVal = GetCachedATR(cache, indexBar);
    double threshold = ATRVal * Trigger_Multiplier;      

    return (MathAbs(diff) <= threshold);
}


/**
 * 将价格值按位数进行标准化放大
 */
double NormalizeToDigit(double doubleValue) {
    double returnValue = doubleValue;

    for (int i = 1; i <= Digits; i++)
        returnValue = 10.0 * returnValue;

    return (returnValue);
}

/**
 * 准备警报文本信息
 */
string PrepareTextAlarm(datetime timeAlarm, int isTopOrBottom, double price, datetime pivotTime) {
    string returnValue = TimeToStr(timeAlarm, TIME_DATE) + " " + TimeToStr(timeAlarm, TIME_MINUTES) + " : ";

    if (isTopOrBottom == 1) returnValue += "The top maximum is generated : ";
    if (isTopOrBottom == 2) returnValue += "The bottom minimum is generated : ";

    returnValue += TimeToStr(pivotTime, TIME_DATE) + " " + TimeToStr(pivotTime, TIME_MINUTES) + " Price Value: ";
    returnValue += DoubleToStr(price, Digits);

    return (returnValue);
}
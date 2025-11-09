//+------------------------------------------------------------------+
//|                                                PreciseSwings.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+



#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

// 输入参数
input color  ColorHigh = clrRed;
input color  ColorLow = clrYellow;
input color  ColorConfirmed = clrAqua;

input int High_period = 70;
input int Low_period = 21;

input bool DrawLowPivotSemafor = TRUE;
input int LowPivotSemaforDrawOffset = 18;
input bool DrawHighPivotSemafor = TRUE;
input bool LowPivotTextAlarm = FALSE;
input int Trigger_Sens = 2;
input int HighPivotSemaforDrawOffset = 28;
input bool HighPivotTextAlarm = TRUE;
input string HighPivotSoundAlarm = "alert.wav";
input string LowPivotSoundAlarm = "";
input bool DrawLowestPivotSemafor = TRUE;

// 缓冲区
double HighSwingBuffer[];
double LowSwingBuffer[];
double LowestSemaBuffer[];
double ConfirmedLowBuffer[];

// 只计算最近3000根K线
const int calc_limit = 500;

datetime g_Time_ShiftBar_F_F_Zero = 0;
datetime g_Time_ShiftBar_F_S_Zero = 0;
int g_WaveType = -1;


/*
 波浪信息数组 arrayAllWavesInfo[][6] 的列结构：
 索引	数据类型     描述                       示例
   0     int         波浪类型：1=波峰，2=波谷       1
   1     int         第一个零点时间（波浪开始）     1672531200
   2     int         第二个零点时间（波浪结束）     1672534800
   3     double      枢轴点价格                1.12345
   4     int         枢轴点K线索引             125
   5     int         枢轴点时间                1672533000
*/
double arrayWavesInfoBigPeriod[][6];
double arrayWavesInfoSmallPeriod[][6];
double arrayWavesInfo25Period[][6];

datetime timeBar0 = 0;
int periodHigh;
int periodHigh7;
int periodLow;
int periodLow5;

int g_WaveType_H = -1;
int g_FoundWave_H;

datetime g_time_F_F_Zero_H = 0;
datetime g_time_F_S_Zero_H = 0;


datetime g_time_F_F_Zero_L = 0;
datetime g_time_F_S_Zero_L = 0;
int g_WaveType_L = -1;
int g_FoundWave_L;


datetime gi_412 = 0;
datetime gi_416 = 0;
int gi_420 = -1;
int gi_424;

//+------------------------------------------------------------------+
//| 自定义指标初始化函数                                              |
//+------------------------------------------------------------------+
int OnInit() {
   SetIndexBuffer(0, HighSwingBuffer);
   SetIndexBuffer(1, LowSwingBuffer);
   SetIndexBuffer(2, LowestSemaBuffer);
   SetIndexBuffer(3, ConfirmedLowBuffer);
   
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 3, ColorHigh);
   SetIndexArrow(0, 204); // 向下箭头
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 2, ColorLow);
   SetIndexArrow(1, 91); // 向上箭头
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ColorConfirmed);
   SetIndexArrow(2, 181);
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 3, ColorConfirmed);
   SetIndexArrow(3, 233);
   
   ArraySetAsSeries(HighSwingBuffer, true);
   ArraySetAsSeries(LowSwingBuffer, true);
   ArraySetAsSeries(LowestSemaBuffer, true);
   ArraySetAsSeries(ConfirmedLowBuffer, true);
   
   ArrayInitialize(HighSwingBuffer, EMPTY_VALUE);
   ArrayInitialize(LowSwingBuffer, EMPTY_VALUE);
   ArrayInitialize(LowestSemaBuffer, EMPTY_VALUE);
   ArrayInitialize(ConfirmedLowBuffer, EMPTY_VALUE);
   
   
   if (High_period == 0 && Low_period == 0) {
		Alert("High_period == 0 && Low_period == 0");
		deinit();
		return (INIT_FAILED);
	}
	periodHigh = High_period;
	periodHigh7 = Double2Int(MathRound(High_period / 7));
	periodLow = Low_period;
	periodLow5 = Double2Int(MathRound(Low_period / 5));
	/*
	if (Trigger_Sens <= 0) {
		Trigger_Sens = 2;
		Alert("<Trigger_Sens> cannot have zero or less value. Now it is adjusted by default");
	}
   */
   return(INIT_SUCCEEDED);
}

int deinit() {
	ArrayResize(arrayWavesInfoBigPeriod, 0);
	ArrayResize(arrayWavesInfoSmallPeriod, 0);
	ArrayResize(arrayWavesInfo25Period, 0);
	ArrayInitialize(HighSwingBuffer, 0.0);
	ArrayInitialize(LowSwingBuffer, 0.0);
	ArrayInitialize(LowestSemaBuffer, 0.0);
	return (0);
}

//+------------------------------------------------------------------+
//| 自定义指标迭代函数                                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]) {
   
   // 设置数组为时间序列
   /*
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);
   */
   
   int begin;
   if(prev_calculated == 0) {
      // 第一次计算
      begin = calc_limit;

   } else {
      // 只处理最新的K线
      begin = prev_calculated - 1;
   }

   begin = MathMin(begin, rates_total - 1);

    // 第三阶段：新K线检测
    // 检查是否是新K线（避免在同一根K线上重复计算）
    if (timeBar0 == Time[0])
        return (rates_total);  // 同一根K线，直接返回
        
    // 更新当前K线时间记录
    timeBar0 = Time[0];

    // 第五阶段：处理所有未计算的K线（从最新到最旧）
    // 逆序处理确保历史数据计算的准确性
    for (int i = begin; 0 <= i; i--) {
      // 清空当前位的缓冲区值（避免重复绘制）
      HighSwingBuffer[i] = EMPTY_VALUE;
      LowSwingBuffer[i] = EMPTY_VALUE;
      LowestSemaBuffer[i] = EMPTY_VALUE;
      ConfirmedLowBuffer[i] = EMPTY_VALUE;
        
        // 5.1 高点波浪管理（大周期检测）
        NewWave_Manager(    i                           // 当前处理的K线索引
                          , periodHigh7                // SMA周期：高点周期的1/7
                          , periodHigh                 // LWMA周期：完整高点周期
                          , arrayWavesInfoBigPeriod    // 高点波浪数据存储数组
                          , HighSwingBuffer            // 高点信号旗缓冲区
                          , g_time_F_F_Zero_H         // 高点第一个零点时间
                          , g_time_F_S_Zero_H         // 高点第二个零点时间
                          , g_WaveType_H              // 高点波浪类型
                          , g_FoundWave_H             // 高点波浪发现标志
                          , DrawHighPivotSemafor      // 是否绘制高点信号旗
                          , HighPivotSemaforDrawOffset // 高点信号旗偏移量
                          , HighPivotTextAlarm        // 高点文本警报开关
                          , HighPivotSoundAlarm       // 高点声音警报文件
                       );
        
        // 5.2 低点波浪管理（小周期检测）
        NewWave_Manager(    i                           // 当前处理的K线索引
                          , periodLow5                 // SMA周期：低点周期的1/5
                          , periodLow                  // LWMA周期：完整低点周期
                          , arrayWavesInfoSmallPeriod  // 低点波浪数据存储数组
                          , LowSwingBuffer             // 低点信号旗缓冲区
                          , g_time_F_F_Zero_L         // 低点第一个零点时间
                          , g_time_F_S_Zero_L         // 低点第二个零点时间
                          , g_WaveType_L              // 低点波浪类型
                          , g_FoundWave_L             // 低点波浪发现标志
                          , DrawLowPivotSemafor       // 是否绘制低点信号旗
                          , LowPivotSemaforDrawOffset  // 低点信号旗偏移量
                          , LowPivotTextAlarm         // 低点文本警报开关
                          , LowPivotSoundAlarm        // 低点声音警报文件
                       );
        
        // 5.3 最低点波浪管理（极值检测）
        NewWave_Manager(    i                           // 当前处理的K线索引
                          , 2                          // 固定SMA周期：2
                          , 5                          // 固定LWMA周期：5
                          , arrayWavesInfo25Period     // 最低点波浪数据存储数组
                          , LowestSemaBuffer          // 最低点信号旗缓冲区
                          , gi_412                    // 最低点第一个零点时间
                          , gi_416                    // 最低点第二个零点时间
                          , gi_420                    // 最低点波浪类型
                          , gi_424                    // 最低点波浪发现标志
                          , DrawLowestPivotSemafor    // 是否绘制最低点信号旗
                          , 3                          // 固定信号旗偏移量：3点
                          , 0                         // 关闭文本警报
                          , ""                        // 无声音警报
                       );
    }

 
   return(rates_total);
}

int NewWave_Manager(int indexBar
                  , int periodSMA
                  , int periodLWMA
                  , double &arrayAllWavesInfo[][6]
                  , double &SemaBuffer[]
                  , datetime &time_F_F_Zero
                  , datetime &time_F_S_Zero
                  , int &waveType
                  , int &foundWave
                  , bool drawPivotSemafor
                  , int pivotSemaforDrawOffset
                  , int pivotTextAlarm
                  , string pivotSoundAlarm) {

	// 第一步：初始化波浪管理器，加载之前的波浪状态
	Init_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);

	// 第二步：检查是否已找到第一个零点（波浪起点）
	// 如果未找到，尝试寻找第一个零点
	if (g_Time_ShiftBar_F_F_Zero == 0) {
		F_F_Zero(periodSMA, periodLWMA, indexBar);
		foundWave = 0;  // 标记未找到完整波浪
		DeInit_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);  // 保存当前状态
		return (0);  // 直接返回，等待下一个周期
	}

	// 第四步：检查是否已找到第二个零点（波浪终点）
	// 如果未找到，尝试寻找第二个零点
	if (g_Time_ShiftBar_F_S_Zero == 0) {
		F_S_Zero(periodSMA, periodLWMA, g_WaveType, indexBar);
		// 如果仍未找到第二个零点，标记未找到完整波浪
		if (g_Time_ShiftBar_F_S_Zero == 0) {
			foundWave = 0;
			DeInit_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);
			return (0);
		}
	}

	// 第五步：将完整的波浪信息添加到波浪数组
	// 此时已找到波浪的起点和终点
	Add_Wave(g_Time_ShiftBar_F_F_Zero, g_Time_ShiftBar_F_S_Zero, g_WaveType, arrayAllWavesInfo);

	// 第六步：标记已找到完整波浪
	foundWave = 1;

	// 第七步：获取波浪总数和最新波浪的枢轴点信息
	int wavesCount = WAMng_WaveCount(arrayAllWavesInfo);
	int iBarPivot = StrToInteger(DoubleToStr(arrayAllWavesInfo[wavesCount - 1][4], 0));  // 枢轴点Bar索引
	datetime timePivot = Time[iBarPivot];  // 枢轴点时间

	// 第八步：绘制枢轴点信号旗（如果启用）
	if (drawPivotSemafor) {
		int iPivot = iBarPivot;
		int iBar_F_S_Zero = iBarShift(NULL, 0, g_Time_ShiftBar_F_S_Zero, FALSE);

		// 清空信号旗缓冲区中相关区域
		for (int i = iBar_F_S_Zero - 1; i > iPivot; i++)
			SemaBuffer[i] = 0;

		// 设置枢轴点位置的信号旗值
		SemaBuffer[iBarPivot] = arrayAllWavesInfo[wavesCount - 1][3];  // 枢轴点价格

		// 根据波浪类型调整信号旗的绘制位置
		if (g_WaveType == 1) {
			// 波峰信号旗：在价格上方偏移绘制，避免遮挡价格线
			SemaBuffer[iBarPivot] += pivotSemaforDrawOffset * Point;
		} else if (g_WaveType == 2) {
			// 波谷信号旗：在价格下方偏移绘制，避免遮挡价格线
			SemaBuffer[iBarPivot] = SemaBuffer[iBarPivot] - pivotSemaforDrawOffset * Point;
		}

		// 第九步：触发警报（如果启用且在当前K线附近）
		if (indexBar < 50) {
			if (pivotSoundAlarm != "") {
				PlaySound(pivotSoundAlarm);  // 播放声音警报
			}

			if (pivotTextAlarm == 1) {
				// 显示文本警报
				Alert(PrepareTextAlarm(Time[0], g_WaveType, arrayAllWavesInfo[wavesCount - 1][3], timePivot));
			}
		}
	}

	// 第十一步：为下一个波浪准备状态
	// 将当前波浪的终点作为下一个波浪的起点
	g_Time_ShiftBar_F_F_Zero = g_Time_ShiftBar_F_S_Zero;

	// 切换波浪类型（波峰↔波谷交替）
	if (g_WaveType == 1) {
		g_WaveType = 2;  // 波峰后应该是波谷
	} else if (g_WaveType == 2) {
		g_WaveType = 1;  // 波谷后应该是波峰
	} else {
		g_WaveType = -1; // 错误状态
	}

	// 重置第二个零点，开始寻找新波浪的终点
	g_Time_ShiftBar_F_S_Zero = 0;
	
	// 第十二步：保存当前波浪状态到调用方变量
	DeInit_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);
	return (0);
}

void Init_Wave_Manager(datetime time_F_F_Zero, datetime time_F_S_Zero, int waveType) {
    // 将调用方传递的第一个零点时间加载到全局变量
    // 这样波浪分析过程可以从正确的位置继续
    g_Time_ShiftBar_F_F_Zero = time_F_F_Zero;
    
    // 将调用方传递的第二个零点时间加载到全局变量
    // 如果为0表示尚未找到第二个零点，需要继续搜索
    g_Time_ShiftBar_F_S_Zero = time_F_S_Zero;
    
    // 将调用方传递的波浪类型加载到全局变量
    // 确定当前的波浪方向，用于后续的趋势分析
    g_WaveType = waveType;
}

void DeInit_Wave_Manager(datetime &time_F_F_Zero, datetime &time_F_S_Zero, int &waveType) {
    // 将全局的第一个零点时间保存到调用方的变量中
    // 这样调用方可以获取最新的波浪起始点信息
    time_F_F_Zero = g_Time_ShiftBar_F_F_Zero;
    
    // 将全局的第二个零点时间保存到调用方的变量中
    // 这样调用方可以获取最新的波浪结束点信息
    time_F_S_Zero = g_Time_ShiftBar_F_S_Zero;
    
    // 将全局的波浪类型保存到调用方的变量中
    // 这样调用方可以获取当前的波浪方向（1=上涨，2=下跌）
    waveType = g_WaveType;
}

void F_F_Zero(int periodSMA, int periodLWMA, int shiftBarIndex) {

    // 数据充足性检查：确保有足够的K线数据来计算移动平均线
    // (periodLWMA << 1) 等价于 periodLWMA * 2，确保有双倍周期的数据量
    // 这是为了避免在数据不足时产生不可靠的移动平均信号
    if ((Bars - shiftBarIndex) >= (periodLWMA << 1)) {

        // 获取当前K线位置的波浪类型
        // 分析SMA和LWMA的相对位置关系来确定趋势方向
        int currentWaveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, shiftBarIndex);

        // 初始化全局变量，准备寻找新的零点
        g_Time_ShiftBar_F_F_Zero = 0;  // 重置第一个零点时间
        g_WaveType = 0;                // 重置波浪类型

        datetime timeFindZeroFromShift = 0;  // 存储找到的零点时间
        int index2ShiftBar = shiftBarIndex; // 保存当前搜索位置索引

        // 情况1：当前K线已有明确的波浪类型（上涨或下跌）
        if (currentWaveType > 0) {
            // 从当前K线开始向后搜索，寻找趋势的转折点（零点）
            timeFindZeroFromShift = ChMnr_FindZeroFromShift(periodSMA, periodLWMA, index2ShiftBar);
            // 如果没有找到有效的零点，直接返回
            if (timeFindZeroFromShift <= 0.0)
                return;

        } 
        // 情况2：当前K线处于零点区域或没有明确趋势
        else {
            // 从当前K线开始向后搜索，寻找第一个明确的波浪
            currentWaveType = ChMnr_FirstWaveFromShift(periodSMA, periodLWMA, index2ShiftBar);
            // 如果没有找到有效的波浪，直接返回
            if (currentWaveType <= 0)
                return;

            // 找到波浪后，继续向后搜索该波浪的结束点（零点）
            timeFindZeroFromShift = ChMnr_FindZeroFromShift(periodSMA, periodLWMA, index2ShiftBar);
            // 如果没有找到有效的零点，直接返回
            if (timeFindZeroFromShift <= 0.0)
                return;
        }

        // 成功找到第一个零点，更新全局变量
        g_Time_ShiftBar_F_F_Zero = Time[index2ShiftBar];  // 记录零点时间
        g_WaveType = currentWaveType;                     // 记录波浪类型
    }
}

void F_S_Zero(int periodSMA, int periodLWMA, int globalWaveType, int index2ShiftBar) {

    // 获取当前K线位置的波浪类型
    // 通过分析SMA和LWMA的关系判断当前市场状态
    int waveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, index2ShiftBar);

    // 前置条件检查：确保第一个零点已找到且波浪类型有效
    // 如果任何条件不满足，直接返回不设置第二个零点
    if (g_Time_ShiftBar_F_F_Zero == 0 || g_WaveType <= 0 || globalWaveType <= 0)
        return;

    // 情况1：当前处于零点区域（趋势转折点）
    // 如果当前K线处于零点状态，说明还没有形成明确的相反趋势
    // 因此不能设置第二个零点，需要继续等待趋势明确
    if (waveType == 0) {
        g_Time_ShiftBar_F_S_Zero = 0;  // 重置第二个零点时间
        return;
    }

    // 情况2：当前波浪类型与全局波浪类型相同
    // 说明趋势方向没有改变，仍在同一波浪中运行
    // 因此不能设置第二个零点，需要等待趋势反转
    if (waveType == globalWaveType) {
        g_Time_ShiftBar_F_S_Zero = 0;  // 重置第二个零点时间
        return;
    }

    // 情况3：找到有效的第二个零点
    // 当前波浪类型与全局波浪类型不同，且不是零点区域
    // 说明趋势已经发生反转，当前K线位置就是第二个零点
    g_Time_ShiftBar_F_S_Zero = Time[index2ShiftBar];
}

int Add_Wave(datetime time_F_F_Zero, datetime time_F_S_Zero, int waveType, double &arrayAllWavesInfo[][6]) {
    // 获取当前波浪数组的第一维大小（即已存储的波浪数量）
    int dimension1 = ArrayRange(arrayAllWavesInfo, 0);
    
    // 增加数组大小以容纳新波浪
    dimension1++;
    ArrayResize(arrayAllWavesInfo, dimension1);
    
    // 存储波浪的基本信息到新数组位置
    // 数组结构：[波浪索引][6个属性]
    arrayAllWavesInfo[dimension1 - 1][0] = waveType;        // 索引0：波浪类型 (1=波峰, 2=波谷)
    arrayAllWavesInfo[dimension1 - 1][1] = time_F_F_Zero;   // 索引1：第一个零点时间（波浪开始）
    arrayAllWavesInfo[dimension1 - 1][2] = time_F_S_Zero;   // 索引2：第二个零点时间（波浪结束）
    
    // 获取前一个波浪的枢轴点时间，用于优化当前波浪的枢轴点搜索范围
    datetime time_Pre_Pivot = 0;
    if (dimension1 - 2 >= 0)  // 确保存在前一个波浪（当前波浪索引-2 >= 0）
        time_Pre_Pivot = arrayAllWavesInfo[dimension1 - 2][5];  // 索引5存储前一个波浪的枢轴时间
        
    // 寻找当前波浪的枢轴点（波峰或波谷的时间）
    // 参数说明：
    // time_F_F_Zero - 搜索范围结束时间
    // time_F_S_Zero - 搜索范围开始时间  
    // waveType - 波浪类型，决定寻找波峰还是波谷
    // time_Pre_Pivot - 前一个枢轴点时间，用于优化搜索范围
    datetime timePivot = FindPivot(time_F_F_Zero, time_F_S_Zero, waveType, time_Pre_Pivot);
    
    // 如果成功找到枢轴点
    if (timePivot != 0) {
        // 存储枢轴点的K线索引位置
        // iBarShift(NULL, 0, timePivot, FALSE) - 将时间转换为对应的K线索引
        // FALSE表示如果找不到精确时间就返回-1
        arrayAllWavesInfo[dimension1 - 1][4] = iBarShift(NULL, 0, timePivot, FALSE);  // 索引4：枢轴点Bar索引
        
        // 存储枢轴点的时间戳
        arrayAllWavesInfo[dimension1 - 1][5] = timePivot;  // 索引5：枢轴点时间
        
        // 根据波浪类型存储枢轴点价格
        if (waveType == 1) {
            // 波峰类型：存储最高价
            // High[iBarShift(...)] - 获取枢轴点对应K线的最高价
            arrayAllWavesInfo[dimension1 - 1][3] = High[iBarShift(NULL, 0, timePivot, FALSE)];  // 索引3：枢轴点价格
        }
        else if (waveType == 2) {
            // 波谷类型：存储最低价  
            // Low[iBarShift(...)] - 获取枢轴点对应K线的最低价
            arrayAllWavesInfo[dimension1 - 1][3] = Low[iBarShift(NULL, 0, timePivot, FALSE)];   // 索引3：枢轴点价格
        }
    }
    
    // 函数执行成功，返回0
    return (0);
}

/**
 * 获取波浪数组中波浪的总数量
 * 该函数返回波浪信息数组第一维的大小，即当前已识别的波浪总数
 * 是波浪管理中最基础的数组维度查询函数
 * 
 * @param arrayAllWavesInfo 波浪信息二维数组，包含所有已识别的波浪数据
 * @return 波浪数组中波浪的总数量（整数）
 */
int WAMng_WaveCount(double& arrayAllWavesInfo[][6]) {
    // 使用 ArrayRange 函数获取数组第一维的大小
    // 对于二维数组：ArrayRange(array, 0) 返回行数，ArrayRange(array, 1) 返回列数
    // 参数说明：
    // arrayAllWavesInfo - 要查询的数组
    // 0 - 维度索引（0表示第一维，即波浪数量维度）
    return (ArrayRange(arrayAllWavesInfo, 0));
}

/**
 * 准备警报文本信息
 * 该函数生成格式化的警报消息，包含时间、枢轴点类型和价格信息
 * 用于在检测到新的波峰或波谷时向用户发出文本警报
 * 
 * @param timeAlarm 警报触发时间（当前时间）
 * @param isTopOrBottom 枢轴点类型标识：1=波峰(顶部)，2=波谷(底部)
 * @param price 检测到的枢轴点价格
 * @param ai_16 枢轴点发生的时间
 * @return 格式化后的完整警报文本字符串
 */
string PrepareTextAlarm(datetime timeAlarm, int isTopOrBottom, double price, datetime ai_16) {
    // 初始化返回字符串，包含警报触发时间
    // TimeToStr(timeAlarm, TIME_DATE): 将时间转换为日期格式（如"2023.12.01"）
    // TimeToStr(timeAlarm, TIME_MINUTES): 将时间转换为时分格式（如"14:30"）
    string returnValue = TimeToStr(timeAlarm, TIME_DATE) + " " + TimeToStr(timeAlarm, TIME_MINUTES) + " : ";
    
    // 根据枢轴点类型添加相应的描述文本
    if (isTopOrBottom == 1)
        // 如果是波峰（顶部最大值），添加对应描述
        returnValue += "The top maximum is generated : ";
    if (isTopOrBottom == 2)
        // 如果是波谷（底部最小值），添加对应描述  
        returnValue += "The bottom minimum is generated : ";
    
    // 添加枢轴点发生的时间和价格信息
    // TimeToStr(ai_16, TIME_DATE): 枢轴点的日期
    // TimeToStr(ai_16, TIME_MINUTES): 枢轴点的具体时间
    returnValue += TimeToStr(ai_16, TIME_DATE) + " " + TimeToStr(ai_16, TIME_MINUTES) + " Price Value: ";
    
    // 添加格式化后的价格值
    // DoubleToStr(price, Digits): 将价格转换为字符串，保留当前货币对的小数位数
    returnValue += DoubleToStr(price, Digits);
    
    // 返回完整的警报文本
    return (returnValue);
}

/**
 * 确定当前K线位置的波浪类型
 * 该函数通过分析SMA和LWMA的相对位置关系来判断当前市场的波浪状态
 * 是波浪识别系统的核心判断函数
 * 
 * @param periodSMA 简单移动平均线(SMA)的计算周期
 * @param periodLWMA 线性加权移动平均线(LWMA)的计算周期
 * @param bufferIndex4MA 要分析的K线索引位置
 * @return 波浪类型代码：0=零点区域, 1=上涨波浪, 2=下跌波浪, -1=错误状态

   返回值含义：
   返回值	波浪类型	市场状态     交易意义
   0        零点区域	趋势转折点    SMA和LWMA接近，可能发生趋势反转
   1        上涨波浪	上升趋势      SMA在LWMA之上，可能形成波峰
   2        下跌波浪	下降趋势      SMA在LWMA之下，可能形成波谷
   -1       错误状态	无法判断      计算错误或异常情况
 
   技术分析原理：
   为什么使用SMA和LWMA的组合？
      1.SMA（简单移动平均）：
         反应较慢，过滤市场噪音
         代表中长期趋势方向
         稳定性高，但滞后性明显
      2.LWMA（线性加权移动平均）：
         反应较快，对近期价格敏感
         代表短期趋势动能
         领先性强，但波动较大
      3.组合优势：
         SMA确定主要趋势方向
         LWMA捕捉趋势变化先机
         两者的交叉点提供高质量的交易信号
 
 开始
  ↓
计算SMA和LWMA值
  ↓
计算差值 diff = SMA - LWMA
  ↓
调用ChMnr_IfZero检查是否在零点区域
  ├─ 如果是 → 返回0（零点）
  ↓ 如果不是
检查diff > 0
  ├─ 如果是 → 返回1（上涨波浪）
  ↓ 如果不是  
检查diff < 0
  ├─ 如果是 → 返回2（下跌波浪）
  ↓ 如果不是
返回-1（错误状态）
 
 */
int ChMnr_CurrentWaveType(int periodSMA, int periodLWMA, int bufferIndex4MA) {
    // 计算简单移动平均线(SMA)的当前值
    // 使用收盘价计算，反应整体趋势方向
    double valueSMA = iMA(NULL, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, bufferIndex4MA);
    
    // 计算线性加权移动平均线(LWMA)的当前值
    // 使用加权价格(H+L+C)/3计算，对近期价格更敏感
    double valueLWMA = iMA(NULL, 0, periodLWMA, 0, MODE_LWMA, PRICE_WEIGHTED, bufferIndex4MA);
    
    // 计算两条移动平均线的差值
    // 这个差值决定了当前的趋势方向和强度
    double diff = valueSMA - valueLWMA;
    
    // 首先检查是否处于"零点"区域（交叉点附近）
    // 如果两条均线非常接近，认为处于趋势转折区域
    if (ChMnr_IfZero(periodSMA, periodLWMA, bufferIndex4MA) == 1)
        return (0);  // 返回0表示处于零点/转折区域
    
    // 如果SMA在LWMA之上，表示上涨趋势
    // SMA反应较慢但更稳定，LWMA反应更快但波动较大
    // 当SMA > LWMA时，说明整体趋势向上
    if (diff > 0.0)
        return (1);  // 返回1表示上涨波浪（波峰形成阶段）
    
    // 如果SMA在LWMA之下，表示下跌趋势
    // 当SMA < LWMA时，说明整体趋势向下
    if (diff < 0.0)
        return (2);  // 返回2表示下跌波浪（波谷形成阶段）
    
    // 如果以上条件都不满足，返回错误代码
    // 这种情况理论上很少发生，因为diff要么>0，要么<0，要么≈0
    return (-1);
}

/**
 * 从指定K线位置开始向后搜索零点（趋势转折点）
 * 该函数从给定的起始位置开始，逐根K线向后搜索，寻找SMA和LWMA交叉的区域
 * 零点代表趋势可能发生转折的关键位置
 * 
 * @param periodSMA 简单移动平均线的计算周期
 * @param periodLWMA 线性加权移动平均线的计算周期
 * @param startIndexShiftBar 引用参数：搜索的起始K线索引，找到零点后会更新此参数
 * @return 找到的零点时间，如果搜索失败返回负值错误代码

返回值	   含义	            说明
正数时间戳   成功找到零点	    如：1672531200
-99999	    初始错误值	    理论上不应返回此值
-55555	    超出数据范围	   搜索到最新K线仍未找到零点

 
 这个函数是波浪识别中的"探测器"，负责在价格序列中精确定位趋势转折的关键位置。
 通过系统的逐K线搜索，确保不错过任何可能的波浪起始点，为整个波浪分析系统提供可靠的基础数据。

零点（Zero Point）的概念：
零点是指SMA和LWMA非常接近的区域，代表：
   趋势可能发生转折的位置
   多空力量平衡的点
   新波浪开始的潜在位置

开始搜索
↓
初始化计数器和标志
↓
进入循环搜索
↓
检查当前K线是否为零点
├─ 是 → 记录时间、更新索引、结束搜索
↓ 否
计数器+1，移动到下一根K线
↓
检查是否超出数据范围
├─ 是 → 设置错误代码、结束搜索
↓ 否
继续循环
↓
返回搜索结果

 */
datetime ChMnr_FindZeroFromShift(int periodSMA, int periodLWMA, int &startIndexShiftBar) {
    int count = 0;                          // 搜索计数器，记录向后搜索的K线数量
    datetime timeFindZeroFromShift = -99999;  // 存储找到的零点时间，初始化为错误值
    bool found = FALSE;                     // 搜索完成标志
    
    // 开始循环搜索，直到找到零点或超出数据范围
    while (found == FALSE) {
        // 检查当前K线位置是否为零点区域
        // startIndexShiftBar + count：从起始位置向后移动count根K线
        if (ChMnr_IfZero(periodSMA, periodLWMA, startIndexShiftBar + count) == 1) {
            found = TRUE;  // 找到零点，设置完成标志
            
            // 记录找到的零点时间
            // Time[startIndexShiftBar + count]：获取该K线的时间戳
            timeFindZeroFromShift = Time[startIndexShiftBar + count];
            
            // 更新起始索引参数，使其指向找到的零点位置
            // 这样调用方知道零点具体在哪根K线
            startIndexShiftBar += count;
        }
        
        // 移动到下一根K线继续搜索
        count++;
        
        // 边界检查：防止搜索超出可用数据范围
        if (startIndexShiftBar + count >= Bars) {
            found = TRUE;  // 强制结束搜索
            
            // 设置特定的错误代码，表示搜索失败（超出数据范围）
            timeFindZeroFromShift = -55555;
        }
    }
    
    // 返回搜索结果：找到的零点时间或错误代码
    return (timeFindZeroFromShift);
}

/**
 * 从指定K线位置开始向后搜索第一个明确的波浪类型
 * 该函数用于在当前处于零点区域（趋势不明）时，寻找后续出现的第一个明确趋势方向
 * 跳过所有模糊的零点区域，直到找到明确的上涨或下跌波浪
 * 
 * @param periodSMA 简单移动平均线的计算周期
 * @param periodLWMA 线性加权移动平均线的计算周期
 * @param startIndexShiftBar 引用参数：搜索的起始K线索引，找到波浪后会更新此参数
 * @return 找到的波浪类型：1=上涨波浪，2=下跌波浪，负值=错误代码


返回值	波浪类型	市场状态	    说明
1	      上涨波浪	上升趋势	    SMA在LWMA之上，明确上涨
2	      下跌波浪	下降趋势	    SMA在LWMA之下，明确下跌
-99999	初始错误	未使用	     理论上不应返回此值
-55555	搜索失败	无明确趋势	   搜索到最新K线仍未找到明确波浪


这个函数是波浪识别系统中的"方向探测器"，专门用于在趋势不明确的市场环境中寻找第一个明确的趋势方向。
通过与ChMnr_FindZeroFromShift函数的配合使用，确保了在各种市场情况下都能可靠地启动波浪分析过程。

 
函数的作用和意义：
当市场处于整理或转折区域时（零点区域），该函数帮助：
   跳过模糊区域：忽略所有趋势不明确的零点
   寻找明确方向：定位第一个出现的明确上涨或下跌趋势
   确定波浪起点：为后续的波浪分析提供清晰的起始点


开始搜索
↓
初始化计数器和标志
↓
进入循环搜索
↓
检查当前K线波浪类型
├─ 明确波浪(1或2) → 记录类型、更新索引、结束搜索
↓ 零点区域(0)
计数器+1，移动到下一根K线
↓
检查是否超出数据范围
├─ 是 → 设置错误代码、结束搜索
↓ 否
继续循环
↓
返回搜索结果


搜索过程示例：
// 假设从第100根K线开始搜索，当前处于整理区域
startIndexShiftBar = 100
count = 0 → K线100: waveType = 0 (零点区域)
count = 1 → K线101: waveType = 0 (零点区域)  
count = 2 → K线102: waveType = 1 (明确上涨波浪!)
↓
更新 startIndexShiftBar = 100 + 2 = 102
返回 1 (上涨波浪类型)

 */
int ChMnr_FirstWaveFromShift(int periodSMA, int periodLWMA, int &startIndexShiftBar) {
    int count = 0;                          // 搜索计数器，记录向后搜索的K线数量
    int returnValueWaveType = -99999;       // 存储找到的波浪类型，初始化为错误值
    int waveType = 0;                       // 临时存储当前K线的波浪类型
    bool found = FALSE;                     // 搜索完成标志
    
    // 开始循环搜索，直到找到明确波浪或超出数据范围
    while (found == FALSE) {
        // 获取当前K线位置的波浪类型
        // startIndexShiftBar + count：从起始位置向后移动count根K线
        waveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, startIndexShiftBar + count);
        
        // 检查是否找到明确波浪类型（1=上涨，2=下跌）
        if (waveType > 0) {
            returnValueWaveType = waveType;  // 记录找到的波浪类型
            found = TRUE;                    // 设置完成标志
            
            // 更新起始索引参数，使其指向找到波浪的位置
            // 这样调用方知道明确的波浪从哪根K线开始
            startIndexShiftBar += count;
        }
        
        // 移动到下一根K线继续搜索
        count++;
        
        // 边界检查：防止搜索超出可用数据范围
        if (startIndexShiftBar + count >= Bars) {
            found = TRUE;  // 强制结束搜索
            
            // 设置特定的错误代码，表示搜索失败（超出数据范围）
            returnValueWaveType = -55555;
        }
    }
    
    // 返回搜索结果：找到的波浪类型或错误代码
    return (returnValueWaveType);
}

/**
 * 寻找枢轴点（波峰或波谷）的时间
 * 该函数在给定的时间范围内寻找最高点或最低点作为枢轴点
 * 
 * @param time_F_F_Zero 第一个零点时间（搜索范围的结束时间）
 * @param time_F_S_Zero 第二个零点时间（搜索范围的开始时间）  
 * @param waveType 波浪类型：1=寻找波峰(高点)，2=寻找波谷(低点)
 * @param time_Pre_Pivot 前一个枢轴点的时间（可选，用于优化搜索范围）
 * @return 返回找到的枢轴点时间，如果找不到返回0
 */
datetime FindPivot(datetime time_F_F_Zero, datetime time_F_S_Zero, int waveType, datetime time_Pre_Pivot) {
    // 参数有效性检查
    // 如果波浪类型无效或时间参数为0，直接返回0
    if (waveType < 1 || time_F_F_Zero == 0 || time_F_S_Zero == 0)
        return (0);
    
    // 将时间转换为对应的K线索引位置（bar index）
    // endBar: 搜索范围的结束位置（对应第一个零点时间）
    // startBar: 搜索范围的开始位置（对应第二个零点时间）
    // iBarShift 返回指定时间对应的 bar 索引，TRUE参数表示如果找不到精确时间，返回最接近的K线索引
    int endBar = iBarShift(NULL, 0, time_F_F_Zero, TRUE);
    int startBar = iBarShift(NULL, 0, time_F_S_Zero, TRUE);
    
    // 检查时间转换是否成功，如果转换失败（未找到 bar）返回0
    if (endBar == -1 || startBar == -1)
        return (0);
    
    // 计算前一个枢轴点的K线索引位置（如果有的话）
    int iBarShift_Pre_Pivot = 0;
    if (time_Pre_Pivot > 0)
        iBarShift_Pre_Pivot = iBarShift(NULL, 0, time_Pre_Pivot, TRUE);
    
    // 计算需要搜索的K线数量
    int count = 0;
    if (iBarShift_Pre_Pivot > 0) {
        // 如果存在前一个枢轴点，搜索范围从前一个枢轴点到当前开始位置
        // 这样可以避免重复搜索已经识别过的区域，提高效率
        count = iBarShift_Pre_Pivot - startBar + 1;
    } else {
        // 如果没有前一个枢轴点，搜索整个指定范围
        // 从开始位置到结束位置的所有K线
        count = endBar - startBar + 1;
    }
    
    // 根据波浪类型寻找不同类型的枢轴点
    if (waveType == 1) {
        // 寻找波峰（高点枢轴）
        // iHighest函数在指定范围内寻找最高价的K线索引
        // 参数说明：
        // NULL - 当前货币对
        // 0 - 当前时间框架  
        // MODE_HIGH - 搜索最高价
        // count - 搜索的K线数量
        // startBar - 搜索的起始位置
        int barIndexHighest = iHighest(NULL, 0, MODE_HIGH, count, startBar);
        // 返回找到的最高点对应的时间
        return (Time[barIndexHighest]);
    }
    
    if (waveType == 2) {
        // 寻找波谷（低点枢轴）
        // iLowest函数在指定范围内寻找最低价的K线索引
        // 参数说明：
        // NULL - 当前货币对
        // 0 - 当前时间框架
        // MODE_LOW - 搜索最低价  
        // count - 搜索的K线数量
        // startBar - 搜索的起始位置
        int barIndexLowest = iLowest(NULL, 0, MODE_LOW, count, startBar);
        // 返回找到的最低点对应的时间
        return (Time[barIndexLowest]);
    }
    
    // 如果波浪类型不是1或2，返回0
    return (0);
}

/**
 * 检查移动平均线是否处于"零点"状态（即交叉点附近）
 * 该函数通过比较SMA和LWMA的标准化差值来判断是否处于交叉区域
 * 用于识别波浪的转折点（零点）
 * 
 * @param periodSMA 简单移动平均线(SMA)的周期
 * @param periodLWMA 线性加权移动平均线(LWMA)的周期  
 * @param bufferIndex4MA 用于计算移动平均的K线索引位置
 * @return 如果SMA和LWMA差值在触发灵敏度范围内返回1，否则返回0
 
 
 通过Trigger_Sens参数控制对市场噪音的过滤程度
 这个函数是整个波浪识别算法的核心判断逻辑，通过双移动平均线的交叉关系来精确定位市场的转折点。
 */
int ChMnr_IfZero(int periodSMA, int periodLWMA, int bufferIndex4MA) {
    // 计算简单移动平均线(SMA)的标准化值
    // iMA参数说明：
    // NULL - 当前货币对
    // 0 - 当前时间框架
    // periodSMA - SMA计算周期
    // 0 - 平移偏移量
    // MODE_SMA - 简单移动平均模式
    // PRICE_CLOSE - 使用收盘价计算
    // bufferIndex4MA - 计算的K线索引位置
    double valueSMA = NormalizeToDigit(iMA(NULL, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, bufferIndex4MA));
    
    // 计算线性加权移动平均线(LWMA)的标准化值
    // iMA参数说明：
    // NULL - 当前货币对  
    // 0 - 当前时间框架
    // periodLWMA - LWMA计算周期
    // 0 - 平移偏移量
    // MODE_LWMA - 线性加权移动平均模式
    // PRICE_WEIGHTED - 使用加权价格((H+L+C)/3)计算
    // bufferIndex4MA - 计算的K线索引位置
    double valueLWMA = NormalizeToDigit(iMA(NULL, 0, periodLWMA, 0, MODE_LWMA, PRICE_WEIGHTED, bufferIndex4MA));
    
    // 计算两条移动平均线的差值
    // 正值表示SMA在LWMA之上，负值表示SMA在LWMA之下
    double diff = valueSMA - valueLWMA;
    
    // 检查差值是否在触发灵敏度范围内（即是否接近零点）
    // IsInChanel参数说明：
    // diff - 需要检查的差值
    // 0 - 基线值（零点）
    // Trigger_Sens - 触发灵敏度范围
    return (IsInChanel(diff, 0, Trigger_Sens));
}

/**
 * 将价格值按位数进行标准化放大
 * 该函数通过对价格值进行10的幂次方放大，将其转换为整数形式进行比较
 * 主要用于解决浮点数精度比较问题
 * 直接比较：1.12345 == 1.12346? 可能因浮点误差判断错误
 * 
 * @param doubleValue 需要标准化的价格值（如：1.23456）
 * @return 放大后的整数值（如：对于5位小数货币对，1.23456 → 123456.0）
 */
double NormalizeToDigit(double doubleValue) {
    // 保存原始值到返回变量
    double returnValue = doubleValue;
    
    // 根据货币对的小数位数进行循环放大
    // Digits 是MT4内置变量，表示当前货币对的价格小数位数
    // 例如：EURUSD的Digits=5，XAUUSD的Digits=2
    for (int i = 1; i <= Digits; i++)
        // 每次循环将数值乘以10，相当于向左移动一位小数
        returnValue = 10.0 * returnValue;
    
    // 返回放大后的数值
    return (returnValue);
}

/**
 * 检查数值是否在指定的通道范围内
 * 该函数用于判断一个给定值是否落在以基线为中心、指定范围大小的通道内
 * 
 * @param value 需要检查的数值
 * @param baseLine 通道的基线（中心值）
 * @param range 通道的范围（从基线向上下延伸的距离）
 * @return 如果值在通道范围内返回1，否则返回0
 */
int IsInChanel(double value, double baseLine, double range) {
    // 计算通道的上限：基线值加上范围值
    // 例如：baseLine=100, range=5 => limitAbove=105
    double limitAbove = baseLine + range;
    
    // 计算通道的下限：基线值减去范围值  
    // 例如：baseLine=100, range=5 => limitBelow=95
    double limitBelow = baseLine - range;
    
    // 检查给定值是否在通道范围内（包含边界）
    // 使用逻辑与(&&)确保值同时满足大于等于下限且小于等于上限
    if (limitBelow <= value && value <= limitAbove) {
        // 值在通道范围内，返回1表示"是"
        return 1;
    }

    // 值不在通道范围内，返回0表示"否"
    return 0;
}

int Double2Int(double doubleValue) {
	return (StrToInteger(DoubleToStr(doubleValue, 0)));
}
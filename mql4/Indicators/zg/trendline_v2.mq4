//|Copyright 2018～2019, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
/*
   1.波浪检测：通过SMA和LWMA的交叉来识别市场的高点和低点
   2.趋势线绘制：自动连接相同类型的波浪点形成支撑线和阻力线
   3.信号旗标记：在检测到的枢轴点位置绘制箭头标记
   4.预测趋势线：基于当前波浪预测未来的趋势方向
   5.警报功能：在检测到新的枢轴点时发出声音和文本警报
   使用多重时间周期分析

*/


#property copyright "WATL ?Modified by ideal "
#property link      "http://www.indofx-trader.net/index.php"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 DarkGoldenrod
#property indicator_color3 BlueViolet

extern int High_period = 70;
extern int Low_period = 21;
extern int Trigger_Sens = 2;
extern bool ForecastHighTrendLine = TRUE;
extern bool StayLinesAfterDelete = FALSE;
extern string Note0 = "***** Semafor Drawing Adjustment";
extern bool DrawHighPivotSemafor = TRUE;
extern bool DrawLowPivotSemafor = TRUE;
extern bool DrawLowestPivotSemafor = TRUE;
extern string Note1 = "***** High Trend Lines Adjustment";
extern bool HTL_Draw = TRUE;
extern color HTL_ResColor = Red;
extern color HTL_SupColor = Maroon;
extern int HTL_Style = 1;
extern int HTL_Width = 2;
extern double HTL_Ext = 1.5;
extern int HTL_InMemory = 10;
extern int HTL_MinPivotDifferentIgnore = 5;
extern string Note2 = "***** Low Trend Lines Adjustment";
extern bool LTL_Draw = TRUE;
extern color LTL_ResColor = Gold;
extern color LTL_SupColor = Goldenrod;
extern int LTL_Style = 0;
extern int LTL_Width = 0;
extern double LTL_Ext = 1.5;
extern int LTL_InMemory = 30;
extern int LTL_MinPivotDifferentIgnore = 4;
extern string Note3 = "***** High Semafor Adjustment";
extern bool HighPivotTextAlarm = TRUE;
extern string HighPivotSoundAlarm = "alert.wav";
extern int HighPivotSemaforDrawOffset = 28;
extern int HighSemaforSymbol = 142;
extern string Note4 = "***** High Semafor Adjustment";
extern bool LowPivotTextAlarm = FALSE;
extern string LowPivotSoundAlarm = "";
extern int LowPivotSemaforDrawOffset = 18;
extern int LowSemaforSymbol = 141;
extern string Note5 = "***** Lowest Semafor Adjustment";
extern int LowestSemaforSymbol = 115;
extern string Note6 = "***** Forecast Trend Line Adjustment";
extern color FTL_Color = DeepPink;
extern int FTL_Style = 1;
extern int FTL_Width = 2;
extern double FTL_Ext = 1.05;
double HighSemaBuffer[];
double LowSemaBuffer[];
double LowestSemaBuffer[];

string gs_durko_l2_320 = "L2";
int periodHigh;
int periodHigh7;
int periodLow;
int periodLow5;
int timeBar0 = 0;
bool g_IsInited = FALSE;
double arrayWavesInfoBigPeriod[][6];
int g_time_F_F_Zero_H = 0;
int g_time_F_S_Zero_H = 0;
int g_WaveType_H = -1;
int g_FoundWave_H;
double arrayWavesInfoSmallPeriod[][6];
int g_time_F_F_Zero_L = 0;
int g_time_F_S_Zero_L = 0;
int g_WaveType_L = -1;
int g_FoundWave_L;
double arrayWavesInfo25Period[][6];
int gi_412 = 0;
int gi_416 = 0;
int gi_420 = -1;
int gi_424;
int g_Time_ShiftBar_F_F_Zero = 0;
int g_Time_ShiftBar_F_S_Zero = 0;
int g_WaveType = -1;
string gsa_440[];
string gsa_444[];
color g_Color_Resistance;
color g_Color_Support;
int g_Line_Style;
int g_Line_Width;
double g_Line_Ext;
int g_Line_InMemory = 0;
string g_Line_Name = "";
int g_count_TrendLine = 0;
int g_Line_MinPivotDifferentIgnore = 0;
string nameForecastHighTrendLine = "ForecastHighTrendLine";
bool g_ReDrawed = FALSE;
int g_timePivot = 0;
double g_pricePivot = 0.0;
int g_ReDraw_WaveType = 0;
int countBars;

int init() {
	countBars = Bars;
	g_IsInited = FALSE;
	TLMng_DeleteLinesCurrentTF();
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
		deinit();
		return (0);
	}
	periodHigh = High_period;
	periodHigh7 = Double2Int(MathRound(High_period / 7));
	periodLow = Low_period;
	periodLow5 = Double2Int(MathRound(Low_period / 5));
	if (Trigger_Sens <= 0) {
		Trigger_Sens = 2;
		Alert("<Trigger_Sens> cannot have zero or less value. Now it is adjusted by default");
	}

	return (0);
}

int deinit() {
	if (StayLinesAfterDelete == FALSE)
		TLMng_DeleteAllLines();
	ObjectDelete(nameForecastHighTrendLine);
	ArrayResize(gsa_440, 0);
	ArrayResize(gsa_444, 0);
	ArrayResize(arrayWavesInfoBigPeriod, 0);
	ArrayResize(arrayWavesInfoSmallPeriod, 0);
	ArrayResize(arrayWavesInfo25Period, 0);
	ArrayInitialize(HighSemaBuffer, 0.0);
	ArrayInitialize(LowSemaBuffer, 0.0);
	ArrayInitialize(LowestSemaBuffer, 0.0);
	ObjectDelete(gs_durko_l2_320);
	if (StayLinesAfterDelete == FALSE)
		TLMng_DeleteLinesCurrentInd();
	return (0);
}

/**
 * MT4指标主函数 - 每个tick自动执行
 * 该函数是波浪分析指标的核心循环，负责协调所有波浪检测、信号绘制和趋势线管理功能
 * 在每个价格变动时被MT4平台自动调用，确保指标的实时性
 * 
 * @return 始终返回0
 */
int start() {
    // 第一阶段：初始化检查和数据重置
    // 检查指标是否已完成初始化
    if (g_IsInited == FALSE) {
        // 检查K线数量是否发生变化（新K线生成或历史数据更新）
        if (countBars != Bars) {
            // 执行反初始化：清理所有对象和数组
            deinit();
            // 暂停1秒，确保清理操作完成
            Sleep(1000);
            // 更新K线数量记录
            countBars = Bars;
            // 重置当前K线时间记录
            timeBar0 = 0;
            // 直接返回，等待下一个tick重新初始化
            return (0);
        }
    }
    
    // 第二阶段：完成初始化标记
    // 如果尚未初始化，现在标记为已初始化
    if (g_IsInited == FALSE) {
        g_IsInited = TRUE;
    }
    
    // 第三阶段：新K线检测
    // 检查是否是新K线（避免在同一根K线上重复计算）
    if (timeBar0 == Time[0])
        return (0);  // 同一根K线，直接返回
        
    // 更新当前K线时间记录
    timeBar0 = Time[0];
    
    // 第四阶段：计算未处理的K线数量
    // IndicatorCounted()返回已计算的K线数量
    int countedBars = IndicatorCounted();
    // 计算需要处理的新K线数量
    int uncountedBars = Bars - countedBars;

    // 第五阶段：处理所有未计算的K线（从最新到最旧）
    // 逆序处理确保历史数据计算的准确性
    for (int i = uncountedBars; 0 < i; i--) {
        
        // 5.1 高点波浪管理（大周期检测）
        NewWave_Manager(    i                           // 当前处理的K线索引
                          , periodHigh7                // SMA周期：高点周期的1/7
                          , periodHigh                 // LWMA周期：完整高点周期
                          , arrayWavesInfoBigPeriod    // 高点波浪数据存储数组
                          , HighSemaBuffer            // 高点信号旗缓冲区
                          , g_time_F_F_Zero_H         // 高点第一个零点时间
                          , g_time_F_S_Zero_H         // 高点第二个零点时间
                          , g_WaveType_H              // 高点波浪类型
                          , g_FoundWave_H             // 高点波浪发现标志
                          , DrawHighPivotSemafor      // 是否绘制高点信号旗
                          , HighPivotSemaforDrawOffset // 高点信号旗偏移量
                          , HighPivotTextAlarm        // 高点文本警报开关
                          , HighPivotSoundAlarm       // 高点声音警报文件
                          , 1);                       // 需要绘制预测趋势线
        
        // 5.2 低点波浪管理（小周期检测）
        NewWave_Manager(    i                           // 当前处理的K线索引
                          , periodLow5                 // SMA周期：低点周期的1/5
                          , periodLow                  // LWMA周期：完整低点周期
                          , arrayWavesInfoSmallPeriod  // 低点波浪数据存储数组
                          , LowSemaBuffer             // 低点信号旗缓冲区
                          , g_time_F_F_Zero_L         // 低点第一个零点时间
                          , g_time_F_S_Zero_L         // 低点第二个零点时间
                          , g_WaveType_L              // 低点波浪类型
                          , g_FoundWave_L             // 低点波浪发现标志
                          , DrawLowPivotSemafor       // 是否绘制低点信号旗
                          , LowPivotSemaforDrawOffset  // 低点信号旗偏移量
                          , LowPivotTextAlarm         // 低点文本警报开关
                          , LowPivotSoundAlarm        // 低点声音警报文件
                          , 0);                       // 不需要绘制预测趋势线
        
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
                          , 0);                       // 不需要绘制预测趋势线
        
        // 5.4 高点趋势线绘制（如果发现高点波浪且启用绘制）
        if (g_FoundWave_H && HTL_Draw) {
            // 初始化高点趋势线参数
            TLMng_Init(   HTL_ResColor                 // 阻力线颜色
                        , HTL_SupColor                // 支撑线颜色
                        , HTL_Style                   // 线型样式
                        , HTL_Width                   // 线宽
                        , HTL_Ext                     // 延长系数
                        , HTL_InMemory                // 内存中保留的线数量
                        , "HTL"                       // 趋势线名称前缀
                        , HTL_MinPivotDifferentIgnore // 最小枢轴差异忽略值
            );
            // 执行高点趋势线绘制
            TLMng_Main(arrayWavesInfoBigPeriod, gsa_440, g_FoundWave_H);
        }
        
        // 5.5 低点趋势线绘制（如果发现低点波浪且启用绘制）
        if (g_FoundWave_L && LTL_Draw) {
            // 初始化低点趋势线参数
            TLMng_Init(   LTL_ResColor                 // 阻力线颜色
                        , LTL_SupColor                // 支撑线颜色
                        , LTL_Style                   // 线型样式
                        , LTL_Width                   // 线宽
                        , LTL_Ext                     // 延长系数
                        , LTL_InMemory                // 内存中保留的线数量
                        , "LTL"                       // 趋势线名称前缀
                        , LTL_MinPivotDifferentIgnore // 最小枢轴差异忽略值
            );
            // 执行低点趋势线绘制
            TLMng_Main(arrayWavesInfoSmallPeriod, gsa_444, g_FoundWave_L);
        }
    }
    
    // 第六阶段：函数执行完成
    return (0);
}

void FTLMng_Main(int indexBar, int timePivot, double pricePivot, int waveType) {

	if (ObjectFind(nameForecastHighTrendLine) > -1) {
		ObjectDelete(nameForecastHighTrendLine);
		g_ReDrawed = FALSE;
		g_timePivot = 0;
		g_pricePivot = 0;
	}
	double value_LWMA = FTLMng_FindSecondpoint(indexBar, timePivot, waveType);
	if (value_LWMA != 0.0) {
		datetime timeBar = Time[indexBar];
		if (FTLMng_DrawFirst(timePivot, pricePivot, timeBar, value_LWMA) != 0) {
			g_ReDraw_WaveType = waveType;
			FTLMng_ReDraw(indexBar);
			g_ReDrawed = TRUE;
			return;
		}
	}
}

int FTLMng_DrawFirst(int timePivot, double pricePivot, int timeBar, double value_LWMA) {
	if (ObjectCreate(nameForecastHighTrendLine, OBJ_TREND, 0, timePivot, pricePivot, timeBar, value_LWMA)) {
		ObjectSet(nameForecastHighTrendLine, OBJPROP_RAY, FALSE);
		ObjectSet(nameForecastHighTrendLine, OBJPROP_COLOR, FTL_Color);
		ObjectSet(nameForecastHighTrendLine, OBJPROP_STYLE, FTL_Style);
		ObjectSet(nameForecastHighTrendLine, OBJPROP_WIDTH, FTL_Width);
		g_timePivot = timePivot;
		g_pricePivot = pricePivot;
		ObjectsRedraw();
		return (1);
	}
	GetLastError();
	return (0);
}

int FTLMng_ReDraw(int indexBar) {
	if (ObjectFind(nameForecastHighTrendLine) == -1)
		return (0);
	double secondPointMA = FTLMng_FindSecondpoint(indexBar, g_timePivot, g_ReDraw_WaveType);
	if (secondPointMA == 0.0)
		return (0);
	int timeBarN = Time[indexBar];
	int l_datetime_16 = 0;
	double ld_20 = 0;
	ObjectMove(nameForecastHighTrendLine, 1, timeBarN, secondPointMA);
	if (FTL_Ext > 0.0) {
		TLMng_CountExt(FTL_Ext, g_timePivot, g_pricePivot, timeBarN, secondPointMA, l_datetime_16, ld_20);
		if (l_datetime_16 == 0 || ld_20 == 0.0)
			return (0);
		ObjectMove(nameForecastHighTrendLine, 1, l_datetime_16, ld_20);
	}
	ObjectsRedraw();
	return (0);
}

/**
 * 寻找预测趋势线的第二个点
 * 该函数根据波浪类型和枢轴点位置，计算预测趋势线的第二个端点
 * 用于绘制从历史枢轴点延伸到当前价格的预测趋势线
 * 
 * @param indexBar 当前K线索引位置（0=最新K线）
 * @param timePivot 枢轴点的时间戳（波峰或波谷的发生时间）
 * @param waveType 波浪类型（1=波峰，2=波谷）
 * @return 预测趋势线第二个点的价格值，如果参数无效返回0

预测趋势线的构成：
预测趋势线由两个点确定：
点1（固定点）：历史枢轴点（波峰或波谷） - 已知的时间+价格
点2（动态点）：当前计算的移动平均值 - 本函数计算的结果

移动平均类型：
MODE_LWMA：线性加权移动平均，对近期价格赋予更高权重
PRICE_HIGH：波峰时使用最高价，捕捉上升动量
PRICE_LOW：波谷时使用最低价，捕捉下降动量


技术分析原理：
为什么使用1.1倍周期？
   缓冲作用：避免周期过短导致的信号抖动
   平滑效果：使趋势线更加平滑稳定
   适应性：根据市场波动自动调整灵敏度

为什么使用LWMA？
   响应速度：LWMA对近期价格更敏感，能快速反应趋势变化
   趋势捕捉：相比SMA，LWMA能更好地捕捉新兴趋势
   噪声过滤：仍然保持一定的平滑性，过滤短期噪声

价格选择逻辑：
   波峰趋势线：使用PRICE_HIGH，关注上升动能
   波谷趋势线：使用PRICE_LOW，关注下降动能

这个函数是预测趋势线系统的核心计算组件，它通过智能的移动平均计算，
为历史枢轴点提供动态的第二个端点，从而生成有预测意义的趋势线。
这种基于历史波动自适应调整周期的设计，使预测趋势线既保持了技术分析的严谨性，又具备了动态适应的灵活性。

 */
double FTLMng_FindSecondpoint(int indexBar, int timePivot, int waveType) {
    // 第一步：参数有效性检查
    // 确保当前K线索引和枢轴点时间有效
    if (indexBar == 0 || timePivot == 0)
        return (0);  // 参数无效，直接返回0

    // 第二步：计算移动平均线的周期
    // 将枢轴点时间转换为对应的K线索引位置
    // FALSE表示如果找不到精确时间就返回-1
    // 枢轴点到现在的K线数量
    int periodMa = iBarShift(NULL, 0, timePivot, FALSE);
    
    // 第三步：初始化移动平均值变量
    double valueMA = 0;

    // 第四步：根据波浪类型计算不同的移动平均值
    if (waveType == 1) {
        // 波峰情况：使用最高价的线性加权移动平均
        // 计算从枢轴点到当前K线的距离，并增加10%的缓冲
        valueMA = iMA(NULL, 0, 1.1 * periodMa, 0, MODE_LWMA, PRICE_HIGH, indexBar);
    }
    if (waveType == 2) {
        // 波谷情况：使用最低价的线性加权移动平均  
        // 同样使用1.1倍距离作为移动平均周期
        valueMA = iMA(NULL, 0, 1.1 * periodMa, 0, MODE_LWMA, PRICE_LOW, indexBar);
    }
    
    // 第五步：返回计算得到的移动平均值作为趋势线第二个点
    return (valueMA);
}

/**
 * 趋势线管理主函数 - 自动趋势线绘制的核心逻辑
 * 该函数负责识别符合条件的波浪点对，并自动绘制支撑线和阻力线
 * 通过连接相同类型的波浪点（波峰连波峰，波谷连波谷）形成趋势线
 * 
 * @param arrayAllWavesInfo 波浪信息数组，包含所有已识别的波浪数据
 * @param asa_4 趋势线名称数组，用于管理已绘制的趋势线对象
 * @param foundWave 波浪发现标志，在特定情况下会重置该标志
 * @return 始终返回0


趋势线绘制逻辑流程：
获取波浪总数
↓
检查是否有波浪数据？
├─ 无 → 直接返回
↓ 有
获取最新波浪类型
↓
检查波浪类型有效？
├─ 无效 → 直接返回
↓ 有效
寻找前一个相同类型波浪
↓
找到前一个波浪？
├─ 未找到 → 直接返回
↓ 找到
获取两个波浪的价格和时间
↓
检查价格和时间有效性？
├─ 无效 → 直接返回
↓ 有效
检查最小K线间隔要求？
├─ 不满足 → 直接返回
↓ 满足
根据波浪类型判断趋势方向
↓
符合趋势条件？
├─ 不符合 → 重置foundWave
↓ 符合
绘制趋势线



趋势线绘制的技术分析原理：
有效的趋势线特征：
   阻力线：连接连续下降的波峰点
   支撑线：连接连续上升的波谷点
   时间跨度：波浪点之间有足够的间隔
   趋势确认：价格在趋势线处表现出反应

无效的情况（foundWave被重置）：
   波峰创新高（阻力线失效）
   波谷创新低（支撑线失效）
   波浪点过于接近（技术意义不大）

 */
int TLMng_Main(double& arrayAllWavesInfo[][6], string& asa_4[], int &foundWave) {
    // 局部变量声明
    int waveType;           // 当前波浪类型（1=波峰，2=波谷）
    double ld_24;           // 当前波浪的枢轴点价格
    double ld_32;           // 前一个相同类型波浪的枢轴点价格
    int li_40;              // 当前波浪的枢轴点时间
    int li_44;              // 前一个相同类型波浪的枢轴点时间
    int l_shift_48;         // 当前波浪的K线偏移量
    int l_shift_52;         // 前一个波浪的K线偏移量
    
    // 第一步：获取波浪总数并检查是否有波浪数据
    int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
    if (waveCount > 0)
        waveType = WAMng_WaveType(arrayAllWavesInfo, waveCount);  // 获取最新波浪类型
    
    // 第二步：检查波浪类型是否有效
    if (waveType > 0) {
        // 第三步：寻找前一个相同类型的波浪
        // 例如：如果当前是波峰，就寻找前一个波峰
        int index2PreviousSameWaveType = WAMng_LookPrivWaveSameType(arrayAllWavesInfo, waveType, waveCount);
        
        // 第四步：检查是否找到前一个相同类型的波浪
        if (index2PreviousSameWaveType > 0) {
            // 第五步：获取两个波浪的枢轴点价格
            ld_24 = WAMng_GetWavePiv(arrayAllWavesInfo, waveCount);                    // 当前波浪价格
            ld_32 = WAMng_GetWavePiv(arrayAllWavesInfo, index2PreviousSameWaveType);   // 前一个波浪价格
            
            // 价格有效性检查
            if (ld_24 == 0.0 || ld_32 == 0.0)
                return (0);
            
            // 第六步：获取两个波浪的枢轴点时间
            li_40 = WAMng_GetWavePivBar(arrayAllWavesInfo, waveCount);                 // 当前波浪时间
            li_44 = WAMng_GetWavePivBar(arrayAllWavesInfo, index2PreviousSameWaveType);// 前一个波浪时间
            
            // 时间有效性检查
            if (li_40 == 0 || li_44 == 0)
                return (0);
            
            // 第七步：检查最小枢轴点差异（避免波浪点过于接近）避免在过于接近的波浪点之间绘制无意义的趋势线
            if (g_Line_MinPivotDifferentIgnore > 0) {
                // 将时间转换为K线偏移量
                l_shift_48 = iBarShift(NULL, 0, li_40, FALSE);  // 当前波浪的K线位置
                l_shift_52 = iBarShift(NULL, 0, li_44, FALSE);  // 前一个波浪的K线位置
                
                // 检查两个波浪之间的K线数量是否达到最小要求
                // 如果两个波浪之间的K线数量太少，不绘制趋势线
                if (l_shift_52 - l_shift_48 <= g_Line_MinPivotDifferentIgnore)
                    return (0);  // 波浪点过于接近，不绘制趋势线
            }
            // 示例：g_Line_MinPivotDifferentIgnore = 5
            // 如果两个波峰之间只有3根K线，不绘制阻力线
            // 确保趋势线有足够的时间跨度，提高技术分析价值
            
            
            // 第八步：根据波浪类型进行趋势线绘制判断
            if (waveType == 1) {
                // 波峰类型（阻力线）的绘制条件：当前波峰低于前一个波峰（下降趋势）
                if (ld_24 < ld_32)
                    // 符合下降趋势，绘制阻力线
                    TLMng_BuidLine(asa_4, waveType, ld_32, li_44, ld_24, li_40);
                else
                    // 当前波峰更高，不符合下降趋势，重置波浪标志
                    foundWave = 0;
            } else {
                // 波谷类型（支撑线）的绘制条件：当前波谷高于前一个波谷（上升趋势）
                if (waveType == 2) {
                    if (ld_24 > ld_32)
                        // 符合上升趋势，绘制支撑线
                        TLMng_BuidLine(asa_4, waveType, ld_32, li_44, ld_24, li_40);
                    else
                        // 当前波谷更低，不符合上升趋势，重置波浪标志
                        foundWave = 0;
                }
            }
        }
    }
    return (0);
}

void TLMng_Init(int ResColor, int SupColor, int lineStyle, int lineWidth, double lineExt, int lineInMemory, string lineName, int MinPivotDifferentIgnore) {
	g_Color_Resistance = ResColor;
	g_Color_Support = SupColor;
	if (g_Line_Width <= 1) {
		g_Line_Style = lineStyle;
		g_Line_Width = 1;
	} else {
		g_Line_Style = 0;
		g_Line_Width = lineWidth;
	}
	if (lineExt < 1.0)
		g_Line_Ext = 1;
	else
		g_Line_Ext = lineExt;
	g_Line_InMemory = lineInMemory;
	g_Line_Name = lineName;
	g_Line_MinPivotDifferentIgnore = MinPivotDifferentIgnore;
}

/**
 * 构建趋势线对象 - 趋势线绘制的核心函数
 * 该函数创建并配置趋势线对象，包括线条样式、颜色、延长和修正等高级功能
 * 负责将波浪分析结果可视化为图表上的趋势线
 * 
 * @param asa_0 趋势线名称数组引用，用于管理已绘制的趋势线
 * @param time4Search 波浪类型（1=波峰/阻力，2=波谷/支撑）
 * @param ad_8 第一个点的价格（历史波浪点价格）
 * @param a_datetime_16 第一个点的时间（历史波浪点时间）
 * @param ad_20 第二个点的价格（当前波浪点价格）
 * @param a_datetime_28 第二个点的时间（当前波浪点时间）

趋势线构建完整流程：
构建唯一名称 → 确定线条类型 → 创建对象 → 设置基本属性 → 
设置颜色样式 → 延长处理 → 位置修正 → 数量管理 → 重绘图表

名称格式： 前缀_Asys_AutoTL_时间框架_类型 - 序号
   示例：
      HTL_Asys_AutoTL_5_Res - 15 （5分钟图阻力线第15号）
      LTL_Asys_AutoTL_60_Sup - 8 （1小时图支撑线第8号）
      Def_Asys_AutoTL_240_Res - 3 （4小时图默认阻力线第3号）
 */
void TLMng_BuidLine(string& asa_0[], int time4Search, double ad_8, int a_datetime_16, double ad_20, int a_datetime_28) {
    // 局部变量声明
    string ls_48;           // 趋势线类型标识（"Sup"或"Res"）
    int l_datetime_56;      // 延长点的时间坐标
    double ld_60;           // 延长点的价格坐标
    int l_count_68;         // 修正循环计数器
    double ld_72;           // 线条修正值
    
    // 第一步：构建趋势线名称基础部分
    string ls_32 = "";
    if (g_Line_Name == "")
        ls_32 = "Def";      // 默认名称前缀
    else
        ls_32 = g_Line_Name; // 用户自定义名称前缀
    
    // 构建唯一趋势线名称：前缀 + 时间框架 + 计数
    string l_name_40 = ls_32 + "_Asys_AutoTL_" + Period() + "_";
    g_count_TrendLine++;    // 趋势线计数器递增
    
    // 第二步：确定趋势线类型（支撑线或阻力线）
    if (time4Search == 2)
        ls_48 = "Sup";      // 支撑线（Support）
    else
        ls_48 = "Res";      // 阻力线（Resistance）
    
    // 完成趋势线名称构建：基础名称 + 类型 + 序号
    l_name_40 = l_name_40 + ls_48 + " - " + g_count_TrendLine;
    
    // 第三步：创建趋势线对象
    if (ObjectCreate(l_name_40, OBJ_TREND, 0, a_datetime_16, NormalizeDouble(ad_8, Digits), a_datetime_28, NormalizeDouble(ad_20, Digits))) {
        
        // 第四步：配置趋势线基本属性
        ObjectSet(l_name_40, OBJPROP_RAY, FALSE);  // 设置为线段（非射线）
        
        // 第五步：设置趋势线颜色（根据类型）
        if (ls_48 == "Sup")
            ObjectSet(l_name_40, OBJPROP_COLOR, g_Color_Support);     // 支撑线颜色
        else {
            if (ls_48 == "Res")
                ObjectSet(l_name_40, OBJPROP_COLOR, g_Color_Resistance); // 阻力线颜色
            else
                ObjectSet(l_name_40, OBJPROP_COLOR, Red);             // 错误情况使用红色
        }
        
        // 第六步：设置线条样式和宽度
        ObjectSet(l_name_40, OBJPROP_STYLE, g_Line_Style);  // 线型（实线、虚线等）
        ObjectSet(l_name_40, OBJPROP_WIDTH, g_Line_Width);  // 线宽
        
        // 第七步：趋势线延长处理（如果启用延长功能）
        if (g_Line_Ext > 1.0) {
            l_datetime_56 = 0;
            ld_60 = 0;
            
            // 计算趋势线延长点坐标
            TLMng_CountExt(g_Line_Ext, a_datetime_16, NormalizeDouble(ad_8, Digits), 
                          a_datetime_28, NormalizeDouble(ad_20, Digits), 
                          l_datetime_56, ld_60);
            
            // 将趋势线终点移动到延长点
            ObjectMove(l_name_40, 1, l_datetime_56, ld_60);
            
            // 第八步：趋势线位置修正（确保精确对齐）
            l_count_68 = 0;
            ld_72 = TLMng_CorrectLine(l_name_40, a_datetime_28, NormalizeDouble(ad_20, Digits));
            
            // 循环修正直到位置准确或达到最大尝试次数
            while (ld_72 != 0.0) {
                ld_60 += ld_72;  // 应用修正值
                ObjectMove(l_name_40, 1, l_datetime_56, ld_60);  // 更新延长点位置
                ld_72 = TLMng_CorrectLine(l_name_40, a_datetime_28, NormalizeDouble(ad_20, Digits)); // 重新检查
                l_count_68++;
                
                // 防止无限循环，最多尝试20次
                if (l_count_68 > 20)
                    break;
            }
        }
        
        // 第九步：管理趋势线数量（避免图表过于拥挤）
        TLMng_CheckNumTL(asa_0, l_name_40, g_Line_InMemory);
        
        // 第十步：强制重绘图表对象
        ObjectsRedraw();
    }
}

double TLMng_CorrectLine(string a_name_0, int appliedPrice, double ad_12) {
	if (a_name_0 == "" || appliedPrice == 0)
		return (0);
	GetLastError();
	double ld_20 = ObjectGetValueByShift(a_name_0, iBarShift(NULL, 0, appliedPrice, TRUE));
	if (GetLastError() > 0/* NO_ERROR */)
		return (0);
	double ld_28 = ld_20 - ad_12;
	if (IsInChanel(ld_28, 0, 2.0 * Point) == 1)
		return (0);
	return (-1.0 * ld_28);
}

void TLMng_CheckNumTL(string &asa_0[], string as_4, int ai_12) {
	if (as_4 == "" || ai_12 < 0)
		return;
	if (ArraySize(asa_0) + 1 > ai_12) {
		if (!ObjectDelete(asa_0[0]))
			Print("Object Delete failure.", asa_0[0], " error code: ", GetLastError());
		ArrayCopy(asa_0, asa_0, 0, 1);
		asa_0[ArraySize(asa_0) - 1] = as_4;
		return;
	}
	ArrayResize(asa_0, ArraySize(asa_0) + 1);
	asa_0[ArraySize(asa_0) - 1] = as_4;
}

void TLMng_DeleteAllLines() {
	int li_0 = ArrayRange(gsa_440, 0);
	if (li_0 > 0) {
		for (int i = 0; i <= li_0 - 1; i++)
			if (ObjectFind(gsa_440[i]) > -1)
				ObjectDelete(gsa_440[i]);
	}
	ArrayResize(gsa_440, 0);
	li_0 = 0;
	li_0 = ArrayRange(gsa_444, 0);
	if (li_0 > 0) {
		for (i = 0; i <= li_0 - 1; i++)
			if (ObjectFind(gsa_444[i]) > -1)
				ObjectDelete(gsa_444[i]);
	}
	ArrayResize(gsa_444, 0);
}

void TLMng_DeleteLinesCurrentTF() {
	string l_name_4;
	string lsa_12[];
	int l_objs_total_0 = ObjectsTotal();
	if (l_objs_total_0 != 0) {
		for (int i = 0; i <= l_objs_total_0 - 1; i++) {
			l_name_4 = ObjectName(i);
			if (StringFind(l_name_4, StringConcatenate("Asys_AutoTL_", Period())) > -1) {
				ArrayResize(lsa_12, ArraySize(lsa_12) + 1);
				lsa_12[ArraySize(lsa_12) - 1] = l_name_4;
			}
		}
		if (ArraySize(lsa_12) > 0) {
			for (i = 0; i <= ArraySize(lsa_12) - 1; i++)
				if (ObjectFind(lsa_12[i]) > -1)
					ObjectDelete(lsa_12[i]);
		}
	}
}

void TLMng_DeleteLinesCurrentInd() {
	string l_name_4;
	string lsa_12[];
	int l_objs_total_0 = ObjectsTotal();
	if (l_objs_total_0 != 0) {
		for (int i = 0; i <= l_objs_total_0 - 1; i++) {
			l_name_4 = ObjectName(i);
			if (StringFind(l_name_4, "Asys_AutoTL") > -1) {
				ArrayResize(lsa_12, ArraySize(lsa_12) + 1);
				lsa_12[ArraySize(lsa_12) - 1] = l_name_4;
			}
		}
		if (ArraySize(lsa_12) > 0) {
			for (i = 0; i <= ArraySize(lsa_12) - 1; i++)
				if (ObjectFind(lsa_12[i]) > -1)
					ObjectDelete(lsa_12[i]);
		}
	}
}

/**
 * 趋势线延长点计算函数
 * 该函数根据延长系数计算趋势线的延长点坐标（时间和价格）
 * 用于将趋势线向前延伸一定的比例，以便显示未来的可能支撑/阻力位
 * 
 * @param ad_0 延长系数，决定趋势线延长的倍数（如1.5表示延长50%）
 * @param appliedPrice 趋势线第一个点的时间（起点时间）
 * @param ad_12 趋势线第一个点的价格（起点价格）
 * @param ai_20 趋势线第二个点的时间（终点时间）
 * @param ad_24 趋势线第二个点的价格（终点价格）
 * @param ai_32 输出参数：延长点的时间坐标
 * @param ad_36 输出参数：延长点的价格坐标

趋势线延长公式：
延长点价格 = 终点价格 ± (延长系数 × 价格变化率 × 原K线数量)

价格变化率计算：
价格变化率 = |终点价格 - 起点价格| / K线数量

可视化效果：
原始趋势线：起点A ──────────→ 终点B
延长趋势线：起点A ──────────→ 终点B ──────→ 延长点C

这个函数是趋势线分析中的重要工具，它通过数学计算将历史趋势线向前延伸，
为交易者提供未来可能的支撑阻力位参考。
延长系数的灵活性允许用户根据不同的交易风格和市场条件调整预测的范围。
 */
void TLMng_CountExt(double ad_0, int appliedPrice, double ad_12, int ai_20, double ad_24, int &ai_32, double &ad_36) {
    // 将趋势线起点时间转换为K线索引
    // FALSE表示如果找不到精确时间就返回-1
    int l_shift_44 = iBarShift(NULL, 0, appliedPrice, FALSE);
    
    // 将趋势线终点时间转换为K线索引
    int l_shift_48 = iBarShift(NULL, 0, ai_20, FALSE);
    
    // 计算趋势线起点和终点之间的K线数量（时间跨度）
    int li_52 = l_shift_44 - l_shift_48;
    
    // 计算延长后的K线数量，使用延长系数
    // MathRound进行四舍五入，Double2Int转换为整数
    int li_56 = Double2Int(MathRound(li_52 * ad_0));
    
    // 计算趋势线的价格跨度（起点和终点的价格差绝对值）
    double ld_60 = MathAbs(ad_24 - ad_12);
    
    // 如果延长后的K线数量为0，延长点价格就是终点价格
    if (li_56 == 0)
        ad_36 = ad_24;
    else {
        // 根据趋势方向计算延长点价格
        
        // 情况1：上升趋势（终点价格高于起点价格）
        if (ad_24 > ad_12)
            // 延长点价格 = 终点价格 + (延长K线数 × 单位K线价格变化)
            // 单位K线价格变化 = 总价格差 / 总K线数
            ad_36 = NormalizeDouble(ad_24 + li_56 * ld_60 / li_52, Digits);
        
        // 情况2：下降趋势（终点价格低于起点价格）  
        if (ad_24 < ad_12)
            // 延长点价格 = 终点价格 - (延长K线数 × 单位K线价格变化)
            ad_36 = NormalizeDouble(ad_24 - li_56 * ld_60 / li_52, Digits);
    }
    
    // 计算延长点的时间坐标
    // Time[l_shift_48]：趋势线终点的时间
    // 60 * Period()：每个K线的秒数（1分钟图=60，5分钟图=300等）
    // li_56：延长后的K线数量
    ai_32 = Time[l_shift_48] + 60 * Period() * li_56;
}

/**
 * 寻找前一个相同类型的波浪索引
 * 该函数从当前波浪开始向前（向历史数据方向）搜索，寻找与当前波浪类型相同的最近一个波浪
 * 用于趋势线绘制时连接相同类型的波浪点
 * 
 * @param arrayAllWavesInfo 波浪信息二维数组，包含所有已识别的波浪数据
 * @param currentWaveType 当前波浪的类型（1=波峰/上涨波浪，2=波谷/下跌波浪）
 * @param startIndex 开始搜索的波浪索引（通常是当前最新波浪的索引）
 * @return 找到的前一个相同类型波浪的索引，如果未找到（没有相同类型的波浪）返回0
 
搜索逻辑示意图：
波浪数组：[波浪1, 波浪2, 波浪3, 波浪4, 波浪5] ← 当前波浪
索引：     1      2      3      4      5     ← startIndex=5

搜索过程（currentWaveType=1）：
检查波浪4 → 类型=2 → 不匹配 → 继续
检查波浪3 → 类型=1 → 匹配! → 返回索引3

这个函数是趋势线自动绘制系统的核心组件，它通过智能地寻找历史中相同类型的波浪点，
为绘制有意义的支撑线和阻力线提供了基础。
这种"同类相连"的原则确保了趋势线能够准确反映市场的真实动态支撑和阻力水平。
 */
int WAMng_LookPrivWaveSameType(double& arrayAllWavesInfo[][6], int currentWaveType, int startIndex) {

    // 参数有效性检查
    // 如果当前波浪类型无效或起始索引为0，直接返回0
    if (currentWaveType <= 0 || startIndex == 0) {
        return (0);
    }

    // 初始化搜索变量
    int index2PreviousSameWaveType = startIndex - 1;  // 从当前波浪的前一个波浪开始搜索
    int waveType;                                     // 临时存储检查的波浪类型
    bool found = FALSE;                               // 搜索完成标志
    
    // 循环搜索前一个相同类型的波浪
    while (found == FALSE) {
        // 获取指定索引位置的波浪类型
        waveType = WAMng_WaveType(arrayAllWavesInfo, index2PreviousSameWaveType);
        
        // 如果找到有效波浪类型（1或2）
        if (waveType > 0) {
            // 检查波浪类型是否与当前波浪类型相同
            if (waveType == currentWaveType) {
                found = TRUE;  // 找到匹配的波浪，设置完成标志
                break;         // 跳出循环
            }
        }
        
        // 向前移动一个波浪（向更早的历史数据）
        index2PreviousSameWaveType--;
        
        // 边界检查：如果索引小于0，说明已搜索到数组开头
        if (index2PreviousSameWaveType < 0)
            found = TRUE;  // 强制结束搜索
    }

    // 检查是否找到有效的相同类型波浪
    if (index2PreviousSameWaveType > 0) {
        // 返回找到的波浪索引
        return (index2PreviousSameWaveType);
    }

    // 未找到相同类型的波浪，返回0
    return (0);
}

/**
 * 获取指定索引位置的波浪类型
 * 该函数从波浪信息数组中检索特定波浪索引对应的波浪类型
 * 提供了对波浪数组的安全访问和边界检查
 * 
 * @param arrayAllWavesInfo 波浪信息二维数组，包含所有已识别的波浪数据
 * @param index 要查询的波浪索引（从1开始计数）
 * @return 波浪类型：1=波峰/上涨波浪，2=波谷/下跌波浪，-1=无效索引
 */
int WAMng_WaveType(double& arrayAllWavesInfo[][6], int index) {
    // 获取当前波浪数组中的波浪总数
    int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
    
    // 索引有效性检查
    // 波浪索引从1开始，所以必须满足：1 ≤ index ≤ waveCount
    if (index < 1 || index > waveCount)
        return (-1);  // 索引超出有效范围，返回错误代码
    
    // 返回指定波浪索引的波浪类型
    // 数组索引从0开始，所以需要 index - 1
    // [0] 表示波浪类型在数组中的列位置（第0列存储波浪类型）
    return (arrayAllWavesInfo[index - 1][0]);
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
 * 获取指定波浪的枢轴点价格
 * 该函数从波浪信息数组中检索特定波浪的枢轴点价格（波峰或波谷的价格）
 * 提供了对波浪价格数据的安全访问和边界检查
 * 
 * @param arrayAllWavesInfo 波浪信息二维数组，包含所有已识别的波浪数据
 * @param index 要查询的波浪索引（从1开始计数）
 * @return 指定波浪的枢轴点价格，如果索引无效返回0.0
 */
double WAMng_GetWavePiv(double& arrayAllWavesInfo[][6], int index) {
    // 获取当前波浪数组中的波浪总数
    int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
    
    // 索引有效性检查
    // 确保请求的波浪索引在有效范围内：1 ≤ index ≤ waveCount
    if (index < 1 || index > waveCount)
        return (0.0);  // 索引无效，返回0.0作为错误指示
    
    // 返回指定波浪索引的枢轴点价格
    // 数组索引从0开始，所以需要 index - 1
    // [3] 表示枢轴点价格在数组中的列位置（第3列存储价格）
    return (arrayAllWavesInfo[index - 1][3]);
}

/**
 * 获取指定波浪的枢轴点时间
 * 该函数从波浪信息数组中检索特定波浪的枢轴点发生时间（波峰或波谷的时间戳）
 * 提供了对波浪时间数据的安全访问和边界检查
 * 
 * @param arrayAllWavesInfo 波浪信息二维数组，包含所有已识别的波浪数据
 * @param index 要查询的波浪索引（从1开始计数）
 * @return 指定波浪的枢轴点时间（Unix时间戳），如果索引无效返回0
 */
int WAMng_GetWavePivBar(double& arrayAllWavesInfo[][6], int index) {
    // 获取当前波浪数组中的波浪总数
    int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
    
    // 索引有效性检查
    // 确保请求的波浪索引在有效范围内：1 ≤ index ≤ waveCount
    if (index < 1 || index > waveCount)
        return (0);  // 索引无效，返回0作为错误指示
    
    // 返回指定波浪索引的枢轴点时间
    // 数组索引从0开始，所以需要 index - 1
    // [5] 表示枢轴点时间在数组中的列位置（第5列存储时间戳）
    return (arrayAllWavesInfo[index - 1][5]);
}

/**
 * 新波浪管理器 - 波浪识别和管理的核心函数
 * 该函数负责协调整个波浪识别流程，包括波浪检测、信号绘制、警报触发和趋势线预测
 * 是波浪分析系统的总调度中心
 * 
 * @param indexBar 当前处理的K线索引位置
 * @param periodSMA 简单移动平均线的计算周期
 * @param periodLWMA 线性加权移动平均线的计算周期
 * @param arrayAllWavesInfo 波浪信息数组，用于存储所有识别到的波浪数据
 * @param SemaBuffer 信号旗缓冲区，用于在图表上绘制波浪信号
 * @param time_F_F_Zero 第一个零点时间（波浪开始时间）
 * @param time_F_S_Zero 第二个零点时间（波浪结束时间）
 * @param waveType 波浪类型标识
 * @param foundWave 波浪发现标志
 * @param drawPivotSemafor 是否绘制枢轴点信号旗
 * @param pivotSemaforDrawOffset 信号旗绘制偏移量
 * @param pivotTextAlarm 是否启用文本警报
 * @param pivotSoundAlarm 声音警报文件名称
 * @param needDrawForecastHighTrendLine 是否需要绘制预测趋势线
 * @return 始终返回0

这个函数是整个波浪识别系统的"大脑"，它协调了波浪检测、信号显示、用户警报和趋势预测的所有功能。
通过精心的状态管理和流程控制，确保了波浪分析的准确性、实时性和用户友好性。

波浪识别完整流程：
初始化波浪状态
↓
检查第一个零点？
├─ 未找到 → 寻找第一个零点 → 返回
↓ 已找到
检查预测趋势线重绘？
├─ 需要 → 重绘预测趋势线
↓
检查第二个零点？
├─ 未找到 → 寻找第二个零点 → 检查结果？
    ├─ 仍未找到 → 返回
    ↓ 找到
↓ 已找到
添加完整波浪到数组
↓
绘制信号旗和触发警报
↓
绘制预测趋势线
↓
准备下一个波浪状态
↓
保存波浪状态并返回



参数详细说明：
参数组	 参数	                                                说明
核心参数	indexBar, periodSMA, periodLWMA	                      波浪检测的计算参数
数据存储	arrayAllWavesInfo, SemaBuffer	                         波浪数据和信号输出
状态管理	time_F_F_Zero, time_F_S_Zero, waveType, foundWave	    波浪识别状态
显示控制	drawPivotSemafor, pivotSemaforDrawOffset	             信号旗绘制设置
警报设置	pivotTextAlarm, pivotSoundAlarm	                      用户警报配置
趋势线	 needDrawForecastHighTrendLine	                       预测趋势线控制

 */
int NewWave_Manager(int indexBar
                  , int periodSMA
                  , int periodLWMA
                  , double &arrayAllWavesInfo[][6]
                  , double &SemaBuffer[]
                  , int &time_F_F_Zero
                  , int &time_F_S_Zero
                  , int &waveType
                  , int &foundWave
                  , bool drawPivotSemafor
                  , int pivotSemaforDrawOffset
                  , int pivotTextAlarm
                  , string pivotSoundAlarm
                  , int needDrawForecastHighTrendLine) {

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

	// 第三步：如果需要且已绘制预测趋势线，进行重绘
	// 确保预测趋势线随最新价格更新
	if (needDrawForecastHighTrendLine == 1 && ForecastHighTrendLine == TRUE && g_ReDrawed == TRUE) {
		FTLMng_ReDraw(indexBar);
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

	// 第十步：绘制预测趋势线（如果启用）
	if (needDrawForecastHighTrendLine == 1 && ForecastHighTrendLine == TRUE) {
		FTLMng_Main(indexBar, timePivot, arrayAllWavesInfo[wavesCount - 1][3], g_WaveType);
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

/**
 * 波浪管理器初始化函数 - 加载波浪状态到全局变量
 * 该函数将调用方保存的波浪状态加载到全局波浪管理变量中
 * 用于在波浪管理过程开始时恢复之前的波浪分析状态
 * 
 * @param time_F_F_Zero 第一个零点时间，从调用方传递的波浪起始点时间
 * @param time_F_S_Zero 第二个零点时间，从调用方传递的波浪结束点时间
 * @param waveType 波浪类型，从调用方传递的当前波浪方向（1=上涨，2=下跌）
 
与DeInit_Wave_Manager的对称关系：
// 状态管理的完整闭环：
// 
//  调用方变量  ←→  Init/DeInit  ←→  全局变量
//    (持久存储)      (桥梁作用)      (计算使用)
//
// Init:    调用方变量  →  全局变量  (加载状态)
// DeInit:  全局变量  →  调用方变量  (保存状态)

这个函数是波浪管理器的"状态加载器"，通过与DeInit_Wave_Manager的配合，实现了波浪分析状态的持久化和连续性。
这种设计模式确保了即使在MT4指标频繁重新初始化的环境下，波浪分析过程也能够正确地从上次停止的地方继续，
而不是每次都从头开始。


 */
void Init_Wave_Manager(int time_F_F_Zero, int time_F_S_Zero, int waveType) {
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

/**
 * 波浪管理器反初始化函数 - 保存波浪状态到调用方变量
 * 该函数将全局波浪管理变量中的当前状态保存到调用方的局部变量中
 * 用于在波浪管理过程结束时传递最新的波浪状态信息
 * 
 * @param time_F_F_Zero 引用参数：用于接收第一个零点时间
 * @param time_F_S_Zero 引用参数：用于接收第二个零点时间  
 * @param waveType 引用参数：用于接收当前波浪类型
 */
void DeInit_Wave_Manager(int &time_F_F_Zero, int &time_F_S_Zero, int &waveType) {
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

/*
波浪识别的完整时序：
   1. F_F_Zero：找到波浪起点（第一个零点）
   2. F_S_Zero：找到波浪终点（第二个零点）
   3. FindPivot：在起点终点间寻找波峰/波谷
   4. Add_Wave：存储完整波浪信息
*/

/**
 * 寻找第一个零点（F_F_Zero） - 波浪起点检测函数
 * 该函数负责识别新波浪的起始点（第一个零点），即趋势转折的开始位置
 * 第一个零点是波浪分析的起点，标志着新趋势方向的开始
 * 
 * @param periodSMA 简单移动平均线的计算周期
 * @param periodLWMA 线性加权移动平均线的计算周期
 * @param shiftBarIndex 开始搜索的K线索引位置（0=当前K线，1=前一根K线）
 
 
 这个函数是整个波浪识别系统的"启动器"，它确定了新波浪的起始位置和方向，为后续的波浪分析奠定了基础。
 通过双重搜索策略（直接搜索零点或先找波浪再找零点），确保了在各种市场情况下都能可靠地识别波浪起点。
 
 
   第一个零点的概念：
   第一个零点是波浪理论中的关键概念：
      代表趋势转折的起始点
      是新波浪开始的标志
      通常是SMA和LWMA交叉或接近的区域
 
开始
↓
检查数据是否充足
├─ 不足 → 直接返回
↓ 充足
获取当前K线波浪类型
↓
初始化全局变量
↓
判断当前是否有明确波浪类型
├─ 有明确类型(1或2) → 向后搜索零点
↓ 无明确类型(0) → 向后搜索第一个波浪 → 再搜索零点
↓
检查是否找到有效零点
├─ 未找到 → 直接返回
↓ 找到
设置第一个零点和波浪类型
 
 */
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

        double timeFindZeroFromShift = 0;  // 存储找到的零点时间
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

/**
 *
 * index2ShiftBar:第几根K线的值(iMA函数的最后一个参数shift)
 */
/**
 * 寻找第二个零点（F_S_Zero）
 * 该函数在已确定第一个零点和波浪类型的基础上，寻找波浪的结束点（第二个零点）
 * 第二个零点标志着当前波浪的完成和新波浪的开始
 * 
 * @param periodSMA 简单移动平均线的计算周期
 * @param periodLWMA 线性加权移动平均线的计算周期
 * @param globalWaveType 全局波浪类型（从第一个零点确定的波浪方向）
 * @param index2ShiftBar 当前分析的K线索引位置
 
 
   第二个零点的概念：
   在波浪理论中，一个完整的波浪包含：
      第一个零点：波浪的起点（趋势开始点）
      枢轴点：波浪的极值点（波峰或波谷）
      第二个零点：波浪的终点（趋势结束点）
 
 开始
  ↓
获取当前K线的波浪类型
  ↓
检查前置条件是否满足
  ├─ 不满足 → 直接返回
  ↓ 满足
检查当前是否为零点区域
  ├─ 是 → 重置第二个零点并返回
  ↓ 否
检查波浪类型是否相同
  ├─ 是 → 重置第二个零点并返回  
  ↓ 否
设置当前时间为第二个零点
 
 */
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
double ChMnr_FindZeroFromShift(int periodSMA, int periodLWMA, int &startIndexShiftBar) {
    int count = 0;                          // 搜索计数器，记录向后搜索的K线数量
    double timeFindZeroFromShift = -99999;  // 存储找到的零点时间，初始化为错误值
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
 * 添加新波浪信息到波浪数组
 * 该函数将检测到的波浪信息（包括时间范围、类型和枢轴点）存储到二维数组中
 * 用于后续的趋势线绘制和波浪分析
 * 
 * @param time_F_F_Zero 第一个零点时间（波浪起始时间）
 * @param time_F_S_Zero 第二个零点时间（波浪结束时间）
 * @param waveType 波浪类型：1=波峰(上涨波浪)，2=波谷(下跌波浪)
 * @param arrayAllWavesInfo 引用传递的二维数组，用于存储所有波浪信息
 * @return 始终返回0，表示函数执行完成
 
 函数执行流程：
   1.数组扩容：dimension1++ → ArrayResize()
   2.基本信息存储：存储波浪类型和时间范围（索引0-2）
   3.前序波浪查询：获取前一个波浪的枢轴时间用于优化搜索
   4.枢轴点检测：调用FindPivot()寻找关键转折点
   5.详细信息存储：如果找到枢轴点，存储其索引、时间和价格（索引3-5）
 
 波浪信息数组 arrayAllWavesInfo[][6] 的列结构：
 索引	数据类型     描述                         示例
   0     int         波浪类型：1=波峰，2=波谷       1
   1     int         第一个零点时间（波浪开始）     1672531200
   2     int         第二个零点时间（波浪结束）     1672534800
   3     double      枢轴点价格                     1.12345
   4     int         枢轴点K线索引                  125
   5     int         枢轴点时间                     1672533000

 
 */
int Add_Wave(int time_F_F_Zero, int time_F_S_Zero, int waveType, double &arrayAllWavesInfo[][6]) {
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
    int time_Pre_Pivot = 0;
    if (dimension1 - 2 >= 0)  // 确保存在前一个波浪（当前波浪索引-2 >= 0）
        time_Pre_Pivot = arrayAllWavesInfo[dimension1 - 2][5];  // 索引5存储前一个波浪的枢轴时间
        
    // 寻找当前波浪的枢轴点（波峰或波谷的时间）
    // 参数说明：
    // time_F_F_Zero - 搜索范围结束时间
    // time_F_S_Zero - 搜索范围开始时间  
    // waveType - 波浪类型，决定寻找波峰还是波谷
    // time_Pre_Pivot - 前一个枢轴点时间，用于优化搜索范围
    int timePivot = FindPivot(time_F_F_Zero, time_F_S_Zero, waveType, time_Pre_Pivot);
    
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
 * 寻找枢轴点（波峰或波谷）的时间
 * 该函数在给定的时间范围内寻找最高点或最低点作为枢轴点
 * 
 * @param time_F_F_Zero 第一个零点时间（搜索范围的结束时间）
 * @param time_F_S_Zero 第二个零点时间（搜索范围的开始时间）  
 * @param waveType 波浪类型：1=寻找波峰(高点)，2=寻找波谷(低点)
 * @param time_Pre_Pivot 前一个枢轴点的时间（可选，用于优化搜索范围）
 * @return 返回找到的枢轴点时间，如果找不到返回0
 */
int FindPivot(int time_F_F_Zero, int time_F_S_Zero, int waveType, int time_Pre_Pivot) {
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

int Double2Int(double doubleValue) {
	return (StrToInteger(DoubleToStr(doubleValue, 0)));
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
string PrepareTextAlarm(int timeAlarm, int isTopOrBottom, double price, int ai_16) {
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

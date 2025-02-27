//|Copyright 2018～2019, Gao Zeng.QQ--183947281,mail--soko8@sina.com |

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

int start() {
	if (g_IsInited == FALSE) {
		if (countBars != Bars) {
			deinit();
			Sleep(1000);
			countBars = Bars;
			timeBar0 = 0;
			return (0);
		}
	}
	
	if (g_IsInited == FALSE) {
		g_IsInited = TRUE;
	}
	
	if (timeBar0 == Time[0])
		return (0);
		
	timeBar0 = Time[0];
	int countedBars = IndicatorCounted();
	int uncountedBars = Bars - countedBars;

	for (int i = uncountedBars; 0 < i; i--) {
		NewWave_Manager(    i
		                  , periodHigh7
		                  , periodHigh
		                  , arrayWavesInfoBigPeriod
		                  , HighSemaBuffer
		                  , g_time_F_F_Zero_H
		                  , g_time_F_S_Zero_H
		                  , g_WaveType_H
		                  , g_FoundWave_H
		                  , DrawHighPivotSemafor
		                  , HighPivotSemaforDrawOffset
		                  , HighPivotTextAlarm
		                  , HighPivotSoundAlarm
		                  , 1);
		NewWave_Manager(    i
		                  , periodLow5
		                  , periodLow
		                  , arrayWavesInfoSmallPeriod
		                  , LowSemaBuffer
		                  , g_time_F_F_Zero_L
		                  , g_time_F_S_Zero_L
		                  , g_WaveType_L
		                  , g_FoundWave_L
		                  , DrawLowPivotSemafor
		                  , LowPivotSemaforDrawOffset
		                  , LowPivotTextAlarm
		                  , LowPivotSoundAlarm
		                  , 0);
		NewWave_Manager(    i
		                  , 2
		                  , 5
		                  , arrayWavesInfo25Period
		                  , LowestSemaBuffer
		                  , gi_412
		                  , gi_416
		                  , gi_420
		                  , gi_424
		                  , DrawLowestPivotSemafor
		                  , 3
		                  , 0
		                  , ""
		                  , 0);
		if (g_FoundWave_H && HTL_Draw) {
			TLMng_Init(   HTL_ResColor
			            , HTL_SupColor
			            , HTL_Style
			            , HTL_Width
			            , HTL_Ext
			            , HTL_InMemory
			            , "HTL"
			            , HTL_MinPivotDifferentIgnore);
			TLMng_Main(arrayWavesInfoBigPeriod, gsa_440, g_FoundWave_H);
		}
		if (g_FoundWave_L && LTL_Draw) {
			TLMng_Init(   LTL_ResColor
			            , LTL_SupColor
			            , LTL_Style
			            , LTL_Width
			            , LTL_Ext
			            , LTL_InMemory
			            , "LTL"
			            , LTL_MinPivotDifferentIgnore);
			TLMng_Main(arrayWavesInfoSmallPeriod, gsa_444, g_FoundWave_L);
		}
	}
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

double FTLMng_FindSecondpoint(int indexBar, int timePivot, int waveType) {
	if (indexBar == 0 || timePivot == 0)
		return (0);
	int periodMa = iBarShift(NULL, 0, timePivot, FALSE);
	double valueMA = 0;
	if (waveType == 1)
		valueMA = iMA(NULL, 0, 1.1 * periodMa, 0, MODE_LWMA, PRICE_HIGH, indexBar);
	if (waveType == 2)
		valueMA = iMA(NULL, 0, 1.1 * periodMa, 0, MODE_LWMA, PRICE_LOW, indexBar);
	return (valueMA);
}

int TLMng_Main(double& arrayAllWavesInfo[][6], string& asa_4[], int &foundWave) {
	int waveType;
	double ld_24;
	double ld_32;
	int li_40;
	int li_44;
	int l_shift_48;
	int l_shift_52;
	int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
	if (waveCount > 0)
		waveType = WAMng_WaveType(arrayAllWavesInfo, waveCount);
	if (waveType > 0) {
		int index2PreviousSameWaveType = WAMng_LookPrivWaveSameType(arrayAllWavesInfo, waveType, waveCount);
		if (index2PreviousSameWaveType > 0) {
			ld_24 = WAMng_GetWavePiv(arrayAllWavesInfo, waveCount);
			ld_32 = WAMng_GetWavePiv(arrayAllWavesInfo, index2PreviousSameWaveType);
			if (ld_24 == 0.0 || ld_32 == 0.0)
				return (0);
			li_40 = WAMng_GetWavePivBar(arrayAllWavesInfo, waveCount);
			li_44 = WAMng_GetWavePivBar(arrayAllWavesInfo, index2PreviousSameWaveType);
			if (li_40 == 0 || li_44 == 0)
				return (0);
			if (g_Line_MinPivotDifferentIgnore > 0) {
				l_shift_48 = iBarShift(NULL, 0, li_40, FALSE);
				l_shift_52 = iBarShift(NULL, 0, li_44, FALSE);
				if (l_shift_52 - l_shift_48 <= g_Line_MinPivotDifferentIgnore)
					return (0);
			}
			if (waveType == 1) {
				if (ld_24 < ld_32)
					TLMng_BuidLine(asa_4, waveType, ld_32, li_44, ld_24, li_40);
				else
					foundWave = 0;
			} else {
				if (waveType == 2) {
					if (ld_24 > ld_32)
						TLMng_BuidLine(asa_4, waveType, ld_32, li_44, ld_24, li_40);
					else
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

void TLMng_BuidLine(string& asa_0[], int time4Search, double ad_8, int a_datetime_16, double ad_20, int a_datetime_28) {
	string ls_48;
	int l_datetime_56;
	double ld_60;
	int l_count_68;
	double ld_72;
	string ls_32 = "";
	if (g_Line_Name == "")
		ls_32 = "Def";
	else
		ls_32 = g_Line_Name;
	string l_name_40 = ls_32 + "_Asys_AutoTL_" + Period() + "_";
	g_count_TrendLine++;
	if (time4Search == 2)
		ls_48 = "Sup";
	else
		ls_48 = "Res";
	l_name_40 = l_name_40 + ls_48 + " - " + g_count_TrendLine;
	if (ObjectCreate(l_name_40, OBJ_TREND, 0, a_datetime_16, NormalizeDouble(ad_8, Digits), a_datetime_28, NormalizeDouble(ad_20, Digits))) {
		ObjectSet(l_name_40, OBJPROP_RAY, FALSE);
		if (ls_48 == "Sup")
			ObjectSet(l_name_40, OBJPROP_COLOR, g_Color_Support);
		else {
			if (ls_48 == "Res")
				ObjectSet(l_name_40, OBJPROP_COLOR, g_Color_Resistance);
			else
				ObjectSet(l_name_40, OBJPROP_COLOR, Red);
		}
		ObjectSet(l_name_40, OBJPROP_STYLE, g_Line_Style);
		ObjectSet(l_name_40, OBJPROP_WIDTH, g_Line_Width);
		if (g_Line_Ext > 1.0) {
			l_datetime_56 = 0;
			ld_60 = 0;
			TLMng_CountExt(g_Line_Ext, a_datetime_16, NormalizeDouble(ad_8, Digits), a_datetime_28, NormalizeDouble(ad_20, Digits), l_datetime_56, ld_60);
			ObjectMove(l_name_40, 1, l_datetime_56, ld_60);
			l_count_68 = 0;
			ld_72 = TLMng_CorrectLine(l_name_40, a_datetime_28, NormalizeDouble(ad_20, Digits));
			while (ld_72 != 0.0) {
				ld_60 += ld_72;
				ObjectMove(l_name_40, 1, l_datetime_56, ld_60);
				ld_72 = TLMng_CorrectLine(l_name_40, a_datetime_28, NormalizeDouble(ad_20, Digits));
				l_count_68++;
				if (l_count_68 > 20)
					break;
			}
		}
		TLMng_CheckNumTL(asa_0, l_name_40, g_Line_InMemory);
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
			Print("硒栳赅 箐嚯屙? 腓龛?- ", asa_0[0], " 觐?铠栳觇 - ", GetLastError());
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

void TLMng_CountExt(double ad_0, int appliedPrice, double ad_12, int ai_20, double ad_24, int &ai_32, double &ad_36) {
	int l_shift_44 = iBarShift(NULL, 0, appliedPrice, FALSE);
	int l_shift_48 = iBarShift(NULL, 0, ai_20, FALSE);
	int li_52 = l_shift_44 - l_shift_48;
	int li_56 = Double2Int(MathRound(li_52 * ad_0));
	double ld_60 = MathAbs(ad_24 - ad_12);
	if (li_56 == 0)
		ad_36 = ad_24;
	else {
		if (ad_24 > ad_12)
			ad_36 = NormalizeDouble(ad_24 + li_56 * ld_60 / li_52, Digits);
		if (ad_24 < ad_12)
			ad_36 = NormalizeDouble(ad_24 - li_56 * ld_60 / li_52, Digits);
	}
	ai_32 = Time[l_shift_48] + 60 * Period() * li_56;
}

int WAMng_LookPrivWaveSameType(double& arrayAllWavesInfo[][6], int currentWaveType, int startIndex) {

	if (currentWaveType <= 0 || startIndex == 0) {
		return (0);
	}

	int index2PreviousSameWaveType = startIndex - 1;
	int waveType;
	bool found = FALSE;
	while (found == FALSE) {
		waveType = WAMng_WaveType(arrayAllWavesInfo, index2PreviousSameWaveType);
		if (waveType > 0) {
			if (waveType == currentWaveType) {
				found = TRUE;
				break;
			}
		}
		index2PreviousSameWaveType--;
		if (index2PreviousSameWaveType < 0)
			found = TRUE;
	}

	if (index2PreviousSameWaveType > 0) {
		return (index2PreviousSameWaveType);
	}

	return (0);
}

int WAMng_WaveType(double& arrayAllWavesInfo[][6], int index) {
	int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
	if (index < 1 || index > waveCount)
		return (-1);
	return (arrayAllWavesInfo[index - 1][0]);
}

int WAMng_WaveCount(double& arrayAllWavesInfo[][6]) {
	return (ArrayRange(arrayAllWavesInfo, 0));
}

double WAMng_GetWavePiv(double& arrayAllWavesInfo[][6], int index) {
	int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
	if (index < 1 || index > waveCount)
		return (0);
	return (arrayAllWavesInfo[index - 1][3]);
}

int WAMng_GetWavePivBar(double& arrayAllWavesInfo[][6], int index) {
	int waveCount = WAMng_WaveCount(arrayAllWavesInfo);
	if (index < 1 || index > waveCount)
		return (0);
	return (arrayAllWavesInfo[index - 1][5]);
}

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

	Init_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);

	if (g_Time_ShiftBar_F_F_Zero == 0) {
		F_F_Zero(periodSMA, periodLWMA, indexBar);
		foundWave = 0;
		DeInit_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);
		return (0);
	}

	if (needDrawForecastHighTrendLine == 1 && ForecastHighTrendLine == TRUE && g_ReDrawed == TRUE) {
		FTLMng_ReDraw(indexBar);
	}

	if (g_Time_ShiftBar_F_S_Zero == 0) {
		F_S_Zero(periodSMA, periodLWMA, g_WaveType, indexBar);
		if (g_Time_ShiftBar_F_S_Zero == 0) {
			foundWave = 0;
			DeInit_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);
			return (0);
		}
	}

	Add_Wave(g_Time_ShiftBar_F_F_Zero, g_Time_ShiftBar_F_S_Zero, g_WaveType, arrayAllWavesInfo);

	foundWave = 1;

	int wavesCount = WAMng_WaveCount(arrayAllWavesInfo);

	int iBarPivot = StrToInteger(DoubleToStr(arrayAllWavesInfo[wavesCount - 1][4], 0));

	datetime timePivot = Time[iBarPivot];

	if (drawPivotSemafor) {
		int iPivot = iBarPivot;
		int iBar_F_S_Zero = iBarShift(NULL, 0, g_Time_ShiftBar_F_S_Zero, FALSE);

		for (int i = iBar_F_S_Zero - 1; i > iPivot; i++)
			SemaBuffer[i] = 0;

		SemaBuffer[iBarPivot] = arrayAllWavesInfo[wavesCount - 1][3];

		if (g_WaveType == 1) {
			SemaBuffer[iBarPivot] += pivotSemaforDrawOffset * Point;
		} else if (g_WaveType == 2) {
			SemaBuffer[iBarPivot] = SemaBuffer[iBarPivot] - pivotSemaforDrawOffset * Point;
		}

		if (indexBar < 50) {
			if (pivotSoundAlarm != "") {
				PlaySound(pivotSoundAlarm);
			}

			if (pivotTextAlarm == 1) {
				Alert(PrepareTextAlarm(Time[0], g_WaveType, arrayAllWavesInfo[wavesCount - 1][3], timePivot));
			}
		}
	}

	if (needDrawForecastHighTrendLine == 1 && ForecastHighTrendLine == TRUE) {
		FTLMng_Main(indexBar, timePivot, arrayAllWavesInfo[wavesCount - 1][3], g_WaveType);
	}

	g_Time_ShiftBar_F_F_Zero = g_Time_ShiftBar_F_S_Zero;

	if (g_WaveType == 1) {
		g_WaveType = 2;
	} else if (g_WaveType == 2) {
		g_WaveType = 1;
	} else {
		g_WaveType = -1;
	}

	g_Time_ShiftBar_F_S_Zero = 0;
	DeInit_Wave_Manager(time_F_F_Zero, time_F_S_Zero, waveType);
	return (0);
}

void Init_Wave_Manager(int time_F_F_Zero, int time_F_S_Zero, int waveType) {
	g_Time_ShiftBar_F_F_Zero = time_F_F_Zero;
	g_Time_ShiftBar_F_S_Zero = time_F_S_Zero;
	g_WaveType = waveType;
}

void DeInit_Wave_Manager(int &time_F_F_Zero, int &time_F_S_Zero, int &waveType) {
	time_F_F_Zero = g_Time_ShiftBar_F_F_Zero;
	time_F_S_Zero = g_Time_ShiftBar_F_S_Zero;
	waveType = g_WaveType;
}

void F_F_Zero(int periodSMA, int periodLWMA, int shiftBarIndex) {

	if ((Bars - shiftBarIndex) >= (periodLWMA << 1)) {

		int currentWaveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, shiftBarIndex);

		g_Time_ShiftBar_F_F_Zero = 0;
		g_WaveType = 0;

		double timeFindZeroFromShift = 0;
		int index2ShiftBar = shiftBarIndex;

		if (currentWaveType > 0) {
			timeFindZeroFromShift = ChMnr_FindZeroFromShift(periodSMA, periodLWMA, index2ShiftBar);
			if (timeFindZeroFromShift <= 0.0)
				return;

		} else {
			currentWaveType = ChMnr_FirstWaveFromShift(periodSMA, periodLWMA, index2ShiftBar);
			if (currentWaveType <= 0)
				return;

			timeFindZeroFromShift = ChMnr_FindZeroFromShift(periodSMA, periodLWMA, index2ShiftBar);
			if (timeFindZeroFromShift <= 0.0)
				return;
		}

		g_Time_ShiftBar_F_F_Zero = Time[index2ShiftBar];
		g_WaveType = currentWaveType;
	}
}

/**
 *
 * index2ShiftBar:第几根K线的值(iMA函数的最后一个参数shift)
 */
void F_S_Zero(int periodSMA, int periodLWMA, int globalWaveType, int index2ShiftBar) {

	int waveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, index2ShiftBar);

	if (g_Time_ShiftBar_F_F_Zero == 0 || g_WaveType <= 0 || globalWaveType <= 0)
		return;

	if (waveType == 0) {
		g_Time_ShiftBar_F_S_Zero = 0;
		return;
	}

	if (waveType == globalWaveType) {
		g_Time_ShiftBar_F_S_Zero = 0;
		return;
	}

	g_Time_ShiftBar_F_S_Zero = Time[index2ShiftBar];
}

double ChMnr_FindZeroFromShift(int periodSMA, int periodLWMA, int &startIndexShiftBar) {
	int count = 0;
	double timeFindZeroFromShift = -99999;
	bool found = FALSE;
	while (found == FALSE) {
		if (ChMnr_IfZero(periodSMA, periodLWMA, startIndexShiftBar + count) == 1) {
			found = TRUE;
			timeFindZeroFromShift = Time[startIndexShiftBar + count];
			startIndexShiftBar += count;
		}
		count++;
		if (startIndexShiftBar + count >= Bars) {
			found = TRUE;
			timeFindZeroFromShift = -55555;
		}
	}
	return (timeFindZeroFromShift);
}

int ChMnr_FirstWaveFromShift(int periodSMA, int periodLWMA, int &startIndexShiftBar) {
	int count = 0;
	int returnValueWaveType = -99999;
	int waveType = 0;
	bool found = FALSE;
	while (found == FALSE) {
		waveType = ChMnr_CurrentWaveType(periodSMA, periodLWMA, startIndexShiftBar + count);
		if (waveType > 0) {
			returnValueWaveType = waveType;
			found = TRUE;
			startIndexShiftBar += count;
		}
		count++;
		if (startIndexShiftBar + count >= Bars) {
			found = TRUE;
			returnValueWaveType = -55555;
		}
	}
	return (returnValueWaveType);
}

int ChMnr_IfZero(int periodSMA, int periodLWMA, int bufferIndex4MA) {
	double valueSMA = NormalizeToDigit(iMA(NULL, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, bufferIndex4MA));
	double valueLWMA = NormalizeToDigit(iMA(NULL, 0, periodLWMA, 0, MODE_LWMA, PRICE_WEIGHTED, bufferIndex4MA));
	double diff = valueSMA - valueLWMA;
	return (IsInChanel(diff, 0, Trigger_Sens));
}

int ChMnr_CurrentWaveType(int periodSMA, int periodLWMA, int bufferIndex4MA) {
	double valueSMA = iMA(NULL, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, bufferIndex4MA);
	double valueLWMA = iMA(NULL, 0, periodLWMA, 0, MODE_LWMA, PRICE_WEIGHTED, bufferIndex4MA);
	double diff = valueSMA - valueLWMA;
	if (ChMnr_IfZero(periodSMA, periodLWMA, bufferIndex4MA) == 1)
		return (0);
	if (diff > 0.0)
		return (1);
	if (diff < 0.0)
		return (2);
	return (-1);
}

int Add_Wave(int time_F_F_Zero, int time_F_S_Zero, int waveType, double &arrayAllWavesInfo[][6]) {
		int dimension1 = ArrayRange(arrayAllWavesInfo, 0);
		dimension1++;
		ArrayResize(arrayAllWavesInfo, dimension1);
		arrayAllWavesInfo[dimension1 - 1][0] = waveType;
		arrayAllWavesInfo[dimension1 - 1][1] = time_F_F_Zero;
		arrayAllWavesInfo[dimension1 - 1][2] = time_F_S_Zero;
		
		int time_Pre_Pivot = 0;
		if (dimension1 - 2 >= 0)
			time_Pre_Pivot = arrayAllWavesInfo[dimension1 - 2][5];
			
		// 波峰或者波谷的时间轴
		int timePivot = FindPivot(time_F_F_Zero, time_F_S_Zero, waveType, time_Pre_Pivot);
		
		if (timePivot != 0) {
			arrayAllWavesInfo[dimension1 - 1][4] = iBarShift(NULL, 0, timePivot, FALSE);
			arrayAllWavesInfo[dimension1 - 1][5] = timePivot;
			
			if (waveType == 1)
				arrayAllWavesInfo[dimension1 - 1][3] = High[iBarShift(NULL, 0, timePivot, FALSE)];
			else if (waveType == 2)
				arrayAllWavesInfo[dimension1 - 1][3] = Low[iBarShift(NULL, 0, timePivot, FALSE)];
		}
		
		return (0);
}

int FindPivot(int time_F_F_Zero, int time_F_S_Zero, int waveType, int time_Pre_Pivot) {
	if (waveType < 1 || time_F_F_Zero == 0 || time_F_S_Zero == 0)
		return (0);
		
	int endBar = iBarShift(NULL, 0, time_F_F_Zero, TRUE);
	int startBar = iBarShift(NULL, 0, time_F_S_Zero, TRUE);
	
	if (endBar == -1 || startBar == -1)
		return (0);
		
	int iBarShift_Pre_Pivot = 0;
	if (time_Pre_Pivot > 0)
		iBarShift_Pre_Pivot = iBarShift(NULL, 0, time_Pre_Pivot, TRUE);
		
	int count = 0;
	if (iBarShift_Pre_Pivot > 0)
		count = iBarShift_Pre_Pivot - startBar + 1;
	else
		count = endBar - startBar + 1;
		
	if (waveType == 1) {
		int barIndexHighest = iHighest(NULL, 0, MODE_HIGH, count, startBar);
		return (Time[barIndexHighest]);
	}
	
	if (waveType == 2) {
		int barIndexLowest = iLowest(NULL, 0, MODE_LOW, count, startBar);
		return (Time[barIndexLowest]);
	}
	
	return (0);
}

int Double2Int(double doubleValue) {
	return (StrToInteger(DoubleToStr(doubleValue, 0)));
}

int IsInChanel(double value, double baseLine, double range) {
	double limitAbove = baseLine + range;
	double limitBelow = baseLine - range;
	if (limitBelow <= value && value <= limitAbove) {
		return 1;
	}

	return 0;
}

double NormalizeToDigit(double doubleValue) {
	double returnValue = doubleValue;
	for (int i = 1; i <= Digits; i++)
		returnValue = 10.0 * returnValue;
	return (returnValue);
}

string PrepareTextAlarm(int timeAlarm, int isTopOrBottom, double price, int ai_16) {
	string returnValue = TimeToStr(timeAlarm, TIME_DATE) + " " + TimeToStr(timeAlarm, TIME_MINUTES) + " : ";
	if (isTopOrBottom == 1)
		returnValue += "The top maximum is generated : ";
	if (isTopOrBottom == 2)
		returnValue += "The bottom minimum is generated : ";
	returnValue += TimeToStr(ai_16, TIME_DATE) + " " + TimeToStr(ai_16, TIME_MINUTES) + " Price Value: ";
	returnValue += DoubleToStr(price, Digits);
	return (returnValue);
}

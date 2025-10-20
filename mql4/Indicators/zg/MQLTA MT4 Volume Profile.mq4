#property link          "https://www.earnforex.com/indicators/volume-profile/"
#property version       "1.01"
#property strict
#property copyright     "EarnForex.com - 2020-2025"
#property description   "Volume profile indicator"
#property description   "Shows the price levels with most price action weighted by tick volume"
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this indicator cannot be held responsible for any damage or loss."
#property description   ""
#property description   "Find More on EarnForex.com"
//#property icon          "\\Files\\EF-Icon-64x64px.ico"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_type1 DRAW_NONE

enum ENUM_CALCULATION_START_TIME
{
    CALC_START_LAST = 0,  //MOST RECENT CANDLE
    CALC_START_MANUAL = 1 //MANUAL SELECTION
};

enum ENUM_CALCULATION_MODE
{
    CANDLE_WHOLE = 0, //CANDLE WHOLE
    CANDLE_OPEN = 2,  //CANDLE OPEN
    CANDLE_CLOSE = 3  //CANDLE CLOSE
};

enum ENUM_CALCULATION_RANGE_TIMEFRAME
{
    CALC_TF_MINUTES = PERIOD_M1, //MINUTES
    CALC_TF_HOURS = PERIOD_H1,   //HOURS
    CALC_TF_DAYS = PERIOD_D1,    //DAYS
    CALC_TF_WEEKS = PERIOD_W1    //WEEKS
};

input string Comment1 = "========================";  //MQLTA Volume Profile
input string IndicatorName = "MQLTA-VPI1";           //Indicator Short Name

input string Comment2 = "========================";  //Indicator Parameters
input ENUM_TIMEFRAMES VPTimeFrame = PERIOD_CURRENT;  //Volume Profile Calculation Timeframe
input ENUM_CALCULATION_MODE CalculationMode = CANDLE_WHOLE; //Value to Use for Calculation
input bool UseVolume = true;                         //Use Volume in Calculation
input int StepPointsExt = 10;                        //Step in Points

input string Comment2a = "========================"; //Time Range for Calculation
input ENUM_CALCULATION_START_TIME StartTimeType = CALC_START_LAST; //Show Volume Profile up to
input int UnitsToScan = 5;                           //Calculate with Previous (Number of Units)
input ENUM_CALCULATION_RANGE_TIMEFRAME UnitType = CALC_TF_DAYS; //Calculate with Previous (Type of Units)

input string Comment4 = "========================";  //Volume Profile Graphic Parameters
input int WindowSize = 1;                            //Window Width Multiplier
input color WindowColor = clrGreenYellow;            //Window Color
input bool ShowLineLabel = false;                    //Show Vertical Line Label
input color LineLabelColor = clrRed;                 //Vertical Line Label Color
input bool CleanLineAtClose = true;                  //Delete Vertical Line at Close
input int RefreshDelay = 10;                         //Refresh Delay for Most Recent Candle

input string Comment5 = "========================";  //Point of Control (POC) Parameters
input bool ShowPOC = true;                           //Show POC Line
input int POCSize = 2;                               //POC Line Width (1 to 5)
input color POCColor = clrRed;                       //POC Line Color

long VolumeProfile[];
int BarsToScan = 0;
int WindowSizeMin = 10;
double StepPoints;
double PriceMin;
double PriceMax;
datetime StartTime = TimeCurrent();
double OutputBuffer[];
bool WasntEnoughBars = true;

void OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    OnInitInitialization();

    InitialiseBuffers();
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    bool IsNewCandle = CheckIfNewCandle();

    if (IsNewCandle && StartTimeType == CALC_START_LAST)
    {
        StartTime = iTime(Symbol(), PERIOD_CURRENT, 0);
        ObjectSetInteger(0, IndicatorName + "-VLINE-VP", OBJPROP_TIME, StartTime);
        VolumeProfileCalculate();
    }
    else if ((StartTimeType == CALC_START_MANUAL) && ((WasntEnoughBars) || (rates_total - prev_calculated > 1))) // Recalculating when more than 1 bar got loaded because most likely it's a result of a chart TF/Symbol change.
    {
        StartTime = (datetime)ObjectGetInteger(0, IndicatorName + "-VLINE-VP", OBJPROP_TIME);
        WasntEnoughBars = false;
        VolumeProfileCalculate();
    }

    return rates_total;
}

void OnDeinit(const int reason)
{
    CleanChart(); // Delete everything except the vertical line.
    // Delete the vertical line only if the indicator is removed.
    if (reason == REASON_REMOVE)
    {
        ObjectDelete(ChartID(), IndicatorName + "-VLINE-VP");
    }
    EventKillTimer();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_DRAG)
    {
        if (StringFind(sparam, IndicatorName + "-VLINE-VP", 0) >= 0)
        {
            StartTime = (datetime)ObjectGetInteger(0, IndicatorName + "-VLINE-VP", OBJPROP_TIME);
            VolumeProfileCalculate();
        }
    }
}

void OnTimer()
{
    StartTime = (datetime)ObjectGetInteger(0, IndicatorName + "-VLINE-VP", OBJPROP_TIME);
    VolumeProfileCalculate();
}

void OnInitInitialization()
{
    StepPoints = StepPointsExt * Point();
    BarsToScan = PeriodSeconds((ENUM_TIMEFRAMES)UnitType) * UnitsToScan / PeriodSeconds(VPTimeFrame);
    ScanLines();
    CreateLine();
    StartTime = (datetime)ObjectGetInteger(0, IndicatorName + "-VLINE-VP", OBJPROP_TIME);
    if (StartTimeType == CALC_START_LAST)
    {
        EventSetTimer(RefreshDelay);
    }
}

// Delete all chart objects except the vertical line.
void CleanChart()
{
    ObjectsDeleteAll(ChartID(), IndicatorName, -1, OBJ_RECTANGLE);
    ObjectsDeleteAll(ChartID(), IndicatorName, -1, OBJ_HLINE);
    ObjectsDeleteAll(ChartID(), IndicatorName, -1, OBJ_TEXT);
}

void InitialiseBuffers()
{
    SetIndexBuffer(0, OutputBuffer);
}

datetime NewCandleTime = TimeCurrent();
bool CheckIfNewCandle()
{
    if (NewCandleTime == iTime(Symbol(), 0, 0)) return false;
    NewCandleTime = iTime(Symbol(), 0, 0);
    return true;
}

void VolumeProfileCalculate()
{
    int BarStart = iBarShift(Symbol(), VPTimeFrame, StartTime);
    if (BarStart + BarsToScan > iBars(Symbol(), VPTimeFrame))
    {
        BarsToScan = iBars(Symbol(), VPTimeFrame) - BarStart;
        if (BarsToScan <= 0)
        {
            Print("Not enough bars.");
            WasntEnoughBars = true;
            return;
        }
    }
    int PriceHighMode = MODE_CLOSE;
    int PriceLowMode = MODE_CLOSE;
    if (CalculationMode == CANDLE_WHOLE)
    {
        PriceHighMode = MODE_HIGH;
        PriceLowMode = MODE_LOW;
    }
    else if (CalculationMode == CANDLE_CLOSE)
    {
        PriceHighMode = MODE_CLOSE;
        PriceLowMode = MODE_CLOSE;
    }
    else if (CalculationMode == CANDLE_OPEN)
    {
        PriceHighMode = MODE_OPEN;
        PriceLowMode = MODE_OPEN;
    }
    if (StepPoints == 0)
    {
        Print("Error: StepPoints = 0. Not proceeding due to a potential division by zero.");
        StepPoints = StepPointsExt * Point();
        return;
    }
    PriceMin = MathFloor(iLow(Symbol(), VPTimeFrame, iLowest(Symbol(), VPTimeFrame, PriceLowMode, BarsToScan, BarStart)) / StepPoints) * StepPoints;
    PriceMax = MathCeil(iHigh(Symbol(), VPTimeFrame, iHighest(Symbol(), VPTimeFrame, PriceHighMode, BarsToScan, BarStart)) / StepPoints) * StepPoints;
    int Steps = (int)MathCeil((PriceMax - PriceMin) / StepPoints) + 1;
    ArrayResize(VolumeProfile, Steps);
    ArrayInitialize(VolumeProfile, 0);
    for (int i = 0; i < BarsToScan; i++)
    {
        int j = BarStart + i;
        double MinPrice = 0;
        double MaxPrice = 0;
        double CandleSteps = 0;
        if (CalculationMode == CANDLE_WHOLE)
        {
            MinPrice = iLow(Symbol(), VPTimeFrame, j);
            MaxPrice = iHigh(Symbol(), VPTimeFrame, j);
        }
        else if (CalculationMode == CANDLE_CLOSE)
        {
            MinPrice = iClose(Symbol(), VPTimeFrame, j);
            MaxPrice = iClose(Symbol(), VPTimeFrame, j);
        }
        else if (CalculationMode == CANDLE_OPEN)
        {
            MinPrice = iOpen(Symbol(), VPTimeFrame, j);
            MaxPrice = iOpen(Symbol(), VPTimeFrame, j);
        }
        MinPrice = MathFloor(MinPrice / StepPoints) * StepPoints;
        MaxPrice = MathFloor(MaxPrice / StepPoints) * StepPoints;
        CandleSteps = MathRound((MaxPrice - MinPrice) / StepPoints);
        for (int k = 0; k <= CandleSteps; k++)
        {
            double CalcPrice = MinPrice + StepPoints * k;
            int h = (int)MathRound((CalcPrice - PriceMin) / StepPoints);
            long Weight = 1;
            if (UseVolume) Weight = iVolume(Symbol(), VPTimeFrame, j);
            VolumeProfile[h] += Weight;
        }
    }
    DrawVolumeProfile();
}

void DrawVolumeProfile()
{
    CleanVolumeProfile();
    long VolumeMax = VolumeProfile[ArrayMaximum(VolumeProfile)];
    if (VolumeMax == 0)
    {
        Print("Error with historical data. Waiting for data to load...");
        WasntEnoughBars = true;
        return;
    }
    long VolumeMin = VolumeProfile[ArrayMinimum(VolumeProfile)];
    long VolumeDiffMax = VolumeMax - VolumeMin;
    double PricePOC = PriceMin + StepPoints * ArrayMaximum(VolumeProfile) + StepPoints / 2;
    OutputBuffer[0] = PricePOC;
    int VolumeWidth = (int)MathRound(WindowSizeMin * WindowSize * (6 - ChartGetInteger(0, CHART_SCALE)));
    int StartTimeShift = iBarShift(Symbol(), PERIOD_CURRENT, StartTime);
    for (int i = 0; i < ArraySize(VolumeProfile); i++)
    {
        double PriceLow = PriceMin + StepPoints * i;
        double PriceHigh = PriceLow + StepPoints;
        datetime TimeRight = StartTime;
        long VolumeDiff = VolumeProfile[i] - VolumeMin;
        int TimeStepsShift = (int)MathRound(((VolumeWidth - 1) * VolumeProfile[i]) / VolumeMax);
        datetime TimeLeft = iTime(Symbol(), PERIOD_CURRENT, StartTimeShift + TimeStepsShift + 1);
        string RectangleName = IndicatorName + "-VP-RECT-" + DoubleToString(PriceLow / Point(), 0);
        ObjectCreate(0, RectangleName, OBJ_RECTANGLE, 0, TimeRight, PriceLow, TimeLeft, PriceHigh);
        ObjectSetInteger(0, RectangleName, OBJPROP_COLOR, WindowColor);
        ObjectSetInteger(0, RectangleName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, RectangleName, OBJPROP_BACK, true);
        ObjectSetInteger(0, RectangleName, OBJPROP_HIDDEN, true);
    }
    if (ShowPOC)
    {
        string POCName = IndicatorName + "-VP-RECT-H-" + DoubleToString(PricePOC / Point(), 0);
        ObjectCreate(0, POCName, OBJ_HLINE, 0, 0, PricePOC);
        ObjectSetInteger(0, POCName, OBJPROP_COLOR, POCColor);
        ObjectSetInteger(0, POCName, OBJPROP_WIDTH, POCSize);
        ObjectSetInteger(0, POCName, OBJPROP_SELECTABLE, false);
    }
    UpdateLineLabels();
}

void CleanVolumeProfile()
{
    ObjectsDeleteAll(ChartID(), IndicatorName + "-VP-RECT-");
    ObjectsDeleteAll(ChartID(), IndicatorName + "-VLINE-LABEL");
}

int TotalLines = 0;
void ScanLines()
{
    TotalLines = 0;
    if (ObjectFind(ChartID(), IndicatorName + "-VLINE-VP") >= 0)
    {
        TotalLines++;
        StartTime = (datetime)ObjectGetInteger(0, IndicatorName + "-VLINE-VP", OBJPROP_TIME);
    }
}

void CreateLine()
{
    string LineName = IndicatorName + "-VLINE-VP";
    if (TotalLines == 0)
    {
        ObjectCreate(0, LineName, OBJ_VLINE, 0, iTime(Symbol(), PERIOD_CURRENT, 0), 0);
    }
    ObjectSetInteger(0, LineName, OBJPROP_COLOR, WindowColor);
    ObjectSetInteger(0, LineName, OBJPROP_BACK, true);
    if (StartTimeType == CALC_START_LAST)
    {
        ObjectSetInteger(0, LineName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, LineName, OBJPROP_TIME, iTime(Symbol(), PERIOD_CURRENT, 0));
    }
    else
    {
        ObjectSetInteger(0, LineName, OBJPROP_SELECTABLE, true);
    }
    ObjectSetInteger(0, LineName, OBJPROP_WIDTH, 1);
    UpdateLineLabels();
}

void UpdateLineLabels()
{
    if (!ShowLineLabel) return;
    string LabelName = IndicatorName + "-VLINE-LABEL";
    ObjectCreate(0, LabelName, OBJ_TEXT, 0, 0, 0);
    ObjectSetDouble(0, LabelName, OBJPROP_ANGLE, 90);
    ObjectSetInteger(0, LabelName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, LabelName, OBJPROP_COLOR, WindowColor);
    int Y = (int)MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0) - 10);
    double PriceY = 0;
    int SubW = 0;
    string UnitString = "";
    if (UnitType == CALC_TF_DAYS) UnitString = "DAYS";
    if (UnitType == CALC_TF_HOURS) UnitString = "HOURS";
    if (UnitType == CALC_TF_MINUTES) UnitString = "MINUTES";
    if (UnitType == CALC_TF_WEEKS) UnitString = "WEEKS";
    string LabelDescr = IndicatorName + "-VP-PREVIOUS " + IntegerToString(UnitsToScan) + " " + UnitString;
    datetime TimeTmp = TimeCurrent();
    ChartXYToTimePrice(0, 0, Y, SubW, TimeTmp, PriceY);
    ObjectSetInteger(0, LabelName, OBJPROP_TIME, StartTime);
    ObjectSetDouble(0, LabelName, OBJPROP_PRICE, PriceY);
    ObjectSetInteger(0, LabelName, OBJPROP_HIDDEN, false);
    ObjectSetText(LabelName, LabelDescr, 10, "Consolas", LineLabelColor);
}
//+------------------------------------------------------------------+
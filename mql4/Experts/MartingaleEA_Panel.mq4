//+------------------------------------------------------------------+
//|                                                 MartingaleEA.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Gao Zeng.QQ--183947281,mail--soko8@sina.com."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\SpinEditFloat.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\WindowWithoutCloseButton.mqh>

struct OrderInfo {
   double   lotSize;
   double   openPrice;
   double   slPrice;
   double   tpPrice;
   int      ticketId;
   int      operationType;
};

enum enCloseMode
{
   Close_All = 0,
   Close_Part = 1,
   Close_Part_All = 2
};

enum enAddPositionMode
{
   Fixed = 0,
   Multiplied = 1
};

enum enButtonMode
{
   Close_Order_Mode = 0,
   Create_Order_Mode = 1
};

//--- input parameters
input double               InitLotSize=0.01;
input int                  GridPoints=200;
input int                  TakeProfitPoints = 30;
input double               RetraceProfitCoefficient = 0.25;
input int                  MaxTimesAddPosition = 9;
input bool                 AddPositionByTrend = false;
input enCloseMode          CloseMode = Close_Part_All;
input enAddPositionMode    AddPositionMode = Multiplied;
input double               LotAddPositionStep = 0.01;
input double               LotAddPositionMultiple = 2.0;
input int                  MagicNumber=888888;
input double               MaxLots4AddPositionLimit=0.4;

      double               initLots;
      int                  grid;
      double               gridPrice;
      
      int                  tpPoints;
      double               tp;
      double               retraceProfitRatio;
      int                  maxTimes4AP;
      int                  times_Part2All;
      bool                 addPosition2Trend;
      
      enCloseMode          closePositionMode;
      enAddPositionMode    addPositionMode;
      
      double               lotStep;
      double               lotMultiple;

      OrderInfo            arrOrdersBuy[];
      OrderInfo            arrOrdersSell[];
      
      double               initLotSize4Buy;
      double               initLotSize4Sell;
      double               curInitLotSize4Buy;
      double               curInitLotSize4Sell;
      
      int                  countAPBuy = -1;
      int                  countAPSell = -1;
      
      double               retracePriceBuy = 0.0;
      double               retracePriceSell = 0.0;
      
      double               retraceRatioBuy = 0.0;
      double               retraceRatioSell = 0.0;
      
      double               closeProfitBuy = 0.0;
      double               closeProfitSell = 0.0;
      
      int                  arraySize;
      double               reduceFactor;

const string               nmLineClosePositionBuy = "ClosePositionBuy";
const string               nmLineClosePositionSell = "ClosePositionSell";


      enButtonMode         btnModeBuy;
      enButtonMode         btnModeSell;
      
const string Font_Name = "Lucida Bright";

      bool        isActive                = false;

      bool        isForbidCreateOrderManual              = false;


      bool        isStopedByNews          = false;
      datetime    stopedTimeByNews        = 0;
      bool        forbidCreateOrder       = false;
      bool        mustStopEAByNews        = false;
      int         hoursForbidCreateOrderBeforeNews = 24;
      int         minutesMustStopEABeforeNews = 10;
      int         minutesAfterNewsResume  = 180;


      bool        enableMaxLotControl = true;
      double      Max_Lot_AP = 0;

      bool AccountCtrl = true;
   const int         AuthorizeAccountList[4] = {  6154218
                                                 ,7100152
                                                 ,5015177
                                                 ,5330172
                                                };
      bool        enableUseLimit=true;
      datetime    expireTime = D'2017.12.31 23:59:59';
      
      
class COpPanel : public CAppWindowWithoutCloseButton {
private:
   CLabel         lblTotalProfitWords;
   CEdit          edtTotalProfit;
   
   CButton        btnStopStart;
   CButton        btnForbidAllow;
   
   CEdit          edtHorizontalLine1;
   
   CLabel         lblLong;
   CEdit          edtVerticalLine1;
   CLabel         lblShort;
   
   CLabel         lblProfitWordsLong;
   CLabel         lblProfitWordsShort;
   
   CButton        btnCloseLong;
   CEdit          edtProfitCloseLong;
   CButton        btnCloseShort;
   CEdit          edtProfitCloseShort;
   
   CButton        btnDecreaseLong;
   CEdit          edtProfitDecreaseLong;
   CButton        btnDecreaseShort;
   CEdit          edtProfitDecreaseShort;
   
   CButton        btnAdd1LongOrder;
   CButton        btnAdd1ShortOrder;
   
   CButton        btnCloseTheMaxLongOrder;
   CEdit          edtProfitCloseTheMaxLongOrder;
   CButton        btnCloseTheMaxShortOrder;
   CEdit          edtProfitCloseTheMaxShortOrder;
   
   CLabel         lblTargetProfitCloseLongWords;
   CEdit          edtTargetProfitCloseLong;
   CLabel         lblTargetProfitCloseShortWords;
   CEdit          edtTargetProfitCloseShort;

   CLabel         lblTargetRetraceLongWords;
   CEdit          edtTargetRetraceLong;
   CLabel         lblTargetRetraceShortWords;
   CEdit          edtTargetRetraceShort;
   
   CLabel         lblAddPositionTimesLongWords;
   CEdit          edtAddPositionTimesLong;
   CLabel         lblAddPositionTimesShortWords;
   CEdit          edtAddPositionTimesShort;
   
   CEdit          edtVerticalLine2;
   /****parameters****/
   CLabel         lblParametersWords;
   
   CLabel         lblInitLotSize;
   CSpinEditFloat sefInitLotSize;
   
   CLabel         lblGridPoints;
   CSpinEdit      speGridPoints;
   
   CLabel         lblTakeProfitPoints;
   CSpinEdit      speTakeProfitPoints;
   
   CLabel         lblRetraceProfitCoefficient;
   CSpinEditFloat sefRetraceProfitCoefficient;
   
   CLabel         lblMaxTimesAddPosition;
   CSpinEdit      speMaxTimesAddPosition;
   
   CCheckBox      ckbAddPositionByTrend;
   
   CLabel         lblCloseMode;
   CComboBox      cmbCloseMode;
   
   CLabel         lblAddPositionMode;
   CComboBox      cmbAddPositionMode;
   
   CLabel         lblLotAddPositionStep;
   CSpinEditFloat sefLotAddPositionStep;
   
   CLabel         lblLotAddPositionMultiple;
   CSpinEditFloat sefLotAddPositionMultiple;
   
   CLabel         lblMaxLots4AddPositionLimit;
   CSpinEditFloat sefMaxLots4AddPositionLimit;
   
   CLabel         lblMagicNumberWords;
   CEdit          edtMagicNumber;
   
public:
   
    COpPanel() {}
   ~COpPanel() {}
   
   bool OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   bool create(const long chart, const string name, const int subwin) {
      //--- call method of parent class
      if(!CAppWindowWithoutCloseButton::Create(chart, name, subwin, 1, 14, 640, 393)) return(false);
      CAppWindowWithoutCloseButton::setBackgroundColor(clrBlack);
   
      if(!lblTotalProfitWords.Create(m_chart_id, "lblTotalProfitWords", m_subwin, 2, 3, 79, 20)) return(false);
      lblTotalProfitWords.Text("Total Profit：");
      lblTotalProfitWords.Color(clrWhite);
      //lblTotalProfitWords.ColorBackground(clrRed);
      //lblTotalProfitWords.ColorBorder(clrRed);
      lblTotalProfitWords.Font(Font_Name);
      lblTotalProfitWords.FontSize(10);
      if(!Add(lblTotalProfitWords)) return(false);
      
      if(!edtTotalProfit.Create(m_chart_id, "edtTotalProfit", m_subwin, 84, 2, 170, 20)) return(false);
      //edtTotalProfit.Text("1234567.12");
      edtTotalProfit.Text("0.00");
      edtTotalProfit.ColorBackground(clrBlack);
      edtTotalProfit.Color(clrWhite);
      edtTotalProfit.Font(Font_Name);
      edtTotalProfit.FontSize(10);
      edtTotalProfit.ReadOnly(true);
      edtTotalProfit.TextAlign(ALIGN_RIGHT);
      if(!Add(edtTotalProfit)) return(false);
      
      if(!btnStopStart.Create(m_chart_id, "btnStopStart", m_subwin, 3, 23, 70, 50)) return(false);
      if (isActive) {
         btnStopStart.Text("Stop");
         btnStopStart.Color(clrWhite);
         btnStopStart.ColorBackground(clrMaroon);
      } else {
         btnStopStart.Text("Start");
         btnStopStart.Color(clrWhite);
         btnStopStart.ColorBackground(clrDarkGreen);
      }
      btnStopStart.Font(Font_Name);
      btnStopStart.FontSize(18);
      if(!Add(btnStopStart)) return(false);
      
      if(!btnForbidAllow.Create(m_chart_id, "btnForbidAllow", m_subwin, 89, 23, 170, 50)) return(false);
      if (isForbidCreateOrderManual) {
         btnForbidAllow.Text("Allow");
         btnForbidAllow.Color(clrBlack);
         btnForbidAllow.ColorBackground(clrLime);
      } else {
         btnForbidAllow.Text("Forbid");
         btnForbidAllow.Color(clrWhite);
         btnForbidAllow.ColorBackground(clrMaroon);
      }
      btnForbidAllow.Font(Font_Name);
      btnForbidAllow.FontSize(18);
      if(!Add(btnForbidAllow)) return(false);
      
      if(!edtHorizontalLine1.Create(m_chart_id, "edtHorizontalLine1", m_subwin, 1, 56, 410, 59)) return(false);
      edtHorizontalLine1.ColorBackground(clrCoral);
      edtHorizontalLine1.ColorBorder(clrCoral);
      edtHorizontalLine1.ReadOnly(false);
      if(!Add(edtHorizontalLine1)) return(false);
      
      if(!lblLong.Create(m_chart_id, "lblLong", m_subwin, 50, 60, 120, 100)) return(false);
      lblLong.Text("Long");
      lblLong.Color(clrWhite);
      lblLong.Font(Font_Name);
      lblLong.FontSize(30);
      if(!Add(lblLong)) return(false);
      
      if(!edtVerticalLine1.Create(m_chart_id, "edtVerticalLine1", m_subwin, 200, 58, 203, 350)) return(false);
      edtVerticalLine1.ColorBackground(clrCoral);
      edtVerticalLine1.ColorBorder(clrCoral);
      edtVerticalLine1.ReadOnly(false);
      if(!Add(edtVerticalLine1)) return(false);
      
      if(!lblShort.Create(m_chart_id, "lblShort", m_subwin, 260, 60, 320, 80)) return(false);
      lblShort.Text("Short");
      lblShort.Color(clrWhite);
      lblShort.Font(Font_Name);
      lblShort.FontSize(30);
      if(!Add(lblShort)) return(false);
      
      if(!lblProfitWordsLong.Create(m_chart_id, "lblProfitWordsLong", m_subwin, 130, 105, 160, 120)) return(false);
      lblProfitWordsLong.Text("Profit");
      lblProfitWordsLong.Color(clrWhite);
      lblProfitWordsLong.Font(Font_Name);
      lblProfitWordsLong.FontSize(11);
      if(!Add(lblProfitWordsLong)) return(false);
      
      if(!lblProfitWordsShort.Create(m_chart_id, "lblProfitWordsShort", m_subwin, 340, 105, 360, 120)) return(false);
      lblProfitWordsShort.Text("Profit");
      lblProfitWordsShort.Color(clrWhite);
      lblProfitWordsShort.Font(Font_Name);
      lblProfitWordsShort.FontSize(11);
      if(!Add(lblProfitWordsShort)) return(false);
      
      if(!btnCloseLong.Create(m_chart_id, "btnCloseLong", m_subwin, 3, 123, 105, 147)) return(false);
      btnCloseLong.Text("Create Buy");
      btnCloseLong.Color(clrWhite);
      btnCloseLong.ColorBackground(clrDarkGreen);
      btnCloseLong.Font(Font_Name);
      btnCloseLong.FontSize(14);
      if(!Add(btnCloseLong)) return(false);
      
      if(!edtProfitCloseLong.Create(m_chart_id, "edtProfitCloseLong", m_subwin, 107, 123, 193, 147)) return(false);
      //edtProfitCloseLong.Text("1234567.12");
      edtProfitCloseLong.Text("0.00");
      edtProfitCloseLong.ColorBackground(clrBlack);
      edtProfitCloseLong.Color(clrWhite);
      edtProfitCloseLong.Font(Font_Name);
      edtProfitCloseLong.FontSize(10);
      edtProfitCloseLong.ReadOnly(true);
      edtProfitCloseLong.TextAlign(ALIGN_RIGHT);
      if(!Add(edtProfitCloseLong)) return(false);
      
      if(!btnCloseShort.Create(m_chart_id, "btnCloseShort", m_subwin, 210, 123, 314, 147)) return(false);
      btnCloseShort.Text("Create Sell");
      btnCloseShort.Color(clrWhite);
      btnCloseShort.ColorBackground(clrBrown);
      btnCloseShort.Font(Font_Name);
      btnCloseShort.FontSize(14);
      if(!Add(btnCloseShort)) return(false);
      
      if(!edtProfitCloseShort.Create(m_chart_id, "edtProfitCloseShort", m_subwin, 316, 123, 402, 147)) return(false);
      //edtProfitCloseShort.Text("1234567.12");
      edtProfitCloseShort.Text("0.00");
      edtProfitCloseShort.ColorBackground(clrBlack);
      edtProfitCloseShort.Color(clrWhite);
      edtProfitCloseShort.Font(Font_Name);
      edtProfitCloseShort.FontSize(10);
      edtProfitCloseShort.ReadOnly(true);
      edtProfitCloseShort.TextAlign(ALIGN_RIGHT);
      if(!Add(edtProfitCloseShort)) return(false);

      if(!btnDecreaseLong.Create(m_chart_id, "btnDecreaseLong", m_subwin, 3, 160, 105, 184)) return(false);
      btnDecreaseLong.Text("Decrease Buy");
      btnDecreaseLong.Color(clrBlack);
      btnDecreaseLong.ColorBackground(clrLawnGreen);
      btnDecreaseLong.Font(Font_Name);
      btnDecreaseLong.FontSize(10);
      if(!Add(btnDecreaseLong)) return(false);
      
      if(!edtProfitDecreaseLong.Create(m_chart_id, "edtProfitDecreaseLong", m_subwin, 107, 160, 193, 184)) return(false);
      //edtProfitDecreaseLong.Text("1234567.12");
      edtProfitDecreaseLong.Text("0.00");
      edtProfitDecreaseLong.ColorBackground(clrBlack);
      edtProfitDecreaseLong.Color(clrWhite);
      edtProfitDecreaseLong.Font(Font_Name);
      edtProfitDecreaseLong.FontSize(10);
      edtProfitDecreaseLong.ReadOnly(true);
      edtProfitDecreaseLong.TextAlign(ALIGN_RIGHT);
      if(!Add(edtProfitDecreaseLong)) return(false);
      
      if(!btnDecreaseShort.Create(m_chart_id, "btnDecreaseShort", m_subwin, 210, 160, 314, 184)) return(false);
      btnDecreaseShort.Text("Decrease Sell");
      btnDecreaseShort.Color(clrBlack);
      btnDecreaseShort.ColorBackground(clrIndianRed);
      btnDecreaseShort.Font(Font_Name);
      btnDecreaseShort.FontSize(10);
      if(!Add(btnDecreaseShort)) return(false);
      
      if(!edtProfitDecreaseShort.Create(m_chart_id, "edtProfitDecreaseShort", m_subwin, 316, 160, 402, 184)) return(false);
      //edtProfitDecreaseShort.Text("1234567.12");
      edtProfitDecreaseShort.Text("0.00");
      edtProfitDecreaseShort.ColorBackground(clrBlack);
      edtProfitDecreaseShort.Color(clrWhite);
      edtProfitDecreaseShort.Font(Font_Name);
      edtProfitDecreaseShort.FontSize(10);
      edtProfitDecreaseShort.ReadOnly(true);
      edtProfitDecreaseShort.TextAlign(ALIGN_RIGHT);
      if(!Add(edtProfitDecreaseShort)) return(false);

      if(!btnAdd1LongOrder.Create(m_chart_id, "btnAdd1LongOrder", m_subwin, 3, 197, 168, 221)) return(false);
      btnAdd1LongOrder.Text("Add a Buy Order");
      btnAdd1LongOrder.Color(clrWhite);
      btnAdd1LongOrder.ColorBackground(clrMediumBlue);
      btnAdd1LongOrder.Font(Font_Name);
      btnAdd1LongOrder.FontSize(14);
      if(!Add(btnAdd1LongOrder)) return(false);
      
      if(!btnAdd1ShortOrder.Create(m_chart_id, "btnAdd1ShortOrder", m_subwin, 210, 197, 375, 221)) return(false);
      btnAdd1ShortOrder.Text("Add a Sell Order");
      btnAdd1ShortOrder.Color(clrWhite);
      btnAdd1ShortOrder.ColorBackground(clrMaroon);
      btnAdd1ShortOrder.Font(Font_Name);
      btnAdd1ShortOrder.FontSize(14);
      if(!Add(btnAdd1ShortOrder)) return(false);

      if(!btnCloseTheMaxLongOrder.Create(m_chart_id, "btnCloseTheMaxLongOrder", m_subwin, 3, 234, 122, 258)) return(false);
      btnCloseTheMaxLongOrder.Text("Close Max Buy Order");
      btnCloseTheMaxLongOrder.Color(clrBlack);
      btnCloseTheMaxLongOrder.ColorBackground(clrPaleGreen);
      btnCloseTheMaxLongOrder.Font(Font_Name);
      btnCloseTheMaxLongOrder.FontSize(8);
      if(!Add(btnCloseTheMaxLongOrder)) return(false);
      
      if(!edtProfitCloseTheMaxLongOrder.Create(m_chart_id, "edtProfitCloseTheMaxLongOrder", m_subwin, 124, 234, 193, 258)) return(false);
      //edtProfitCloseTheMaxLongOrder.Text("12345.12");
      edtProfitCloseTheMaxLongOrder.Text("0.00");
      edtProfitCloseTheMaxLongOrder.ColorBackground(clrBlack);
      edtProfitCloseTheMaxLongOrder.Color(clrWhite);
      edtProfitCloseTheMaxLongOrder.Font(Font_Name);
      edtProfitCloseTheMaxLongOrder.FontSize(10);
      edtProfitCloseTheMaxLongOrder.ReadOnly(true);
      edtProfitCloseTheMaxLongOrder.TextAlign(ALIGN_RIGHT);
      if(!Add(edtProfitCloseTheMaxLongOrder)) return(false);
      
      if(!btnCloseTheMaxShortOrder.Create(m_chart_id, "btnCloseTheMaxShortOrder", m_subwin, 210, 234, 329, 258)) return(false);
      btnCloseTheMaxShortOrder.Text("Close Max Sell Order");
      btnCloseTheMaxShortOrder.Color(clrBlack);
      btnCloseTheMaxShortOrder.ColorBackground(clrRosyBrown);
      btnCloseTheMaxShortOrder.Font(Font_Name);
      btnCloseTheMaxShortOrder.FontSize(8);
      if(!Add(btnCloseTheMaxShortOrder)) return(false);
      
      if(!edtProfitCloseTheMaxShortOrder.Create(m_chart_id, "edtProfitCloseTheMaxShortOrder", m_subwin, 331, 234, 402, 258)) return(false);
      //edtProfitCloseTheMaxShortOrder.Text("12345.12");
      edtProfitCloseTheMaxShortOrder.Text("0.00");
      edtProfitCloseTheMaxShortOrder.ColorBackground(clrBlack);
      edtProfitCloseTheMaxShortOrder.Color(clrWhite);
      edtProfitCloseTheMaxShortOrder.Font(Font_Name);
      edtProfitCloseTheMaxShortOrder.FontSize(10);
      edtProfitCloseTheMaxShortOrder.ReadOnly(true);
      edtProfitCloseTheMaxShortOrder.TextAlign(ALIGN_RIGHT);
      if(!Add(edtProfitCloseTheMaxShortOrder)) return(false);
      
      if(!lblTargetProfitCloseLongWords.Create(m_chart_id, "lblTargetProfitCloseLongWords", m_subwin, 1, 284, 105, 300)) return(false);
      lblTargetProfitCloseLongWords.Text("Buy Target Profit：");
      lblTargetProfitCloseLongWords.Color(clrWhite);
      lblTargetProfitCloseLongWords.Font(Font_Name);
      lblTargetProfitCloseLongWords.FontSize(9);
      if(!Add(lblTargetProfitCloseLongWords)) return(false);
      
      if(!edtTargetProfitCloseLong.Create(m_chart_id, "edtTargetProfitCloseLong", m_subwin, 107, 282, 193, 300)) return(false);
      //edtTargetProfitCloseLong.Text("1234567.12");
      edtTargetProfitCloseLong.Text("0.00");
      edtTargetProfitCloseLong.ColorBackground(clrBlack);
      edtTargetProfitCloseLong.Color(clrWhite);
      edtTargetProfitCloseLong.Font(Font_Name);
      edtTargetProfitCloseLong.FontSize(10);
      edtTargetProfitCloseLong.ReadOnly(true);
      edtTargetProfitCloseLong.TextAlign(ALIGN_RIGHT);
      if(!Add(edtTargetProfitCloseLong)) return(false);

      if(!lblTargetProfitCloseShortWords.Create(m_chart_id, "lblTargetProfitCloseShortWords", m_subwin, 210, 284, 314, 300)) return(false);
      lblTargetProfitCloseShortWords.Text("Sell Target Profit：");
      lblTargetProfitCloseShortWords.Color(clrWhite);
      lblTargetProfitCloseShortWords.Font(Font_Name);
      lblTargetProfitCloseShortWords.FontSize(9);
      if(!Add(lblTargetProfitCloseShortWords)) return(false);
      
      if(!edtTargetProfitCloseShort.Create(m_chart_id, "edtTargetProfitCloseShort", m_subwin, 316, 282, 402, 300)) return(false);
      //edtTargetProfitCloseShort.Text("1234567.12");
      edtTargetProfitCloseShort.Text("0.00");
      edtTargetProfitCloseShort.ColorBackground(clrBlack);
      edtTargetProfitCloseShort.Color(clrWhite);
      edtTargetProfitCloseShort.Font(Font_Name);
      edtTargetProfitCloseShort.FontSize(10);
      edtTargetProfitCloseShort.ReadOnly(true);
      edtTargetProfitCloseShort.TextAlign(ALIGN_RIGHT);
      if(!Add(edtTargetProfitCloseShort)) return(false);
      
      if(!lblTargetRetraceLongWords.Create(m_chart_id, "lblTargetRetraceLongWords", m_subwin, 1, 305, 105, 323)) return(false);
      lblTargetRetraceLongWords.Text("Buy Retrace：");
      lblTargetRetraceLongWords.Color(clrWhite);
      lblTargetRetraceLongWords.Font(Font_Name);
      lblTargetRetraceLongWords.FontSize(9);
      if(!Add(lblTargetRetraceLongWords)) return(false);
      
      if(!edtTargetRetraceLong.Create(m_chart_id, "edtTargetRetraceLong", m_subwin, 107, 303, 193, 323)) return(false);
      //edtTargetRetraceLong.Text("0.1234");
      edtTargetRetraceLong.Text("0.0000");
      edtTargetRetraceLong.ColorBackground(clrBlack);
      edtTargetRetraceLong.Color(clrWhite);
      edtTargetRetraceLong.Font(Font_Name);
      edtTargetRetraceLong.FontSize(10);
      edtTargetRetraceLong.ReadOnly(true);
      edtTargetRetraceLong.TextAlign(ALIGN_RIGHT);
      if(!Add(edtTargetRetraceLong)) return(false);

      if(!lblTargetRetraceShortWords.Create(m_chart_id, "lblTargetRetraceShortWords", m_subwin, 210, 305, 314, 323)) return(false);
      lblTargetRetraceShortWords.Text("Sell Retrace：");
      lblTargetRetraceShortWords.Color(clrWhite);
      lblTargetRetraceShortWords.Font(Font_Name);
      lblTargetRetraceShortWords.FontSize(9);
      if(!Add(lblTargetRetraceShortWords)) return(false);
      
      if(!edtTargetRetraceShort.Create(m_chart_id, "edtTargetRetraceShort", m_subwin, 316, 303, 402, 323)) return(false);
      //edtTargetRetraceShort.Text("0.1234");
      edtTargetRetraceShort.Text("0.0000");
      edtTargetRetraceShort.ColorBackground(clrBlack);
      edtTargetRetraceShort.Color(clrWhite);
      edtTargetRetraceShort.Font(Font_Name);
      edtTargetRetraceShort.FontSize(10);
      edtTargetRetraceShort.ReadOnly(true);
      edtTargetRetraceShort.TextAlign(ALIGN_RIGHT);
      if(!Add(edtTargetRetraceShort)) return(false);
      
      if(!lblAddPositionTimesLongWords.Create(m_chart_id, "lblAddPositionTimesLongWords", m_subwin, 1, 328, 105, 346)) return(false);
      lblAddPositionTimesLongWords.Text("Buy Add Position Times：");
      lblAddPositionTimesLongWords.Color(clrWhite);
      lblAddPositionTimesLongWords.Font(Font_Name);
      lblAddPositionTimesLongWords.FontSize(9);
      if(!Add(lblAddPositionTimesLongWords)) return(false);
      
      if(!edtAddPositionTimesLong.Create(m_chart_id, "edtAddPositionTimesLong", m_subwin, 165, 326, 193, 346)) return(false);
      //edtAddPositionTimesLong.Text("12");
      edtAddPositionTimesLong.Text("-1");
      edtAddPositionTimesLong.ColorBackground(clrBlack);
      edtAddPositionTimesLong.Color(clrWhite);
      edtAddPositionTimesLong.Font(Font_Name);
      edtAddPositionTimesLong.FontSize(10);
      edtAddPositionTimesLong.ReadOnly(true);
      edtAddPositionTimesLong.TextAlign(ALIGN_RIGHT);
      if(!Add(edtAddPositionTimesLong)) return(false);

      if(!lblAddPositionTimesShortWords.Create(m_chart_id, "lblAddPositionTimesShortWords", m_subwin, 210, 328, 314, 346)) return(false);
      lblAddPositionTimesShortWords.Text("Sell Add Position Times：");
      lblAddPositionTimesShortWords.Color(clrWhite);
      lblAddPositionTimesShortWords.Font(Font_Name);
      lblAddPositionTimesShortWords.FontSize(9);
      if(!Add(lblAddPositionTimesShortWords)) return(false);
      
      if(!edtAddPositionTimesShort.Create(m_chart_id, "edtAddPositionTimesShort", m_subwin, 374, 326, 402, 346)) return(false);
      //edtAddPositionTimesShort.Text("12");
      edtAddPositionTimesShort.Text("-1");
      edtAddPositionTimesShort.ColorBackground(clrBlack);
      edtAddPositionTimesShort.Color(clrWhite);
      edtAddPositionTimesShort.Font(Font_Name);
      edtAddPositionTimesShort.FontSize(10);
      edtAddPositionTimesShort.ReadOnly(true);
      edtAddPositionTimesShort.TextAlign(ALIGN_RIGHT);
      if(!Add(edtAddPositionTimesShort)) return(false);
      
      
      if(!edtVerticalLine2.Create(m_chart_id, "edtVerticalLine2", m_subwin, 408, 1, 411, 350)) return(false);
      edtVerticalLine2.ColorBackground(clrCoral);
      edtVerticalLine2.ColorBorder(clrCoral);
      edtVerticalLine2.ReadOnly(false);
      if(!Add(edtVerticalLine2)) return(false);
      
      /******************Input Parameters********************************/
      if(!lblParametersWords.Create(m_chart_id, "lblParametersWords", m_subwin, 420, 1, 590, 25)) return(false);
      lblParametersWords.Text("Input Parameters");
      lblParametersWords.Color(clrWhite);
      lblParametersWords.Font(Font_Name);
      lblParametersWords.FontSize(18);
      if(!Add(lblParametersWords)) return(false);
      
      if(!lblInitLotSize.Create(m_chart_id, "lblInitLotSize", m_subwin, 434, 32, 495, 50)) return(false);
      lblInitLotSize.Text("Init Lots：");
      lblInitLotSize.Color(clrWhite);
      lblInitLotSize.Font(Font_Name);
      lblInitLotSize.FontSize(9);
      if(!Add(lblInitLotSize)) return(false);
      
      if(!sefInitLotSize.Create(m_chart_id, "sefInitLotSize", m_subwin, 500, 30, 628, 50)) return(false);
      sefInitLotSize.MinValue(0.01);
      sefInitLotSize.MaxValue(999.99);
      sefInitLotSize.Value(initLots);
      if(!Add(sefInitLotSize)) return(false);
      
      if(!lblGridPoints.Create(m_chart_id, "lblGridPoints", m_subwin, 416, 54, 495, 70)) return(false);
      lblGridPoints.Text("Grid Points：");
      lblGridPoints.Color(clrWhite);
      lblGridPoints.Font(Font_Name);
      lblGridPoints.FontSize(9);
      if(!Add(lblGridPoints)) return(false);
      
      if(!speGridPoints.Create(m_chart_id, "speGridPoints", m_subwin, 500, 52, 628, 70)) return(false);
      speGridPoints.MinValue(100);
      speGridPoints.MaxValue(100000);
      speGridPoints.Value(grid);
      if(!Add(speGridPoints)) return(false);

      if(!lblTakeProfitPoints.Create(m_chart_id, "lblTakeProfitPoints", m_subwin, 413, 74, 545, 90)) return(false);
      lblTakeProfitPoints.Text("Take Profit Points：");
      lblTakeProfitPoints.Color(clrWhite);
      lblTakeProfitPoints.Font(Font_Name);
      lblTakeProfitPoints.FontSize(9);
      if(!Add(lblTakeProfitPoints)) return(false);
      
      if(!speTakeProfitPoints.Create(m_chart_id, "speTakeProfitPoints", m_subwin, 550, 72, 628, 90)) return(false);
      speTakeProfitPoints.MinValue(10);
      speTakeProfitPoints.MaxValue(100000);
      speTakeProfitPoints.Value(tpPoints);
      if(!Add(speTakeProfitPoints)) return(false);

      if(!lblRetraceProfitCoefficient.Create(m_chart_id, "lblRetraceProfitCoefficient", m_subwin, 413, 94, 545, 110)) return(false);
      lblRetraceProfitCoefficient.Text("Retrace Coefficient：");
      lblRetraceProfitCoefficient.Color(clrWhite);
      lblRetraceProfitCoefficient.Font(Font_Name);
      lblRetraceProfitCoefficient.FontSize(9);
      if(!Add(lblRetraceProfitCoefficient)) return(false);
      
      if(!sefRetraceProfitCoefficient.Create(m_chart_id, "sefRetraceProfitCoefficient", m_subwin, 550, 92, 628, 110)) return(false);
      sefRetraceProfitCoefficient.MinValue(0.05);
      sefRetraceProfitCoefficient.MaxValue(999.99);
      sefRetraceProfitCoefficient.Value(retraceProfitRatio);
      if(!Add(sefRetraceProfitCoefficient)) return(false);

      if(!lblMaxTimesAddPosition.Create(m_chart_id, "lblMaxTimesAddPosition", m_subwin, 413, 114, 575, 130)) return(false);
      lblMaxTimesAddPosition.Text("Max Add Position Times：");
      lblMaxTimesAddPosition.Color(clrWhite);
      lblMaxTimesAddPosition.Font(Font_Name);
      lblMaxTimesAddPosition.FontSize(9);
      if(!Add(lblMaxTimesAddPosition)) return(false);
      
      if(!speMaxTimesAddPosition.Create(m_chart_id, "speMaxTimesAddPosition", m_subwin, 580, 112, 628, 130)) return(false);
      speMaxTimesAddPosition.MinValue(3);
      speMaxTimesAddPosition.MaxValue(100);
      speMaxTimesAddPosition.Value(maxTimes4AP);
      if(!Add(speMaxTimesAddPosition)) return(false);

      if(!ckbAddPositionByTrend.Create(m_chart_id, "ckbAddPositionByTrend", m_subwin, 420, 132, 628, 150)) return(false);
      ckbAddPositionByTrend.Checked(addPosition2Trend);
      if (addPosition2Trend) {
         ckbAddPositionByTrend.Text("    Add Position By Trend");
      } else {
         ckbAddPositionByTrend.Text("   Don't Add Position By Trend");
      }
      if(!Add(ckbAddPositionByTrend)) return(false);

      if(!lblCloseMode.Create(m_chart_id, "lblCloseMode", m_subwin, 420, 154, 495, 170)) return(false);
      lblCloseMode.Text("Close Mode：");
      lblCloseMode.Color(clrWhite);
      lblCloseMode.Font(Font_Name);
      lblCloseMode.FontSize(9);
      if(!Add(lblCloseMode)) return(false);
      
      if(!cmbCloseMode.Create(m_chart_id, "cmbCloseMode", m_subwin, 500, 152, 628, 170)) return(false);
      if(!cmbCloseMode.ItemAdd("Close_All")) return(false);
      if(!cmbCloseMode.ItemAdd("Close_Part")) return(false);
      if(!cmbCloseMode.ItemAdd("Close_Part_All")) return(false);
      if (Close_All == CloseMode) {
         if(!cmbCloseMode.SelectByText("Close_All")) return (false);
      } else if (Close_Part == CloseMode) {
         if(!cmbCloseMode.SelectByText("Close_Part")) return (false);
      } else {
         if(!cmbCloseMode.SelectByText("Close_Part_All")) return (false);
      }
      
      if(!Add(cmbCloseMode)) return(false);
      
      if(!lblAddPositionMode.Create(m_chart_id, "lblAddPositionMode", m_subwin, 420, 174, 545, 190)) return(false);
      lblAddPositionMode.Text("Add Position Mode：");
      lblAddPositionMode.Color(clrWhite);
      lblAddPositionMode.Font(Font_Name);
      lblAddPositionMode.FontSize(9);
      if(!Add(lblAddPositionMode)) return(false);
      
      if(!cmbAddPositionMode.Create(m_chart_id, "cmbAddPositionMode", m_subwin, 550, 172, 628, 190)) return(false);
      if(!cmbAddPositionMode.ItemAdd("Fixed")) return(false);
      if(!cmbAddPositionMode.ItemAdd("Multiplied")) return(false);
      if (Fixed == AddPositionMode) {
         if(!cmbAddPositionMode.SelectByText("Fixed")) return (false);
      } else {
         if(!cmbAddPositionMode.SelectByText("Multiplied")) return (false);
      }
      if(!Add(cmbAddPositionMode)) return(false);
      
      if(!lblLotAddPositionStep.Create(m_chart_id, "lblLotAddPositionStep", m_subwin, 413, 194, 555, 210)) return(false);
      lblLotAddPositionStep.Text("Lots Add Position Step：");
      lblLotAddPositionStep.Color(clrWhite);
      lblLotAddPositionStep.Font(Font_Name);
      lblLotAddPositionStep.FontSize(9);
      if(!Add(lblLotAddPositionStep)) return(false);
      
      if(!sefLotAddPositionStep.Create(m_chart_id, "sefLotAddPositionStep", m_subwin, 560, 192, 628, 210)) return(false);
      sefLotAddPositionStep.MinValue(0.01);
      sefLotAddPositionStep.MaxValue(999.99);
      sefLotAddPositionStep.Value(lotStep);
      if(!Add(sefLotAddPositionStep)) return(false);
      
      if(!lblLotAddPositionMultiple.Create(m_chart_id, "lblLotAddPositionMultiple", m_subwin, 413, 214, 575, 230)) return(false);
      lblLotAddPositionMultiple.Text("Lots Add Position Multiple：");
      lblLotAddPositionMultiple.Color(clrWhite);
      lblLotAddPositionMultiple.Font(Font_Name);
      lblLotAddPositionMultiple.FontSize(9);
      if(!Add(lblLotAddPositionMultiple)) return(false);
      
      if(!sefLotAddPositionMultiple.Create(m_chart_id, "sefLotAddPositionMultiple", m_subwin, 580, 212, 628, 230)) return(false);
      sefLotAddPositionMultiple.MinValue(1.1);
      sefLotAddPositionMultiple.MaxValue(10.0);
      sefLotAddPositionMultiple.Value(lotMultiple);
      if(!Add(sefLotAddPositionMultiple)) return(false);
      
      if(!lblMaxLots4AddPositionLimit.Create(m_chart_id, "lblMaxLots4AddPositionLimit", m_subwin, 413, 234, 555, 250)) return(false);
      lblMaxLots4AddPositionLimit.Text("Max Add Position Lots：");
      lblMaxLots4AddPositionLimit.Color(clrWhite);
      lblMaxLots4AddPositionLimit.Font(Font_Name);
      lblMaxLots4AddPositionLimit.FontSize(9);
      if(!Add(lblMaxLots4AddPositionLimit)) return(false);
      
      if(!sefMaxLots4AddPositionLimit.Create(m_chart_id, "sefMaxLots4AddPositionLimit", m_subwin, 560, 232, 628, 250)) return(false);
      sefMaxLots4AddPositionLimit.MinValue(0.01);
      sefMaxLots4AddPositionLimit.MaxValue(100.00);
      sefMaxLots4AddPositionLimit.Value(Max_Lot_AP);
      if(!Add(sefMaxLots4AddPositionLimit)) return(false);

      if(!lblMagicNumberWords.Create(m_chart_id, "lblMagicNumberWords", m_subwin, 413, 254, 505, 270)) return(false);
      lblMagicNumberWords.Text("Magic Number：");
      lblMagicNumberWords.Color(clrWhite);
      lblMagicNumberWords.Font(Font_Name);
      lblMagicNumberWords.FontSize(9);
      if(!Add(lblMagicNumberWords)) return(false);
      
      if(!edtMagicNumber.Create(m_chart_id, "edtMagicNumber", m_subwin, 510, 252, 628, 270)) return(false);
      edtMagicNumber.Text(IntegerToString(MagicNumber));
      edtMagicNumber.ColorBackground(clrBlack);
      edtMagicNumber.Color(clrWhite);
      edtMagicNumber.Font(Font_Name);
      edtMagicNumber.FontSize(9);
      edtMagicNumber.ReadOnly(true);
      edtMagicNumber.TextAlign(ALIGN_RIGHT);
      if(!Add(edtMagicNumber)) return(false);
      
      return(true);
   }
   
   bool run(void) {
      //--- redraw chart for dialog invalidate
      m_chart.Redraw();
      //--- here we begin to assign IDs to controls
      if( Id(m_subwin*CONTROLS_MAXIMUM_ID) > CONTROLS_MAXIMUM_ID ) {
         Print("COpPanel: too many objects");
         return(false);
      }
      return(true);
   }
   
   
   void refreshTotalProfit(double totalProfit) {
      edtTotalProfit.Text(DoubleToStr(totalProfit, 2));
      if (0 < totalProfit) {
         edtTotalProfit.Color(clrGreen);
      } else if (totalProfit < 0) {
         edtTotalProfit.Color(clrRed);
      } else {
         edtTotalProfit.Color(clrWhite);
      }
   }
   
   void refreshProfitCloseLong(double profit) {
      edtProfitCloseLong.Text(DoubleToStr(profit, 2));
      if (0 < profit) {
         edtProfitCloseLong.Color(clrGreen);
      } else if (profit < 0) {
         edtProfitCloseLong.Color(clrRed);
      } else {
         edtProfitCloseLong.Color(clrWhite);
      }
   }
   
   void refreshProfitCloseShort(double profit) {
      edtProfitCloseShort.Text(DoubleToStr(profit, 2));
      if (0 < profit) {
         edtProfitCloseShort.Color(clrGreen);
      } else if (profit < 0) {
         edtProfitCloseShort.Color(clrRed);
      } else {
         edtProfitCloseShort.Color(clrWhite);
      }
   }
   
   void refreshProfitDecreaseLong(double profit) {
      edtProfitDecreaseLong.Text(DoubleToStr(profit, 2));
      if (0 < profit) {
         edtProfitDecreaseLong.Color(clrGreen);
      } else if (profit < 0) {
         edtProfitDecreaseLong.Color(clrRed);
      } else {
         edtProfitDecreaseLong.Color(clrWhite);
      }
   }
   
   void refreshProfitDecreaseShort(double profit) {
      edtProfitDecreaseShort.Text(DoubleToStr(profit, 2));
      if (0 < profit) {
         edtProfitDecreaseShort.Color(clrGreen);
      } else if (profit < 0) {
         edtProfitDecreaseShort.Color(clrRed);
      } else {
         edtProfitDecreaseShort.Color(clrWhite);
      }
   }
   
   void refreshProfitCloseMaxOrderLong(double profit) {
      edtProfitCloseTheMaxLongOrder.Text(DoubleToStr(profit, 2));
      if (0 < profit) {
         edtProfitCloseTheMaxLongOrder.Color(clrGreen);
      } else if (profit < 0) {
         edtProfitCloseTheMaxLongOrder.Color(clrRed);
      } else {
         edtProfitCloseTheMaxLongOrder.Color(clrWhite);
      }
   }
   
   void refreshProfitCloseMaxOrderShort(double profit) {
      edtProfitCloseTheMaxShortOrder.Text(DoubleToStr(profit, 2));
      if (0 < profit) {
         edtProfitCloseTheMaxShortOrder.Color(clrGreen);
      } else if (profit < 0) {
         edtProfitCloseTheMaxShortOrder.Color(clrRed);
      } else {
         edtProfitCloseTheMaxShortOrder.Color(clrWhite);
      }
   }
   
   void refreshTargetProfitLong(double targetProfit) {
      edtTargetProfitCloseLong.Text(DoubleToStr(targetProfit, 2));
      if (targetProfit < 0) {
         edtTargetProfitCloseLong.Color(clrRed);
      } else {
         edtTargetProfitCloseLong.Color(clrWhite);
      }
   }

   void refreshTargetProfitShort(double targetProfit) {
      edtTargetProfitCloseShort.Text(DoubleToStr(targetProfit, 2));
      if (targetProfit < 0) {
         edtTargetProfitCloseShort.Color(clrRed);
      } else {
         edtTargetProfitCloseShort.Color(clrWhite);
      }
   }
   
   void refreshTargetRetraceLong(double retrace) {
      edtTargetRetraceLong.Text(DoubleToStr(retrace, 5));
   }
   
   void refreshTargetRetraceShort(double retrace) {
      edtTargetRetraceShort.Text(DoubleToStr(retrace, 5));
   }
   
   void refreshAddPositionTimesLong(int addPositionTimes) {
      edtAddPositionTimesLong.Text(IntegerToString(addPositionTimes));
   }
   
   void refreshAddPositionTimesShort(int addPositionTimes) {
      edtAddPositionTimesShort.Text(IntegerToString(addPositionTimes));
   }
   
   void stopEA() {
      isActive = false;
      btnStopStart.Text("Start");
      btnStopStart.Color(clrWhite);
      btnStopStart.ColorBackground(clrDarkGreen);
   }
   
   void resumeEA() {
      isActive = true;
      btnStopStart.Text("Stop");
      btnStopStart.Color(clrWhite);
      btnStopStart.ColorBackground(clrMaroon);
   }
   
   void onClickBtnStopStart() {
      if (isActive) {
         stopEA();
      } else {
         resumeEA();
      }
   }
   
   void OnClickBtnForbidAllow() {
      if (isForbidCreateOrderManual) {
         isForbidCreateOrderManual = false;
         btnForbidAllow.Text("Forbid");
         btnForbidAllow.Color(clrWhite);
         btnForbidAllow.ColorBackground(clrMaroon);
      } else {
         isForbidCreateOrderManual = true;
         btnForbidAllow.Text("Allow");
         btnForbidAllow.Color(clrBlack);
         btnForbidAllow.ColorBackground(clrLime);
      }
   }

   void setCloseBuyButton(enButtonMode btnMode) {
      if (Close_Order_Mode == btnMode) {
         btnCloseLong.Text("Close Buy");
      } else {
         btnCloseLong.Text("Create Buy");
      }
      btnModeBuy = btnMode;
   }
   
   void setCloseSellButton(enButtonMode btnMode) {
      if (Close_Order_Mode == btnMode) {
         btnCloseShort.Text("Close Sell");
      } else {
         btnCloseShort.Text("Create Sell");
      }
      btnModeSell = btnMode;
   }

   void onClickBtnCloseLong() {
      if (Close_Order_Mode == btnModeBuy) {
         if (0 <= countAPBuy) {
            CloseAllBuy();
            resetStateBuy();
            setCloseBuyButton(Create_Order_Mode);
            SetComments();
         }
      } else {
         createOrderBuy(initLotSize4Buy);
         setCloseBuyButton(Close_Order_Mode);
         SetComments();
      }
   }
   
   void onClickBtnCloseShort() {
      if (Close_Order_Mode == btnModeSell) {
         if (0 <= countAPSell) {
            CloseAllSell();
            resetStateSell();
            setCloseSellButton(Create_Order_Mode);
            SetComments();
         }
      } else {
         createOrderSell(initLotSize4Sell);
         setCloseSellButton(Close_Order_Mode);
         SetComments();
      }
   }
   
   void onClickBtnDecreaseLong() {
      if (0 < countAPBuy) {
         DecreaseLongPosition();
         SetComments();
      }
   }
   
   void onClickBtnDecreaseShort() {
      if (0 < countAPSell) {
         DecreaseShortPosition();
         SetComments();
      }
   }
   
   /*******************TODO BEGIN***********************/
   void onClickBtnAdd1LongOrder() {
      doAP4LongByManual();
   }
   
   void onClickBtnAdd1ShortOrder() {
      doAP4ShortByManual();
   }
   
   void onClickBtnCloseTheMaxLongOrder() {
      closeMaxAPLongOrder();
   }
   
   void onClickBtnCloseTheMaxShortOrder() {
      closeMaxAPShortOrder();
   }
   
   /******************TODO END**********************/
   
   void OnChangeSefInitLotSize() {
      initLots = StrToDouble(sefInitLotSize.Value());
      printf("initLots is changed to " + DoubleToStr(initLots, 2));
   }
   
   void OnChangeSpeGridPoints() {
      if (0 == countOrders()) {
         grid = StrToInteger(speGridPoints.Value());
         gridPrice = NormalizeDouble(Point * grid, Digits);
         printf("grid is changed to " + IntegerToString(grid));
         resetRetrace4Buy();
         resetRetrace4Sell();
      } else {
         Alert("Orders > 0, you can't change it.");
      }
   }

   void OnChangeSpeTakeProfitPoints() {
      tpPoints = StrToInteger(speTakeProfitPoints.Value());
      tp = NormalizeDouble(Point * tpPoints, Digits);
      printf("tpPoints is changed to " + IntegerToString(tpPoints));
   }

   void OnChangeSefRetraceProfitCoefficient() {
      retraceProfitRatio = StrToDouble(sefRetraceProfitCoefficient.Value());
      printf("retraceProfitRatio is changed to " + DoubleToStr(retraceProfitRatio, 2));
      resetRetrace4Buy();
      resetRetrace4Sell();
   }

   void OnChangeSpeMaxTimesAddPosition() {
      maxTimes4AP = StrToInteger(speMaxTimesAddPosition.Value());
      times_Part2All = maxTimes4AP - 3;
      printf("maxTimes4AP is changed to " + IntegerToString(maxTimes4AP));
   }
   
   void OnChangeCkbAddPositionByTrend() {
      addPosition2Trend = ckbAddPositionByTrend.Checked();
      if (addPosition2Trend) {
         ckbAddPositionByTrend.Text("    Add Position By Trend");
         printf("addPosition2Trend is changed to true");
      } else {
         ckbAddPositionByTrend.Text("   Don't Add Position By Trend");
         printf("addPosition2Trend is changed to false");
      }
      
   }

   void OnChangeSefLotAddPositionStep() {
      lotStep = StrToDouble(sefLotAddPositionStep.Value());
      printf("lotStep is changed to " + DoubleToStr(lotStep, 2));
   }

   void OnChangeSefLotAddPositionMultiple() {
      if (0 == countOrders()) {
         lotMultiple = StrToDouble(sefLotAddPositionMultiple.Value());
         printf("lotMultiple is changed to " + DoubleToStr(lotMultiple, 2));
         resetRetrace4Buy();
         resetRetrace4Sell();
      } else {
         Alert("Orders > 0, you can't change it.");
      }
   }

   void OnChangeSefMaxLots4AddPositionLimit() {
      Max_Lot_AP = StrToDouble(sefMaxLots4AddPositionLimit.Value());
      printf("Max_Lot_AP is changed to " + DoubleToStr(Max_Lot_AP, 2));
   }
   
   void OnChangeCmbCloseMode() {
      string closeModeText = cmbCloseMode.Select();
      if ("Close_All" == closeModeText) {
         closePositionMode = Close_All;
      } else if ("Close_Part" == closeModeText) {
         closePositionMode = Close_Part;
      } else {
         closePositionMode = Close_Part_All;
      }
      resetRetrace4Buy();
      resetRetrace4Sell();
      printf("closePositionMode is changed to " + closeModeText);
   }
   
   void OnChangeCmbAddPositionMode() {
      if (0 == countOrders()) {
         string addPositionModeText = cmbAddPositionMode.Select();
         if ("Fixed" == addPositionModeText) {
            addPositionMode = Fixed;
         } else {
            addPositionMode = Multiplied;
         }
         printf("addPositionMode is changed to " + addPositionModeText);
         resetRetrace4Buy();
         resetRetrace4Sell();
      } else {
         Alert("Orders > 0, you can't change it.");
      }
   }
   
};
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+

EVENT_MAP_BEGIN(COpPanel)
ON_EVENT(ON_CLICK, btnStopStart,                onClickBtnStopStart)
ON_EVENT(ON_CLICK, btnForbidAllow,              OnClickBtnForbidAllow)
ON_EVENT(ON_CLICK, btnCloseLong,                onClickBtnCloseLong)
ON_EVENT(ON_CLICK, btnCloseShort,               onClickBtnCloseShort)
ON_EVENT(ON_CLICK, btnDecreaseLong,             onClickBtnDecreaseLong)
ON_EVENT(ON_CLICK, btnDecreaseShort,            onClickBtnDecreaseShort)

ON_EVENT(ON_CLICK, btnAdd1LongOrder,            onClickBtnAdd1LongOrder)
ON_EVENT(ON_CLICK, btnAdd1ShortOrder,           onClickBtnAdd1ShortOrder)
ON_EVENT(ON_CLICK, btnCloseTheMaxLongOrder,     onClickBtnCloseTheMaxLongOrder)
ON_EVENT(ON_CLICK, btnCloseTheMaxShortOrder,    onClickBtnCloseTheMaxShortOrder)

ON_EVENT(ON_CHANGE, sefInitLotSize,                OnChangeSefInitLotSize)
ON_EVENT(ON_CHANGE, speGridPoints,                 OnChangeSpeGridPoints)
ON_EVENT(ON_CHANGE, speTakeProfitPoints,           OnChangeSpeTakeProfitPoints)
ON_EVENT(ON_CHANGE, sefRetraceProfitCoefficient,   OnChangeSefRetraceProfitCoefficient)
ON_EVENT(ON_CHANGE, speMaxTimesAddPosition,        OnChangeSpeMaxTimesAddPosition)
ON_EVENT(ON_CHANGE, ckbAddPositionByTrend,         OnChangeCkbAddPositionByTrend)
ON_EVENT(ON_CHANGE, sefLotAddPositionStep,         OnChangeSefLotAddPositionStep)
ON_EVENT(ON_CHANGE, sefLotAddPositionMultiple,     OnChangeSefLotAddPositionMultiple)
ON_EVENT(ON_CHANGE, sefMaxLots4AddPositionLimit,   OnChangeSefMaxLots4AddPositionLimit)

ON_EVENT(ON_CHANGE, cmbCloseMode,                  OnChangeCmbCloseMode)
ON_EVENT(ON_CHANGE, cmbAddPositionMode,            OnChangeCmbAddPositionMode)

//ON_OTHER_EVENTS(OnDefault)
EVENT_MAP_END(CAppWindowWithoutCloseButton)

//+------------------------------------------------------------------+
      COpPanel    opPanel;

int countOrders() {
   int orderNumber = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      if ( OrderSelect(i, SELECT_BY_POS) ) {
         if ( OrderSymbol() == _Symbol && MagicNumber == OrderMagicNumber() ) {
            orderNumber++;
         }
      }
   }
   
   return orderNumber;
}

bool isAuthorized() {
   if (!AccountCtrl) {
      return true;
   }
   int size = ArraySize(AuthorizeAccountList);
   int curAccount = AccountNumber();
   for (int i = 0; i < size; i++) {
      if (curAccount == AuthorizeAccountList[i]) {
         return true;
      }
   }
   Alert("你的交易账号未经授权！联系QQ:183947281！");
   return false;
}

int OnInit() {

   if (!isAuthorized()) {
		return INIT_FAILED;
	}

   if (enableUseLimit) {
      datetime now = TimeGMT();
      if (expireTime < now) {
         return INIT_FAILED;
      }
   }

   if (0 < countOrders()) {
      Alert("Order Exist。Please manually delete Order or modify input parameter MagicNumber.");
      return(INIT_FAILED);
   }

   double minLot = MarketInfo(_Symbol, MODE_MINLOT);
   if (InitLotSize < minLot) {
      initLots = minLot;
   } else {
      initLots = InitLotSize;
   }
   
   grid = GridPoints;
   gridPrice = NormalizeDouble(Point * grid, Digits);
   
   tpPoints = TakeProfitPoints;
   tp = NormalizeDouble(Point * tpPoints, Digits);
   retraceProfitRatio = RetraceProfitCoefficient;
   maxTimes4AP = MaxTimesAddPosition;
   times_Part2All = maxTimes4AP - 3;
   addPosition2Trend = AddPositionByTrend;
   
   closePositionMode = CloseMode;
   addPositionMode = AddPositionMode;
   
   lotStep = LotAddPositionStep;
   lotMultiple = LotAddPositionMultiple;
   reduceFactor = (lotMultiple-1)/lotMultiple;
   
   initLotSize4Buy = initLots;
   initLotSize4Sell = initLots;
   curInitLotSize4Buy = initLots;
   curInitLotSize4Sell = initLots;
   
   arraySize = maxTimes4AP+1;
   
   ArrayResize(arrOrdersBuy, arraySize);
   ArrayResize(arrOrdersSell, arraySize);
   
   DrawLine(nmLineClosePositionBuy, 0, clrGold, STYLE_DOT);
   DrawLine(nmLineClosePositionSell, 0, clrGold, STYLE_DOT);
   
   btnModeBuy = Close_Order_Mode;
   btnModeSell = Close_Order_Mode;
   
   string fontName = "Lucida Bright";
   
   /*
   if (Fixed == addPositionMode) {
      Max_Lot_AP = initLots*(maxTimes4AP-4);
   } else {
      double lotCoefficient = MathPow(lotMultiple, maxTimes4AP-4);
      Max_Lot_AP = calculateLot(initLots, lotCoefficient);
   }
   */
   Max_Lot_AP = MaxLots4AddPositionLimit;
   isActive = false;
   
   if(!opPanel.create(0, "OperatePanel", 0)) return(INIT_FAILED);

   if(!opPanel.run()) return(INIT_FAILED);
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   ObjectDelete(nmLineClosePositionBuy);
   ObjectDelete(nmLineClosePositionSell);

   opPanel.Destroy(reason);
}


bool isNewBegin(int orderType) {
   int countAP = -2;
   switch(orderType) {
      case OP_BUY:
         countAP = countAPBuy;
         break;
      case OP_SELL:
         countAP = countAPSell;
         break;
      default:
         return false;
   }

   if (-1 == countAP) {
      return true;
   }
   return false;
}

bool isCloseAllMode(int orderType) {

   if (Close_All == closePositionMode) {
      return true;
   }
   
   int countAP = countAPSell;
   if (OP_BUY == orderType) {
      countAP = countAPBuy;
   }
   
   if (Close_Part_All == closePositionMode && times_Part2All <= countAP) {
      return true;
   }
   
   return false;

}

bool isClosePartMode(int orderType) {
   if (Close_Part == closePositionMode) {
      return true;
   }
   
   int countAP = countAPSell;
   if (OP_BUY == orderType) {
      countAP = countAPBuy;
   }
   
   if (Close_Part_All == closePositionMode && countAP < times_Part2All) {
      return true;
   }
   
   return false;
}

void resetRetrace4Buy() {
   if (countAPBuy < 1) {
      return;
   }
   if (Fixed == addPositionMode) {
      retraceRatioBuy = calculateRetrace4Fixed(countAPBuy, initLotSize4Buy) + retraceProfitRatio;
   } else {
      if ( isCloseAllMode(OP_BUY) ) {
         retraceRatioBuy = calculateRetraceAll(countAPBuy, lotMultiple) + retraceProfitRatio;
      } else if ( isClosePartMode(OP_BUY) ) {
         retraceRatioBuy = calculateRetracePart(countAPBuy, lotMultiple) + retraceProfitRatio;
      }
   }
   
   int retracePoints = (int) (grid * retraceRatioBuy);
   double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
   retracePriceBuy = NormalizeDouble(Point * retracePoints, Digits) + minOpenPrice;
   ObjectMove(nmLineClosePositionBuy, 0, 0, retracePriceBuy);
   calculateCloseProfit4Buy();
}

void resetRetrace4Sell() {
   if (countAPSell < 1) {
      return;
   }
   if (Fixed == addPositionMode) {
      retraceRatioSell = calculateRetrace4Fixed(countAPSell, initLotSize4Sell) + retraceProfitRatio;
   } else {
      if ( isCloseAllMode(OP_SELL) ) {
         retraceRatioSell = calculateRetraceAll(countAPSell, lotMultiple) + retraceProfitRatio;
      } else if ( isClosePartMode(OP_SELL) ) {
         retraceRatioSell = calculateRetracePart(countAPSell, lotMultiple) + retraceProfitRatio;
      }
   }
   
   int retracePoints = (int) (grid * retraceRatioSell);
   double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
   retracePriceSell = maxOpenPrice - NormalizeDouble(Point * retracePoints, Digits);
   ObjectMove(nmLineClosePositionSell, 0, 0, retracePriceSell);
   calculateCloseProfit4Sell();
}

double calculateLot(double lotSize, double coefficient) {

   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double lotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   //double lot = MathFloor(lotSize*coefficient/lotStepServer)*lotStepServer;
   //double lot = MathCeil(lotSize*coefficient/lotStepServer)*lotStepServer;
   double lot = MathRound(lotSize*coefficient/lotStepServer)*lotStepServer;
   
   if (lot < minLot) {
      lot = minLot;
   }
   
   return lot;
}

double calculateLot4AP(int orderType) {
   double lotsize;
   int countAP = -2;
   double curInitLotSize;

   switch(orderType) {
      case OP_BUY:
         countAP = countAPBuy;
         curInitLotSize = curInitLotSize4Buy;
         break;
      case OP_SELL:
         countAP = countAPSell;
         curInitLotSize = curInitLotSize4Sell;
         break;
      default:
         return 0;
   }
   
   if (Fixed == addPositionMode) {
      lotsize = initLots + lotStep*(countAP+1);
   } else {
      double lotCoefficient = MathPow(lotMultiple, countAP+1);
      lotsize = calculateLot(curInitLotSize, lotCoefficient);
   }

   return lotsize;
}

double calculateInitLot(int orderType) {
   int countAP = -2;
   switch(orderType) {
      case OP_BUY:
         countAP = countAPSell;
         break;
      case OP_SELL:
         countAP = countAPBuy;
         break;
      default:
         return 0;
   }
   /*
   if (addPosition2Trend) {
      if (Fixed == addPositionMode) {
         return (initLots + lotStep*countAP);
      }
      return calculateLot(initLots, MathPow(lotMultiple, countAP));
   }
   return initLots;
   */
   double lots = initLots;
   if (addPosition2Trend) {
      if (Fixed == addPositionMode) {
         lots = (initLots + lotStep*countAP);
      } else {
         lots = calculateLot(initLots, MathPow(lotMultiple, countAP));
      }
   }
   if (enableMaxLotControl) {
      if (Max_Lot_AP < lots) {
         lots = Max_Lot_AP;
      }
   }
   return lots;
}

bool doAP4LongByManual() {
   if (countAPBuy < 0) {
      return false;
   }
   
   if (maxTimes4AP <= countAPBuy) {
      return false;
   }

   double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
   double addPositionPrice = minOpenPrice - gridPrice;

   RefreshRates();
   double lotsize = calculateLot4AP(OP_BUY);
   createOrderBuy(lotsize);
   resetRetrace4Buy();
   return true;
}

bool addPosition4Buy() {

   if (countAPBuy < 0) {
      return false;
   }
   
   if (maxTimes4AP <= countAPBuy) {
      return false;
   }

   double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
   
   double addPositionPrice = minOpenPrice - gridPrice;
   
   RefreshRates();
   if (Ask < addPositionPrice) {
      double lotsize = calculateLot4AP(OP_BUY);
      createOrderBuy(lotsize);
      resetRetrace4Buy();
      return true;
   }
   
   return false;
}

bool doAP4ShortByManual() {
   if (countAPSell < 0) {
      return false;
   }

   if (maxTimes4AP <= countAPSell) {
      return false;
   }

   double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
   double addPositionPrice = maxOpenPrice + gridPrice;

   RefreshRates();
   double lotsize = calculateLot4AP(OP_SELL);
   createOrderSell(lotsize);
   resetRetrace4Sell();
   return true;
}

bool addPosition4Sell() {

   if (countAPSell < 0) {
      return false;
   }
   
   if (maxTimes4AP <= countAPSell) {
      return false;
   }
   
   double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
   
   double addPositionPrice = maxOpenPrice + gridPrice;
   
   RefreshRates();
   if (addPositionPrice < Bid) {
      double lotsize = calculateLot4AP(OP_SELL);
      createOrderSell(lotsize);
      resetRetrace4Sell();
      return true;
   }
   
   return false;
}

void resetStateBuy() {
   
   countAPBuy = -1;

   ArrayResize(arrOrdersBuy, arraySize);
   
   retraceRatioBuy = 0.0;
   retracePriceBuy = 0.0;
   
   closeProfitBuy = 0.0;

   ObjectMove(nmLineClosePositionBuy, 0, 0, 0.0);
}

void resetStateSell() {
   
   countAPSell = -1;

   ArrayResize(arrOrdersSell, arraySize);
   
   retraceRatioSell = 0.0;
   retracePriceSell = 0.0;
   
   closeProfitSell = 0.0;

   ObjectMove(nmLineClosePositionSell, 0, 0, 0.0);
}

void resetTicket(int orderType) {

   int addPositionCount;
   double orderLot;
   
   for (int i = OrdersTotal()-1; 0 <= i; i--) {
   
      bool isSelected = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSelected) {
         string msg = "OrderSelect failed in resetTicket.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      if (_Symbol != OrderSymbol()) {
         continue;
      }
      
      if (MagicNumber != OrderMagicNumber()) {
         continue;
      }

      if (orderType != OrderType()) {
         continue;
      }
      
      orderLot = OrderLots();
      
      if (OP_BUY == orderType) {
         //addPositionCount = (int) (MathLog10(orderLot/curInitLotSize4Buy)/MathLog10(lotMultiple));
         for (int k = 0; k <= countAPBuy; k++) {
            if (isEqualDouble(arrOrdersBuy[k].openPrice, OrderOpenPrice())) {
               addPositionCount = k;
            }
         }
         arrOrdersBuy[addPositionCount].ticketId = OrderTicket();
         arrOrdersBuy[addPositionCount].lotSize = orderLot;
      } else if (OP_SELL == orderType) {
         //addPositionCount = (int) (MathLog10(orderLot/curInitLotSize4Sell)/MathLog10(lotMultiple));
         for (int k = 0; k <= countAPSell; k++) {
            if (isEqualDouble(arrOrdersSell[k].openPrice, OrderOpenPrice())) {
               addPositionCount = k;
            }
         }
         arrOrdersSell[addPositionCount].ticketId = OrderTicket();
         arrOrdersSell[addPositionCount].lotSize = orderLot;
      }

   }
}

void DecreaseLongPosition() {

   int maxShiftIndex = countAPBuy-1;
   
   double preLot = 0;
   
   for (int i = 0; i <= countAPBuy; i++) {
   
      int ticketId = arrOrdersBuy[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         string msg = "OrderSelect failed in DecreaseLongPosition.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
         continue;
      }

      double lot = OrderLots();
      double closeLot = lot;

      // 非最小单，并且非最大单时（即中间单时）
      if (0 != i && countAPBuy != i) {
         closeLot = lot - preLot;
      }
      
      bool isClosed = OrderClose(OrderTicket(), closeLot, Bid, 0);
      
      if (i < maxShiftIndex) {
         arrOrdersBuy[i] = arrOrdersBuy[i+1];
      }

      preLot = lot;
 
      if (!isClosed) {
         string msg = "Buy OrderClose failed in DecreaseLongPosition. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lot=" + DoubleToStr(closeLot, 2);
         msg += " Bid=" + DoubleToStr(Bid, Digits);
         Alert(msg);
         continue;
      }

   }
   
   countAPBuy = countAPBuy - 2;
   ArrayResize(arrOrdersBuy, arraySize, countAPBuy+1);
   
   resetTicket(OP_BUY);

   if (0 < countAPBuy) {
      resetRetrace4Buy();
      if (addPosition2Trend) {
         initLotSize4Sell = calculateLot(initLots, MathPow(lotMultiple, countAPBuy));
      }
   } else if (0 == countAPBuy) {
      retraceRatioBuy = 0.0;
      retracePriceBuy = 0.0;
      closeProfitBuy = 0.0;
      ObjectMove(nmLineClosePositionBuy, 0, 0, 0.0);
      initLotSize4Sell = initLots;

   } else {
      resetStateBuy();
      initLotSize4Sell = initLots;
   }

}

void DecreaseShortPosition() {

   int maxShiftIndex = countAPSell-1;

   double preLot = 0;
   
   for (int i = 0; i <= countAPSell; i++) {
   
      int ticketId = arrOrdersSell[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
      if (!isSelected) {
         string msg = "OrderSelect failed in DecreaseShortPosition.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
         continue;
      }
      
      double lot = OrderLots();
      double closeLot = lot;
      
      // 非最小单，并且非最大单时（即中间单时）
      if (0 != i && countAPSell != i) {
         closeLot = lot - preLot;
      }
      
      bool isClosed = OrderClose(OrderTicket(), closeLot, Ask, 0);
      
      if (i < maxShiftIndex) {
         arrOrdersSell[i] = arrOrdersSell[i+1];
      }

      preLot = lot;

      if (!isClosed) {
         string msg = "Sell OrderClose failed in DecreaseShortPosition. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lot=" + DoubleToStr(closeLot, 2);
         msg += " Ask=" + DoubleToStr(Ask, Digits);
         Alert(msg);
         continue;
      }

   }
   
   countAPSell = countAPSell - 2;
   ArrayResize(arrOrdersSell, arraySize, countAPSell+1);
   
   resetTicket(OP_SELL);

   if (0 < countAPSell) {
      resetRetrace4Sell();
      if (addPosition2Trend) {
         initLotSize4Buy = calculateLot(initLots, MathPow(lotMultiple, countAPSell));
      }
   } else if (0 == countAPSell) {
      retraceRatioSell = 0.0;
      retracePriceSell = 0.0;
      closeProfitSell = 0.0;
      ObjectMove(nmLineClosePositionSell, 0, 0, 0.0);
      initLotSize4Buy = initLots;
      
   } else {
      resetStateSell();
      initLotSize4Buy = initLots;
   }

}

bool doRetrace4Buy() {

   if (countAPBuy < 1) {
      return false;
   }

   RefreshRates();
   if (retracePriceBuy <= Bid) {
      if (Fixed == addPositionMode || isCloseAllMode(OP_BUY)) {
         CloseAllBuy();
         resetStateBuy();
         return true;
      } else if ( isClosePartMode(OP_BUY) ) {
         DecreaseLongPosition();
         return true;
      }

   }
   
   return false;
}

bool doRetrace4Sell() {

   if (countAPSell < 1) {
      return false;
   }
   
   RefreshRates();
   if (Ask <= retracePriceSell) {
      if (Fixed == addPositionMode || isCloseAllMode(OP_SELL)) {
         CloseAllSell();
         resetStateSell();
         return true;
      } else if ( isClosePartMode(OP_SELL) ) {
         DecreaseShortPosition();
         return true;
      }
   }
   
   return false;
}

bool takeProfit4Buy() {
   if (0 != countAPBuy) {
      return false;
   }
   
   int ticketId = arrOrdersBuy[0].ticketId;
   
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect failed in takeProfit4Buy.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   
   double tpPrice = OrderOpenPrice() + tp;
   RefreshRates();
   // 止赢时
   if (tpPrice <= Bid) {
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), Bid, 0);

      if (!isClosed) {
         string msg = "Buy OrderClose failed in takeProfit4Buy. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
         msg += " Bid=" + DoubleToStr(Bid, Digits);
         Alert(msg);
         return false;
      }
      countAPBuy--;
      ArrayResize(arrOrdersBuy, arraySize);
      
      return true;
   }

   return false;
}

bool takeProfit4Sell() {
   if (0 != countAPSell) {
      return false;
   }
   
   int ticketId = arrOrdersSell[0].ticketId;
   
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
   if (!isSelected) {
      string msg = "OrderSelect failed in takeProfit4Sell.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   
   double tpPrice = OrderOpenPrice() - tp;
   RefreshRates();
   // 止赢时
   if (Ask <= tpPrice) {
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), Ask, 0);

      if (!isClosed) {
         string msg = "Sell OrderClose failed in takeProfit4Sell. Error:" + ErrorDescription(GetLastError());
         msg += " OrderTicket=" + IntegerToString(OrderTicket());
         msg += " lotSize=" + DoubleToStr(OrderLots(), 2);
         msg += " Ask=" + DoubleToStr(Ask, Digits);
         Alert(msg);
         return false;
      }
      countAPSell--;
      ArrayResize(arrOrdersSell, arraySize);
      
      return true;
   }

   return false;
}

void checkBuyOrder() {

   if (takeProfit4Buy()) {
      return;
   }
   
   if (doRetrace4Buy()) {
      return;
   }
   
   addPosition4Buy();
}

void checkSellOrder() {
   if (takeProfit4Sell()) {
      return;
   }
   
   if (doRetrace4Sell()) {
      return;
   }
   
   addPosition4Sell();
}

void resetState() {
   resetStateBuy();
   resetStateSell();
}

void OnTick() {

   if (enableUseLimit) {
      datetime now = TimeGMT();
      if (expireTime < now) {
         Alert("使用过期，请联系作者。邮箱：soko8@sina.com  或者QQ:183947281");
         return;
      }
   }

   calculateProfit();
   
   if (!isActive) {
   
      if (!isStopedByNews) {
         return;
      }

      datetime nowTime = TimeLocal();
      int diffTime = (int) (nowTime - stopedTimeByNews);
      if (minutesAfterNewsResume*60 < diffTime) {
         opPanel.resumeEA();
      } else {
         return;
      }
   }
   
   updateNewsStatus();
   
   if (mustStopEAByNews) {
      
      closeAll();
      resetState();

      opPanel.stopEA();
      
      isStopedByNews = true;
      stopedTimeByNews = TimeLocal();
      
      return;
   }

   checkBuyOrder();
   checkSellOrder();
   
   if (isNewBegin(OP_BUY)) {
      if (!forbidCreateOrder && !isForbidCreateOrderManual) {
         curInitLotSize4Buy = calculateInitLot(OP_BUY);
         createOrderBuy(curInitLotSize4Buy);
         opPanel.setCloseBuyButton(Close_Order_Mode);
      }
   }
   
   if (isNewBegin(OP_SELL)) {
      if (!forbidCreateOrder && !isForbidCreateOrderManual) {
         curInitLotSize4Sell = calculateInitLot(OP_SELL);
         createOrderSell(curInitLotSize4Sell);
         opPanel.setCloseSellButton(Close_Order_Mode);
      }
   }
   
   calculateProfit();
   SetComments();
}

void CloseAllBuy() {

   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSuccess) {
         string msg = "Order Select failed in CloseAllBuy.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      if (_Symbol != OrderSymbol()) {
         continue;
      }
      
      if (MagicNumber != OrderMagicNumber()) {
         continue;
      }
      
      if (OP_BUY != OrderType()) {
         continue;
      }

      isSuccess = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
      
      if (!isSuccess) {
         string msg = "Buy Order Close failed in CloseAllBuy.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());
         Alert(msg);
      }

   }

}

void CloseAllSell() {

   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSuccess) {
         string msg = "Order Select failed in CloseAllSell.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      if (_Symbol != OrderSymbol()) {
         continue;
      }
      
      if (MagicNumber != OrderMagicNumber()) {
         continue;
      }
      
      if (OP_SELL != OrderType()) {
         continue;
      }

      isSuccess = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
      
      if (!isSuccess) {
         string msg = "Sell Order Close failed in CloseAllSell.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());
         Alert(msg);
      }

   }

}


void CloseOrDeleteOrder() {
   
   if (_Symbol != OrderSymbol()) {
      return;
   }
   
   if (MagicNumber != OrderMagicNumber()) {
      return;
   }

   bool isSuccess = true;
   string kbn = "";
   switch(OrderType()) {
      case OP_BUY:
         kbn = "Buy";
         isSuccess = OrderClose(OrderTicket(), OrderLots(), Bid, 0);
         break;
      case OP_SELL:
         kbn = "Sell";
         isSuccess = OrderClose(OrderTicket(), OrderLots(), Ask, 0);
         break;
      case OP_BUYSTOP:
      case OP_BUYLIMIT:
      case OP_SELLSTOP:
      case OP_SELLLIMIT:
         kbn = "Pending";
         isSuccess = OrderDelete(OrderTicket());
         break;
   }

   if (!isSuccess) {
      string msg = kbn + " Order Close failed.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());
      Alert(msg);
   }

}

void closeAll() {

   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);
      
      if (!isSuccess) {
         string msg = "Order Select failed.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " i = " + IntegerToString(i);
         Alert(msg);
         continue;
      }
      
      CloseOrDeleteOrder();

   }

}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) { 

   if (id == CHARTEVENT_OBJECT_DRAG) {
      string objectName = sparam;
      if (nmLineClosePositionBuy == objectName) {
         retracePriceBuy = ObjectGet(nmLineClosePositionBuy, OBJPROP_PRICE1);
         double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;
         retraceRatioBuy = (retracePriceBuy-minOpenPrice)/Point/grid;
         calculateCloseProfit4Buy();
         SetComments();
      } else if (nmLineClosePositionSell == objectName) {
         retracePriceSell = ObjectGet(nmLineClosePositionSell, OBJPROP_PRICE1);
         double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;
         retraceRatioSell = (maxOpenPrice-retracePriceSell)/Point/grid;
         calculateCloseProfit4Sell();
         SetComments();
      }
   }
   
   opPanel.ChartEvent(id,lparam,dparam,sparam);
}

void calculateCloseProfit4Buy() {
   
   closeProfitBuy = 0.0;

   if (retracePriceBuy <= 0.0) {
      return;
   }
   
   for (int i = 0; i <= countAPBuy; i++) {
      if ( OrderSelect(arrOrdersBuy[i].ticketId, SELECT_BY_TICKET) ) {

         double diffPrice = retracePriceBuy - OrderOpenPrice();
         double profiti = OrderLots()*diffPrice/Point;
         closeProfitBuy += profiti;
         if ( isClosePartMode(OP_BUY) ) {
            if (countAPBuy != i && 0 != i) {
               closeProfitBuy -= profiti/lotMultiple;
            }
         }
         closeProfitBuy += OrderCommission();
         closeProfitBuy += OrderSwap(); 

      }
   }
   
}

void calculateCloseProfit4Sell() {
   
   closeProfitSell = 0.0;

   if (retracePriceSell <= 0.0) {
      return;
   }
   
   for (int i = 0; i <= countAPSell; i++) {
      if ( OrderSelect(arrOrdersSell[i].ticketId, SELECT_BY_TICKET) ) {

         double diffPrice = OrderOpenPrice() - retracePriceSell;
         double profiti = OrderLots()*diffPrice/Point;
         closeProfitSell += profiti;
         if ( isClosePartMode(OP_SELL) ) {
            if (countAPSell != i && 0 != i) {
               closeProfitSell -= profiti/lotMultiple;
            }
         }
         closeProfitSell += OrderCommission();
         closeProfitSell += OrderSwap();

      }
   }
   
}

void calculateProfit() {

   double profitLong = 0.0;
   double profitShort = 0.0;
   
   double profitDPLong = 0.0;
   double tmpOneProfit = 0.0;
   for (int i = 0; i <= countAPBuy; i++) {

      int ticketId = arrOrdersBuy[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         tmpOneProfit = OrderProfit();
         tmpOneProfit += OrderCommission();
         tmpOneProfit += OrderSwap();
         
         profitLong += tmpOneProfit;
         profitDPLong += tmpOneProfit;
         
         if (0 != i && countAPBuy != i) {
            double minusProfit = OrderProfit()*(1-reduceFactor);
            profitDPLong -= minusProfit;
         }
      } else {
         string msg = "OrderSelect failed in calculateProfit.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

   }
   
   double profitDPShort = 0.0;
   for (int i = 0; i <= countAPSell; i++) {

      int ticketId = arrOrdersSell[i].ticketId;
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   
      if (isSelected) {
         tmpOneProfit = OrderProfit();
         tmpOneProfit += OrderCommission();
         tmpOneProfit += OrderSwap();
         
         profitShort += tmpOneProfit;
         profitDPShort += tmpOneProfit;
         
         if (0 != i && countAPSell != i) {
            double minusProfit = OrderProfit()*(1-reduceFactor);
            profitDPShort -= minusProfit;
         }
      } else {
         string msg = "OrderSelect failed in calculateProfit.";
         msg = msg + " Error:" + ErrorDescription(GetLastError());
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);
         Alert(msg);
      }

   }
   
   opPanel.refreshProfitCloseLong(profitLong);
   opPanel.refreshProfitCloseShort(profitShort);
   
   double total = profitLong + profitShort;
   opPanel.refreshTotalProfit(total);
   
   opPanel.refreshProfitDecreaseLong(profitDPLong);
   opPanel.refreshProfitDecreaseShort(profitDPShort);
   
   double maxAPLongProfit = 0.0;
   if (0 <= countAPBuy) {
      bool isSelected = OrderSelect(arrOrdersBuy[countAPBuy].ticketId, SELECT_BY_TICKET);
      if (isSelected) {
         maxAPLongProfit = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   opPanel.refreshProfitCloseMaxOrderLong(maxAPLongProfit);
   
   double maxAPShortProfit = 0.0;
   if (0 <= countAPSell) {
      bool isSelected = OrderSelect(arrOrdersSell[countAPSell].ticketId, SELECT_BY_TICKET);
      if (isSelected) {
         maxAPShortProfit = OrderProfit()+OrderCommission()+OrderSwap();
      }
   }
   opPanel.refreshProfitCloseMaxOrderShort(maxAPShortProfit);
}


/*
       3M+NS-S
  X = ---------N
       3NS+6M
       
  M:初始手数
  S:加仓手数
  N:第几次加仓
*/

double calculateRetrace4Fixed(int N, double lotInit) {
   
   double M = lotInit/initLots;
   double S = lotStep/initLots;
   double ret = (M*3+S*N-S)*N/(S*N*3+M*6);
   return ret;
}

/*** 以(a-1)/a 倍系数减仓****/
double calculateRetracePart(int n, double a) {
   
   // 分子
   double numerator = 0;
   
   // 分母
   double denominator = 0;
   
   // a的i次幂
   double aMi = 1;
   
   // [0～n] n+1次
   for (int i = 1; i < n; i++) {
      aMi = a*aMi;
   }
   
   numerator = a*aMi - 1;
   denominator = (a*a-1)*aMi;
   
   return (numerator/denominator);
}

double calculateRetraceAll(int n, double a) {
   
   // 分子
   double numerator = 0;
   
   // 分母
   double denominator = 0;
   
   // a的i次幂
   double aMi = 1;
   
   // [0～n] n+1次
   for (int i = 0; i <= n; i++) {
      aMi = a*aMi;
   }
   
   numerator = aMi + n - a*(n+1);
   denominator = (a-1)*(aMi -1);
   
   return (numerator/denominator);
}

int createOrderBuy(double lotSize) {

   int chkBuy  = OrderSend(Symbol(), OP_BUY , lotSize, Ask, 0, 0, 0, "", MagicNumber, 0, clrBlue);
   
   if (-1 == chkBuy) {
      string msg = "BUY OrderSend failed in createOrderBuy. Error:" + ErrorDescription(GetLastError());
      msg += " Ask=" + DoubleToStr(Ask, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return chkBuy;
   }
   
   if (0 == countAPBuy && isEqualDouble(lotSize, initLots)) {
      
   } else {
      countAPBuy++;
   }
   
   double openPrice = Ask;
   
   if (OrderSelect(chkBuy, SELECT_BY_TICKET)) {
      openPrice = OrderOpenPrice();
   } else {
      string msg = "OrderSelect failed in createOrderBuy.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(chkBuy);
      Alert(msg);
   }
   
   OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_BUY};
   orderInfo.lotSize = lotSize;
   orderInfo.openPrice = openPrice;
   orderInfo.ticketId = chkBuy;
   arrOrdersBuy[countAPBuy] = orderInfo;
   
   return chkBuy;
}

int createOrderSell(double lotSize) {

   int chkSell = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, 0, 0, "", MagicNumber, 0, clrRed);
   
   if (-1 == chkSell) {
      string msg = "SELL OrderSend failed in createOrderSell. Error:" + ErrorDescription(GetLastError());
      msg += " Bid=" + DoubleToStr(Bid, Digits);
      msg += " lotSize=" + DoubleToStr(lotSize, 2);
      Alert(msg);
      return chkSell;
   }
   
   if (0 == countAPSell && isEqualDouble(lotSize, initLots)) {
   } else {
      countAPSell++;
   }
   
   double openPrice = Bid;
   
   if (OrderSelect(chkSell, SELECT_BY_TICKET)) {
      openPrice = OrderOpenPrice();
   } else {
      string msg = "OrderSelect failed in createOrderSell.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Sell Ticket = " + IntegerToString(chkSell);
      Alert(msg);
   }
   
   OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_SELL};
   orderInfo.lotSize = lotSize;
   orderInfo.openPrice = openPrice;
   orderInfo.ticketId = chkSell;
   arrOrdersSell[countAPSell] = orderInfo;
   
   return chkSell;
}

bool isEqualDouble(double num1, double num2) {

   if( NormalizeDouble(num1-num2,8) == 0 ) {
      return true;
   }
   
   return false;
}

void SetComments() {
   opPanel.refreshTargetProfitLong(closeProfitBuy);
   opPanel.refreshTargetProfitShort(closeProfitSell);
   opPanel.refreshTargetRetraceLong(retraceRatioBuy);
   opPanel.refreshTargetRetraceShort(retraceRatioSell);
   opPanel.refreshAddPositionTimesLong(countAPBuy);
   opPanel.refreshAddPositionTimesShort(countAPSell);
}

void updateNewsStatus() {

   string lblRemainTime = "Remain_Time";
   if (ObjectFind(0, lblRemainTime) < 0) {
      mustStopEAByNews = false;
      forbidCreateOrder = false;
      return;
   }
   
   string remainTime = "";
   ObjectGetString(0, lblRemainTime, OBJPROP_TEXT, 0, remainTime);
   
   int hours = StrToInteger(StringSubstr(remainTime, 0, 2));
   int minutes = StrToInteger(StringSubstr(remainTime, 3, 2));
   //int seconds = StrToInteger(StringSubstr(remainTime, 6, 2));
   
   if (0 == hours && minutes <= 1) {
      stopedTimeByNews = TimeLocal();
   }
   
   if (0 == hours && minutes <= minutesMustStopEABeforeNews) {
      mustStopEAByNews = true;
      //return;
   } else {
      mustStopEAByNews = false;
   }
   
   if (hours < hoursForbidCreateOrderBeforeNews) {
      forbidCreateOrder = true;
   } else {
      forbidCreateOrder = false;
   }

}

void DrawLine(string ctlName, 
               double Price = 0, 
               color LineColor = clrGold, 
               ENUM_LINE_STYLE LineStyle = STYLE_SOLID,
               int LineWidth = 1) 
{
   string FullCtlName = ctlName;
   
   if (-1 < ObjectFind(ChartID(), FullCtlName))
   {
         ObjectMove(FullCtlName, 0, 0, Price);
         ObjectSet(FullCtlName, OBJPROP_STYLE, LineStyle);
         ObjectSet(FullCtlName, OBJPROP_WIDTH, LineWidth);
         ObjectSet(FullCtlName, OBJPROP_COLOR, LineColor);
   }
   else
   {
      ObjectCreate(ChartID(), FullCtlName, OBJ_HLINE, 0, 0, Price);
      ObjectSet(FullCtlName, OBJPROP_STYLE, LineStyle);
      ObjectSet(FullCtlName, OBJPROP_WIDTH, LineWidth);
      ObjectSet(FullCtlName, OBJPROP_COLOR, LineColor);
   }
}

bool closeMaxAPLongOrder() {
   if (countAPBuy < 1) {
      return false;
   }
   int ticketId = arrOrdersBuy[countAPBuy].ticketId;
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   if (!isSelected) {
      string msg = "OrderSelect failed in closeMaxAPLongOrder.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   bool isSuccess = OrderClose(ticketId, OrderLots(), Bid, 0);
   if (!isSuccess) {
      printf("Buy Order Close failure in closeMaxAPLongOrder. tickedId = " + IntegerToString(ticketId) + " Error:" + ErrorDescription(GetLastError()));
   } else {
      OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_BUY};
      arrOrdersBuy[countAPBuy] = orderInfo;
      countAPBuy--;
      resetRetrace4Buy();
   }
   return isSuccess;
}

bool closeMaxAPShortOrder() {
   if (countAPSell < 1) {
      return false;
   }
   int ticketId = arrOrdersSell[countAPSell].ticketId;
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);
   if (!isSelected) {
      string msg = "OrderSelect failed in closeMaxAPShortOrder.";
      msg = msg + " Error:" + ErrorDescription(GetLastError());
      msg = msg + " Buy Ticket = " + IntegerToString(ticketId);
      Alert(msg);
      return false;
   }
   bool isSuccess = OrderClose(ticketId, OrderLots(), Ask, 0);
   if (!isSuccess) {
      printf("Sell Order Close failure in closeMaxAPShortOrder. tickedId = " + IntegerToString(ticketId) + " Error:" + ErrorDescription(GetLastError()));
   } else {
      OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_SELL};
      arrOrdersSell[countAPSell] = orderInfo;
      countAPSell--;
      resetRetrace4Sell();
   }
   return isSuccess;
}
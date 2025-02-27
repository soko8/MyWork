//+------------------------------------------------------------------+਍⼀⼀簀                                                 䴀愀爀琀椀渀最愀氀攀䔀䄀⸀洀焀㐀 簀ഀഀ
//|                        Copyright 2017, MetaQuotes Software Corp. |਍⼀⼀簀                                             栀琀琀瀀猀㨀⼀⼀眀眀眀⸀洀焀氀㔀⸀挀漀洀 簀ഀഀ
//+------------------------------------------------------------------+਍⌀瀀爀漀瀀攀爀琀礀 挀漀瀀礀爀椀最栀琀 ∀䌀漀瀀礀爀椀最栀琀 ㈀　㄀㜀Ⰰ 䜀愀漀 娀攀渀最⸀儀儀ⴀⴀ㄀㠀㌀㤀㐀㜀㈀㠀㄀Ⰰ洀愀椀氀ⴀⴀ猀漀欀漀㠀䀀猀椀渀愀⸀挀漀洀⸀∀ഀഀ
#property link      "https://www.mql5.com"਍⌀瀀爀漀瀀攀爀琀礀 瘀攀爀猀椀漀渀   ∀㄀⸀　　∀ഀഀ
#property strict਍ഀഀ
#include <stdlib.mqh>਍⌀椀渀挀氀甀搀攀 㰀䌀漀渀琀爀漀氀猀尀䈀甀琀琀漀渀⸀洀焀栀㸀ഀഀ
#include <Controls\Label.mqh>਍⌀椀渀挀氀甀搀攀 㰀䌀漀渀琀爀漀氀猀尀䔀搀椀琀⸀洀焀栀㸀ഀഀ
#include <Controls\SpinEdit.mqh>਍⌀椀渀挀氀甀搀攀 㰀䌀漀渀琀爀漀氀猀尀匀瀀椀渀䔀搀椀琀䘀氀漀愀琀⸀洀焀栀㸀ഀഀ
#include <Controls\CheckBox.mqh>਍⌀椀渀挀氀甀搀攀 㰀䌀漀渀琀爀漀氀猀尀䌀漀洀戀漀䈀漀砀⸀洀焀栀㸀ഀഀ
#include <Controls\WindowWithoutCloseButton.mqh>਍ഀഀ
struct OrderInfo {਍   搀漀甀戀氀攀   氀漀琀匀椀稀攀㬀ഀഀ
   double   openPrice;਍   搀漀甀戀氀攀   猀氀倀爀椀挀攀㬀ഀഀ
   double   tpPrice;਍   椀渀琀      琀椀挀欀攀琀䤀搀㬀ഀഀ
   int      operationType;਍紀㬀ഀഀ
਍攀渀甀洀 攀渀䌀氀漀猀攀䴀漀搀攀ഀഀ
{਍   䌀氀漀猀攀开䄀氀氀 㴀 　Ⰰഀഀ
   Close_Part = 1,਍   䌀氀漀猀攀开倀愀爀琀开䄀氀氀 㴀 ㈀ഀഀ
};਍ഀഀ
enum enAddPositionMode਍笀ഀഀ
   Fixed = 0,਍   䴀甀氀琀椀瀀氀椀攀搀 㴀 ㄀ഀഀ
};਍ഀഀ
enum enButtonMode਍笀ഀഀ
   Close_Order_Mode = 0,਍   䌀爀攀愀琀攀开伀爀搀攀爀开䴀漀搀攀 㴀 ㄀ഀഀ
};਍ഀഀ
//--- input parameters਍椀渀瀀甀琀 搀漀甀戀氀攀               䤀渀椀琀䰀漀琀匀椀稀攀㴀　⸀　㄀㬀ഀഀ
input int                  GridPoints=200;਍椀渀瀀甀琀 椀渀琀                  吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀 㴀 ㌀　㬀ഀഀ
input double               RetraceProfitCoefficient = 0.25;਍椀渀瀀甀琀 椀渀琀                  䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀 㴀 㤀㬀ഀഀ
input bool                 AddPositionByTrend = false;਍椀渀瀀甀琀 攀渀䌀氀漀猀攀䴀漀搀攀          䌀氀漀猀攀䴀漀搀攀 㴀 䌀氀漀猀攀开倀愀爀琀开䄀氀氀㬀ഀഀ
input enAddPositionMode    AddPositionMode = Multiplied;਍椀渀瀀甀琀 搀漀甀戀氀攀               䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀 㴀 　⸀　㄀㬀ഀഀ
input double               LotAddPositionMultiple = 2.0;਍椀渀瀀甀琀 椀渀琀                  䴀愀最椀挀一甀洀戀攀爀㴀㠀㠀㠀㠀㠀㠀㬀ഀഀ
input double               MaxLots4AddPositionLimit=0.4;਍ഀഀ
      double               initLots;਍      椀渀琀                  最爀椀搀㬀ഀഀ
      double               gridPrice;਍      ഀഀ
      int                  tpPoints;਍      搀漀甀戀氀攀               琀瀀㬀ഀഀ
      double               retraceProfitRatio;਍      椀渀琀                  洀愀砀吀椀洀攀猀㐀䄀倀㬀ഀഀ
      int                  times_Part2All;਍      戀漀漀氀                 愀搀搀倀漀猀椀琀椀漀渀㈀吀爀攀渀搀㬀ഀഀ
      ਍      攀渀䌀氀漀猀攀䴀漀搀攀          挀氀漀猀攀倀漀猀椀琀椀漀渀䴀漀搀攀㬀ഀഀ
      enAddPositionMode    addPositionMode;਍      ഀഀ
      double               lotStep;਍      搀漀甀戀氀攀               氀漀琀䴀甀氀琀椀瀀氀攀㬀ഀഀ
਍      伀爀搀攀爀䤀渀昀漀            愀爀爀伀爀搀攀爀猀䈀甀礀嬀崀㬀ഀഀ
      OrderInfo            arrOrdersSell[];਍      ഀഀ
      double               initLotSize4Buy;਍      搀漀甀戀氀攀               椀渀椀琀䰀漀琀匀椀稀攀㐀匀攀氀氀㬀ഀഀ
      double               curInitLotSize4Buy;਍      搀漀甀戀氀攀               挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀㐀匀攀氀氀㬀ഀഀ
      ਍      椀渀琀                  挀漀甀渀琀䄀倀䈀甀礀 㴀 ⴀ㄀㬀ഀഀ
      int                  countAPSell = -1;਍      ഀഀ
      double               retracePriceBuy = 0.0;਍      搀漀甀戀氀攀               爀攀琀爀愀挀攀倀爀椀挀攀匀攀氀氀 㴀 　⸀　㬀ഀഀ
      ਍      搀漀甀戀氀攀               爀攀琀爀愀挀攀刀愀琀椀漀䈀甀礀 㴀 　⸀　㬀ഀഀ
      double               retraceRatioSell = 0.0;਍      ഀഀ
      double               closeProfitBuy = 0.0;਍      搀漀甀戀氀攀               挀氀漀猀攀倀爀漀昀椀琀匀攀氀氀 㴀 　⸀　㬀ഀഀ
      ਍      椀渀琀                  愀爀爀愀礀匀椀稀攀㬀ഀഀ
      double               reduceFactor;਍ഀഀ
const string               nmLineClosePositionBuy = "ClosePositionBuy";਍挀漀渀猀琀 猀琀爀椀渀最               渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀匀攀氀氀 㴀 ∀䌀氀漀猀攀倀漀猀椀琀椀漀渀匀攀氀氀∀㬀ഀഀ
਍ഀഀ
      enButtonMode         btnModeBuy;਍      攀渀䈀甀琀琀漀渀䴀漀搀攀         戀琀渀䴀漀搀攀匀攀氀氀㬀ഀഀ
      ਍挀漀渀猀琀 猀琀爀椀渀最 䘀漀渀琀开一愀洀攀 㴀 ∀䰀甀挀椀搀愀 䈀爀椀最栀琀∀㬀ഀഀ
਍      戀漀漀氀        椀猀䄀挀琀椀瘀攀                㴀 昀愀氀猀攀㬀ഀഀ
਍      戀漀漀氀        椀猀䘀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀䴀愀渀甀愀氀              㴀 昀愀氀猀攀㬀ഀഀ
਍ഀഀ
      bool        isStopedByNews          = false;਍      搀愀琀攀琀椀洀攀    猀琀漀瀀攀搀吀椀洀攀䈀礀一攀眀猀        㴀 　㬀ഀഀ
      bool        forbidCreateOrder       = false;਍      戀漀漀氀        洀甀猀琀匀琀漀瀀䔀䄀䈀礀一攀眀猀        㴀 昀愀氀猀攀㬀ഀഀ
      int         hoursForbidCreateOrderBeforeNews = 24;਍      椀渀琀         洀椀渀甀琀攀猀䴀甀猀琀匀琀漀瀀䔀䄀䈀攀昀漀爀攀一攀眀猀 㴀 ㄀　㬀ഀഀ
      int         minutesAfterNewsResume  = 180;਍ഀഀ
਍      戀漀漀氀        攀渀愀戀氀攀䴀愀砀䰀漀琀䌀漀渀琀爀漀氀 㴀 琀爀甀攀㬀ഀഀ
      double      Max_Lot_AP = 0;਍ഀഀ
      bool AccountCtrl = true;਍   挀漀渀猀琀 椀渀琀         䄀甀琀栀漀爀椀稀攀䄀挀挀漀甀渀琀䰀椀猀琀嬀㐀崀 㴀 笀  㘀㄀㔀㐀㈀㄀㠀ഀഀ
                                                 ,7100152਍                                                 Ⰰ㔀　㄀㔀㄀㜀㜀ഀഀ
                                                 ,5330172਍                                                紀㬀ഀഀ
      bool        enableUseLimit=true;਍      搀愀琀攀琀椀洀攀    攀砀瀀椀爀攀吀椀洀攀 㴀 䐀✀㈀　㄀㜀⸀㄀㈀⸀㌀㄀ ㈀㌀㨀㔀㤀㨀㔀㤀✀㬀ഀഀ
      ਍      ഀഀ
class COpPanel : public CAppWindowWithoutCloseButton {਍瀀爀椀瘀愀琀攀㨀ഀഀ
   CLabel         lblTotalProfitWords;਍   䌀䔀搀椀琀          攀搀琀吀漀琀愀氀倀爀漀昀椀琀㬀ഀഀ
   ਍   䌀䈀甀琀琀漀渀        戀琀渀匀琀漀瀀匀琀愀爀琀㬀ഀഀ
   CButton        btnForbidAllow;਍   ഀഀ
   CEdit          edtHorizontalLine1;਍   ഀഀ
   CLabel         lblLong;਍   䌀䔀搀椀琀          攀搀琀嘀攀爀琀椀挀愀氀䰀椀渀攀㄀㬀ഀഀ
   CLabel         lblShort;਍   ഀഀ
   CLabel         lblProfitWordsLong;਍   䌀䰀愀戀攀氀         氀戀氀倀爀漀昀椀琀圀漀爀搀猀匀栀漀爀琀㬀ഀഀ
   ਍   䌀䈀甀琀琀漀渀        戀琀渀䌀氀漀猀攀䰀漀渀最㬀ഀഀ
   CEdit          edtProfitCloseLong;਍   䌀䈀甀琀琀漀渀        戀琀渀䌀氀漀猀攀匀栀漀爀琀㬀ഀഀ
   CEdit          edtProfitCloseShort;਍   ഀഀ
   CButton        btnDecreaseLong;਍   䌀䔀搀椀琀          攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最㬀ഀഀ
   CButton        btnDecreaseShort;਍   䌀䔀搀椀琀          攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀㬀ഀഀ
   ਍   䌀䈀甀琀琀漀渀        戀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀㬀ഀഀ
   CButton        btnAdd1ShortOrder;਍   ഀഀ
   CButton        btnCloseTheMaxLongOrder;਍   䌀䔀搀椀琀          攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀㬀ഀഀ
   CButton        btnCloseTheMaxShortOrder;਍   䌀䔀搀椀琀          攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀㬀ഀഀ
   ਍   䌀䰀愀戀攀氀         氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最圀漀爀搀猀㬀ഀഀ
   CEdit          edtTargetProfitCloseLong;਍   䌀䰀愀戀攀氀         氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀圀漀爀搀猀㬀ഀഀ
   CEdit          edtTargetProfitCloseShort;਍ഀഀ
   CLabel         lblTargetRetraceLongWords;਍   䌀䔀搀椀琀          攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最㬀ഀഀ
   CLabel         lblTargetRetraceShortWords;਍   䌀䔀搀椀琀          攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀㬀ഀഀ
   ਍   䌀䰀愀戀攀氀         氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最圀漀爀搀猀㬀ഀഀ
   CEdit          edtAddPositionTimesLong;਍   䌀䰀愀戀攀氀         氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀圀漀爀搀猀㬀ഀഀ
   CEdit          edtAddPositionTimesShort;਍   ഀഀ
   CEdit          edtVerticalLine2;਍   ⼀⨀⨀⨀⨀瀀愀爀愀洀攀琀攀爀猀⨀⨀⨀⨀⼀ഀഀ
   CLabel         lblParametersWords;਍   ഀഀ
   CLabel         lblInitLotSize;਍   䌀匀瀀椀渀䔀搀椀琀䘀氀漀愀琀 猀攀昀䤀渀椀琀䰀漀琀匀椀稀攀㬀ഀഀ
   ਍   䌀䰀愀戀攀氀         氀戀氀䜀爀椀搀倀漀椀渀琀猀㬀ഀഀ
   CSpinEdit      speGridPoints;਍   ഀഀ
   CLabel         lblTakeProfitPoints;਍   䌀匀瀀椀渀䔀搀椀琀      猀瀀攀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀㬀ഀഀ
   ਍   䌀䰀愀戀攀氀         氀戀氀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀㬀ഀഀ
   CSpinEditFloat sefRetraceProfitCoefficient;਍   ഀഀ
   CLabel         lblMaxTimesAddPosition;਍   䌀匀瀀椀渀䔀搀椀琀      猀瀀攀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀㬀ഀഀ
   ਍   䌀䌀栀攀挀欀䈀漀砀      挀欀戀䄀搀搀倀漀猀椀琀椀漀渀䈀礀吀爀攀渀搀㬀ഀഀ
   ਍   䌀䰀愀戀攀氀         氀戀氀䌀氀漀猀攀䴀漀搀攀㬀ഀഀ
   CComboBox      cmbCloseMode;਍   ഀഀ
   CLabel         lblAddPositionMode;਍   䌀䌀漀洀戀漀䈀漀砀      挀洀戀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀㬀ഀഀ
   ਍   䌀䰀愀戀攀氀         氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀㬀ഀഀ
   CSpinEditFloat sefLotAddPositionStep;਍   ഀഀ
   CLabel         lblLotAddPositionMultiple;਍   䌀匀瀀椀渀䔀搀椀琀䘀氀漀愀琀 猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀㬀ഀഀ
   ਍   䌀䰀愀戀攀氀         氀戀氀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀㬀ഀഀ
   CSpinEditFloat sefMaxLots4AddPositionLimit;਍   ഀഀ
   CLabel         lblMagicNumberWords;਍   䌀䔀搀椀琀          攀搀琀䴀愀最椀挀一甀洀戀攀爀㬀ഀഀ
   ਍瀀甀戀氀椀挀㨀ഀഀ
   ਍    䌀伀瀀倀愀渀攀氀⠀⤀ 笀紀ഀഀ
   ~COpPanel() {}਍   ഀഀ
   bool OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);਍ഀഀ
   bool create(const long chart, const string name, const int subwin) {਍      ⼀⼀ⴀⴀⴀ 挀愀氀氀 洀攀琀栀漀搀 漀昀 瀀愀爀攀渀琀 挀氀愀猀猀ഀഀ
      if(!CAppWindowWithoutCloseButton::Create(chart, name, subwin, 1, 14, 640, 393)) return(false);਍      䌀䄀瀀瀀圀椀渀搀漀眀圀椀琀栀漀甀琀䌀氀漀猀攀䈀甀琀琀漀渀㨀㨀猀攀琀䈀愀挀欀最爀漀甀渀搀䌀漀氀漀爀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
   ਍      椀昀⠀℀氀戀氀吀漀琀愀氀倀爀漀昀椀琀圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀吀漀琀愀氀倀爀漀昀椀琀圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㈀Ⰰ ㌀Ⰰ 㜀㤀Ⰰ ㈀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblTotalProfitWords.Text("Total Profit：");਍      氀戀氀吀漀琀愀氀倀爀漀昀椀琀圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      //lblTotalProfitWords.ColorBackground(clrRed);਍      ⼀⼀氀戀氀吀漀琀愀氀倀爀漀昀椀琀圀漀爀搀猀⸀䌀漀氀漀爀䈀漀爀搀攀爀⠀挀氀爀刀攀搀⤀㬀ഀഀ
      lblTotalProfitWords.Font(Font_Name);਍      氀戀氀吀漀琀愀氀倀爀漀昀椀琀圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㄀　⤀㬀ഀഀ
      if(!Add(lblTotalProfitWords)) return(false);਍      ഀഀ
      if(!edtTotalProfit.Create(m_chart_id, "edtTotalProfit", m_subwin, 84, 2, 170, 20)) return(false);਍      ⼀⼀攀搀琀吀漀琀愀氀倀爀漀昀椀琀⸀吀攀砀琀⠀∀㄀㈀㌀㐀㔀㘀㜀⸀㄀㈀∀⤀㬀ഀഀ
      edtTotalProfit.Text("0.00");਍      攀搀琀吀漀琀愀氀倀爀漀昀椀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtTotalProfit.Color(clrWhite);਍      攀搀琀吀漀琀愀氀倀爀漀昀椀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtTotalProfit.FontSize(10);਍      攀搀琀吀漀琀愀氀倀爀漀昀椀琀⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtTotalProfit.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀吀漀琀愀氀倀爀漀昀椀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀戀琀渀匀琀漀瀀匀琀愀爀琀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀戀琀渀匀琀漀瀀匀琀愀爀琀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㌀Ⰰ ㈀㌀Ⰰ 㜀　Ⰰ 㔀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      if (isActive) {਍         戀琀渀匀琀漀瀀匀琀愀爀琀⸀吀攀砀琀⠀∀匀琀漀瀀∀⤀㬀ഀഀ
         btnStopStart.Color(clrWhite);਍         戀琀渀匀琀漀瀀匀琀愀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䴀愀爀漀漀渀⤀㬀ഀഀ
      } else {਍         戀琀渀匀琀漀瀀匀琀愀爀琀⸀吀攀砀琀⠀∀匀琀愀爀琀∀⤀㬀ഀഀ
         btnStopStart.Color(clrWhite);਍         戀琀渀匀琀漀瀀匀琀愀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䐀愀爀欀䜀爀攀攀渀⤀㬀ഀഀ
      }਍      戀琀渀匀琀漀瀀匀琀愀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      btnStopStart.FontSize(18);਍      椀昀⠀℀䄀搀搀⠀戀琀渀匀琀漀瀀匀琀愀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㠀㤀Ⰰ ㈀㌀Ⰰ ㄀㜀　Ⰰ 㔀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      if (isForbidCreateOrderManual) {਍         戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀吀攀砀琀⠀∀䄀氀氀漀眀∀⤀㬀ഀഀ
         btnForbidAllow.Color(clrBlack);਍         戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䰀椀洀攀⤀㬀ഀഀ
      } else {਍         戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀吀攀砀琀⠀∀䘀漀爀戀椀搀∀⤀㬀ഀഀ
         btnForbidAllow.Color(clrWhite);਍         戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䴀愀爀漀漀渀⤀㬀ഀഀ
      }਍      戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      btnForbidAllow.FontSize(18);਍      椀昀⠀℀䄀搀搀⠀戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀攀搀琀䠀漀爀椀稀漀渀琀愀氀䰀椀渀攀㄀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀攀搀琀䠀漀爀椀稀漀渀琀愀氀䰀椀渀攀㄀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀Ⰰ 㔀㘀Ⰰ 㐀㄀　Ⰰ 㔀㤀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      edtHorizontalLine1.ColorBackground(clrCoral);਍      攀搀琀䠀漀爀椀稀漀渀琀愀氀䰀椀渀攀㄀⸀䌀漀氀漀爀䈀漀爀搀攀爀⠀挀氀爀䌀漀爀愀氀⤀㬀ഀഀ
      edtHorizontalLine1.ReadOnly(false);਍      椀昀⠀℀䄀搀搀⠀攀搀琀䠀漀爀椀稀漀渀琀愀氀䰀椀渀攀㄀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀䰀漀渀最⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀䰀漀渀最∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㔀　Ⰰ 㘀　Ⰰ ㄀㈀　Ⰰ ㄀　　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblLong.Text("Long");਍      氀戀氀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblLong.Font(Font_Name);਍      氀戀氀䰀漀渀最⸀䘀漀渀琀匀椀稀攀⠀㌀　⤀㬀ഀഀ
      if(!Add(lblLong)) return(false);਍      ഀഀ
      if(!edtVerticalLine1.Create(m_chart_id, "edtVerticalLine1", m_subwin, 200, 58, 203, 350)) return(false);਍      攀搀琀嘀攀爀琀椀挀愀氀䰀椀渀攀㄀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䌀漀爀愀氀⤀㬀ഀഀ
      edtVerticalLine1.ColorBorder(clrCoral);਍      攀搀琀嘀攀爀琀椀挀愀氀䰀椀渀攀㄀⸀刀攀愀搀伀渀氀礀⠀昀愀氀猀攀⤀㬀ഀഀ
      if(!Add(edtVerticalLine1)) return(false);਍      ഀഀ
      if(!lblShort.Create(m_chart_id, "lblShort", m_subwin, 260, 60, 320, 80)) return(false);਍      氀戀氀匀栀漀爀琀⸀吀攀砀琀⠀∀匀栀漀爀琀∀⤀㬀ഀഀ
      lblShort.Color(clrWhite);਍      氀戀氀匀栀漀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblShort.FontSize(30);਍      椀昀⠀℀䄀搀搀⠀氀戀氀匀栀漀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀倀爀漀昀椀琀圀漀爀搀猀䰀漀渀最⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀倀爀漀昀椀琀圀漀爀搀猀䰀漀渀最∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀㌀　Ⰰ ㄀　㔀Ⰰ ㄀㘀　Ⰰ ㄀㈀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblProfitWordsLong.Text("Profit");਍      氀戀氀倀爀漀昀椀琀圀漀爀搀猀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblProfitWordsLong.Font(Font_Name);਍      氀戀氀倀爀漀昀椀琀圀漀爀搀猀䰀漀渀最⸀䘀漀渀琀匀椀稀攀⠀㄀㄀⤀㬀ഀഀ
      if(!Add(lblProfitWordsLong)) return(false);਍      ഀഀ
      if(!lblProfitWordsShort.Create(m_chart_id, "lblProfitWordsShort", m_subwin, 340, 105, 360, 120)) return(false);਍      氀戀氀倀爀漀昀椀琀圀漀爀搀猀匀栀漀爀琀⸀吀攀砀琀⠀∀倀爀漀昀椀琀∀⤀㬀ഀഀ
      lblProfitWordsShort.Color(clrWhite);਍      氀戀氀倀爀漀昀椀琀圀漀爀搀猀匀栀漀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblProfitWordsShort.FontSize(11);਍      椀昀⠀℀䄀搀搀⠀氀戀氀倀爀漀昀椀琀圀漀爀搀猀匀栀漀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀戀琀渀䌀氀漀猀攀䰀漀渀最⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀戀琀渀䌀氀漀猀攀䰀漀渀最∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㌀Ⰰ ㄀㈀㌀Ⰰ ㄀　㔀Ⰰ ㄀㐀㜀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      btnCloseLong.Text("Create Buy");਍      戀琀渀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      btnCloseLong.ColorBackground(clrDarkGreen);਍      戀琀渀䌀氀漀猀攀䰀漀渀最⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      btnCloseLong.FontSize(14);਍      椀昀⠀℀䄀搀搀⠀戀琀渀䌀氀漀猀攀䰀漀渀最⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀　㜀Ⰰ ㄀㈀㌀Ⰰ ㄀㤀㌀Ⰰ ㄀㐀㜀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      //edtProfitCloseLong.Text("1234567.12");਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀吀攀砀琀⠀∀　⸀　　∀⤀㬀ഀഀ
      edtProfitCloseLong.ColorBackground(clrBlack);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      edtProfitCloseLong.Font(Font_Name);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䘀漀渀琀匀椀稀攀⠀㄀　⤀㬀ഀഀ
      edtProfitCloseLong.ReadOnly(true);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀吀攀砀琀䄀氀椀最渀⠀䄀䰀䤀䜀一开刀䤀䜀䠀吀⤀㬀ഀഀ
      if(!Add(edtProfitCloseLong)) return(false);਍      ഀഀ
      if(!btnCloseShort.Create(m_chart_id, "btnCloseShort", m_subwin, 210, 123, 314, 147)) return(false);਍      戀琀渀䌀氀漀猀攀匀栀漀爀琀⸀吀攀砀琀⠀∀䌀爀攀愀琀攀 匀攀氀氀∀⤀㬀ഀഀ
      btnCloseShort.Color(clrWhite);਍      戀琀渀䌀氀漀猀攀匀栀漀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀爀漀眀渀⤀㬀ഀഀ
      btnCloseShort.Font(Font_Name);਍      戀琀渀䌀氀漀猀攀匀栀漀爀琀⸀䘀漀渀琀匀椀稀攀⠀㄀㐀⤀㬀ഀഀ
      if(!Add(btnCloseShort)) return(false);਍      ഀഀ
      if(!edtProfitCloseShort.Create(m_chart_id, "edtProfitCloseShort", m_subwin, 316, 123, 402, 147)) return(false);਍      ⼀⼀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀吀攀砀琀⠀∀㄀㈀㌀㐀㔀㘀㜀⸀㄀㈀∀⤀㬀ഀഀ
      edtProfitCloseShort.Text("0.00");਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtProfitCloseShort.Color(clrWhite);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtProfitCloseShort.FontSize(10);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtProfitCloseShort.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀戀琀渀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀戀琀渀䐀攀挀爀攀愀猀攀䰀漀渀最∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㌀Ⰰ ㄀㘀　Ⰰ ㄀　㔀Ⰰ ㄀㠀㐀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      btnDecreaseLong.Text("Decrease Buy");਍      戀琀渀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      btnDecreaseLong.ColorBackground(clrLawnGreen);਍      戀琀渀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      btnDecreaseLong.FontSize(10);਍      椀昀⠀℀䄀搀搀⠀戀琀渀䐀攀挀爀攀愀猀攀䰀漀渀最⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀　㜀Ⰰ ㄀㘀　Ⰰ ㄀㤀㌀Ⰰ ㄀㠀㐀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      //edtProfitDecreaseLong.Text("1234567.12");਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀吀攀砀琀⠀∀　⸀　　∀⤀㬀ഀഀ
      edtProfitDecreaseLong.ColorBackground(clrBlack);਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      edtProfitDecreaseLong.Font(Font_Name);਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䘀漀渀琀匀椀稀攀⠀㄀　⤀㬀ഀഀ
      edtProfitDecreaseLong.ReadOnly(true);਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀吀攀砀琀䄀氀椀最渀⠀䄀䰀䤀䜀一开刀䤀䜀䠀吀⤀㬀ഀഀ
      if(!Add(edtProfitDecreaseLong)) return(false);਍      ഀഀ
      if(!btnDecreaseShort.Create(m_chart_id, "btnDecreaseShort", m_subwin, 210, 160, 314, 184)) return(false);਍      戀琀渀䐀攀挀爀攀愀猀攀匀栀漀爀琀⸀吀攀砀琀⠀∀䐀攀挀爀攀愀猀攀 匀攀氀氀∀⤀㬀ഀഀ
      btnDecreaseShort.Color(clrBlack);਍      戀琀渀䐀攀挀爀攀愀猀攀匀栀漀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䤀渀搀椀愀渀刀攀搀⤀㬀ഀഀ
      btnDecreaseShort.Font(Font_Name);਍      戀琀渀䐀攀挀爀攀愀猀攀匀栀漀爀琀⸀䘀漀渀琀匀椀稀攀⠀㄀　⤀㬀ഀഀ
      if(!Add(btnDecreaseShort)) return(false);਍      ഀഀ
      if(!edtProfitDecreaseShort.Create(m_chart_id, "edtProfitDecreaseShort", m_subwin, 316, 160, 402, 184)) return(false);਍      ⼀⼀攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀⸀吀攀砀琀⠀∀㄀㈀㌀㐀㔀㘀㜀⸀㄀㈀∀⤀㬀ഀഀ
      edtProfitDecreaseShort.Text("0.00");਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtProfitDecreaseShort.Color(clrWhite);਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtProfitDecreaseShort.FontSize(10);਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtProfitDecreaseShort.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀戀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀戀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㌀Ⰰ ㄀㤀㜀Ⰰ ㄀㘀㠀Ⰰ ㈀㈀㄀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      btnAdd1LongOrder.Text("Add a Buy Order");਍      戀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      btnAdd1LongOrder.ColorBackground(clrMediumBlue);਍      戀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      btnAdd1LongOrder.FontSize(14);਍      椀昀⠀℀䄀搀搀⠀戀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀戀琀渀䄀搀搀㄀匀栀漀爀琀伀爀搀攀爀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀戀琀渀䄀搀搀㄀匀栀漀爀琀伀爀搀攀爀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㈀㄀　Ⰰ ㄀㤀㜀Ⰰ ㌀㜀㔀Ⰰ ㈀㈀㄀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      btnAdd1ShortOrder.Text("Add a Sell Order");਍      戀琀渀䄀搀搀㄀匀栀漀爀琀伀爀搀攀爀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      btnAdd1ShortOrder.ColorBackground(clrMaroon);਍      戀琀渀䄀搀搀㄀匀栀漀爀琀伀爀搀攀爀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      btnAdd1ShortOrder.FontSize(14);਍      椀昀⠀℀䄀搀搀⠀戀琀渀䄀搀搀㄀匀栀漀爀琀伀爀搀攀爀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㌀Ⰰ ㈀㌀㐀Ⰰ ㄀㈀㈀Ⰰ ㈀㔀㠀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      btnCloseTheMaxLongOrder.Text("Close Max Buy Order");਍      戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䌀漀氀漀爀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      btnCloseTheMaxLongOrder.ColorBackground(clrPaleGreen);਍      戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      btnCloseTheMaxLongOrder.FontSize(8);਍      椀昀⠀℀䄀搀搀⠀戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀㈀㐀Ⰰ ㈀㌀㐀Ⰰ ㄀㤀㌀Ⰰ ㈀㔀㠀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      //edtProfitCloseTheMaxLongOrder.Text("12345.12");਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀吀攀砀琀⠀∀　⸀　　∀⤀㬀ഀഀ
      edtProfitCloseTheMaxLongOrder.ColorBackground(clrBlack);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      edtProfitCloseTheMaxLongOrder.Font(Font_Name);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䘀漀渀琀匀椀稀攀⠀㄀　⤀㬀ഀഀ
      edtProfitCloseTheMaxLongOrder.ReadOnly(true);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀吀攀砀琀䄀氀椀最渀⠀䄀䰀䤀䜀一开刀䤀䜀䠀吀⤀㬀ഀഀ
      if(!Add(edtProfitCloseTheMaxLongOrder)) return(false);਍      ഀഀ
      if(!btnCloseTheMaxShortOrder.Create(m_chart_id, "btnCloseTheMaxShortOrder", m_subwin, 210, 234, 329, 258)) return(false);਍      戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⸀吀攀砀琀⠀∀䌀氀漀猀攀 䴀愀砀 匀攀氀氀 伀爀搀攀爀∀⤀㬀ഀഀ
      btnCloseTheMaxShortOrder.Color(clrBlack);਍      戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀刀漀猀礀䈀爀漀眀渀⤀㬀ഀഀ
      btnCloseTheMaxShortOrder.Font(Font_Name);਍      戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⸀䘀漀渀琀匀椀稀攀⠀㠀⤀㬀ഀഀ
      if(!Add(btnCloseTheMaxShortOrder)) return(false);਍      ഀഀ
      if(!edtProfitCloseTheMaxShortOrder.Create(m_chart_id, "edtProfitCloseTheMaxShortOrder", m_subwin, 331, 234, 402, 258)) return(false);਍      ⼀⼀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⸀吀攀砀琀⠀∀㄀㈀㌀㐀㔀⸀㄀㈀∀⤀㬀ഀഀ
      edtProfitCloseTheMaxShortOrder.Text("0.00");਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtProfitCloseTheMaxShortOrder.Color(clrWhite);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtProfitCloseTheMaxShortOrder.FontSize(10);਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtProfitCloseTheMaxShortOrder.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀Ⰰ ㈀㠀㐀Ⰰ ㄀　㔀Ⰰ ㌀　　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblTargetProfitCloseLongWords.Text("Buy Target Profit：");਍      氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblTargetProfitCloseLongWords.Font(Font_Name);਍      氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblTargetProfitCloseLongWords)) return(false);਍      ഀഀ
      if(!edtTargetProfitCloseLong.Create(m_chart_id, "edtTargetProfitCloseLong", m_subwin, 107, 282, 193, 300)) return(false);਍      ⼀⼀攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀吀攀砀琀⠀∀㄀㈀㌀㐀㔀㘀㜀⸀㄀㈀∀⤀㬀ഀഀ
      edtTargetProfitCloseLong.Text("0.00");਍      攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtTargetProfitCloseLong.Color(clrWhite);਍      攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtTargetProfitCloseLong.FontSize(10);਍      攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtTargetProfitCloseLong.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㈀㄀　Ⰰ ㈀㠀㐀Ⰰ ㌀㄀㐀Ⰰ ㌀　　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblTargetProfitCloseShortWords.Text("Sell Target Profit：");਍      氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblTargetProfitCloseShortWords.Font(Font_Name);਍      氀戀氀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblTargetProfitCloseShortWords)) return(false);਍      ഀഀ
      if(!edtTargetProfitCloseShort.Create(m_chart_id, "edtTargetProfitCloseShort", m_subwin, 316, 282, 402, 300)) return(false);਍      ⼀⼀攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀吀攀砀琀⠀∀㄀㈀㌀㐀㔀㘀㜀⸀㄀㈀∀⤀㬀ഀഀ
      edtTargetProfitCloseShort.Text("0.00");਍      攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtTargetProfitCloseShort.Color(clrWhite);਍      攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtTargetProfitCloseShort.FontSize(10);਍      攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtTargetProfitCloseShort.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀Ⰰ ㌀　㔀Ⰰ ㄀　㔀Ⰰ ㌀㈀㌀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblTargetRetraceLongWords.Text("Buy Retrace：");਍      氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblTargetRetraceLongWords.Font(Font_Name);਍      氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblTargetRetraceLongWords)) return(false);਍      ഀഀ
      if(!edtTargetRetraceLong.Create(m_chart_id, "edtTargetRetraceLong", m_subwin, 107, 303, 193, 323)) return(false);਍      ⼀⼀攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最⸀吀攀砀琀⠀∀　⸀㄀㈀㌀㐀∀⤀㬀ഀഀ
      edtTargetRetraceLong.Text("0.0000");਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtTargetRetraceLong.Color(clrWhite);਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtTargetRetraceLong.FontSize(10);਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtTargetRetraceLong.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㈀㄀　Ⰰ ㌀　㔀Ⰰ ㌀㄀㐀Ⰰ ㌀㈀㌀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblTargetRetraceShortWords.Text("Sell Retrace：");਍      氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblTargetRetraceShortWords.Font(Font_Name);਍      氀戀氀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblTargetRetraceShortWords)) return(false);਍      ഀഀ
      if(!edtTargetRetraceShort.Create(m_chart_id, "edtTargetRetraceShort", m_subwin, 316, 303, 402, 323)) return(false);਍      ⼀⼀攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀⸀吀攀砀琀⠀∀　⸀㄀㈀㌀㐀∀⤀㬀ഀഀ
      edtTargetRetraceShort.Text("0.0000");਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtTargetRetraceShort.Color(clrWhite);਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtTargetRetraceShort.FontSize(10);਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtTargetRetraceShort.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㄀Ⰰ ㌀㈀㠀Ⰰ ㄀　㔀Ⰰ ㌀㐀㘀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblAddPositionTimesLongWords.Text("Buy Add Position Times：");਍      氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblAddPositionTimesLongWords.Font(Font_Name);਍      氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblAddPositionTimesLongWords)) return(false);਍      ഀഀ
      if(!edtAddPositionTimesLong.Create(m_chart_id, "edtAddPositionTimesLong", m_subwin, 165, 326, 193, 346)) return(false);਍      ⼀⼀攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最⸀吀攀砀琀⠀∀㄀㈀∀⤀㬀ഀഀ
      edtAddPositionTimesLong.Text("-1");਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtAddPositionTimesLong.Color(clrWhite);਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtAddPositionTimesLong.FontSize(10);਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtAddPositionTimesLong.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ ㈀㄀　Ⰰ ㌀㈀㠀Ⰰ ㌀㄀㐀Ⰰ ㌀㐀㘀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblAddPositionTimesShortWords.Text("Sell Add Position Times：");਍      氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblAddPositionTimesShortWords.Font(Font_Name);਍      氀戀氀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblAddPositionTimesShortWords)) return(false);਍      ഀഀ
      if(!edtAddPositionTimesShort.Create(m_chart_id, "edtAddPositionTimesShort", m_subwin, 374, 326, 402, 346)) return(false);਍      ⼀⼀攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀⸀吀攀砀琀⠀∀㄀㈀∀⤀㬀ഀഀ
      edtAddPositionTimesShort.Text("-1");਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
      edtAddPositionTimesShort.Color(clrWhite);਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      edtAddPositionTimesShort.FontSize(10);਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀⸀刀攀愀搀伀渀氀礀⠀琀爀甀攀⤀㬀ഀഀ
      edtAddPositionTimesShort.TextAlign(ALIGN_RIGHT);਍      椀昀⠀℀䄀搀搀⠀攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      ഀഀ
      if(!edtVerticalLine2.Create(m_chart_id, "edtVerticalLine2", m_subwin, 408, 1, 411, 350)) return(false);਍      攀搀琀嘀攀爀琀椀挀愀氀䰀椀渀攀㈀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䌀漀爀愀氀⤀㬀ഀഀ
      edtVerticalLine2.ColorBorder(clrCoral);਍      攀搀琀嘀攀爀琀椀挀愀氀䰀椀渀攀㈀⸀刀攀愀搀伀渀氀礀⠀昀愀氀猀攀⤀㬀ഀഀ
      if(!Add(edtVerticalLine2)) return(false);਍      ഀഀ
      /******************Input Parameters********************************/਍      椀昀⠀℀氀戀氀倀愀爀愀洀攀琀攀爀猀圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀倀愀爀愀洀攀琀攀爀猀圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㐀㈀　Ⰰ ㄀Ⰰ 㔀㤀　Ⰰ ㈀㔀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblParametersWords.Text("Input Parameters");਍      氀戀氀倀愀爀愀洀攀琀攀爀猀圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblParametersWords.Font(Font_Name);਍      氀戀氀倀愀爀愀洀攀琀攀爀猀圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㄀㠀⤀㬀ഀഀ
      if(!Add(lblParametersWords)) return(false);਍      ഀഀ
      if(!lblInitLotSize.Create(m_chart_id, "lblInitLotSize", m_subwin, 434, 32, 495, 50)) return(false);਍      氀戀氀䤀渀椀琀䰀漀琀匀椀稀攀⸀吀攀砀琀⠀∀䤀渀椀琀 䰀漀琀猀ᨀ⋿⤀㬀ഀഀ
      lblInitLotSize.Color(clrWhite);਍      氀戀氀䤀渀椀琀䰀漀琀匀椀稀攀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblInitLotSize.FontSize(9);਍      椀昀⠀℀䄀搀搀⠀氀戀氀䤀渀椀琀䰀漀琀匀椀稀攀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀猀攀昀䤀渀椀琀䰀漀琀匀椀稀攀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀猀攀昀䤀渀椀琀䰀漀琀匀椀稀攀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㔀　　Ⰰ ㌀　Ⰰ 㘀㈀㠀Ⰰ 㔀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      sefInitLotSize.MinValue(0.01);਍      猀攀昀䤀渀椀琀䰀漀琀匀椀稀攀⸀䴀愀砀嘀愀氀甀攀⠀㤀㤀㤀⸀㤀㤀⤀㬀ഀഀ
      sefInitLotSize.Value(initLots);਍      椀昀⠀℀䄀搀搀⠀猀攀昀䤀渀椀琀䰀漀琀匀椀稀攀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀䜀爀椀搀倀漀椀渀琀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀䜀爀椀搀倀漀椀渀琀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㐀㄀㘀Ⰰ 㔀㐀Ⰰ 㐀㤀㔀Ⰰ 㜀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblGridPoints.Text("Grid Points：");਍      氀戀氀䜀爀椀搀倀漀椀渀琀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblGridPoints.Font(Font_Name);਍      氀戀氀䜀爀椀搀倀漀椀渀琀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblGridPoints)) return(false);਍      ഀഀ
      if(!speGridPoints.Create(m_chart_id, "speGridPoints", m_subwin, 500, 52, 628, 70)) return(false);਍      猀瀀攀䜀爀椀搀倀漀椀渀琀猀⸀䴀椀渀嘀愀氀甀攀⠀㄀　　⤀㬀ഀഀ
      speGridPoints.MaxValue(100000);਍      猀瀀攀䜀爀椀搀倀漀椀渀琀猀⸀嘀愀氀甀攀⠀最爀椀搀⤀㬀ഀഀ
      if(!Add(speGridPoints)) return(false);਍ഀഀ
      if(!lblTakeProfitPoints.Create(m_chart_id, "lblTakeProfitPoints", m_subwin, 413, 74, 545, 90)) return(false);਍      氀戀氀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀⸀吀攀砀琀⠀∀吀愀欀攀 倀爀漀昀椀琀 倀漀椀渀琀猀ᨀ⋿⤀㬀ഀഀ
      lblTakeProfitPoints.Color(clrWhite);਍      氀戀氀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblTakeProfitPoints.FontSize(9);਍      椀昀⠀℀䄀搀搀⠀氀戀氀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀猀瀀攀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀猀瀀攀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㔀㔀　Ⰰ 㜀㈀Ⰰ 㘀㈀㠀Ⰰ 㤀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      speTakeProfitPoints.MinValue(10);਍      猀瀀攀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀⸀䴀愀砀嘀愀氀甀攀⠀㄀　　　　　⤀㬀ഀഀ
      speTakeProfitPoints.Value(tpPoints);਍      椀昀⠀℀䄀搀搀⠀猀瀀攀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀氀戀氀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㐀㄀㌀Ⰰ 㤀㐀Ⰰ 㔀㐀㔀Ⰰ ㄀㄀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblRetraceProfitCoefficient.Text("Retrace Coefficient：");਍      氀戀氀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblRetraceProfitCoefficient.Font(Font_Name);਍      氀戀氀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblRetraceProfitCoefficient)) return(false);਍      ഀഀ
      if(!sefRetraceProfitCoefficient.Create(m_chart_id, "sefRetraceProfitCoefficient", m_subwin, 550, 92, 628, 110)) return(false);਍      猀攀昀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀⸀䴀椀渀嘀愀氀甀攀⠀　⸀　㔀⤀㬀ഀഀ
      sefRetraceProfitCoefficient.MaxValue(999.99);਍      猀攀昀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀⸀嘀愀氀甀攀⠀爀攀琀爀愀挀攀倀爀漀昀椀琀刀愀琀椀漀⤀㬀ഀഀ
      if(!Add(sefRetraceProfitCoefficient)) return(false);਍ഀഀ
      if(!lblMaxTimesAddPosition.Create(m_chart_id, "lblMaxTimesAddPosition", m_subwin, 413, 114, 575, 130)) return(false);਍      氀戀氀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀⸀吀攀砀琀⠀∀䴀愀砀 䄀搀搀 倀漀猀椀琀椀漀渀 吀椀洀攀猀ᨀ⋿⤀㬀ഀഀ
      lblMaxTimesAddPosition.Color(clrWhite);਍      氀戀氀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblMaxTimesAddPosition.FontSize(9);਍      椀昀⠀℀䄀搀搀⠀氀戀氀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀猀瀀攀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀猀瀀攀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㔀㠀　Ⰰ ㄀㄀㈀Ⰰ 㘀㈀㠀Ⰰ ㄀㌀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      speMaxTimesAddPosition.MinValue(3);਍      猀瀀攀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀⸀䴀愀砀嘀愀氀甀攀⠀㄀　　⤀㬀ഀഀ
      speMaxTimesAddPosition.Value(maxTimes4AP);਍      椀昀⠀℀䄀搀搀⠀猀瀀攀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀挀欀戀䄀搀搀倀漀猀椀琀椀漀渀䈀礀吀爀攀渀搀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀挀欀戀䄀搀搀倀漀猀椀琀椀漀渀䈀礀吀爀攀渀搀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㐀㈀　Ⰰ ㄀㌀㈀Ⰰ 㘀㈀㠀Ⰰ ㄀㔀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ckbAddPositionByTrend.Checked(addPosition2Trend);਍      椀昀 ⠀愀搀搀倀漀猀椀琀椀漀渀㈀吀爀攀渀搀⤀ 笀ഀഀ
         ckbAddPositionByTrend.Text("    Add Position By Trend");਍      紀 攀氀猀攀 笀ഀഀ
         ckbAddPositionByTrend.Text("   Don't Add Position By Trend");਍      紀ഀഀ
      if(!Add(ckbAddPositionByTrend)) return(false);਍ഀഀ
      if(!lblCloseMode.Create(m_chart_id, "lblCloseMode", m_subwin, 420, 154, 495, 170)) return(false);਍      氀戀氀䌀氀漀猀攀䴀漀搀攀⸀吀攀砀琀⠀∀䌀氀漀猀攀 䴀漀搀攀ᨀ⋿⤀㬀ഀഀ
      lblCloseMode.Color(clrWhite);਍      氀戀氀䌀氀漀猀攀䴀漀搀攀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblCloseMode.FontSize(9);਍      椀昀⠀℀䄀搀搀⠀氀戀氀䌀氀漀猀攀䴀漀搀攀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀挀洀戀䌀氀漀猀攀䴀漀搀攀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀挀洀戀䌀氀漀猀攀䴀漀搀攀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㔀　　Ⰰ ㄀㔀㈀Ⰰ 㘀㈀㠀Ⰰ ㄀㜀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      if(!cmbCloseMode.ItemAdd("Close_All")) return(false);਍      椀昀⠀℀挀洀戀䌀氀漀猀攀䴀漀搀攀⸀䤀琀攀洀䄀搀搀⠀∀䌀氀漀猀攀开倀愀爀琀∀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      if(!cmbCloseMode.ItemAdd("Close_Part_All")) return(false);਍      椀昀 ⠀䌀氀漀猀攀开䄀氀氀 㴀㴀 䌀氀漀猀攀䴀漀搀攀⤀ 笀ഀഀ
         if(!cmbCloseMode.SelectByText("Close_All")) return (false);਍      紀 攀氀猀攀 椀昀 ⠀䌀氀漀猀攀开倀愀爀琀 㴀㴀 䌀氀漀猀攀䴀漀搀攀⤀ 笀ഀഀ
         if(!cmbCloseMode.SelectByText("Close_Part")) return (false);਍      紀 攀氀猀攀 笀ഀഀ
         if(!cmbCloseMode.SelectByText("Close_Part_All")) return (false);਍      紀ഀഀ
      ਍      椀昀⠀℀䄀搀搀⠀挀洀戀䌀氀漀猀攀䴀漀搀攀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㐀㈀　Ⰰ ㄀㜀㐀Ⰰ 㔀㐀㔀Ⰰ ㄀㤀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblAddPositionMode.Text("Add Position Mode：");਍      氀戀氀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblAddPositionMode.Font(Font_Name);਍      氀戀氀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblAddPositionMode)) return(false);਍      ഀഀ
      if(!cmbAddPositionMode.Create(m_chart_id, "cmbAddPositionMode", m_subwin, 550, 172, 628, 190)) return(false);਍      椀昀⠀℀挀洀戀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⸀䤀琀攀洀䄀搀搀⠀∀䘀椀砀攀搀∀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      if(!cmbAddPositionMode.ItemAdd("Multiplied")) return(false);਍      椀昀 ⠀䘀椀砀攀搀 㴀㴀 䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⤀ 笀ഀഀ
         if(!cmbAddPositionMode.SelectByText("Fixed")) return (false);਍      紀 攀氀猀攀 笀ഀഀ
         if(!cmbAddPositionMode.SelectByText("Multiplied")) return (false);਍      紀ഀഀ
      if(!Add(cmbAddPositionMode)) return(false);਍      ഀഀ
      if(!lblLotAddPositionStep.Create(m_chart_id, "lblLotAddPositionStep", m_subwin, 413, 194, 555, 210)) return(false);਍      氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀⸀吀攀砀琀⠀∀䰀漀琀猀 䄀搀搀 倀漀猀椀琀椀漀渀 匀琀攀瀀ᨀ⋿⤀㬀ഀഀ
      lblLotAddPositionStep.Color(clrWhite);਍      氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblLotAddPositionStep.FontSize(9);਍      椀昀⠀℀䄀搀搀⠀氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㔀㘀　Ⰰ ㄀㤀㈀Ⰰ 㘀㈀㠀Ⰰ ㈀㄀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      sefLotAddPositionStep.MinValue(0.01);਍      猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀⸀䴀愀砀嘀愀氀甀攀⠀㤀㤀㤀⸀㤀㤀⤀㬀ഀഀ
      sefLotAddPositionStep.Value(lotStep);਍      椀昀⠀℀䄀搀搀⠀猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㐀㄀㌀Ⰰ ㈀㄀㐀Ⰰ 㔀㜀㔀Ⰰ ㈀㌀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblLotAddPositionMultiple.Text("Lots Add Position Multiple：");਍      氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblLotAddPositionMultiple.Font(Font_Name);਍      氀戀氀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblLotAddPositionMultiple)) return(false);਍      ഀഀ
      if(!sefLotAddPositionMultiple.Create(m_chart_id, "sefLotAddPositionMultiple", m_subwin, 580, 212, 628, 230)) return(false);਍      猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀⸀䴀椀渀嘀愀氀甀攀⠀㄀⸀㄀⤀㬀ഀഀ
      sefLotAddPositionMultiple.MaxValue(10.0);਍      猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀⸀嘀愀氀甀攀⠀氀漀琀䴀甀氀琀椀瀀氀攀⤀㬀ഀഀ
      if(!Add(sefLotAddPositionMultiple)) return(false);਍      ഀഀ
      if(!lblMaxLots4AddPositionLimit.Create(m_chart_id, "lblMaxLots4AddPositionLimit", m_subwin, 413, 234, 555, 250)) return(false);਍      氀戀氀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀⸀吀攀砀琀⠀∀䴀愀砀 䄀搀搀 倀漀猀椀琀椀漀渀 䰀漀琀猀ᨀ⋿⤀㬀ഀഀ
      lblMaxLots4AddPositionLimit.Color(clrWhite);਍      氀戀氀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀⸀䘀漀渀琀⠀䘀漀渀琀开一愀洀攀⤀㬀ഀഀ
      lblMaxLots4AddPositionLimit.FontSize(9);਍      椀昀⠀℀䄀搀搀⠀氀戀氀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      ਍      椀昀⠀℀猀攀昀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀猀攀昀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㔀㘀　Ⰰ ㈀㌀㈀Ⰰ 㘀㈀㠀Ⰰ ㈀㔀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      sefMaxLots4AddPositionLimit.MinValue(0.01);਍      猀攀昀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀⸀䴀愀砀嘀愀氀甀攀⠀㄀　　⸀　　⤀㬀ഀഀ
      sefMaxLots4AddPositionLimit.Value(Max_Lot_AP);਍      椀昀⠀℀䄀搀搀⠀猀攀昀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
਍      椀昀⠀℀氀戀氀䴀愀最椀挀一甀洀戀攀爀圀漀爀搀猀⸀䌀爀攀愀琀攀⠀洀开挀栀愀爀琀开椀搀Ⰰ ∀氀戀氀䴀愀最椀挀一甀洀戀攀爀圀漀爀搀猀∀Ⰰ 洀开猀甀戀眀椀渀Ⰰ 㐀㄀㌀Ⰰ ㈀㔀㐀Ⰰ 㔀　㔀Ⰰ ㈀㜀　⤀⤀ 爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      lblMagicNumberWords.Text("Magic Number：");਍      氀戀氀䴀愀最椀挀一甀洀戀攀爀圀漀爀搀猀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      lblMagicNumberWords.Font(Font_Name);਍      氀戀氀䴀愀最椀挀一甀洀戀攀爀圀漀爀搀猀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      if(!Add(lblMagicNumberWords)) return(false);਍      ഀഀ
      if(!edtMagicNumber.Create(m_chart_id, "edtMagicNumber", m_subwin, 510, 252, 628, 270)) return(false);਍      攀搀琀䴀愀最椀挀一甀洀戀攀爀⸀吀攀砀琀⠀䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀䴀愀最椀挀一甀洀戀攀爀⤀⤀㬀ഀഀ
      edtMagicNumber.ColorBackground(clrBlack);਍      攀搀琀䴀愀最椀挀一甀洀戀攀爀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      edtMagicNumber.Font(Font_Name);਍      攀搀琀䴀愀最椀挀一甀洀戀攀爀⸀䘀漀渀琀匀椀稀攀⠀㤀⤀㬀ഀഀ
      edtMagicNumber.ReadOnly(true);਍      攀搀琀䴀愀最椀挀一甀洀戀攀爀⸀吀攀砀琀䄀氀椀最渀⠀䄀䰀䤀䜀一开刀䤀䜀䠀吀⤀㬀ഀഀ
      if(!Add(edtMagicNumber)) return(false);਍      ഀഀ
      return(true);਍   紀ഀഀ
   ਍   戀漀漀氀 爀甀渀⠀瘀漀椀搀⤀ 笀ഀഀ
      //--- redraw chart for dialog invalidate਍      洀开挀栀愀爀琀⸀刀攀搀爀愀眀⠀⤀㬀ഀഀ
      //--- here we begin to assign IDs to controls਍      椀昀⠀ 䤀搀⠀洀开猀甀戀眀椀渀⨀䌀伀一吀刀伀䰀匀开䴀䄀堀䤀䴀唀䴀开䤀䐀⤀ 㸀 䌀伀一吀刀伀䰀匀开䴀䄀堀䤀䴀唀䴀开䤀䐀 ⤀ 笀ഀഀ
         Print("COpPanel: too many objects");਍         爀攀琀甀爀渀⠀昀愀氀猀攀⤀㬀ഀഀ
      }਍      爀攀琀甀爀渀⠀琀爀甀攀⤀㬀ഀഀ
   }਍   ഀഀ
   ਍   瘀漀椀搀 爀攀昀爀攀猀栀吀漀琀愀氀倀爀漀昀椀琀⠀搀漀甀戀氀攀 琀漀琀愀氀倀爀漀昀椀琀⤀ 笀ഀഀ
      edtTotalProfit.Text(DoubleToStr(totalProfit, 2));਍      椀昀 ⠀　 㰀 琀漀琀愀氀倀爀漀昀椀琀⤀ 笀ഀഀ
         edtTotalProfit.Color(clrGreen);਍      紀 攀氀猀攀 椀昀 ⠀琀漀琀愀氀倀爀漀昀椀琀 㰀 　⤀ 笀ഀഀ
         edtTotalProfit.Color(clrRed);਍      紀 攀氀猀攀 笀ഀഀ
         edtTotalProfit.Color(clrWhite);਍      紀ഀഀ
   }਍   ഀഀ
   void refreshProfitCloseLong(double profit) {਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀吀攀砀琀⠀䐀漀甀戀氀攀吀漀匀琀爀⠀瀀爀漀昀椀琀Ⰰ ㈀⤀⤀㬀ഀഀ
      if (0 < profit) {਍         攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀䜀爀攀攀渀⤀㬀ഀഀ
      } else if (profit < 0) {਍         攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀刀攀搀⤀㬀ഀഀ
      } else {਍         攀搀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      }਍   紀ഀഀ
   ਍   瘀漀椀搀 爀攀昀爀攀猀栀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⠀搀漀甀戀氀攀 瀀爀漀昀椀琀⤀ 笀ഀഀ
      edtProfitCloseShort.Text(DoubleToStr(profit, 2));਍      椀昀 ⠀　 㰀 瀀爀漀昀椀琀⤀ 笀ഀഀ
         edtProfitCloseShort.Color(clrGreen);਍      紀 攀氀猀攀 椀昀 ⠀瀀爀漀昀椀琀 㰀 　⤀ 笀ഀഀ
         edtProfitCloseShort.Color(clrRed);਍      紀 攀氀猀攀 笀ഀഀ
         edtProfitCloseShort.Color(clrWhite);਍      紀ഀഀ
   }਍   ഀഀ
   void refreshProfitDecreaseLong(double profit) {਍      攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀吀攀砀琀⠀䐀漀甀戀氀攀吀漀匀琀爀⠀瀀爀漀昀椀琀Ⰰ ㈀⤀⤀㬀ഀഀ
      if (0 < profit) {਍         攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀䜀爀攀攀渀⤀㬀ഀഀ
      } else if (profit < 0) {਍         攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀刀攀搀⤀㬀ഀഀ
      } else {਍         攀搀琀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      }਍   紀ഀഀ
   ਍   瘀漀椀搀 爀攀昀爀攀猀栀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀⠀搀漀甀戀氀攀 瀀爀漀昀椀琀⤀ 笀ഀഀ
      edtProfitDecreaseShort.Text(DoubleToStr(profit, 2));਍      椀昀 ⠀　 㰀 瀀爀漀昀椀琀⤀ 笀ഀഀ
         edtProfitDecreaseShort.Color(clrGreen);਍      紀 攀氀猀攀 椀昀 ⠀瀀爀漀昀椀琀 㰀 　⤀ 笀ഀഀ
         edtProfitDecreaseShort.Color(clrRed);਍      紀 攀氀猀攀 笀ഀഀ
         edtProfitDecreaseShort.Color(clrWhite);਍      紀ഀഀ
   }਍   ഀഀ
   void refreshProfitCloseMaxOrderLong(double profit) {਍      攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀吀攀砀琀⠀䐀漀甀戀氀攀吀漀匀琀爀⠀瀀爀漀昀椀琀Ⰰ ㈀⤀⤀㬀ഀഀ
      if (0 < profit) {਍         攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䌀漀氀漀爀⠀挀氀爀䜀爀攀攀渀⤀㬀ഀഀ
      } else if (profit < 0) {਍         攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䌀漀氀漀爀⠀挀氀爀刀攀搀⤀㬀ഀഀ
      } else {਍         攀搀琀倀爀漀昀椀琀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      }਍   紀ഀഀ
   ਍   瘀漀椀搀 爀攀昀爀攀猀栀倀爀漀昀椀琀䌀氀漀猀攀䴀愀砀伀爀搀攀爀匀栀漀爀琀⠀搀漀甀戀氀攀 瀀爀漀昀椀琀⤀ 笀ഀഀ
      edtProfitCloseTheMaxShortOrder.Text(DoubleToStr(profit, 2));਍      椀昀 ⠀　 㰀 瀀爀漀昀椀琀⤀ 笀ഀഀ
         edtProfitCloseTheMaxShortOrder.Color(clrGreen);਍      紀 攀氀猀攀 椀昀 ⠀瀀爀漀昀椀琀 㰀 　⤀ 笀ഀഀ
         edtProfitCloseTheMaxShortOrder.Color(clrRed);਍      紀 攀氀猀攀 笀ഀഀ
         edtProfitCloseTheMaxShortOrder.Color(clrWhite);਍      紀ഀഀ
   }਍   ഀഀ
   void refreshTargetProfitLong(double targetProfit) {਍      攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀吀攀砀琀⠀䐀漀甀戀氀攀吀漀匀琀爀⠀琀愀爀最攀琀倀爀漀昀椀琀Ⰰ ㈀⤀⤀㬀ഀഀ
      if (targetProfit < 0) {਍         攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀刀攀搀⤀㬀ഀഀ
      } else {਍         攀搀琀吀愀爀最攀琀倀爀漀昀椀琀䌀氀漀猀攀䰀漀渀最⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      }਍   紀ഀഀ
਍   瘀漀椀搀 爀攀昀爀攀猀栀吀愀爀最攀琀倀爀漀昀椀琀匀栀漀爀琀⠀搀漀甀戀氀攀 琀愀爀最攀琀倀爀漀昀椀琀⤀ 笀ഀഀ
      edtTargetProfitCloseShort.Text(DoubleToStr(targetProfit, 2));਍      椀昀 ⠀琀愀爀最攀琀倀爀漀昀椀琀 㰀 　⤀ 笀ഀഀ
         edtTargetProfitCloseShort.Color(clrRed);਍      紀 攀氀猀攀 笀ഀഀ
         edtTargetProfitCloseShort.Color(clrWhite);਍      紀ഀഀ
   }਍   ഀഀ
   void refreshTargetRetraceLong(double retrace) {਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最⸀吀攀砀琀⠀䐀漀甀戀氀攀吀漀匀琀爀⠀爀攀琀爀愀挀攀Ⰰ 㔀⤀⤀㬀ഀഀ
   }਍   ഀഀ
   void refreshTargetRetraceShort(double retrace) {਍      攀搀琀吀愀爀最攀琀刀攀琀爀愀挀攀匀栀漀爀琀⸀吀攀砀琀⠀䐀漀甀戀氀攀吀漀匀琀爀⠀爀攀琀爀愀挀攀Ⰰ 㔀⤀⤀㬀ഀഀ
   }਍   ഀഀ
   void refreshAddPositionTimesLong(int addPositionTimes) {਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最⸀吀攀砀琀⠀䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀愀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀⤀⤀㬀ഀഀ
   }਍   ഀഀ
   void refreshAddPositionTimesShort(int addPositionTimes) {਍      攀搀琀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀匀栀漀爀琀⸀吀攀砀琀⠀䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀愀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀⤀⤀㬀ഀഀ
   }਍   ഀഀ
   void stopEA() {਍      椀猀䄀挀琀椀瘀攀 㴀 昀愀氀猀攀㬀ഀഀ
      btnStopStart.Text("Start");਍      戀琀渀匀琀漀瀀匀琀愀爀琀⸀䌀漀氀漀爀⠀挀氀爀圀栀椀琀攀⤀㬀ഀഀ
      btnStopStart.ColorBackground(clrDarkGreen);਍   紀ഀഀ
   ਍   瘀漀椀搀 爀攀猀甀洀攀䔀䄀⠀⤀ 笀ഀഀ
      isActive = true;਍      戀琀渀匀琀漀瀀匀琀愀爀琀⸀吀攀砀琀⠀∀匀琀漀瀀∀⤀㬀ഀഀ
      btnStopStart.Color(clrWhite);਍      戀琀渀匀琀漀瀀匀琀愀爀琀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䴀愀爀漀漀渀⤀㬀ഀഀ
   }਍   ഀഀ
   void onClickBtnStopStart() {਍      椀昀 ⠀椀猀䄀挀琀椀瘀攀⤀ 笀ഀഀ
         stopEA();਍      紀 攀氀猀攀 笀ഀഀ
         resumeEA();਍      紀ഀഀ
   }਍   ഀഀ
   void OnClickBtnForbidAllow() {਍      椀昀 ⠀椀猀䘀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀䴀愀渀甀愀氀⤀ 笀ഀഀ
         isForbidCreateOrderManual = false;਍         戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀吀攀砀琀⠀∀䘀漀爀戀椀搀∀⤀㬀ഀഀ
         btnForbidAllow.Color(clrWhite);਍         戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀䌀漀氀漀爀䈀愀挀欀最爀漀甀渀搀⠀挀氀爀䴀愀爀漀漀渀⤀㬀ഀഀ
      } else {਍         椀猀䘀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀䴀愀渀甀愀氀 㴀 琀爀甀攀㬀ഀഀ
         btnForbidAllow.Text("Allow");਍         戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⸀䌀漀氀漀爀⠀挀氀爀䈀氀愀挀欀⤀㬀ഀഀ
         btnForbidAllow.ColorBackground(clrLime);਍      紀ഀഀ
   }਍ഀഀ
   void setCloseBuyButton(enButtonMode btnMode) {਍      椀昀 ⠀䌀氀漀猀攀开伀爀搀攀爀开䴀漀搀攀 㴀㴀 戀琀渀䴀漀搀攀⤀ 笀ഀഀ
         btnCloseLong.Text("Close Buy");਍      紀 攀氀猀攀 笀ഀഀ
         btnCloseLong.Text("Create Buy");਍      紀ഀഀ
      btnModeBuy = btnMode;਍   紀ഀഀ
   ਍   瘀漀椀搀 猀攀琀䌀氀漀猀攀匀攀氀氀䈀甀琀琀漀渀⠀攀渀䈀甀琀琀漀渀䴀漀搀攀 戀琀渀䴀漀搀攀⤀ 笀ഀഀ
      if (Close_Order_Mode == btnMode) {਍         戀琀渀䌀氀漀猀攀匀栀漀爀琀⸀吀攀砀琀⠀∀䌀氀漀猀攀 匀攀氀氀∀⤀㬀ഀഀ
      } else {਍         戀琀渀䌀氀漀猀攀匀栀漀爀琀⸀吀攀砀琀⠀∀䌀爀攀愀琀攀 匀攀氀氀∀⤀㬀ഀഀ
      }਍      戀琀渀䴀漀搀攀匀攀氀氀 㴀 戀琀渀䴀漀搀攀㬀ഀഀ
   }਍ഀഀ
   void onClickBtnCloseLong() {਍      椀昀 ⠀䌀氀漀猀攀开伀爀搀攀爀开䴀漀搀攀 㴀㴀 戀琀渀䴀漀搀攀䈀甀礀⤀ 笀ഀഀ
         if (0 <= countAPBuy) {਍            䌀氀漀猀攀䄀氀氀䈀甀礀⠀⤀㬀ഀഀ
            resetStateBuy();਍            猀攀琀䌀氀漀猀攀䈀甀礀䈀甀琀琀漀渀⠀䌀爀攀愀琀攀开伀爀搀攀爀开䴀漀搀攀⤀㬀ഀഀ
            SetComments();਍         紀ഀഀ
      } else {਍         挀爀攀愀琀攀伀爀搀攀爀䈀甀礀⠀椀渀椀琀䰀漀琀匀椀稀攀㐀䈀甀礀⤀㬀ഀഀ
         setCloseBuyButton(Close_Order_Mode);਍         匀攀琀䌀漀洀洀攀渀琀猀⠀⤀㬀ഀഀ
      }਍   紀ഀഀ
   ਍   瘀漀椀搀 漀渀䌀氀椀挀欀䈀琀渀䌀氀漀猀攀匀栀漀爀琀⠀⤀ 笀ഀഀ
      if (Close_Order_Mode == btnModeSell) {਍         椀昀 ⠀　 㰀㴀 挀漀甀渀琀䄀倀匀攀氀氀⤀ 笀ഀഀ
            CloseAllSell();਍            爀攀猀攀琀匀琀愀琀攀匀攀氀氀⠀⤀㬀ഀഀ
            setCloseSellButton(Create_Order_Mode);਍            匀攀琀䌀漀洀洀攀渀琀猀⠀⤀㬀ഀഀ
         }਍      紀 攀氀猀攀 笀ഀഀ
         createOrderSell(initLotSize4Sell);਍         猀攀琀䌀氀漀猀攀匀攀氀氀䈀甀琀琀漀渀⠀䌀氀漀猀攀开伀爀搀攀爀开䴀漀搀攀⤀㬀ഀഀ
         SetComments();਍      紀ഀഀ
   }਍   ഀഀ
   void onClickBtnDecreaseLong() {਍      椀昀 ⠀　 㰀 挀漀甀渀琀䄀倀䈀甀礀⤀ 笀ഀഀ
         DecreaseLongPosition();਍         匀攀琀䌀漀洀洀攀渀琀猀⠀⤀㬀ഀഀ
      }਍   紀ഀഀ
   ਍   瘀漀椀搀 漀渀䌀氀椀挀欀䈀琀渀䐀攀挀爀攀愀猀攀匀栀漀爀琀⠀⤀ 笀ഀഀ
      if (0 < countAPSell) {਍         䐀攀挀爀攀愀猀攀匀栀漀爀琀倀漀猀椀琀椀漀渀⠀⤀㬀ഀഀ
         SetComments();਍      紀ഀഀ
   }਍   ഀഀ
   /*******************TODO BEGIN***********************/਍   瘀漀椀搀 漀渀䌀氀椀挀欀䈀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀⠀⤀ 笀ഀഀ
      doAP4LongByManual();਍   紀ഀഀ
   ਍   瘀漀椀搀 漀渀䌀氀椀挀欀䈀琀渀䄀搀搀㄀匀栀漀爀琀伀爀搀攀爀⠀⤀ 笀ഀഀ
      doAP4ShortByManual();਍   紀ഀഀ
   ਍   瘀漀椀搀 漀渀䌀氀椀挀欀䈀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⠀⤀ 笀ഀഀ
      closeMaxAPLongOrder();਍   紀ഀഀ
   ਍   瘀漀椀搀 漀渀䌀氀椀挀欀䈀琀渀䌀氀漀猀攀吀栀攀䴀愀砀匀栀漀爀琀伀爀搀攀爀⠀⤀ 笀ഀഀ
      closeMaxAPShortOrder();਍   紀ഀഀ
   ਍   ⼀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀吀伀䐀伀 䔀一䐀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⨀⼀ഀഀ
   ਍   瘀漀椀搀 伀渀䌀栀愀渀最攀匀攀昀䤀渀椀琀䰀漀琀匀椀稀攀⠀⤀ 笀ഀഀ
      initLots = StrToDouble(sefInitLotSize.Value());਍      瀀爀椀渀琀昀⠀∀椀渀椀琀䰀漀琀猀 椀猀 挀栀愀渀最攀搀 琀漀 ∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀椀渀椀琀䰀漀琀猀Ⰰ ㈀⤀⤀㬀ഀഀ
   }਍   ഀഀ
   void OnChangeSpeGridPoints() {਍      椀昀 ⠀　 㴀㴀 挀漀甀渀琀伀爀搀攀爀猀⠀⤀⤀ 笀ഀഀ
         grid = StrToInteger(speGridPoints.Value());਍         最爀椀搀倀爀椀挀攀 㴀 一漀爀洀愀氀椀稀攀䐀漀甀戀氀攀⠀倀漀椀渀琀 ⨀ 最爀椀搀Ⰰ 䐀椀最椀琀猀⤀㬀ഀഀ
         printf("grid is changed to " + IntegerToString(grid));਍         爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀㬀ഀഀ
         resetRetrace4Sell();਍      紀 攀氀猀攀 笀ഀഀ
         Alert("Orders > 0, you can't change it.");਍      紀ഀഀ
   }਍ഀഀ
   void OnChangeSpeTakeProfitPoints() {਍      琀瀀倀漀椀渀琀猀 㴀 匀琀爀吀漀䤀渀琀攀最攀爀⠀猀瀀攀吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀⸀嘀愀氀甀攀⠀⤀⤀㬀ഀഀ
      tp = NormalizeDouble(Point * tpPoints, Digits);਍      瀀爀椀渀琀昀⠀∀琀瀀倀漀椀渀琀猀 椀猀 挀栀愀渀最攀搀 琀漀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀琀瀀倀漀椀渀琀猀⤀⤀㬀ഀഀ
   }਍ഀഀ
   void OnChangeSefRetraceProfitCoefficient() {਍      爀攀琀爀愀挀攀倀爀漀昀椀琀刀愀琀椀漀 㴀 匀琀爀吀漀䐀漀甀戀氀攀⠀猀攀昀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀⸀嘀愀氀甀攀⠀⤀⤀㬀ഀഀ
      printf("retraceProfitRatio is changed to " + DoubleToStr(retraceProfitRatio, 2));਍      爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀㬀ഀഀ
      resetRetrace4Sell();਍   紀ഀഀ
਍   瘀漀椀搀 伀渀䌀栀愀渀最攀匀瀀攀䴀愀砀吀椀洀攀猀䄀搀搀倀漀猀椀琀椀漀渀⠀⤀ 笀ഀഀ
      maxTimes4AP = StrToInteger(speMaxTimesAddPosition.Value());਍      琀椀洀攀猀开倀愀爀琀㈀䄀氀氀 㴀 洀愀砀吀椀洀攀猀㐀䄀倀 ⴀ ㌀㬀ഀഀ
      printf("maxTimes4AP is changed to " + IntegerToString(maxTimes4AP));਍   紀ഀഀ
   ਍   瘀漀椀搀 伀渀䌀栀愀渀最攀䌀欀戀䄀搀搀倀漀猀椀琀椀漀渀䈀礀吀爀攀渀搀⠀⤀ 笀ഀഀ
      addPosition2Trend = ckbAddPositionByTrend.Checked();਍      椀昀 ⠀愀搀搀倀漀猀椀琀椀漀渀㈀吀爀攀渀搀⤀ 笀ഀഀ
         ckbAddPositionByTrend.Text("    Add Position By Trend");਍         瀀爀椀渀琀昀⠀∀愀搀搀倀漀猀椀琀椀漀渀㈀吀爀攀渀搀 椀猀 挀栀愀渀最攀搀 琀漀 琀爀甀攀∀⤀㬀ഀഀ
      } else {਍         挀欀戀䄀搀搀倀漀猀椀琀椀漀渀䈀礀吀爀攀渀搀⸀吀攀砀琀⠀∀   䐀漀渀✀琀 䄀搀搀 倀漀猀椀琀椀漀渀 䈀礀 吀爀攀渀搀∀⤀㬀ഀഀ
         printf("addPosition2Trend is changed to false");਍      紀ഀഀ
      ਍   紀ഀഀ
਍   瘀漀椀搀 伀渀䌀栀愀渀最攀匀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀⠀⤀ 笀ഀഀ
      lotStep = StrToDouble(sefLotAddPositionStep.Value());਍      瀀爀椀渀琀昀⠀∀氀漀琀匀琀攀瀀 椀猀 挀栀愀渀最攀搀 琀漀 ∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀氀漀琀匀琀攀瀀Ⰰ ㈀⤀⤀㬀ഀഀ
   }਍ഀഀ
   void OnChangeSefLotAddPositionMultiple() {਍      椀昀 ⠀　 㴀㴀 挀漀甀渀琀伀爀搀攀爀猀⠀⤀⤀ 笀ഀഀ
         lotMultiple = StrToDouble(sefLotAddPositionMultiple.Value());਍         瀀爀椀渀琀昀⠀∀氀漀琀䴀甀氀琀椀瀀氀攀 椀猀 挀栀愀渀最攀搀 琀漀 ∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀氀漀琀䴀甀氀琀椀瀀氀攀Ⰰ ㈀⤀⤀㬀ഀഀ
         resetRetrace4Buy();਍         爀攀猀攀琀刀攀琀爀愀挀攀㐀匀攀氀氀⠀⤀㬀ഀഀ
      } else {਍         䄀氀攀爀琀⠀∀伀爀搀攀爀猀 㸀 　Ⰰ 礀漀甀 挀愀渀✀琀 挀栀愀渀最攀 椀琀⸀∀⤀㬀ഀഀ
      }਍   紀ഀഀ
਍   瘀漀椀搀 伀渀䌀栀愀渀最攀匀攀昀䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀⠀⤀ 笀ഀഀ
      Max_Lot_AP = StrToDouble(sefMaxLots4AddPositionLimit.Value());਍      瀀爀椀渀琀昀⠀∀䴀愀砀开䰀漀琀开䄀倀 椀猀 挀栀愀渀最攀搀 琀漀 ∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀䴀愀砀开䰀漀琀开䄀倀Ⰰ ㈀⤀⤀㬀ഀഀ
   }਍   ഀഀ
   void OnChangeCmbCloseMode() {਍      猀琀爀椀渀最 挀氀漀猀攀䴀漀搀攀吀攀砀琀 㴀 挀洀戀䌀氀漀猀攀䴀漀搀攀⸀匀攀氀攀挀琀⠀⤀㬀ഀഀ
      if ("Close_All" == closeModeText) {਍         挀氀漀猀攀倀漀猀椀琀椀漀渀䴀漀搀攀 㴀 䌀氀漀猀攀开䄀氀氀㬀ഀഀ
      } else if ("Close_Part" == closeModeText) {਍         挀氀漀猀攀倀漀猀椀琀椀漀渀䴀漀搀攀 㴀 䌀氀漀猀攀开倀愀爀琀㬀ഀഀ
      } else {਍         挀氀漀猀攀倀漀猀椀琀椀漀渀䴀漀搀攀 㴀 䌀氀漀猀攀开倀愀爀琀开䄀氀氀㬀ഀഀ
      }਍      爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀㬀ഀഀ
      resetRetrace4Sell();਍      瀀爀椀渀琀昀⠀∀挀氀漀猀攀倀漀猀椀琀椀漀渀䴀漀搀攀 椀猀 挀栀愀渀最攀搀 琀漀 ∀ ⬀ 挀氀漀猀攀䴀漀搀攀吀攀砀琀⤀㬀ഀഀ
   }਍   ഀഀ
   void OnChangeCmbAddPositionMode() {਍      椀昀 ⠀　 㴀㴀 挀漀甀渀琀伀爀搀攀爀猀⠀⤀⤀ 笀ഀഀ
         string addPositionModeText = cmbAddPositionMode.Select();਍         椀昀 ⠀∀䘀椀砀攀搀∀ 㴀㴀 愀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀吀攀砀琀⤀ 笀ഀഀ
            addPositionMode = Fixed;਍         紀 攀氀猀攀 笀ഀഀ
            addPositionMode = Multiplied;਍         紀ഀഀ
         printf("addPositionMode is changed to " + addPositionModeText);਍         爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀㬀ഀഀ
         resetRetrace4Sell();਍      紀 攀氀猀攀 笀ഀഀ
         Alert("Orders > 0, you can't change it.");਍      紀ഀഀ
   }਍   ഀഀ
};਍⼀⼀⬀ⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀ⬀ഀഀ
//| Event Handling                                                   |਍⼀⼀⬀ⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀ⬀ഀഀ
਍䔀嘀䔀一吀开䴀䄀倀开䈀䔀䜀䤀一⠀䌀伀瀀倀愀渀攀氀⤀ഀഀ
ON_EVENT(ON_CLICK, btnStopStart,                onClickBtnStopStart)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䰀䤀䌀䬀Ⰰ 戀琀渀䘀漀爀戀椀搀䄀氀氀漀眀Ⰰ              伀渀䌀氀椀挀欀䈀琀渀䘀漀爀戀椀搀䄀氀氀漀眀⤀ഀഀ
ON_EVENT(ON_CLICK, btnCloseLong,                onClickBtnCloseLong)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䰀䤀䌀䬀Ⰰ 戀琀渀䌀氀漀猀攀匀栀漀爀琀Ⰰ               漀渀䌀氀椀挀欀䈀琀渀䌀氀漀猀攀匀栀漀爀琀⤀ഀഀ
ON_EVENT(ON_CLICK, btnDecreaseLong,             onClickBtnDecreaseLong)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䰀䤀䌀䬀Ⰰ 戀琀渀䐀攀挀爀攀愀猀攀匀栀漀爀琀Ⰰ            漀渀䌀氀椀挀欀䈀琀渀䐀攀挀爀攀愀猀攀匀栀漀爀琀⤀ഀഀ
਍伀一开䔀嘀䔀一吀⠀伀一开䌀䰀䤀䌀䬀Ⰰ 戀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀Ⰰ            漀渀䌀氀椀挀欀䈀琀渀䄀搀搀㄀䰀漀渀最伀爀搀攀爀⤀ഀഀ
ON_EVENT(ON_CLICK, btnAdd1ShortOrder,           onClickBtnAdd1ShortOrder)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䰀䤀䌀䬀Ⰰ 戀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀Ⰰ     漀渀䌀氀椀挀欀䈀琀渀䌀氀漀猀攀吀栀攀䴀愀砀䰀漀渀最伀爀搀攀爀⤀ഀഀ
ON_EVENT(ON_CLICK, btnCloseTheMaxShortOrder,    onClickBtnCloseTheMaxShortOrder)਍ഀഀ
ON_EVENT(ON_CHANGE, sefInitLotSize,                OnChangeSefInitLotSize)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䠀䄀一䜀䔀Ⰰ 猀瀀攀䜀爀椀搀倀漀椀渀琀猀Ⰰ                 伀渀䌀栀愀渀最攀匀瀀攀䜀爀椀搀倀漀椀渀琀猀⤀ഀഀ
ON_EVENT(ON_CHANGE, speTakeProfitPoints,           OnChangeSpeTakeProfitPoints)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䠀䄀一䜀䔀Ⰰ 猀攀昀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀Ⰰ   伀渀䌀栀愀渀最攀匀攀昀刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀⤀ഀഀ
ON_EVENT(ON_CHANGE, speMaxTimesAddPosition,        OnChangeSpeMaxTimesAddPosition)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䠀䄀一䜀䔀Ⰰ 挀欀戀䄀搀搀倀漀猀椀琀椀漀渀䈀礀吀爀攀渀搀Ⰰ         伀渀䌀栀愀渀最攀䌀欀戀䄀搀搀倀漀猀椀琀椀漀渀䈀礀吀爀攀渀搀⤀ഀഀ
ON_EVENT(ON_CHANGE, sefLotAddPositionStep,         OnChangeSefLotAddPositionStep)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䠀䄀一䜀䔀Ⰰ 猀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀Ⰰ     伀渀䌀栀愀渀最攀匀攀昀䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀䴀甀氀琀椀瀀氀攀⤀ഀഀ
ON_EVENT(ON_CHANGE, sefMaxLots4AddPositionLimit,   OnChangeSefMaxLots4AddPositionLimit)਍ഀഀ
ON_EVENT(ON_CHANGE, cmbCloseMode,                  OnChangeCmbCloseMode)਍伀一开䔀嘀䔀一吀⠀伀一开䌀䠀䄀一䜀䔀Ⰰ 挀洀戀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀Ⰰ            伀渀䌀栀愀渀最攀䌀洀戀䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⤀ഀഀ
਍⼀⼀伀一开伀吀䠀䔀刀开䔀嘀䔀一吀匀⠀伀渀䐀攀昀愀甀氀琀⤀ഀഀ
EVENT_MAP_END(CAppWindowWithoutCloseButton)਍ഀഀ
//+------------------------------------------------------------------+਍      䌀伀瀀倀愀渀攀氀    漀瀀倀愀渀攀氀㬀ഀഀ
਍椀渀琀 挀漀甀渀琀伀爀搀攀爀猀⠀⤀ 笀ഀഀ
   int orderNumber = 0;਍   昀漀爀 ⠀椀渀琀 椀 㴀 伀爀搀攀爀猀吀漀琀愀氀⠀⤀ⴀ㄀㬀 　 㰀㴀 椀㬀 椀ⴀⴀ⤀ 笀ഀഀ
      if ( OrderSelect(i, SELECT_BY_POS) ) {਍         椀昀 ⠀ 伀爀搀攀爀匀礀洀戀漀氀⠀⤀ 㴀㴀 开匀礀洀戀漀氀 ☀☀ 䴀愀最椀挀一甀洀戀攀爀 㴀㴀 伀爀搀攀爀䴀愀最椀挀一甀洀戀攀爀⠀⤀ ⤀ 笀ഀഀ
            orderNumber++;਍         紀ഀഀ
      }਍   紀ഀഀ
   ਍   爀攀琀甀爀渀 漀爀搀攀爀一甀洀戀攀爀㬀ഀഀ
}਍ഀഀ
bool isAuthorized() {਍   椀昀 ⠀℀䄀挀挀漀甀渀琀䌀琀爀氀⤀ 笀ഀഀ
      return true;਍   紀ഀഀ
   int size = ArraySize(AuthorizeAccountList);਍   椀渀琀 挀甀爀䄀挀挀漀甀渀琀 㴀 䄀挀挀漀甀渀琀一甀洀戀攀爀⠀⤀㬀ഀഀ
   for (int i = 0; i < size; i++) {਍      椀昀 ⠀挀甀爀䄀挀挀漀甀渀琀 㴀㴀 䄀甀琀栀漀爀椀稀攀䄀挀挀漀甀渀琀䰀椀猀琀嬀椀崀⤀ 笀ഀഀ
         return true;਍      紀ഀഀ
   }਍   䄀氀攀爀琀⠀∀怀葏ꑶፎ♦⩓콧衾䍣ŧ哿ﮀ兼儀㨀㄀㠀㌀㤀㐀㜀㈀㠀㄀Ā⋿⤀㬀ഀഀ
   return false;਍紀ഀഀ
਍椀渀琀 伀渀䤀渀椀琀⠀⤀ 笀ഀഀ
਍   椀昀 ⠀℀椀猀䄀甀琀栀漀爀椀稀攀搀⠀⤀⤀ 笀ഀഀ
		return INIT_FAILED;਍ऀ紀ഀഀ
਍   椀昀 ⠀攀渀愀戀氀攀唀猀攀䰀椀洀椀琀⤀ 笀ഀഀ
      datetime now = TimeGMT();਍      椀昀 ⠀攀砀瀀椀爀攀吀椀洀攀 㰀 渀漀眀⤀ 笀ഀഀ
         return INIT_FAILED;਍      紀ഀഀ
   }਍ഀഀ
   if (0 < countOrders()) {਍      䄀氀攀爀琀⠀∀伀爀搀攀爀 䔀砀椀猀琀Ȁ倰氀攀愀猀攀 洀愀渀甀愀氀氀礀 搀攀氀攀琀攀 伀爀搀攀爀 漀爀 洀漀搀椀昀礀 椀渀瀀甀琀 瀀愀爀愀洀攀琀攀爀 䴀愀最椀挀一甀洀戀攀爀⸀∀⤀㬀ഀഀ
      return(INIT_FAILED);਍   紀ഀഀ
਍   搀漀甀戀氀攀 洀椀渀䰀漀琀 㴀 䴀愀爀欀攀琀䤀渀昀漀⠀开匀礀洀戀漀氀Ⰰ 䴀伀䐀䔀开䴀䤀一䰀伀吀⤀㬀ഀഀ
   if (InitLotSize < minLot) {਍      椀渀椀琀䰀漀琀猀 㴀 洀椀渀䰀漀琀㬀ഀഀ
   } else {਍      椀渀椀琀䰀漀琀猀 㴀 䤀渀椀琀䰀漀琀匀椀稀攀㬀ഀഀ
   }਍   ഀഀ
   grid = GridPoints;਍   最爀椀搀倀爀椀挀攀 㴀 一漀爀洀愀氀椀稀攀䐀漀甀戀氀攀⠀倀漀椀渀琀 ⨀ 最爀椀搀Ⰰ 䐀椀最椀琀猀⤀㬀ഀഀ
   ਍   琀瀀倀漀椀渀琀猀 㴀 吀愀欀攀倀爀漀昀椀琀倀漀椀渀琀猀㬀ഀഀ
   tp = NormalizeDouble(Point * tpPoints, Digits);਍   爀攀琀爀愀挀攀倀爀漀昀椀琀刀愀琀椀漀 㴀 刀攀琀爀愀挀攀倀爀漀昀椀琀䌀漀攀昀昀椀挀椀攀渀琀㬀ഀഀ
   maxTimes4AP = MaxTimesAddPosition;਍   琀椀洀攀猀开倀愀爀琀㈀䄀氀氀 㴀 洀愀砀吀椀洀攀猀㐀䄀倀 ⴀ ㌀㬀ഀഀ
   addPosition2Trend = AddPositionByTrend;਍   ഀഀ
   closePositionMode = CloseMode;਍   愀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀 㴀 䄀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀㬀ഀഀ
   ਍   氀漀琀匀琀攀瀀 㴀 䰀漀琀䄀搀搀倀漀猀椀琀椀漀渀匀琀攀瀀㬀ഀഀ
   lotMultiple = LotAddPositionMultiple;਍   爀攀搀甀挀攀䘀愀挀琀漀爀 㴀 ⠀氀漀琀䴀甀氀琀椀瀀氀攀ⴀ㄀⤀⼀氀漀琀䴀甀氀琀椀瀀氀攀㬀ഀഀ
   ਍   椀渀椀琀䰀漀琀匀椀稀攀㐀䈀甀礀 㴀 椀渀椀琀䰀漀琀猀㬀ഀഀ
   initLotSize4Sell = initLots;਍   挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀㐀䈀甀礀 㴀 椀渀椀琀䰀漀琀猀㬀ഀഀ
   curInitLotSize4Sell = initLots;਍   ഀഀ
   arraySize = maxTimes4AP+1;਍   ഀഀ
   ArrayResize(arrOrdersBuy, arraySize);਍   䄀爀爀愀礀刀攀猀椀稀攀⠀愀爀爀伀爀搀攀爀猀匀攀氀氀Ⰰ 愀爀爀愀礀匀椀稀攀⤀㬀ഀഀ
   ਍   䐀爀愀眀䰀椀渀攀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀䈀甀礀Ⰰ 　Ⰰ 挀氀爀䜀漀氀搀Ⰰ 匀吀夀䰀䔀开䐀伀吀⤀㬀ഀഀ
   DrawLine(nmLineClosePositionSell, 0, clrGold, STYLE_DOT);਍   ഀഀ
   btnModeBuy = Close_Order_Mode;਍   戀琀渀䴀漀搀攀匀攀氀氀 㴀 䌀氀漀猀攀开伀爀搀攀爀开䴀漀搀攀㬀ഀഀ
   ਍   猀琀爀椀渀最 昀漀渀琀一愀洀攀 㴀 ∀䰀甀挀椀搀愀 䈀爀椀最栀琀∀㬀ഀഀ
   ਍   ⼀⨀ഀഀ
   if (Fixed == addPositionMode) {਍      䴀愀砀开䰀漀琀开䄀倀 㴀 椀渀椀琀䰀漀琀猀⨀⠀洀愀砀吀椀洀攀猀㐀䄀倀ⴀ㐀⤀㬀ഀഀ
   } else {਍      搀漀甀戀氀攀 氀漀琀䌀漀攀昀昀椀挀椀攀渀琀 㴀 䴀愀琀栀倀漀眀⠀氀漀琀䴀甀氀琀椀瀀氀攀Ⰰ 洀愀砀吀椀洀攀猀㐀䄀倀ⴀ㐀⤀㬀ഀഀ
      Max_Lot_AP = calculateLot(initLots, lotCoefficient);਍   紀ഀഀ
   */਍   䴀愀砀开䰀漀琀开䄀倀 㴀 䴀愀砀䰀漀琀猀㐀䄀搀搀倀漀猀椀琀椀漀渀䰀椀洀椀琀㬀ഀഀ
   isActive = false;਍   ഀഀ
   if(!opPanel.create(0, "OperatePanel", 0)) return(INIT_FAILED);਍ഀഀ
   if(!opPanel.run()) return(INIT_FAILED);਍   ഀഀ
   return(INIT_SUCCEEDED);਍紀ഀഀ
਍瘀漀椀搀 伀渀䐀攀椀渀椀琀⠀挀漀渀猀琀 椀渀琀 爀攀愀猀漀渀⤀ 笀ഀഀ
਍   伀戀樀攀挀琀䐀攀氀攀琀攀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀䈀甀礀⤀㬀ഀഀ
   ObjectDelete(nmLineClosePositionSell);਍ഀഀ
   opPanel.Destroy(reason);਍紀ഀഀ
਍ഀഀ
bool isNewBegin(int orderType) {਍   椀渀琀 挀漀甀渀琀䄀倀 㴀 ⴀ㈀㬀ഀഀ
   switch(orderType) {਍      挀愀猀攀 伀倀开䈀唀夀㨀ഀഀ
         countAP = countAPBuy;਍         戀爀攀愀欀㬀ഀഀ
      case OP_SELL:਍         挀漀甀渀琀䄀倀 㴀 挀漀甀渀琀䄀倀匀攀氀氀㬀ഀഀ
         break;਍      搀攀昀愀甀氀琀㨀ഀഀ
         return false;਍   紀ഀഀ
਍   椀昀 ⠀ⴀ㄀ 㴀㴀 挀漀甀渀琀䄀倀⤀ 笀ഀഀ
      return true;਍   紀ഀഀ
   return false;਍紀ഀഀ
਍戀漀漀氀 椀猀䌀氀漀猀攀䄀氀氀䴀漀搀攀⠀椀渀琀 漀爀搀攀爀吀礀瀀攀⤀ 笀ഀഀ
਍   椀昀 ⠀䌀氀漀猀攀开䄀氀氀 㴀㴀 挀氀漀猀攀倀漀猀椀琀椀漀渀䴀漀搀攀⤀ 笀ഀഀ
      return true;਍   紀ഀഀ
   ਍   椀渀琀 挀漀甀渀琀䄀倀 㴀 挀漀甀渀琀䄀倀匀攀氀氀㬀ഀഀ
   if (OP_BUY == orderType) {਍      挀漀甀渀琀䄀倀 㴀 挀漀甀渀琀䄀倀䈀甀礀㬀ഀഀ
   }਍   ഀഀ
   if (Close_Part_All == closePositionMode && times_Part2All <= countAP) {਍      爀攀琀甀爀渀 琀爀甀攀㬀ഀഀ
   }਍   ഀഀ
   return false;਍ഀഀ
}਍ഀഀ
bool isClosePartMode(int orderType) {਍   椀昀 ⠀䌀氀漀猀攀开倀愀爀琀 㴀㴀 挀氀漀猀攀倀漀猀椀琀椀漀渀䴀漀搀攀⤀ 笀ഀഀ
      return true;਍   紀ഀഀ
   ਍   椀渀琀 挀漀甀渀琀䄀倀 㴀 挀漀甀渀琀䄀倀匀攀氀氀㬀ഀഀ
   if (OP_BUY == orderType) {਍      挀漀甀渀琀䄀倀 㴀 挀漀甀渀琀䄀倀䈀甀礀㬀ഀഀ
   }਍   ഀഀ
   if (Close_Part_All == closePositionMode && countAP < times_Part2All) {਍      爀攀琀甀爀渀 琀爀甀攀㬀ഀഀ
   }਍   ഀഀ
   return false;਍紀ഀഀ
਍瘀漀椀搀 爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀ 笀ഀഀ
   if (countAPBuy < 1) {਍      爀攀琀甀爀渀㬀ഀഀ
   }਍   椀昀 ⠀䘀椀砀攀搀 㴀㴀 愀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⤀ 笀ഀഀ
      retraceRatioBuy = calculateRetrace4Fixed(countAPBuy, initLotSize4Buy) + retraceProfitRatio;਍   紀 攀氀猀攀 笀ഀഀ
      if ( isCloseAllMode(OP_BUY) ) {਍         爀攀琀爀愀挀攀刀愀琀椀漀䈀甀礀 㴀 挀愀氀挀甀氀愀琀攀刀攀琀爀愀挀攀䄀氀氀⠀挀漀甀渀琀䄀倀䈀甀礀Ⰰ 氀漀琀䴀甀氀琀椀瀀氀攀⤀ ⬀ 爀攀琀爀愀挀攀倀爀漀昀椀琀刀愀琀椀漀㬀ഀഀ
      } else if ( isClosePartMode(OP_BUY) ) {਍         爀攀琀爀愀挀攀刀愀琀椀漀䈀甀礀 㴀 挀愀氀挀甀氀愀琀攀刀攀琀爀愀挀攀倀愀爀琀⠀挀漀甀渀琀䄀倀䈀甀礀Ⰰ 氀漀琀䴀甀氀琀椀瀀氀攀⤀ ⬀ 爀攀琀爀愀挀攀倀爀漀昀椀琀刀愀琀椀漀㬀ഀഀ
      }਍   紀ഀഀ
   ਍   椀渀琀 爀攀琀爀愀挀攀倀漀椀渀琀猀 㴀 ⠀椀渀琀⤀ ⠀最爀椀搀 ⨀ 爀攀琀爀愀挀攀刀愀琀椀漀䈀甀礀⤀㬀ഀഀ
   double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;਍   爀攀琀爀愀挀攀倀爀椀挀攀䈀甀礀 㴀 一漀爀洀愀氀椀稀攀䐀漀甀戀氀攀⠀倀漀椀渀琀 ⨀ 爀攀琀爀愀挀攀倀漀椀渀琀猀Ⰰ 䐀椀最椀琀猀⤀ ⬀ 洀椀渀伀瀀攀渀倀爀椀挀攀㬀ഀഀ
   ObjectMove(nmLineClosePositionBuy, 0, 0, retracePriceBuy);਍   挀愀氀挀甀氀愀琀攀䌀氀漀猀攀倀爀漀昀椀琀㐀䈀甀礀⠀⤀㬀ഀഀ
}਍ഀഀ
void resetRetrace4Sell() {਍   椀昀 ⠀挀漀甀渀琀䄀倀匀攀氀氀 㰀 ㄀⤀ 笀ഀഀ
      return;਍   紀ഀഀ
   if (Fixed == addPositionMode) {਍      爀攀琀爀愀挀攀刀愀琀椀漀匀攀氀氀 㴀 挀愀氀挀甀氀愀琀攀刀攀琀爀愀挀攀㐀䘀椀砀攀搀⠀挀漀甀渀琀䄀倀匀攀氀氀Ⰰ 椀渀椀琀䰀漀琀匀椀稀攀㐀匀攀氀氀⤀ ⬀ 爀攀琀爀愀挀攀倀爀漀昀椀琀刀愀琀椀漀㬀ഀഀ
   } else {਍      椀昀 ⠀ 椀猀䌀氀漀猀攀䄀氀氀䴀漀搀攀⠀伀倀开匀䔀䰀䰀⤀ ⤀ 笀ഀഀ
         retraceRatioSell = calculateRetraceAll(countAPSell, lotMultiple) + retraceProfitRatio;਍      紀 攀氀猀攀 椀昀 ⠀ 椀猀䌀氀漀猀攀倀愀爀琀䴀漀搀攀⠀伀倀开匀䔀䰀䰀⤀ ⤀ 笀ഀഀ
         retraceRatioSell = calculateRetracePart(countAPSell, lotMultiple) + retraceProfitRatio;਍      紀ഀഀ
   }਍   ഀഀ
   int retracePoints = (int) (grid * retraceRatioSell);਍   搀漀甀戀氀攀 洀愀砀伀瀀攀渀倀爀椀挀攀 㴀 愀爀爀伀爀搀攀爀猀匀攀氀氀嬀挀漀甀渀琀䄀倀匀攀氀氀崀⸀漀瀀攀渀倀爀椀挀攀㬀ഀഀ
   retracePriceSell = maxOpenPrice - NormalizeDouble(Point * retracePoints, Digits);਍   伀戀樀攀挀琀䴀漀瘀攀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀匀攀氀氀Ⰰ 　Ⰰ 　Ⰰ 爀攀琀爀愀挀攀倀爀椀挀攀匀攀氀氀⤀㬀ഀഀ
   calculateCloseProfit4Sell();਍紀ഀഀ
਍搀漀甀戀氀攀 挀愀氀挀甀氀愀琀攀䰀漀琀⠀搀漀甀戀氀攀 氀漀琀匀椀稀攀Ⰰ 搀漀甀戀氀攀 挀漀攀昀昀椀挀椀攀渀琀⤀ 笀ഀഀ
਍   搀漀甀戀氀攀 洀椀渀䰀漀琀  㴀 䴀愀爀欀攀琀䤀渀昀漀⠀匀礀洀戀漀氀⠀⤀Ⰰ 䴀伀䐀䔀开䴀䤀一䰀伀吀⤀㬀ഀഀ
   double lotStepServer = MarketInfo(Symbol(), MODE_LOTSTEP);਍   ഀഀ
   //double lot = MathFloor(lotSize*coefficient/lotStepServer)*lotStepServer;਍   ⼀⼀搀漀甀戀氀攀 氀漀琀 㴀 䴀愀琀栀䌀攀椀氀⠀氀漀琀匀椀稀攀⨀挀漀攀昀昀椀挀椀攀渀琀⼀氀漀琀匀琀攀瀀匀攀爀瘀攀爀⤀⨀氀漀琀匀琀攀瀀匀攀爀瘀攀爀㬀ഀഀ
   double lot = MathRound(lotSize*coefficient/lotStepServer)*lotStepServer;਍   ഀഀ
   if (lot < minLot) {਍      氀漀琀 㴀 洀椀渀䰀漀琀㬀ഀഀ
   }਍   ഀഀ
   return lot;਍紀ഀഀ
਍搀漀甀戀氀攀 挀愀氀挀甀氀愀琀攀䰀漀琀㐀䄀倀⠀椀渀琀 漀爀搀攀爀吀礀瀀攀⤀ 笀ഀഀ
   double lotsize;਍   椀渀琀 挀漀甀渀琀䄀倀 㴀 ⴀ㈀㬀ഀഀ
   double curInitLotSize;਍ഀഀ
   switch(orderType) {਍      挀愀猀攀 伀倀开䈀唀夀㨀ഀഀ
         countAP = countAPBuy;਍         挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀 㴀 挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀㐀䈀甀礀㬀ഀഀ
         break;਍      挀愀猀攀 伀倀开匀䔀䰀䰀㨀ഀഀ
         countAP = countAPSell;਍         挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀 㴀 挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀㐀匀攀氀氀㬀ഀഀ
         break;਍      搀攀昀愀甀氀琀㨀ഀഀ
         return 0;਍   紀ഀഀ
   ਍   椀昀 ⠀䘀椀砀攀搀 㴀㴀 愀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⤀ 笀ഀഀ
      lotsize = initLots + lotStep*(countAP+1);਍   紀 攀氀猀攀 笀ഀഀ
      double lotCoefficient = MathPow(lotMultiple, countAP+1);਍      氀漀琀猀椀稀攀 㴀 挀愀氀挀甀氀愀琀攀䰀漀琀⠀挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀Ⰰ 氀漀琀䌀漀攀昀昀椀挀椀攀渀琀⤀㬀ഀഀ
   }਍ഀഀ
   return lotsize;਍紀ഀഀ
਍搀漀甀戀氀攀 挀愀氀挀甀氀愀琀攀䤀渀椀琀䰀漀琀⠀椀渀琀 漀爀搀攀爀吀礀瀀攀⤀ 笀ഀഀ
   int countAP = -2;਍   猀眀椀琀挀栀⠀漀爀搀攀爀吀礀瀀攀⤀ 笀ഀഀ
      case OP_BUY:਍         挀漀甀渀琀䄀倀 㴀 挀漀甀渀琀䄀倀匀攀氀氀㬀ഀഀ
         break;਍      挀愀猀攀 伀倀开匀䔀䰀䰀㨀ഀഀ
         countAP = countAPBuy;਍         戀爀攀愀欀㬀ഀഀ
      default:਍         爀攀琀甀爀渀 　㬀ഀഀ
   }਍   ⼀⨀ഀഀ
   if (addPosition2Trend) {਍      椀昀 ⠀䘀椀砀攀搀 㴀㴀 愀搀搀倀漀猀椀琀椀漀渀䴀漀搀攀⤀ 笀ഀഀ
         return (initLots + lotStep*countAP);਍      紀ഀഀ
      return calculateLot(initLots, MathPow(lotMultiple, countAP));਍   紀ഀഀ
   return initLots;਍   ⨀⼀ഀഀ
   double lots = initLots;਍   椀昀 ⠀愀搀搀倀漀猀椀琀椀漀渀㈀吀爀攀渀搀⤀ 笀ഀഀ
      if (Fixed == addPositionMode) {਍         氀漀琀猀 㴀 ⠀椀渀椀琀䰀漀琀猀 ⬀ 氀漀琀匀琀攀瀀⨀挀漀甀渀琀䄀倀⤀㬀ഀഀ
      } else {਍         氀漀琀猀 㴀 挀愀氀挀甀氀愀琀攀䰀漀琀⠀椀渀椀琀䰀漀琀猀Ⰰ 䴀愀琀栀倀漀眀⠀氀漀琀䴀甀氀琀椀瀀氀攀Ⰰ 挀漀甀渀琀䄀倀⤀⤀㬀ഀഀ
      }਍   紀ഀഀ
   if (enableMaxLotControl) {਍      椀昀 ⠀䴀愀砀开䰀漀琀开䄀倀 㰀 氀漀琀猀⤀ 笀ഀഀ
         lots = Max_Lot_AP;਍      紀ഀഀ
   }਍   爀攀琀甀爀渀 氀漀琀猀㬀ഀഀ
}਍ഀഀ
bool doAP4LongByManual() {਍   椀昀 ⠀挀漀甀渀琀䄀倀䈀甀礀 㰀 　⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
   ਍   椀昀 ⠀洀愀砀吀椀洀攀猀㐀䄀倀 㰀㴀 挀漀甀渀琀䄀倀䈀甀礀⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
਍   搀漀甀戀氀攀 洀椀渀伀瀀攀渀倀爀椀挀攀 㴀 愀爀爀伀爀搀攀爀猀䈀甀礀嬀挀漀甀渀琀䄀倀䈀甀礀崀⸀漀瀀攀渀倀爀椀挀攀㬀ഀഀ
   double addPositionPrice = minOpenPrice - gridPrice;਍ഀഀ
   RefreshRates();਍   搀漀甀戀氀攀 氀漀琀猀椀稀攀 㴀 挀愀氀挀甀氀愀琀攀䰀漀琀㐀䄀倀⠀伀倀开䈀唀夀⤀㬀ഀഀ
   createOrderBuy(lotsize);਍   爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀㬀ഀഀ
   return true;਍紀ഀഀ
਍戀漀漀氀 愀搀搀倀漀猀椀琀椀漀渀㐀䈀甀礀⠀⤀ 笀ഀഀ
਍   椀昀 ⠀挀漀甀渀琀䄀倀䈀甀礀 㰀 　⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
   ਍   椀昀 ⠀洀愀砀吀椀洀攀猀㐀䄀倀 㰀㴀 挀漀甀渀琀䄀倀䈀甀礀⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
਍   搀漀甀戀氀攀 洀椀渀伀瀀攀渀倀爀椀挀攀 㴀 愀爀爀伀爀搀攀爀猀䈀甀礀嬀挀漀甀渀琀䄀倀䈀甀礀崀⸀漀瀀攀渀倀爀椀挀攀㬀ഀഀ
   ਍   搀漀甀戀氀攀 愀搀搀倀漀猀椀琀椀漀渀倀爀椀挀攀 㴀 洀椀渀伀瀀攀渀倀爀椀挀攀 ⴀ 最爀椀搀倀爀椀挀攀㬀ഀഀ
   ਍   刀攀昀爀攀猀栀刀愀琀攀猀⠀⤀㬀ഀഀ
   if (Ask < addPositionPrice) {਍      搀漀甀戀氀攀 氀漀琀猀椀稀攀 㴀 挀愀氀挀甀氀愀琀攀䰀漀琀㐀䄀倀⠀伀倀开䈀唀夀⤀㬀ഀഀ
      createOrderBuy(lotsize);਍      爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀㬀ഀഀ
      return true;਍   紀ഀഀ
   ਍   爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
}਍ഀഀ
bool doAP4ShortByManual() {਍   椀昀 ⠀挀漀甀渀琀䄀倀匀攀氀氀 㰀 　⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
਍   椀昀 ⠀洀愀砀吀椀洀攀猀㐀䄀倀 㰀㴀 挀漀甀渀琀䄀倀匀攀氀氀⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
਍   搀漀甀戀氀攀 洀愀砀伀瀀攀渀倀爀椀挀攀 㴀 愀爀爀伀爀搀攀爀猀匀攀氀氀嬀挀漀甀渀琀䄀倀匀攀氀氀崀⸀漀瀀攀渀倀爀椀挀攀㬀ഀഀ
   double addPositionPrice = maxOpenPrice + gridPrice;਍ഀഀ
   RefreshRates();਍   搀漀甀戀氀攀 氀漀琀猀椀稀攀 㴀 挀愀氀挀甀氀愀琀攀䰀漀琀㐀䄀倀⠀伀倀开匀䔀䰀䰀⤀㬀ഀഀ
   createOrderSell(lotsize);਍   爀攀猀攀琀刀攀琀爀愀挀攀㐀匀攀氀氀⠀⤀㬀ഀഀ
   return true;਍紀ഀഀ
਍戀漀漀氀 愀搀搀倀漀猀椀琀椀漀渀㐀匀攀氀氀⠀⤀ 笀ഀഀ
਍   椀昀 ⠀挀漀甀渀琀䄀倀匀攀氀氀 㰀 　⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
   ਍   椀昀 ⠀洀愀砀吀椀洀攀猀㐀䄀倀 㰀㴀 挀漀甀渀琀䄀倀匀攀氀氀⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
   ਍   搀漀甀戀氀攀 洀愀砀伀瀀攀渀倀爀椀挀攀 㴀 愀爀爀伀爀搀攀爀猀匀攀氀氀嬀挀漀甀渀琀䄀倀匀攀氀氀崀⸀漀瀀攀渀倀爀椀挀攀㬀ഀഀ
   ਍   搀漀甀戀氀攀 愀搀搀倀漀猀椀琀椀漀渀倀爀椀挀攀 㴀 洀愀砀伀瀀攀渀倀爀椀挀攀 ⬀ 最爀椀搀倀爀椀挀攀㬀ഀഀ
   ਍   刀攀昀爀攀猀栀刀愀琀攀猀⠀⤀㬀ഀഀ
   if (addPositionPrice < Bid) {਍      搀漀甀戀氀攀 氀漀琀猀椀稀攀 㴀 挀愀氀挀甀氀愀琀攀䰀漀琀㐀䄀倀⠀伀倀开匀䔀䰀䰀⤀㬀ഀഀ
      createOrderSell(lotsize);਍      爀攀猀攀琀刀攀琀爀愀挀攀㐀匀攀氀氀⠀⤀㬀ഀഀ
      return true;਍   紀ഀഀ
   ਍   爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
}਍ഀഀ
void resetStateBuy() {਍   ഀഀ
   countAPBuy = -1;਍ഀഀ
   ArrayResize(arrOrdersBuy, arraySize);਍   ഀഀ
   retraceRatioBuy = 0.0;਍   爀攀琀爀愀挀攀倀爀椀挀攀䈀甀礀 㴀 　⸀　㬀ഀഀ
   ਍   挀氀漀猀攀倀爀漀昀椀琀䈀甀礀 㴀 　⸀　㬀ഀഀ
਍   伀戀樀攀挀琀䴀漀瘀攀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀䈀甀礀Ⰰ 　Ⰰ 　Ⰰ 　⸀　⤀㬀ഀഀ
}਍ഀഀ
void resetStateSell() {਍   ഀഀ
   countAPSell = -1;਍ഀഀ
   ArrayResize(arrOrdersSell, arraySize);਍   ഀഀ
   retraceRatioSell = 0.0;਍   爀攀琀爀愀挀攀倀爀椀挀攀匀攀氀氀 㴀 　⸀　㬀ഀഀ
   ਍   挀氀漀猀攀倀爀漀昀椀琀匀攀氀氀 㴀 　⸀　㬀ഀഀ
਍   伀戀樀攀挀琀䴀漀瘀攀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀匀攀氀氀Ⰰ 　Ⰰ 　Ⰰ 　⸀　⤀㬀ഀഀ
}਍ഀഀ
void resetTicket(int orderType) {਍ഀഀ
   int addPositionCount;਍   搀漀甀戀氀攀 漀爀搀攀爀䰀漀琀㬀ഀഀ
   ਍   昀漀爀 ⠀椀渀琀 椀 㴀 伀爀搀攀爀猀吀漀琀愀氀⠀⤀ⴀ㄀㬀 　 㰀㴀 椀㬀 椀ⴀⴀ⤀ 笀ഀഀ
   ਍      戀漀漀氀 椀猀匀攀氀攀挀琀攀搀 㴀 伀爀搀攀爀匀攀氀攀挀琀⠀椀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开倀伀匀⤀㬀ഀഀ
      ਍      椀昀 ⠀℀椀猀匀攀氀攀挀琀攀搀⤀ 笀ഀഀ
         string msg = "OrderSelect failed in resetTicket.";਍         洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg = msg + " i = " + IntegerToString(i);਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
         continue;਍      紀ഀഀ
      ਍      椀昀 ⠀开匀礀洀戀漀氀 ℀㴀 伀爀搀攀爀匀礀洀戀漀氀⠀⤀⤀ 笀ഀഀ
         continue;਍      紀ഀഀ
      ਍      椀昀 ⠀䴀愀最椀挀一甀洀戀攀爀 ℀㴀 伀爀搀攀爀䴀愀最椀挀一甀洀戀攀爀⠀⤀⤀ 笀ഀഀ
         continue;਍      紀ഀഀ
਍      椀昀 ⠀漀爀搀攀爀吀礀瀀攀 ℀㴀 伀爀搀攀爀吀礀瀀攀⠀⤀⤀ 笀ഀഀ
         continue;਍      紀ഀഀ
      ਍      漀爀搀攀爀䰀漀琀 㴀 伀爀搀攀爀䰀漀琀猀⠀⤀㬀ഀഀ
      ਍      椀昀 ⠀伀倀开䈀唀夀 㴀㴀 漀爀搀攀爀吀礀瀀攀⤀ 笀ഀഀ
         //addPositionCount = (int) (MathLog10(orderLot/curInitLotSize4Buy)/MathLog10(lotMultiple));਍         昀漀爀 ⠀椀渀琀 欀 㴀 　㬀 欀 㰀㴀 挀漀甀渀琀䄀倀䈀甀礀㬀 欀⬀⬀⤀ 笀ഀഀ
            if (isEqualDouble(arrOrdersBuy[k].openPrice, OrderOpenPrice())) {਍               愀搀搀倀漀猀椀琀椀漀渀䌀漀甀渀琀 㴀 欀㬀ഀഀ
            }਍         紀ഀഀ
         arrOrdersBuy[addPositionCount].ticketId = OrderTicket();਍         愀爀爀伀爀搀攀爀猀䈀甀礀嬀愀搀搀倀漀猀椀琀椀漀渀䌀漀甀渀琀崀⸀氀漀琀匀椀稀攀 㴀 漀爀搀攀爀䰀漀琀㬀ഀഀ
      } else if (OP_SELL == orderType) {਍         ⼀⼀愀搀搀倀漀猀椀琀椀漀渀䌀漀甀渀琀 㴀 ⠀椀渀琀⤀ ⠀䴀愀琀栀䰀漀最㄀　⠀漀爀搀攀爀䰀漀琀⼀挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀㐀匀攀氀氀⤀⼀䴀愀琀栀䰀漀最㄀　⠀氀漀琀䴀甀氀琀椀瀀氀攀⤀⤀㬀ഀഀ
         for (int k = 0; k <= countAPSell; k++) {਍            椀昀 ⠀椀猀䔀焀甀愀氀䐀漀甀戀氀攀⠀愀爀爀伀爀搀攀爀猀匀攀氀氀嬀欀崀⸀漀瀀攀渀倀爀椀挀攀Ⰰ 伀爀搀攀爀伀瀀攀渀倀爀椀挀攀⠀⤀⤀⤀ 笀ഀഀ
               addPositionCount = k;਍            紀ഀഀ
         }਍         愀爀爀伀爀搀攀爀猀匀攀氀氀嬀愀搀搀倀漀猀椀琀椀漀渀䌀漀甀渀琀崀⸀琀椀挀欀攀琀䤀搀 㴀 伀爀搀攀爀吀椀挀欀攀琀⠀⤀㬀ഀഀ
         arrOrdersSell[addPositionCount].lotSize = orderLot;਍      紀ഀഀ
਍   紀ഀഀ
}਍ഀഀ
void DecreaseLongPosition() {਍ഀഀ
   int maxShiftIndex = countAPBuy-1;਍   ഀഀ
   double preLot = 0;਍   ഀഀ
   for (int i = 0; i <= countAPBuy; i++) {਍   ഀഀ
      int ticketId = arrOrdersBuy[i].ticketId;਍      戀漀漀氀 椀猀匀攀氀攀挀琀攀搀 㴀 伀爀搀攀爀匀攀氀攀挀琀⠀琀椀挀欀攀琀䤀搀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开吀䤀䌀䬀䔀吀⤀㬀ഀഀ
      if (!isSelected) {਍         猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀匀攀氀攀挀琀 昀愀椀氀攀搀 椀渀 䐀攀挀爀攀愀猀攀䰀漀渀最倀漀猀椀琀椀漀渀⸀∀㬀ഀഀ
         msg = msg + " Error:" + ErrorDescription(GetLastError());਍         洀猀最 㴀 洀猀最 ⬀ ∀ 䈀甀礀 吀椀挀欀攀琀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀琀椀挀欀攀琀䤀搀⤀㬀ഀഀ
         Alert(msg);਍         挀漀渀琀椀渀甀攀㬀ഀഀ
      }਍ഀഀ
      double lot = OrderLots();਍      搀漀甀戀氀攀 挀氀漀猀攀䰀漀琀 㴀 氀漀琀㬀ഀഀ
਍      ⼀⼀ 帀ཧ啜౓盿ᑞ幎❧啙ࡥ珿ⵓ喕॥෿ഀ
      if (0 != i && countAPBuy != i) {਍         挀氀漀猀攀䰀漀琀 㴀 氀漀琀 ⴀ 瀀爀攀䰀漀琀㬀ഀഀ
      }਍      ഀഀ
      bool isClosed = OrderClose(OrderTicket(), closeLot, Bid, 0);਍      ഀഀ
      if (i < maxShiftIndex) {਍         愀爀爀伀爀搀攀爀猀䈀甀礀嬀椀崀 㴀 愀爀爀伀爀搀攀爀猀䈀甀礀嬀椀⬀㄀崀㬀ഀഀ
      }਍ഀഀ
      preLot = lot;਍ ഀഀ
      if (!isClosed) {਍         猀琀爀椀渀最 洀猀最 㴀 ∀䈀甀礀 伀爀搀攀爀䌀氀漀猀攀 昀愀椀氀攀搀 椀渀 䐀攀挀爀攀愀猀攀䰀漀渀最倀漀猀椀琀椀漀渀⸀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg += " OrderTicket=" + IntegerToString(OrderTicket());਍         洀猀最 ⬀㴀 ∀ 氀漀琀㴀∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀挀氀漀猀攀䰀漀琀Ⰰ ㈀⤀㬀ഀഀ
         msg += " Bid=" + DoubleToStr(Bid, Digits);਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
         continue;਍      紀ഀഀ
਍   紀ഀഀ
   ਍   挀漀甀渀琀䄀倀䈀甀礀 㴀 挀漀甀渀琀䄀倀䈀甀礀 ⴀ ㈀㬀ഀഀ
   ArrayResize(arrOrdersBuy, arraySize, countAPBuy+1);਍   ഀഀ
   resetTicket(OP_BUY);਍ഀഀ
   if (0 < countAPBuy) {਍      爀攀猀攀琀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀㬀ഀഀ
      if (addPosition2Trend) {਍         椀渀椀琀䰀漀琀匀椀稀攀㐀匀攀氀氀 㴀 挀愀氀挀甀氀愀琀攀䰀漀琀⠀椀渀椀琀䰀漀琀猀Ⰰ 䴀愀琀栀倀漀眀⠀氀漀琀䴀甀氀琀椀瀀氀攀Ⰰ 挀漀甀渀琀䄀倀䈀甀礀⤀⤀㬀ഀഀ
      }਍   紀 攀氀猀攀 椀昀 ⠀　 㴀㴀 挀漀甀渀琀䄀倀䈀甀礀⤀ 笀ഀഀ
      retraceRatioBuy = 0.0;਍      爀攀琀爀愀挀攀倀爀椀挀攀䈀甀礀 㴀 　⸀　㬀ഀഀ
      closeProfitBuy = 0.0;਍      伀戀樀攀挀琀䴀漀瘀攀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀䈀甀礀Ⰰ 　Ⰰ 　Ⰰ 　⸀　⤀㬀ഀഀ
      initLotSize4Sell = initLots;਍ഀഀ
   } else {਍      爀攀猀攀琀匀琀愀琀攀䈀甀礀⠀⤀㬀ഀഀ
      initLotSize4Sell = initLots;਍   紀ഀഀ
਍紀ഀഀ
਍瘀漀椀搀 䐀攀挀爀攀愀猀攀匀栀漀爀琀倀漀猀椀琀椀漀渀⠀⤀ 笀ഀഀ
਍   椀渀琀 洀愀砀匀栀椀昀琀䤀渀搀攀砀 㴀 挀漀甀渀琀䄀倀匀攀氀氀ⴀ㄀㬀ഀഀ
਍   搀漀甀戀氀攀 瀀爀攀䰀漀琀 㴀 　㬀ഀഀ
   ਍   昀漀爀 ⠀椀渀琀 椀 㴀 　㬀 椀 㰀㴀 挀漀甀渀琀䄀倀匀攀氀氀㬀 椀⬀⬀⤀ 笀ഀഀ
   ਍      椀渀琀 琀椀挀欀攀琀䤀搀 㴀 愀爀爀伀爀搀攀爀猀匀攀氀氀嬀椀崀⸀琀椀挀欀攀琀䤀搀㬀ഀഀ
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);਍      椀昀 ⠀℀椀猀匀攀氀攀挀琀攀搀⤀ 笀ഀഀ
         string msg = "OrderSelect failed in DecreaseShortPosition.";਍         洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
         continue;਍      紀ഀഀ
      ਍      搀漀甀戀氀攀 氀漀琀 㴀 伀爀搀攀爀䰀漀琀猀⠀⤀㬀ഀഀ
      double closeLot = lot;਍      ഀഀ
      // 非最小单，并且非最大单时（即中间单时）਍      椀昀 ⠀　 ℀㴀 椀 ☀☀ 挀漀甀渀琀䄀倀匀攀氀氀 ℀㴀 椀⤀ 笀ഀഀ
         closeLot = lot - preLot;਍      紀ഀഀ
      ਍      戀漀漀氀 椀猀䌀氀漀猀攀搀 㴀 伀爀搀攀爀䌀氀漀猀攀⠀伀爀搀攀爀吀椀挀欀攀琀⠀⤀Ⰰ 挀氀漀猀攀䰀漀琀Ⰰ 䄀猀欀Ⰰ 　⤀㬀ഀഀ
      ਍      椀昀 ⠀椀 㰀 洀愀砀匀栀椀昀琀䤀渀搀攀砀⤀ 笀ഀഀ
         arrOrdersSell[i] = arrOrdersSell[i+1];਍      紀ഀഀ
਍      瀀爀攀䰀漀琀 㴀 氀漀琀㬀ഀഀ
਍      椀昀 ⠀℀椀猀䌀氀漀猀攀搀⤀ 笀ഀഀ
         string msg = "Sell OrderClose failed in DecreaseShortPosition. Error:" + ErrorDescription(GetLastError());਍         洀猀最 ⬀㴀 ∀ 伀爀搀攀爀吀椀挀欀攀琀㴀∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀伀爀搀攀爀吀椀挀欀攀琀⠀⤀⤀㬀ഀഀ
         msg += " lot=" + DoubleToStr(closeLot, 2);਍         洀猀最 ⬀㴀 ∀ 䄀猀欀㴀∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀䄀猀欀Ⰰ 䐀椀最椀琀猀⤀㬀ഀഀ
         Alert(msg);਍         挀漀渀琀椀渀甀攀㬀ഀഀ
      }਍ഀഀ
   }਍   ഀഀ
   countAPSell = countAPSell - 2;਍   䄀爀爀愀礀刀攀猀椀稀攀⠀愀爀爀伀爀搀攀爀猀匀攀氀氀Ⰰ 愀爀爀愀礀匀椀稀攀Ⰰ 挀漀甀渀琀䄀倀匀攀氀氀⬀㄀⤀㬀ഀഀ
   ਍   爀攀猀攀琀吀椀挀欀攀琀⠀伀倀开匀䔀䰀䰀⤀㬀ഀഀ
਍   椀昀 ⠀　 㰀 挀漀甀渀琀䄀倀匀攀氀氀⤀ 笀ഀഀ
      resetRetrace4Sell();਍      椀昀 ⠀愀搀搀倀漀猀椀琀椀漀渀㈀吀爀攀渀搀⤀ 笀ഀഀ
         initLotSize4Buy = calculateLot(initLots, MathPow(lotMultiple, countAPSell));਍      紀ഀഀ
   } else if (0 == countAPSell) {਍      爀攀琀爀愀挀攀刀愀琀椀漀匀攀氀氀 㴀 　⸀　㬀ഀഀ
      retracePriceSell = 0.0;਍      挀氀漀猀攀倀爀漀昀椀琀匀攀氀氀 㴀 　⸀　㬀ഀഀ
      ObjectMove(nmLineClosePositionSell, 0, 0, 0.0);਍      椀渀椀琀䰀漀琀匀椀稀攀㐀䈀甀礀 㴀 椀渀椀琀䰀漀琀猀㬀ഀഀ
      ਍   紀 攀氀猀攀 笀ഀഀ
      resetStateSell();਍      椀渀椀琀䰀漀琀匀椀稀攀㐀䈀甀礀 㴀 椀渀椀琀䰀漀琀猀㬀ഀഀ
   }਍ഀഀ
}਍ഀഀ
bool doRetrace4Buy() {਍ഀഀ
   if (countAPBuy < 1) {਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍ഀഀ
   RefreshRates();਍   椀昀 ⠀爀攀琀爀愀挀攀倀爀椀挀攀䈀甀礀 㰀㴀 䈀椀搀⤀ 笀ഀഀ
      if (Fixed == addPositionMode || isCloseAllMode(OP_BUY)) {਍         䌀氀漀猀攀䄀氀氀䈀甀礀⠀⤀㬀ഀഀ
         resetStateBuy();਍         爀攀琀甀爀渀 琀爀甀攀㬀ഀഀ
      } else if ( isClosePartMode(OP_BUY) ) {਍         䐀攀挀爀攀愀猀攀䰀漀渀最倀漀猀椀琀椀漀渀⠀⤀㬀ഀഀ
         return true;਍      紀ഀഀ
਍   紀ഀഀ
   ਍   爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
}਍ഀഀ
bool doRetrace4Sell() {਍ഀഀ
   if (countAPSell < 1) {਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍   ഀഀ
   RefreshRates();਍   椀昀 ⠀䄀猀欀 㰀㴀 爀攀琀爀愀挀攀倀爀椀挀攀匀攀氀氀⤀ 笀ഀഀ
      if (Fixed == addPositionMode || isCloseAllMode(OP_SELL)) {਍         䌀氀漀猀攀䄀氀氀匀攀氀氀⠀⤀㬀ഀഀ
         resetStateSell();਍         爀攀琀甀爀渀 琀爀甀攀㬀ഀഀ
      } else if ( isClosePartMode(OP_SELL) ) {਍         䐀攀挀爀攀愀猀攀匀栀漀爀琀倀漀猀椀琀椀漀渀⠀⤀㬀ഀഀ
         return true;਍      紀ഀഀ
   }਍   ഀഀ
   return false;਍紀ഀഀ
਍戀漀漀氀 琀愀欀攀倀爀漀昀椀琀㐀䈀甀礀⠀⤀ 笀ഀഀ
   if (0 != countAPBuy) {਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍   ഀഀ
   int ticketId = arrOrdersBuy[0].ticketId;਍   ഀഀ
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);਍   ഀഀ
   if (!isSelected) {਍      猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀匀攀氀攀挀琀 昀愀椀氀攀搀 椀渀 琀愀欀攀倀爀漀昀椀琀㐀䈀甀礀⸀∀㬀ഀഀ
      msg = msg + " Error:" + ErrorDescription(GetLastError());਍      洀猀最 㴀 洀猀最 ⬀ ∀ 䈀甀礀 吀椀挀欀攀琀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀琀椀挀欀攀琀䤀搀⤀㬀ഀഀ
      Alert(msg);਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍   ഀഀ
   double tpPrice = OrderOpenPrice() + tp;਍   刀攀昀爀攀猀栀刀愀琀攀猀⠀⤀㬀ഀഀ
   // 止赢时਍   椀昀 ⠀琀瀀倀爀椀挀攀 㰀㴀 䈀椀搀⤀ 笀ഀഀ
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), Bid, 0);਍ഀഀ
      if (!isClosed) {਍         猀琀爀椀渀最 洀猀最 㴀 ∀䈀甀礀 伀爀搀攀爀䌀氀漀猀攀 昀愀椀氀攀搀 椀渀 琀愀欀攀倀爀漀昀椀琀㐀䈀甀礀⸀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg += " OrderTicket=" + IntegerToString(OrderTicket());਍         洀猀最 ⬀㴀 ∀ 氀漀琀匀椀稀攀㴀∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀伀爀搀攀爀䰀漀琀猀⠀⤀Ⰰ ㈀⤀㬀ഀഀ
         msg += " Bid=" + DoubleToStr(Bid, Digits);਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
         return false;਍      紀ഀഀ
      countAPBuy--;਍      䄀爀爀愀礀刀攀猀椀稀攀⠀愀爀爀伀爀搀攀爀猀䈀甀礀Ⰰ 愀爀爀愀礀匀椀稀攀⤀㬀ഀഀ
      ਍      爀攀琀甀爀渀 琀爀甀攀㬀ഀഀ
   }਍ഀഀ
   return false;਍紀ഀഀ
਍戀漀漀氀 琀愀欀攀倀爀漀昀椀琀㐀匀攀氀氀⠀⤀ 笀ഀഀ
   if (0 != countAPSell) {਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍   ഀഀ
   int ticketId = arrOrdersSell[0].ticketId;਍   ഀഀ
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);਍   ഀഀ
   if (!isSelected) {਍      猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀匀攀氀攀挀琀 昀愀椀氀攀搀 椀渀 琀愀欀攀倀爀漀昀椀琀㐀匀攀氀氀⸀∀㬀ഀഀ
      msg = msg + " Error:" + ErrorDescription(GetLastError());਍      洀猀最 㴀 洀猀最 ⬀ ∀ 匀攀氀氀 吀椀挀欀攀琀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀琀椀挀欀攀琀䤀搀⤀㬀ഀഀ
      Alert(msg);਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍   ഀഀ
   double tpPrice = OrderOpenPrice() - tp;਍   刀攀昀爀攀猀栀刀愀琀攀猀⠀⤀㬀ഀഀ
   // 止赢时਍   椀昀 ⠀䄀猀欀 㰀㴀 琀瀀倀爀椀挀攀⤀ 笀ഀഀ
      bool isClosed = OrderClose(OrderTicket(), OrderLots(), Ask, 0);਍ഀഀ
      if (!isClosed) {਍         猀琀爀椀渀最 洀猀最 㴀 ∀匀攀氀氀 伀爀搀攀爀䌀氀漀猀攀 昀愀椀氀攀搀 椀渀 琀愀欀攀倀爀漀昀椀琀㐀匀攀氀氀⸀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg += " OrderTicket=" + IntegerToString(OrderTicket());਍         洀猀最 ⬀㴀 ∀ 氀漀琀匀椀稀攀㴀∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀伀爀搀攀爀䰀漀琀猀⠀⤀Ⰰ ㈀⤀㬀ഀഀ
         msg += " Ask=" + DoubleToStr(Ask, Digits);਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
         return false;਍      紀ഀഀ
      countAPSell--;਍      䄀爀爀愀礀刀攀猀椀稀攀⠀愀爀爀伀爀搀攀爀猀匀攀氀氀Ⰰ 愀爀爀愀礀匀椀稀攀⤀㬀ഀഀ
      ਍      爀攀琀甀爀渀 琀爀甀攀㬀ഀഀ
   }਍ഀഀ
   return false;਍紀ഀഀ
਍瘀漀椀搀 挀栀攀挀欀䈀甀礀伀爀搀攀爀⠀⤀ 笀ഀഀ
਍   椀昀 ⠀琀愀欀攀倀爀漀昀椀琀㐀䈀甀礀⠀⤀⤀ 笀ഀഀ
      return;਍   紀ഀഀ
   ਍   椀昀 ⠀搀漀刀攀琀爀愀挀攀㐀䈀甀礀⠀⤀⤀ 笀ഀഀ
      return;਍   紀ഀഀ
   ਍   愀搀搀倀漀猀椀琀椀漀渀㐀䈀甀礀⠀⤀㬀ഀഀ
}਍ഀഀ
void checkSellOrder() {਍   椀昀 ⠀琀愀欀攀倀爀漀昀椀琀㐀匀攀氀氀⠀⤀⤀ 笀ഀഀ
      return;਍   紀ഀഀ
   ਍   椀昀 ⠀搀漀刀攀琀爀愀挀攀㐀匀攀氀氀⠀⤀⤀ 笀ഀഀ
      return;਍   紀ഀഀ
   ਍   愀搀搀倀漀猀椀琀椀漀渀㐀匀攀氀氀⠀⤀㬀ഀഀ
}਍ഀഀ
void resetState() {਍   爀攀猀攀琀匀琀愀琀攀䈀甀礀⠀⤀㬀ഀഀ
   resetStateSell();਍紀ഀഀ
਍瘀漀椀搀 伀渀吀椀挀欀⠀⤀ 笀ഀഀ
਍   椀昀 ⠀攀渀愀戀氀攀唀猀攀䰀椀洀椀琀⤀ 笀ഀഀ
      datetime now = TimeGMT();਍      椀昀 ⠀攀砀瀀椀爀攀吀椀洀攀 㰀 渀漀眀⤀ 笀ഀഀ
         Alert("使用过期，请联系作者。邮箱：soko8@sina.com  或者QQ:183947281");਍         爀攀琀甀爀渀㬀ഀഀ
      }਍   紀ഀഀ
਍   挀愀氀挀甀氀愀琀攀倀爀漀昀椀琀⠀⤀㬀ഀഀ
   ਍   椀昀 ⠀℀椀猀䄀挀琀椀瘀攀⤀ 笀ഀഀ
   ਍      椀昀 ⠀℀椀猀匀琀漀瀀攀搀䈀礀一攀眀猀⤀ 笀ഀഀ
         return;਍      紀ഀഀ
਍      搀愀琀攀琀椀洀攀 渀漀眀吀椀洀攀 㴀 吀椀洀攀䰀漀挀愀氀⠀⤀㬀ഀഀ
      int diffTime = (int) (nowTime - stopedTimeByNews);਍      椀昀 ⠀洀椀渀甀琀攀猀䄀昀琀攀爀一攀眀猀刀攀猀甀洀攀⨀㘀　 㰀 搀椀昀昀吀椀洀攀⤀ 笀ഀഀ
         opPanel.resumeEA();਍      紀 攀氀猀攀 笀ഀഀ
         return;਍      紀ഀഀ
   }਍   ഀഀ
   updateNewsStatus();਍   ഀഀ
   if (mustStopEAByNews) {਍      ഀഀ
      closeAll();਍      爀攀猀攀琀匀琀愀琀攀⠀⤀㬀ഀഀ
਍      漀瀀倀愀渀攀氀⸀猀琀漀瀀䔀䄀⠀⤀㬀ഀഀ
      ਍      椀猀匀琀漀瀀攀搀䈀礀一攀眀猀 㴀 琀爀甀攀㬀ഀഀ
      stopedTimeByNews = TimeLocal();਍      ഀഀ
      return;਍   紀ഀഀ
਍   挀栀攀挀欀䈀甀礀伀爀搀攀爀⠀⤀㬀ഀഀ
   checkSellOrder();਍   ഀഀ
   if (isNewBegin(OP_BUY)) {਍      椀昀 ⠀℀昀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀 ☀☀ ℀椀猀䘀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀䴀愀渀甀愀氀⤀ 笀ഀഀ
         curInitLotSize4Buy = calculateInitLot(OP_BUY);਍         挀爀攀愀琀攀伀爀搀攀爀䈀甀礀⠀挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀㐀䈀甀礀⤀㬀ഀഀ
         opPanel.setCloseBuyButton(Close_Order_Mode);਍      紀ഀഀ
   }਍   ഀഀ
   if (isNewBegin(OP_SELL)) {਍      椀昀 ⠀℀昀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀 ☀☀ ℀椀猀䘀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀䴀愀渀甀愀氀⤀ 笀ഀഀ
         curInitLotSize4Sell = calculateInitLot(OP_SELL);਍         挀爀攀愀琀攀伀爀搀攀爀匀攀氀氀⠀挀甀爀䤀渀椀琀䰀漀琀匀椀稀攀㐀匀攀氀氀⤀㬀ഀഀ
         opPanel.setCloseSellButton(Close_Order_Mode);਍      紀ഀഀ
   }਍   ഀഀ
   calculateProfit();਍   匀攀琀䌀漀洀洀攀渀琀猀⠀⤀㬀ഀഀ
}਍ഀഀ
void CloseAllBuy() {਍ഀഀ
   for (int i = OrdersTotal()-1; 0 <= i; i--) {਍      ഀഀ
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);਍      ഀഀ
      if (!isSuccess) {਍         猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀 匀攀氀攀挀琀 昀愀椀氀攀搀 椀渀 䌀氀漀猀攀䄀氀氀䈀甀礀⸀∀㬀ഀഀ
         msg = msg + " Error:" + ErrorDescription(GetLastError());਍         洀猀最 㴀 洀猀最 ⬀ ∀ 椀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀椀⤀㬀ഀഀ
         Alert(msg);਍         挀漀渀琀椀渀甀攀㬀ഀഀ
      }਍      ഀഀ
      if (_Symbol != OrderSymbol()) {਍         挀漀渀琀椀渀甀攀㬀ഀഀ
      }਍      ഀഀ
      if (MagicNumber != OrderMagicNumber()) {਍         挀漀渀琀椀渀甀攀㬀ഀഀ
      }਍      ഀഀ
      if (OP_BUY != OrderType()) {਍         挀漀渀琀椀渀甀攀㬀ഀഀ
      }਍ഀഀ
      isSuccess = OrderClose(OrderTicket(), OrderLots(), Bid, 0);਍      ഀഀ
      if (!isSuccess) {਍         猀琀爀椀渀最 洀猀最 㴀 ∀䈀甀礀 伀爀搀攀爀 䌀氀漀猀攀 昀愀椀氀攀搀 椀渀 䌀氀漀猀攀䄀氀氀䈀甀礀⸀∀㬀ഀഀ
         msg = msg + " Error:" + ErrorDescription(GetLastError());਍         洀猀最 㴀 洀猀最 ⬀ ∀ 伀爀搀攀爀吀椀挀欀攀琀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀伀爀搀攀爀吀椀挀欀攀琀⠀⤀⤀㬀ഀഀ
         Alert(msg);਍      紀ഀഀ
਍   紀ഀഀ
਍紀ഀഀ
਍瘀漀椀搀 䌀氀漀猀攀䄀氀氀匀攀氀氀⠀⤀ 笀ഀഀ
਍   昀漀爀 ⠀椀渀琀 椀 㴀 伀爀搀攀爀猀吀漀琀愀氀⠀⤀ⴀ㄀㬀 　 㰀㴀 椀㬀 椀ⴀⴀ⤀ 笀ഀഀ
      ਍      戀漀漀氀 椀猀匀甀挀挀攀猀猀 㴀 伀爀搀攀爀匀攀氀攀挀琀⠀椀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开倀伀匀⤀㬀ഀഀ
      ਍      椀昀 ⠀℀椀猀匀甀挀挀攀猀猀⤀ 笀ഀഀ
         string msg = "Order Select failed in CloseAllSell.";਍         洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg = msg + " i = " + IntegerToString(i);਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
         continue;਍      紀ഀഀ
      ਍      椀昀 ⠀开匀礀洀戀漀氀 ℀㴀 伀爀搀攀爀匀礀洀戀漀氀⠀⤀⤀ 笀ഀഀ
         continue;਍      紀ഀഀ
      ਍      椀昀 ⠀䴀愀最椀挀一甀洀戀攀爀 ℀㴀 伀爀搀攀爀䴀愀最椀挀一甀洀戀攀爀⠀⤀⤀ 笀ഀഀ
         continue;਍      紀ഀഀ
      ਍      椀昀 ⠀伀倀开匀䔀䰀䰀 ℀㴀 伀爀搀攀爀吀礀瀀攀⠀⤀⤀ 笀ഀഀ
         continue;਍      紀ഀഀ
਍      椀猀匀甀挀挀攀猀猀 㴀 伀爀搀攀爀䌀氀漀猀攀⠀伀爀搀攀爀吀椀挀欀攀琀⠀⤀Ⰰ 伀爀搀攀爀䰀漀琀猀⠀⤀Ⰰ 䄀猀欀Ⰰ 　⤀㬀ഀഀ
      ਍      椀昀 ⠀℀椀猀匀甀挀挀攀猀猀⤀ 笀ഀഀ
         string msg = "Sell Order Close failed in CloseAllSell.";਍         洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
      }਍ഀഀ
   }਍ഀഀ
}਍ഀഀ
਍瘀漀椀搀 䌀氀漀猀攀伀爀䐀攀氀攀琀攀伀爀搀攀爀⠀⤀ 笀ഀഀ
   ਍   椀昀 ⠀开匀礀洀戀漀氀 ℀㴀 伀爀搀攀爀匀礀洀戀漀氀⠀⤀⤀ 笀ഀഀ
      return;਍   紀ഀഀ
   ਍   椀昀 ⠀䴀愀最椀挀一甀洀戀攀爀 ℀㴀 伀爀搀攀爀䴀愀最椀挀一甀洀戀攀爀⠀⤀⤀ 笀ഀഀ
      return;਍   紀ഀഀ
਍   戀漀漀氀 椀猀匀甀挀挀攀猀猀 㴀 琀爀甀攀㬀ഀഀ
   string kbn = "";਍   猀眀椀琀挀栀⠀伀爀搀攀爀吀礀瀀攀⠀⤀⤀ 笀ഀഀ
      case OP_BUY:਍         欀戀渀 㴀 ∀䈀甀礀∀㬀ഀഀ
         isSuccess = OrderClose(OrderTicket(), OrderLots(), Bid, 0);਍         戀爀攀愀欀㬀ഀഀ
      case OP_SELL:਍         欀戀渀 㴀 ∀匀攀氀氀∀㬀ഀഀ
         isSuccess = OrderClose(OrderTicket(), OrderLots(), Ask, 0);਍         戀爀攀愀欀㬀ഀഀ
      case OP_BUYSTOP:਍      挀愀猀攀 伀倀开䈀唀夀䰀䤀䴀䤀吀㨀ഀഀ
      case OP_SELLSTOP:਍      挀愀猀攀 伀倀开匀䔀䰀䰀䰀䤀䴀䤀吀㨀ഀഀ
         kbn = "Pending";਍         椀猀匀甀挀挀攀猀猀 㴀 伀爀搀攀爀䐀攀氀攀琀攀⠀伀爀搀攀爀吀椀挀欀攀琀⠀⤀⤀㬀ഀഀ
         break;਍   紀ഀഀ
਍   椀昀 ⠀℀椀猀匀甀挀挀攀猀猀⤀ 笀ഀഀ
      string msg = kbn + " Order Close failed.";਍      洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
      msg = msg + " OrderTicket = " + IntegerToString(OrderTicket());਍      䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
   }਍ഀഀ
}਍ഀഀ
void closeAll() {਍ഀഀ
   for (int i = OrdersTotal()-1; 0 <= i; i--) {਍      ഀഀ
      bool isSuccess = OrderSelect(i, SELECT_BY_POS);਍      ഀഀ
      if (!isSuccess) {਍         猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀 匀攀氀攀挀琀 昀愀椀氀攀搀⸀∀㬀ഀഀ
         msg = msg + " Error:" + ErrorDescription(GetLastError());਍         洀猀最 㴀 洀猀最 ⬀ ∀ 椀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀椀⤀㬀ഀഀ
         Alert(msg);਍         挀漀渀琀椀渀甀攀㬀ഀഀ
      }਍      ഀഀ
      CloseOrDeleteOrder();਍ഀഀ
   }਍ഀഀ
}਍ഀഀ
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) { ਍ഀഀ
   if (id == CHARTEVENT_OBJECT_DRAG) {਍      猀琀爀椀渀最 漀戀樀攀挀琀一愀洀攀 㴀 猀瀀愀爀愀洀㬀ഀഀ
      if (nmLineClosePositionBuy == objectName) {਍         爀攀琀爀愀挀攀倀爀椀挀攀䈀甀礀 㴀 伀戀樀攀挀琀䜀攀琀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀䈀甀礀Ⰰ 伀䈀䨀倀刀伀倀开倀刀䤀䌀䔀㄀⤀㬀ഀഀ
         double minOpenPrice = arrOrdersBuy[countAPBuy].openPrice;਍         爀攀琀爀愀挀攀刀愀琀椀漀䈀甀礀 㴀 ⠀爀攀琀爀愀挀攀倀爀椀挀攀䈀甀礀ⴀ洀椀渀伀瀀攀渀倀爀椀挀攀⤀⼀倀漀椀渀琀⼀最爀椀搀㬀ഀഀ
         calculateCloseProfit4Buy();਍         匀攀琀䌀漀洀洀攀渀琀猀⠀⤀㬀ഀഀ
      } else if (nmLineClosePositionSell == objectName) {਍         爀攀琀爀愀挀攀倀爀椀挀攀匀攀氀氀 㴀 伀戀樀攀挀琀䜀攀琀⠀渀洀䰀椀渀攀䌀氀漀猀攀倀漀猀椀琀椀漀渀匀攀氀氀Ⰰ 伀䈀䨀倀刀伀倀开倀刀䤀䌀䔀㄀⤀㬀ഀഀ
         double maxOpenPrice = arrOrdersSell[countAPSell].openPrice;਍         爀攀琀爀愀挀攀刀愀琀椀漀匀攀氀氀 㴀 ⠀洀愀砀伀瀀攀渀倀爀椀挀攀ⴀ爀攀琀爀愀挀攀倀爀椀挀攀匀攀氀氀⤀⼀倀漀椀渀琀⼀最爀椀搀㬀ഀഀ
         calculateCloseProfit4Sell();਍         匀攀琀䌀漀洀洀攀渀琀猀⠀⤀㬀ഀഀ
      }਍   紀ഀഀ
   ਍   漀瀀倀愀渀攀氀⸀䌀栀愀爀琀䔀瘀攀渀琀⠀椀搀Ⰰ氀瀀愀爀愀洀Ⰰ搀瀀愀爀愀洀Ⰰ猀瀀愀爀愀洀⤀㬀ഀഀ
}਍ഀഀ
void calculateCloseProfit4Buy() {਍   ഀഀ
   closeProfitBuy = 0.0;਍ഀഀ
   if (retracePriceBuy <= 0.0) {਍      爀攀琀甀爀渀㬀ഀഀ
   }਍   ഀഀ
   for (int i = 0; i <= countAPBuy; i++) {਍      椀昀 ⠀ 伀爀搀攀爀匀攀氀攀挀琀⠀愀爀爀伀爀搀攀爀猀䈀甀礀嬀椀崀⸀琀椀挀欀攀琀䤀搀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开吀䤀䌀䬀䔀吀⤀ ⤀ 笀ഀഀ
਍         搀漀甀戀氀攀 搀椀昀昀倀爀椀挀攀 㴀 爀攀琀爀愀挀攀倀爀椀挀攀䈀甀礀 ⴀ 伀爀搀攀爀伀瀀攀渀倀爀椀挀攀⠀⤀㬀ഀഀ
         double profiti = OrderLots()*diffPrice/Point;਍         挀氀漀猀攀倀爀漀昀椀琀䈀甀礀 ⬀㴀 瀀爀漀昀椀琀椀㬀ഀഀ
         if ( isClosePartMode(OP_BUY) ) {਍            椀昀 ⠀挀漀甀渀琀䄀倀䈀甀礀 ℀㴀 椀 ☀☀ 　 ℀㴀 椀⤀ 笀ഀഀ
               closeProfitBuy -= profiti/lotMultiple;਍            紀ഀഀ
         }਍         挀氀漀猀攀倀爀漀昀椀琀䈀甀礀 ⬀㴀 伀爀搀攀爀䌀漀洀洀椀猀猀椀漀渀⠀⤀㬀ഀഀ
         closeProfitBuy += OrderSwap(); ਍ഀഀ
      }਍   紀ഀഀ
   ਍紀ഀഀ
਍瘀漀椀搀 挀愀氀挀甀氀愀琀攀䌀氀漀猀攀倀爀漀昀椀琀㐀匀攀氀氀⠀⤀ 笀ഀഀ
   ਍   挀氀漀猀攀倀爀漀昀椀琀匀攀氀氀 㴀 　⸀　㬀ഀഀ
਍   椀昀 ⠀爀攀琀爀愀挀攀倀爀椀挀攀匀攀氀氀 㰀㴀 　⸀　⤀ 笀ഀഀ
      return;਍   紀ഀഀ
   ਍   昀漀爀 ⠀椀渀琀 椀 㴀 　㬀 椀 㰀㴀 挀漀甀渀琀䄀倀匀攀氀氀㬀 椀⬀⬀⤀ 笀ഀഀ
      if ( OrderSelect(arrOrdersSell[i].ticketId, SELECT_BY_TICKET) ) {਍ഀഀ
         double diffPrice = OrderOpenPrice() - retracePriceSell;਍         搀漀甀戀氀攀 瀀爀漀昀椀琀椀 㴀 伀爀搀攀爀䰀漀琀猀⠀⤀⨀搀椀昀昀倀爀椀挀攀⼀倀漀椀渀琀㬀ഀഀ
         closeProfitSell += profiti;਍         椀昀 ⠀ 椀猀䌀氀漀猀攀倀愀爀琀䴀漀搀攀⠀伀倀开匀䔀䰀䰀⤀ ⤀ 笀ഀഀ
            if (countAPSell != i && 0 != i) {਍               挀氀漀猀攀倀爀漀昀椀琀匀攀氀氀 ⴀ㴀 瀀爀漀昀椀琀椀⼀氀漀琀䴀甀氀琀椀瀀氀攀㬀ഀഀ
            }਍         紀ഀഀ
         closeProfitSell += OrderCommission();਍         挀氀漀猀攀倀爀漀昀椀琀匀攀氀氀 ⬀㴀 伀爀搀攀爀匀眀愀瀀⠀⤀㬀ഀഀ
਍      紀ഀഀ
   }਍   ഀഀ
}਍ഀഀ
void calculateProfit() {਍ഀഀ
   double profitLong = 0.0;਍   搀漀甀戀氀攀 瀀爀漀昀椀琀匀栀漀爀琀 㴀 　⸀　㬀ഀഀ
   ਍   搀漀甀戀氀攀 瀀爀漀昀椀琀䐀倀䰀漀渀最 㴀 　⸀　㬀ഀഀ
   double tmpOneProfit = 0.0;਍   昀漀爀 ⠀椀渀琀 椀 㴀 　㬀 椀 㰀㴀 挀漀甀渀琀䄀倀䈀甀礀㬀 椀⬀⬀⤀ 笀ഀഀ
਍      椀渀琀 琀椀挀欀攀琀䤀搀 㴀 愀爀爀伀爀搀攀爀猀䈀甀礀嬀椀崀⸀琀椀挀欀攀琀䤀搀㬀ഀഀ
      bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);਍   ഀഀ
      if (isSelected) {਍         琀洀瀀伀渀攀倀爀漀昀椀琀 㴀 伀爀搀攀爀倀爀漀昀椀琀⠀⤀㬀ഀഀ
         tmpOneProfit += OrderCommission();਍         琀洀瀀伀渀攀倀爀漀昀椀琀 ⬀㴀 伀爀搀攀爀匀眀愀瀀⠀⤀㬀ഀഀ
         ਍         瀀爀漀昀椀琀䰀漀渀最 ⬀㴀 琀洀瀀伀渀攀倀爀漀昀椀琀㬀ഀഀ
         profitDPLong += tmpOneProfit;਍         ഀഀ
         if (0 != i && countAPBuy != i) {਍            搀漀甀戀氀攀 洀椀渀甀猀倀爀漀昀椀琀 㴀 伀爀搀攀爀倀爀漀昀椀琀⠀⤀⨀⠀㄀ⴀ爀攀搀甀挀攀䘀愀挀琀漀爀⤀㬀ഀഀ
            profitDPLong -= minusProfit;਍         紀ഀഀ
      } else {਍         猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀匀攀氀攀挀琀 昀愀椀氀攀搀 椀渀 挀愀氀挀甀氀愀琀攀倀爀漀昀椀琀⸀∀㬀ഀഀ
         msg = msg + " Error:" + ErrorDescription(GetLastError());਍         洀猀最 㴀 洀猀最 ⬀ ∀ 䈀甀礀 吀椀挀欀攀琀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀琀椀挀欀攀琀䤀搀⤀㬀ഀഀ
         Alert(msg);਍      紀ഀഀ
਍   紀ഀഀ
   ਍   搀漀甀戀氀攀 瀀爀漀昀椀琀䐀倀匀栀漀爀琀 㴀 　⸀　㬀ഀഀ
   for (int i = 0; i <= countAPSell; i++) {਍ഀഀ
      int ticketId = arrOrdersSell[i].ticketId;਍      戀漀漀氀 椀猀匀攀氀攀挀琀攀搀 㴀 伀爀搀攀爀匀攀氀攀挀琀⠀琀椀挀欀攀琀䤀搀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开吀䤀䌀䬀䔀吀⤀㬀ഀഀ
   ਍      椀昀 ⠀椀猀匀攀氀攀挀琀攀搀⤀ 笀ഀഀ
         tmpOneProfit = OrderProfit();਍         琀洀瀀伀渀攀倀爀漀昀椀琀 ⬀㴀 伀爀搀攀爀䌀漀洀洀椀猀猀椀漀渀⠀⤀㬀ഀഀ
         tmpOneProfit += OrderSwap();਍         ഀഀ
         profitShort += tmpOneProfit;਍         瀀爀漀昀椀琀䐀倀匀栀漀爀琀 ⬀㴀 琀洀瀀伀渀攀倀爀漀昀椀琀㬀ഀഀ
         ਍         椀昀 ⠀　 ℀㴀 椀 ☀☀ 挀漀甀渀琀䄀倀匀攀氀氀 ℀㴀 椀⤀ 笀ഀഀ
            double minusProfit = OrderProfit()*(1-reduceFactor);਍            瀀爀漀昀椀琀䐀倀匀栀漀爀琀 ⴀ㴀 洀椀渀甀猀倀爀漀昀椀琀㬀ഀഀ
         }਍      紀 攀氀猀攀 笀ഀഀ
         string msg = "OrderSelect failed in calculateProfit.";਍         洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
         msg = msg + " Sell Ticket = " + IntegerToString(ticketId);਍         䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
      }਍ഀഀ
   }਍   ഀഀ
   opPanel.refreshProfitCloseLong(profitLong);਍   漀瀀倀愀渀攀氀⸀爀攀昀爀攀猀栀倀爀漀昀椀琀䌀氀漀猀攀匀栀漀爀琀⠀瀀爀漀昀椀琀匀栀漀爀琀⤀㬀ഀഀ
   ਍   搀漀甀戀氀攀 琀漀琀愀氀 㴀 瀀爀漀昀椀琀䰀漀渀最 ⬀ 瀀爀漀昀椀琀匀栀漀爀琀㬀ഀഀ
   opPanel.refreshTotalProfit(total);਍   ഀഀ
   opPanel.refreshProfitDecreaseLong(profitDPLong);਍   漀瀀倀愀渀攀氀⸀爀攀昀爀攀猀栀倀爀漀昀椀琀䐀攀挀爀攀愀猀攀匀栀漀爀琀⠀瀀爀漀昀椀琀䐀倀匀栀漀爀琀⤀㬀ഀഀ
   ਍   搀漀甀戀氀攀 洀愀砀䄀倀䰀漀渀最倀爀漀昀椀琀 㴀 　⸀　㬀ഀഀ
   if (0 <= countAPBuy) {਍      戀漀漀氀 椀猀匀攀氀攀挀琀攀搀 㴀 伀爀搀攀爀匀攀氀攀挀琀⠀愀爀爀伀爀搀攀爀猀䈀甀礀嬀挀漀甀渀琀䄀倀䈀甀礀崀⸀琀椀挀欀攀琀䤀搀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开吀䤀䌀䬀䔀吀⤀㬀ഀഀ
      if (isSelected) {਍         洀愀砀䄀倀䰀漀渀最倀爀漀昀椀琀 㴀 伀爀搀攀爀倀爀漀昀椀琀⠀⤀⬀伀爀搀攀爀䌀漀洀洀椀猀猀椀漀渀⠀⤀⬀伀爀搀攀爀匀眀愀瀀⠀⤀㬀ഀഀ
      }਍   紀ഀഀ
   opPanel.refreshProfitCloseMaxOrderLong(maxAPLongProfit);਍   ഀഀ
   double maxAPShortProfit = 0.0;਍   椀昀 ⠀　 㰀㴀 挀漀甀渀琀䄀倀匀攀氀氀⤀ 笀ഀഀ
      bool isSelected = OrderSelect(arrOrdersSell[countAPSell].ticketId, SELECT_BY_TICKET);਍      椀昀 ⠀椀猀匀攀氀攀挀琀攀搀⤀ 笀ഀഀ
         maxAPShortProfit = OrderProfit()+OrderCommission()+OrderSwap();਍      紀ഀഀ
   }਍   漀瀀倀愀渀攀氀⸀爀攀昀爀攀猀栀倀爀漀昀椀琀䌀氀漀猀攀䴀愀砀伀爀搀攀爀匀栀漀爀琀⠀洀愀砀䄀倀匀栀漀爀琀倀爀漀昀椀琀⤀㬀ഀഀ
}਍ഀഀ
਍⼀⨀ഀഀ
       3M+NS-S਍  堀 㴀 ⴀⴀⴀⴀⴀⴀⴀⴀⴀ一ഀഀ
       3NS+6M਍       ഀഀ
  M:初始手数਍  匀㨀ꀀ퍒䭎灢൥ഀ
  N:第几次加仓਍⨀⼀ഀഀ
਍搀漀甀戀氀攀 挀愀氀挀甀氀愀琀攀刀攀琀爀愀挀攀㐀䘀椀砀攀搀⠀椀渀琀 一Ⰰ 搀漀甀戀氀攀 氀漀琀䤀渀椀琀⤀ 笀ഀഀ
   ਍   搀漀甀戀氀攀 䴀 㴀 氀漀琀䤀渀椀琀⼀椀渀椀琀䰀漀琀猀㬀ഀഀ
   double S = lotStep/initLots;਍   搀漀甀戀氀攀 爀攀琀 㴀 ⠀䴀⨀㌀⬀匀⨀一ⴀ匀⤀⨀一⼀⠀匀⨀一⨀㌀⬀䴀⨀㘀⤀㬀ഀഀ
   return ret;਍紀ഀഀ
਍⼀⨀⨀⨀ ⡎愀ⴀ㄀⤀⼀愀 ഀﭐ灼콥퍑⩎⨀⨀⨀⼀ഀഀ
double calculateRetracePart(int n, double a) {਍   ഀഀ
   // 分子਍   搀漀甀戀氀攀 渀甀洀攀爀愀琀漀爀 㴀 　㬀ഀഀ
   ਍   ⼀⼀ ؀쵒൫ഀ
   double denominator = 0;਍   ഀഀ
   // a的i次幂਍   搀漀甀戀氀攀 愀䴀椀 㴀 ㄀㬀ഀഀ
   ਍   ⼀⼀ 嬀　帀滿崀 渀⬀㄀℀൫ഀ
   for (int i = 1; i < n; i++) {਍      愀䴀椀 㴀 愀⨀愀䴀椀㬀ഀഀ
   }਍   ഀഀ
   numerator = a*aMi - 1;਍   搀攀渀漀洀椀渀愀琀漀爀 㴀 ⠀愀⨀愀ⴀ㄀⤀⨀愀䴀椀㬀ഀഀ
   ਍   爀攀琀甀爀渀 ⠀渀甀洀攀爀愀琀漀爀⼀搀攀渀漀洀椀渀愀琀漀爀⤀㬀ഀഀ
}਍ഀഀ
double calculateRetraceAll(int n, double a) {਍   ഀഀ
   // 分子਍   搀漀甀戀氀攀 渀甀洀攀爀愀琀漀爀 㴀 　㬀ഀഀ
   ਍   ⼀⼀ ؀쵒൫ഀ
   double denominator = 0;਍   ഀഀ
   // a的i次幂਍   搀漀甀戀氀攀 愀䴀椀 㴀 ㄀㬀ഀഀ
   ਍   ⼀⼀ 嬀　帀滿崀 渀⬀㄀℀൫ഀ
   for (int i = 0; i <= n; i++) {਍      愀䴀椀 㴀 愀⨀愀䴀椀㬀ഀഀ
   }਍   ഀഀ
   numerator = aMi + n - a*(n+1);਍   搀攀渀漀洀椀渀愀琀漀爀 㴀 ⠀愀ⴀ㄀⤀⨀⠀愀䴀椀 ⴀ㄀⤀㬀ഀഀ
   ਍   爀攀琀甀爀渀 ⠀渀甀洀攀爀愀琀漀爀⼀搀攀渀漀洀椀渀愀琀漀爀⤀㬀ഀഀ
}਍ഀഀ
int createOrderBuy(double lotSize) {਍ഀഀ
   int chkBuy  = OrderSend(Symbol(), OP_BUY , lotSize, Ask, 0, 0, 0, "", MagicNumber, 0, clrBlue);਍   ഀഀ
   if (-1 == chkBuy) {਍      猀琀爀椀渀最 洀猀最 㴀 ∀䈀唀夀 伀爀搀攀爀匀攀渀搀 昀愀椀氀攀搀 椀渀 挀爀攀愀琀攀伀爀搀攀爀䈀甀礀⸀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
      msg += " Ask=" + DoubleToStr(Ask, Digits);਍      洀猀最 ⬀㴀 ∀ 氀漀琀匀椀稀攀㴀∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀氀漀琀匀椀稀攀Ⰰ ㈀⤀㬀ഀഀ
      Alert(msg);਍      爀攀琀甀爀渀 挀栀欀䈀甀礀㬀ഀഀ
   }਍   ഀഀ
   if (0 == countAPBuy && isEqualDouble(lotSize, initLots)) {਍      ഀഀ
   } else {਍      挀漀甀渀琀䄀倀䈀甀礀⬀⬀㬀ഀഀ
   }਍   ഀഀ
   double openPrice = Ask;਍   ഀഀ
   if (OrderSelect(chkBuy, SELECT_BY_TICKET)) {਍      漀瀀攀渀倀爀椀挀攀 㴀 伀爀搀攀爀伀瀀攀渀倀爀椀挀攀⠀⤀㬀ഀഀ
   } else {਍      猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀匀攀氀攀挀琀 昀愀椀氀攀搀 椀渀 挀爀攀愀琀攀伀爀搀攀爀䈀甀礀⸀∀㬀ഀഀ
      msg = msg + " Error:" + ErrorDescription(GetLastError());਍      洀猀最 㴀 洀猀最 ⬀ ∀ 䈀甀礀 吀椀挀欀攀琀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀挀栀欀䈀甀礀⤀㬀ഀഀ
      Alert(msg);਍   紀ഀഀ
   ਍   伀爀搀攀爀䤀渀昀漀 漀爀搀攀爀䤀渀昀漀 㴀 笀　⸀　㄀Ⰰ 　⸀　Ⰰ 　⸀　Ⰰ 　⸀　Ⰰ 　Ⰰ 伀倀开䈀唀夀紀㬀ഀഀ
   orderInfo.lotSize = lotSize;਍   漀爀搀攀爀䤀渀昀漀⸀漀瀀攀渀倀爀椀挀攀 㴀 漀瀀攀渀倀爀椀挀攀㬀ഀഀ
   orderInfo.ticketId = chkBuy;਍   愀爀爀伀爀搀攀爀猀䈀甀礀嬀挀漀甀渀琀䄀倀䈀甀礀崀 㴀 漀爀搀攀爀䤀渀昀漀㬀ഀഀ
   ਍   爀攀琀甀爀渀 挀栀欀䈀甀礀㬀ഀഀ
}਍ഀഀ
int createOrderSell(double lotSize) {਍ഀഀ
   int chkSell = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, 0, 0, "", MagicNumber, 0, clrRed);਍   ഀഀ
   if (-1 == chkSell) {਍      猀琀爀椀渀最 洀猀最 㴀 ∀匀䔀䰀䰀 伀爀搀攀爀匀攀渀搀 昀愀椀氀攀搀 椀渀 挀爀攀愀琀攀伀爀搀攀爀匀攀氀氀⸀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
      msg += " Bid=" + DoubleToStr(Bid, Digits);਍      洀猀最 ⬀㴀 ∀ 氀漀琀匀椀稀攀㴀∀ ⬀ 䐀漀甀戀氀攀吀漀匀琀爀⠀氀漀琀匀椀稀攀Ⰰ ㈀⤀㬀ഀഀ
      Alert(msg);਍      爀攀琀甀爀渀 挀栀欀匀攀氀氀㬀ഀഀ
   }਍   ഀഀ
   if (0 == countAPSell && isEqualDouble(lotSize, initLots)) {਍   紀 攀氀猀攀 笀ഀഀ
      countAPSell++;਍   紀ഀഀ
   ਍   搀漀甀戀氀攀 漀瀀攀渀倀爀椀挀攀 㴀 䈀椀搀㬀ഀഀ
   ਍   椀昀 ⠀伀爀搀攀爀匀攀氀攀挀琀⠀挀栀欀匀攀氀氀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开吀䤀䌀䬀䔀吀⤀⤀ 笀ഀഀ
      openPrice = OrderOpenPrice();਍   紀 攀氀猀攀 笀ഀഀ
      string msg = "OrderSelect failed in createOrderSell.";਍      洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
      msg = msg + " Sell Ticket = " + IntegerToString(chkSell);਍      䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
   }਍   ഀഀ
   OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_SELL};਍   漀爀搀攀爀䤀渀昀漀⸀氀漀琀匀椀稀攀 㴀 氀漀琀匀椀稀攀㬀ഀഀ
   orderInfo.openPrice = openPrice;਍   漀爀搀攀爀䤀渀昀漀⸀琀椀挀欀攀琀䤀搀 㴀 挀栀欀匀攀氀氀㬀ഀഀ
   arrOrdersSell[countAPSell] = orderInfo;਍   ഀഀ
   return chkSell;਍紀ഀഀ
਍戀漀漀氀 椀猀䔀焀甀愀氀䐀漀甀戀氀攀⠀搀漀甀戀氀攀 渀甀洀㄀Ⰰ 搀漀甀戀氀攀 渀甀洀㈀⤀ 笀ഀഀ
਍   椀昀⠀ 一漀爀洀愀氀椀稀攀䐀漀甀戀氀攀⠀渀甀洀㄀ⴀ渀甀洀㈀Ⰰ㠀⤀ 㴀㴀 　 ⤀ 笀ഀഀ
      return true;਍   紀ഀഀ
   ਍   爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
}਍ഀഀ
void SetComments() {਍   漀瀀倀愀渀攀氀⸀爀攀昀爀攀猀栀吀愀爀最攀琀倀爀漀昀椀琀䰀漀渀最⠀挀氀漀猀攀倀爀漀昀椀琀䈀甀礀⤀㬀ഀഀ
   opPanel.refreshTargetProfitShort(closeProfitSell);਍   漀瀀倀愀渀攀氀⸀爀攀昀爀攀猀栀吀愀爀最攀琀刀攀琀爀愀挀攀䰀漀渀最⠀爀攀琀爀愀挀攀刀愀琀椀漀䈀甀礀⤀㬀ഀഀ
   opPanel.refreshTargetRetraceShort(retraceRatioSell);਍   漀瀀倀愀渀攀氀⸀爀攀昀爀攀猀栀䄀搀搀倀漀猀椀琀椀漀渀吀椀洀攀猀䰀漀渀最⠀挀漀甀渀琀䄀倀䈀甀礀⤀㬀ഀഀ
   opPanel.refreshAddPositionTimesShort(countAPSell);਍紀ഀഀ
਍瘀漀椀搀 甀瀀搀愀琀攀一攀眀猀匀琀愀琀甀猀⠀⤀ 笀ഀഀ
਍   猀琀爀椀渀最 氀戀氀刀攀洀愀椀渀吀椀洀攀 㴀 ∀刀攀洀愀椀渀开吀椀洀攀∀㬀ഀഀ
   if (ObjectFind(0, lblRemainTime) < 0) {਍      洀甀猀琀匀琀漀瀀䔀䄀䈀礀一攀眀猀 㴀 昀愀氀猀攀㬀ഀഀ
      forbidCreateOrder = false;਍      爀攀琀甀爀渀㬀ഀഀ
   }਍   ഀഀ
   string remainTime = "";਍   伀戀樀攀挀琀䜀攀琀匀琀爀椀渀最⠀　Ⰰ 氀戀氀刀攀洀愀椀渀吀椀洀攀Ⰰ 伀䈀䨀倀刀伀倀开吀䔀堀吀Ⰰ 　Ⰰ 爀攀洀愀椀渀吀椀洀攀⤀㬀ഀഀ
   ਍   椀渀琀 栀漀甀爀猀 㴀 匀琀爀吀漀䤀渀琀攀最攀爀⠀匀琀爀椀渀最匀甀戀猀琀爀⠀爀攀洀愀椀渀吀椀洀攀Ⰰ 　Ⰰ ㈀⤀⤀㬀ഀഀ
   int minutes = StrToInteger(StringSubstr(remainTime, 3, 2));਍   ⼀⼀椀渀琀 猀攀挀漀渀搀猀 㴀 匀琀爀吀漀䤀渀琀攀最攀爀⠀匀琀爀椀渀最匀甀戀猀琀爀⠀爀攀洀愀椀渀吀椀洀攀Ⰰ 㘀Ⰰ ㈀⤀⤀㬀ഀഀ
   ਍   椀昀 ⠀　 㴀㴀 栀漀甀爀猀 ☀☀ 洀椀渀甀琀攀猀 㰀㴀 ㄀⤀ 笀ഀഀ
      stopedTimeByNews = TimeLocal();਍   紀ഀഀ
   ਍   椀昀 ⠀　 㴀㴀 栀漀甀爀猀 ☀☀ 洀椀渀甀琀攀猀 㰀㴀 洀椀渀甀琀攀猀䴀甀猀琀匀琀漀瀀䔀䄀䈀攀昀漀爀攀一攀眀猀⤀ 笀ഀഀ
      mustStopEAByNews = true;਍      ⼀⼀爀攀琀甀爀渀㬀ഀഀ
   } else {਍      洀甀猀琀匀琀漀瀀䔀䄀䈀礀一攀眀猀 㴀 昀愀氀猀攀㬀ഀഀ
   }਍   ഀഀ
   if (hours < hoursForbidCreateOrderBeforeNews) {਍      昀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀 㴀 琀爀甀攀㬀ഀഀ
   } else {਍      昀漀爀戀椀搀䌀爀攀愀琀攀伀爀搀攀爀 㴀 昀愀氀猀攀㬀ഀഀ
   }਍ഀഀ
}਍ഀഀ
void DrawLine(string ctlName, ਍               搀漀甀戀氀攀 倀爀椀挀攀 㴀 　Ⰰ ഀഀ
               color LineColor = clrGold, ਍               䔀一唀䴀开䰀䤀一䔀开匀吀夀䰀䔀 䰀椀渀攀匀琀礀氀攀 㴀 匀吀夀䰀䔀开匀伀䰀䤀䐀Ⰰഀഀ
               int LineWidth = 1) ਍笀ഀഀ
   string FullCtlName = ctlName;਍   ഀഀ
   if (-1 < ObjectFind(ChartID(), FullCtlName))਍   笀ഀഀ
         ObjectMove(FullCtlName, 0, 0, Price);਍         伀戀樀攀挀琀匀攀琀⠀䘀甀氀氀䌀琀氀一愀洀攀Ⰰ 伀䈀䨀倀刀伀倀开匀吀夀䰀䔀Ⰰ 䰀椀渀攀匀琀礀氀攀⤀㬀ഀഀ
         ObjectSet(FullCtlName, OBJPROP_WIDTH, LineWidth);਍         伀戀樀攀挀琀匀攀琀⠀䘀甀氀氀䌀琀氀一愀洀攀Ⰰ 伀䈀䨀倀刀伀倀开䌀伀䰀伀刀Ⰰ 䰀椀渀攀䌀漀氀漀爀⤀㬀ഀഀ
   }਍   攀氀猀攀ഀഀ
   {਍      伀戀樀攀挀琀䌀爀攀愀琀攀⠀䌀栀愀爀琀䤀䐀⠀⤀Ⰰ 䘀甀氀氀䌀琀氀一愀洀攀Ⰰ 伀䈀䨀开䠀䰀䤀一䔀Ⰰ 　Ⰰ 　Ⰰ 倀爀椀挀攀⤀㬀ഀഀ
      ObjectSet(FullCtlName, OBJPROP_STYLE, LineStyle);਍      伀戀樀攀挀琀匀攀琀⠀䘀甀氀氀䌀琀氀一愀洀攀Ⰰ 伀䈀䨀倀刀伀倀开圀䤀䐀吀䠀Ⰰ 䰀椀渀攀圀椀搀琀栀⤀㬀ഀഀ
      ObjectSet(FullCtlName, OBJPROP_COLOR, LineColor);਍   紀ഀഀ
}਍ഀഀ
bool closeMaxAPLongOrder() {਍   椀昀 ⠀挀漀甀渀琀䄀倀䈀甀礀 㰀 ㄀⤀ 笀ഀഀ
      return false;਍   紀ഀഀ
   int ticketId = arrOrdersBuy[countAPBuy].ticketId;਍   戀漀漀氀 椀猀匀攀氀攀挀琀攀搀 㴀 伀爀搀攀爀匀攀氀攀挀琀⠀琀椀挀欀攀琀䤀搀Ⰰ 匀䔀䰀䔀䌀吀开䈀夀开吀䤀䌀䬀䔀吀⤀㬀ഀഀ
   if (!isSelected) {਍      猀琀爀椀渀最 洀猀最 㴀 ∀伀爀搀攀爀匀攀氀攀挀琀 昀愀椀氀攀搀 椀渀 挀氀漀猀攀䴀愀砀䄀倀䰀漀渀最伀爀搀攀爀⸀∀㬀ഀഀ
      msg = msg + " Error:" + ErrorDescription(GetLastError());਍      洀猀最 㴀 洀猀最 ⬀ ∀ 䈀甀礀 吀椀挀欀攀琀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀琀椀挀欀攀琀䤀搀⤀㬀ഀഀ
      Alert(msg);਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍   戀漀漀氀 椀猀匀甀挀挀攀猀猀 㴀 伀爀搀攀爀䌀氀漀猀攀⠀琀椀挀欀攀琀䤀搀Ⰰ 伀爀搀攀爀䰀漀琀猀⠀⤀Ⰰ 䈀椀搀Ⰰ 　⤀㬀ഀഀ
   if (!isSuccess) {਍      瀀爀椀渀琀昀⠀∀䈀甀礀 伀爀搀攀爀 䌀氀漀猀攀 昀愀椀氀甀爀攀 椀渀 挀氀漀猀攀䴀愀砀䄀倀䰀漀渀最伀爀搀攀爀⸀ 琀椀挀欀攀搀䤀搀 㴀 ∀ ⬀ 䤀渀琀攀最攀爀吀漀匀琀爀椀渀最⠀琀椀挀欀攀琀䤀搀⤀ ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀⤀㬀ഀഀ
   } else {਍      伀爀搀攀爀䤀渀昀漀 漀爀搀攀爀䤀渀昀漀 㴀 笀　⸀　㄀Ⰰ 　⸀　Ⰰ 　⸀　Ⰰ 　⸀　Ⰰ 　Ⰰ 伀倀开䈀唀夀紀㬀ഀഀ
      arrOrdersBuy[countAPBuy] = orderInfo;਍      挀漀甀渀琀䄀倀䈀甀礀ⴀⴀ㬀ഀഀ
      resetRetrace4Buy();਍   紀ഀഀ
   return isSuccess;਍紀ഀഀ
਍戀漀漀氀 挀氀漀猀攀䴀愀砀䄀倀匀栀漀爀琀伀爀搀攀爀⠀⤀ 笀ഀഀ
   if (countAPSell < 1) {਍      爀攀琀甀爀渀 昀愀氀猀攀㬀ഀഀ
   }਍   椀渀琀 琀椀挀欀攀琀䤀搀 㴀 愀爀爀伀爀搀攀爀猀匀攀氀氀嬀挀漀甀渀琀䄀倀匀攀氀氀崀⸀琀椀挀欀攀琀䤀搀㬀ഀഀ
   bool isSelected = OrderSelect(ticketId, SELECT_BY_TICKET);਍   椀昀 ⠀℀椀猀匀攀氀攀挀琀攀搀⤀ 笀ഀഀ
      string msg = "OrderSelect failed in closeMaxAPShortOrder.";਍      洀猀最 㴀 洀猀最 ⬀ ∀ 䔀爀爀漀爀㨀∀ ⬀ 䔀爀爀漀爀䐀攀猀挀爀椀瀀琀椀漀渀⠀䜀攀琀䰀愀猀琀䔀爀爀漀爀⠀⤀⤀㬀ഀഀ
      msg = msg + " Buy Ticket = " + IntegerToString(ticketId);਍      䄀氀攀爀琀⠀洀猀最⤀㬀ഀഀ
      return false;਍   紀ഀഀ
   bool isSuccess = OrderClose(ticketId, OrderLots(), Ask, 0);਍   椀昀 ⠀℀椀猀匀甀挀挀攀猀猀⤀ 笀ഀഀ
      printf("Sell Order Close failure in closeMaxAPShortOrder. tickedId = " + IntegerToString(ticketId) + " Error:" + ErrorDescription(GetLastError()));਍   紀 攀氀猀攀 笀ഀഀ
      OrderInfo orderInfo = {0.01, 0.0, 0.0, 0.0, 0, OP_SELL};਍      愀爀爀伀爀搀攀爀猀匀攀氀氀嬀挀漀甀渀琀䄀倀匀攀氀氀崀 㴀 漀爀搀攀爀䤀渀昀漀㬀ഀഀ
      countAPSell--;਍      爀攀猀攀琀刀攀琀爀愀挀攀㐀匀攀氀氀⠀⤀㬀ഀഀ
   }਍   爀攀琀甀爀渀 椀猀匀甀挀挀攀猀猀㬀ഀഀ
}
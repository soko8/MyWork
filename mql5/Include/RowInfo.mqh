//+------------------------------------------------------------------+
//|                                                      RowInfo.mqh |
//|                                        Copyright 2022, Zeng Gao. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Zeng Gao."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>
#include <Arrays\List.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade/Trade.mqh>

class COrder : public CPositionInfo {
//class COrder : public CObject {
protected:
   ulong             _ticket;
   //double            _OpenPrice;
   //ENUM_ORDER_TYPE   _type;
   //double            _StopLoss;
   //double            _TakeProfit;
   string            _PairName;
   string            _Description;
   //double            _ProfitCurrent;
   bool              _Closed;
   //double            _Volume;
   double            _Pips_Tp2OpenPrice;
   //double            _Pips_Tp2CurrentPrice;
   double            _Pips_Sl2OpenPrice;
   //double            _Pips_Sl2CurrentPrice;
   
public:
                     COrder(void) {}
                    ~COrder(void) {}

   void              setTicket(const ulong ticket) { _ticket = ticket; }
   ulong             getTicket(void)               { return(_ticket); }
   
   double            PriceOpen(void) const { return(m_price); }
   //void              PriceOpen(const double price) { _OpenPrice = price; }
   
   ENUM_POSITION_TYPE   PositionType(void) const { return(m_type); }
   //void              OrderType(const ENUM_ORDER_TYPE type) { _type = type; }
   
   double            StopLoss(void) const { return(m_stop_loss); }
   void              StopLoss(const double sl);
   
   double            TakeProfit(void) const { return(m_take_profit); }
   void              TakeProfit(const double tp);
   
   double            Volume(void) const { return(m_volume); }
   void              Volume(const double lots) { m_volume = lots; }
   
   string            Description(void) const { return(_Description); }
   void              Description(const string comment) { _Description = comment; }
   
   string            PairName(void) const { return(_PairName); }
   void              PairName(const string name) { _PairName = name; }
   
   bool              IsClosed(void) const { return(_Closed); }
   void              Closed(const bool closed) { _Closed = closed; }
   
   double            ProfitCurrent(void) const;
   
   double            Pips_Tp2OpenPrice(void) const { return(_Pips_Tp2OpenPrice); }
   double            Pips_Sl2OpenPrice(void) const { return(_Pips_Sl2OpenPrice); }
   
   double            Pips4Tp2CurrentPrice(void) const;
   double            Pips4Sl2CurrentPrice(void) const;
   
   bool              Select(void);
   //void              StoreState(void);
};
bool COrder::Select(void) {
   bool isSelected = PositionSelectByTicket(_ticket);
   if (!isSelected) return false;
   StoreState();
   _PairName = Symbol();
   _Description = Comment();
   _Pips_Sl2OpenPrice = calculatePips(_PairName, m_stop_loss, m_price);
   _Pips_Tp2OpenPrice = calculatePips(_PairName, m_take_profit, m_price);
   return true;
}
double COrder::ProfitCurrent(void) const {
   /*
   double closePrice = 0.0;
   double profit;
   if (POSITION_TYPE_BUY == _type) {
      closePrice = SymbolInfoDouble(_PairName, SYMBOL_BID);
      if (OrderCalcProfit(_type, _PairName, _Volume, _OpenPrice, closePrice, profit)) return(profit);
   }
   if (POSITION_TYPE_SELL == _type) {
      closePrice = SymbolInfoDouble(_PairName, SYMBOL_ASK);
      if (OrderCalcProfit(_type, _PairName, _Volume, _OpenPrice, closePrice, profit)) return(profit);
   }
   */
   bool isSelected = PositionSelectByTicket(_ticket);
   if (!isSelected) return 0.0;
   return(Profit()+Commission()+Swap());
};

double calculatePips(const string symbol, const double price1, const double price2) {
   double diff = price1 - price2;
   diff = diff/SymbolInfoDouble(symbol, SYMBOL_POINT);
   diff = diff/10;
   return (diff);
}
double COrder::Pips4Tp2CurrentPrice(void) const {
   if (POSITION_TYPE_BUY == m_type) {
      /*
      double diff = m_take_profit - SymbolInfoDouble(_PairName, SYMBOL_BID);
      diff = diff/SymbolInfoDouble(_PairName, SYMBOL_POINT);
      diff = diff/10;
      */
      return (calculatePips(_PairName, m_take_profit, SymbolInfoDouble(_PairName, SYMBOL_BID)));
   }
   if (POSITION_TYPE_SELL == m_type) {
      return (calculatePips(_PairName, m_take_profit, SymbolInfoDouble(_PairName, SYMBOL_ASK)));
   }
   return (0.0);
}

double COrder::Pips4Sl2CurrentPrice(void) const {
   if (POSITION_TYPE_BUY == m_type) {
      return (calculatePips(_PairName, m_stop_loss, SymbolInfoDouble(_PairName, SYMBOL_BID)));
   }
   if (POSITION_TYPE_SELL == m_type) {
      return (calculatePips(_PairName, m_stop_loss, SymbolInfoDouble(_PairName, SYMBOL_ASK)));
   }
   return (0.0);
}

void COrder::StopLoss(const double sl) {
   m_stop_loss = sl;
   _Pips_Sl2OpenPrice = calculatePips(_PairName, m_stop_loss, m_price);
}

void COrder::TakeProfit(const double tp) {
   m_take_profit = tp;
   _Pips_Tp2OpenPrice = calculatePips(_PairName, m_take_profit, m_price);
}
/*
void COrder::StoreState(void) {
   _type       = ((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE));
   _Volume     = OrderGetDouble(ORDER_VOLUME_CURRENT);
   _OpenPrice  = OrderGetDouble(ORDER_PRICE_OPEN);
   _StopLoss   = OrderGetDouble(ORDER_SL);
   _TakeProfit = OrderGetDouble(ORDER_TP);
   _PairName   = OrderGetString(ORDER_SYMBOL);
}




COrder *add2Orders(CList *list, const ulong ticket, const string comment="") {
   COrder *order;
   order = new COrder;
   order.Select();
   order.StoreState();
   order.Description(comment);
   //order.PairName(order.Symbol());
   //order.StopLoss(order.StopLoss());
   //order.TakeProfit(order.TakeProfit());
   //order.Volume(order.VolumeCurrent());
   list.Add(order);
   return order;
}
bool deleteFromOrders(CList *list, const ulong ticket) {
   int cnt = list.Total();
   ulong ticket__;
   COrder *order;
   for (int i=0; i<cnt; i++) {
      order = list.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) return list.Delete(i);
   }
   
   return false;
}
*/

double pip2Price(const ushort pips, const string symbol) {
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);
   return (pips*10*point);
}

class CRowInfo : public CObject {

protected:

	bool        _H;
	bool        _D;
	bool        _N;
	//string		_Chart;
	bool        _Select;
	double		_MaxProfit;
	double		_MinProfit;
	bool        _SingularModeL;
	bool        _TradeModeL;
	bool        _GridModeL;
	bool        _RetraceModeL;
	bool        _OtherModeL;
	//bool        _PlusOrdL;
	int         _OrdCntL;
	//bool        _MinusOrdL;
	double		_ProfitLMinus;
	//bool        _MinusMaxOrdL;
	double		_ProfitLMinusMax;
	double		_LotsL;
	//bool        _ClosePositiveL;
	double		_ProfitL;
	//bool        _CloseNegativeL;
	double		_MaxProfitL;
	double		_MinProfitL;
	//bool        _CloseL;
	double		_Tp2OPL;
	bool        _EnableTpL;
	//bool        _AddTpL;
	double		_Tp2Bid;
	//bool        _MinusTpL;
	double		_Sl2OPL;
	bool        _EnableSlL;
	//bool        _AddSlL;
	double		_Sl2Ask;
	//bool        _MinusSlL;
	double		_SwapL;
	string		_SymbolN;
	bool        _EnableGrid;
	//bool        _PlusGrid;
	short       _GridPips;
	//bool        _MinusGrid;
	bool        _EnableRetrace;
	//bool		   _PlusRetrace;
	short		   _RetracePips;
	//bool		   _MinusRetrace;
	double		_SwapS;
	bool		   _SingularModeS;
	bool		   _TradeModeS;
	bool		   _GridModeS;
	bool		   _RetraceModeS;
	bool		   _OtherModeS;
	//bool		   _PlusOrdS;
	int         _OrdCntS;
	//bool		   _MinusOrdS;
	double		_ProfitSMinus;
	//bool		   _MinusMaxOrdS;
	double		_ProfitSMinusMax;
	double		_LotsS;
	//bool		   _ClosePositiveS;
	double		_ProfitS;
	//bool		   _CloseNegativeS;
	double		_MaxProfitS;
	double		_MinProfitS;
	//bool		   _CloseS;
	double		_Tp2OPS;
	bool		   _EnableTpS;
	//bool		   _AddTpS;
	double		_Tp2Ask;
	//bool		   _MinusTpS;
	double		_Sl2OPS;
	bool		   _EnableSlS;
	//bool		   _AddSlS;
	double		_Sl2Bid;
	//bool		   _MinusSlS;
	double		_Profit;
	//bool		   _CloseLS;
	//double		_Spread;
	ushort		_ADR;
	//ushort		_CDR;
	char		   _Pins[];
	/*char		   _PIN2;
	char		   _PIN3;
	char		   _PIN4;
	char		   _PIN5;
	char		   _PIN6;
	char		   _PIN7;
	char		   _PIN8;
	char		   _PIN9;*/
	bool        hasSignalL;
	bool        hasSignalS;

	string      _SymbolNm;
	
	ushort		_TpPips;
	ushort		_SlPips;
	
	bool        _EnableTrailingStop;
	ushort		_TrailingStopPips;
	
	double      pip2PriceTp;
	double      pip2PriceSl;
	double      pip2PriceTs;
	
	//bool        _UseGrid;
	uchar       _GridMaxTimes;
	double      _GridNextPrice;
	
	//bool        _UseRetrace;
	uchar       _RetraceMaxTimes;
	double      _RetraceMultiple;
	double      _RetraceProfitCoefficient;
	double      _RetraceNextPrice;
	
	uchar       _MaxOrders;
	double      _InitLotSize;
	double      _LotStep;
	datetime    _NextNewOrderTimeL;
	datetime    _NextNewOrderTimeS;
	
   CSymbolInfo _symbolInfo;
   CList *_OrdersL;
   CList *_OrdersS;
   
   CList *_OrdersGridL;
   CList *_OrdersGridS;
   
   CList *_OrdersRetraceL;
   CList *_OrdersRetraceS;
   
   CList *_OrdersAllL;
   CList *_OrdersAllS;
   
   CTrade            trade;
   MqlTradeResult    TradeResult;

public:
                     CRowInfo(void);
                     CRowInfo(const string showName, const string prefix, const string surfix, const int pinCount);
                    ~CRowInfo(void);
   //--- methods of access to protected data
   string            SymbolNm(void) const { return(_SymbolNm); }
   void              SymbolNm(const string name) { _SymbolNm = name; }
   
   ushort            TpPips(void) const { return(_TpPips); }
   double            TpPrice(void) const { return(pip2PriceTp); }
   void              TpPips(const ushort pips) { _TpPips = pips; pip2PriceTp = pip2Price(pips, _SymbolNm); }
   
   ushort            SlPips(void) const { return(_SlPips); }
   double            SlPrice(void) const { return(pip2PriceSl); }
   void              SlPips(const ushort pips) { _SlPips = pips; pip2PriceSl = pip2Price(pips, _SymbolNm); }
   
   bool              EnableTrailingStop(void) const { return(_EnableTrailingStop); }
   void              EnableTrailingStop(const bool trailingStop) { _EnableTrailingStop = trailingStop; }
   ushort            TrailingStopPips(void) const { return(_TrailingStopPips); }
   void              TrailingStopPips(const ushort pips) { _TrailingStopPips = pips; pip2PriceTs = pip2Price(pips, _SymbolNm); }
   
   
   uchar             GridMaxTimes(void) const { return(_GridMaxTimes); }
   void              GridMaxTimes(const uchar times) { _GridMaxTimes = times; }
   double            GridNextPrice(void) const { return(_GridNextPrice); }
   void              GridNextPrice(const double price) { _GridNextPrice = price; }
   
   uchar             RetraceMaxTimes(void) const { return(_RetraceMaxTimes); }
   void              RetraceMaxTimes(const uchar times) { _RetraceMaxTimes = times; }
   double            RetraceMultiple(void) const { return(_RetraceMultiple); }
   void              RetraceMultiple(const double multiple) { _RetraceMultiple = multiple; }
   double            RetraceProfitCoefficient(void) const { return(_RetraceProfitCoefficient); }
   void              RetraceProfitCoefficient(const double coefficient) { _RetraceProfitCoefficient = coefficient; }
   double            RetraceNextPrice(void) const { return(_RetraceNextPrice); }
   void              RetraceNextPrice(const double price) { _RetraceNextPrice = price; }
   
   double            InitLotSize(void) const { return(_InitLotSize); }
   void              InitLotSize(const double lots) { _InitLotSize = lots; }
   double            LotStep(void) const { return(_LotStep); }
   void              LotStep(const double lotStep) { _LotStep = lotStep; }
   
   uchar             MaxOrders(void) const { return(_MaxOrders); }
   void              MaxOrders(const uchar times) { _MaxOrders = times; }
   
   datetime          NextNewOrderTimeL(void) const { return(_NextNewOrderTimeL); }
   datetime          NextNewOrderTimeS(void) const { return(_NextNewOrderTimeS); }

   char              GetPin(int index) const { return(_Pins[index]); }
   void              SetPin(const char pinValue, int index) { _Pins[index] = pinValue; }
   
   bool              HasSignalL(void) const { return(hasSignalL); }
   void              HasSignalL(const bool signal) { hasSignalL = signal; }
   
   bool              HasSignalS(void) const { return(hasSignalS); }
   void              HasSignalS(const bool signal) { hasSignalS = signal; }
   
	bool	H(void)			         const { return(_H); }
	bool	D(void)			         const { return(_D); }
	bool	N(void)			         const { return(_N); }
	//string	Chart(void)          const { return(_Chart); }
	bool	Select(void)            const { return(_Select); }
	double	MaxProfit(void)      const { return(_MaxProfit); }
	double	MinProfit(void)      const { return(_MinProfit); }
	bool	SingularModeL(void)     const { return(_SingularModeL); }
	bool	TradeModeL(void)			const { return(_TradeModeL); }
	bool	GridModeL(void)			const { return(_GridModeL); }
	bool	RetraceModeL(void)      const { return(_RetraceModeL); }
	bool	OtherModeL(void)			const { return(_OtherModeL); }
	//bool	PlusOrdL(void)			const { return(_PlusOrdL); }
	int      OrdCntL(void)        const { return(_OrdCntL); }
	//bool	MinusOrdL(void)      const { return(_MinusOrdL); }
	double	ProfitLMinus(void)   const { return(_ProfitLMinus); }
	//bool	MinusMaxOrdL(void)   const { return(_MinusMaxOrdL); }
	double	ProfitLMinusMax(void)const { return(_ProfitLMinusMax); }
	double	LotsL(void)          const { return(_LotsL); }
	//bool	ClosePositiveL(void) const { return(_ClosePositiveL); }
	double	ProfitL(void)        const { return(_ProfitL); }
	//bool	CloseNegativeL(void) const { return(_CloseNegativeL); }
	double	MaxProfitL(void)     const { return(_MaxProfitL); }
	double	MinProfitL(void)     const { return(_MinProfitL); }
	//bool	CloseL(void)			const { return(_CloseL); }
	double	Tp2OPL(void)         const { return(_Tp2OPL); }
	bool	EnableTpL(void)			const { return(_EnableTpL); }
	//bool	AddTpL(void)			const { return(_AddTpL); }
	double	Tp2Bid(void)         const { return(_Tp2Bid); }
	//bool	MinusTpL(void)			const { return(_MinusTpL); }
	double	Sl2OPL(void)         const { return(_Sl2OPL); }
	bool	EnableSlL(void)			const { return(_EnableSlL); }
	//bool	AddSlL(void)			const { return(_AddSlL); }
	double	Sl2Ask(void)         const { return(_Sl2Ask); }
	//bool	MinusSlL(void)			const { return(_MinusSlL); }
	double	SwapL(void)          const { return(_SwapL); }
	string	SymbolN(void)			const { return(_SymbolN); }
	bool	EnableGrid(void)			const { return(_EnableGrid); }
	//bool	PlusGrid(void)			const { return(_PlusGrid); }
	short	GridPips(void)          const { return(_GridPips); }
	//bool	MinusGrid(void)      const { return(_MinusGrid); }
	bool	EnableRetrace(void)     const { return(_EnableRetrace); }
	//bool	PlusRetrace(void)    const { return(_PlusRetrace); }
	short	RetracePips(void)			const { return(_RetracePips); }
	//bool	MinusRetrace(void)   const { return(_MinusRetrace); }
	double	SwapS(void)          const { return(_SwapS); }
	bool	SingularModeS(void)     const { return(_SingularModeS); }
	bool	TradeModeS(void)			const { return(_TradeModeS); }
	bool	GridModeS(void)			const { return(_GridModeS); }
	bool	RetraceModeS(void)      const { return(_RetraceModeS); }
	bool	OtherModeS(void)			const { return(_OtherModeS); }
	//bool	PlusOrdS(void)			const { return(_PlusOrdS); }
	int	OrdCntS(void)           const { return(_OrdCntS); }
	//bool	MinusOrdS(void)      const { return(_MinusOrdS); }
	double	ProfitSMinus(void)   const { return(_ProfitSMinus); }
	//bool	MinusMaxOrdS(void)   const { return(_MinusMaxOrdS); }
	double	ProfitSMinusMax(void)const { return(_ProfitSMinusMax); }
	double	LotsS(void)          const { return(_LotsS); }
	//bool	ClosePositiveS(void) const { return(_ClosePositiveS); }
	double	ProfitS(void)			const { return(_ProfitS); }
	//bool	CloseNegativeS(void) const { return(_CloseNegativeS); }
	double	MaxProfitS(void)     const { return(_MaxProfitS); }
	double	MinProfitS(void)     const { return(_MinProfitS); }
	//bool	CloseS(void)			const { return(_CloseS); }
	double	Tp2OPS(void)			const { return(_Tp2OPS); }
	bool	EnableTpS(void)			const { return(_EnableTpS); }
	//bool	AddTpS(void)			const { return(_AddTpS); }
	double	Tp2Ask(void)			const { return(_Tp2Ask); }
	//bool	MinusTpS(void)			const { return(_MinusTpS); }
	double	Sl2OPS(void)			const { return(_Sl2OPS); }
	bool	EnableSlS(void)			const { return(_EnableSlS); }
	//bool	AddSlS(void)			const { return(_AddSlS); }
	double	Sl2Bid(void)			const { return(_Sl2Bid); }
	//bool	MinusSlS(void)			const { return(_MinusSlS); }
	double	Profit(void)			const { return(_Profit); }
	//bool	CloseLS(void)			const { return(_CloseLS); }
	double	Spread(void)			const { return((double)SymbolInfoInteger(_SymbolNm,SYMBOL_SPREAD))/10; }
	ushort	ADR(void)            const { return(_ADR); }
	ushort	CDR(void)            const { return((ushort)((SymbolInfoDouble(_SymbolNm,SYMBOL_BIDHIGH)-SymbolInfoDouble(_SymbolNm,SYMBOL_BIDLOW))/SymbolInfoDouble(_SymbolNm,SYMBOL_POINT))); }
	/*char	PIN1(void)           const { return(_PIN1); }
	char	PIN2(void)			      const { return(_PIN2); }
	char	PIN3(void)			      const { return(_PIN3); }
	char	PIN4(void)			      const { return(_PIN4); }
	char	PIN5(void)			      const { return(_PIN5); }
	char	PIN6(void)			      const { return(_PIN6); }
	char	PIN7(void)			      const { return(_PIN7); }
	char	PIN8(void)			      const { return(_PIN8); }
	char	PIN9(void)			      const { return(_PIN9); }*/



	void	H(const bool	H_)		{ _H	=	H_;  }
	void	D(const bool	D_)		{ _D	=	D_;  }
	void	N(const bool	N_)		{ _N	=	N_;  }
	//void	Chart(const string	Chart_)		{ _Chart	=	Chart_;  }
	void	Select(const bool	Select_)		{ _Select	=	Select_;  }
	//void	MaxProfit(const double	MaxProfit_)		{ _MaxProfit	=	MaxProfit_;  }
	//void	MinProfit(const double	MinProfit_)		{ _MinProfit	=	MinProfit_;  }
	void	SingularModeL(const bool	SingularModeL_);//		{ _SingularModeL	=	SingularModeL_;  }
	void	TradeModeL(const bool	TradeModeL_);
	//void	TradeModeL(const bool	TradeModeL_)		{ _TradeModeL=TradeModeL_; if (_TradeModeL) {_Tp2OPL=_TpPips;_Sl2OPL=_SlPips;} }
	void	GridModeL(const bool	GridModeL_);//		{ _GridModeL	=	GridModeL_; if (_GridModeL&&_SingularModeL) _OrdCntL=_OrdersGridL.Total(); }
	void	RetraceModeL(const bool	RetraceModeL_);//		{ _RetraceModeL	=	RetraceModeL_; if (_RetraceModeL&&_SingularModeL) _OrdCntL=_OrdersRetraceL.Total(); }
	void	OtherModeL(const bool	OtherModeL_);//		{ _OtherModeL	=	OtherModeL_; if (_OtherModeL&&_SingularModeL) _OrdCntL=_OrdersL.Total(); }
	//void	PlusOrdL(const bool	PlusOrdL_)		{ _PlusOrdL	=	PlusOrdL_;  }
	void	OrdCntL(const int	OrdCntL_)		{ _OrdCntL	=	OrdCntL_;  }
	//void	MinusOrdL(const bool	MinusOrdL_)		{ _MinusOrdL	=	MinusOrdL_;  }
	//void	ProfitLMinus(const double	ProfitLMinus_)		{ _ProfitLMinus	=	ProfitLMinus_;  }
	//void	MinusMaxOrdL(const bool	MinusMaxOrdL_)		{ _MinusMaxOrdL	=	MinusMaxOrdL_;  }
	//void	ProfitLMinusMax(const double	ProfitLMinusMax_)		{ _ProfitLMinusMax	=	ProfitLMinusMax_;  }
	void	LotsL(const double	LotsL_)		{ _LotsL	=	LotsL_;  }
	//void	ClosePositiveL(const bool	ClosePositiveL_)		{ _ClosePositiveL	=	ClosePositiveL_;  }
	//void	ProfitL(const double	ProfitL_)		{ _ProfitL	=	ProfitL_;  }
	//void	CloseNegativeL(const bool	CloseNegativeL_)		{ _CloseNegativeL	=	CloseNegativeL_;  }
	//void	MaxProfitL(const double	MaxProfitL_)		{ _MaxProfitL	=	MaxProfitL_;  }
	//void	MinProfitL(const double	MinProfitL_)		{ _MinProfitL	=	MinProfitL_;  }
	//void	CloseL(const bool	CloseL_)		{ _CloseL	=	CloseL_;  }
	//void	Tp2OPL(const double	Tp2OPL_)		{ _Tp2OPL	=	Tp2OPL_;  }
	void	EnableTpL(const bool	EnableTpL_)		{ _EnableTpL	=	EnableTpL_;  }
	//void	AddTpL(const bool	AddTpL_)		{ _AddTpL	=	AddTpL_;  }
	//void	Tp2Bid(const double	Tp2Bid_)		{ _Tp2Bid	=	Tp2Bid_;  }
	//void	MinusTpL(const bool	MinusTpL_)		{ _MinusTpL	=	MinusTpL_;  }
	//void	Sl2OPL(const double	Sl2OPL_)		{ _Sl2OPL	=	Sl2OPL_;  }
	void	EnableSlL(const bool	EnableSlL_)		{ _EnableSlL	=	EnableSlL_;  }
	//void	AddSlL(const bool	AddSlL_)		{ _AddSlL	=	AddSlL_;  }
	//void	Sl2Ask(const double	Sl2Ask_)		{ _Sl2Ask	=	Sl2Ask_;  }
	//void	MinusSlL(const bool	MinusSlL_)		{ _MinusSlL	=	MinusSlL_;  }
	void	SwapL(const double	SwapL_)		{ _SwapL	=	SwapL_;  }
	void	SymbolN(const string	SymbolN_)		{ _SymbolN	=	SymbolN_;  }
	void	EnableGrid(const bool	EnableGrid_)		{ _EnableGrid	=	EnableGrid_;  }
	//void	PlusGrid(const bool	PlusGrid_)		{ _PlusGrid	=	PlusGrid_;  }
	void	GridPips(const short	GridPips_)		{ _GridPips	=	GridPips_;  }
	//void	MinusGrid(const bool	MinusGrid_)		{ _MinusGrid	=	MinusGrid_;  }
	void	EnableRetrace(const bool	EnableRetrace_)		{ _EnableRetrace	=	EnableRetrace_;  }
	//void	PlusRetrace(const bool	PlusRetrace_)		{ _PlusRetrace	=	PlusRetrace_;  }
	void	RetracePips(const short	RetracePips_)		{ _RetracePips	=	RetracePips_;  }
	//void	MinusRetrace(const bool	MinusRetrace_)		{ _MinusRetrace	=	MinusRetrace_;  }
	void	SwapS(const double	SwapS_)		{ _SwapS	=	SwapS_;  }
	void	SingularModeS(const bool	SingularModeS_)		{ _SingularModeS	=	SingularModeS_;  }
	void	TradeModeS(const bool	TradeModeS_);
	//void	TradeModeS(const bool	TradeModeS_)		{ _TradeModeS	=	TradeModeS_; if (_TradeModeS) {_Tp2OPS=_TpPips;_Sl2OPS=_SlPips;} }
	void	GridModeS(const bool	GridModeS_)		{ _GridModeS	=	GridModeS_;  }
	void	RetraceModeS(const bool	RetraceModeS_)		{ _RetraceModeS	=	RetraceModeS_;  }
	void	OtherModeS(const bool	OtherModeS_)		{ _OtherModeS	=	OtherModeS_;  }
	//void	PlusOrdS(const bool	PlusOrdS_)		{ _PlusOrdS	=	PlusOrdS_;  }
	void	OrdCntS(const int	OrdCntS_)		{ _OrdCntS	=	OrdCntS_;  }
	//void	MinusOrdS(const bool	MinusOrdS_)		{ _MinusOrdS	=	MinusOrdS_;  }
	//void	ProfitSMinus(const double	ProfitSMinus_)		{ _ProfitSMinus	=	ProfitSMinus_;  }
	//void	MinusMaxOrdS(const bool	MinusMaxOrdS_)		{ _MinusMaxOrdS	=	MinusMaxOrdS_;  }
	//void	ProfitSMinusMax(const double	ProfitSMinusMax_)		{ _ProfitSMinusMax	=	ProfitSMinusMax_;  }
	void	LotsS(const double	LotsS_)		{ _LotsS	=	LotsS_;  }
	//void	ClosePositiveS(const bool	ClosePositiveS_)		{ _ClosePositiveS	=	ClosePositiveS_;  }
	//void	ProfitS(const double	ProfitS_)		{ _ProfitS	=	ProfitS_;  }
	//void	CloseNegativeS(const bool	CloseNegativeS_)		{ _CloseNegativeS	=	CloseNegativeS_;  }
	//void	MaxProfitS(const double	MaxProfitS_)		{ _MaxProfitS	=	MaxProfitS_;  }
	//void	MinProfitS(const double	MinProfitS_)		{ _MinProfitS	=	MinProfitS_;  }
	//void	CloseS(const bool	CloseS_)		{ _CloseS	=	CloseS_;  }
	//void	Tp2OPS(const double	Tp2OPS_)		{ _Tp2OPS	=	Tp2OPS_;  }
	void	EnableTpS(const bool	EnableTpS_)		{ _EnableTpS	=	EnableTpS_;  }
	//void	AddTpS(const bool	AddTpS_)		{ _AddTpS	=	AddTpS_;  }
	//void	Tp2Ask(const double	Tp2Ask_)		{ _Tp2Ask	=	Tp2Ask_;  }
	//void	MinusTpS(const bool	MinusTpS_)		{ _MinusTpS	=	MinusTpS_;  }
	//void	Sl2OPS(const double	Sl2OPS_)		{ _Sl2OPS	=	Sl2OPS_;  }
	void	EnableSlS(const bool	EnableSlS_)		{ _EnableSlS	=	EnableSlS_;  }
	//void	AddSlS(const bool	AddSlS_)		{ _AddSlS	=	AddSlS_;  }
	//void	Sl2Bid(const double	Sl2Bid_)		{ _Sl2Bid	=	Sl2Bid_;  }
	//void	MinusSlS(const bool	MinusSlS_)		{ _MinusSlS	=	MinusSlS_;  }
	//void	Profit(const double	Profit_)		{ _Profit	=	Profit_;  }
	//void	CloseLS(const bool	CloseLS_)		{ _CloseLS	=	CloseLS_;  }
	//void	Spread(const double	Spread_)		{ _Spread	=	Spread_;  }
	void	ADR(const ushort	ADR_)		{ _ADR	=	ADR_;  }
	//void	CDR(const ushort	CDR_)		{ _CDR	=	CDR_;  }
	/*void	PIN1(const char	PIN1_)		{ _PIN1	=	PIN1_;  }
	void	PIN2(const char	PIN2_)		{ _PIN2	=	PIN2_;  }
	void	PIN3(const char	PIN3_)		{ _PIN3	=	PIN3_;  }
	void	PIN4(const char	PIN4_)		{ _PIN4	=	PIN4_;  }
	void	PIN5(const char	PIN5_)		{ _PIN5	=	PIN5_;  }
	void	PIN6(const char	PIN6_)		{ _PIN6	=	PIN6_;  }
	void	PIN7(const char	PIN7_)		{ _PIN7	=	PIN7_;  }
	void	PIN8(const char	PIN8_)		{ _PIN8	=	PIN8_;  }
	void	PIN9(const char	PIN9_)		{ _PIN9	=	PIN9_;  }*/
	
	void  AddOrderL(const ulong ticket, const string comment="");
	void  AddOrderS(const ulong ticket, const string comment="");

	void  Add2OrdersL(const ulong ticket, const string comment="");
	void  Add2OrdersS(const ulong ticket, const string comment="");
	void  Add2OrdersGridL(const ulong ticket, const string comment="");
	void  Add2OrdersGridS(const ulong ticket, const string comment="");
	void  Add2OrdersRetraceL(const ulong ticket, const string comment="");
	void  Add2OrdersRetraceS(const ulong ticket, const string comment="");
	//void  Add2OrdersL(const ulong ticket, const string comment="")         { _OrdersAllL.Add(add2Orders(_OrdersL, ticket, comment)); COrder *order = _OrdersAllL.GetNodeAtIndex(_OrdCntL-1);Print("_OrdersAllL.ticket==", order.getTicket());}
	//void  Add2OrdersS(const ulong ticket, const string comment="")         { _OrdersAllS.Add(add2Orders(_OrdersS, ticket, comment)); }
	//void  Add2OrdersGridL(const ulong ticket, const string comment="")     { _OrdersAllL.Add(add2Orders(_OrdersGridL, ticket, comment)); }
	//void  Add2OrdersGridS(const ulong ticket, const string comment="")     { _OrdersAllS.Add(add2Orders(_OrdersGridS, ticket, comment)); }
	//void  Add2OrdersRetraceL(const ulong ticket, const string comment="")  { _OrdersAllL.Add(add2Orders(_OrdersRetraceL, ticket, comment)); }
	//void  Add2OrdersRetraceS(const ulong ticket, const string comment="")  { _OrdersAllS.Add(add2Orders(_OrdersRetraceS, ticket, comment)); }
	void  DeleteFromOrdersL(const ulong ticket);
	void  DeleteFromOrdersS(const ulong ticket);
	void  DeleteFromOrdersGridL(const ulong ticket);
	void  DeleteFromOrdersGridS(const ulong ticket);
	void  DeleteFromOrdersRetraceL(const ulong ticket);
	void  DeleteFromOrdersRetraceS(const ulong ticket);
	/*
   void  DeleteFromOrdersL(const ulong ticket)         { deleteFromOrders(_OrdersL, ticket);         deleteFromOrders(_OrdersAllL, ticket); }
	void  DeleteFromOrdersS(const ulong ticket)         { deleteFromOrders(_OrdersS, ticket);         deleteFromOrders(_OrdersAllS, ticket); }
	void  DeleteFromOrdersGridL(const ulong ticket)     { deleteFromOrders(_OrdersGridL, ticket);     deleteFromOrders(_OrdersAllL, ticket); }
	void  DeleteFromOrdersGridS(const ulong ticket)     { deleteFromOrders(_OrdersGridS, ticket);     deleteFromOrders(_OrdersAllS, ticket); }
	void  DeleteFromOrdersRetraceL(const ulong ticket)  { deleteFromOrders(_OrdersRetraceL, ticket);  deleteFromOrders(_OrdersAllL, ticket); }
	void  DeleteFromOrdersRetraceS(const ulong ticket)  { deleteFromOrders(_OrdersRetraceS, ticket);  deleteFromOrders(_OrdersAllS, ticket); }
	*/
	//void Buy() {}
	void  refresh(void);
	void  refreshTotalProfit(void);
	void  refreshL(void);
	void  refreshS(void);
	int   getCountL(void)         { return(_OrdersL.Total()); }
	int   getCountS(void)         { return(_OrdersS.Total()); }
	int   getCountGridL(void)     { return(_OrdersGridL.Total()); }
	int   getCountGridS(void)     { return(_OrdersGridS.Total()); }
	int   getCountRetraceL(void)  { return(_OrdersRetraceL.Total()); }
	int   getCountRetraceS(void)  { return(_OrdersRetraceS.Total()); }
	ulong getTicketL(void);
	ulong getTicketS(void);
};

CRowInfo::CRowInfo() {
   _OrdersL = new CList;
   _OrdersS = new CList;
   _OrdersGridL = new CList;
   _OrdersGridS = new CList;
   _OrdersRetraceL = new CList;
   _OrdersRetraceS = new CList;
   _OrdersAllL = new CList;
   _OrdersAllS = new CList;
}
CRowInfo::CRowInfo(const string showName, const string prefix, const string surfix, const int pinCount) {
   _Select = false;
   _SymbolN = showName;
   _SymbolNm = prefix+showName+surfix;
   _symbolInfo.Name(_SymbolNm);

   _SwapL = _symbolInfo.SwapLong();
   _SwapS = _symbolInfo.SwapShort();
   
   
   _OrdersL = new CList;
   _OrdersS = new CList;
   _OrdersGridL = new CList;
   _OrdersGridS = new CList;
   _OrdersRetraceL = new CList;
   _OrdersRetraceS = new CList;
   _OrdersAllL = new CList;
   _OrdersAllS = new CList;
   
   ArrayResize(_Pins, pinCount);
   ArrayInitialize(_Pins, 9);
   
}

CRowInfo::~CRowInfo() {
   delete _OrdersL;
   delete _OrdersS;
   delete _OrdersGridL;
   delete _OrdersGridS;
   delete _OrdersRetraceL;
   delete _OrdersRetraceS;
   delete _OrdersAllL;
   delete _OrdersAllS;
}
void CRowInfo::AddOrderL(const ulong ticket, const string comment="") {
         if (_GridModeL) Add2OrdersGridL(ticket, comment);
   else  if (_RetraceModeL) Add2OrdersRetraceL(ticket, comment);
   else  Add2OrdersL(ticket, comment);
}
void CRowInfo::AddOrderS(const ulong ticket, const string comment="") {
         if (_GridModeS) Add2OrdersGridS(ticket, comment);
   else  if (_RetraceModeS) Add2OrdersRetraceS(ticket, comment);
   else  Add2OrdersS(ticket, comment);
}

void CRowInfo::Add2OrdersL(const ulong ticket, const string comment="") {
   COrder *order = new COrder;
   order.setTicket(ticket);
   order.Select();
   //order.StoreState();
   //order.Description(comment);
   //order.PairName(order.Symbol());
   //order.StopLoss(order.StopLoss());
   //order.TakeProfit(order.TakeProfit());
   //order.Volume(order.VolumeCurrent());
   /*
   Print("ticket == ", ticket);
   Print("order.ticket == ", order.getTicket());
   Print("order.Volume == ", order.Volume());
   Print("order.PairName == ", order.PairName());
   Print("order.OrderType == ", order.PositionType());
   Print("order.PriceOpen == ", order.PriceOpen());
   Print("order.StopLoss == ", order.StopLoss());
   Print("order.TakeProfit == ", order.TakeProfit());
   */
   _OrdersL.Add(order);
   _OrdersAllL.Add(order);
   refreshL();
   refreshTotalProfit();
}

void CRowInfo::Add2OrdersS(const ulong ticket, const string comment="") {
   COrder *order = new COrder;
   order.setTicket(ticket);
   order.Select();
   _OrdersS.Add(order);
   _OrdersAllS.Add(order);
   refreshS();
   refreshTotalProfit();
}

void CRowInfo::Add2OrdersGridL(const ulong ticket, const string comment="") {
   COrder *order = new COrder;
   order.setTicket(ticket);
   order.Select();
   _OrdersGridL.Add(order);
   _OrdersAllL.Add(order);
   refreshL();
   refreshTotalProfit();
}

void CRowInfo::Add2OrdersGridS(const ulong ticket, const string comment="") {
   COrder *order = new COrder;
   order.setTicket(ticket);
   order.Select();
   _OrdersGridS.Add(order);
   _OrdersAllS.Add(order);
   refreshS();
   refreshTotalProfit();
}

void CRowInfo::Add2OrdersRetraceL(const ulong ticket,const string comment="") {
   COrder *order = new COrder;
   order.setTicket(ticket);
   order.Select();
   _OrdersRetraceL.Add(order);
   _OrdersAllL.Add(order);
   refreshL();
   refreshTotalProfit();
}

void CRowInfo::Add2OrdersRetraceS(const ulong ticket,const string comment="") {
   COrder *order = new COrder;
   order.setTicket(ticket);
   order.Select();
   _OrdersRetraceS.Add(order);
   _OrdersAllS.Add(order);
   refreshS();
   refreshTotalProfit();
}

void  CRowInfo::DeleteFromOrdersL(const ulong ticket) {
   int cnt = _OrdersL.Total();
   ulong ticket__;
   COrder *order;
   bool found = false;
   for (int i=0; i<cnt; i++) {
      order = _OrdersL.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersL.Delete(i);found=true;}
   }
   
   //if (!found) return;
   cnt = _OrdersAllL.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersAllL.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersAllL.Delete(i);found=true;}
   }
   
   refreshL();
   refreshTotalProfit();
   //return false;
}

void  CRowInfo::DeleteFromOrdersS(const ulong ticket) {
   int cnt = _OrdersS.Total();
   ulong ticket__;
   COrder *order;
   bool found = false;
   for (int i=0; i<cnt; i++) {
      order = _OrdersS.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersS.Delete(i);found=true;}
   }
   
   //if (!found) return;
   cnt = _OrdersAllS.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersAllS.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersAllS.Delete(i);found=true;}
   }
   refreshS();
   refreshTotalProfit();
   //return false;
}

void  CRowInfo::DeleteFromOrdersGridL(const ulong ticket) {
   int cnt = _OrdersGridL.Total();
   ulong ticket__;
   COrder *order;
   bool found = false;
   for (int i=0; i<cnt; i++) {
      order = _OrdersGridL.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersGridL.Delete(i);found=true;}
   }
   
   //if (!found) return;
   cnt = _OrdersAllL.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersAllL.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersAllL.Delete(i);found=true;}
   }
   refreshL();
   refreshTotalProfit();
}

void  CRowInfo::DeleteFromOrdersGridS(const ulong ticket) {
   int cnt = _OrdersGridS.Total();
   ulong ticket__;
   COrder *order;
   bool found = false;
   for (int i=0; i<cnt; i++) {
      order = _OrdersGridS.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersGridS.Delete(i);found=true;}
   }
   
   //if (!found) return;
   cnt = _OrdersAllS.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersAllS.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersAllS.Delete(i);found=true;}
   }
   refreshS();
   refreshTotalProfit();
}

void  CRowInfo::DeleteFromOrdersRetraceL(const ulong ticket) {
   int cnt = _OrdersRetraceL.Total();
   ulong ticket__;
   COrder *order;
   bool found = false;
   for (int i=0; i<cnt; i++) {
      order = _OrdersRetraceL.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersRetraceL.Delete(i);found=true;}
   }
   
   //if (!found) return;
   cnt = _OrdersAllL.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersAllL.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersAllL.Delete(i);found=true;}
   }
   refreshL();
   refreshTotalProfit();
   //return false;
}

void  CRowInfo::DeleteFromOrdersRetraceS(const ulong ticket) {
   int cnt = _OrdersRetraceS.Total();
   ulong ticket__;
   COrder *order;
   bool found = false;
   for (int i=0; i<cnt; i++) {
      order = _OrdersRetraceS.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersRetraceS.Delete(i);found=true;}
   }
   
   //if (!found) return;
   cnt = _OrdersAllS.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersAllS.GetNodeAtIndex(i);
      ticket__ = order.getTicket();
      if (ticket == ticket__) {_OrdersAllS.Delete(i);found=true;}
   }
   refreshS();
   refreshTotalProfit();
   //return false;
}

ulong CRowInfo::getTicketL(void) {
   if (_GridModeL) {
      COrder *order = _OrdersGridL.GetNodeAtIndex(_OrdCntL-1);
      return order.getTicket();
   }
   if (_RetraceModeL) {
      COrder *order = _OrdersRetraceL.GetNodeAtIndex(_OrdCntL-1);
      return order.getTicket();
   }
   COrder *order = _OrdersL.GetNodeAtIndex(_OrdCntL-1);
   return order.getTicket();
}
ulong CRowInfo::getTicketS(void) {
   if (_GridModeS) {
      COrder *order = _OrdersGridS.GetNodeAtIndex(_OrdCntS-1);
      return order.getTicket();
   }
   if (_RetraceModeS) {
      COrder *order = _OrdersRetraceS.GetNodeAtIndex(_OrdCntS-1);
      return order.getTicket();
   }
   COrder *order = _OrdersS.GetNodeAtIndex(_OrdCntS-1);
   return order.getTicket();
}
void CRowInfo::SingularModeL(const bool SingularModeL_) {
   _SingularModeL	=	SingularModeL_;
}

void CRowInfo::TradeModeL(const bool TradeModeL_) {
   _TradeModeL	=	TradeModeL_;
   //refreshL();
}
void CRowInfo::TradeModeS(const bool TradeModeS_) {
   _TradeModeS	=	TradeModeS_;
   //refreshS();
}
void CRowInfo::GridModeL(const bool GridModeL_) {
   _GridModeL	=	GridModeL_;
   //if (_GridModeL&&_SingularModeL) _OrdCntL=_OrdersGridL.Total();
}
void CRowInfo::RetraceModeL(const bool	RetraceModeL_) {
   _RetraceModeL	=	RetraceModeL_;
   //if (_RetraceModeL&&_SingularModeL) _OrdCntL=_OrdersRetraceL.Total();
}
void CRowInfo::OtherModeL(const bool OtherModeL_) {
   _OtherModeL	=	OtherModeL_;
   //if (_OtherModeL&&_SingularModeL) _OrdCntL=_OrdersL.Total();
}

void CRowInfo::refresh(void) {
   refreshL();
   refreshS();
   refreshTotalProfit();
}

void CRowInfo::refreshTotalProfit(void) {
   _MaxProfit = 0.0;
	_MinProfit = 0.0;
	_Profit = 0.0;
	int cnt = _OrdersGridL.Total();
	COrder *order;
   for (int i=0; i<cnt; i++) {
      order = _OrdersGridL.GetNodeAtIndex(i);
      _Profit += order.ProfitCurrent();
   }
   
   cnt = _OrdersGridS.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersGridS.GetNodeAtIndex(i);
      _Profit += order.ProfitCurrent();
   }
   
   cnt = _OrdersRetraceL.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersRetraceL.GetNodeAtIndex(i);
      _Profit += order.ProfitCurrent();
   }
   
   cnt = _OrdersRetraceS.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersRetraceS.GetNodeAtIndex(i);
      _Profit += order.ProfitCurrent();
   }
   
   cnt = _OrdersL.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersL.GetNodeAtIndex(i);
      _Profit += order.ProfitCurrent();
   }
   
   cnt = _OrdersS.Total();
   for (int i=0; i<cnt; i++) {
      order = _OrdersS.GetNodeAtIndex(i);
      _Profit += order.ProfitCurrent();
   }
}

void CRowInfo::refreshL(void) {
   _ProfitLMinus = 0.0;
   _ProfitLMinusMax = 0.0;
	_MaxProfitL = 0.0;
	_MinProfitL = 0.0;
	
	// 交易模式
	if (_TradeModeL) {
      _OrdCntL = 1;
      //_LotsL = _InitLotSize;
      _ProfitL = _LotsL*_TpPips*10;
      _Tp2OPL = 0.0;
      _Tp2Bid = _TpPips;
      _Sl2OPL = 0.0;
      _Sl2Ask = _SlPips;
	   return;
	}

   _OrdCntL = 0;
   _LotsL = 0.0;
   _Tp2OPL = 0.0;
	_Tp2Bid = 0.0;
	_Sl2OPL = 0.0;
	_Sl2Ask = 0.0;
   _ProfitL = 0.0;
   // 单数模式
   if (_SingularModeL) {
      int index = _OrdCntL - 1;
		if (_GridModeL && 0 < _OrdersGridL.Total()) {
		   COrder *order = _OrdersGridL.GetNodeAtIndex(index);
		   _LotsL = order.Volume();
		   _ProfitL = order.ProfitCurrent();
		   _Tp2OPL = order.Pips_Tp2OpenPrice();
      	_Tp2Bid = order.Pips4Tp2CurrentPrice();
      	_Sl2OPL = order.Pips_Sl2OpenPrice();
      	_Sl2Ask = order.Pips4Sl2CurrentPrice();
		} else
		if (_RetraceModeL && 0 < _OrdersRetraceL.Total()) {
		   COrder *order = _OrdersRetraceL.GetNodeAtIndex(index);
		   _LotsL = order.Volume();
		   _ProfitL = order.ProfitCurrent();
		   _Tp2OPL = order.Pips_Tp2OpenPrice();
      	_Tp2Bid = order.Pips4Tp2CurrentPrice();
      	_Sl2OPL = order.Pips_Sl2OpenPrice();
      	_Sl2Ask = order.Pips4Sl2CurrentPrice();
		} else
		if (_OtherModeL && 0 < _OrdersL.Total()) {
		   COrder *order = _OrdersL.GetNodeAtIndex(index);
		   _LotsL = order.Volume();
		   _ProfitL = order.ProfitCurrent();
		   _Tp2OPL = order.Pips_Tp2OpenPrice();
      	_Tp2Bid = order.Pips4Tp2CurrentPrice();
      	_Sl2OPL = order.Pips_Sl2OpenPrice();
      	_Sl2Ask = order.Pips4Sl2CurrentPrice();
		}
		return;
   }
   // 复数模式
   if (_GridModeL) {
      int cnt = _OrdersGridL.Total();
      _OrdCntL += cnt;
      COrder *order;
      for (int i=0; i<cnt; i++) {
         order = _OrdersGridL.GetNodeAtIndex(i);
         _LotsL   += order.Volume();
         _ProfitL += order.ProfitCurrent();
		   _Tp2OPL  += order.Pips_Tp2OpenPrice();
      	_Tp2Bid  += order.Pips4Tp2CurrentPrice();
      	_Sl2OPL  += order.Pips_Sl2OpenPrice();
      	_Sl2Ask  += order.Pips4Sl2CurrentPrice();
      }
   }
   
   if (_RetraceModeL) {
      int cnt = _OrdersRetraceL.Total();
      _OrdCntL += cnt;
      COrder *order;
      for (int i=0; i<cnt; i++) {
         order = _OrdersRetraceL.GetNodeAtIndex(i);
         _LotsL   += order.Volume();
         _ProfitL += order.ProfitCurrent();
		   _Tp2OPL  += order.Pips_Tp2OpenPrice();
      	_Tp2Bid  += order.Pips4Tp2CurrentPrice();
      	_Sl2OPL  += order.Pips_Sl2OpenPrice();
      	_Sl2Ask  += order.Pips4Sl2CurrentPrice();
      }
   }
   
   if (_OtherModeL) {
      int cnt = _OrdersL.Total();
      _OrdCntL += cnt;
      COrder *order;
      for (int i=0; i<cnt; i++) {
         order = _OrdersL.GetNodeAtIndex(i);
         _LotsL   += order.Volume();
         _ProfitL += order.ProfitCurrent();
		   _Tp2OPL  += order.Pips_Tp2OpenPrice();
      	_Tp2Bid  += order.Pips4Tp2CurrentPrice();
      	_Sl2OPL  += order.Pips_Sl2OpenPrice();
      	_Sl2Ask  += order.Pips4Sl2CurrentPrice();
      }
   }
}

void CRowInfo::refreshS(void) {
   _ProfitSMinus = 0.0;
   _ProfitSMinusMax = 0.0;
	_MaxProfitS = 0.0;
	_MinProfitS = 0.0;
	
	// 交易模式
	if (_TradeModeS) {
      _OrdCntS = 1;
      //_LotsS = _InitLotSize;
      _ProfitS = _LotsS*_TpPips*10;
      _Tp2OPS = 0.0;
      _Tp2Ask = _TpPips;
      _Sl2OPS = 0.0;
      _Sl2Bid = _SlPips;
      return;
   }

   _OrdCntS = 0;
   _LotsS = 0.0;
   _ProfitS = 0.0;
	_Tp2OPS = 0.0;
	_Tp2Ask = 0.0;
	_Sl2OPS = 0.0;
	_Sl2Bid = 0.0;
   // 单数模式
   if (_SingularModeS) {
      int index = _OrdCntS - 1;
		if (_GridModeS && 0 < _OrdersGridS.Total()) {
		   COrder *order = _OrdersGridS.GetNodeAtIndex(index);
		   _LotsS = order.Volume();
		   _ProfitS = order.ProfitCurrent();
		   _Tp2OPS = order.Pips_Tp2OpenPrice();
      	_Tp2Ask = order.Pips4Tp2CurrentPrice();
      	_Sl2OPS = order.Pips_Sl2OpenPrice();
      	_Sl2Bid = order.Pips4Sl2CurrentPrice();
		} else
		if (_RetraceModeS && 0 < _OrdersRetraceS.Total()) {
		   COrder *order = _OrdersRetraceS.GetNodeAtIndex(index);
		   _LotsS = order.Volume();
		   _ProfitS = order.ProfitCurrent();
		   _Tp2OPS = order.Pips_Tp2OpenPrice();
      	_Tp2Ask = order.Pips4Tp2CurrentPrice();
      	_Sl2OPS = order.Pips_Sl2OpenPrice();
      	_Sl2Bid = order.Pips4Sl2CurrentPrice();
		} else
		if (_OtherModeS && 0 < _OrdersS.Total()) {
		   COrder *order = _OrdersS.GetNodeAtIndex(index);
		   _LotsS = order.Volume();
		   _ProfitS = order.ProfitCurrent();
		   _Tp2OPS = order.Pips_Tp2OpenPrice();
      	_Tp2Ask = order.Pips4Tp2CurrentPrice();
      	_Sl2OPS = order.Pips_Sl2OpenPrice();
      	_Sl2Bid = order.Pips4Sl2CurrentPrice();
		}
		return;
   }
   // 复数模式
   if (_GridModeS) {
      int cnt = _OrdersGridS.Total();
      _OrdCntS += cnt;
      COrder *order;
      for (int i=0; i<cnt; i++) {
         order = _OrdersGridS.GetNodeAtIndex(i);
         _LotsS   += order.Volume();
         _ProfitS += order.ProfitCurrent();
		   _Tp2OPS  += order.Pips_Tp2OpenPrice();
      	_Tp2Ask  += order.Pips4Tp2CurrentPrice();
      	_Sl2OPS  += order.Pips_Sl2OpenPrice();
      	_Sl2Bid  += order.Pips4Sl2CurrentPrice();
      }
   }
   
   if (_RetraceModeS) {
      int cnt = _OrdersRetraceS.Total();
      _OrdCntS += cnt;
      COrder *order;
      for (int i=0; i<cnt; i++) {
         order = _OrdersRetraceS.GetNodeAtIndex(i);
         _LotsS   += order.Volume();
         _ProfitS += order.ProfitCurrent();
		   _Tp2OPS  += order.Pips_Tp2OpenPrice();
      	_Tp2Ask  += order.Pips4Tp2CurrentPrice();
      	_Sl2OPS  += order.Pips_Sl2OpenPrice();
      	_Sl2Bid  += order.Pips4Sl2CurrentPrice();
      }
   }
   
   if (_OtherModeS) {
      int cnt = _OrdersS.Total();
      _OrdCntS += cnt;
      COrder *order;
      for (int i=0; i<cnt; i++) {
         order = _OrdersS.GetNodeAtIndex(i);
         _LotsS   += order.Volume();
         _ProfitS += order.ProfitCurrent();
		   _Tp2OPS  += order.Pips_Tp2OpenPrice();
      	_Tp2Ask  += order.Pips4Tp2CurrentPrice();
      	_Sl2OPS  += order.Pips_Sl2OpenPrice();
      	_Sl2Bid  += order.Pips4Sl2CurrentPrice();
      }
   }
}

/*
double CRowInfo::ProfitLMinus(void) const { return(_ProfitLMinus); }
double CRowInfo::ProfitLMinusMax(void) const { return(_ProfitLMinusMax); }

int CRowInfo::OrdCntL(void) const {
   //return 0.0;
   if (_SingularModeL) return(_OrdCntL);
   int cnt = 0;
   if (_GridModeL) { cnt = cnt + _OrdersGridL.Total(); }
   if (_RetraceModeL) cnt += _OrdersRetraceL.Total();
   if (_OtherModeL) cnt += _OrdersL.Total();
   return (cnt);
}
double getLot(CList *list,int index) {
   if (0 == list.Total()) {
      return 0.0;
   }
   Print(7);
   COrder *order = list.GetNodeAtIndex(index);
   Print("order.Volume()"+order.Volume());
   Print("order.Ticket()"+order.Ticket());
   return order.Volume();
}

double countLot(CList *list) {
   int cnt = list.Total();
   double lots = 0.0;
   COrder *order;
   for (int i=0; i<cnt; i++) {
      order = list.GetNodeAtIndex(i);
      lots += order.Volume();
   }
   
   return lots;
}

double CRowInfo::LotsL(void) const {
   // 单数模式
   if (_SingularModeL) {
      if (_GridModeL) return(getLot(_OrdersGridL, _OrdCntL-1));
      if (_RetraceModeL) return(getLot(_OrdersRetraceL, _OrdCntL-1));
      if (_OtherModeL) return(getLot(_OrdersL, _OrdCntL-1));
      return(0.0);
   }
   // 复数模式
   double lots = 0.0;
   if (_GridModeL) lots += countLot(_OrdersGridL);
   if (_RetraceModeL) lots += countLot(_OrdersRetraceL);
   if (_OtherModeL) lots += countLot(_OrdersL);
   return(lots);
}

double getProfit(CList *list,int index) {
   if (0 == list.Total()) {
      return 0.0;
   }
   COrder *order = list.GetNodeAtIndex(index);
   return order.ProfitCurrent();
}

double countProfit(CList *list) {
   int cnt = list.Total();
   double profit = 0.0;
   COrder *order;
   for (int i=0; i<cnt; i++) {
      order = list.GetNodeAtIndex(i);
      profit += order.ProfitCurrent();
   }
   
   return profit;
}

double CRowInfo::ProfitL(void) const {
   // 单数模式
   if (_SingularModeL) {
      if (_GridModeL) return(getProfit(_OrdersGridL, _OrdCntL-1));
      if (_RetraceModeL) return(getProfit(_OrdersRetraceL, _OrdCntL-1));
      if (_OtherModeL) return(getProfit(_OrdersL, _OrdCntL-1));
      return(0.0);
   }
   // 复数模式
   double profit = 0.0;
   if (_GridModeL) profit += countProfit(_OrdersGridL);
   if (_RetraceModeL) profit += countProfit(_OrdersRetraceL);
   if (_OtherModeL) profit += countProfit(_OrdersL);
   return(profit);
}
double CRowInfo::MaxProfitL(void) const { return(_MaxProfitL); }
double CRowInfo::MinProfitL(void) const { return(_MinProfitL); }
double CRowInfo::Tp2OPL(void) const {
   //return(_Tp2OPL);
   return(0.0);
}
double CRowInfo::Tp2Bid(void) const {
   //return(_Tp2Bid);
   return(0.0);
}
double CRowInfo::Sl2OPL(void) const {
   //return(_Sl2OPL);
   return(0.0);
}
double CRowInfo::Sl2Ask(void) const {
   //return(_Sl2Ask);
   return(0.0);
}
*/
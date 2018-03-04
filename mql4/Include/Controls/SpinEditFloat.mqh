//+------------------------------------------------------------------+
//|                                                     SpinEdit.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "WndContainer.mqh"
#include "Edit.mqh"
#include "BmpButton.mqh"
//+------------------------------------------------------------------+
//| Resources                                                        |
//+------------------------------------------------------------------+
#resource "res\\SpinInc.bmp"
#resource "res\\SpinDec.bmp"
//+------------------------------------------------------------------+
//| Class CSpinEditFloat                                                  |
//| Usage: class that implements the "Up-Down" control               |
//+------------------------------------------------------------------+
class CSpinEditFloat: public CWndContainer {
private:
	//--- dependent controls
	CEdit m_edit;                // the entry field object
	CBmpButton m_inc;                 // the "Increment button" object
	CBmpButton m_dec;                 // the "Decrement button" object
	//--- adjusted parameters
	float m_min_value;           // minimum value
	float m_max_value;           // maximum value
	//--- state
	float m_value;               // current value

public:
	CSpinEditFloat(void);
	~CSpinEditFloat(void);
	//--- create
	virtual bool Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2);
	//--- chart event handler
	virtual bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
	//--- set up
	float MinValue(void) const {
		return (m_min_value);
	}
	void MinValue(const float value);
	float MaxValue(void) const {
		return (m_min_value);
	}
	void MaxValue(const float value);
	//--- state
	float Value(void) const {
		return (m_value);
	}
	bool Value(float value);
	//--- methods for working with files
	virtual bool Save(const int file_handle);
	virtual bool Load(const int file_handle);

protected:
	//--- create dependent controls
	virtual bool CreateEdit(void);
	virtual bool CreateInc(void);
	virtual bool CreateDec(void);
	//--- handlers of the dependent controls events
	virtual bool OnClickInc(void);
	virtual bool OnClickDec(void);
	//--- internal event handlers
	virtual bool OnChangeValue(void);
};
//+------------------------------------------------------------------+
//| Common handler of chart events                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN (CSpinEditFloat)
   ON_EVENT(ON_CLICK,m_inc,OnClickInc)
   ON_EVENT(ON_CLICK,m_dec,OnClickDec)
EVENT_MAP_END(CWndContainer)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSpinEditFloat::CSpinEditFloat(void) :  m_min_value(0.0),
                              m_max_value(0.0),
                              m_value(0.0)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSpinEditFloat::~CSpinEditFloat(void) {
}
//+------------------------------------------------------------------+
//| Create a control                                                 |
//+------------------------------------------------------------------+
bool CSpinEditFloat::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2) {
//--- check height
	if (y2 - y1 < CONTROLS_SPIN_MIN_HEIGHT)
		return (false);
//--- call method of the parent class
	if (!CWndContainer::Create(chart, name, subwin, x1, y1, x2, y2))
		return (false);
//--- create dependent controls
	if (!CreateEdit())
		return (false);
	if (!CreateInc())
		return (false);
	if (!CreateDec())
		return (false);
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Set current value                                                |
//+------------------------------------------------------------------+
bool CSpinEditFloat::Value(float value) {
//--- check value
	if (value < m_min_value)
		value = m_min_value;
	if (value > m_max_value)
		value = m_max_value;
//--- if value was changed
	if (m_value != value) {
		m_value = value;
		//--- call virtual handler
		return (OnChangeValue());
	}
//--- value has not been changed
	return (false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSpinEditFloat::Save(const int file_handle) {
//--- check
	if (file_handle == INVALID_HANDLE)
		return (false);
//---
	FileWriteFloat(file_handle, m_value);
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSpinEditFloat::Load(const int file_handle) {
//--- check
	if (file_handle == INVALID_HANDLE)
		return (false);
//---
	if (!FileIsEnding(file_handle))
		Value(FileReadFloat(file_handle));
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Set minimum value                                                |
//+------------------------------------------------------------------+
void CSpinEditFloat::MinValue(const float value) {
//--- if value was changed
	if (m_min_value != value) {
		m_min_value = value;
		//--- adjust the edit value
		Value(m_value);
	}
}
//+------------------------------------------------------------------+
//| Set maximum value                                                |
//+------------------------------------------------------------------+
void CSpinEditFloat::MaxValue(const float value) {
//--- if value was changed
	if (m_max_value != value) {
		m_max_value = value;
		//--- adjust the edit value
		Value(m_value);
	}
}
//+------------------------------------------------------------------+
//| Create the edit field                                            |
//+------------------------------------------------------------------+
bool CSpinEditFloat::CreateEdit(void) {
//--- create
	if (!m_edit.Create(m_chart_id, m_name + "Edit", m_subwin, 0, 0, Width(), Height()))
		return (false);
	if (!m_edit.Text(""))
		return (false);
	if (!m_edit.ReadOnly(true))
		return (false);
	if (!Add(m_edit))
		return (false);
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Create the "Increment" button                                    |
//+------------------------------------------------------------------+
bool CSpinEditFloat::CreateInc(void) {
//--- right align button (try to make equal offsets from top and bottom)
	int x1 = Width() - (CONTROLS_BUTTON_SIZE + CONTROLS_SPIN_BUTTON_X_OFF);
	int y1 = (Height() - 2 * CONTROLS_SPIN_BUTTON_SIZE) / 2;
	int x2 = x1 + CONTROLS_BUTTON_SIZE;
	int y2 = y1 + CONTROLS_SPIN_BUTTON_SIZE;
//--- create
	if (!m_inc.Create(m_chart_id, m_name + "Inc", m_subwin, x1, y1, x2, y2))
		return (false);
	if (!m_inc.BmpNames("::res\\SpinInc.bmp"))
		return (false);
	if (!Add(m_inc))
		return (false);
//--- property
	m_inc.PropFlags(WND_PROP_FLAG_CLICKS_BY_PRESS);
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Create the "Decrement" button                                    |
//+------------------------------------------------------------------+
bool CSpinEditFloat::CreateDec(void) {
//--- right align button (try to make equal offsets from top and bottom)
	int x1 = Width() - (CONTROLS_BUTTON_SIZE + CONTROLS_SPIN_BUTTON_X_OFF);
	int y1 = (Height() - 2 * CONTROLS_SPIN_BUTTON_SIZE) / 2 + CONTROLS_SPIN_BUTTON_SIZE;
	int x2 = x1 + CONTROLS_BUTTON_SIZE;
	int y2 = y1 + CONTROLS_SPIN_BUTTON_SIZE;
//--- create
	if (!m_dec.Create(m_chart_id, m_name + "Dec", m_subwin, x1, y1, x2, y2))
		return (false);
	if (!m_dec.BmpNames("::res\\SpinDec.bmp"))
		return (false);
	if (!Add(m_dec))
		return (false);
//--- property
	m_dec.PropFlags(WND_PROP_FLAG_CLICKS_BY_PRESS);
//--- succeed
	return (true);
}
//+------------------------------------------------------------------+
//| Handler of click on the "increment" button                       |
//+------------------------------------------------------------------+
bool CSpinEditFloat::OnClickInc(void) {
//--- try to increment current value
	return (Value(m_value + 0.01));
}
//+------------------------------------------------------------------+
//| Handler of click on the "decrement" button                       |
//+------------------------------------------------------------------+
bool CSpinEditFloat::OnClickDec(void) {
//--- try to decrement current value
	return (Value(m_value - 0.01));
}
//+------------------------------------------------------------------+
//| Handler of changing current state                                |
//+------------------------------------------------------------------+
bool CSpinEditFloat::OnChangeValue(void) {
//--- copy text to the edit field edit
	m_edit.Text(DoubleToStr(m_value, 2));
//--- send notification
	EventChartCustom(INTERNAL_EVENT, ON_CHANGE, m_id, 0.0, m_name);
//--- handled
	return (true);
}
//+------------------------------------------------------------------+

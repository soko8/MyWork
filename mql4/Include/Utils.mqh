//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
#include <OrderInfo.mqh>
#include <Arrays\List.mqh>
#import "Utils.ex4"
   bool isEqualDouble(double num1, double num2);
   double pips2Price(string symbolName, int pips);
   bool isAuthorized(bool AccountCtrl, int& AuthorizeAccountList[]);
   bool isExpire(bool EnableUseTimeControl, datetime ExpireTime);
   int countOrders(int magicNumber=0, string symbolName=NULL);
   int closeAllOrders(int magicNumber=0, string symbolName=NULL);
   bool isNumber(string number);
   void PressButton(string ctlName);
   bool closeOrderShort(OrderInfo *orderInfo, double lotSize=0.0);
   bool closeOrderLong(OrderInfo *orderInfo, double lotSize=0.0);
   OrderInfo *createOrderLong(double lotSize, int MagicNumber, double sl=0.0, double tp=0.0);
   OrderInfo *createOrderShort(double lotSize, int MagicNumber, double sl=0.0, double tp=0.0);
   void closeOrdersByList(CList *orderList);
#import
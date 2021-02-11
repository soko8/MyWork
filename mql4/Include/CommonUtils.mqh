//+------------------------------------------------------------------+
//|                                                  CommonUtils.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Arrays\List.mqh>
#include <Infos\OrderInfo.mqh>

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


#import "CommonUtils.ex4"
   bool isExpire(datetime ExpireTime, bool EnableUseTimeControl=true);
   string rightAlign (double varToAlign, int numChar, int decimalPoint);
   OrderInfo *createOrderLong(int MagicNumber, double lotSize, string comment="", double slPrice=0.0, double tpPrice=0.0);
   OrderInfo *createOrderShort(int MagicNumber, double lotSize, string comment="", double slPrice=0.0, double tpPrice=0.0);
   bool closeOrderLong(OrderInfo *orderInfo, double lotSize=0.0);
   bool closeOrderShort(OrderInfo *orderInfo, double lotSize=0.0);
   double calculateListTotalProfit(CList *orderList);
   bool closeAllOrdersList(CList *orderList);
   double getListTotalLot(CList *orderList);
   int closeListPositiveProfitOrders(CList *orderList);
   int closeListNegativeProfitOrders(CList *orderList);
   bool TP1Order(OrderInfo *oi, double targetProfit);
   
#import
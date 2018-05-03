//+------------------------------------------------------------------+
//|                                                        Utils.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+
bool isEqualDouble(double num1, double num2) export {

   if( NormalizeDouble(num1-num2, 5) == 0 ) {
      return true;
   }
   
   return false;
}

double pips2Price(string symbolName, int pips) export {
   int vdigits = (int) MarketInfo(symbolName, MODE_DIGITS);
   double vpoint  = MarketInfo(symbolName, MODE_POINT);
   double price = NormalizeDouble(10*vpoint*pips, vdigits);
   return price;
}

bool isAuthorized(bool AccountCtrl, int& AuthorizeAccountList[]) export {
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

bool isExpire(bool EnableUseTimeControl, datetime ExpireTime) export {
   if (EnableUseTimeControl) {
      datetime now = TimeGMT();
      if (ExpireTime < now) {
         Alert("使用过期，请联系作者。邮箱：soko8@sina.com  或者QQ:183947281");
         return true;
      }
   }
   
   return false;
}

int countOrders(int magicNumber=0, string symbolName=NULL) export {
   int orderNumber = 0;
   for (int i = OrdersTotal()-1; 0 <= i; i--) {
      if ( OrderSelect(i, SELECT_BY_POS) ) {
         if ((NULL!=symbolName && OrderSymbol()==symbolName) || (NULL==symbolName)) {
            if ((0!=magicNumber && magicNumber==OrderMagicNumber()) || (0==magicNumber)) {
               orderNumber++;
            }
         }
      }
   }
   
   return orderNumber;
}
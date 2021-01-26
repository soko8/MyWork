//+------------------------------------------------------------------+
//|                                                    EA_Sender.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <FileUtils.mqh>

//--- input parameters
input bool     UsePositiveProfitTrigger=false;
input double   PositiveProfitTargetPercent=7;
//input double   LoopCycleMinutes=120;
input bool     UseNegativeProfitTrigger=false;
input double   NegativeProfitTargetPercent=7;
input string   _______ = "________________________________________________";
input bool     UseTimeTrigger=true;
input string   StartSendHMS_GMT="11:00:00";
input int      ValidOrderCountPeriodBeforeStartSendHMS_Minutes=300;
input string   ________ = "________________________________________________";
input string   SaveSendResultFilePath="D:\\temp\\Result.txt";
input bool     EnableMagicNumberManage=false;
input string   MagicNumbersSeparateBySemicolon="";


bool           isSended = false;
datetime       previousDaiyTime = 0;
int            startSendTimeHour = 0;
int            startSendTimeMinute = 0;
int            startSendTimeSeconds = 0;
string         StartSendHMS = "";
int            diffPickTime = 0;
string         magicNumsStr[];

double         maxEquity = 0.0;
double         minEquity = 0.0;

int OnInit() {
   maxEquity = AccountEquity();
   minEquity = AccountEquity();
   startSendTimeHour = StrToInteger(StringSubstr(StartSendHMS_GMT, 0, 2));
   startSendTimeMinute = StrToInteger(StringSubstr(StartSendHMS_GMT, 3, 2));
   startSendTimeSeconds = StrToInteger(StringSubstr(StartSendHMS_GMT, 6, 2));
   StartSendHMS = StringSubstr(StartSendHMS_GMT, 0, 5);
   diffPickTime = ValidOrderCountPeriodBeforeStartSendHMS_Minutes*60;
   ushort u_sep = StringGetCharacter(";", 0);
   StringSplit(MagicNumbersSeparateBySemicolon, u_sep, magicNumsStr);
   
   EventSetTimer(1);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
}

void OnTick() {}


bool isNewDay() {
   return isNewCycle(previousDaiyTime, iTime(NULL,PERIOD_D1,0));
}

void OnTimer() {
   maxEquity = MathMax(maxEquity, AccountEquity());
   minEquity = MathMin(minEquity, AccountEquity());
   if (isNewDay()) {
      isSended = false;
      previousDaiyTime = iTime(NULL,PERIOD_D1,0);
      maxEquity = AccountEquity();
      minEquity = AccountEquity();
   }
   
   if (!isSended) {
      string msg = "";
      if (UsePositiveProfitTrigger) {
         msg += getPositiveProfitTriggerMsg();
      }
      if (UseNegativeProfitTrigger) {
         msg += getNegativeProfitTriggerMsg();
      }
      if (UseTimeTrigger) {
         msg += getTimeTriggerMsg();
      }
      
      outputMsg(msg);
   }
   
}

bool isNewCycle(datetime preTime, datetime curTime) {
   if (preTime == curTime) {
      return false;
   }
   
   return true;
}

string getPositiveProfitTriggerMsg() {
   string msgs = "";
   if (PositiveProfitTargetPercent/100 <= (AccountEquity()-minEquity)/minEquity) {
      int total=OrdersTotal();
      for(int pos=0; pos<total; pos++) {
         if(OrderSelect(pos, SELECT_BY_POS)) {
            bool isTarget = true;
            if (EnableMagicNumberManage) {
               int magicNum = OrderMagicNumber();
               if (!ArrayContains(magicNumsStr, magicNum)) {
                  isTarget = false;
               }
            }
            
            if (isTarget) {
               double profit = OrderProfit();
               if (0.0 < profit) {
                  if (OP_BUY == OrderType()) {
                     string msg = OrderSymbol() + ":Buy;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  } else if (OP_SELL == OrderType()) {
                     string msg = OrderSymbol() + ":Sell;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  }
                  
               } else if (profit < 0.0) {
                  if (OP_BUY == OrderType()) {
                     string msg = OrderSymbol() + ":Sell;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  } else if (OP_SELL == OrderType()) {
                     string msg = OrderSymbol() + ":Buy;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  }
               }
            }
         }
      }
   }
   return msgs;
}

string getNegativeProfitTriggerMsg() {
   string msgs = "";
   if ( (maxEquity-AccountEquity())/AccountEquity() <= -NegativeProfitTargetPercent/100) {
      int total=OrdersTotal();
      for(int pos=0; pos<total; pos++) {
         if(OrderSelect(pos, SELECT_BY_POS)) {
            bool isTarget = true;
            if (EnableMagicNumberManage) {
               int magicNum = OrderMagicNumber();
               if (!ArrayContains(magicNumsStr, magicNum)) {
                  isTarget = false;
               }
            }
            
            if (isTarget) {
               double profit = OrderProfit();
               if (0.0 < profit) {
                  if (OP_BUY == OrderType()) {
                     string msg = OrderSymbol() + ":Buy;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  } else if (OP_SELL == OrderType()) {
                     string msg = OrderSymbol() + ":Sell;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  }
                  
               } else if (profit < 0.0) {
                  if (OP_BUY == OrderType()) {
                     string msg = OrderSymbol() + ":Sell;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  } else if (OP_SELL == OrderType()) {
                     string msg = OrderSymbol() + ":Buy;";
                     if (StringFind(msgs, msg) < 0) {
                        msgs += msg;
                     }
                  }
               }
            }
         }
      }
   }
   return msgs;
}

void outputMsg(string msg) {
   if ("" == msg) {
      return;
   }
   int fWrite = OpenNewFileForWriting(SaveSendResultFilePath);
   if (!IsValidFileHandle(fWrite)) {
      MessageBox("Unable to open " + SaveSendResultFilePath + " for writing");
   } else {
      WriteToFile(fWrite, msg);
      CloseFile(fWrite);
      isSended = true;
      closeAll();
   }
}

string getTimeTriggerMsg() {
   string sendInfo = "";
   datetime now = TimeGMT();
   int nowHour = TimeHour(now);
   int nowMinute = TimeMinute(now);
   int nowSeconds = TimeSeconds(now);
   if (startSendTimeHour<=nowHour && startSendTimeMinute<=nowMinute && startSendTimeSeconds<=nowSeconds) {
      string startValidTimeStr = TimeToStr(now, TIME_DATE) + " " + StartSendHMS; //"yyyy.mm.dd hh:mi"
      datetime startValidTime = StrToTime(startValidTimeStr);
      int total=OrdersTotal();
      for(int pos=0; pos<total; pos++) {
         if(OrderSelect(pos, SELECT_BY_POS)) {
            if (startValidTime <= OrderOpenTime()) {
               bool isTarget = true;
               if (EnableMagicNumberManage) {
                  int magicNum = OrderMagicNumber();
                  if (!ArrayContains(magicNumsStr, magicNum)) {
                     isTarget = false;
                  }
               }
               if (isTarget) {
                  double profit = OrderProfit();
                  if (0.0 < profit) {
                     if (OP_BUY == OrderType()) {
                        string msg = OrderSymbol() + ":Buy;";
                        if (StringFind(sendInfo, msg) < 0) {
                           sendInfo += msg;
                        }
                        
                     } else if (OP_SELL == OrderType()) {
                        string msg = OrderSymbol() + ":Sell;";
                        if (StringFind(sendInfo, msg) < 0) {
                           sendInfo += msg;
                        }
                     }
                     
                  } else if (profit < 0.0) {
                     if (OP_BUY == OrderType()) {
                        string msg = OrderSymbol() + ":Sell;";
                        if (StringFind(sendInfo, msg) < 0) {
                           sendInfo += msg;
                        }
                     } else if (OP_SELL == OrderType()) {
                        string msg = OrderSymbol() + ":Buy;";
                        if (StringFind(sendInfo, msg) < 0) {
                           sendInfo += msg;
                        }
                     }
                  }
               }
            
            }
         }
         
      }

   }
   return sendInfo;
}

bool ArrayContains(const string& array[], int num) {
   int size=ArraySize(array);
   string numStr = IntegerToString(num);
   for (int i=0; i<size; i++) {
      if (numStr == array[i]) {
         return true;
      }
   }
   return false;
}

void closeAll() {
   int total=OrdersTotal();
   for(int pos=0; pos<total; pos++) {
      if(OrderSelect(pos, SELECT_BY_POS)) {
         if (EnableMagicNumberManage) {
            int magicNum = OrderMagicNumber();
            if (!ArrayContains(magicNumsStr, magicNum)) {
               continue;
            }
         }
         if (OP_BUY == OrderType()) {
            if (!OrderClose(OrderTicket(), OrderLots(), Bid, 0)) {
               Print("Order Close Failed.");
            }
         } else if (OP_SELL == OrderType()) {
            if (!OrderClose(OrderTicket(), OrderLots(), Ask, 0)) {
               Print("Order Close Failed.");
            }
         }

      }
   }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) { 
}

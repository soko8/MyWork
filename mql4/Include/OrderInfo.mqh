//+------------------------------------------------------------------+
//|                                                    OrderInfo.mqh |
//|Copyright 2017～2019                                              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Gao Zeng.QQ--183947281,mail--soko8@sina.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class OrderInfo : public CObject {
private:

protected:
   int               ticketId;            // 订单号
   double            openPrice;           // 开仓价
   double            lotSize;             // 手数
   double            tpPrice;             // 止盈价
   double            slPrice;             // 止损价
   int               operationType;       // 订单类型
   string            symbolName;          // 货币对名
   datetime          openTime;            // 开仓时间
   bool              active;              // 订单是否可激活
   bool              closed;              // 订单是否被平仓
   bool              valid;               // 订单是否有效


public:
                     OrderInfo();
                    ~OrderInfo();

   void              setTicketId(int ticketNo)     { ticketId = ticketNo;  }
   int               getTicketId(void)       const { return(ticketId);     }

   void              setOpenPrice(double price)    { openPrice = price;    }
   double            getOpenPrice(void)      const { return(openPrice);    }

   void              setLotSize(double lots)       { lotSize = lots;       }
   double            getLotSize(void)        const { return(lotSize);      }

   void              setTpPrice(double price)      { tpPrice = price;      }
   double            getTpPrice(void)        const { return(tpPrice);      }

   void              setSlPrice(double price)      { slPrice = price;      }
   double            getSlPrice(void)        const { return(slPrice);      }

   void              setOperationType(int op)      { operationType = op;   }
   int               getOperationType(void)  const { return(operationType);}

   void              setSymbolName(string symbolNm){ symbolName = symbolNm;}
   string            getSymbolName(void)     const { return(symbolName);   }

   void              setOpenTime(datetime openTm)  { openTime = openTm;    }
   datetime          getOpenTime(void)       const { return(openTime);     }

   void              setActive(bool actived)       { this.active = actived;}
   bool              isActive(void)          const { return(active);       }

   void              setClosed(bool close)         { this.closed = close;  }
   bool              isClosed(void)          const { return(closed);       }

   void              setValid(bool valided)        { this.valid = valided; }
   bool              isValid(void)           const { return(valid);        }

   string            toString(void);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
OrderInfo::OrderInfo() {
      active = false;
      closed = false;
      valid = false;
}

OrderInfo::~OrderInfo() {}

string OrderInfo::toString(void) {
   return("ticketId="+IntegerToString(ticketId)+"||symbol="+symbolName+"||type="+IntegerToString(operationType)+"||lot="+DoubleToStr(lotSize,2)+"||OpenPrice="+DoubleToStr(openPrice,5)+"||TP="+DoubleToStr(tpPrice,5)+"||SL="+DoubleToStr(slPrice,5)+"||OpenTime="+TimeToStr(openTime,TIME_DATE|TIME_SECONDS));
}
//+------------------------------------------------------------------+

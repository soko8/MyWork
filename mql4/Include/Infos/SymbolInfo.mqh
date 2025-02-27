//+------------------------------------------------------------------+
//|                                                   SymbolInfo.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Object.mqh>

class SymbolInfo : public CObject {
private:
protected:
   string            name;
   string            prefix;
   string            suffix;
   double            point;
   int               digits;
   //double            profit;
   int               orderCountL;
   double            lotL;
   double            profitL;
   int               orderCountS;
   double            lotS;
   double            profitS;
   int               index;
   double            stopLoss;
   double            takeProfit;
   double            trailingStop;
   bool              enabled;
   int               cutTimes;
   double            maxDD;
   double            maxProfit;
public:
                     SymbolInfo();
                     SymbolInfo(string SymbolShortName, string SymbolPrefix="", string SymbolSuffix="");
                    ~SymbolInfo();
   void              setName(string symbolNm)                     { name = symbolNm;            }
   string            getName(void)                          const { return(name);               }
   
   void              setPrefix(string SymbolPrefix)               { prefix = SymbolPrefix;      }
   string            getPrefix(void)                        const { return(prefix);             }
   
   void              setSuffix(string SymbolSuffix)               { suffix = SymbolSuffix;      }
   string            getSuffix(void)                        const { return(suffix);             }
   string            getRealName(void)                      const { return(prefix+name+suffix); }
   
   void              setPoint(double vPoint)                      { point = vPoint;             }
   double            getPoint(void)                         const { return(point);              }
   
   void              setDigits(int vDigits)                       { digits = vDigits;           }
   int               getDigits(void)                        const { return(digits);             }
   
   void              setOrderCountL(int vOrderCountL)             { orderCountL = vOrderCountL; }
   int               getOrderCountL(void)                   const { return(orderCountL);        }
   
   void              setLotL(double vLotL)                        { lotL = vLotL;               }
   double            getLotL(void)                          const { return(lotL);               }
   
   void              setProfitL(double vProfitL)                  { profitL = vProfitL;         }
   double            getProfitL(void)                       const { return(profitL);            }
   
   void              setOrderCountS(int vOrderCountS)             { orderCountS = vOrderCountS; }
   int               getOrderCountS(void)                   const { return(orderCountS);        }
   
   void              setLotS(double vLotS)                        { lotS = vLotS;               }
   double            getLotS(void)                          const { return(lotS);               }
   
   void              setProfitS(double vProfitS)                  { profitS = vProfitS;         }
   double            getProfitS(void)                       const { return(profitS);            }
   
   double            getProfit(void)                        const { return(profitL+profitS);    }
   
   void              setIndex(int vIndex)                         { index = vIndex;             }
   int               getIndex(void)                         const { return(index);              }
   
   void              setStopLoss(double vStopLoss)                { stopLoss = vStopLoss;       }
   double            getStopLoss(void)                      const { return(stopLoss);           }
   
   void              setTakeProfit(double vTakeProfit)            { takeProfit = vTakeProfit;   }
   double            getTakeProfit(void)                    const { return(takeProfit);         }
   
   void              setTrailingStop(double vTrailStop)           { trailingStop = vTrailStop;  }
   double            getTrailingStop(void)                  const { return(trailingStop);       }
   
   void              setEnabled(bool vEnabled)                    { this.enabled = vEnabled;    }
   bool              isEnabled(void)                        const { return(enabled);            }
   
   void              setCutTimes(int vCutTimes)                   { cutTimes = vCutTimes;       }
   int               getCutTimes(void)                      const { return(cutTimes);           }
   
   void              setMaxDD(double vMaxDD)                      { maxDD = vMaxDD;             }
   double            getMaxDD(void)                         const { return(maxDD);              }
   
   void              setMaxProfit(double vMaxProfit)              { maxProfit = vMaxProfit;     }
   double            getMaxProfit(void)                     const { return(maxProfit);          }
};

SymbolInfo::SymbolInfo() {}

SymbolInfo::SymbolInfo(string SymbolShortName, string SymbolPrefix="", string SymbolSuffix="") {
   this.name = SymbolShortName;
   this.prefix = SymbolPrefix;
   this.suffix = SymbolSuffix;
   this.point = MarketInfo(prefix+name+suffix,MODE_POINT);
   this.digits = (int)MarketInfo(prefix+name+suffix,MODE_DIGITS);
   this.maxDD = 0.0;
   this.maxProfit = 0.0;
}

SymbolInfo::~SymbolInfo() {}

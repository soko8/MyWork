//+------------------------------------------------------------------+
//|                                                GetNewsFromJS.mq4 |
//|Copyright 2016～2019, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define MAX_SIZE_NEWS_EVENT   32

#define TIME		0
#define COUNTRY   1
#define EVENT		2
#define RANK		3
#define PREVIOUS	4
#define FORECAST	5
#define ACTUAL    6
#define IMPACT    7
#define DATE      8

#include <Tools\DateTime.mqh>

#import  "Wininet.dll"
   bool DeleteUrlCacheEntry(string);
#import

#import "urlmon.dll"
  int URLDownloadToFileW(int, string, string, int, int);
#import

enum enNewsRank
{
   HighImportant = 5,
   MediumImportant = 4,
   LowImportant = 3
//   MediumImpact = 2,
//   LowImpact = 1
};

input       enNewsRank         RankFilterData   = 5;
input       enNewsRank         RankFilterEvent  = 4;

            string      newsEventArray[MAX_SIZE_NEWS_EVENT][9];
            
            int         timeDiff;
            //bool        timeChanged = false;
            
            //datetime    currentNewsTime;

            string      varName4Timer;
            
            int         newsCount = 0;
            int         eventLabelCount = 0;
            
const       string      nmEventlbl = "Event";
const       string      nameLabelRemain = "Remain_Time";
const       string      nameLabelCountry = "Country";
const       string      nameLabelEventContent = "EventContent";

const       string      separator = "_";

int OnInit() {

   varName4Timer = "preRefreshTimeJS" + _Symbol;
   GlobalVariableDel(varName4Timer);
   
   createNewsEventLabel();
   
   EventSetTimer(1);
   
   OnTimer();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   EventKillTimer();
   
   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
      string eventName = nmEventlbl+IntegerToString(i);
      if (0 <= ObjectFind(eventName)) {
         ObjectDelete(eventName);
      }
   }

   deleteNewsEventLabel();
      
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   return(rates_total);
}

void OnTimer() {

   OnTimerCustomize(12*3600);
   setCurrentNews();

}

void OnTimerCustomize(int refreshRateSeconds) {

   bool isFirst = false;
   if (!GlobalVariableCheck(varName4Timer)) {
      isFirst = true;
   }
   
   int diffTime = 0;
   if (!isFirst) {
      datetime time = TimeLocal();
      diffTime = (int) (time - GlobalVariableGet(varName4Timer));
   }
   //printf("isFirst = " + isFirst);
   //printf("refreshRateSeconds = " + refreshRateSeconds);
   //printf("diffTime = " + diffTime);
   if (isFirst || refreshRateSeconds < diffTime) {
   
      // today
      string today = getTodayGmt8();
      string newsInfoFileNameToday = GetFileName(today);
      string urlToday = getDownloadURL(today);
      DownLoadWebPageToFile(urlToday, newsInfoFileNameToday);
      string fileContentsToday = getFileContents(newsInfoFileNameToday);
      
      string newsEventArrayToday[MAX_SIZE_NEWS_EVENT][9];
      int newsCountToday = parseFileContents(newsEventArrayToday, fileContentsToday, today);
      
      // tomorrow
      string tomorrow = getTomorrowGmt8();
      string newsInfoFileNameTomorrow = GetFileName(tomorrow);
      string urlTomorrow = getDownloadURL(tomorrow);
      DownLoadWebPageToFile(urlTomorrow, newsInfoFileNameTomorrow);
      string fileContentsTomorrow = getFileContents(newsInfoFileNameTomorrow);
      
      string newsEventArrayTomorrow[MAX_SIZE_NEWS_EVENT][9];
      int newsCountTomorrow = parseFileContents(newsEventArrayTomorrow, fileContentsTomorrow, tomorrow);
      
      newsCount = 0;
      ArrayResize(newsEventArray, MAX_SIZE_NEWS_EVENT, 0);
      // array merge
      if (0 < newsCountToday) {
         //int arraySizeToday = ArrayRange(newsEventArrayToday, 1);
         //arraySizeToday = arraySizeToday/9;
         //printf("newsCountToday=" + newsCountToday);
         
         for (int i = 0; i < newsCountToday; i++, newsCount++) {
         
            for (int j = 0; j < 9; j++) {
               //printf("i = " + i + "  j = " + j + "  newsCount=" + newsCount);
               newsEventArray[newsCount][j] = newsEventArrayToday[i][j];
               //printf("newsEventArrayToday[" + i + "][" + j + "]" + newsEventArrayToday[i][j]);
            }
            
         }
      }
      
      if (0 < newsCountTomorrow) {
         //int arraySizeTomorrow = ArrayRange(newsEventArrayTomorrow, 1);
         //arraySizeTomorrow = arraySizeTomorrow/9;
         //printf("newsCountTomorrow=" + newsCountTomorrow);
         for (int i = 0; i < newsCountTomorrow; i++, newsCount++) {
         
            for (int j = 0; j < 9; j++) {
               //printf("newsCount=" + newsCount);
               newsEventArray[newsCount][j] = newsEventArrayTomorrow[i][j];
               //printf("newsEventArrayTomorrow[" + i + "][" + j + "]" + newsEventArrayTomorrow[i][j]);
            }
            
         }
      }
      
      if (0 == newsCount) {
         return;
      }
      
      //timeChanged = false;
      timeDiff = getTimeDiffBetweenGmt8AndServer();
      
      change2TimeZone(timeDiff);
      
      refreshEvents();
      GlobalVariableSet(varName4Timer, TimeLocal());
   }

}

void setCurrentNews() {

   datetime  serverTime = TimeCurrent();

   color eventColorPast = clrGray;
   color eventColorCurrent = clrRed;
   
   bool found = false;
   datetime currentNewsTime = 0;
   string currentCountry = "";
   string currentEvent = "";
   
   for (int i = 0; i < eventLabelCount; i++) {
   
      string eventName = nmEventlbl+IntegerToString(i);

      //if (ObjectFind(eventName) < 0) {
         //continue;
      //}
      
      datetime newsTime  = (datetime) ObjectGetInteger(0, eventName, OBJPROP_TIME);
      //printf("i="+i +" newsTime="+newsTime +" serverTime"+serverTime);
      if (newsTime < serverTime) {
         ObjectSetInteger(0, eventName, OBJPROP_COLOR, eventColorPast);
      } else {
         ObjectSetInteger(0, eventName, OBJPROP_COLOR, eventColorCurrent);
         found = true;
         currentNewsTime = newsTime;
         string newsEventContents = ObjectGetString(0, eventName, OBJPROP_TEXT);
         ushort u_sep = StringGetCharacter(separator,0);
         string splitResult[];
         StringSplit(newsEventContents, u_sep, splitResult);
         currentCountry = splitResult[0];
         currentEvent = splitResult[1];
         break;
      }

   }
   
   if (!found) {
      ObjectSetString(0, nameLabelRemain, OBJPROP_TEXT, "");
      ObjectSetString(0, nameLabelCountry, OBJPROP_TEXT, "");
      ObjectSetString(0, nameLabelEventContent, OBJPROP_TEXT, "");
      return;
   }
   
   int remainSeconds = (int) (currentNewsTime - serverTime);
   
   int remainHours = remainSeconds/3600;
   
   int remainMinutes = (remainSeconds%3600)/60;
   
   int remainSecond = (remainSeconds%3600)%60;
   
   string hs = IntegerToString(remainHours);
   if (remainHours < 10) {
      hs = "0" + hs;
   }
   
   string ms = IntegerToString(remainMinutes);
   if (remainMinutes < 10) {
      ms = "0" + ms;
   }
   
   string ss = IntegerToString(remainSecond);
   if (remainSecond < 10) {
      ss = "0" + ss;
   }

   ObjectSetString(0, nameLabelRemain, OBJPROP_TEXT, StringConcatenate(hs, ":", ms, ":", ss));
   ObjectSetString(0, nameLabelCountry, OBJPROP_TEXT, currentCountry);
   ObjectSetString(0, nameLabelEventContent, OBJPROP_TEXT, currentEvent);
   
}

void refreshEvents() {
   
   ObjectSetString(0, nameLabelRemain, OBJPROP_TEXT, "");
   ObjectSetString(0, nameLabelCountry, OBJPROP_TEXT, "");
   ObjectSetString(0, nameLabelEventContent, OBJPROP_TEXT, "");
   
   datetime  serverTime = TimeCurrent();
   
   color eventColor = clrAqua;

   eventLabelCount = 0;
   for (int i = 0; i < newsCount; i++) {

      datetime newstime = StrToTime((newsEventArray[i][DATE]+" "+newsEventArray[i][TIME]));
      if (newstime < serverTime) {
         continue;
      }
      //printf("i="+i +"newstime="+newstime +"serverTime"+serverTime);
      string newsContents = newsEventArray[i][COUNTRY]+separator+newsEventArray[i][EVENT];
      
      EventCreate(nmEventlbl+IntegerToString(eventLabelCount), newsContents, newstime, eventColor);
      eventLabelCount++;
   }
}


void change2TimeZone(int timeDifference) {

   //if (timeChanged) {
      //return;
   //}

   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
   
      if ("" == newsEventArray[i][EVENT]) {
         //printf("i = " + i);
         break;
      }
      
      string date = newsEventArray[i][DATE];
      string year = StringSubstr(date, 0, 4);
      string month = StringSubstr(date, 4, 2);
      string day = StringSubstr(date, 6, 2);
      

      string time = newsEventArray[i][TIME];
      
      
      datetime newsTime = StrToTime(year + "." + month + "." + day + " " + time);
      
      CDateTime cdt;
      cdt.DateTime(newsTime);
      int incHours = timeDifference;

      cdt.HourInc(incHours);
      datetime toTimeZoneDateTime = cdt.DateTime();
      
      string dateTimeStr = TimeToStr(toTimeZoneDateTime, TIME_DATE|TIME_MINUTES);
      
      newsEventArray[i][DATE] = StringSubstr(dateTimeStr, 0, 10);
      newsEventArray[i][TIME] = StringSubstr(dateTimeStr, 11, 5);
   }
   
   //timeChanged = true;
}

int getTimeDiffBetweenGmt8AndServer() {
   
   datetime gmtTime = TimeGMT();
   datetime serverTime = TimeCurrent();
   
   // hours
   int timeZoneServer = (int) ((serverTime-gmtTime)/3600);
   
   int timeDifference = timeZoneServer-8;
   
   return timeDifference;
}



string getTodayGmt8() {
   datetime nowGMT8 = TimeGMT() + 8*60*60;
   string date = TimeToStr(nowGMT8, TIME_DATE);
   StringReplace(date, ".", "");
   return date;
}

string getTomorrowGmt8() {
   datetime tomorrowGMT8 = TimeGMT() + (8+24)*60*60;
   string date = TimeToStr(tomorrowGMT8, TIME_DATE);
   StringReplace(date, ".", "");
   return date;
}

//deVries: one file for all charts!
string GetFileName(string date) {
   
   string fileName = StringConcatenate("rili.jin10.com.", date,".html");

   return fileName;
}


string getDownloadURL(string date) {
   
   string url = "http://rili.jin10.com/";
   
   url += date;
   url += "/%E9%87%8D%E8%A6%81";
   
   return url;
}

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: downloading the http://rili.jin10.com/YYYYMMDD/重要 file                          |
//+-----------------------------------------------------------------------------------------------+
void DownLoadWebPageToFile(string jsUrl, string saveFileName) {

   DeleteUrlCacheEntry(jsUrl);
   
   string filepath = TerminalInfoString(TERMINAL_DATA_PATH);
   
   URLDownloadToFileW(NULL, jsUrl, filepath+"/MQL4/Files/"+saveFileName, NULL, NULL);
}

string getFileContents(string fileName) {

   string fileContents = "";

   int devider='\x90';
	int fileHandle = FileOpen(fileName, FILE_BIN|FILE_READ, devider, CP_UTF8);
	if(0 <= fileHandle) {
	   ulong fileSize = FileSize(fileHandle);
	   fileContents = FileReadString(fileHandle, fileSize);
	   FileClose(fileHandle);
   }

   return fileContents;
}

int parseFileContents(string& newsEvents[][], string fileContents, string date) {
   
   //ArrayResize(newsEvents, MAX_SIZE_NEWS_EVENT);
   
   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
      for (int j = 0; j < 8; j++) {
         newsEvents[i][j] = "";
      }
   }
   
   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
      newsEvents[i][DATE] = date;
   }
   
   int newsIdx = 0;
	
	int startPositionEvent = 0;
	int next = 0;
	int begin = 0;
	int end = 0;
	
	// for data list
	startPositionEvent = StringFind(fileContents, "<tbody>", startPositionEvent);
	if (-1 == startPositionEvent) return 0;
	startPositionEvent += 7;
	
	next = StringFind(fileContents, "</tbody>", startPositionEvent);
	if (-1 == next) return 0;
	
	string dataListContents = StringSubstr(fileContents, startPositionEvent, next - startPositionEvent);
	if (0 <= StringFind(dataListContents, "今日无重要经济数据", startPositionEvent)) {
	   dataListContents = "";
	}
	
	// for event list
	startPositionEvent = next;
	
	string eventListContents = "";
	
	startPositionEvent = StringFind(fileContents, "<tbody>", startPositionEvent);
	if (-1 < startPositionEvent) {
	   startPositionEvent += 7;
	
	   next = StringFind(fileContents, "</tbody>", startPositionEvent);
	   if (-1 < next) {
	      eventListContents = StringSubstr(fileContents, startPositionEvent, next - startPositionEvent);
	   }
	}
	
	if (0 <= StringFind(eventListContents, "今日无财经大事", startPositionEvent)) {
	   eventListContents = "";
	}
	
	// parse data list
	startPositionEvent = 0;
	int rowspan = 0;
	string preTime = "";
	string preCountry = "";
	while (true) {
		
		startPositionEvent = StringFind(dataListContents, "<tr>", startPositionEvent);
      
		if (-1 == startPositionEvent) break;
		
		startPositionEvent += 4;
		
		next = StringFind(dataListContents, "</tr>", startPositionEvent);
		
		if (-1 == next) break;
		
		string oneEvent = StringSubstr(dataListContents, startPositionEvent, next - startPositionEvent);
		
		startPositionEvent = next;
		
		begin = 0;
		end = 0;
		
		// rowspan
		bool hasRowspan = false;
		if (0 == rowspan) {
		   begin = StringFind(oneEvent, "<td rowspan=", begin);
		   begin += 13;
		   rowspan = StrToInteger(StringSubstr(oneEvent, begin, 1));
		   hasRowspan = true;
		}
		
		// 0 time
		string newsTime = "";
		if (hasRowspan) {
		   begin = StringFind(oneEvent, "center", begin);
   		begin += 8;
   		newsTime = StringSubstr(oneEvent, begin, 5);
		} else {
		   newsTime = preTime;
		}
		//printf("newsTime=" + newsTime);
		
		// 1 country
		string country = "";
		if (hasRowspan) {
		   begin = StringFind(oneEvent, "mini/", begin);
   		begin += 5;
   		end   = StringFind(oneEvent, ".png", begin);
   		country = StringSubstr(oneEvent, begin, end-begin);
		} else {
		   country = preCountry;
		}
		//printf("country=" + country);
		
		// 2 news data
		begin = end;
		begin = StringFind(oneEvent, "importantText", begin);
		begin += 15;
		end   = StringFind(oneEvent, "</td>", begin);
		string newsData = StringSubstr(oneEvent, begin, end-begin);
		//printf("newsData=" + newsData);
		
		// 3 rank
		begin = end;
		begin = StringFind(oneEvent, "img/", begin);
		begin += 4;
		end   = StringFind(oneEvent, ".png", begin);
		string rank = StringSubstr(oneEvent, begin, end-begin);
		//printf("rank=" + rank);
		
		// 4 previous
		begin = end;
		begin = StringFind(oneEvent, "importantData", begin);
		begin += 15;
		end   = StringFind(oneEvent, "</td>", begin);
		string previous = StringSubstr(oneEvent, begin, end-begin);
		
		// 5 forecast
		begin = end;
		begin = StringFind(oneEvent, "importantData", begin);
		begin += 15;
		end   = StringFind(oneEvent, "</td>", begin);
		string forecast = StringSubstr(oneEvent, begin, end-begin);
		
		// 6 actual
		begin = end;
		begin = StringFind(oneEvent, "<div", begin);
		begin = StringFind(oneEvent, ">", begin);
		begin += 1;
		end   = StringFind(oneEvent, "</div>", begin);
		string actual = StringSubstr(oneEvent, begin, end-begin);
		
		// 7 impact
		begin = end;
		begin = StringFind(oneEvent, "status-text", begin);
		begin += 13;
		end   = StringFind(oneEvent, "</span>", begin);
		string impact = StringSubstr(oneEvent, begin, end-begin);
		begin = end;
		begin = StringFind(oneEvent, "currency", begin);
		begin += 10;
		end   = StringFind(oneEvent, "</span>", begin);
		impact+= StringSubstr(oneEvent, begin, end-begin);
		
		
		rowspan--;
      preTime = newsTime;
      preCountry = country;
      
      if (RankFilterData <= StrToInteger(rank)) {
         newsEvents[newsIdx][TIME] = newsTime;
   		newsEvents[newsIdx][COUNTRY] = country;
   		newsEvents[newsIdx][EVENT] = newsData;
   		newsEvents[newsIdx][RANK] = rank;
   		newsEvents[newsIdx][PREVIOUS] = previous;
   		newsEvents[newsIdx][FORECAST] = forecast;
   		newsEvents[newsIdx][ACTUAL] = actual;
   		newsEvents[newsIdx][IMPACT] = impact;
   		
   		newsIdx++;
      }
		
   }//End "while" routine
   
   //printf("newsIdx="+newsIdx);
   
   startPositionEvent = 0;
   next = 0;
   while (true) {
		
		startPositionEvent = StringFind(eventListContents, "<tr>", startPositionEvent);
      
		if (-1 == startPositionEvent) break;
		
		startPositionEvent += 4;
		
		next = StringFind(eventListContents, "</tr>", startPositionEvent);
		
		if (-1 == next) break;
		
		string oneEvent = StringSubstr(eventListContents, startPositionEvent, next - startPositionEvent);
		
		startPositionEvent = next;
		
		begin = 0;
		end = 0;
		
		// 0 time
		begin = StringFind(oneEvent, "center", begin);
		begin += 8;
		end   = StringFind(oneEvent, "</td>", begin);
		string newsTime = StringSubstr(oneEvent, begin, end-begin);
		
		// 1 country
		begin = end;
		begin = StringFind(oneEvent, "center", begin);
		begin += 8;
		end   = StringFind(oneEvent, "</td>", begin);
		string country = StringSubstr(oneEvent, begin, end-begin);
		
		// 2 rank
      begin = end;
		begin = StringFind(oneEvent, "img/", begin);
		begin += 4;
		end   = StringFind(oneEvent, ".png", begin);
		string rank = StringSubstr(oneEvent, begin, end-begin);
		
		// 3 event
      begin = end;
		begin = StringFind(oneEvent, "</li>", begin);
		begin += 5;
		end   = StringFind(oneEvent, "</td>", begin);
		string event = StringSubstr(oneEvent, begin, end-begin);
		event = StringTrimLeft(event);
		
		if (RankFilterEvent <= StrToInteger(rank)) {
		
		   int insertPosition = -1;
		   string dumyDate = "2000.01.01 ";
		   for (int k = 0; k < newsIdx; k++) {
		      datetime arrayTime = StrToTime(dumyDate+newsEvents[k][TIME]);
		      datetime insertTime = StrToTime(dumyDate+newsTime);
		      if (insertTime < arrayTime) {
		         insertPosition = k;
		         break;
		      }
		   }
		   //printf("insertPosition=" + insertPosition);
		   if (insertPosition < 0) {
		      insertPosition = newsIdx;
		   } else {
		      for (int n = newsIdx-1; insertPosition <= n; n--) {
		         newsEvents[n+1][TIME] = newsEvents[n][TIME];
         		newsEvents[n+1][COUNTRY] = newsEvents[n][COUNTRY];
         		newsEvents[n+1][EVENT] = newsEvents[n][EVENT];
         		newsEvents[n+1][RANK] = newsEvents[n][RANK];
         		newsEvents[n+1][PREVIOUS] = newsEvents[n][PREVIOUS];
         		newsEvents[n+1][FORECAST] = newsEvents[n][FORECAST];
         		newsEvents[n+1][ACTUAL] = newsEvents[n][ACTUAL];
         		newsEvents[n+1][IMPACT] = newsEvents[n][IMPACT];
		      }
		   }
         newsEvents[insertPosition][TIME] = newsTime;
   		newsEvents[insertPosition][COUNTRY] = country;
   		newsEvents[insertPosition][EVENT] = event;
   		newsEvents[insertPosition][RANK] = rank;
   		
   		newsIdx++;
      }

   }
   //printf("newsIdx="+newsIdx);
   ArrayResize(newsEvents, newsIdx, newsIdx);
   
   return newsIdx;
}

void SetText(  string            name,
               string            text,
               int               x=0,
               int               y=0,
               int               fontSize=8,
               color             fontColor=clrWhite,
               string            fontName="Arial",
               ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER)
{
   if (ObjectFind(0,name) < 0) {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSet(name, OBJPROP_BACK, false);
   ObjectSetText(name, text, fontSize, fontName, fontColor);
}


void deleteNewsEventLabel() {
   ObjectDelete(nameLabelRemain);
   ObjectDelete(nameLabelCountry);
   ObjectDelete(nameLabelEventContent);
}


void createNewsEventLabel() {
   SetText(nameLabelRemain, "", 5, 60, 20, clrLightGoldenrod);
   SetText(nameLabelCountry, "", 125, 60, 20, clrPaleGreen);
   SetText(nameLabelEventContent, "", 280, 60, 20, clrPaleGreen);
}

bool EventCreate(const string          name="Event",    // event name
                 const string          text="Text",     // event text
                 datetime              time=0,          // time
                 const color           clr=clrRed,      // color
                 const int             width=8,         // point width when highlighted
                 const bool            selection=false, // highlight to move
                 const bool            back=false,      // in the background
                 const bool            hidden=true,     // hidden in the object list
                 const long            chart_ID=0,      // chart's ID
                 const int             sub_window=0,    // subwindow index
                 const long            z_order=0)       // priority for mouse click
{
   //--- if time is not set, create the object on the last bar
   if(!time) {
      time=TimeCurrent();
   }
   
   //--- reset the error value
   ResetLastError();
   
   if (ObjectFind(chart_ID, name) < 0) {
      //--- create Event object
      if(!ObjectCreate(chart_ID, name, OBJ_EVENT, sub_window, time, 0)) {
         Print(__FUNCTION__, ": failed to create \"Event\" object! Error code = ",GetLastError());
         return(false);
      }
   } else {
      if(!ObjectMove(name, 0, time, 0)) { 
         Print(__FUNCTION__, ": failed to move \"Event\" object! Error code = ",GetLastError());
         return(false); 
      } 
   }
   
   //--- set event text
   ObjectSetString(chart_ID,  name, OBJPROP_TEXT, text);
   //--- set color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
   //--- set anchor point width if the object is highlighted
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
   //--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
   //--- enable (true) or disable (false) the mode of moving event by mouse
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
   //--- successful execution
   return(true);
}

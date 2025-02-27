//+------------------------------------------------------------------+
//|                                                      GetNews.mq4 |
//|Copyright 2016～2019, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define READURL_BUFFER_SIZE   100

#define MAX_SIZE_NEWS_EVENT   64

#define TITLE		0
#define COUNTRY   1
#define DATE		2
#define TIME		3
#define IMPACT		4
#define FORECAST	5
#define PREVIOUS	6

#include <Tools\DateTime.mqh>
#import  "Wininet.dll"
   int InternetOpenW(string, int, string, string, int);
   int InternetConnectW(int, string, int, string, string, int, int, int);
   int HttpOpenRequestW(int, string, string, int, string, int, string, int);
   int InternetOpenUrlW(int, string, string, int, int, int);
   int InternetReadFile(int, uchar & arr[], int, int & arr[]);
   int InternetCloseHandle(int);
#import

input       int         TimeDifferenceBetweenNewsSiteTimeAndGmtTime  = 0; // USA West 5 time zone

const       string      url = "http://www.forexfactory.com/ff_calendar_thisweek.xml"; //original
const       string      suffixFileName = "-FF-News";
const       string      extensionFileName = ".xml";

const       string      nameLabelDate = "News_Date_";
const       string      nameLabelTime = "News_Time_";
const       string      nameLabelNewsCountry = "News_Country_";
const       string      nameLabelEvent = "News_Event_";
const       string      nameLabelRemain = "Remain_Time";
const       string      nameLabelCountry = "Country";

const       int         refreshFrequencyRemainTime = 1;  // second


string      sTags[7] =  {  "<title>",
                           "<country>",
                           "<date><![CDATA[",
                           "<time><![CDATA[",
                           "<impact><![CDATA[",
                           "<forecast><![CDATA[",
                           "<previous><![CDATA["
                        };
string      eTags[7] =  {  "</title>",
                           "</country>",
                           "]]></date>",
                           "]]></time>",
                           "]]></impact>",
                           "]]></forecast>",
                           "]]></previous>"
                        };


            string      newsInfoFileName;
            string      newsEventArray[MAX_SIZE_NEWS_EVENT][7];
            
            int         timeDiff;
            bool        timeChanged = false;
            
            datetime    currentNewsTime;

            string      varName4Timer;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   varName4Timer = "preRefreshTime" + _Symbol;
   GlobalVariableDel(varName4Timer);
   
   createNewsEventLabel();

   EventSetTimer(1);
   
   OnTimer();

   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
   deleteNewsEventLabel();
   //ObjectsDeleteAll();
      
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
//---
   //setCurrentNews();
//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
/*
   newsInfoFileName = GetFileName();
   //newsInfoFileName = "2016-03-13-FF-News.xml";
   DownLoadWebPageToFile(url, newsInfoFileName);
   string fileContents = getFileContents(newsInfoFileName);
   
   parseFileContents(newsEventArray, fileContents);
   timeChanged = false;
   timeDiff = getTimeDiffBetweenLocalAndNewsSite(TimeDifferenceBetweenNewsSiteTimeAndGmtTime);
   
   change2LocalTime();
   
   refreshLable();
*/
   OnTimerCustomize(14400);
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
      diffTime = time - GlobalVariableGet(varName4Timer);
   }
   
   if (isFirst || refreshRateSeconds < diffTime) {
      newsInfoFileName = GetFileName();
      //newsInfoFileName = "2016-03-13-FF-News.xml";
      DownLoadWebPageToFile(url, newsInfoFileName);
      string fileContents = getFileContents(newsInfoFileName);
      
      parseFileContents(newsEventArray, fileContents);
      timeChanged = false;
      timeDiff = getTimeDiffBetweenLocalAndNewsSite(TimeDifferenceBetweenNewsSiteTimeAndGmtTime);
      
      change2LocalTime();
      
      refreshLable();
      GlobalVariableSet(varName4Timer, TimeLocal());
   }

}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
//---
   
}


int getTimeDiffBetweenLocalAndNewsSite(int newsSiteTimeZone) {
   
   // hours
   int timeDiffBetweenLocalAndGmt = TimeGMTOffset()/3600;
   //printf("timeDiffBetweenLocalAndGmt="  + timeDiffBetweenLocalAndGmt);
   timeDiffBetweenLocalAndGmt = 0 - timeDiffBetweenLocalAndGmt;
   
   int timeDifference = timeDiffBetweenLocalAndGmt-newsSiteTimeZone;
   
   /*
   if (isSummerTime(TimeGMT())) {
      timeDifference--;
   }
   */
   //printf("timeDifference="  + timeDifference);
   return timeDifference;
   
}

/**
 *
 * 夏令时在每年三月的第二个星期日，冬令时在每年十一月的第一个星期日
 * date : 2015-11-07 美国西五区时间
 */
bool isSummerTime(datetime time) {

   int month = TimeMonth(time);
   
   if (3 < month && month < 11) {
      return true;
   }
   
   int day = TimeDay(time);
   
   int year = TimeYear(time);
   
   
   string firstDaySummerTimeStartMonth = StringConcatenate(year, ".03.01");
   int wdaySummer = TimeDayOfWeek(StrToTime(firstDaySummerTimeStartMonth));
   
   int summerTimeStartDay;
   if (0 == wdaySummer) {
      summerTimeStartDay = 7;
   } else {
      summerTimeStartDay = 1 + 14 - wdaySummer;
   }
   
   
   string firstDayStandardTimeStartMonth = StringConcatenate(year, ".11.01");
   int wdayStandard = TimeDayOfWeek(StrToTime(firstDayStandardTimeStartMonth));
   
   int standardTimeStartDay;
   if (0 == wdayStandard) {
      standardTimeStartDay = 1;
   } else {
      standardTimeStartDay = 1 + 7 - wdayStandard;
   }
   
   
   if (3 == month) {
      if (summerTimeStartDay <= day) {
			return true;
		}
		return false;
   }
   
   if (11 == month) {
      if (day < standardTimeStartDay) {
			return true;
		}
		return false;
   }
   
   return false;
}


//+-----------------------------------------------------------------------------------------------+
//| Subroutine: getting the name of the ForexFactory .xml file                                    |
//+-----------------------------------------------------------------------------------------------+
//deVries: one file for all charts!
string GetFileName() {

   int adjustDays = 0;
   
   switch(TimeDayOfWeek(TimeLocal())) {
      case 0:
         adjustDays = 0;
         break;
      case 1:
         adjustDays = 1;
         break;
      case 2:
         adjustDays = 2;
         break;
      case 3:
         adjustDays = 3;
         break;
      case 4:
         adjustDays = 4;
         break;
      case 5:
         adjustDays = 5;
         break;
      case 6:
         adjustDays = 6;
         break;
   }
   
   datetime calendardate =  TimeLocal() - (adjustDays  * 86400);
   
   int year = TimeYear(calendardate);
   
   int month = TimeMonth(calendardate);
   string strMonth = IntegerToString(month);
   if (month < 10) {
      strMonth = "0" + strMonth;
   }
   
   int day = TimeDay(calendardate);
   string strDay = IntegerToString(day);
   if (day < 10) {
      strDay = "0" + strDay;
   }
   
   string fileName = StringConcatenate(year, "-", strMonth,"-", strDay, suffixFileName, extensionFileName);

   return fileName; //Always a Sunday date
}

//+-----------------------------------------------------------------------------------------------+
//| Subroutine: downloading the ForexFactory .xml file                                            |
//+-----------------------------------------------------------------------------------------------+
//deVries: new coding replacing old "GrabWeb" coding
void DownLoadWebPageToFile(string ffurl, string saveFileName) {

   int HttpOpen = InternetOpenW(" ", 0, " ", " ", 0);
   int HttpConnect = InternetConnectW(HttpOpen, "", 80, "", "", 3, 0, 1);
   int HttpRequest = InternetOpenUrlW(HttpOpen, ffurl, NULL, 0, 0, 0);

   int read[1];
   uchar  Buffer[];
   ArrayResize(Buffer, READURL_BUFFER_SIZE + 1);
   string NEWS = "";
   
   //string xmlFileName = GetFileName();

   int fileHandle = FileOpen(saveFileName, FILE_BIN|FILE_READ|FILE_WRITE);
   //File exists if FileOpen return >=0. 
   if (fileHandle >= 0) {FileClose(fileHandle); FileDelete(saveFileName);}
	
	//Open new XML.  Write the ForexFactory page contents to a .htm file.  Close new XML.
	fileHandle = FileOpen(saveFileName, FILE_BIN|FILE_WRITE);
      
   while (true) {
      InternetReadFile(HttpRequest, Buffer, READURL_BUFFER_SIZE, read);      
      string strThisRead = CharArrayToString(Buffer, 0, read[0], CP_UTF8);
      if (read[0] > 0) {
         NEWS = NEWS + strThisRead;
      } else {
         FileWriteString(fileHandle, NEWS);
         FileClose(fileHandle);
         //Find the XML end tag to ensure a complete page was downloaded.
         int end = StringFind(NEWS, "</weeklyevents>", 0);
         //If the end of file tag is not found, a return -1 (or, "end <=0" in this case), 
         //then return (false).
         if (end == -1) {
            Alert(Symbol()," ",Period(),", GetNews Error: File download incomplete!");
         //Else, set global to time of last update
         } else {
            //GlobalVariableSet("Update.FF_Cal", TimeCurrent());
         }
         break;
      }
   }
   if (HttpRequest > 0) InternetCloseHandle(HttpRequest);
   if (HttpConnect > 0) InternetCloseHandle(HttpConnect);
   if (HttpOpen > 0) InternetCloseHandle(HttpOpen);
}

string getFileContents(string fileName) {

   string fileContents = "";
	//New xml file handling coding and revised parsing coding
	int fileHandle = FileOpen(fileName, FILE_BIN|FILE_READ);
	if(0 <= fileHandle) {
	   ulong fileSize = FileSize(fileHandle);
	   fileContents = FileReadString(fileHandle, fileSize);
	   FileClose(fileHandle);
   }

   return fileContents;
}

void parseFileContents(string& newsEvents[][], string fileContents) {
   
   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
      for (int j = 0; j < 7; j++) {
         newsEvents[i][j] = "";
      }
   }
   
   int newsIdx = 0;
	
	int startPositionEvent = 0;
	int next = 0;
	int begin = 0;
	int end = 0;
	bool skip = false;
	
	string tempArray[7];
	
	while (true) {
	
      startPositionEvent = StringFind(fileContents, "<event>", startPositionEvent);
      
		if (startPositionEvent == -1) break;
		
		startPositionEvent += 7;
		
		next = StringFind(fileContents, "</event>", startPositionEvent);
		
		if (next == -1) break;
		
		string oneEvent = StringSubstr(fileContents, startPositionEvent, next - startPositionEvent);
		
		startPositionEvent = next;
		
		begin = 0;
		skip = false;
      for (int i = 0; i < 7; i++) {
			tempArray[i] = "";
			next = StringFind(oneEvent, sTags[i], begin);
			// Within this event, if tag not found, then it must be missing; skip it
			if (next == -1) {
			   continue;
         } else {
				// We must have found the sTag okay...
				begin = next + StringLen(sTags[i]);		   	// Advance past the start tag
				end = StringFind(oneEvent, eTags[i], begin);	// Find start of end tag
				//Get data between start and end tag
				if (begin < end && end != -1) {
				   tempArray[i] = StringSubstr(oneEvent, begin, end - begin);
            }
         }
      }//End "for" loop
	
		//Test against filters that define whether we want to skip this particular announcement
      if (tempArray[IMPACT] == "Holiday")
		   {skip = true;}
		   
		else if (tempArray[IMPACT] == "Medium")
		   {skip = true;}
		   														   
		else if (tempArray[IMPACT] == "Low")
		   {skip = true;}

		else if (StringSubstr(tempArray[TITLE],0,4)== "Bank")
		    {skip = true;}
		    
		else if (StringSubstr(tempArray[TITLE],0,8)== "Daylight")
		    {skip = true;}
			
   	else if (   (tempArray[TIME] == "All Day"   && tempArray[TIME] == "")
      		   || (tempArray[TIME] == "Tentative" && tempArray[TIME] == "")
      		  	|| (tempArray[TIME] == "")
		  	     )
		  	{skip = true;}

		//If not skipping this event, then log time to event it into ExtMapBuffer0
		if (!skip) {
			//If we got this far then we need to calc the minutes until this event
			//First, convert the announcement time to seconds (in GMT)
			//newsTime = MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]);
			// Now calculate the minutes until this announcement (may be negative)
			//minsTillNews = (newsTime - TimeGMT()) / 60;
			
			for (int i = 0; i < 7; i++) {
			   newsEvents[newsIdx][i] = tempArray[i];
			}
			
			newsIdx++;
      }//End "skip" routine
   }//End "while" routine
   
}

void SetText(  string            name,
               string            text,
               int               x=0,
               int               y=0,
               int               fontSize=8,
               color             fontColor=clrWhite,
               string            fontName="Arial",
               ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER)
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
   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
      ObjectDelete(nameLabelDate+IntegerToString(i));
      ObjectDelete(nameLabelTime+IntegerToString(i));
      ObjectDelete(nameLabelNewsCountry+IntegerToString(i));
      ObjectDelete(nameLabelEvent+IntegerToString(i));
   }
}

void createNewsEventLabel() {

   SetText(nameLabelRemain, "", 5, 45, 30, clrLightGoldenrod);
   SetText(nameLabelCountry, "", 175, 45, 30, clrPaleGreen);
   
   int fontSize = 10;
   color fontColor = clrAqua;
   int y = 0;
   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
      y = 85 + 20*i;
      SetText(nameLabelDate+IntegerToString(i), "", 3, y, fontSize, fontColor);

      SetText(nameLabelTime+IntegerToString(i), "", 44, y, fontSize, fontColor);

      SetText(nameLabelNewsCountry+IntegerToString(i), "", 88, y, fontSize, fontColor);

      SetText(nameLabelEvent+IntegerToString(i), "", 128, y, fontSize, fontColor);
   }
}

void refreshLable() {
   
   ObjectSetString(0, nameLabelRemain, OBJPROP_TEXT, "");
   ObjectSetString(0, nameLabelCountry, OBJPROP_TEXT, "");
   
   datetime  localtime = TimeLocal();
   
   color fontColor = clrAqua;
   
   string preDate = "";
   string preTime = "";
   int countLabel = 0;
   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {

      if ("" == newsEventArray[i][0]) {
         break;
      }
      
      string strCount = IntegerToString(countLabel);
      string dateLabelName = nameLabelDate+strCount;
      string timeLabelName = nameLabelTime+strCount;
      string countryLabelName = nameLabelNewsCountry+strCount;
      string eventLabelName = nameLabelEvent+strCount;
      ObjectSetInteger(0, dateLabelName, OBJPROP_COLOR, fontColor);
      ObjectSetInteger(0, timeLabelName, OBJPROP_COLOR, fontColor);
      ObjectSetInteger(0, countryLabelName, OBJPROP_COLOR, fontColor);
      ObjectSetInteger(0, eventLabelName, OBJPROP_COLOR, fontColor);
      
      datetime newstime = StrToTime((newsEventArray[i][2]+" "+newsEventArray[i][3]));
      if (newstime < localtime) {
         continue;
      }

      if (preDate == newsEventArray[i][2]) {
         ObjectSetString(0, dateLabelName, OBJPROP_TEXT, "");
         
         if (preTime == newsEventArray[i][3]) {
            ObjectSetString(0, timeLabelName, OBJPROP_TEXT, "");
         } else {
            ObjectSetString(0, timeLabelName, OBJPROP_TEXT, newsEventArray[i][3]);
            preTime = newsEventArray[i][3];
         }
      
      } else {
         ObjectSetString(0, dateLabelName, OBJPROP_TEXT, StringSubstr(newsEventArray[i][2], 5, 5));
         preDate = newsEventArray[i][2];
         
         ObjectSetString(0, timeLabelName, OBJPROP_TEXT, newsEventArray[i][3]);
         preTime = newsEventArray[i][3];
      }

      ObjectSetString(0, countryLabelName, OBJPROP_TEXT, newsEventArray[i][1]);

      ObjectSetString(0, eventLabelName, OBJPROP_TEXT, newsEventArray[i][0]);
      
      countLabel++;
   }
}

void change2LocalTime() {

   if (timeChanged) {
      return;
   }

   for (int i = 0; i < MAX_SIZE_NEWS_EVENT; i++) {
   
      if ("" == newsEventArray[i][2]) {
         //printf("i = " + i);
         break;
      }
      
      string date = newsEventArray[i][2];
      string year = StringSubstr(date, 6, 4);
      string month = StringSubstr(date, 0, 2);
      string day = StringSubstr(date, 3, 2);
      
      string timeOriginal = newsEventArray[i][3];
      int timeStrLen = StringLen(timeOriginal);
      if (7 != timeStrLen) {
         timeOriginal = "0" + timeOriginal;
      }
      string time = StringSubstr(timeOriginal, 0, 5);
      string timeSuffix = StringSubstr(timeOriginal, 5, 2);
      
      datetime newsTime = StrToTime(year + "." + month + "." + day + " " + time);
      
      CDateTime cdt;
      cdt.DateTime(newsTime);
      int incHours = timeDiff;
      //int incHours = -4;
      /*
      printf("timeOriginal=" + timeOriginal);
      printf("time=" + time);
      printf("timeSuffix=" + timeSuffix);
      */
      if ("pm" == timeSuffix) {
         if ("12" == StringSubstr(time, 0, 2)) {
         
         } else {
            incHours = incHours + 12;
         }
      }
      cdt.HourInc(incHours);
      datetime localDateTime = cdt.DateTime();
      
      string localDateTimeStr = TimeToStr(localDateTime, TIME_DATE|TIME_MINUTES);
      
      newsEventArray[i][2] = StringSubstr(localDateTimeStr, 0, 10);
      newsEventArray[i][3] = StringSubstr(localDateTimeStr, 11, 5);
   }
   
   timeChanged = true;
}

void setCurrentNews() {

   datetime  localtime = TimeLocal();

   string year = IntegerToString(TimeYear(localtime));

   color fontColorPast = clrGray;
   color fontColorCurrent = clrRed;
   
   bool found = false;
   
   string preDate = "";
   string country = "";
   string curDate = "";
   string curTime = "";
   
   int i = 0;
   
   for (; i < MAX_SIZE_NEWS_EVENT; i++) {
   
      string eventLabelName = nameLabelEvent+IntegerToString(i);
      string eventLabel = "";
      ObjectGetString(0, eventLabelName, OBJPROP_TEXT, 0, eventLabel);
      
      if ("" == eventLabel) {
         break;
      }
      
      string dateLabelName = nameLabelDate+IntegerToString(i);
      //string curDate = "";
      ObjectGetString(0, dateLabelName, OBJPROP_TEXT, 0, curDate);
      
      if ("" == curDate) {
         curDate = preDate;
      } else {
         preDate = curDate;
      }
      
      string timeLabelName = nameLabelTime+IntegerToString(i);
      //string curTime = "";
      ObjectGetString(0, timeLabelName, OBJPROP_TEXT, 0, curTime);
      
      string countryLabelName = nameLabelNewsCountry+IntegerToString(i);
      string curCountry = "";
      ObjectGetString(0, countryLabelName, OBJPROP_TEXT, 0, curCountry);
      
      
      if ("" == curTime && !found) {
         ObjectSetInteger(0, dateLabelName, OBJPROP_COLOR, fontColorPast);
         ObjectSetInteger(0, timeLabelName, OBJPROP_COLOR, fontColorPast);
         ObjectSetInteger(0, countryLabelName, OBJPROP_COLOR, fontColorPast);
         ObjectSetInteger(0, eventLabelName, OBJPROP_COLOR, fontColorPast);
         continue;
      } else if ("" == curTime && found) {
         ObjectSetInteger(0, dateLabelName, OBJPROP_COLOR, fontColorCurrent);
         ObjectSetInteger(0, timeLabelName, OBJPROP_COLOR, fontColorCurrent);
         ObjectSetInteger(0, countryLabelName, OBJPROP_COLOR, fontColorCurrent);
         ObjectSetInteger(0, eventLabelName, OBJPROP_COLOR, fontColorCurrent);
         if (-1 == StringFind(country, curCountry)) {
            country = country + " " + curCountry;
         }
         continue;
      } else if ("" != curTime && found) {
         break;
      }
      
      datetime newstime = StrToTime(year + "." + curDate + " " + curTime);
 
      if (newstime < localtime) {
         ObjectSetInteger(0, dateLabelName, OBJPROP_COLOR, fontColorPast);
         ObjectSetInteger(0, timeLabelName, OBJPROP_COLOR, fontColorPast);
         ObjectSetInteger(0, countryLabelName, OBJPROP_COLOR, fontColorPast);
         ObjectSetInteger(0, eventLabelName, OBJPROP_COLOR, fontColorPast);
      } else {
         ObjectSetInteger(0, dateLabelName, OBJPROP_COLOR, fontColorCurrent);
         ObjectSetInteger(0, timeLabelName, OBJPROP_COLOR, fontColorCurrent);
         ObjectSetInteger(0, countryLabelName, OBJPROP_COLOR, fontColorCurrent);
         ObjectSetInteger(0, eventLabelName, OBJPROP_COLOR, fontColorCurrent);
         found = true;
         currentNewsTime = newstime;
         country = curCountry;
      }

   }
   
   if (0 == i) {
      ObjectSetString(0, nameLabelRemain, OBJPROP_TEXT, "");
      ObjectSetString(0, nameLabelCountry, OBJPROP_TEXT, "");
      return;
   }
   
   int remainSeconds = currentNewsTime - localtime;
   
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
   ObjectSetString(0, nameLabelCountry, OBJPROP_TEXT, country);
   
}


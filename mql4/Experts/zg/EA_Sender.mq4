//+------------------------------------------------------------------+
//|                                                    EA_Sender.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input string   StartSendHMS_GMT="11:00:00";
input int      ValidOrderCountPeriodBeforeStartSendHMS_Minutes=300;
input string   SaveSendResultFilePath="D:\\temp\\Result.txt";
input bool     EnableMagicNumberManage=false;
input string   MagicNumbersSeparateBySemicolon="";

#define GENERIC_READ -2147483648
#define GENERIC_WRITE 1073741824
#define CREATE_NEW 1
#define CREATE_ALWAYS 2
#define OPEN_ALWAYS 4
#define OPEN_EXISTING 3
#define TRUNCATE_EXISTING 5
#define FILE_BEGIN 0
#define FILE_CURRENT 1
#define FILE_END 2
#define INVALID_HANDLE_VALUE -1

#import "kernel32.dll"
   int CreateFileW(string Filename, int AccessMode, int ShareMode, int PassAsZero, int CreationMode, int FlagsAndAttributes, int AlsoPassAsZero);
   int ReadFile(int FileHandle, int BufferPtr, int BufferLength, int & BytesRead[], int PassAsZero);
   int WriteFile(int FileHandle, int BufferPtr, int BufferLength, int & BytesWritten[], int PassAsZero);
   int SetFilePointer(int FileHandle, int Distance, int PassAsZero, int FromPosition);
   int GetFileSize(int FileHandle, int PassAsZero);
   int CloseHandle(int FileHandle);
   bool DeleteFileW(string Filename);
   
   // Used for converting the address of a string into an integer
   int MulDiv(string X, int N1, int N2);
   // Used for temporary conversion of an array into a block of memory, which
   // can then be passed as an integer to ReadFile
   int LocalAlloc(int Flags, int Bytes);
   int RtlMoveMemory(int DestPtr, double & Array[], int Length);
   int LocalFree(int lMem);
   // Used for converting the address of an array to an integer
   int GlobalLock(double & Array[]);
   bool GlobalUnlock(int hMem);
#import

// *************************************************************************************
// Determines whether a file exists. N.B. A file can exist without being openable, if
// it is already in use by a caller who has not specified FILE_SHARE_READ or
// FILE_SHARE_WRITE
// *************************************************************************************
bool DoesFileExist(string FileName) {
   int FileHandle = CreateFileW(FileName, 0, 0, 0, OPEN_EXISTING, 0, 0);
   if (IsValidFileHandle(FileHandle)) {
      CloseHandle(FileHandle);
      return (true);
   }
   return (false);

}

// *************************************************************************************
// Opens a file for writing, and overwrites its contents (setting its length to zero) if
// it already exists. The return value is the file handle for use in subsequent calls,
// or INVALID_HANDLE_VALUE if the operation fails. This is a simple wrapper around CreateFileA,
// and overwrites the file if it already exists by specifying CREATE_ALWAYS. The call will
// fail if the file is already in use by something else.
// *************************************************************************************
int OpenNewFileForWriting(string FileName, bool ShareForReading = false) {
   int ShareMode = 0;
   if (ShareForReading) ShareMode = FILE_SHARE_READ;
   return (CreateFileW(FileName, GENERIC_WRITE, ShareMode, 0, CREATE_ALWAYS, 0, 0));
}

// *************************************************************************************
// Opens a existing file for writing and, by default, opens it for appending rather
// than overwriting data already in the file. The return value is the file handle for
// use in subsequent calls, or INVALID_HANDLE_VALUE if the operation fails.
// This is a simple wrapper around CreateFileA, using OPEN_ALWAYS so that the file
// is opened if it already exists, or created if not already in existence.
// The call will fail if the file has already been opened for writing by somebody else.
// *************************************************************************************
int OpenExistingFileForWriting(string FileName, bool Append = true, bool ShareForReading = false) {
   int ShareMode = 0;
   if (ShareForReading) ShareMode = FILE_SHARE_READ;
   int FileHandle = CreateFileW(FileName, GENERIC_WRITE, ShareMode, 0, OPEN_ALWAYS, 0, 0);
   if (IsValidFileHandle(FileHandle) && Append) {
      SetFilePointer(FileHandle, 0, 0, FILE_END);
   }
   
   return (FileHandle);
}

// *************************************************************************************
// Opens a existing file for reading and, by default, opens it for appending rather
// than overwriting data already in teh file. The return value is the file handle for
// use in subsequent calls, or INVALID_HANDLE_VALUE if the operation fails.
// This is a simple wrapper around CreateFileA, using OPEN_EXISTING so that the call
// fails if the file does not already exist. By default, the optional parameters allow
// other callers to read from the file, but not to write to it. The function will
// fail if somebody else has already opened the file for writing without specifying
// FILE_SHARE_READ.
// *************************************************************************************
int OpenExistingFileForReading(string FileName, bool ShareForReading = true, bool ShareForWriting = false) {
   int ShareMode = 0;
   if (ShareForReading) ShareMode += FILE_SHARE_READ;
   if (ShareForWriting) ShareMode += FILE_SHARE_WRITE;
   return (CreateFileW(FileName, GENERIC_READ, ShareMode, 0, OPEN_EXISTING, 0, 0));
}

// *************************************************************************************
// Checks to see if a file handle is valid.
// *************************************************************************************
bool IsValidFileHandle(int FileHandle) {
   return (FileHandle != INVALID_HANDLE_VALUE);
}

// *************************************************************************************
// Writes a string to a file handle. Returns True if the data is written in its entirety.
// Can return False if the data was only partially written. However, a False return
// value much more commonly indicates that the file handle is invalid - i.e. has been
// opened for reading rather than writing. Can be called multiple times to append
// blocks of data to a file.
// *************************************************************************************
bool WriteToFile(int FileHandle, string DataToWrite) {
   // Receives the number of bytes written to the file. Note that MQL can only pass
   // arrays as by-reference parameters to DLLs
   int BytesWritten[1] = {0};
   // Get the length of the string
   int szData = StringLen(DataToWrite);
   // Do the write
   WriteFile(FileHandle, MulDiv(DataToWrite, 1, 1), szData, BytesWritten, 0);
   
   // Return true if the number of bytes written matches the expected number
   return (BytesWritten[0] == szData);
}

// *************************************************************************************
// Reads a file's entire contents into a string. Can return a blank string either if
// the file is empty, or if the read failed - because the file handle is invalid, or
// because the file has been opened for writing rather than reading.
// *************************************************************************************
string ReadWholeFile(int FileHandle) {
   // Move to the start of the file
   SetFilePointer(FileHandle, 0, 0, FILE_BEGIN);
   
   // String which holds the combined file
   string strCombinedFile = "";
   
   // Keep reading from the file until reads fail because we've reached the end (or
   // because the file handle is not valid for reading)
   bool bContinueRead = true;
   
   while (bContinueRead) {
      // Receives the number of bytes read from the file. Note that MQL can only pass
      // arrays as by-reference parameters to DLLs
      int BytesRead[1] = {0};
      
      // 200-byte buffer...
      string ReadBuffer = "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789";
      int BufferLength = StringLen(ReadBuffer);
      
      // Do a read of up to 200 bytes
      ReadFile(FileHandle, MulDiv(ReadBuffer, 1, 1), BufferLength, BytesRead, 0);
      
      // Check whether any data has been read...
      if (BytesRead[0] != 0) {
         // Add the data which has been read to the combined string
         strCombinedFile = StringConcatenate(strCombinedFile, StringSubstr(ReadBuffer, 0, BytesRead[0]));
         bContinueRead = true;
      } else {
         // Read failed. Must be at the end of the file (or the file handle is not valid for reading)
         bContinueRead = false;
      }
   }
   return (strCombinedFile);
}

// *************************************************************************************
// Reads a line from a file. The return value can be blank if the end of the file
// has been reached, or if the file handle is simply not valid for reading. The
// line-end terminator to look for can be specified using the optional second parameter.
// This can be set to "\r" rather than "\r\n" to read CR rather than CRLF terminated lines.
// Can also be set to e.g. "|" to read files which are pipe-delimited rather than
// CRLF-delimited
// *************************************************************************************
string ReadLineFromFile(int FileHandle, string Terminator = "\r\n") {
   // Holds the line which is eventually returned to the caller
   string Line = "";
   // Keep track of the file pointer before we start doing any reading
   int InitialFilePointer = SetFilePointer(FileHandle, 0, 0, FILE_CURRENT);
   
   // Keep reading from the file until we get the end of the line, or the end of the file
   bool bContinueRead = true;
   while (bContinueRead) {
      // Receives the number of bytes read from the file. Note that MQL can only pass
      // arrays as by-reference parameters to DLLs
      int BytesRead[1] = {0};
      // 200-byte buffer...
      string ReadBuffer = "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789";
      int BufferLength = StringLen(ReadBuffer);
      // Do a read of up to 200 bytes
      ReadFile(FileHandle, MulDiv(ReadBuffer, 1, 1), BufferLength, BytesRead, 0);
      // Check whether any data has been read...
      if (BytesRead[0] != 0) {
         // Add the new data to the line we've built so far
         Line = StringConcatenate(Line, StringSubstr(ReadBuffer, 0, BytesRead[0]));
         // Does the line now contain the specified terminator?
         int pFindTerminator = StringFind(Line, Terminator);
         if (pFindTerminator != -1) {
            // The line does contain the specified terminator. Remove it from the data we're
            // going to pass back to the caller
            Line = StringSubstr(Line, 0, pFindTerminator);
            
            // We've almost certainly read too much data - i.e. the latest 200 byte block
            // intrudes into the next line. Need to adjust the file pointer to the start
            // of the next line. This must be the file pointer before we started reading, plus
            // the length of the line we've read, plus the length of the terminator
            SetFilePointer(FileHandle, InitialFilePointer + StringLen(Line) + StringLen(Terminator), 0, FILE_BEGIN);
            
            // Stop reading
            bContinueRead = false;
         } else {
            // The line read so far does not yet contain the specified terminator
            bContinueRead = true;
         }
      
      } else {
         // Either at the end of the file, or the file handle is not valid for reading
         bContinueRead = false;
      }
   }
   return (Line);
}

// *************************************************************************************
// Checks to see if the file's pointer is currently at the end of the file. Can be
// used e.g. with repeated calls to ReadLineFromFile() to keep reading until the
// end of the file is reached
// *************************************************************************************
bool IsFileAtEnd(int FileHandle) {
   int CurrentFilePointer = SetFilePointer(FileHandle, 0, 0, FILE_CURRENT);
   return (CurrentFilePointer >= GetFileSize(FileHandle, 0));
}

// *************************************************************************************
// Writes an array of doubles to a file. Returns true if the entire array is successfully
// written. Can return false if the data is only partially written but, more normally,
// a false return value indicates that the file handle is not valid for writing.
// *************************************************************************************
bool WriteDoubleArrayToFile(int FileHandle, double & Array[], int Precision = 6) {
   // Get the total number of elements in the array
   int sz = 1;
   for (int iDim = 0; iDim < ArrayDimension(Array); iDim++) {
      sz *= ArrayRange(Array, iDim);
   }
   // Quit now if the array is empty
   if (!sz) return (false);
   // Get the size of the array in bytes
   int szBytes = sz * 8;
   
   // Allocate a block of memory and copy the array into that.
   // (This step is necessary because we have to pass an integer parameter to ReadFile -
   // see the notes above)
   int lMem = LocalAlloc(0, szBytes);
   RtlMoveMemory(lMem, Array, szBytes);
   // Receives the number of bytes written to the file. Note that MQL can only pass
   // arrays as by-reference parameters to DLLs
   int BytesWritten[1] = {0};
   // Do the write
   WriteFile(FileHandle, lMem, szBytes, BytesWritten, 0);
   
   // Free the temporary memory
   LocalFree(lMem);
   
   // Indicate whether the write succeeded in full
   return (szBytes == BytesWritten[0]);
}

// *************************************************************************************
// Reads a double array from a file. The dimensions of the array **MUST** be set
// before calling the function. It returns true if the entire array was read from disk.
// False indicates either that there was insufficient data in the file, or that the
// file handle is simply not valid for reading. If the function returns false then
// the contents of the array are effectively random.
// *************************************************************************************
bool ReadDoubleArrayFromFile(int FileHandle, double & Array[]) {
   // Get the total number of elements in the array
   int sz = 1;
   for (int iDim = 0; iDim < ArrayDimension(Array); iDim++) {
      sz *= ArrayRange(Array, iDim);
   }
   // Quit if the array has no elements
   if (!sz) return (false);
   // Get the size of the double array in bytes
   int szBytes = sz * 8;
   // Nasty workaround (see notes above). Get the address in memory of the array
   int pMem = GlobalLock(Array);
   // Receives the number of bytes written to the file. Note that MQL can only pass
   // arrays as by-reference parameters to DLLs
   int BytesRead[1] = {0};
   // Do the read from the file
   ReadFile(FileHandle, pMem, szBytes, BytesRead, 0);
   // Undo the temporary memory lock which was required to get the address of the array
   GlobalUnlock(pMem);
   // See if the entire expected amount of data was returned
   return (szBytes == BytesRead[0]);
}

// *************************************************************************************
// Simple wrappers around SetFilePointer(), moving to the start and end of a file
// *************************************************************************************
bool MoveToFileStart(int FileHandle) {
   return (SetFilePointer(FileHandle, 0, 0, FILE_BEGIN) != -1);
}
bool MoveToFileEnd(int FileHandle) {
   return (SetFilePointer(FileHandle, 0, 0, FILE_END) != -1);
}

// *************************************************************************************
// Simple renaming wrapper around CloseHandle(), making its name more intuitive
// *************************************************************************************
void CloseFile(int FileHandle) {
   CloseHandle(FileHandle);
}
// *************************************************************************************
// Simple renaming wrapper around DeleteFileA(), making its name more intuitive
// *************************************************************************************
bool DeleteFile(string FileName) {
   return (DeleteFileW(FileName));
}



bool           isSended = false;
datetime       previousDaiyBarTime = 0;
int            startSendTimeHour = 0;
int            startSendTimeMinute = 0;
int            startSendTimeSeconds = 0;
string         StartSendHMS = "";
int            diffPickTime = 0;
string         magicNumsStr[];

int OnInit() {
   Print("aaaaa");
   int fWrite = OpenNewFileForWriting(SaveSendResultFilePath, true);
   if (!IsValidFileHandle(fWrite)) {
      MessageBox("Unable to open " + SaveSendResultFilePath + " for writing");
   } else {
      WriteToFile(fWrite, "aaaa");
   }
   /**
   startSendTimeHour = StrToInteger(StringSubstr(StartSendHMS_GMT, 0, 2));
   startSendTimeMinute = StrToInteger(StringSubstr(StartSendHMS_GMT, 3, 2));
   startSendTimeSeconds = StrToInteger(StringSubstr(StartSendHMS_GMT, 6, 2));
   StartSendHMS = StringSubstr(StartSendHMS_GMT, 0, 5);
   diffPickTime = ValidOrderCountPeriodBeforeStartSendHMS_Minutes*60;
   ushort u_sep = StringGetCharacter(";", 0);
   StringSplit(MagicNumbersSeparateBySemicolon, u_sep, magicNumsStr);
   
   EventSetTimer(60);
   */
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();
}

void OnTick() {}


bool isNewDay() {
   datetime currentDaiyBarTime = iTime(NULL,PERIOD_D1,0);
   if (previousDaiyBarTime == currentDaiyBarTime) {
      return false;
   }
   previousDaiyBarTime = currentDaiyBarTime;
   return true;
}

void OnTimer() {
   if (isNewDay()) {
      isSended = false;
   }
   
   if (!isSended) {
      datetime now = TimeGMT();
      int nowHour = TimeHour(now);
      int nowMinute = TimeMinute(now);
      int nowSeconds = TimeSeconds(now);
      if (startSendTimeHour<=nowHour && startSendTimeMinute<=nowMinute && startSendTimeSeconds<=nowSeconds) {
         string startValidTimeStr = TimeToStr(now, TIME_DATE) + " " + StartSendHMS; //"yyyy.mm.dd hh:mi"
         datetime startValidTime = StrToTime(startValidTimeStr);
         string sendInfo = "";
         int total=OrdersTotal();
         for(int pos=0; pos<total; pos++) {
            if(OrderSelect(pos, SELECT_BY_POS)) {
               if (startValidTime <= OrderOpenTime()) {
                  bool add = false;
                  if (EnableMagicNumberManage) {
                     // TODO
                     int magicNum = OrderMagicNumber();
                     if (ArrayContains(magicNumsStr, magicNum)) {
                        add = true;
                     }
                  } else {
                     add = true;
                  }
                  if (add) {
                     double profit = OrderProfit();
                     if (0.0 < profit) {
                        if (OP_BUY == OrderType()) {
                           sendInfo += OrderSymbol() + ":Buy;";
                        } else if (OP_SELL == OrderType()) {
                           sendInfo += OrderSymbol() + ":Sell;";
                        }
                        
                     } else if (profit < 0.0) {
                        if (OP_BUY == OrderType()) {
                           sendInfo += OrderSymbol() + ":Sell;";
                        } else if (OP_SELL == OrderType()) {
                           sendInfo += OrderSymbol() + ":Buy;";
                        }
                     }
                  }
               
               }
            }
            
         }
         int fWrite = OpenNewFileForWriting(SaveSendResultFilePath, true);
         if (!IsValidFileHandle(fWrite)) {
            MessageBox("Unable to open " + SaveSendResultFilePath + " for writing");
         } else {
            WriteToFile(fWrite, sendInfo);
         }
         
      }
   }
   
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

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

   
}

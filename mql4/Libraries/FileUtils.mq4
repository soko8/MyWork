//+------------------------------------------------------------------+
//|                                                    FileUtils.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2021, MetaQuotes Software Corp."
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
#define GENERIC_READ 0x80000000
#define GENERIC_WRITE 0x40000000

#define FILE_SHARE_READ_ 0x00000001
#define FILE_SHARE_WRITE_ 0x00000002
#define FILE_SHARE_DELETE_ 0x00000004

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
   int CreateFileW(string, uint, int, int, int, int, int);
   int ReadFile(int, uchar&[], int, int&[], int);
   int WriteFile(int, uchar&[], int, int&[], int);
   int GetFileSize(int, int);
   int CloseHandle(int);
   bool DeleteFileW(string);
   int SetFilePointer(int, int, int, int);
#import

// *************************************************************************************
// Determines whether a file exists. N.B. A file can exist without being openable, if
// it is already in use by a caller who has not specified FILE_SHARE_READ_ or
// FILE_SHARE_WRITE_
// *************************************************************************************
bool DoesFileExist(string FileName) export {
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
int OpenNewFileForWriting(string FileName, bool ShareForReading = false) export {
   int ShareMode = 0;
   if (ShareForReading) ShareMode = FILE_SHARE_READ_;
   int fileHandle = CreateFileW(FileName, GENERIC_WRITE, ShareMode, 0, CREATE_ALWAYS, 0, 0);
   return (fileHandle);
}

// *************************************************************************************
// Opens a existing file for writing and, by default, opens it for appending rather
// than overwriting data already in the file. The return value is the file handle for
// use in subsequent calls, or INVALID_HANDLE_VALUE if the operation fails.
// This is a simple wrapper around CreateFileA, using OPEN_ALWAYS so that the file
// is opened if it already exists, or created if not already in existence.
// The call will fail if the file has already been opened for writing by somebody else.
// *************************************************************************************
int OpenExistingFileForWriting(string FileName, bool Append = true, bool ShareForReading = false) export {
   int ShareMode = 0;
   if (ShareForReading) ShareMode = FILE_SHARE_READ_;
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
// FILE_SHARE_READ_.
// *************************************************************************************
int OpenExistingFileForReading(string FileName, bool ShareForReading = true, bool ShareForWriting = false) export {
   int ShareMode = 0;
   if (ShareForReading) ShareMode += FILE_SHARE_READ_;
   if (ShareForWriting) ShareMode += FILE_SHARE_WRITE_;
   return (CreateFileW(FileName, GENERIC_READ, ShareMode, 0, OPEN_EXISTING, 0, 0));
}

// *************************************************************************************
// Checks to see if a file handle is valid.
// *************************************************************************************
bool IsValidFileHandle(int FileHandle) export {
   return (FileHandle != INVALID_HANDLE_VALUE);
}

// *************************************************************************************
// Writes a string to a file handle. Returns True if the data is written in its entirety.
// Can return False if the data was only partially written. However, a False return
// value much more commonly indicates that the file handle is invalid - i.e. has been
// opened for reading rather than writing. Can be called multiple times to append
// blocks of data to a file.
// *************************************************************************************
bool WriteToFile(int FileHandle, string DataToWrite) export {
   // Receives the number of bytes written to the file. Note that MQL can only pass
   // arrays as by-reference parameters to DLLs
   int BytesWritten[1] = {0};
   // Get the length of the string
   int szData = StringLen(DataToWrite);
   uchar array[];
   ArrayResize(array, szData);
   StringToCharArray(DataToWrite, array);
   // Do the write
   WriteFile(FileHandle, array, szData, BytesWritten, 0);
   
   // Return true if the number of bytes written matches the expected number
   return (BytesWritten[0] == szData);
}

// *************************************************************************************
// Reads a file's entire contents into a string. Can return a blank string either if
// the file is empty, or if the read failed - because the file handle is invalid, or
// because the file has been opened for writing rather than reading.
// *************************************************************************************
string ReadWholeFile(int FileHandle) export {
   // Move to the start of the file
   SetFilePointer(FileHandle, 0, 0, FILE_BEGIN);
   
   // String which holds the combined file
   string strCombinedFile = "";
   
   // Keep reading from the file until reads fail because we've reached the end (or
   // because the file handle is not valid for reading)
   bool bContinueRead = true;
   int BufferLength = 200;
   
   while (bContinueRead) {
      // Receives the number of bytes read from the file. Note that MQL can only pass
      // arrays as by-reference parameters to DLLs
      int BytesRead[1] = {0};
      
      // 200-byte buffer...
      uchar buffer[];
      ArrayResize(buffer, BufferLength);
      
      // Do a read of up to 200 bytes
      ReadFile(FileHandle, buffer, BufferLength, BytesRead, 0);
      
      // Check whether any data has been read...
      if (BytesRead[0] != 0) {
         // Add the data which has been read to the combined string
         strCombinedFile = StringConcatenate(strCombinedFile, CharArrayToString(buffer, 0, BytesRead[0]));
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
string ReadLineFromFile(int FileHandle, string Terminator = "\r\n") export {
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
      int BufferLength = 200;
      uchar buffer[];
      ArrayResize(buffer, BufferLength);
      // Do a read of up to 200 bytes
      ReadFile(FileHandle, buffer, BufferLength, BytesRead, 0);
      // Check whether any data has been read...
      if (BytesRead[0] != 0) {
         // Add the new data to the line we've built so far
         Line = StringConcatenate(Line, CharArrayToString(buffer, 0, BytesRead[0]));
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
// Simple renaming wrapper around CloseHandle(), making its name more intuitive
// *************************************************************************************
void CloseFile(int FileHandle) export {
   CloseHandle(FileHandle);
}
// *************************************************************************************
// Simple renaming wrapper around DeleteFileA(), making its name more intuitive
// *************************************************************************************
bool DeleteFile(string FileName) export {
   return (DeleteFileW(FileName));
}
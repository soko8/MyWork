//+------------------------------------------------------------------+
//|                                                    FileUtils.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
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
#import "FileUtils.ex4"

bool DoesFileExist(string FileName);
int OpenNewFileForWriting(string FileName, bool ShareForReading = false);
int OpenExistingFileForWriting(string FileName, bool Append = true, bool ShareForReading = false);
int OpenExistingFileForReading(string FileName, bool ShareForReading = true, bool ShareForWriting = false);
bool IsValidFileHandle(int FileHandle);
bool WriteToFile(int FileHandle, string DataToWrite);
string ReadWholeFile(int FileHandle);
string ReadLineFromFile(int FileHandle, string Terminator = "\r\n");
void CloseFile(int FileHandle);
bool DeleteFile(string FileName);

#import
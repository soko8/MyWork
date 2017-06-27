//+------------------------------------------------------------------+
//|                                                   SymbolsLib.mq4 |
//|      Copyright 2017, Gao Zeng.QQ--183947281,mail--soko8@sina.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2017, Gao Zeng.QQ--183947281,mail--soko8@sina.com"
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
int SymbolsList(string &Symbols[], bool Selected) export {
	string SymbolsFileName;
	int Offset, SymbolsNumber;

	if (Selected)
		SymbolsFileName = "symbols.sel";
	else
		SymbolsFileName = "symbols.raw";

	int hFile = FileOpenHistory(SymbolsFileName, FILE_BIN | FILE_READ);
	if (hFile < 0)
		return (-1);

	if (Selected) {
		SymbolsNumber = (FileSize(hFile) - 4) / 128;
		Offset = 116;
	} else {
		SymbolsNumber = FileSize(hFile) / 1936;
		Offset = 1924;
	}

	ArrayResize(Symbols, SymbolsNumber);

	if (Selected)
		FileSeek(hFile, 4, SEEK_SET);

	for (int i = 0; i < SymbolsNumber; i++) {
		Symbols[i] = FileReadString(hFile, 12);
		FileSeek(hFile, Offset, SEEK_CUR);
	}

	FileClose(hFile);

	return (SymbolsNumber);
}

string SymbolDescription(string SymbolName) export {
	string SymbolDescription = "";

	int hFile = FileOpenHistory("symbols.raw", FILE_BIN | FILE_READ);
	if (hFile < 0)
		return ("");

	int SymbolsNumber = FileSize(hFile) / 1936;

	for (int i = 0; i < SymbolsNumber; i++) {
		if (FileReadString(hFile, 12) == SymbolName) {
			SymbolDescription = FileReadString(hFile, 64);
			break;
		}
		FileSeek(hFile, 1924, SEEK_CUR);
	}

	FileClose(hFile);

	return (SymbolDescription);
}

string SymbolType(string SymbolName) export {
	int GroupNumber = -1;
	string SymbolGroup = "";

	int hFile = FileOpenHistory("symbols.raw", FILE_BIN | FILE_READ);
	if (hFile < 0)
		return ("");

	int SymbolsNumber = FileSize(hFile) / 1936;

	for (int i = 0; i < SymbolsNumber; i++) {
		if (FileReadString(hFile, 12) == SymbolName) {
			FileSeek(hFile, 1936 * i + 100, SEEK_SET);
			GroupNumber = FileReadInteger(hFile);

			break;
		}
		FileSeek(hFile, 1924, SEEK_CUR);
	}

	FileClose(hFile);

	if (GroupNumber < 0)
		return ("");

	hFile = FileOpenHistory("symgroups.raw", FILE_BIN | FILE_READ);
	if (hFile < 0)
		return ("");

	FileSeek(hFile, 80 * GroupNumber, SEEK_SET);
	SymbolGroup = FileReadString(hFile, 16);

	FileClose(hFile);

	return (SymbolGroup);
}
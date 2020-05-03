package jp.co.dcs21.migration.utils;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.List;

import jp.co.dcs21.migration.logic.BusinessLogic;

public class CsvHandler extends ExcelFileHandler {

	private String charsetName = null;
	
	public CsvHandler() {}
	
	public CsvHandler(String csvfile) {
		this.file = csvfile;
	}
	
	public CsvHandler(String csvfile, BusinessLogic bl) {
		this.file = csvfile;
		this.bl = bl;
	}
	
	@Override
	public void read() throws Exception {
		
//		String[] line = this.readLine();
		
		if (null == this.file || 0 == this.file.length()) {
			return;
		}
		
		FileInputStream fis = null;
		
		InputStreamReader isr = null;
		
//		FileReader fr = null;
		
		BufferedReader reader = null;
		
		try {
			
			fis = new FileInputStream(this.file);
			
			if (null == this.charsetName || 0 == this.charsetName.length()) {
				isr = new InputStreamReader(fis);
			} else {
				isr = new InputStreamReader(fis, this.charsetName);
			}
			
//			fr = new FileReader(this.file);
			
//			reader = new BufferedReader(fr);
			reader = new BufferedReader(isr);
			
			String line = null;
			
			List<String> record = null;
			
			int row = -1;
			
			while(true) {
				
				line = reader.readLine();
				
				
				
				if (null == line || 0 == line.length()) {
					break;
				} else {
//					String temp = new String(line.getBytes(), "SJIS");
//					System.err.println(line);
					row++;
					record = Arrays.asList(line.split(","));
					this.bl.processBusiness("", record, row);
				}
			}
//			System.err.println(row);
			
		} finally {
			
			/*if (null != fr) {
				try {
					fr.close();
				} catch (IOException e) {
					fr = null;
				}
			}*/
			if (null != fis) {
				try {
					fis.close();
				} catch (IOException e) {
					fis = null;
				}
			}
			
			if (null != isr) {
				try {
					isr.close();
				} catch (IOException e) {
					isr = null;
				}
			}
			
			if (null != reader) {

				try {
					reader.close();
				} catch (IOException e) {
					reader = null;
				}
			
			}
			
		}
	}

	public String getCharsetName() {
		return charsetName;
	}

	public void setCharsetName(String charsetName) {
		this.charsetName = charsetName;
	}
}

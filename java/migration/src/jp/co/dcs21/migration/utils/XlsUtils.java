package jp.co.dcs21.migration.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;

import org.apache.poi.hssf.eventusermodel.HSSFEventFactory;
import org.apache.poi.hssf.eventusermodel.HSSFListener;
import org.apache.poi.hssf.eventusermodel.HSSFRequest;
import org.apache.poi.hssf.record.BOFRecord;
import org.apache.poi.hssf.record.BlankRecord;
import org.apache.poi.hssf.record.BoolErrRecord;
import org.apache.poi.hssf.record.BoundSheetRecord;
import org.apache.poi.hssf.record.FormulaRecord;
import org.apache.poi.hssf.record.LabelSSTRecord;
import org.apache.poi.hssf.record.NumberRecord;
import org.apache.poi.hssf.record.Record;
import org.apache.poi.hssf.record.RowRecord;
import org.apache.poi.hssf.record.SSTRecord;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

public class XlsUtils {

	private String xlsFile = null;
	
	public XlsUtils(String xlsFile) {
		this.xlsFile = xlsFile;
	}

	public void read() throws IOException {
		
		FileInputStream fis = null;
		
		InputStream is = null;
		
		try {
			
			fis = new FileInputStream(new File(xlsFile));
			
			POIFSFileSystem pfs = new POIFSFileSystem(fis);
			
			is = pfs.createDocumentInputStream("Workbook");

			HSSFRequest request = new HSSFRequest();
			// 这儿为所有类型的Record都注册了监听器，如果需求明确的话，可以用addListener方法，并指定所需的Record类型
			request.addListenerForAllRecords(new RecordListener());

			(new HSSFEventFactory()).processEvents(request, is);

			
		} finally {
			
			if (null != fis) {
				try {
					fis.close();
				} catch(IOException e) {
					fis = null;
				}
			}
			
			if (null != is) {
				try {
					is.close();
				} catch(IOException e) {
					is = null;
				}
			}
			
		}
	}
	
	public String getXlsFile() {
		return xlsFile;
	}

	public void setXlsFile(String xlsFile) {
		this.xlsFile = xlsFile;
	}
	
}

class RecordListener implements HSSFListener {
	// 记录下来字符串表
	private SSTRecord strRec;

	public void processRecord(Record record) {
		
		switch (record.getSid()) {
			
			// begin of file
			case BOFRecord.sid:
				BOFRecord br = (BOFRecord) record;
				switch (br.getType()) {
					case BOFRecord.TYPE_WORKBOOK: // 顺序进入新的Workbook
						System.out.println("新workbook");
						break;
					case BOFRecord.TYPE_WORKSHEET:// 顺序进入新的Worksheet，因为Event
													// API不会把Excel文件里的所有数据结构都关联起来，所以这儿一定要记录现在进入第几个sheet了。
						System.out.println("新worksheet");
						break;
				}
				break;
			case BoundSheetRecord.sid: // 记录sheet，这儿会把所有的sheet都顺序打印出来，如果有多个sheet的话，可以顺序记入到一个List里
				BoundSheetRecord bsr = (BoundSheetRecord) record;
				System.out.println("sheetName：" + bsr.getSheetname());
				break;
			case SSTRecord.sid: // 记录字符串表
				strRec = (SSTRecord) record;
				System.out.println("字符串表");
				break;
			case RowRecord.sid: // 打印行，这个用处不大
				RowRecord rr = (RowRecord) record;
				System.out.println("行：" + rr.getRowNumber() + "。 開始列:" + rr.getFirstCol() + ", 終了列：" + rr.getLastCol());
				break;
			case NumberRecord.sid: // 发现数字类型的cell，因为数字和日期都是用这个格式，所以下面一定要判断是不是日期格式，另外默认的数字也会被视为日期格式，所以如果是数字的话，一定要明确指定格式！！！！！！！
				NumberRecord nr = (NumberRecord) record;
				if (HSSFDateUtil.isInternalDateFormat(nr.getXFIndex())) {
					System.out.println("日付：" + (new SimpleDateFormat("yyyy-MM-dd")).format(HSSFDateUtil.getJavaDate(nr.getValue())) + ", 行:" + nr.getRow() + ", 列：" + nr.getColumn() + "。（" + nr.getXFIndex() + "）");
				} else {
					System.out.println("数字：" + nr.getValue() + ", 行:" + nr.getRow() + ", 列：" + nr.getColumn() + "。（" + nr.getXFIndex() + "）");
				}
				break;
			case LabelSSTRecord.sid: // 发现字符串类型，这儿要取字符串的值的话，跟据其index去字符串表里读取
				LabelSSTRecord lsr = (LabelSSTRecord) record;
				System.out.println("文字列:" + strRec.getString(lsr.getSSTIndex()) + ",　行：" + lsr.getRow() + ", 列：" + lsr.getColumn());
				break;
			case BoolErrRecord.sid: // boolean or error
				BoolErrRecord ber = (BoolErrRecord) record;
				if (ber.isBoolean()) {
					System.out.println("Boolean:" + ber.getBooleanValue() + ", 行：" + ber.getRow() + ", 列：" + ber.getColumn());
				}
				if (ber.isError()) {
					System.out.println("Error:" + ber.getErrorValue() + ", 行：" + ber.getRow() + ", 列：" + ber.getColumn());
				}
				break;
			case BlankRecord.sid:
				BlankRecord br1 = (BlankRecord) record;
				System.out.println("空。　行：" + br1.getRow() + ", 列：" + br1.getColumn());
				break;
			case FormulaRecord.sid: // 数式
				FormulaRecord fr = (FormulaRecord) record;
				break;
		}
	}

}


/**
 * This example shows how to use the event API for reading a file.
 */
class EventExample
        implements HSSFListener
{
    private SSTRecord sstrec;

    /**
     * This method listens for incoming records and handles them as required.
     * @param record    The record that was found while reading.
     */
    public void processRecord(Record record)
    {
        switch (record.getSid())
        {
            // the BOFRecord can represent either the beginning of a sheet or the workbook
            case BOFRecord.sid:
                BOFRecord bof = (BOFRecord) record;
                if (bof.getType() == bof.TYPE_WORKBOOK)
                {
                    System.out.println("Encountered workbook");
                    // assigned to the class level member
                } else if (bof.getType() == bof.TYPE_WORKSHEET)
                {
                    System.out.println("Encountered sheet reference");
                }
                break;
            case BoundSheetRecord.sid:
                BoundSheetRecord bsr = (BoundSheetRecord) record;
                System.out.println("New sheet named: " + bsr.getSheetname());
                break;
            case RowRecord.sid:
                RowRecord rowrec = (RowRecord) record;
                System.out.println("Row found, first column at "
                        + rowrec.getFirstCol() + " last column at " + rowrec.getLastCol());
                break;
            case NumberRecord.sid:
                NumberRecord numrec = (NumberRecord) record;
                System.out.println("Cell found with value " + numrec.getValue()
                        + " at row " + numrec.getRow() + " and column " + numrec.getColumn());
                break;
                // SSTRecords store a array of unique strings used in Excel.
            case SSTRecord.sid:
                sstrec = (SSTRecord) record;
                for (int k = 0; k < sstrec.getNumUniqueStrings(); k++)
                {
                    System.out.println("String table value " + k + " = " + sstrec.getString(k));
                }
                break;
            case LabelSSTRecord.sid:
                LabelSSTRecord lrec = (LabelSSTRecord) record;
                System.out.println("String cell found with value "
                        + sstrec.getString(lrec.getSSTIndex()));
                break;
        }
    }
}
package jp.co.dcs21.migration.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import jp.co.dcs21.migration.logic.BusinessLogic;

import org.apache.poi.hssf.eventusermodel.HSSFEventFactory;
import org.apache.poi.hssf.eventusermodel.HSSFListener;
import org.apache.poi.hssf.eventusermodel.HSSFRequest;
import org.apache.poi.hssf.record.BoundSheetRecord;
import org.apache.poi.hssf.record.LabelSSTRecord;
import org.apache.poi.hssf.record.NumberRecord;
import org.apache.poi.hssf.record.Record;
import org.apache.poi.hssf.record.RowRecord;
import org.apache.poi.hssf.record.SSTRecord;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

public class XlsHandler extends ExcelFileHandler {

	public XlsHandler() {}

	public XlsHandler(String xlsfile) {
		this.file = xlsfile;
	}

	public XlsHandler(String xlsfile, BusinessLogic bl) {
		this.file = xlsfile;
		this.bl = bl;
	}

	@Override
	public void read() throws Exception {

		FileInputStream fis = null;

		InputStream is = null;

		try {

			fis = new FileInputStream(new File(this.file));

			POIFSFileSystem pfs = new POIFSFileSystem(fis);

			is = pfs.createDocumentInputStream("Workbook");

			HSSFRequest request = new HSSFRequest();

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


class RecordListener implements HSSFListener {

		// シートの名称
		private String sheetName = null;
		// 文字列表を記録する用
		private SSTRecord strRec = null;

		private int columnsSize = 0;

		List<String> record = new ArrayList<String>();

		Object value = null;

		public void processRecord(Record record) {

			switch (record.getSid()) {

				case BoundSheetRecord.sid: // sheetをレコードする，ここで、全てのシートを順次に印刷する。
					BoundSheetRecord bsr = (BoundSheetRecord) record;
					sheetName = bsr.getSheetname();
					break;
				case RowRecord.sid:
					RowRecord rr = (RowRecord) record;
					if (0 == rr.getRowNumber()) {
						columnsSize = rr.getLastCol();
					}
					break;
				case SSTRecord.sid: // 文字列表の記録を取る
					strRec = (SSTRecord) record;
					break;
				case NumberRecord.sid:		// 数字型のセル
					NumberRecord nr = (NumberRecord) record;

					if (!HSSFDateUtil.isInternalDateFormat(nr.getXFIndex())) {	// 日付の場合
						value = (new SimpleDateFormat("yyyy-MM-dd hh:mm:ss")).format(HSSFDateUtil.getJavaDate(nr.getValue()));
					} else {													// 数字の場合
						value = nr.getValue();
					}
					process(sheetName, value, nr.getRow(), nr.getColumn());
					break;
				case LabelSSTRecord.sid:	// 文字列型のセル
					LabelSSTRecord lsr = (LabelSSTRecord) record;
					value = strRec.getString(lsr.getSSTIndex());
					process(sheetName, value, lsr.getRow(), lsr.getColumn());
					break;
			}
		}

		private void process(String sheetName, Object cellValue, int row, int column) {

			if (this.columnsSize == column + 1) {
				record.add(column, String.valueOf(cellValue));
				bl.processBusiness(sheetName, record, row);
				record = new ArrayList<String>();
			} else {
				record.add(column, String.valueOf(cellValue));
			}
		}
	}
}


package jp.co.dcs21.migration.utils;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import jp.co.dcs21.migration.logic.BusinessLogic;

import org.apache.poi.openxml4j.opc.OPCPackage;
import org.apache.poi.ss.usermodel.BuiltinFormats;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.eventusermodel.XSSFReader;
import org.apache.poi.xssf.model.SharedStringsTable;
import org.apache.poi.xssf.model.StylesTable;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFRichTextString;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;

public class XlsxHandler extends ExcelFileHandler {

	enum xssfDataType {
		BOOLEAN,
		ERROR,
		FORMULA,
		INLINE_STRING,
		SST_STRING,
		NUMBER,
	}

	private StylesTable stylesTable = null;

	SharedStringsTable sst = null;

	private String outputFile = null;

	public XlsxHandler() {}

	public XlsxHandler(String xlsxfile) {
		this.file = xlsxfile;
	}

	public XlsxHandler(String xlsxfile, BusinessLogic bl) {
		this.file = xlsxfile;
		this.bl = bl;
	}

	@Override
	public void read() throws Exception  {

		OPCPackage pkg = OPCPackage.open(this.file);

		XSSFReader r = new XSSFReader( pkg );

		this.stylesTable = r.getStylesTable();

		this.sst = r.getSharedStringsTable();

		XMLReader parser = fetchSheetParser(sst);

		Iterator<InputStream> sheets = r.getSheetsData();

		while(sheets.hasNext()) {
			System.out.println("Processing new sheet:\n");
			InputStream sheet = sheets.next();
			InputSource sheetSource = new InputSource(sheet);
			parser.parse(sheetSource);
			sheet.close();
			System.out.println("");
		}
	}

	public XMLReader fetchSheetParser(SharedStringsTable sst) throws SAXException {
		XMLReader parser =XMLReaderFactory.createXMLReader("org.apache.xerces.parsers.SAXParser");
		ContentHandler handler = new SheetHandler();
		parser.setContentHandler(handler);
		return parser;
	}

	/**
	 * See org.xml.sax.helpers.DefaultHandler javadocs
	 */
	private class SheetHandler extends DefaultHandler {

		private final DataFormatter formatter = new DataFormatter();

		private StringBuilder cellContent = new StringBuilder();
		private StringBuilder formula = new StringBuilder();
		private xssfDataType cellDataType = null;
		private String cellValue = null;

		private String sheetName = null;

		private int row = -1;
		private int preColumn = 0;
		private int curColumn = 0;

		private short formatIndex = -1;
		private String formatString = null;

		private List<String> record = null;

		// Set when V start element is seen
		private boolean vIsOpen;
		// Set when F start element is seen
		private boolean fIsOpen;
		// Set when an Inline String "is" is seen
		private boolean isIsOpen;

		private SheetHandler() {
//			this.sst = sst;
		}

		// XSSFSheetXMLHandlerを参照する
		public void startElement(String uri, String localName, String name,
				Attributes attributes) throws SAXException {

			if (isTextTag(name)) {
				vIsOpen = true;
				// Clear contents cache
				cellContent.setLength(0);
			} else if ("is".equals(name)) {
				// Inline string outer tag
				isIsOpen = true;
			} else if ("f".equals(name)) {
				// Clear contents cache
				formula.setLength(0);

				// Mark us as being a formula if not already
				if (cellDataType == xssfDataType.NUMBER) {
					cellDataType = xssfDataType.FORMULA;
				}

				// Decide where to get the formula string from
				String type = attributes.getValue("t");
				if (type != null && type.equals("shared")) {
					// Is it the one that defines the shared, or uses it?
					String ref = attributes.getValue("ref");
					// String si = attributes.getValue("si");

					if (ref != null) {
						// This one defines it
						// Save it somewhere
						fIsOpen = true;
					}
				} else {
					fIsOpen = true;
				}
			} else if ("row".equals(name)) {

				this.record = new ArrayList<String>();
				this.row = Integer.parseInt(attributes.getValue("r")) - 1;

			} else if("c".equals(name)) {	// c => cell

				this.cellDataType = xssfDataType.NUMBER;

				String cellType = attributes.getValue("t");
				String cellStyleStr = attributes.getValue("s");

				String cell = attributes.getValue("r");

				this.curColumn = this.getIndex(cell.replaceAll("\\d", ""));
				// 列のindexが連続していない場合
				if (this.preColumn + 1 != this.curColumn) {
					int loop = this.curColumn - this.preColumn - 1;
					for (int i = 0; i < loop; i++) {
						record.add(null);
					}
				}

				this.preColumn = this.curColumn;

				if ("b".equals(cellType))
					cellDataType = xssfDataType.BOOLEAN;
				else if ("e".equals(cellType))
					cellDataType = xssfDataType.ERROR;
				else if ("inlineStr".equals(cellType))
					cellDataType = xssfDataType.INLINE_STRING;
				else if ("s".equals(cellType))
					cellDataType = xssfDataType.SST_STRING;
				else if ("str".equals(cellType))
					cellDataType = xssfDataType.FORMULA;
				else if (cellStyleStr != null) {
					// Number, but almost certainly with a special style or format
					int styleIndex = Integer.parseInt(cellStyleStr);
					XSSFCellStyle style = stylesTable.getStyleAt(styleIndex);
					this.formatIndex = style.getDataFormat();
					this.formatString = style.getDataFormatString();
					if (this.formatString == null)
						this.formatString = BuiltinFormats.getBuiltinFormat(this.formatIndex);
				}
			}
		}

		public void endElement(String uri, String localName, String name)
				throws SAXException {



			// v => contents of a cell
			if (isTextTag(name)) {
				vIsOpen = false;

				// Process the value contents as required, now we have it all
				switch (cellDataType) {
				case BOOLEAN:
					char first = cellContent.charAt(0);
					cellValue = first == '0' ? "FALSE" : "TRUE";
//					record.add(this.column, cellValue);
					record.add(cellValue);
					break;

				case ERROR:
					cellValue = "ERROR:" + cellContent.toString();
//					record.add(this.column, cellValue);
					record.add(cellValue);
					break;

				case FORMULA:

					String fv = cellContent.toString();

					if (this.formatString != null) {
						try {
							// Try to use the value as a formattable number
							double d = Double.parseDouble(fv);
							cellValue = formatter.formatRawCellContents(d, this.formatIndex, this.formatString);
						} catch (NumberFormatException e) {
							// Formula is a String result not a Numeric one
							cellValue = fv;
						}
					} else {
						// No formating applied, just do raw value in all cases
						cellValue = fv;
					}
//					record.add(this.column, cellValue);
					record.add(cellValue);
					break;

				case INLINE_STRING:
					// TODO: Can these ever have formatting on them?
					XSSFRichTextString rtsi = new XSSFRichTextString(cellContent.toString());
					cellValue = rtsi.toString();
//					record.add(this.column, cellValue);
					record.add(cellValue);
					break;

				case SST_STRING:
					String sstIndex = cellContent.toString();
					try {
						int idx = Integer.parseInt(sstIndex);
						XSSFRichTextString rtss = new XSSFRichTextString(sst.getEntryAt(idx));
						cellValue = rtss.toString();
					} catch (NumberFormatException ex) {
						System.err.println("Failed to parse SST index '" + sstIndex + "': " + ex.toString());
					}
//					record.add(this.column, cellValue);
					record.add(cellValue);
					break;

				case NUMBER:
					String n = cellContent.toString();
					if (this.formatString != null) {

						if ("m/d/yy".equals(this.formatString)) {
							this.formatString = "yyyymmdd";
						}
						cellValue = formatter.formatRawCellContents(Double.parseDouble(n), this.formatIndex, this.formatString);

					} else
						cellValue = n;
//					record.add(this.column, cellValue);
					record.add(cellValue);
					break;

				default:
					cellValue = "(TODO: Unexpected type: " + cellDataType + ")";
//					record.add(this.column, cellValue);
					record.add(cellValue);
					break;
				}

			} else if ("c".equals(name)) {
				this.formatIndex = -1;
				this.formatString = null;
				this.cellDataType = null;
			} else if ("is".equals(name)) {
				isIsOpen = false;
			} else if ("row".equals(name)) {
				bl.processBusiness(sheetName, record, row);
			}
		}

		private boolean isTextTag(String name) {
			if ("v".equals(name)) {
				// Easy, normal v text tag
				return true;
			}
			if ("inlineStr".equals(name)) {
				// Easy inline string
				return true;
			}
			if ("t".equals(name) && isIsOpen) {
				// Inline string <is><t>...</t></is> pair
				return true;
			}
			// It isn't a text tag
			return false;
		}

		/**
		 * Captures characters only if a suitable element is open. Originally
		 * was just "v"; extended for inlineStr also.
		 */
		public void characters(char[] ch, int start, int length) throws SAXException {
			if (vIsOpen) {
				cellContent.append(ch, start, length);
			}
			if (fIsOpen) {
				formula.append(ch, start, length);
			}
		}

		private int getIndex(String column) {
			String temp = column.toUpperCase();
			int size = temp.length();
			char ch;
			int mi = 1;
			int ret = 0;
			for (int i = size - 1; i > -1; i--) {
				ch = temp.charAt(i);
				ret += mi * (((short) ch) - 64);
				mi = 26 * mi;
			}
			return ret;
		}


	}

	public void write(List<String[]> records) throws IOException {
		Workbook wb = new SXSSFWorkbook(100); // keep 100 rows in memory, exceeding rows will be flushed to disk
		Sheet sh = wb.createSheet();
		int rows = records.size();
		int columns = records.get(0).length;
		for(int rownum = 0; rownum < rows; rownum++){
			Row row = sh.createRow(rownum);
			for(int cellnum = 0; cellnum < columns; cellnum++){
				Cell cell = row.createCell(cellnum);
				cell.setCellValue(records.get(rownum)[cellnum]);
			}

		}

		FileOutputStream out = new FileOutputStream(this.outputFile);
		wb.write(out);
		out.close();
	}

	public String getOutputFile() {
		return outputFile;
	}

	public void setOutputFile(String outputFile) {
		this.outputFile = outputFile;
	}

}

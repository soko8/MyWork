package test;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.ss.util.CellRangeAddress;

public class ExcelUtility {

	public static void copyCell(HSSFCell srcCell, HSSFCell distCell) {

		distCell.setCellStyle(srcCell.getCellStyle());

		if (srcCell.getCellComment() != null) {
			distCell.setCellComment(srcCell.getCellComment());
		}

		int srcCellType = srcCell.getCellType();
		distCell.setCellType(srcCellType);

		if (srcCellType == HSSFCell.CELL_TYPE_NUMERIC) {

			if (HSSFDateUtil.isCellDateFormatted(srcCell)) {
				distCell.setCellValue(srcCell.getDateCellValue());
			} else {
				distCell.setCellValue(srcCell.getNumericCellValue());
			}

		} else if (srcCellType == HSSFCell.CELL_TYPE_STRING) {
			distCell.setCellValue(srcCell.getRichStringCellValue());
		} else if (srcCellType == HSSFCell.CELL_TYPE_BLANK) {
			// nothing
		} else if (srcCellType == HSSFCell.CELL_TYPE_BOOLEAN) {
			distCell.setCellValue(srcCell.getBooleanCellValue());
		} else if (srcCellType == HSSFCell.CELL_TYPE_ERROR) {
			distCell.setCellErrorValue(srcCell.getErrorCellValue());
		} else if (srcCellType == HSSFCell.CELL_TYPE_FORMULA) {
			distCell.setCellFormula(srcCell.getCellFormula());
		} else {
			// nothing
		}
	}

	// to same sheet
	public static void copyRows(HSSFSheet st, int startRow, int endRow, int pPosition) {
		int pStartRow = startRow - 1;
		int pEndRow = endRow - 1;
		int targetRowFrom;
		int targetRowTo;
		int columnCount;
		CellRangeAddress region = null;
		int i;
		int j;

		if (pStartRow == -1 || pEndRow == -1)
			return;

		// merged cells
		System.out.println(st.getNumMergedRegions());

		for (i = 0; i < st.getNumMergedRegions(); i++) {
			region = st.getMergedRegion(i);
			if ((region.getFirstRow() >= pStartRow) && (region.getLastRow() <= pEndRow)) {
				targetRowFrom = region.getFirstRow() - pStartRow + pPosition;
				targetRowTo = region.getLastRow() - pStartRow + pPosition;

				CellRangeAddress newRegion = region.copy();

				newRegion.setFirstRow(targetRowFrom);
				newRegion.setFirstColumn(region.getFirstColumn());
				newRegion.setLastRow(targetRowTo);
				newRegion.setLastColumn(region.getLastColumn());
				st.addMergedRegion(newRegion);
			}
		}
		// set the column height and value
		for (i = pStartRow; i <= pEndRow; i++) {
//			Util.copyRow(srcSheet, targetSheet, srcRow, targetSheet.createRow(srcRow.getRowNum()));
			HSSFRow sourceRow = st.getRow(i);
			columnCount = sourceRow.getLastCellNum();
			if (sourceRow != null) {
				HSSFRow newRow = st.createRow(pPosition + i);
				newRow.setHeight(sourceRow.getHeight());
				for (j = 0; j < columnCount; j++) {
					HSSFCell templateCell = sourceRow.getCell(j);
					if (templateCell != null) {
						HSSFCell newCell = newRow.createCell(j);
						copyCell(templateCell, newCell);
					}
				}
			}
		}
	}
}

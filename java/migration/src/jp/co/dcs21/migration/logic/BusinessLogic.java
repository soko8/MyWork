package jp.co.dcs21.migration.logic;

import java.util.List;

public interface BusinessLogic {

	public void processBusiness(String sheetName, List<String> record, int row);

}

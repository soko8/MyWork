package jp.co.dcs21.migration.utils;

import jp.co.dcs21.migration.logic.BusinessLogic;

public abstract class ExcelFileHandler implements FileHandler {

	protected String file = null;

	protected BusinessLogic bl = null;

	// public abstract void read() throws Exception;

	public void setFile(String file) {
		this.file = file;
	}

	public BusinessLogic getBl() {
		return bl;
	}

	public void setBl(BusinessLogic bl) {
		this.bl = bl;
	}

}

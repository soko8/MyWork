package jp.co.dcs21.migration.utils;

import java.util.List;

public class Config {

	/**
	 * @return the dbName
	 */
	public String getDbName() {
		return dbName;
	}

	/**
	 * @param dbName the dbName to set
	 */
	public void setDbName(String dbName) {
		this.dbName = dbName;
	}

	/**
	 * @return the url
	 */
	public String getUrl() {
		return url;
	}

	/**
	 * @param url the url to set
	 */
	public void setUrl(String url) {
		this.url = url;
	}

	/**
	 * @return the driverClass
	 */
	public String getDriverClass() {
		return driverClass;
	}

	/**
	 * @param driverClass the driverClass to set
	 */
	public void setDriverClass(String driverClass) {
		this.driverClass = driverClass;
	}

	/**
	 * @return the userName
	 */
	public String getUserName() {
		return userName;
	}

	/**
	 * @param userName the userName to set
	 */
	public void setUserName(String userName) {
		this.userName = userName;
	}

	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * @param password the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}

	/**
	 * @return the tableList
	 */
	public List<String> getTableList() {
		return tableList;
	}

	/**
	 * @param tableList the tableList to set
	 */
	public void setTableList(List<String> tableList) {
		this.tableList = tableList;
	}

	private String dbName = null;
	
	private String url = null;
	
	private String driverClass = null;
	
	private String userName = null;
	
	private String password = null;
	
	private List<String> tableList = null;
	
}

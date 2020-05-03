package jp.co.dcs21.migration.utils;

public interface Constants {

	public enum DBTYPE {
		  postgresql
		, oracle
		, db2
		, mysql
		, mssql
	}
	
	public static final String[][] ITEMTYPE = {
		/***********postgresql*******************/
		{"bpchar","varchar", "", ""}
		};
}

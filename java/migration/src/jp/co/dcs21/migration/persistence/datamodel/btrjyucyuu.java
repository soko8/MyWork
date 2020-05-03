package jp.co.dcs21.migration.persistence.datamodel;

import java.util.List;
import java.util.Map;

import jp.co.dcs21.migration.persistence.MasterInfo;

public class btrjyucyuu extends SuperTable {

	/*
	 * (non-Javadoc)
	 *
	 * @see jp.co.dcs21.migration.persistence.datamodel.Table#prepareValue(java.util.List, java.util.List, java.util.Map, java.util.Map)
	 */
	@Override
	public void prepareValue(List<String> record, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {

		super.commonPrepareValue(record, headerInfo, indexDictionary, romaji);

		// 依頼者ＩＤ
		Item item0 = this.table.get("iraisyaid");
//		item0.setColumnValue(MasterInfo.getCompanyId(record.get(headerInfo.indexOf("iraisyaid"))));
		item0.setColumnValue("12345");

		// 入力担当者ID
		Item item1 = this.table.get("nyuuryokutntid");
//		item1.setColumnValue(MasterInfo.getPersonId(record.get(headerInfo.indexOf("nyuuryokutntid"))));
		item1.setColumnValue("98765432");

		// 手配担当者ID
		Item item2 = this.table.get("tehaitntid");
//		item2.setColumnValue(MasterInfo.getPersonId(record.get(headerInfo.indexOf("tehaitntid"))));
		item2.setColumnValue("87654321");

	}

	@Override
	public String getTableName() {
		return "btrjyucyuu";
	}

	@Override
	public String[] getInsertSQL(List<String> record, List<String> preRecord, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {

		String preKanriNo = null == preRecord ? null : preRecord.get(headerInfo.indexOf("kanrino"));
		String curKanriNo = record.get(headerInfo.indexOf("kanrino"));
//		System.err.println("前管理Ｎｏ：" + preKanriNo + "   当管理ＮＯ：" + curKanriNo);
		if (curKanriNo.equals(preKanriNo)) {
			return null;
		}

		this.prepareValue(record, headerInfo, indexDictionary, romaji);

		String sql = super.getCommonInsertSQL();

		String[] ret = new String[1];

		ret[0] = sql;

		return ret;
	}

	/*private String getUpdateSql() {

		StringBuilder sql = new StringBuilder();

		sql.append("Update ").append(this.getTableName()).append(" Set ");

		return sql.toString();
	}*/
}

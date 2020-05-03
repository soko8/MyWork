package jp.co.dcs21.migration.persistence.datamodel;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.xml.sax.SAXException;

import jp.co.dcs21.migration.persistence.DbUtils;

public abstract class SuperTable implements Table {

	protected Map<String, Item> table = null;

//	private List<String> preRecord = null;

	public void initTable(Map<String, Item> table) {
		this.table = table;

	}

	public abstract void prepareValue(List<String> record, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji);

	public abstract String getTableName();

	public abstract String[] getInsertSQL(List<String> record, List<String> preRecord, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji);

	protected void commonPrepareValue(List<String> record, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {

		for (String column : this.table.keySet()) {
			Item  item = this.table.get(column);
			int index = headerInfo.indexOf(column);
			if (-1 < index) {
				item.setColumnValue(record.get(index));
			} else {
//				item.setColumnValue("");
				if ("numeric".equals(item.getColumnType())) {
					item.setColumnValue("0");
				} else {
					item.setColumnValue("");
				}
			}

		}
	}

	protected String getCommonInsertSQL() {

		StringBuilder sb_before = new StringBuilder(512);
		StringBuilder sb_after = new StringBuilder(512);

		sb_before.append("Insert into ").append(this.getTableName()).append(" (");

		sb_after.append(") Values (");

		Item item = null;
		String itemType = null;

		for (String column : this.table.keySet()) {

			sb_before.append(column).append(", ");

			item = this.table.get(column);
			itemType = item.getColumnType();

			/*if (null == item.getColumnValue()) {
				sb_after.append("null, ");
			} else {*/
				if ("numeric".equals(itemType)) {
					if (null == item.getColumnValue()) {
						sb_after.append("0, ");
//						System.err.println("$$$$$$$$$$$$$$$$$" + item.getColumnComment() + item.getColumnName());
					} else {
						sb_after.append(Integer.valueOf(item.getColumnValue())).append(", ");
					}
				} else {
					sb_after.append("'").append(item.getColumnValue()).append("', ");
				}
//			}

		}

		sb_before = sb_before.deleteCharAt(sb_before.length() - 2);
		sb_after = sb_after.deleteCharAt(sb_after.length() - 2);
		sb_after.append(")");

		return sb_before.append(sb_after).toString();
	}

	@Override
	public int insertRecord(List<String> record, List<String> preRecord, List<String> headerInfo, Map<String, Item> tableMeta, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) throws SQLException, ClassNotFoundException, IOException, SAXException {

		this.initTable(tableMeta);
		// this.prepareValue(record, headerInfo, indexDictionary, romaji);

		int i = 0;

		String[] sqls = this.getInsertSQL(record, preRecord, headerInfo, indexDictionary, romaji);

		if (null == sqls || 0 == sqls.length) {
			return i;
		}

		for (String sql : sqls) {

			if (null != sql && 0 < sql.length()) {
				System.out.println(sql);
				i += DbUtils.getInstacne().getConnection().createStatement().executeUpdate(sql);
			}
		}

		return i;
	}

	/*public List<String> getPreRecord() {
		return preRecord;
	}

	public void setPreRecord(List<String> preRecord) {
		this.preRecord = preRecord;
	}*/


	// public String getDeleteSQL() {
	// // TODO Auto-generated method stub
	// StringBuilder sb = new StringBuilder(50);
	// sb.append("Delete From ").append(this.tableName).append(" Where kanriNo='").append(this.table.get("kanriNo").getColumnValue()).append("'");
	// // String sql = "Delete From " + this.tableName + " Where kanriNo='" + this.table.get("kanriNo").getColumnValue() + "'";
	// return sb.toString();
	// }

}

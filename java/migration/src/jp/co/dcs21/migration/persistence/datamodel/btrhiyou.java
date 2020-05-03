package jp.co.dcs21.migration.persistence.datamodel;

import java.util.List;
import java.util.Map;

import jp.co.dcs21.migration.persistence.MasterInfo;

public class btrhiyou extends SuperTable {

	/* (non-Javadoc)
	 * @see jp.co.dcs21.migration.persistence.datamodel.Table#prepareValue(java.util.List, java.util.List, java.util.Map, java.util.Map)
	 */
	@Override
	public void prepareValue(List<String> record, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {

		super.commonPrepareValue(record, headerInfo, indexDictionary, romaji);

		// 金額
		Item item0 = this.table.get("kg");
		item0.setColumnValue(record.get(headerInfo.indexOf("kg[上払]")));

		// 費目ID			1:請求	2:支払
		Item item1 = this.table.get("himokuid");
//		item1.setColumnValue(MasterInfo.getExpenseId("上払", "1", record.get(headerInfo.indexOf("syuppatuyoteidt"))));
		item1.setColumnValue("1000");

		// 金額
		Item item2 = this.table.get("keirono");
		item2.setColumnValue(String.valueOf(Integer.valueOf(record.get(headerInfo.indexOf("keirono"))) + 1) );

	}

	@Override
	public String getTableName() {
		// TODO Auto-generated method stub
		return "btrhiyou";
	}

	@Override
	public String[] getInsertSQL(List<String> record, List<String> preRecord, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {


		this.prepareValue(record, headerInfo, indexDictionary, romaji);

		String sql = super.getCommonInsertSQL();

		String[] ret = new String[6];

		ret[0] = sql;

		// 下払金額
		// 金額
		Item item0 = this.table.get("kg");
		item0.setColumnValue(record.get(headerInfo.indexOf("kg[下払]")));

		// 費目ID			1:請求	2:支払
		Item item1 = this.table.get("himokuid");
//		item1.setColumnValue(MasterInfo.getExpenseId("下払", "2", record.get(headerInfo.indexOf("syuppatuyoteidt"))));
		item1.setColumnValue("2000");

		String sql2 = super.getCommonInsertSQL();
		ret[1] = sql2;




		// 燃料調整費上払
		item0.setColumnValue(record.get(headerInfo.indexOf("kg[燃料調整費上払]")));
//		item1.setColumnValue(MasterInfo.getExpenseId("燃料調整費上払", "1", record.get(headerInfo.indexOf("syuppatuyoteidt"))));
		item1.setColumnValue("3000");
		String sql3 = super.getCommonInsertSQL();
		ret[2] = sql3;


		// 燃料調整費下払
		item0.setColumnValue(record.get(headerInfo.indexOf("kg[燃料調整費下払]")));
//		item1.setColumnValue(MasterInfo.getExpenseId("燃料調整費下払", "2", record.get(headerInfo.indexOf("syuppatuyoteidt"))));
		item1.setColumnValue("4000");
		String sql4 = super.getCommonInsertSQL();
		ret[3] = sql4;




		// 経費名
		item0.setColumnValue(record.get(headerInfo.indexOf("kg[経費名]")));
//		item1.setColumnValue(MasterInfo.getExpenseId(record.get(headerInfo.indexOf("経費名")), "1", record.get(headerInfo.indexOf("syuppatuyoteidt"))));
		item1.setColumnValue("5000");
		String sql5 = super.getCommonInsertSQL();
		ret[4] = sql5;





		// キャンセル料
		item0.setColumnValue(record.get(headerInfo.indexOf("kg[キャンセル料]")));
//		item1.setColumnValue(MasterInfo.getExpenseId("キャンセル料", "1", record.get(headerInfo.indexOf("syuppatuyoteidt"))));
		item1.setColumnValue("6000");
		String sql6 = super.getCommonInsertSQL();
		ret[5] = sql6;

		return ret;
	}

}

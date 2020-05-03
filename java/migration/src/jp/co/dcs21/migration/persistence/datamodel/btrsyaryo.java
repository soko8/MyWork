package jp.co.dcs21.migration.persistence.datamodel;

import java.util.List;
import java.util.Map;

import jp.co.dcs21.migration.utils.StringUtils;

public class btrsyaryo extends SuperTable {

	/* (non-Javadoc)
	 * @see jp.co.dcs21.migration.persistence.datamodel.Table#prepareValue(java.util.List, java.util.List, java.util.Map, java.util.Map)
	 */
	@Override
	public void prepareValue(List<String> record, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {

		super.commonPrepareValue(record, headerInfo, indexDictionary, romaji);


		// 登録番号
		String torokuNo = record.get(headerInfo.indexOf("tourokunotimei+tourokunobunruino+tourokunohiragana+itirensiteino"));
		System.err.println("登録番号" + torokuNo);
		String[] torokuNoDetail = split(torokuNo);

		Item item0 = this.table.get("tourokunotimei");
		item0.setColumnValue(torokuNoDetail[0]);

		Item item1 = this.table.get("tourokunobunruino");
		item1.setColumnValue(torokuNoDetail[1]);

		Item item2 = this.table.get("tourokunohiragana");
		item2.setColumnValue(torokuNoDetail[2]);

		Item item3 = this.table.get("itirensiteino");
		item3.setColumnValue(torokuNoDetail[3]);


		// TODO
	}

	@Override
	public String getTableName() {
		// TODO Auto-generated method stub
		return "btrsyaryo";
	}

	@Override
	public String[] getInsertSQL(List<String> record, List<String> preRecord, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {
		// TODO Auto-generated method stub

		String preSyaryouno = null == preRecord ? null : preRecord.get(headerInfo.indexOf("syaryouno"));
//		String preSyaryouno = this.getPreRecord().get(headerInfo.indexOf("syaryouno"));
		String curSyaryouno = record.get(headerInfo.indexOf("syaryouno"));

		String preKanriNo = null == preRecord ? null : preRecord.get(headerInfo.indexOf("kanrino"));
		String curKanriNo = record.get(headerInfo.indexOf("kanrino"));

		if (curKanriNo.equals(preKanriNo) && curSyaryouno.equals(preSyaryouno)) {
			return null;
		}

		this.prepareValue(record, headerInfo, indexDictionary, romaji);

		String sql = super.getCommonInsertSQL();

		String[] ret = new String[1];

		ret[0] = sql;

		return ret;
	}

	private String[] split(String torokuNo) {

		String[] ret = new String[4];

		if (null == torokuNo || 0 == torokuNo.length()) {
			ret[0] = "";
			ret[1] = "";
			ret[2] = "";
			ret[3] = "";
			return ret;
		}

		Character ch = torokuNo.charAt(0);

		int i = 0;

		while (!StringUtils.isFullWidthNumber(ch)) {
			i++;
			ch = torokuNo.charAt(i);
		}
		ret[0] = torokuNo.substring(0, i);

		int nextStartIndex = i;

		while (StringUtils.isFullWidthNumber(ch)) {
			i++;
			ch = torokuNo.charAt(i);
		}
		ret[1] = torokuNo.substring(nextStartIndex, i);

		nextStartIndex = i;
		while (!StringUtils.isFullWidthNumber(ch)) {
			i++;
			ch = torokuNo.charAt(i);
		}
		ret[2] = torokuNo.substring(nextStartIndex, i);

		ret[3] = torokuNo.substring(i);

		return ret;
	}

}

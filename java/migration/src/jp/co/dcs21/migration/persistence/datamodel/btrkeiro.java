package jp.co.dcs21.migration.persistence.datamodel;

import java.util.List;
import java.util.Map;

import jp.co.dcs21.migration.persistence.MasterInfo;
import jp.co.dcs21.migration.utils.AddressUtils;
import jp.co.dcs21.migration.utils.StringUtils;

public class btrkeiro extends SuperTable {
	/* (non-Javadoc)
	 * @see jp.co.dcs21.migration.persistence.datamodel.Table#prepareValue(java.util.List, java.util.List, java.util.Map, java.util.Map)
	 */
	@Override
	public void prepareValue(List<String> record, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {

		super.commonPrepareValue(record, headerInfo, indexDictionary, romaji);

		// 発注先ID
		Item item0 = this.table.get("haccyuusakiid");
//		item0.setColumnValue(MasterInfo.getCompanyId(record.get(headerInfo.indexOf("haccyuusakiid"))));
		item0.setColumnValue("98765");




		// 納車先
		// 納車先電話番号
		Item item1 = this.table.get("tel");
		item1.setColumnValue(StringUtils.lpadString(record.get(headerInfo.indexOf("tel[納車先]")), 10, '0'));

		// 納車先住所
		String address = record.get(headerInfo.indexOf("todouhukencd+sikucyousonja+bantija+tatemononmja[納車先]"));
		String[] addressJa = address.split(" ");
		String[] addressEn = AddressUtils.getRomaji(address, " ", indexDictionary, romaji).get(1);

		Item item2 = this.table.get("todouhukencd");
		item2.setColumnValue(MasterInfo.getprovinceNo(addressJa[0]));

		Item item3 = this.table.get("sikucyousonja");
		item3.setColumnValue(addressJa[1]);

		Item item4 = this.table.get("bantija");
		item4.setColumnValue(addressJa[2]);

		Item item5 = this.table.get("tatemononmja");
		if (3 < addressJa.length) {
			item5.setColumnValue(addressJa[3]);
		} else {
			item5.setColumnValue("");
		}


		Item item6 = this.table.get("sikucyousonen");
		item6.setColumnValue(addressEn[1]);

		Item item7 = this.table.get("bantien");
		item7.setColumnValue(addressEn[2]);

		Item item8 = this.table.get("tatemononmen");
		if (3 < addressEn.length) {
			item8.setColumnValue(addressEn[3]);
		} else {
			item8.setColumnValue("");
		}

		// 経路番号
		Item item9 = this.table.get("keirono");
		String keirono = record.get(headerInfo.indexOf("keirono"));
		item9.setColumnValue(String.valueOf(Integer.valueOf(keirono) + 1));











	}

	@Override
	public String getTableName() {
		// TODO Auto-generated method stub
		return "btrkeiro";
	}

	@Override
	public String[] getInsertSQL(List<String> record, List<String> preRecord, List<String> headerInfo, Map<String, Map<String, Map<String, String>>> indexDictionary, Map<String, String[]> romaji) {

		this.prepareValue(record, headerInfo, indexDictionary, romaji);

		String sql = super.getCommonInsertSQL();

		String[] ret = new String[2];

		ret[0] = sql;

		String keirono = record.get(headerInfo.indexOf("keirono"));

		if (!"1".equals(keirono)) {
			return ret;
		}


		// 引取先電話番号
		Item item1 = this.table.get("tel");
		item1.setColumnValue(StringUtils.lpadString(record.get(headerInfo.indexOf("tel[引取先]")), 10, '0'));

		// 引取先住所
		String address = record.get(headerInfo.indexOf("todouhukencd+sikucyousonja+bantija+tatemononmja[引取先]"));
		String[] addressJa = address.split(" ");
		String[] addressEn = AddressUtils.getRomaji(address, " ", indexDictionary, romaji).get(1);

		Item item2 = this.table.get("todouhukencd");
		item2.setColumnValue(MasterInfo.getprovinceNo(addressJa[0]));

		Item item3 = this.table.get("sikucyousonja");
		item3.setColumnValue(addressJa[1]);

		Item item4 = this.table.get("bantija");
		item4.setColumnValue(addressJa[2]);

		Item item5 = this.table.get("tatemononmja");
		if (3 < addressJa.length) {
			item5.setColumnValue(addressJa[3]);
		} else {
			item5.setColumnValue("");
		}

		Item item6 = this.table.get("sikucyousonen");
		item6.setColumnValue(addressEn[1]);

		Item item7 = this.table.get("bantien");
		item7.setColumnValue(addressEn[2]);

		Item item8 = this.table.get("tatemononmen");
		if (3 < addressEn.length) {
			item8.setColumnValue(addressEn[3]);
		} else {
			item8.setColumnValue("");
		}

		// 経路番号
		Item item9 = this.table.get("keirono");

		item9.setColumnValue(String.valueOf(Integer.valueOf(keirono)));




		String sql2 = super.getCommonInsertSQL();
		ret[1] = sql2;

		return ret;
	}

}

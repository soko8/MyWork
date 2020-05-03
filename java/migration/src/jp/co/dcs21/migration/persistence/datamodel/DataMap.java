package jp.co.dcs21.migration.persistence.datamodel;

import java.util.HashMap;
import java.util.Map;

public class DataMap {

	private static Map<String, String> excel2table = new HashMap<String, String>();
	
	private static Map<String, String> table2excel = new HashMap<String, String>();
	
	static {
		excel2table.put("受注日", "jyucyuuDt");
		excel2table.put("手配日", "");
		excel2table.put("受注属性", "");
		excel2table.put("管理番号", "kanriNo");
		excel2table.put("明細番号", "");
		excel2table.put("経路番号", "");
		excel2table.put("経路明細番号", "");
		excel2table.put("キャンセルNo", "");
		excel2table.put("受注ステータス", "");
		excel2table.put("車台番号", "syataiNo");				// 車両トラン.車体番号
		excel2table.put("登録番号", "tourokuNoBunruiNo");		// 車両トラン.登録番号分類番号
		excel2table.put("車名", "syasyuNmJa");				// 車両トラン.車種名Ja
		excel2table.put("上払金額", "");						// 費用トラン.金額		費目マスタ.請求支払区分=1（請求）
		excel2table.put("下払金額", "");						// 費用トラン.金額		費目マスタ.請求支払区分=2（支払）
		excel2table.put("燃料調整費上払", "");					// 費用トラン.金額		費目マスタ.請求支払区分=1（請求）
		excel2table.put("燃料調整費下払", "");					// 費用トラン.金額		費目マスタ.請求支払区分=2（請求）
		excel2table.put("経費名", "");						// 費目マスタ.費目名Ja
		excel2table.put("経費請求金額", "");
		excel2table.put("赤字フラグ", "");
		excel2table.put("受注元名称", "");
		excel2table.put("受注元電話番号", "");
		excel2table.put("発注先名称", "");
		excel2table.put("発注先電話番号", "");
		excel2table.put("引取予定日", "");
		excel2table.put("納車予定日", "");
		excel2table.put("引取実績日", "");
		excel2table.put("引取実績更新日", "");
		excel2table.put("納車実績日", "");
		excel2table.put("納車実績更新日", "");
		excel2table.put("入力担当者", "");
		excel2table.put("入力担当者コード", "");
		excel2table.put("手配担当者", "");
		excel2table.put("手配担当者コード", "");
		excel2table.put("引取先電話番号", "");
		excel2table.put("引取先名称", "");
		excel2table.put("引取先住所", "");
		excel2table.put("引取先属性", "");
		excel2table.put("納車先電話番号", "");
		excel2table.put("納車先名称", "");
		excel2table.put("納車先住所", "");
		excel2table.put("納車先属性", "");
		excel2table.put("キャンセル", "");
		excel2table.put("キャンセル料", "");
		excel2table.put("キャンセルコメント", "");
		excel2table.put("車輌備考", "");
		excel2table.put("書類管理番号", "");
		excel2table.put("BBNo.", "");
		excel2table.put("部署区分", "");
		excel2table.put("手配確認部署", "");

	}

	/**
	 * @return the excel2table
	 */
	public Map<String, String> getExcel2table() {
		return excel2table;
	}

	/**
	 * @param excel2table the excel2table to set
	 */
	public void setExcel2table(Map<String, String> excel2table) {
		DataMap.excel2table = excel2table;
	}

	/**
	 * @return the table2excel
	 */
	public Map<String, String> getTable2excel() {
		return table2excel;
	}

	/**
	 * @param table2excel the table2excel to set
	 */
	public void setTable2excel(Map<String, String> table2excel) {
		DataMap.table2excel = table2excel;
	}

}

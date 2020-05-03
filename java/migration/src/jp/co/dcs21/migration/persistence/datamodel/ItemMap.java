package jp.co.dcs21.migration.persistence.datamodel;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import jp.co.dcs21.migration.utils.PropUtils;

public class ItemMap {

	private static String file = "ItemMap.properties";


	private static Map<String, String> romaji2kanji = new HashMap<String, String>();

	private static Properties kanji2romaji = null;

	public ItemMap(String file) {
		ItemMap.file = file;
	}

	public static void init() throws FileNotFoundException, IOException {
		kanji2romaji = PropUtils.loadFromFile(file);
	}


	static {



		/*kanji2romaji.put("受注日", "jyucyuuDt");				// 受注トラン.受注日
		kanji2romaji.put("手配日", "");						// ==受注トラン.受注日  若しくは　追加する？
		kanji2romaji.put("受注属性", "");						//　focusシステムではない
		kanji2romaji.put("管理番号", "kanriNo");				// 管理番号
		kanji2romaji.put("明細番号", "");						//　車両トラン.車両番号
		kanji2romaji.put("経路番号", "");						// focusシステムではない　再確認（要るかどうか）
		kanji2romaji.put("経路明細番号", "keiroNo");			// 経路トラン.経路番号
		kanji2romaji.put("キャンセルNo", "");					// 車両トラン.削除フラグ（要確認）
		kanji2romaji.put("受注ステータス", "");					//　受注トランに追加する？依頼主ステータス  協力会社ステータス
		kanji2romaji.put("車台番号", "syataiNo");				// 車両トラン.車体番号
		kanji2romaji.put("登録番号", "tourokuNoBunruiNo");		// 車両トラン.登録番号地名　＋登録番号分類番号 + 登録番号ひらがな + 一連指定番号
		kanji2romaji.put("車名", "syasyuNmJa");				// 車両トラン.車種名Ja
		kanji2romaji.put("上払金額", "");						// 費用トラン.金額		費目マスタ.請求支払区分=1（請求）
		kanji2romaji.put("下払金額", "");						// 費用トラン.金額		費目マスタ.請求支払区分=2（支払）
		kanji2romaji.put("燃料調整費上払", "");					// 費用トラン.金額		費目マスタ.請求支払区分=1（請求）
		kanji2romaji.put("燃料調整費下払", "");					// 費用トラン.金額		費目マスタ.請求支払区分=2（請求）
		kanji2romaji.put("経費名", "");						// 費目マスタ.費目名Ja
		kanji2romaji.put("経費請求金額", "");					// 費用トラン.金額		費目マスタ.請求支払区分=1（請求）
		kanji2romaji.put("赤字フラグ", "");						// focusシステムではない　再確認（要るかどうか）
		kanji2romaji.put("受注元名称", "");					// 受注トラン.依頼者ID
		kanji2romaji.put("受注元電話番号", "");					//
		kanji2romaji.put("発注先名称", "");					// 経路トラン.発注先ID
		kanji2romaji.put("発注先電話番号", "");					//
		kanji2romaji.put("引取予定日", "");					// 経路トラン.出発予定日
		kanji2romaji.put("納車予定日", "");					// 経路トラン.到着予定日
		kanji2romaji.put("引取実績日", "");					// 経路トランに追加するか？
		kanji2romaji.put("引取実績更新日", "");
		kanji2romaji.put("納車実績日", "");
		kanji2romaji.put("納車実績更新日", "");
		kanji2romaji.put("入力担当者", "");					//受注トラン入力担当者ID
		kanji2romaji.put("入力担当者コード", "");
		kanji2romaji.put("手配担当者", "");
		kanji2romaji.put("手配担当者コード", "");
		kanji2romaji.put("引取先電話番号", "");					//　経路トラン.TEL
		kanji2romaji.put("引取先名称", "");					//　場所名Ja
		kanji2romaji.put("引取先住所", "");					//　経路トラン.都道府県コード～建物名Ja
		kanji2romaji.put("引取先属性", "");					//　経路トラン.場所区分
		kanji2romaji.put("納車先電話番号", "");
		kanji2romaji.put("納車先名称", "");
		kanji2romaji.put("納車先住所", "");
		kanji2romaji.put("納車先属性", "");
		kanji2romaji.put("キャンセル", "");						// 車両トラン.削除フラグ（要確認）
		kanji2romaji.put("キャンセル料", "");					// 費用トラン.金額		費目マスタ.請求支払区分=1（請求）
		kanji2romaji.put("キャンセルコメント", "");					// 車両トラン.車両備考
		kanji2romaji.put("車輌備考", "");						// 車両トラン.車両備考
		kanji2romaji.put("書類管理番号", "");					// focusシステムではない　再確認（要るかどうか）
		kanji2romaji.put("BBNo.", "");						// ？？
		kanji2romaji.put("部署区分", "");						// focusシステムではない　再確認（要るかどうか）
		kanji2romaji.put("手配確認部署", "");					// focusシステムではない　再確認（要るかどうか）
*/
	}

	/**
	 * @return the kanji2romaji
	 * @throws IOException
	 * @throws FileNotFoundException
	 */
	public static String getKanji2romaji(String kanji) throws FileNotFoundException, IOException {
		return kanji2romaji.getProperty(kanji);
	}



	/**
	 * @return the romaji2kanji
	 */
	public static Map<String, String> getRomaji2kanji() {
		return romaji2kanji;
	}

}

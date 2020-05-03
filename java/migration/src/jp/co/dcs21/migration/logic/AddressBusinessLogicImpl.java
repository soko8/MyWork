package jp.co.dcs21.migration.logic;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AddressBusinessLogicImpl implements BusinessLogic {



	private boolean isRoma = false;

	/**
	 * 列のインデックスが0から開始する
	 * [0]--->県
	 * [1]--->区
	 * [2]--->町
	 * [3]--->郵便番号
	 */
	private static final int[] columnsId_漢字 = {6, 7, 8, 2};

	/**
	 * key		県（漢字）
	 * value	区のmap
	 * 			key		区（漢字）
	 * 			value	町のMap
	 * 					key		町（漢字）
	 * 					value	郵便番号
	 */
	private Map<String, Map<String, Map<String, String>>> indexDictionary = new HashMap<String, Map<String, Map<String, String>>>();

	/**
	 * 列のインデックスが0から開始する
	 * [0]--->郵便番号
	 * [1]--->県
	 * [2]--->区
	 * [3]--->町
	 */
	private static final int[] columnsId_ローマ = {1, 4, 3, 2};

	/**
	 * key 		郵便番号
	 * value	ローマ字
	 * 		String[0] 県
	 * 		String[1] 区
	 * 		String[2] 町
	 */
	private Map<String, String[]> romaji = new HashMap<String, String[]>();

	@Override
	public void processBusiness(String sheetName, List<String> record, int row) {

		if (!this.isRoma) {
			// 漢字CSVファイルの場合
			String 県 = record.get(columnsId_漢字[0]).replace("\"", "");
			String 区 = record.get(columnsId_漢字[1]).replace("\"", "");
			String 町 = record.get(columnsId_漢字[2]).replace("\"", "");
			String 郵便番号 = record.get(columnsId_漢字[3]).replace("\"", "");

			Map<String, Map<String, String>> map_区町 = indexDictionary.get(県);

			// 区町list
			if (null == map_区町) {
				map_区町 = new HashMap<String, Map<String, String>>();
				indexDictionary.put(県, map_区町);
			}

			Map<String, String> map_町郵番 = map_区町.get(区);

			if (null == map_町郵番) {
				map_町郵番 = new HashMap<String, String>();
				map_区町.put(区, map_町郵番);
			}

			while (map_町郵番.containsValue(郵便番号)) {
				郵便番号 = 郵便番号 + "0";
			}
			map_町郵番.put(町, 郵便番号);

		} else {
			//　ローマ字CSVファイルの場合
			int size = columnsId_ローマ.length;
			String[] roma = new String[size-1];
			for (int i = 1; i < size; i++) {
				roma[i-1] = record.get(columnsId_ローマ[i]).replace("\"", "");
			}
			String postNo = record.get(columnsId_ローマ[0]).replace("\"", "");
			while (romaji.containsKey(postNo)) {
				postNo = postNo + "0";
			}
			romaji.put(postNo, roma);
		}

	}

	public void setRoma(boolean isRoma) {
		this.isRoma = isRoma;
	}



	public Map<String, String[]> getRomaji() {
		return romaji;
	}

//	public void setRomaji(Map<String, String[]> romaji) {
//		this.romaji = romaji;
//	}

	/**
	 * @return the indexDictionary
	 */
	public Map<String, Map<String, Map<String, String>>> getIndexDictionary() {
		return indexDictionary;
	}

//	/**
//	 * @param indexDictionary the indexDictionary to set
//	 */
//	public void setIndexDictionary(Map<String, Map<String, List<String[]>>> indexDictionary) {
//		this.indexDictionary = indexDictionary;
//	}
}

package jp.co.dcs21.migration.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class AddressUtils {

	private static Map<String, String> special = new HashMap<String, String>();

	private static Map<String, String> specialMap = new HashMap<String, String>();

	static {
		special.put("前原市", "MAEBARU-SHI");
		specialMap.put("前原市", "糸島市");

		special.put("鳩ヶ谷市", "HATOGAYA-SHI");
		specialMap.put("鳩ヶ谷市", "川口市");

		special.put("鹿島郡鉾田町", "HOKODEN-CHO KASHIMA-GUN");
		specialMap.put("鹿島郡鉾田町", "鉾田市");
	}

	/**
	 *
	 * @param address
	 * @param delimiter
	 * @param indexDictionary
	 * 	 		key		県（漢字）
	 * 			value	区のmap
	 * 					key		区（漢字）
	 * 					value	町のmap
	 * 							key		町（漢字）
	 * 							value	郵便番号
	 * @param romaji
	 * 			key 	郵便番号
	 * 			value	ローマ字
	 * 					String[0] 県
	 * 					String[1] 区
	 * 					String[2] 町
	 * @return List
	 * 		List(0)-->住所漢字
	 * 		List(1)-->住所ローマ字
	 *
	 */
	public static List<String[]> getRomaji(
			String address
			, String delimiter
			, Map<String, Map<String, Map<String, String>>> indexDictionary
			, Map<String, String[]> romaji) {

		if (null == address || 0 == address.length()) {
			return null;
		}

		List<String[]> ret = new ArrayList<String[]>();

		String[] 住所_漢字 = address.split(delimiter);

		ret.add(住所_漢字);

		if (住所_漢字.length < 3) {
			return ret;
		}

		String[] 住所_ローマ字 = new String[住所_漢字.length];

		String 県 = 住所_漢字[0];
		String 区 = 住所_漢字[1].replaceAll("　", "").trim();
		String 町 = 住所_漢字[2].replaceAll("　", "").trim();

		Map<String, String> 町郵番Map = indexDictionary.get(県).get(区);

		boolean specialflg = false;

		// 特別なケースの場合
		if (null == 町郵番Map) {
			if (specialMap.keySet().contains(区)) {
				町郵番Map = indexDictionary.get(県).get(specialMap.get(区));
				if (null != 町郵番Map) {
					specialflg = true;
				}
			}
		}

		// 市と区がスペースで区切りしている場合		横浜市 戸塚区
		if (null == 町郵番Map) {
			if (0 < 町.indexOf("区")) {
				String[] tmp = 町.split("区");
				区 = 区 + tmp[0] + "区";
				町 = tmp[1];
				町郵番Map = indexDictionary.get(県).get(区);

				if (null == 町郵番Map && 0 < 区.indexOf("市") && 0 < 区.indexOf("区")) {

					return ret;		// エラーデータ
				}


			}
		}

		// 埼玉県 北葛飾郡 松伏町大字魚沼70-1
		if (null == 町郵番Map) {
			if (区.endsWith("郡")  && 0 < 町.indexOf("町")) {
				String[] tmp = 町.split("町");
				区 = 区 + tmp[0] + "町";
				町 = tmp[1];
				町郵番Map = indexDictionary.get(県).get(区);

			}
		}


		// 市区と町がスペースで区切りしていない場合 			埼玉県 八潮市緑町
		if (null == 町郵番Map) {

			if (区.endsWith("市") || 区.endsWith("区") || 区.endsWith("郡") || 区.endsWith("町") || 区.endsWith("村")) {

			} else {
				List<Character> skgts = new ArrayList<Character>(5);
				skgts.add('市');
				skgts.add('区');
				skgts.add('郡');
				skgts.add('町');
				skgts.add('村');

				for (int i = 区.length() - 1; 0 < i; i--) {
					if (skgts.contains(区.charAt(i))) {
						町 = 区.substring(i+1) + 町;
						区 = 区.substring(0, i+1);
						break;
					}
				}
			}

			if (0 < 区.indexOf("市") && 0 < 区.indexOf("区") && 0 < 区.indexOf("町")) {
				String[] sk = 区.split("市");
				町郵番Map = indexDictionary.get(県).get(sk[0] + "市");

				if (null == 町郵番Map) {
					sk = 区.split("区");
					町郵番Map = indexDictionary.get(県).get(sk[0] + "区");

					if (null == 町郵番Map) {
						return ret;
					} else {
						区 = sk[0] + "区";
						町 = sk[1] + 町;
					}
				} else {
					区 = sk[0] + "市";
					町 = sk[1] + 町;
				}
			}

			// 市区・市町・区町・郡町・郡村
			if (0 < 区.indexOf("市") && 区.indexOf("市") < 区.length()-1) {
				String[] sk = 区.split("市");
				区 = sk[0] + "市";
				町郵番Map = indexDictionary.get(県).get(区);

				if (null == 町郵番Map) {
					区 = 区 + sk[1];
					町郵番Map = indexDictionary.get(県).get(区);

					if (null == 町郵番Map) {
						return ret;		// エラーデータ
					}
				} else {
					町 = sk[1] + 町;
				}

			} else if (0 < 区.indexOf("区") && 区.indexOf("区") < 区.length()-1) {

				String[] sk = 区.split("区");
				区 = sk[0] + "区";
				町郵番Map = indexDictionary.get(県).get(区);

				if (null == 町郵番Map) {
					区 = 区 + sk[1];
					町郵番Map = indexDictionary.get(県).get(区);

					if (null == 町郵番Map) {
						return ret;		// エラーデータ
					}
				} else {
					町 = sk[1] + 町;
				}
			} else if (0 < 区.indexOf("郡") && 区.indexOf("郡") < 区.length()-1) {
				String[] sk = 区.split("郡");
				区 = sk[0] + "郡";
				町郵番Map = indexDictionary.get(県).get(区);

				if (null == 町郵番Map) {
					区 = 区 + sk[1];
					町郵番Map = indexDictionary.get(県).get(区);

					if (null == 町郵番Map) {
						return ret;		// エラーデータ
					}
				} else {
					町 = sk[1] + 町;
				}
			}

			// 中央区が漏れている場合		相模原市 田名塩田
			// 横浜市が漏れている場合		神奈川県 泉区和泉町

			if (null == 町郵番Map) {
				Set<String> kuSet = indexDictionary.get(県).keySet();
				for (String ku : kuSet) {
					// 曖昧検索
//					if (-1 < ku.indexOf(区)) {
					if ((ku.startsWith(区) || ku.endsWith(区)) && contains(indexDictionary.get(県).get(ku), 町)) {
						町郵番Map = indexDictionary.get(県).get(ku);

					}

					// 市が漏れている場合		横浜緑区
					if (null == 町郵番Map) {
						StringBuilder sb = new StringBuilder(ku);
						int index = ku.indexOf("市");
						if (0 < index) {
							sb.deleteCharAt(index);
							if (-1 < sb.toString().indexOf(区)) {
								町郵番Map = indexDictionary.get(県).get(ku);

							}
						}


						if (null == 町郵番Map) {
							sb = new StringBuilder(ku);
							index = ku.indexOf("区");
							if (0 < index) {
								sb.deleteCharAt(index);
								if (-1 < sb.toString().indexOf(区)) {
									町郵番Map = indexDictionary.get(県).get(ku);

								}
							}

						}

						if (null == 町郵番Map) {
							sb = new StringBuilder(ku);
							index = ku.indexOf("郡");
							if (0 < index) {
								sb.deleteCharAt(index);
								if (-1 < sb.toString().indexOf(区)) {
									町郵番Map = indexDictionary.get(県).get(ku);

								}
							}

						}

					}
				}
			}

			// 特別なケースの場合
			if (null == 町郵番Map) {
				if (specialMap.keySet().contains(区)) {
					町郵番Map = indexDictionary.get(県).get(specialMap.get(区));
					if (null != 町郵番Map) {
						specialflg = true;
					}
				}
			}

		}


		if (null == 町郵番Map) {
			if (区.startsWith("大阪府")) {
				区 = 区.substring(3);
				町郵番Map = indexDictionary.get(県).get(区);
			}
		}

		// 神奈川県 横浜氏青葉区美しが丘 ３‐２２‐５
		if (null == 町郵番Map) {
			String repku = 区.replaceAll("氏", "市");
			町郵番Map = indexDictionary.get(県).get(repku);
		}

		if (null == 町郵番Map) {
			return ret;
		}

		String 郵便番号 = null;
		boolean found = false;

		if (-1 < 町.indexOf("粟の宮")) {
			町 = 町.replaceAll("粟の宮", "粟宮");
		}


		String sub町_実績_before = 町.substring(0, getEndIndex(町));
		String sub町_csv_before = null;

		String[] ローマ字 = null;


		Set<String> 町Set = 町郵番Map.keySet();
		for (String key_町 : 町Set) {

			sub町_csv_before = key_町.substring(0, getEndIndex(key_町));

			if (町.equals(key_町)) {
				found = true;
				郵便番号 = 町郵番Map.get(key_町);
				住所_ローマ字 = romaji.get(郵便番号);
				break;
			}

			if (sub町_実績_before.equals(sub町_csv_before)) {
				found = true;
				郵便番号 = 町郵番Map.get(key_町);
				ローマ字 = romaji.get(郵便番号);
				住所_ローマ字[0] = ローマ字[0];
				住所_ローマ字[1] = ローマ字[1];
				住所_ローマ字[2] = ローマ字[2].substring(0, getEndIndex(ローマ字[2]));
				住所_ローマ字[2] = 住所_ローマ字[2] + 町.substring(getEndIndex(町));
				break;
			}

			if (町.startsWith("大字")) {
				String tyo_tmp = 町.substring(2);
				if (tyo_tmp.equals(key_町)) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					ローマ字 = romaji.get(郵便番号);
					住所_ローマ字[0] = ローマ字[0];
					住所_ローマ字[1] = ローマ字[1];
					住所_ローマ字[2] = "OAZA" + ローマ字[2];

					break;
				}

				tyo_tmp = sub町_実績_before.substring(2);
				if (tyo_tmp.equals(sub町_csv_before)) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					ローマ字 = romaji.get(郵便番号);
					住所_ローマ字[0] = ローマ字[0];
					住所_ローマ字[1] = ローマ字[1];
					住所_ローマ字[2] = "OAZA" + ローマ字[2].substring(0, getEndIndex(ローマ字[2]));
					住所_ローマ字[2] = 住所_ローマ字[2] + 町.substring(getEndIndex(町));
					break;
				}
			}

			// ヶ-->が			富士見ヶ丘-->富士見が丘
			if (0 < 町.indexOf("ヶ")) {
				String tyo_tmp = 町.replaceAll("ヶ", "が");
				if (tyo_tmp.equals(key_町)) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					住所_ローマ字 = romaji.get(郵便番号);
					break;
				}

				tyo_tmp = sub町_実績_before.replaceAll("ヶ", "が");
				if (tyo_tmp.equals(sub町_csv_before)) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					ローマ字 = romaji.get(郵便番号);
					住所_ローマ字[0] = ローマ字[0];
					住所_ローマ字[1] = ローマ字[1];
					住所_ローマ字[2] = ローマ字[2].substring(0, getEndIndex(ローマ字[2]));
					住所_ローマ字[2] = 住所_ローマ字[2] + 町.substring(getEndIndex(町));
					break;
				}
			}


			// ヶ-->ケ			川原ヶ谷-->川原ケ谷
			if (0 < 町.indexOf("ヶ")) {
				String tyo_tmp = 町.replaceAll("ヶ", "ケ");
				if (tyo_tmp.equals(key_町)) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					住所_ローマ字 = romaji.get(郵便番号);
					break;
				}

				tyo_tmp = sub町_実績_before.replaceAll("ヶ", "ケ");
				if (tyo_tmp.equals(sub町_csv_before)) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					ローマ字 = romaji.get(郵便番号);
					住所_ローマ字[0] = ローマ字[0];
					住所_ローマ字[1] = ローマ字[1];
					住所_ローマ字[2] = ローマ字[2].substring(0, getEndIndex(ローマ字[2]));
					住所_ローマ字[2] = 住所_ローマ字[2] + 町.substring(getEndIndex(町));
					break;
				}
			}

			// 町が漏れっている場合
			if (sub町_実績_before.indexOf("町") < 0 && 0 < key_町.indexOf("町")) {
				StringBuilder sb = new StringBuilder(key_町);
				sb.deleteCharAt(key_町.indexOf("町"));
				String tyo_tmp_csv = sb.toString();

				if (町.equals(tyo_tmp_csv)) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					住所_ローマ字 = romaji.get(郵便番号);
					break;
				}

				if (sub町_実績_before.equals(tyo_tmp_csv.substring(0, getEndIndex(tyo_tmp_csv)))) {
					found = true;
					郵便番号 = 町郵番Map.get(key_町);
					ローマ字 = romaji.get(郵便番号);
					住所_ローマ字[0] = ローマ字[0];
					住所_ローマ字[1] = ローマ字[1];
					住所_ローマ字[2] = ローマ字[2].substring(0, getEndIndex(ローマ字[2]));
					住所_ローマ字[2] = 住所_ローマ字[2] + 町.substring(getEndIndex(町));
					break;
				}
			}

		}

		// 曖昧検索
		if (!found) {

			int preMatchings = 0;
			int curMatchings = 0;
			String index = null;

			String prefix = "";

			if (町.startsWith("大字")) {
				sub町_実績_before = sub町_実績_before.substring(2);
				prefix = "OAZA";
			}

			for (String key_町 : 町Set) {

				sub町_csv_before = key_町.substring(0, getEndIndex(key_町));

				if (0 < sub町_csv_before.length() && (sub町_実績_before.startsWith(sub町_csv_before)
					|| sub町_実績_before.replaceAll("ヶ", "が").startsWith(sub町_csv_before)
					|| sub町_実績_before.replaceAll("ヶ", "ケ").startsWith(sub町_csv_before))) {

					curMatchings = sub町_csv_before.length();

					if (preMatchings < curMatchings) {
						index = key_町;
					}

					preMatchings = curMatchings;

				}

			}

			if (null != index && 0 < index.length()) {

				found = true;
				郵便番号 = 町郵番Map.get(index);
				ローマ字 = romaji.get(郵便番号);
				住所_ローマ字[0] = ローマ字[0];
				住所_ローマ字[1] = ローマ字[1];
				住所_ローマ字[2] = prefix + ローマ字[2].substring(0, getEndIndex(ローマ字[2]));

				住所_ローマ字[2] = 住所_ローマ字[2] + 町.substring(index.substring(0, getEndIndex(index)).length());
			}
		}

		if (!found) {
			String key = 町Set.iterator().next();
			郵便番号 = 町郵番Map.get(key);
			ローマ字 = romaji.get(郵便番号);
			住所_ローマ字[0] = ローマ字[0];
			住所_ローマ字[1] = ローマ字[1];
			住所_ローマ字[2] = 町;
		}

		if (specialflg) {
			住所_ローマ字[1] = special.get(区);
		}

		ret.add(住所_ローマ字);

		return ret;
	}

	private static boolean contains(Map<String, String> tyouMap, String tyou) {

		String key = tyou.substring(0, getEndIndex(tyou));

		for (String t : tyouMap.keySet()) {
			if (-1 < t.indexOf(key)) {
				return true;
			}
		}

		return false;
	}

	private static int getEndIndex(String str) {

		String temp = str.replaceAll("[0-9\\(\\)０-９（）]", "=");

		int ret = temp.indexOf('=');

		if (ret < 0) {
			return str.length();
		}

		return ret;
	}
}

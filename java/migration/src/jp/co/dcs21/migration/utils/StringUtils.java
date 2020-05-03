package jp.co.dcs21.migration.utils;

public class StringUtils {

	public static String lpadString(String str, int length, char fill) {

		if (null == str) {
			str = "";
		}

		int loop = length - str.length();

		StringBuilder sb = new StringBuilder();

		for (int i = 0; i < loop; i++) {
			sb.append(fill);
		}
		sb.append(str);

		return sb.toString();
	}

	public static boolean isFullWidthNumber(Character ch) {

		String str = String.valueOf(ch);

		return str.matches("[０-９]");

	}

}

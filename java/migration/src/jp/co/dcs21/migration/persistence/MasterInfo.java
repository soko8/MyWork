package jp.co.dcs21.migration.persistence;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.xml.sax.SAXException;

public class MasterInfo {

	private static Map<String, String> people = new HashMap<String, String>();

	private static Map<String, String> company = new HashMap<String, String>();

	private static Map<String, List<String[]>> expense = new HashMap<String, List<String[]>>();

	private static Map<String, String> provinceNo = new HashMap<String, String>();


	public static void init() throws SQLException, ClassNotFoundException, IOException, SAXException {

		Statement ps = DbUtils.getInstacne().getConnection().createStatement();

		//　会社マスタ（英語の対応）
		ResultSet rs = ps.executeQuery("select kaisyaid, kaisyakbn, kaisyanmja, kaisyanmen, kaisyanmzh from bmkaisya");
		while (rs.next()) {
			company.put(rs.getString("kaisyanmja"), rs.getString("kaisyaid"));
		}

		// 担当者マスタ(会員マストと関係ある？英語の対応？)
		rs = ps.executeQuery("select userid, tntnmja from bmtnt");
		while (rs.next()) {
			people.put(rs.getString("tntnmja"), rs.getString("userid"));
		}

		// 費目マスタ
		rs = ps.executeQuery("select himokuid, tekiyoukikanfrom, tekiyoukikanto, himokunmja, seikyuusiharaikbn from bmhimoku");
		String himoku = null;
		List<String[]> sameHimokuList = null;
		String[] himokuid = null;
		while (rs.next()) {
			himoku = rs.getString("himokunmja") + "," + rs.getString("seikyuusiharaikbn");
			sameHimokuList = expense.get(himoku);
			if (null == sameHimokuList) {
				sameHimokuList = new ArrayList<String[]>();
				expense.put(himoku, sameHimokuList);
			}
			himokuid = new String[3];
			himokuid[0] = rs.getString("tekiyoukikanfrom");
			himokuid[1] = rs.getString("tekiyoukikanto");
			himokuid[2] = rs.getString("himokuid");
			sameHimokuList.add(himokuid);
		}

		// 都道府県コード
		rs = ps.executeQuery("select code, nameja from amcode where groupid = 'Ac01'");
		while (rs.next()) {
			provinceNo.put(rs.getString("nameja"), rs.getString("code"));
		}
	}

	public static String getCompanyId(String companyName) {
		return company.get(companyName);
	}

	public static String getPersonId(String personName) {
		return people.get(personName);
	}

	public static String getExpenseId(String expenseName, String expenseType, String date) {

		List<String[]> himokuIdList = expense.get(expenseName + "," + expenseType);

		if (null == himokuIdList || 0 == himokuIdList.size()) {
			return null;
		}

		int size = himokuIdList.size();
		if (1 == size) {
			return himokuIdList.get(0)[2];
		}

		for (int i = 0; i < size; i++) {
			if (himokuIdList.get(i)[0].compareTo(date) <= 0 && date.compareTo(himokuIdList.get(i)[1]) <= 0) {
				return himokuIdList.get(i)[2];
			}
		}

		return null;
	}

	public static String getprovinceNo(String provinceName) {
		return provinceNo.get(provinceName);
	}
}

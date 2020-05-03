package jp.co.dcs21.migration;

import jp.co.dcs21.migration.logic.AddressBusinessLogicImpl;
import jp.co.dcs21.migration.utils.CsvHandler;
import jp.co.dcs21.migration.utils.XlsxHandler;


public class ttttt {

	/**
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

//		DbUtils util = DbUtils.getInstacne();
//		System.err.println(String.format("%a9s", "12"));
//		System.err.println(ttttt.class.getName());
		try {

			AddressBusinessLogicImpl address = new AddressBusinessLogicImpl();
			CsvHandler fh = new CsvHandler("c:/temp/KEN_ALL.CSV", address);
			fh.setCharsetName("SJIS");
			fh.read();
//			AddressBusinessLogicImpl romaji = new AddressBusinessLogicImpl();
			address.setRoma(true);
			((CsvHandler) fh).setFile("c:/temp/KEN_ALL_ROME.CSV");
			fh.read();



			sssss testbl = new sssss();
			testbl.setIndexDictionary(address.getIndexDictionary());
			testbl.setRomaji(address.getRomaji());
			XlsxHandler testfh = new XlsxHandler("c:/temp/20120626_実績データ.xlsx", testbl);
			testfh.setOutputFile("C:/soukou/result.xlsx");
			System.out.println("&&&&&&&&&&&&&&&&&&&&&&");
			testfh.read();
			testfh.write(testbl.getResult());
			System.out.println("処理完了");
//			FileHandler fh_romaji = new CsvHandler("c:/KEN_ALL_ROME.CSV", kanji);

//			System.err.println((short)'A');
			/*Configs confs = xmlUtils.parseXmlForDB();

			System.err.println(confs.getConfigs().size());

			Config conf = confs.getConfigs().get(0);
			System.err.println(conf.getDbName());
			System.err.println(conf.getDriverClass());
			System.err.println(conf.getPassword());
			System.err.println(conf.getUrl());
			System.err.println(conf.getUserName());


			List<String> tl = xmlUtils.parseXmlForTableList();
			System.err.println(tl.size());
			System.err.println(tl.get(0));
			System.err.println(tl.get(1));*/

//			XlsUtils xlsUtil = new XlsUtils("C:/soukou/20120626_実績データ.xls");

//			XlsUtils xlsUtil = new XlsUtils("C:/soukou/Book2.xls");

//			xlsUtil.read();

//			XlsxHandler ut = new XlsxHandler("C:/soukou/20120626_実績データ.xlsx");
//			System.err.println("sdf123".replaceAll("\\d", ""));
//			ut.read();

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		/*} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();*/
		}
	}

	public static int getIndex(String column) {
		String temp = column.toUpperCase();
		int size = temp.length();
		char ch;
		int mi = 1;
		int ret = 0;
		for (int i = size - 1; i > -1; i--) {
			ch = temp.charAt(i);
			ret += mi * (((short) ch) - 64);
			mi = 26 * mi;
		}
		return ret;
	}
}

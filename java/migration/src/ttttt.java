import java.util.ArrayList;
import java.util.List;

import jp.co.dcs21.migration.utils.XlsxUtils;



public class ttttt {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub

//		DbUtils util = DbUtils.getInstacne();
		
		try {
			
			List<String[]> records = new ArrayList<String[]>();
			
			String[] s1 = new String[3];
			s1[0] = "00";
			s1[1] = "01";
			s1[2] = "02";
			records.add(s1);
			
			String[] s2 = new String[3];
			s2[0] = "10";
			s2[1] = "11";
			s2[2] = "12";
			records.add(s2);
			
			String[] s3 = new String[3];
			s3[0] = "20";
			s3[1] = "21";
			s3[2] = "22";
			records.add(s3);
			
			XlsxUtils xl = new XlsxUtils();
			xl.write(records);
//			testlog tl = new testlog();
//			tl.test();
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
			
			/*XlsUtils xlsUtil = new XlsUtils("/s");
			
			xlsUtil.read();*/
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		/*} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();*/
		}
	}

}

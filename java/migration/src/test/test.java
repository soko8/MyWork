package test;

import java.io.FileNotFoundException;
import java.io.IOException;

import jp.co.dcs21.migration.persistence.datamodel.ItemMap;
import jp.co.dcs21.migration.utils.StringUtils;

public class test {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		System.err.print(StringUtils.isFullWidthNumber('a'));
		try {
			ItemMap.init();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}

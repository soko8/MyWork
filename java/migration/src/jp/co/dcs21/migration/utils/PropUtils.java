package jp.co.dcs21.migration.utils;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.PropertyResourceBundle;

public class PropUtils {

	public static Properties loadFromFile(String fileFullPath) throws FileNotFoundException, IOException {

		Properties prop = new Properties();

		InputStream fis = null;

		try {
			fis = ClassLoader.getSystemResourceAsStream(fileFullPath);
			prop.load(fis);

		} finally {

			if (null != fis) {
				try {
					fis.close();
				} catch(IOException e) {
					fis = null;
				}
			}

		}

		return prop;

	}

	/**
	 * in jar
	 * sys.properties
	 * ex-->com.shopping.eus.property.sys
	 */
	public static Properties loadFromBundle(String bundleName) {

		Properties prop = new Properties();

		PropertyResourceBundle bundle = null;

		try {

			bundle = (PropertyResourceBundle) PropertyResourceBundle.getBundle(bundleName);
			for (String key : bundle.keySet()) {
				prop.setProperty(key, bundle.getString(key));
			}

		} finally {
			PropertyResourceBundle.clearCache();
		}





		return prop;
	}

}
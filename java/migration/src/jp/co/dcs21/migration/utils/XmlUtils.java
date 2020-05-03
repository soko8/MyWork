package jp.co.dcs21.migration.utils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jp.co.dcs21.migration.persistence.DbUtils;

import org.apache.commons.digester3.Digester;
import org.xml.sax.SAXException;

public class XmlUtils {

	private final static String configFile = "config.xml";
	
	public static Configs parseXmlForDB() throws IOException, SAXException {
		
		Digester ds = new Digester();
		ds.setValidating(false);
		
		Configs configs = new Configs();
		ds.push(configs);
		
		ds.addObjectCreate("configs/db-config", Config.class);
		ds.addSetProperties("configs/db-config", "name", "dbName");
		ds.addSetNestedProperties("configs/db-config");
		ds.addSetNext("configs/db-config", "addConfig");
		
		return ds.parse(DbUtils.class.getClassLoader().getResourceAsStream(configFile));
	}
	
	
	public static List<String> parseXmlForTableList() throws IOException, SAXException {
		
		Digester ds = new Digester();
		ds.setValidating(false);
		
		ds.addObjectCreate("configs/table-list", ArrayList.class);
		ds.addCallMethod("configs/table-list/table", "add", 1);
		ds.addCallParam("configs/table-list/table", 0);
		
		return ds.parse(DbUtils.class.getClassLoader().getResourceAsStream(configFile));
	}
}

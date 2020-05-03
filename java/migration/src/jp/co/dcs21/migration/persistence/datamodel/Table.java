package jp.co.dcs21.migration.persistence.datamodel;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import org.xml.sax.SAXException;

public interface Table {

	public int insertRecord(
			List<String> record
			, List<String> PreRecord
			, List<String> headerInfo
			, Map<String, Item> tableMeta
			, Map<String, Map<String, Map<String, String>>> indexDictionary
			, Map<String, String[]> romaji) throws SQLException, ClassNotFoundException, IOException, SAXException;
}

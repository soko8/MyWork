package jp.co.dcs21.migration.persistence;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.co.dcs21.migration.persistence.datamodel.Item;
import jp.co.dcs21.migration.utils.Config;
import jp.co.dcs21.migration.utils.XmlUtils;

import org.xml.sax.SAXException;

public class DbUtils {

	private static DbUtils dbutils = new DbUtils();

	private Connection con = null;

	private static Config conf = null;

//	private Map<String, Map<String, Item>> allTablesMeta = null;


	private DbUtils() {

	}

	public static DbUtils getInstacne() {
		return dbutils;
	}

//	public Map<String, Item> getTableMeta(String tableName) throws ClassNotFoundException, IOException, SAXException, SQLException {
//		return this.getAllTablesMeta().get(tableName);
//	}

	public Map<String, Map<String, Item>> getTablesMeta() throws IOException, SAXException, ClassNotFoundException, SQLException {

		PreparedStatement ps = null;

		ResultSet rs = null;

		Map<String, Map<String, Item>> allTables = new HashMap<String, Map<String, Item>>();

		try {

			List<String> tableList = XmlUtils.parseXmlForTableList();

			String sql = getMetaSql();

			ps = this.getConnection().prepareStatement(sql);

			Map<String, Item> tableMeta = null;

			Item item = null;

			for (String tableName : tableList) {

				ps.setString(1, tableName);
				rs = ps.executeQuery();

				tableMeta = new HashMap<String, Item>();

				allTables.put(tableName, tableMeta);

				while (rs.next()) {

					item = new Item();
					tableMeta.put(rs.getString(1), item);

					item.setColumnName(rs.getString(1));
					item.setColumnType(rs.getString(2));
					item.setColumnLength(rs.getString(3));
					item.setColumnComment(rs.getString(4));
				}
			}

/*		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();*/
		} finally {

//			closeConnection();

			if (null != ps) {
				try {
					ps.close();
				} catch(SQLException e) {
					ps = null;
					e.printStackTrace();
				}
			}

			if (null != rs) {
				try {
					rs.close();
				} catch(SQLException e) {
					rs = null;
					e.printStackTrace();
				}
			}

		}

		return allTables;
	}


	public Connection getConnection() throws ClassNotFoundException, SQLException, IOException, SAXException {

		if (null == this.con) {
			Config conf = DbUtils.getConf();
			Class.forName(conf.getDriverClass());
			this.con = DriverManager.getConnection(conf.getUrl(), conf.getUserName(), conf.getPassword());
			this.con.setAutoCommit(false);
		}

		return this.con;
	}

	public void closeConnection() {
		if (null != this.con) {
			try {
				this.con.close();
			} catch (SQLException e) {}
		}
	}

	private static String getMetaSql() {

		StringBuilder dictionarySql_ = new StringBuilder();
		dictionarySql_.append("SELECT																										");
		dictionarySql_.append("b.attname as name, 																							");
		dictionarySql_.append("c.typname as type, 																							");
		dictionarySql_.append("case c.typname 																								");
		dictionarySql_.append("	when 'bpchar'																								");
		dictionarySql_.append("		then to_char(atttypmod - 4, '9999')																		");
		dictionarySql_.append("	when 'varchar'																								");
		dictionarySql_.append("		then to_char(atttypmod - 4, '9999')																		");
		dictionarySql_.append("	when 'numeric' 																								");
		dictionarySql_.append("		then to_char(((atttypmod - 4) / 65536), '9999') || '.' || to_char(((atttypmod - 4) % 65536), '9999') 	");
		dictionarySql_.append("	else to_char(b.attlen, '9999')																				");
		dictionarySql_.append("end as length,																								");
		dictionarySql_.append("d.description																								");
		dictionarySql_.append("FROM																											");
		dictionarySql_.append("			pg_class	AS a																					");
		dictionarySql_.append("	LEFT OUTER JOIN pg_attribute	AS b ON (b.attrelid = a.oid)												");
		dictionarySql_.append("	LEFT OUTER JOIN pg_type		AS c ON (b.atttypid = c.oid)													");
		dictionarySql_.append("	LEFT OUTER JOIN pg_description	AS d ON (d.objoid = a.oid AND d.objsubid = b.attnum)						");
		dictionarySql_.append("where a.relname = ? 																							");
		dictionarySql_.append(" and b.attstattarget = -1																					");
		dictionarySql_.append("order by attnum																								");

		return dictionarySql_.toString();
	}


	private String getPkSql() {

		StringBuilder dictionarySql_ = new StringBuilder();

		dictionarySql_.append("SELECT DISTINCT																								");
		dictionarySql_.append("    pg_constraint.conname   as pk_name,																		");
		dictionarySql_.append("    pg_attribute.attname    as colname,																		");
		dictionarySql_.append("    pg_type.typname         as typename																		");
		dictionarySql_.append("FROM																											");
		dictionarySql_.append("    pg_constraint 																							");
		dictionarySql_.append("        inner join pg_class     on pg_constraint.conrelid   = pg_class.oid     								");
		dictionarySql_.append("        inner join pg_attribute on pg_attribute.attrelid    = pg_class.oid     								");
		dictionarySql_.append("                            and  ( pg_attribute.attnum      = pg_constraint.conkey[1] 						");
		dictionarySql_.append("                            or     pg_attribute.attnum      = pg_constraint.conkey[2] 						");
		dictionarySql_.append("                            or     pg_attribute.attnum      = pg_constraint.conkey[3] 						");
		dictionarySql_.append("                            or     pg_attribute.attnum      = pg_constraint.conkey[4] 						");
		dictionarySql_.append("                            or     pg_attribute.attnum      = pg_constraint.conkey[5] 						");
		dictionarySql_.append("                            or     pg_attribute.attnum      = pg_constraint.conkey[6]  )    					");
		dictionarySql_.append("        inner join pg_type      on pg_type.oid              = pg_attribute.atttypid							");
		dictionarySql_.append("WHERE																										");
		dictionarySql_.append("    lower(pg_class.relname) = ?     																			");
		dictionarySql_.append("AND																											");
		dictionarySql_.append("    pg_constraint.contype='p'																				");

		return dictionarySql_.toString();
	}

	public static Config getConf() throws IOException, SAXException {

		if (null == DbUtils.conf) {
			DbUtils.conf = XmlUtils.parseXmlForDB().getConfigs().get(0);
		}
		return DbUtils.conf;
	}

//	public Map<String, Map<String, Item>> getAllTablesMeta() throws ClassNotFoundException, IOException, SAXException, SQLException {
//
//		if (null == this.allTablesMeta) {
//			this.allTablesMeta = this.getTablesMeta();
//		}
//		return this.allTablesMeta;
//	}

}

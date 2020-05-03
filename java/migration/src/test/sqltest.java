package test;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

import jp.co.dcs21.migration.persistence.DbUtils;

import org.xml.sax.SAXException;

public class sqltest {

	public static void main(String[] args) {

		Connection con = null;

		String sql = "insert into amcode values('Tt01', '1', 'test', 'aaa', 'bb', 100, '0', '2012-07-01', 'sys', 'sys', '2012-07-01', 'sys', 'sys', '2012-07-01');";
		sql += "insert into amcode values('Tt02', '2', 'test', 'aaa', 'bb', 100, '0', '2012-07-01', 'sys', 'sys', '2012-07-02', 'sys', 'sys', '2012-07-02');";

		try {
			con = DbUtils.getInstacne().getConnection();
			con.createStatement().executeUpdate(sql);
			con.commit();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			DbUtils.getInstacne().closeConnection();
		}


	}

}

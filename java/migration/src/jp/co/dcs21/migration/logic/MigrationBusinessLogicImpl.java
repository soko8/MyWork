package jp.co.dcs21.migration.logic;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jp.co.dcs21.migration.persistence.DbUtils;
import jp.co.dcs21.migration.persistence.datamodel.Item;
import jp.co.dcs21.migration.persistence.datamodel.ItemMap;
import jp.co.dcs21.migration.persistence.datamodel.SuperTable;
import jp.co.dcs21.migration.persistence.datamodel.Table;

public class MigrationBusinessLogicImpl implements BusinessLogic {

	private Map<String, Map<String, Item>> tablesMeta = null;

	private List<String[]> errorResult = new ArrayList<String[]>();



	private String preKanriNo = null;

	private List<String> preRecord = null;

	private boolean hasErr = false;

	private List<String[]> kanrinoSetResult = new ArrayList<String[]>();

	/**
	 * key		県（漢字）
	 * value	区のmap
	 * 			key		区（漢字）
	 * 			value	町のmap
	 * 					key	町（漢字）
	 * 					value	郵便番号
	 */
	private Map<String, Map<String, Map<String, String>>> indexDictionary = null;

	/**
	 * key 		郵便番号
	 * value	ローマ字
	 * 		String[0] 県
	 * 		String[1] 区
	 * 		String[2] 町
	 */
	private Map<String, String[]> romaji = null;

	private List<String> header = new ArrayList<String>();

	@Override
	public void processBusiness(String sheetName, List<String> record, int row) {

		Connection con = null;

		Table table = null;

		String[] outputTmp = null;

		String curKanriNo = null;

		try {

			int size = record.size();
			outputTmp = new String[size + 1];
			for (int i = 0; i < size; i++) {
				outputTmp[i] = record.get(i);
			}
			kanrinoSetResult.add(outputTmp);

			if (0 == row) {
				ItemMap.init();
				for (String str : record) {
					header.add(ItemMap.getKanji2romaji(str));
				}
				return;
			}

			con = DbUtils.getInstacne().getConnection();

			curKanriNo = record.get(header.indexOf("kanrino"));

			// 管理番号が変わったら、commit
			if (!curKanriNo.equals(preKanriNo)) {
				if (!hasErr) {
					con.commit();
				} else {
					errorResult.addAll(kanrinoSetResult);
				}
				kanrinoSetResult = new ArrayList<String[]>();
				hasErr = false;
			} else {
				if (hasErr) {
					return;
				}
			}

			for (String tableName : tablesMeta.keySet()) {

				table = (Table) Class.forName("jp.co.dcs21.migration.persistence.datamodel." + tableName).newInstance();
				table.insertRecord(record, preRecord, header, tablesMeta.get(tableName), this.indexDictionary, this.romaji);

			}




		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();

			if (e instanceof SQLException) {

				hasErr = true;

				outputTmp[outputTmp.length-1] = e.getMessage();

				if (null != con) {
					try {
						con.rollback();
					} catch (SQLException e1) {
						// TODO Auto-generated catch block
						e1.printStackTrace();
					}
				}
			} else {
				return;
			}

		} /*catch (InstantiationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
		finally {

			if (0 < row) {
				preKanriNo = curKanriNo;
				preRecord = record;
			}

		}

	}

//	public Map<String, Map<String, Item>> getTablesMeta() {
//		return tablesMeta;
//	}

	public void setTablesMeta(Map<String, Map<String, Item>> tablesMeta) {
		this.tablesMeta = tablesMeta;
	}

//	public Map<String, Map<String, List<String[]>>> getIndexDictionary() {
//		return indexDictionary;
//	}

	public void setIndexDictionary(Map<String, Map<String, Map<String, String>>> indexDictionary) {
		this.indexDictionary = indexDictionary;
	}

//	public Map<String, String[]> getRomaji() {
//		return romaji;
//	}

	public void setRomaji(Map<String, String[]> romaji) {
		this.romaji = romaji;
	}

	public List<String[]> getErrorResult() {
		return errorResult;
	}

	/*public void setErrorResult(List<String[]> errorResult) {
		this.errorResult = errorResult;
	}*/






}

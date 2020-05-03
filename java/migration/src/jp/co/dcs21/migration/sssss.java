package jp.co.dcs21.migration;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jp.co.dcs21.migration.logic.BusinessLogic;
import jp.co.dcs21.migration.utils.AddressUtils;

public class sssss implements BusinessLogic {

	/**
	 * @return the result
	 */
	public List<String[]> getResult() {
		return result;
	}


	/**
	 * @param result the result to set
	 */
	public void setResult(List<String[]> result) {
		this.result = result;
	}


	private Map<String, Map<String, Map<String, String>>> indexDictionary = null;

	private Map<String, String[]> romaji = null;

	private List<String[]> result = new ArrayList<String[]>();


	@Override
	public void processBusiness(String sheetName, List<String> record, int row) {
		// TODO Auto-generated method stub
		String ad1 = record.get(35);
		String ad2 = record.get(39);
		List<String[]> ad1l =  AddressUtils.getRomaji(ad1, " ", indexDictionary, romaji);
		/*if (row == 0) {
			return;
		}*/

		String[] resultRecord = new String[16];
		result.add(resultRecord);
		if (null != ad1l && 0 < ad1l.size()) {
			resultRecord[0] = ad1l.get(0)[0];
			if (1 < ad1l.get(0).length) {
				resultRecord[1] = ad1l.get(0)[1];
				resultRecord[2] = ad1l.get(0)[2];
				if (4 == ad1l.get(0).length) {
					resultRecord[3] = ad1l.get(0)[3];
				}
			}


			if (2 == ad1l.size()) {
				resultRecord[4] = ad1l.get(1)[0];
				resultRecord[5] = ad1l.get(1)[1];
				resultRecord[6] = ad1l.get(1)[2];
				if (4 == ad1l.get(0).length) {
					resultRecord[7] = ad1l.get(1)[3];
				}
			}

		}
//		if (ad1l.size() == 2) {
//			System.err.println(ad1l.get(1)[0] + ad1l.get(1)[1] + ad1l.get(1)[2]);
//		}

		ad1l =  AddressUtils.getRomaji(ad2, " ", indexDictionary, romaji);
		if (null != ad1l && 0 < ad1l.size()) {
			resultRecord[8] = ad1l.get(0)[0];
			if (1 < ad1l.get(0).length) {
				resultRecord[9] = ad1l.get(0)[1];
				resultRecord[10] = ad1l.get(0)[2];
				if (4 == ad1l.get(0).length) {
					resultRecord[11] = ad1l.get(0)[3];
				}
			}


			if (2 == ad1l.size()) {
				resultRecord[12] = ad1l.get(1)[0];
				resultRecord[13] = ad1l.get(1)[1];
				resultRecord[14] = ad1l.get(1)[2];
				if (4 == ad1l.get(0).length) {
					resultRecord[15] = ad1l.get(1)[3];
				}
			}

		}
//		if (ad1l.size() == 2) {
//			System.err.println(ad1l.get(0)[0] + ad1l.get(0)[1] + ad1l.get(0)[2]);
//		}
	}


	public Map<String, Map<String, Map<String, String>>> getIndexDictionary() {
		return indexDictionary;
	}


	public void setIndexDictionary(Map<String, Map<String, Map<String, String>>> indexDictionary) {
		this.indexDictionary = indexDictionary;
	}


	public Map<String, String[]> getRomaji() {
		return romaji;
	}


	public void setRomaji(Map<String, String[]> romaji) {
		this.romaji = romaji;
	}

}

/**
 * 
 */
package my.test.javaBean;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * @author zenggao
 *
 */
public class TestBean2  implements Serializable{
	
	private String item = null;
	
	private String money = null;
	
	private List<String> beanUtilsTestList = null;
	
	private String[] beanUtilsTestArray = null;
	
	private Map<String, String> beanUtilsTestMap = null;
	
	private List<TestBean> beanUtilsTestIndexedList = null;



	/**
	 * 
	 */
	public TestBean2() {
	}
	
	/**
	 * @param item
	 * @param money
	 */
	public TestBean2(String item, String money) {
		this.item = item;
		this.money = money;
	}
	
	/**
	 * @return the beanUtilsTestIndexedList
	 */
	public List<TestBean> getBeanUtilsTestIndexedList() {
		return beanUtilsTestIndexedList;
	}

	/**
	 * @param beanUtilsTestIndexedList the beanUtilsTestIndexedList to set
	 */
	public void setBeanUtilsTestIndexedList(List<TestBean> beanUtilsTestIndexedList) {
		this.beanUtilsTestIndexedList = beanUtilsTestIndexedList;
	}
	
	/**
	 * @return the beanUtilsTestList
	 */
	public List<String> getBeanUtilsTestList() {
		return beanUtilsTestList;
	}

	/**
	 * @param beanUtilsTestList the beanUtilsTestList to set
	 */
	public void setBeanUtilsTestList(List<String> beanUtilsTestList) {
		this.beanUtilsTestList = beanUtilsTestList;
	}

	/**
	 * @return the beanUtilsTestArray
	 */
	public String[] getBeanUtilsTestArray() {
		return beanUtilsTestArray;
	}

	/**
	 * @param beanUtilsTestArray the beanUtilsTestArray to set
	 */
	public void setBeanUtilsTestArray(String[] beanUtilsTestArray) {
		this.beanUtilsTestArray = beanUtilsTestArray;
	}

	/**
	 * @return the beanUtilsTestMap
	 */
	public Map<String, String> getBeanUtilsTestMap() {
		return beanUtilsTestMap;
	}

	/**
	 * @param beanUtilsTestMap the beanUtilsTestMap to set
	 */
	public void setBeanUtilsTestMap(Map<String, String> beanUtilsTestMap) {
		this.beanUtilsTestMap = beanUtilsTestMap;
	}





	/**
	 * @return the item
	 */
	public String getItem() {
		return item;
	}

	/**
	 * @param item the item to set
	 */
	public void setItem(String item) {
		this.item = item;
	}

	/**
	 * @return the money
	 */
	public String getMoney() {
		return money;
	}

	/**
	 * @param money the money to set
	 */
	public void setMoney(String money) {
		this.money = money;
	}
	
	
	

}

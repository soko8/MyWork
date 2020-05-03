/**
 * 
 */
package my.test.javaBean;

import java.io.Serializable;

/**
 * @author zenggao
 *
 */
public class TestBean implements Serializable{
	
	private String item = null;
	
	private String money = null;
	
	private String nestedTest = null;

	/**
	 * @return the nestedTest
	 */
	public String getNestedTest() {
		return nestedTest;
	}

	/**
	 * @param nestedTest the nestedTest to set
	 */
	public void setNestedTest(String nestedTest) {
		this.nestedTest = nestedTest;
	}

	/**
	 * 
	 */
	public TestBean() {
	}

	/**
	 * @param item
	 * @param money
	 */
	public TestBean(String item, String money) {
		this.item = item;
		this.money = money;
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

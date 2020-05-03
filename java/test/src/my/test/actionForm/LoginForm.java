/**
 * 
 */
package my.test.actionForm;

import org.apache.struts.validator.ValidatorForm;

/**
 * @author zenggao
 *
 */
public class LoginForm extends ValidatorForm {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1182099857719552667L;

	private String userName = null;
	
	private String password = null;

	/**
	 * @return the userName
	 */
	public String getUserName() {
		return userName;
	}

	/**
	 * @param userName the userName to set
	 */
	public void setUserName(String userName) {
		this.userName = userName;
	}

	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * @param password the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}
	
	
}

/**
 * 
 */
package my.test.actionForm;

import java.util.ArrayList;
import java.util.List;

import my.test.javaBean.NestTestBean;
import my.test.javaBean.TestBean;

import org.apache.struts.validator.ValidatorForm;

/**
 * @author zenggao
 *
 */
public class IteratorValidateForm extends ValidatorForm {

	/**
	 * 
	 */
	private static final long serialVersionUID = -3729854958574451798L;
	
	private String address = null;

	private List<NestTestBean> loopList = new ArrayList();
	
	private List<ArrayList> loop2List = new ArrayList();
	

	/**
	 * @return the address
	 */
	public String getAddress() {
		return address;
	}

	/**
	 * @return the loop2List
	 */
	public List<ArrayList> getLoop2List() {
		return loop2List;
	}

	/**
	 * @param loop2List the loop2List to set
	 */
	public void setLoop2List(List<ArrayList> loop2List) {
		this.loop2List = loop2List;
	}

	/**
	 * @param address the address to set
	 */
	public void setAddress(String address) {
		this.address = address;
	}

	/**
	 * @return the loopList
	 */
	public List<NestTestBean> getLoopList() {
		return loopList;
	}

	/**
	 * @param loopList the loopList to set
	 */
	public void setLoopList(List<NestTestBean> loopList) {
		this.loopList = loopList;
	}
	
	
}

/**
 * 
 */
package my.test.action;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import my.test.actionForm.IteratorValidateForm;
import my.test.javaBean.NestTestBean;
import my.test.javaBean.TestBean;
import my.test.javaBean.TestBean2;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * @author zenggao
 *
 */
public class LoginAction extends Action {

	/* (non-Javadoc)
	 * @see org.apache.struts.action.Action#execute(org.apache.struts.action.ActionMapping, org.apache.struts.action.ActionForm, javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
	 */
	@Override
	public ActionForward execute(ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		// TODO Auto-generated method stub
		super.execute(mapping, form, request, response);
		
		HttpSession session = request.getSession();
		
		IteratorValidateForm vform = new IteratorValidateForm();
		
		List<NestTestBean> list = new ArrayList<NestTestBean>();
		
//		TestBean[] list = new TestBean[3];
		NestTestBean ntb = new NestTestBean();
		TestBean tb = new TestBean();
		tb.setItem("AAA");
		
		ntb.setTbean(tb);
		list.add(ntb);
//		list[0] = tb;
		
		NestTestBean ntb1 = new NestTestBean();
		TestBean tb1 = new TestBean();
		tb1.setItem("BBB");
		ntb1.setTbean(tb1);
		list.add(ntb1);
//		list[1] = tb1;
		
		NestTestBean ntb2 = new NestTestBean();
		TestBean tb2 = new TestBean();
		tb2.setItem("CCC");
		ntb2.setTbean(tb2);
		list.add(ntb2);
//		list[2] = tb2;
		
		vform.setLoopList(list);
		
		
		
		
		
		List loop2list = new ArrayList();
		/**************************/
		List<TestBean2> subloop2list0 = new ArrayList<TestBean2>();
		TestBean2 tb201 = new TestBean2();
		tb201.setItem("00");
		subloop2list0.add(tb201);
		
		TestBean2 tb202 = new TestBean2();
		tb202.setItem("01");
		subloop2list0.add(tb202);
		
		TestBean2 tb203 = new TestBean2();
		tb203.setItem("02");
		subloop2list0.add(tb203);
		
		loop2list.add(subloop2list0);
		
		/**************************/
		List<TestBean2> subloop2list1 = new ArrayList();
		TestBean2 tb211 = new TestBean2();
		tb211.setItem("10");
		subloop2list1.add(tb211);
		
		TestBean2 tb212 = new TestBean2();
		tb212.setItem("11");
		subloop2list1.add(tb212);
		
		TestBean2 tb213 = new TestBean2();
		tb213.setItem("12");
		subloop2list1.add(tb213);
		
		loop2list.add(subloop2list1);
		/**************************/
		
		List<TestBean2> subloop2list2 = new ArrayList();
		
		TestBean2 tb221 = new TestBean2();
		tb221.setItem("20");
		subloop2list2.add(tb221);
		
		TestBean2 tb222 = new TestBean2();
		tb222.setItem("21");
		subloop2list2.add(tb222);
		
		TestBean2 tb223 = new TestBean2();
		tb223.setItem("22");
		subloop2list2.add(tb223);
		loop2list.add(subloop2list2);
		/**************************/
		
		
		vform.setLoop2List(loop2list);
		session.setAttribute("loopValidatorForm", vform);
		
		
		return mapping.findForward("success");
	}

}

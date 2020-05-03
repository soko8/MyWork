package my.test.javaBean;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;

public class BeanUtilsTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		TestBean2 bean = new TestBean2();
		
		List l = new ArrayList();
		l.add("1");
		l.add("2");
		
		String[] arr = new String[]{"a", "b"};
		
		Map m = new HashMap();
		m.put("A", "3");
		m.put("B", "4");
		
		bean.setBeanUtilsTestArray(arr);
		
		bean.setBeanUtilsTestList(l);
		
		bean.setBeanUtilsTestMap(m);
		
		bean.setItem("iii");
		
		List l2 = new ArrayList();
		TestBean subBean1 = new TestBean("s1", "100");
		
		subBean1.setNestedTest("XXXXX");
		l2.add(subBean1);
		
		TestBean subBean2 = new TestBean("s2", "222");
		l2.add(subBean2);
		
		bean.setBeanUtilsTestIndexedList(l2);
		
		
		/*************************************/
		try {
			System.err.println(BeanUtils.getProperty(bean, "item"));
			
			System.err.println(BeanUtils.getNestedProperty(bean, "beanUtilsTestIndexedList[0].nestedTest"));
			
			System.err.println(BeanUtils.getArrayProperty(bean, "beanUtilsTestList")[0]);
			
			
			System.err.println(BeanUtils.getMappedProperty(bean, "beanUtilsTestMap(B)"));
			System.err.println(BeanUtils.getMappedProperty(bean, "beanUtilsTestMap", "A"));
			
			
			System.err.println(BeanUtils.getIndexedProperty(bean, "beanUtilsTestIndexedList[0]"));
			System.err.println(BeanUtils.getIndexedProperty(bean, "beanUtilsTestIndexedList", 0));
		} catch (IllegalAccessException | InvocationTargetException
				| NoSuchMethodException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}

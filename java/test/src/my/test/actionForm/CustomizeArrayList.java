///**
// * 
// */
//package my.test.actionForm;
//
//import java.util.ArrayList;
//
///**
// * @author zenggao
// * 
// */
//public class CustomizeArrayList<E> extends ArrayList<Object> {
//
//	private Class<?> clz = null;
//	/**
//	 * 
//	 */
//	private static final long serialVersionUID = -466302464607340018L;
//
//	/**
//	 * @param clz
//	 */
//	public CustomizeArrayList(Class<?> clz) {
//		super();
//		this.clz = clz;
//	}
//
//	/*
//	 * (non-Javadoc)
//	 * 
//	 * @see java.util.ArrayList#get(int)
//	 */
//	@Override
//	public Object get(int index) {
//		
//		try {
//			
//			while (index >= size()) {
//				add(clz.newInstance());
//			}
//			
//		} catch (InstantiationException e) {
//			return null;
////			e.printStackTrace();
//		} catch (IllegalAccessException e) {
//			return null;
////			e.printStackTrace();
//		}
//		return super.get(index);
//	}
//}

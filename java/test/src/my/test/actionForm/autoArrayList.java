package my.test.actionForm;

import java.util.ArrayList;

public class autoArrayList<E> extends ArrayList<Object> {

	/* (non-Javadoc)
	 * @see java.util.ArrayList#get(int)
	 */
	@Override
	public Object get(int index) {
		// TODO Auto-generated method stub
		
		while (index >= size()) {
			add(new Object());
		}
		return super.get(index);
	}

}

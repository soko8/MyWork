package my.test.javaBean;

import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.beanutils.PropertyUtils;

public class testArray {

	public static void main(String[] args) {

		Map<String, Object> inMap1 = new HashMap<>();
		inMap1.put("a", "aa");
		inMap1.put("b", "1");

		Map<String, Object> inMap2 = new HashMap<>();
		inMap2.put("a", "bb");
		inMap2.put("b", "2");

		List<Map<String, Object>> list = new ArrayList<>();
		list.add(inMap1);
		list.add(inMap2);

		Map<String, Object> map = new HashMap<>();
		map.put("inners", list);

		testArray test = new testArray();
		Outer out = new Outer();
		test.map2Obj(map, out);
		System.err.println(Map.class.getName());
		System.err.println(map.getClass().getName());
		System.err.println(map.getClass() == HashMap.class);
		System.err.println(map.getClass().equals(HashMap.class));
	}

	public void map2Obj(Map<String, Object> map, Object obj) {
		for (Entry<String, Object> entry : map.entrySet()) {
			String key = entry.getKey();
			Object value = entry.getValue();
			try {
				Field field = obj.getClass().getDeclaredField(key);
				field.setAccessible(true);
				Class clz = field.getType();
//				System.err.println(clz.isArray());
//				System.err.println(clz.getComponentType());
				if (clz.isArray()) {
					List<Map<String, Object>> list = (List<Map<String, Object>>) value;
					int size = list.size();
					int i = 0;
					Object[] arr = (Object[]) Array.newInstance(clz.getComponentType(), size);
					for (Map<String, Object> m : list) {
						Object inst = clz.getComponentType().newInstance();
						map2Obj(m, inst);
						arr[i] = inst;
						i++;
					}

					PropertyUtils.setProperty(obj, key, arr);

				} else {
					if (clz == String.class) {
						PropertyUtils.setProperty(obj, key, value.toString());
					} else if (clz == Integer.class) {
						PropertyUtils.setProperty(obj, key, Integer.valueOf(value.toString()));
					}

				}
			} catch (NoSuchFieldException | SecurityException | InstantiationException | IllegalAccessException
					| NumberFormatException | InvocationTargetException | NoSuchMethodException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}

package graph.directed;

/**
 * 标记状态枚举类
 */
public enum StatusEnum {

	NOT_VISIT("未访问"), FIRST_VISIT("第一次访问"), HANDLED("处理完了");

	private String meaning;

	private StatusEnum(String meaning) {
		this.meaning = meaning;
	}

	public String getMeaning() {
		return this.meaning;
	}
}

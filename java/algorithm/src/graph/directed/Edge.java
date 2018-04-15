package graph.directed;

/**
 * 边类
 */
public class Edge {

	private String sourceId = null;

	private String destinationId = null;

	private int weight = 0;

	private boolean isOneWay = true;

	public Edge(String sourceId, String destinationId, int weight, boolean isOneWay) {
		this.sourceId = sourceId;
		this.destinationId = destinationId;
		this.weight = weight;
		this.isOneWay = isOneWay;
	}

	public boolean isStartFromV(String vid) {

		if (sourceId.equals(vid)) {
			return true;
		}

		if (!isOneWay) {
			if (destinationId.equals(vid)) {
				return true;
			}
		}

		return false;
	}

	// 单向还是双向
	public boolean isOneWay() {
		return isOneWay;
	}

	public void setOneWay(boolean isOneWay) {
		this.isOneWay = isOneWay;
	}

	public String getSourceId() {
		return sourceId;
	}

	public void setSourceId(String sourceId) {
		this.sourceId = sourceId;
	}

	public String getDestinationId() {
		return destinationId;
	}

	public void setDestinationId(String destinationId) {
		this.destinationId = destinationId;
	}

	public int getWeight() {
		return weight;
	}

	public void setWeight(int weight) {
		this.weight = weight;
	}

}

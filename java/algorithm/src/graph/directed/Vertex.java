package graph.directed;

/**
 * 顶点类
 */
public class Vertex {

	public Vertex(String vertexId) {
		this.vertexId = vertexId;
	}

	private String vertexId = null;

	private StatusEnum status = StatusEnum.NOT_VISIT;

	public String getVertexId() {
		return vertexId;
	}

	public void setVertexId(String vertexId) {
		this.vertexId = vertexId;
	}

	public StatusEnum getStatus() {
		return status;
	}

	public void setStatus(StatusEnum status) {
		this.status = status;
	}

}

package graph.directed;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;


/*



有向图　　　　　　　　　　　　　　　　该有向图对应的邻接表
①--->②     ③             ①-->②-->④
|   →|    /|			 ②-->⑤
|  / |   / |             ③-->⑥-->⑤
| /  |  /  |             ④-->②
↓/   ↓ /   |             ⑤-->④
④←---⑤←   -⑥             ⑥-->⑥
          |_↑
          
          


*/


/**
 * 有向图
 */
public class DirectedGraph {

	/** 顶点集 Map
	 *		key		顶点Id
	 *		value	顶点
	 * */
	private Map<String, Vertex> vertices = null;

	/*** 边集 ***/
	private List<Edge> edges = null;

	public Map<String, Vertex> getVertices() {
		return vertices;
	}

	public void setVertices(Map<String, Vertex> vertices) {
		this.vertices = vertices;
	}

	public List<Edge> getEdges() {
		return edges;
	}

	public void setEdges(List<Edge> edges) {
		this.edges = edges;
	}

	/**
	 * 由顶点和边生成邻接表 
	 *  key  : 顶点ID
	 *  value: 该顶点所有的邻接顶点
	 * **
	 */
	public Map<String, List<Vertex>> getAdjacencyList() {

		Map<String, List<Vertex>> adjacencyList = new HashMap<String, List<Vertex>>();

		for (Edge edge : edges) {

			String sourceId = edge.getSourceId();

			String destinationId = edge.getDestinationId();

			List<Vertex> nodeAdjacencyList = adjacencyList.get(sourceId);

			if (null == nodeAdjacencyList) {
				nodeAdjacencyList = new ArrayList<>();
				adjacencyList.put(sourceId, nodeAdjacencyList);
			}

			nodeAdjacencyList.add(vertices.get(destinationId));

			// 双向
			if (!edge.isOneWay()) {

				List<Vertex> nodeAdjacencyList2 = adjacencyList.get(destinationId);

				if (null == nodeAdjacencyList2) {
					nodeAdjacencyList2 = new ArrayList<>();
					adjacencyList.put(destinationId, nodeAdjacencyList2);
				}

				nodeAdjacencyList2.add(vertices.get(sourceId));
			}

		}

		outAdjacencyList(adjacencyList);

		return adjacencyList;
	}

	public int getWeight(String sourceId, String destinationId, int notFoundValue) {

		for (Edge edge : edges) {

			if (sourceId.equals(edge.getSourceId()) && destinationId.equals(edge.getDestinationId())) {
				return edge.getWeight();
			}

			if (!edge.isOneWay()) {
				if (sourceId.equals(edge.getDestinationId()) && destinationId.equals(edge.getSourceId())) {
					return edge.getWeight();
				}
			}

		}

		return notFoundValue;
	}

	private void outAdjacencyList(Map<String, List<Vertex>> adjacencyList) {

		Set<String> keys = adjacencyList.keySet();

		for (String key : keys) {
			List<Vertex> list = adjacencyList.get(key);

			StringBuilder sb = new StringBuilder(key);

			sb.append("==>");

			for (Vertex v : list) {
				sb.append(v.getVertexId());
				sb.append("-->");
			}

			System.out.println(sb.toString());
		}

		System.out.println("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");

	}

}

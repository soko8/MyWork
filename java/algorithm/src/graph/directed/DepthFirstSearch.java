package graph.directed;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class DepthFirstSearch {
	
	Map<String, List<Vertex>> adjacencyList = null;

	/** 保存所有路径
	 * 
	 */
	private Map<String, Map<String, Integer>> paths = null;
	
	public void init(DirectedGraph dg) {
			
		Map<String, Vertex> vertices = dg.getVertices();
		
		Set<String> keys = vertices.keySet();
		
		for (String key : keys) {
			Vertex vertex = vertices.get(key);
			vertex.setStatus(StatusEnum.NOT_VISIT);
			/* you can do something else */
		}
		
		
		paths = new HashMap<>();
		
		adjacencyList = dg.getAdjacencyList();
		
	}
	
	public void dfs(DirectedGraph dg, String startVertexId, String destinationVertexId) {
		
		
		if (startVertexId.equals(destinationVertexId)) {
			
			return;
		}
		
		dg.getVertices().get(startVertexId).setStatus(StatusEnum.FIRST_VISIT);
		
		List<Vertex> curAdjacencyList = adjacencyList.get(startVertexId);
		
		Map<String, Integer> curVpaths = paths.get(startVertexId);
		
		for (Vertex v : curAdjacencyList) {
			
//			paths.put("" + "-->" + v.getVertexId(), 1);
			
			if (StatusEnum.NOT_VISIT.equals(v.getStatus())) {
				dfs(dg, v.getVertexId(), destinationVertexId);
			}
			
		}
		
		
		
//		return false;
	}
	
}

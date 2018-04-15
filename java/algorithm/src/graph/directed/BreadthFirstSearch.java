package graph.directed;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.TreeMap;

/*
 * 深度优先和广度优先各有各的优缺点:
 * 		广优的话，占内存多，能找到最优解，必须遍历所有分枝. 广优的一个应用就是迪科斯彻单元最短路径算法.
 * 		深优的话，占内存少，能找到最优解（一定条件下），但能很快找到接近解（优点），可能不必遍历所有分枝（也就是速度快）
 * 
 * 在更多的情况下，深优是比较好的方案。
 */


/**
 * 广度优先搜索
 *
 */
public class BreadthFirstSearch {

	private Integer minWeight = 0;
	
	private Integer maxWeight = 0;
	
	private String minPath = null;
	
	private String maxPath = null;
	
	/** 保存所有路径
	 * 
	 */
	private Map<String, Map<String, Integer>> paths = null;
	
	private void init(DirectedGraph dg) {
		
		Map<String, Vertex> vertices = dg.getVertices();
		
		Set<String> keys = vertices.keySet();
		
		for (String key : keys) {
			Vertex vertex = vertices.get(key);
			vertex.setStatus(StatusEnum.NOT_VISIT);
			/* you can do something else */
		}
		
		
		paths = new HashMap<>();
		
	}
	
	private void setValue(String destinationId) {
		
		Map<String, Integer> source2DestinationPaths = paths.get(destinationId);
		
		TreeMap<Integer, String> sortedMap = new TreeMap<>();
		
		Set<String> pathKeys = source2DestinationPaths.keySet();
		
		for (String pathKey : pathKeys) {
			System.out.println(pathKey);
			sortedMap.put(source2DestinationPaths.get(pathKey), pathKey);
		}
		
		minWeight = sortedMap.firstKey();
		 
		minPath = sortedMap.get(minWeight);
		
		maxWeight = sortedMap.lastKey();
		
		maxPath = sortedMap.get(maxWeight);
		
	}
	
	private int getWeight(List<Edge> edges, String sourceId, String destinationId) {
		
		for (Edge edge : edges) {
			
			if (sourceId.equals(edge.getSourceId()) && destinationId.equals(edge.getDestinationId())) {
				return edge.getWeight();
			}
			
		}
		
		return 0;
	}
	
	public boolean bfs(DirectedGraph dg, String startVertexId, String destinationVertexId) {
		
		init(dg);
		
		// 原点
		Vertex startVertex = dg.getVertices().get(startVertexId);
		
		Queue<Vertex> queue = new LinkedList<Vertex>();
		
		
		
		// 原点入队
		queue.offer(startVertex);
		System.out.println("In" + startVertex);
		
		// 邻接表
		Map<String, List<Vertex>> adjacencyList = dg.getAdjacencyList();
		
		while (!queue.isEmpty()) {
			
			// 出队
			Vertex curSourceVertex = queue.poll();
			
			String vid = curSourceVertex.getVertexId();
			
			System.out.println("Out" + vid);
			
			if (destinationVertexId.equals(vid)) {
				setValue(destinationVertexId);
				return true;
			}
			
			// 该顶点的邻接节点
			List<Vertex> vlist = adjacencyList.get(vid);
			
			// 对于每一个与V邻接的点
			for (Vertex adjacencyVertex : vlist) {
				// 只对未访问的操作
				if (StatusEnum.NOT_VISIT.equals(adjacencyVertex.getStatus())) {
					//标记为第一次访问
					adjacencyVertex.setStatus(StatusEnum.FIRST_VISIT);
					
					String adjacencyVertexId = adjacencyVertex.getVertexId();
					
					Map<String, Integer> adjacencyVertexPaths= paths.get(adjacencyVertexId);
					
					if (null == adjacencyVertexPaths) {
						adjacencyVertexPaths = new HashMap<>();
						paths.put(adjacencyVertexId, adjacencyVertexPaths);
						
					}
					
					
					int weight = getWeight(dg.getEdges(), vid, adjacencyVertexId);
					
					Map<String, Integer> curSourceVertexPaths = paths.get(vid);
					
					if (null == curSourceVertexPaths || curSourceVertexPaths.isEmpty()) {
						String pathKey = vid + "-->" + adjacencyVertexId;
						adjacencyVertexPaths.put(pathKey, weight);
						System.err.println("Put:" + pathKey + "--" + weight);
					} else {
							
						Set<String> curSourceVertexPathKeys = curSourceVertexPaths.keySet();
						
						for (String curSourceVertexPathKey : curSourceVertexPathKeys)  {
							String pathKey = curSourceVertexPathKey + "-->" + adjacencyVertexId;
							adjacencyVertexPaths.put(pathKey, curSourceVertexPaths.get(curSourceVertexPathKey).intValue() + weight);
							System.err.println("Put:" + pathKey + "--" + curSourceVertexPaths.get(curSourceVertexPathKey) + weight);
						}
						
					}
					
					// 入队
					queue.offer(adjacencyVertex);
					System.out.println("In" + adjacencyVertex.getVertexId());
				}
				
			}
			// 此点已经处理完了
			curSourceVertex.setStatus(StatusEnum.HANDLED);
		}
		
		
		return false;
	}

	
	public int getMinWeight() {
		return minWeight;
	}

	public void setMinWeight(int minWeight) {
		this.minWeight = minWeight;
	}

	public int getMaxWeight() {
		return maxWeight;
	}

	public void setMaxWeight(int maxWeight) {
		this.maxWeight = maxWeight;
	}

	public String getMinPath() {
		return minPath;
	}

	public void setMinPath(String minPath) {
		this.minPath = minPath;
	}

	public String getMaxPath() {
		return maxPath;
	}

	public void setMaxPath(String maxPath) {
		this.maxPath = maxPath;
	}
}

package graph.directed.dijkstra;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import graph.directed.DirectedGraph;
import graph.directed.Edge;
import graph.directed.Vertex;


public class Dijkstra {
	
	// 保存从源点开始到各个顶点的最小路径值（d[v]）
//	private Map<String, Integer> minPathValue_S2V = new HashMap<>();
	
	// 保存从源点开始到各个顶点的最小路径
	private Map<String, MinPath> minPaths = new HashMap<>();

	public final static int MAX_V = Integer.MAX_VALUE;

	public void getShortestPath(DirectedGraph dg, String startVertexId, String endVertexId, boolean ignoreWeight) {

		// 有向图的所有边
		List<Edge> edges = dg.getEdges();
		
		// 有向图的所有顶点
		Map<String, Vertex> vertices = dg.getVertices();


		
		// 保存已知的所有 d[v](即上面的minPathValue_S2V) 的值已经是最短路径的值顶点
		List<Vertex> S = new ArrayList<>();

		// 保存有向图的所有顶点中S以外的其他所有顶点（vertices-S）
		Set<Vertex> Q = new HashSet<>();
		


//		Vertex previous = null;

		/*
		 * 初始化处理
		 * 若存在从源顶点能直接到达的边，则设置d[v]=边的权重，
		 * 若不存在则设置为无穷大。
		 * 除源点以为的顶点都加入到Q集里
		 */
		for (Entry<String, Vertex> entry : vertices.entrySet()) {

			String vid = entry.getKey();
			int weight = dg.getWeight(startVertexId, vid, MAX_V);
			if (ignoreWeight) {
				if (weight < MAX_V) {
					weight = 1;
				}
			}
			MinPath minPath = new MinPath();
			minPath.setValue(weight);
			List<Vertex> path = new ArrayList<>();
			path.add(entry.getValue());
			minPath.setPath(path);
			minPaths.put(entry.getKey(), minPath);
			if (!vid.equals(startVertexId)) {
				Q.add(entry.getValue());
			}
		}

		// 因为出发点到出发点间不需移动任何距离，所以可以直接将s到s的最小距离设为0
		minPaths.get(startVertexId).setValue(0);;
		// 源顶点加入到S中
		S.add(vertices.get(startVertexId));
		
		while (!Q.isEmpty()) {
			
			Vertex minVertex = Extract_Min(Q, minPaths);
			
			if (null != endVertexId && endVertexId.equals(minVertex.getVertexId())) {
				break;
			}
			
			S.add(minVertex);
//			previous = minVertex;
			expand(edges, minVertex, minPaths, vertices, ignoreWeight);
		}

	}

	/**
	 * 在顶点集合 Q 中搜索有最小的 d[u] 值的顶点 u。这个顶点被从集合 Q 中删除并返回
	 * @param Q
	 * @param minPaths
	 * @return
	 */
	private Vertex Extract_Min(Set<Vertex> Q, Map<String, MinPath> minPaths) {

		int minWeight = MAX_V;

		Vertex minVertex = null;

		for (Vertex v : Q) {
			int weight = minPaths.get(v.getVertexId()).getValue();

			if (weight < minWeight) {
				minWeight = weight;
				minVertex = v;
			}

		}

		if (null == minVertex) {
			minVertex = Q.iterator().next();
		}

		Q.remove(minVertex);

		return minVertex;
	}
	

	/**
	 * 拓展边
	 * 对每一条从m出发的边
	 * @param edges
	 * @param m
	 * @param minPaths
	 * @param ignoreWeight
	 */
	private void expand(List<Edge> edges, Vertex m, Map<String, MinPath> minPaths, Map<String, Vertex> vertices, boolean ignoreWeight) {

		//System.out.println("expand Begin");
		int weight_S_M = minPaths.get(m.getVertexId()).getValue();

		for (Edge edge : edges) {

			if (edge.isStartFromV(m.getVertexId())) {

				String d = edge.getDestinationId();
				if (d.equals(m.getVertexId())) {
					d = edge.getSourceId();
				}

				MinPath dMinPath = minPaths.get(d);
				int weight_M_D = edge.getWeight();
				if (ignoreWeight) {
					weight_M_D = 1;
				}
				int weight_S_D = dMinPath.getValue();

				int weightSMD = weight_S_M + weight_M_D;

				if (weightSMD < weight_S_D) {
					dMinPath.setValue(weightSMD);
					List<Vertex> dPath = dMinPath.getPath();
					dPath.clear();
					dPath.addAll(minPaths.get(m.getVertexId()).getPath());
					Vertex dVertex = vertices.get(d);
					dPath.add(dVertex);
					//System.err.println("weightSMD="+weightSMD + " weight_S_D=" + weight_S_D + " dMinPath.setValue" + " remove " + dVertex.getVertexId() + "   add " + m.getVertexId() + "   add " + d);
				}
			}

		}
		
		//System.out.println("expand end");

	}

	public MinPath getMinPathByVertexId(String vid) {
		return minPaths.get(vid);
	}

	public class MinPath {

		private int value = 0;

		private List<Vertex> path = null;

		public int getValue() {
			return value;
		}

		public void setValue(int value) {
			this.value = value;
		}

		public List<Vertex> getPath() {
			return path;
		}

		public void setPath(List<Vertex> path) {
			this.path = path;
		}

	}

}

package graph.directed.dijkstra;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import graph.directed.DirectedGraph;
import graph.directed.Edge;
import graph.directed.Vertex;
import graph.directed.dijkstra.Dijkstra.MinPath;

public class test {

	public static void main(String[] args) {
		DirectedGraph dg = new DirectedGraph();
		
		
		Map<String, Vertex> vertices = new HashMap<>();
		
		Vertex A = new Vertex("A");
		vertices.put(A.getVertexId(), A);
		
		Vertex B = new Vertex("B");
		vertices.put(B.getVertexId(), B);
		
		Vertex C = new Vertex("C");
		vertices.put(C.getVertexId(), C);
		
		Vertex D = new Vertex("D");
		vertices.put(D.getVertexId(), D);
		
		Vertex E = new Vertex("E");
		vertices.put(E.getVertexId(), E);
		
		Vertex F = new Vertex("F");
		vertices.put(F.getVertexId(), F);
		
		Vertex G = new Vertex("G");
		vertices.put(G.getVertexId(), G);
		
		Vertex H = new Vertex("H");
		vertices.put(H.getVertexId(), H);
		
		Vertex I = new Vertex("I");
		vertices.put(I.getVertexId(), I);
		
		Vertex J = new Vertex("J");
		vertices.put(J.getVertexId(), J);
		
		Vertex K = new Vertex("K");
		vertices.put(K.getVertexId(), K);
		
		Vertex L = new Vertex("L");
		vertices.put(L.getVertexId(), L);
		
		Vertex M = new Vertex("M");
		vertices.put(M.getVertexId(), M);		
		
		
		List<Edge> edges = new ArrayList<>();
		
		Edge CE = new Edge(C.getVertexId(), E.getVertexId(), 1, false);
		edges.add(CE);

		Edge CG = new Edge(C.getVertexId(), G.getVertexId(), 4, true);
		edges.add(CG);
		
		Edge ED = new Edge(E.getVertexId(), D.getVertexId(), 4, false);
		edges.add(ED);
		
		Edge EF = new Edge(E.getVertexId(), F.getVertexId(), 3, false);
		edges.add(EF);
		
		
		Edge AD = new Edge(A.getVertexId(), D.getVertexId(), 3, false);
		edges.add(AD);
		
		Edge AF = new Edge(A.getVertexId(), F.getVertexId(), 4, false);
		edges.add(AF);
		
		Edge AI = new Edge(A.getVertexId(), I.getVertexId(), 4, false);
		edges.add(AI);
		
		Edge FG = new Edge(F.getVertexId(), G.getVertexId(), 2, false);
		edges.add(FG);
		
		Edge FJ = new Edge(F.getVertexId(), J.getVertexId(), 5, false);
		edges.add(FJ);
		
		Edge GH = new Edge(G.getVertexId(), H.getVertexId(), 3, false);
		edges.add(GH);
		
		Edge GK = new Edge(G.getVertexId(), K.getVertexId(), 5, true);
		edges.add(GK);
		
		Edge HK = new Edge(H.getVertexId(), K.getVertexId(), 6, false);
		edges.add(HK);
		
		Edge IL = new Edge(I.getVertexId(), L.getVertexId(), 3, false);
		edges.add(IL);
		
		Edge JI = new Edge(J.getVertexId(), I.getVertexId(), 4, true);
		edges.add(JI);
		
		Edge JM = new Edge(J.getVertexId(), M.getVertexId(), 2, false);
		edges.add(JM);
		
		Edge LM = new Edge(L.getVertexId(), M.getVertexId(), 4, false);
		edges.add(LM);
		
		Edge MB = new Edge(M.getVertexId(), B.getVertexId(), 5, false);
		edges.add(MB);
		
		Edge KB = new Edge(K.getVertexId(), B.getVertexId(), 1, false);
		edges.add(KB);
		
		dg.setVertices(vertices);
		dg.setEdges(edges);
		
		
		Dijkstra d = new Dijkstra();
		d.getShortestPath(dg, "A", "B", true);
		MinPath minPath = d.getMinPathByVertexId("B");
		System.err.println(minPath.getValue());
		System.err.print("A");
		for (Vertex v : minPath.getPath()) {
			System.err.print("-->" + v.getVertexId());
		}
	}

}

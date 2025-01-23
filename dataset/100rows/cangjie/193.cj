package cjgrapht.graph
public class DefaultDirectedWeightedGraph<V, E> <: DefaultDirectedGraph<V, E> where E <: Equatable<E> & ToString & Hashable,
    V <: Equatable<V> & ToString & Hashable {
    public DefaultDirectedWeightedGraph(edgeSupplier: () -> E) {
        super(None, edgeSupplier, true);
    }
    public init(vertexSupplier: () -> V, edgeSupplier: () -> E) {
        super(vertexSupplier, edgeSupplier, true);
    }
}
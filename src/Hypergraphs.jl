module Hypergraphs

using Graphs, Combinatorics
using GraphHelpers
import Graphs: nv, ne, vertices, edges, is_directed, edgetype, has_vertex, has_edge, inneighbors, outneighbors
import Graphs: add_edge!, is_connected, rem_edge!

include("interface.jl")
include("gen.jl")

export Hypergraph, SComplex
export complete_hypergraph, all_labeled_hypergraphs

end # module

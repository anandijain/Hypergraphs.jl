possible_hyperedges(n) = Iterators.drop(powerset(1:n), 1)
n_hyperedges(n) = (2^n) - 1
n_hypergraphs(n) = 2^n_hyperedges(n)
GraphHelpers.possible_edges(g::AHG) = possible_hyperedges(nv(g))

# we could also treat the edge with no vertices as valid, but that's kind of weird
# GraphHelpers.possible_edges(g::AHG) = powerset(1:nv(g))

function complete_hypergraph(n)
    hg = Hypergraph(n)
    complete!(hg)
    hg
end

"https://oeis.org/A058891"
function all_labeled_hypergraphs(n)
    all_labeled_graphs(Hypergraph, n)
end

"https://oeis.org/A003180"
function all_hypergraphs(n)
    all_graphs(Hypergraph, n)
end

# todo 
# function Graphs.Experimental.has_isomorph(g1::AHG, g2::AHG)

# end

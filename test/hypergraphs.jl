using Hypergraphs, Graphs, GraphHelpers
hg = Hypergraph()

add_vertices!(hg, 3)
add_edge!(hg, [1, 1])
add_edge!(hg, [1, 2])
add_edge!(hg, [1, 2, 3])
edges(hg)
@test has_edge(hg, [1, 2])
@test is_connected(hg)
add_edge!(hg, [1, 2])
@test ne(hg) == 4 # multiedges are allowed, unlike in SimpleGraphs

hg = Hypergraph(3)
add_edge!(hg, [1, 2])
@test !is_cyclic(hg) # it's not actually cyclic

@test is_simple(hg)
dg = SimpleDiGraph(hg)
add_edge!(hg, [1, 2, 3])
@test_throws ErrorException SimpleDiGraph(hg)

# is there a natural meaning to cartesian product of hypergraphs? 
# do hypergraphs also get a unique factorization?
# cartesian_product(hg, hg)

# simp city
sc = SComplex()

add_vertices!(sc, 3)
add_edge!(sc, [1, 2])
@test has_edge(sc, [1, 2])
@test !is_connected(sc)

@test add_edge!(sc, [1, 2, 3])
@test ne(sc) == 1
@test has_edge(sc, [1, 2]) # downward closure
@test sc.v2he == [[2], [2], [2]]
@test is_connected(sc)

@test rem_edge!(sc, [3, 2, 1])
@test ne(sc) == 0
@test sc.v2he == [[], [], []]

@test !is_complete(sc) && is_complete(complete!(sc))
@test ne(sc) == 1 # any complete sc should only have a single edge

n = 3
hg = Hypergraph(n)
@test !is_complete(hg) && is_complete(complete!(hg))
@test ne(hg) == Hypergraphs.n_hyperedges(n)
hg = complete_hypergraph(2)
# rem_vertex!(hg, 1)
rem_edge!(hg, [1])
@test_broken ne(hg) # i forget what this is testing, i think it's fine though
@test ne(hg) == 2

hgs = all_labeled_hypergraphs(3)
@test length(hgs) == Hypergraphs.n_hypergraphs(n)

# needs Graphs.Experimental.has_isomorph
@test_throws MethodError Hypergraphs.all_hypergraphs(3)

hgs2 = all_labeled_graphs(Hypergraph, 3) # using enumeration interface

h = hgs[1]
h2 = hgs2[1]

# need to define == otherwise it defaults to ===
# https://discourse.julialang.org/t/surprising-struct-equality-test/4890/6 
@test_broken hgs == hgs2 

function tmp_isequal(h, h2)
    edges(h) == edges(h2) && vertices(h) == vertices(h2)
end
tmp_isequal(hs) = tmp_isequal(hs...)

@test all(tmp_isequal, zip(hgs, hgs2))

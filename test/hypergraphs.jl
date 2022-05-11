using Hypergraphs, Graphs
# {{1, 1, 1}, {1, 2, 3}, {3, 4, 4}}
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

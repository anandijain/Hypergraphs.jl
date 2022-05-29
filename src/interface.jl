
abstract type AbstractHypergraph{T<:Integer} <: AbstractGraph{T} end
abstract type AbstractSimplicialComplex{T} <: AbstractHypergraph{T} end

const AHG = AbstractHypergraph
const ACS = AbstractSimplicialComplex
# const AHE = AbstractHyperEdge

Hyperedge{T} = Vector{T} # makes edges directed (even for AHG)
# Hyperedge{T} = Set{T}

# struct Hyperedge{T} <: AbstractHyperEdge{T}
#     vs::Vector{T}
# end

mutable struct Hypergraph{T<:Integer} <: AbstractHypergraph{T}
    "contains the list of hyperedge indices that include v as a vertex"
    v2he::Vector{Vector{T}} # why not V{S{T}}
    "contains the list of vertices in a hyperedge"
    he2v::Vector{Hyperedge{T}} # i should probably make this a dict 
end

Hypergraph() = Hypergraph{Int}(Int[], Hyperedge[])

function Hypergraph(n::Int)
    hg = Hypergraph{Int}(Int[], Hyperedge[])
    add_vertices!(hg, n)
    hg
end

is_directed(::Type{<:Hypergraph}) = false
is_directed(g::Hypergraph) = false

Base.eltype(_::AHG{T}) where {T} = T
edgetype(g::AHG) = Hyperedge{eltype(g)}

nv(hg::AHG) = length(hg.v2he)
ne(hg::AHG) = length(hg.he2v)
function inneighbors(hg::AHG, v)
    xs = (hg.he2v[x] for x in hg.v2he[v]) # v{v{t}}
    isempty(xs) && return xs
    setdiff(union(xs...), v) # should I remove v?
end

outneighbors(hg::AHG, v) = inneighbors(hg, v)
vertices(hg::AHG) = 1:nv(hg)
has_vertex(hg::AHG, v) = v ∈ vertices(hg)
edges(hg::AHG) = hg.he2v

function has_edge(hg::AHG, e)
    for he in hg.he2v
        isequal(he, e) && return true
    end
    false
end

# end base graphs interface

Graphs.add_vertex!(hg::AHG) = push!(hg.v2he, eltype(hg)[])
# Graphs.add_vertices!(hg::AHG, n) = push!(hg.v2he, eltype(hg)[])
function Graphs.add_edge!(hg::AHG, he)
    n_v = nv(hg)
    # n_e = ne(hg)
    # all(he.vs <= n_v) || error("out out bounds hyperedge. there are only $n_v vertices")
    # @info he
    all(he .<= n_v) || return false
    push!(hg.he2v, he)
    he_idx = ne(hg) # updated with new he
    for v in he
        push!(hg.v2he[v], he_idx)
    end
    true
end
Graphs.add_edge!(hg::AHG, he::Tuple) = add_edge!(hg, collect(he))

# SimpleGraphs makes an assumption on the number of edges and vertices required for a graph to be connected
function is_connected(g::AHG)
    return length(connected_components(g)) == 1
end

# simp city
mutable struct SimplicialComplex{T<:Integer} <: ACS{T}
    "contains the list of hyperedge indices that include v as a vertex"
    v2he::Vector{Vector{T}}
    "contains the set of vertices in a hyperedge"
    he2v::Dict{T,Set{T}}
    # d::
end
const SComplex = SimplicialComplex
SComplex() = SComplex{Int}(Vector{Vector{Int}}(), Dict{Int,Set{Int}}())

is_directed(::Type{<:SimplicialComplex}) = false
is_directed(_::SimplicialComplex) = false

edgetype(g::SComplex) = Set{eltype(g)}

# Base.eltype(_::SimplicialComplex{T}) where {T} = T
function has_edge(sc::SComplex, e)
    for (_, he) in sc.he2v
        e ⊆ he && return true
    end
    false
end

"""
only add the edge if it is not contained in any other edge
and delete the existing edges that it contains and update all of hg.v2he

the issue is you will end up with non-contiguous edges
"""
function Graphs.add_edge!(sc::SComplex, he)
    all(he .<= nv(sc)) || return false
    to_remove = [] # edges that will be covered by downward closure
    n_e = ne(sc)

    new_e_idx = n_e + one(eltype(sc))
    for (hid, set) in sc.he2v # i should be able to just call edges() I think
        if he ⊊ set # already has edge
            return false
        elseif set ⊊ he
            push!(to_remove, hid)# => new_e_idx)
            delete!(sc.he2v, hid)
        end

    end
    update_old_ids!(sc, to_remove)
    e = Set(he)
    sc.he2v[new_e_idx] = e
    for v in e
        push!(sc.v2he[v], new_e_idx)
    end
    true
end

function Graphs.rem_edge!(sc::SComplex, e)
    # new_e_idx = ne(sc) + one(eltype(sc))
    eid = edge_id(sc, e)
    eid === nothing && return false
    delete!(sc.he2v, eid)
    update_old_ids!(sc, [eid])
    true
end

function update_old_ids!(sc, to_remove)
    for xs in sc.v2he
        filter!(!in(to_remove), xs)
        # replace!(xs, to_replace...)
    end
end
function edge_id(sc::SComplex, e)
    for (k, he) in sc.he2v
        e ⊆ he && return k
    end
    nothing
end

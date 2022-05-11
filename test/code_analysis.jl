# making a hypergraph from a module 
# types are vertices and hyperedges are methods

# what about methods with no arguments? maybe just ignore.
# floating hyperedges might be a good idea. this is what SimpleHypergraphs does 
using Hypergraphs, Graphs

module Shake

struct A
    x
end
struct B
    x
    y
end

foo(a::A) = (a, a)
foo(a::A, b::B) = (a, b)

end # Shake

function is_module_function(m, n)
    (length(methods(getproperty(m, n))) > 0) &&
        n != :eval &&
        n != :include
end

function module_functions(m)
    ns = names(m; all=true, imported=true)
    unique!(filter!(n -> is_module_function(m, n), ns))
end

fs_from_mod(m) = map(x -> getproperty(m, x), module_functions(m))
nmethods(m) = sum(map(x -> length(methods(x, m)), fs_from_mod(m)))

"useful to explain why object orientation is a subset of multiple dispatch"
function hypergraph_of_module(M)
    fs = fs_from_mod(M)
    d = Dict{Type,Int}()
    mt = Pair[] # fname to method id
    hg = Hypergraph()
    # we will have a hyperedge for every method
    # and a vertex for every type 
    mid = 1
    for f in fs
        @info "function $f"
        ms = methods(f, M)
        for m in ms
            @info "method $m"
            sig = m.sig
            sts = sig.types # TODO: UnionAll issue. how do I handle parametric types
            push!(mt, (m.module, m.name) => mid)
            vids = []
            for t in sts[2:end] # skip the name 
                if haskey(d, t)
                    vid = d[t]
                else
                    vid = length(d) == 0 ? 1 : length(d) + 1
                    add_vertex!(hg)
                    d[t] = vid
                end
                push!(vids, vid)
            end
            add_edge!(hg, vids)
            mid += 1
        end
    end
    hg
end

M = Shake
hg = hypergraph_of_module(M)
@test ne(hg) == nmethods(M)

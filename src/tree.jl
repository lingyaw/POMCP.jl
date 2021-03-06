abstract type BeliefNode{B,A,O} end
abstract type AbstractActNode end

# Note: links to parents were taken out because they hadn't been used in anything we've done so far
# Note: probably don't need the labels, but they don't seem like they would really kill performance

type ActNode{A, O, BNodeType <: BeliefNode} <: AbstractActNode
    label::A # for keeping track of which action this corresponds to
    N::Int
    V::Float64
    children::Dict{O, BNodeType} # maps observations to ObsNodes
end

type ObsNode{Belief,A,O} <: BeliefNode{Belief,A,O}
    label::O
    N::Int # for dpw, this is the number of times we have transitioned from parent to this from the parent
    B::Belief # belief/state distribution
    children::Dict{A,ActNode{A,O,ObsNode{Belief,A,O}}}
end

type RootNode{RootBelief,A,ANodeType} <: BeliefNode{RootBelief}
    N::Int
    B::RootBelief # belief/state distribution
    children::Dict{A,ANodeType} # ActNode not parameterized here to make initialize_belief more flexible
end
RootNode{RootBelief}(b::RootBelief) = RootNode{RootBelief,Any,ActNode}(0, b, Dict{Any,ActNode}())

"""
    init_V(initializer, problem::POMDPs.POMDP, h::BeliefNode, action)

Return the initial value (V) associated with a new action node when it is created. This can be used in concert with `init_N` to incorporate prior experience into the solver.
"""
function init_V end
init_V(n::Number, problem::POMDPs.POMDP, h::BeliefNode, action) = convert(Float64, n)
init_V(f::Function, problem::POMDPs.POMDP, h::BeliefNode, action) = f(problem, h, action)

"""
    init_N(initializer, problem::POMDPs.POMDP, h::BeliefNode, action)

Return the initial number of queries (N) associated with a new action node when it is created.
"""
function init_N end
init_N(n::Number, problem::POMDPs.POMDP, h::BeliefNode, action) = convert(Int, n)
init_N(f::Function, problem::POMDPs.POMDP, h::BeliefNode, action) = f(problem, h, action)

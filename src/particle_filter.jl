"""
Belief represented by an unweighted collection of particles
"""
type ParticleCollection{S} <: POMDPs.AbstractDistribution{S}
    particles::Vector{S}
    ParticleCollection(particles) = new(particles)
    ParticleCollection() = new(S[])
end

function rand(rng::AbstractRNG, b::ParticleCollection, sample=nothing)
    return b.particles[rand(rng, 1:length(b.particles))]
end

"""
    uses_states_from_planner(belief)

Return true if the belief should use states simulated by the planner for belief estimation.

If this returns true, push!(belief, state) will be called whenever a new state for the belief node is generated by the planner. This is intended to allow users to be able to implement their own, more advanced particle filters that take advantage of the simulations run by the planner.
"""
uses_states_from_planner(::Any) = false
uses_states_from_planner(::ParticleCollection) = true

Base.push!{S}(b::ParticleCollection{S}, state::S) = push!(b.particles, state)

"""
Abstract base for a domain specific device to reinvigorate the particle collection when it has become depleted.

For use with POMCP, a subtype of this should implement the functions reinvigorate! and handle_unseen_observation
"""
abstract ParticleReinvigorator <: POMDPs.Updater{ParticleCollection}

"""
    reinvigorate!(pc::ParticleCollection, r::ParticleReinvigorator, old_node::BeliefNode, a, o)

Add states to pc to prevent particle depletion.

These states shoulc be consistent with the observation-action history accessible through old_node and a and o.
"""
function reinvigorate!(pc::ParticleCollection, r::ParticleReinvigorator, old_node::BeliefNode, a, o)
    error("""
          POMCP.jl reinvigorate! not implemented for reinvigorator $(typeof(r))\n
          argument types:
              b_old::$(typeof(b_old)),
              a::$(typeof(a)), 
              o::$(typeof(o))
          Did you remember to explicitly import reinvigorate!?
          """)
end

"""
    handle_unseen_observation(r::ParticleReinvigorator, old_node::BeliefNode, a, o)

Create and return a new particle (state) collection of particles consistent with o.

This is called when o has not been previously seen during the state and action 
"""
function handle_unseen_observation(r::ParticleReinvigorator, old_node::BeliefNode, a, o)
    error("""
          POMCP.jl: handle_unseen_observation not implemented for reinvigorator $(typeof(r))
          argument types:
              b_old::$(typeof(b_old)),
              a::$(typeof(a)), 
              o::$(typeof(o))
          Did you remember to explicitly import handle_unseen_observation?
          """)
end

"""
Default reinvigorator - cannot do anything since there is no domain knowledge
"""
type DeadReinvigorator <: ParticleReinvigorator end

function reinvigorate!(pc::ParticleCollection, r::DeadReinvigorator, old_node::BeliefNode, a, o)
    return pc # do nothing
end

function handle_unseen_observation(r::DeadReinvigorator, old_node::BeliefNode, a, o)
    error("""
          POMCP.jl: Particle Depletion! To fix this, you have three options:
                1) use more tree_queries (will only work for very small problems)
                2) implement a ParticleReinvigorator with reinvigorate!() and handle_unseen_observation()
                3) implement a more advanced updater for the agent (POMCP can use any
                   belief/state distribution that supports rand())
          """)
end

function update(::DeadReinvigorator, ::Any, ::Any, ::Any, b=nothing)
    error("update() is not implemented for DeadReinvigorator. update() should never be needed for a ParticleReinvigorator because it uses POMCP simulations to approximate belief updates.")
end

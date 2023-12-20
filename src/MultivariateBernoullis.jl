module MultivariateBernoullis
import Random: AbstractRNG

using Distributions

export MultivariateBernoulli, BinaryMarkovChain

# utils first
include("utils/indices.jl")

# distributions
include("distribution.jl")

# markov chains
include("markov_chain/mc.jl")
include("markov_chain/mtd.jl")
end

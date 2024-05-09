module MVBernoulli

import Random: AbstractRNG

using Distributions
using Kronecker, LinearAlgebra

export MultivariateBernoulli

# utils first
include("utils/indices.jl")

# distributions
include("distribution.jl")

# markov chains
include("markov_chain/mc.jl")
include("markov_chain/mtd.jl")
end
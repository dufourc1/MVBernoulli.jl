module MVBernoulli

import Random: AbstractRNG

using Distributions
using Kronecker, LinearAlgebra

export MultivariateBernoulli, fit_mle, from_tabulation, from_ordinary_moments, correlation_matrix, marginals

# utils first
include("utils/indices.jl")

# distributions
include("distribution.jl")

end

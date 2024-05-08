"""
    MultivariateBernoulli{T}

A type for representing a multivariate Bernoulli distribution.

# Fields
- `tabulation::Vector{T}`
- `ordinary_moments::Vector{T}`
- `normalized_moments::Vector{T}`
- `m::Int`: the number of variables

# Description

For a multivariate Bernoulli distribution with `m` variables, the tabulation
is a vector of length `2^m` containing the probabilities of each of the
possible outcomes.

The ordinary moments are the expected values of the variables and of their products.

```math
\\mathbb{E}\\left[\\prod_{i \\in I X_i}\\right],
```
where `I` is a subset of `1:m`.

The normalized moments are
```math
\\mathbb{E}\\left[\\prod_{i \\in I} (X_i - \\mathbb{X_i})\\right].
```
"""
struct MultivariateBernoulli{T <: Real} <: DiscreteMultivariateDistribution
    tabulation::Categorical
    ordinary_moments::Vector{T}
    normalized_moments::Vector{T}
    m::Int
end

Distributions.length(d::MultivariateBernoulli) = d.m
Distributions.eltype(::MultivariateBernoulli) = Bool

function Distributions._rand!(rng::AbstractRNG,
        d::MultivariateBernoulli{T},
        x::Vector{Bool}) where {T}
    index = rand(rng, d.tabulation)
    index_to_binary_vector!(x, index)
end

# allocating but for now will do
function Distributions._rand!(rng::AbstractRNG,
        s::MultivariateBernoulli{T},
        A::Array{Bool, 2}) where {T}
    x = Vector{Bool}(undef, size(A, 1))
    for i in 1:size(A, 2)
        Distributions._rand!(rng, s, x)
        A[:, i] .= x
    end
    return A
end

function Distributions._logpdf(d::MultivariateBernoulli, x::Vector{T}) where {T}
    index = binary_vector_to_index(x)
    return logpdf(d.tabulation, index)
end


function Distributions.fit_mle(::MultivariateBernoulli, data::AbstractMatrix{T}) where {T}
    data_tab = binary_vector_to_index.(eachcol(data))
    return from_tabulation(fit_mle(Categorical, data_tab).p)
end

function _tabulation_to_ordinary_moments(p_tabulation::Vector{T}) where {T}
    m = Int(log2(length(p_tabulation)))
    return kronecker([1 1; 0 1], m) * p_tabulation
end

function _ordinary_moments_to_tabulation(ordinary_moments::Vector{T}) where {T}
    m = Int(log2(length(ordinary_moments)))
    return kronecker([1 -1; 0 1], m) * ordinary_moments
end

function _tabulation_to_centered_moments(p_tabulation::Vector{T},
        ordinary_moments::Vector{T} = _tabulation_to_ordinary_moments(p_tabulation);
        tol = 1e-15) where {T}
    m = Int(log2(length(p_tabulation)))
    transition = kronecker([1 1; -ordinary_moments[3] 1-ordinary_moments[3]],
        [1 1; -ordinary_moments[2] 1-ordinary_moments[2]])
    for i in 3:m
        transition = kronecker([1 1; -ordinary_moments[i + 1] 1-ordinary_moments[i + 1]],
            transition)
    end
    result = transition * p_tabulation
    #set small entries to 0
    result[abs.(result) .< tol] .= 0
    return result
end

function from_tabulation(tabulation::Vector{T}) where {T}
    m = Int(log2(length(tabulation)))
    ordinary_moments = _tabulation_to_ordinary_moments(tabulation)
    normalized_moments = _tabulation_to_centered_moments(tabulation, ordinary_moments)
    return MultivariateBernoulli(Categorical(tabulation),
        ordinary_moments,
        normalized_moments,
        m)
end

function from_ordinary_moments(ordinary_moments::Vector{T}) where {T}
    m = Int(log2(length(ordinary_moments)))
    tabulation = _ordinary_moments_to_tabulation(ordinary_moments)
    normalized_moments = _tabulation_to_centered_moments(tabulation, ordinary_moments)
    return MultivariateBernoulli(Categorical(tabulation),
        ordinary_moments,
        normalized_moments,
        m)
end

function marginals(d::MultivariateBernoulli)
    return [d.ordinary_moments[1 + 2^(k - 1)] for k in 1:length(d)]
end

function correlation_matrix(d::MultivariateBernoulli)
    m = length(d)
    corr = -1 .* ones(m, m)
    ps = marginals(d)
    for i in 1:m
        for j in 1:m
            if i == j
                corr[i, j] = 1
                continue
            end
            if false
                if ps[i] == 1
                    if ps[j] == 0
                        corr[i, j] = -1
                    elseif ps[j] == 1
                        corr[i, j] = 1
                    else
                        corr[i, j] = 0
                    end
                    continue
                elseif ps[i] == 0
                    if ps[j] == 0
                        corr[i, j] = 1
                    elseif ps[j] == 1
                        corr[i, j] = -1
                    else
                        corr[i, j] = 0
                    end
                    continue
                elseif ps[j] == 0 || ps[j] == 1
                    corr[i, j] = 0
                    continue
                end
            end
            k = 1 + 2^(i - 1) + 2^(j - 1)
            corr[i, j] = d.normalized_moments[k] /
                         (sqrt(ps[i] - ps[i]^2) * sqrt(ps[j] - ps[j]^2))
        end
    end
    return corr
end

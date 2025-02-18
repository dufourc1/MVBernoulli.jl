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
\\mathbb{E}\\left[\\prod_{i \\in I} X_i\\right],
```
where `I` is a subset of `1:m`.

The normalized moments are
```math
\\mathbb{E}\\left[\\prod_{i \\in I} (X_i - \\mathbb{E}[X_i])\\right].
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
    #result[abs.(result) .< tol] .= 0
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
    corr = Matrix{Union{Float64, Missing}}(missing, m, m)
    ps = marginals(d)
    for i in 1:m
        for j in 1:m
            if i == j
                corr[i, j] = 1
            elseif ps[i] ∈ [0, 1] || ps[j] ∈ [0, 1]
                corr[i, j] = NaN
            else
                k = 1 + 2^(i - 1) + 2^(j - 1)
                cov = d.normalized_moments[k]
                norm = sqrt((ps[i] - ps[i]^2) * (ps[j] - ps[j]^2))
                corr[i, j] = cov / norm
            end
        end
    end
    return corr
end

function covariance_matrix(d::MultivariateBernoulli)
    m = length(d)
    cov = -1 .* ones(m, m)
    ps = marginals(d)
    for i in 1:m
        for j in 1:m
            if i == j
                cov[i, j] = ps[i] * (1 - ps[i])
            elseif ps[i] ∈ [0, 1] || ps[j] ∈ [0, 1]
                cov[i, j] = NaN
            else
                k = 1 + 2^(i - 1) + 2^(j - 1)
                cov[i, j] = d.normalized_moments[k]
            end
        end
    end
    return cov
end

function Distributions.insupport(d::MultivariateBernoulli, x::Vector{Bool})
    return length(x) == d.m
end

function Distributions.insupport(d::MultivariateBernoulli, x::Vector{R}) where {R <: Real}
    return length(x) == d.m && all(0 .<= x .<= 1) && all(isinteger.(x))
end

function pmf(d::MultivariateBernoulli{T}, x::Vector{B}) where {T, B}
    if !insupport(d, x)
        return 0
    end
    return exp(logpdf(d.tabulation, binary_vector_to_index(x)))
end

function pmf(d::MultivariateBernoulli{T}, x::Vector{Union{B, Missing}}) where {T, B}
    indices_missing = findall(ismissing.(x))
    indices_non_missing = findall(.!ismissing.(x))
    x_new = Vector{Bool}(undef, length(x))
    x_new[indices_non_missing] .= x[indices_non_missing]
    # sum over all possible values for the missing values
    result = 0
    for i in 1:(2^length(indices_missing))
        x_new[indices_missing] .= index_to_binary_vector(i, length(indices_missing))
        result += exp(logpdf(d, x_new))
    end
    return result
end

"""
    conditional probability of x given y. Missing values in y are considered as the unknown values, while
    missing values in x are considered as not important. This means that if we consider the random variable X, and we set
    x = [1, missing, 0, missing] and y = [missing, 1, 0, missing], we are computing the conditional probability of X[1]=1 given X[2] = 1 and X[3] = 0.

    By convention, if proba(y) = 0, then the conditional probability is 0.
"""
function conditional_proba(
        d::MultivariateBernoulli{T}, x::Vector{Bx}, y::Vector{By}) where {T, Bx, By}
    proba_y = pmf(d, y)
    if proba_y == 0
        return proba_y
    end
    x_inter_y = Vector{Union{Bx, By, Missing}}(undef, length(x))
    for i in 1:length(x)
        if !ismissing(x[i])
            if !ismissing(y[i]) && x[i] != y[i] # x and y are incompatible
                return zero(typeof(proba_y))
            else
                x_inter_y[i] = x[i] # x is fixed
            end
        elseif !ismissing(y[i])
            x_inter_y[i] = y[i] # y is fixed
        else
            x_inter_y[i] = missing # both are missing
        end
    end
    return pmf(d, x_inter_y) / proba_y
end

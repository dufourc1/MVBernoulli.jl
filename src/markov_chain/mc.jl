
abstract type AbstractBinaryMC end

"""
    BinaryMarkovChain{M}

A binary Markov chain of order `M`. The transition matrix `T` is of size `2^M x 2^M`, the
state vector `s_vector` is of size `2^M` and is used to convert a state index to a binary
vector representation of the state.

!!! info
    The transition matrix `T` is assumed to be of the form (for `M = 2`)
    ```math
    \\begin{pmatrix}
    T_{00} & T_{01} \\\\
    T_{10} & T_{11}
    \\end{pmatrix}
    ```
    where `T_{ij}` is the probability of transitioning from state `i` to state `j`.

!!! warning
    we do not check that `T` is a valid transition matrix for a de Bruijn graph.
"""
struct BinaryMarkovChain{M, Ttransition} <: AbstractBinaryMC
    T::AbstractMatrix{Ttransition}
    state_index_vector::AbstractVector{AbstractVector{Bool}}
    state_vector_index::Dict{Tuple, Int}
    order::Int

    function BinaryMarkovChain(T::AbstractMatrix{Ttransition}, order) where {Ttransition}
        if size(T, 1) != size(T, 2)
            throw(ArgumentError("T must be a square matrix"))
        elseif size(T, 1) != 2^(order+1)
            throw(ArgumentError("T must be of size 2^(order+1)"))
        end
        num_states = 2^(order+1)
        state_index_vector = Vector{Vector{Bool}}(undef,num_states)
        state_vector_index = Dict{Tuple, Int}()
        @inbounds for i in 1:(num_states)
            state_index_vector[i] = index_to_binary_vector(i, order+1)
            state_vector_index[Tuple(state_index_vector[i])] = i
        end
        new{order, Ttransition}(T, state_index_vector, state_vector_index, order)
    end
end

function get_transition_matrix(chain::BinaryMarkovChain)
    return chain.T
end

function get_stationary_distribution(chain::AbstractBinaryMC)
    result = eigen(transpose(chain.T))
    stationary_dist = real.(result.vectors[:, findmax(real.(result.values))[2]])
    return stationary_dist ./ sum(stationary_dist)
end

function get_bernoulli_distribution(chain::AbstractBinaryMC)
    return from_tabulation(get_stationary_distribution(chain))
end

function from_bernoulli_distribution(distribution::MultivariateBernoulli)
    @error "Not implemented"
end

function sample(chain::BinaryMarkovChain, n::Int)
    result = Vector{Bool}(undef, n)
    result[1:(chain.order+1)] .= rand(get_bernoulli_distribution(chain))
    index = chain.state_vector_index[Tuple(result[1:(chain.order+1)])]
    index_zero = Dict(i => findfirst(chain.T[i, :] .> 0) for i in 1:size(chain.T, 1))
    @inbounds for i in (chain.order + 2):n
        index = chain.state_vector_index[Tuple(result[(i - chain.order-1):(i - 1)])]
        result[i] = rand() > chain.T[index, index_zero[index]]
    end
    return result
end

function fit_transition(data::Vector{T}, chain::BinaryMarkovChain) where {T}
    num_states = 2^(chain.order+1)
    total = zeros(num_states)
    transition = zeros(num_states, num_states)
    @inbounds for t in (chain.order + 2):lastindex(data)
        index = chain.state_vector_index[Tuple(data[(t - chain.order-1):(t - 1)])]
        total[index] += 1
        transition[index, chain.state_vector_index[Tuple(data[(t - chain.order):t])]] += 1
    end
    total[total .== 0] .= 1
    return BinaryMarkovChain(transition ./ total, chain.order)
end

function fit_moment(data::Vector{T}, chain::BinaryMarkovChain) where {T}
    tabulation = zeros(2^(chain.order+1))
    @inbounds for t in 1:(lastindex(data) - chain.order)
        tabulation[chain.state_vector_index[Tuple(data[(t):(t + chain.order)])]] += 1
    end
    return from_tabulation(tabulation ./ (length(data) - chain.order))
end

struct ParametricBinaryChain{M, F, T} <: AbstractBinaryMC
    T::AbstractMatrix{T}
    state_index_vector::AbstractVector{AbstractVector{Bool}}
    state_vector_index::Dict{Tuple, Int}
    order::Int
    func::F
    parameters::Vector{T}
    function ParametricBinaryChain(order, func, parameters::Vector{Tparam}) where {Tparam}
        T = zeros(2^order, 2^order)
        state_index_vector = Vector{Vector{Bool}}(undef, 2^order)
        state_vector_index = Dict{Tuple, Int}()
        @inbounds for i in 1:(2^order)
            state_index_vector[i] = index_to_binary_vector(i, order)
            state_vector_index[Tuple(state_index_vector[i])] = i
        end

        for (i, state) in enumerate(state_index_vector)
            index_1 = state_vector_index[Tuple([state[2:end]..., true])]
            index_0 = state_vector_index[Tuple([state[2:end]..., false])]
            T[i, index_1] = func(state, parameters)
            T[i, index_0] = 1.0 - T[i, index_1]
        end
        new{order, typeof(func), Tparam}(T,
            state_index_vector,
            state_vector_index,
            order,
            func,
            parameters)
    end
end

function logistic_1_m(x, parameters)
    return 1 / (1 + exp(-parameters[1] - parameters[2] * x[1]))
end

function logistic_m_first_order(x, parameters)
    return 1 / (1 + exp(-parameters[1] - sum(parameters[2:end] .* x)))
end

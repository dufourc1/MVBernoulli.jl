function index_to_binary_vector(index::Int, size::Int)
    result = zeros(Int, size)
    index_to_binary_vector!(result, index)
    return result
end

function index_to_binary_vector!(binary_vector::AbstractVector{T}, index::Int) where {T}
    digits!(binary_vector, index - 1; base = 2)
    reverse!(binary_vector)
end

function binary_vector_to_index(binary_vector::AbstractVector{T}) where {T}
    index = 1
    @inbounds for (i, s) in enumerate(Iterators.reverse(binary_vector))
        index += s * 2^(i - 1)
    end
    return index
end

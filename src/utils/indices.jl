function index_to_binary_vector(index::Int, size::Int)
    if index < 1
        throw(ArgumentError("index must be greater than 0"))
    end
    return digits(index - 1, base = 2, pad = size) |> reverse
end

function binary_vector_to_index(binary_vector::AbstractVector{T}) where {T}
    index = 1
    @inbounds for (i, s) in enumerate(Iterators.reverse(binary_vector))
        index += s * 2^(i - 1)
    end
    return index
end

function index_to_binary_vector(index::Int, size::Int)
    result = falses(size)
    index_to_binary_vector!(result, index)
    return result
end

function index_to_binary_vector!(binary_vector, index)
    digits!(binary_vector, index - 1; base = 2)
end

function binary_vector_to_index(binary_vector)
    index = 1
    @inbounds for (i, s) in enumerate(binary_vector)
        index += s * 2^(i - 1)
    end
    return index
end

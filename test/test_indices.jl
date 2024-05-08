@testset "Mapping binary vectors to indices" begin
    m = 4
    receptacle = zeros(Int, m)
    for i in 1:2^4
        MVBernoulli.index_to_binary_vector!(receptacle, i)
        vector = MVBernoulli.index_to_binary_vector(i, m)
        @test i == MVBernoulli.binary_vector_to_index(vector)
        @test vector == receptacle
    end
end

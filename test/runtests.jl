using MVBernoulli
using Test
using Aqua

@testset "MVBernoulli.jl" begin
    include("test_indices.jl")

    #@testset "Code quality (Aqua.jl)" begin
    #    Aqua.test_all(MVBernoulli; deps_compat = false, ambiguities = false)
    #end
end

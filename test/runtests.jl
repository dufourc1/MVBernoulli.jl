using MVBernoulli
using Test
using Aqua

@testset "MVBernoulli.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MVBernoulli; deps_compat = false, ambiguities = false)
    end
    # Write your tests here.
end

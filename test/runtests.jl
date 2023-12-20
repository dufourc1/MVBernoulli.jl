using MultivariateBernoulli
using Test
using Aqua

@testset "MultivariateBernoulli.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MultivariateBernoulli; deps_compat = false, ambiguities = false)
    end
    # Write your tests here.
end

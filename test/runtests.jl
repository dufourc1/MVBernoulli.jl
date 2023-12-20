using MultivariateBernoullis
using Test
using Aqua

@testset "MultivariateBernoullis.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MultivariateBernoullis; deps_compat = false, ambiguities = false)
    end
    # Write your tests here.
end

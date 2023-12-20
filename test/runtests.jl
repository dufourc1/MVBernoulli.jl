using multivarBernoulli
using Test
using Aqua

@testset "multivarBernoulli.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(multivarBernoulli; deps_compat = (check_extras = false,),)
    end
    # Write your tests here.
end

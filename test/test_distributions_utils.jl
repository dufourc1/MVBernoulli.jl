@testset "pmf" begin
    m = 2
    x = zeros(Union{Bool,Missing}, m)
    tabulation = [0.1, 0.2, 0.3, 0.4]
    d = from_tabulation(tabulation)
    marginals = MVBernoulli.marginals(d)
    @test MVBernoulli.pmf(d, [1,missing]) == marginals[1]
    @test MVBernoulli.pmf(d, [missing, 1]) == marginals[2]
end


@testset "conditional proba" begin
    m = 2
    x = zeros(Union{Bool,Missing}, m)
    tabulation = [0.1, 0.2, 0.3, 0.4]
    d = from_tabulation(tabulation)
    marginals = MVBernoulli.marginals(d)
    @test MVBernoulli.conditional_proba(d, [1,missing], [missing, 1]) == 0.4/marginals[2]
    @test MVBernoulli.conditional_proba(d, [0, missing], [1,missing]) == 0
    @test MVBernoulli.conditional_proba(d, [1, 0], [1, missing]) == tabulation[2]/marginals[1]
end

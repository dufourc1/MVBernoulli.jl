@testset "representation" begin
    @testset "marginals" begin
        p = [0.1, 0.2, 0.3, 0.4]
        d = from_tabulation(p)
        @test marginals(d) ≈ [p[2] + p[4], p[3] + p[4]]
        @test p ≈ from_ordinary_moments(d.ordinary_moments).tabulation.p
    end

    @testset "uncorrelated" begin
        for p_1 in 0.01:0.1:0.99
            for p_2 in 0.01:0.1:0.99
                p = [(1-p_1)*(1-p_2),(1-p_2)*p_1,p_2*(1-p_1),p_1*p_2]
                d = from_tabulation(p)
                @test correlation_matrix(d) ≈ [1 0; 0 1]
            end
        end

        for p_1 in [1,0]
            p_2 = 0.5
            p = [(1-p_1)*(1-p_2),(1-p_2)*p_1,p_2*(1-p_1),p_1*p_2]
            d = from_tabulation(p)
            corr =  correlation_matrix(d)
            @test corr[1,1] == corr[2,2] == 1
            @test isnan(corr[1,2])
            @test isnan(corr[2,1])
        end
    end
end



@testset "mle" begin
    d = from_tabulation([0.1, 0.2, 0.3, 0.4])
    data = rand(d, 100)
    counts = zeros(4)
    for x in eachcol(data)
        counts[1 + x[1] + 2*x[2]] += 1
    end
    d_mle = fit_mle(d, data)
    @test d_mle.tabulation.p ≈ counts ./ 100
end

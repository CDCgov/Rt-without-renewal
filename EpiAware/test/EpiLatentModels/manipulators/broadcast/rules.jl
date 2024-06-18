@testitem "RepeatEach rule" begin
    @testset begin
        rule = RepeatEach()
        latent = [1, 2]
        n = 10
        period = 2
        @test broadcast_n(rule, n, period) == 2
        @test broadcast_rule(rule, latent, n, period) == [1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
    end

    @testset begin
        rule = RepeatEach()
        latent = [1, 2, 3]
        n = 10
        period = 2
        @test broadcast_n(rule, n, period) == 2
        using Test

        @test_throws AssertionError broadcast_rule(rule, latent, n, period)
    end
end

@testitem "RepeatBlock rule" begin
    @testset begin
        rule = RepeatBlock()
        latent = [1, 2, 3, 4, 5]
        n = 10
        period = 2
        @test broadcast_n(rule, n, period) == 5
        @test broadcast_rule(rule, latent, n, period) == [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
    end

    @testset begin
        rule = RepeatBlock()
        latent = [1, 2, 3]
        n = 10
        period = 2
        @test broadcast_n(rule, n, period) == 5
        @test_throws AssertionError broadcast_rule(rule, latent, n, period)
    end
end

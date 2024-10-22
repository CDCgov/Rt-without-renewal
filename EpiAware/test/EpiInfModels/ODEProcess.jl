@testitem "ODEParams Tests" begin
    # Test with vectors
    u0_vec = [1.0, 2.0, 3.0]
    p_vec = [0.1, 0.2, 0.3]
    params_vec = ODEParams(u0 = u0_vec, p = p_vec)

    @test params_vec.u0 == u0_vec
    @test params_vec.p == p_vec
    @test eltype(params_vec.u0) == Float64
    @test eltype(params_vec.p) == Float64

    # Test with matrices
    u0_mat = [1.0 2.0; 3.0 4.0]
    p_mat = [0.1 0.2; 0.3 0.4]
    params_mat = ODEParams(u0 = u0_mat, p = p_mat)

    @test params_mat.u0 == u0_mat
    @test params_mat.p == p_mat
    @test eltype(params_mat.u0) == Float64
    @test eltype(params_mat.p) == Float64

    # Test with mixed types (should promote to common type)
    u0_mixed = [1, 2, 3]
    p_mixed = [0.1, 0.2, 0.3]
    params_mixed = ODEParams(u0 = u0_mixed, p = p_mixed)

    @test params_mixed.u0 == Float64.(u0_mixed)
    @test params_mixed.p == Float64.(p_mixed)
    @test eltype(params_mixed.u0) == Float64
    @test eltype(params_mixed.p) == Float64
end

@testitem "ODEProcess + generate_latent_infs Tests" begin
    using OrdinaryDiffEq

    function simple_ode!(du, u, p, t)
        du[1] = p[1] * u[1]
    end

    u0 = [1.0]
    p = [-0.5]
    params = ODEParams(u0 = u0, p = p)
    tspan = (0.0, 10.0)
    prob = ODEProblem(simple_ode!, u0, tspan, p)

    # Define a simple solver and function for testing
    solver = Tsit5()
    sol2infs = sol -> sol[1, :]

    # Create an instance of ODEProcess for testing
    infectionmodel = ODEProcess(prob; ts = [0.0, 1.0, 2.0], solver, sol2infs)

    @testset "ODEProcess constructor" begin
        @test infectionmodel isa ODEProcess
        @test infectionmodel.prob == prob
        @test infectionmodel.ts == [0.0, 1.0, 2.0]
        @test infectionmodel.solver == solver
        @test infectionmodel.sol2infs == sol2infs
    end

    @testset "infection generation accuracy" begin
        actual_infs = map(t -> exp(params.p[1] * t), infectionmodel.ts)
        generated_infs = generate_latent_infs(infectionmodel, params)()
        @test generated_infs≈actual_infs atol=1e-6
    end
end

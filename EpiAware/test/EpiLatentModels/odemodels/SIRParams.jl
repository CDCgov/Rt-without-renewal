@testitem "SIRParams: constructor and `generate_latent`" begin
    using OrdinaryDiffEq, Distributions
    # Define the time span for the ODE problem
    tspan = (0.0, 10.0)

    # Define prior distributions
    infectiousness = LogNormal(log(0.3), 0.05)
    recovery_rate = LogNormal(log(0.1), 0.05)
    initial_prop_infected = Beta(2, 5)

    # Create an instance of SIRParams
    sirparams = SIRParams(
        tspan = tspan,
        infectiousness = infectiousness,
        recovery_rate = recovery_rate,
        initial_prop_infected = initial_prop_infected
    )

    @testset "SIRParams constructor tests" begin
        # Check the types of the fields
        @test sirparams.prob isa ODEProblem
        @test sirparams.infectiousness isa Distribution
        @test sirparams.recovery_rate isa Distribution
        @test sirparams.initial_prop_infected isa Distribution

        # Check the values of the fields
        @test sirparams.prob.tspan == tspan
        @test sirparams.infectiousness == infectiousness
        @test sirparams.recovery_rate == recovery_rate
        @test sirparams.initial_prop_infected == initial_prop_infected
    end

    @testset "SIRParams `generate_latent` tests" begin
        # Generate parameters
        Z_t = rand(10) # dummy latent process
        sirparam_mdl = generate_latent(sirparams, Z_t)
        sampled_params = rand(sirparam_mdl)

        # Check the types of the fields
        @test sampled_params.β isa Float64
        @test sampled_params.γ isa Float64
        @test sampled_params.I₀ isa Float64
    end
end

@testitem "SIRParams: jac_prototype non-zeros invariant to jac call" begin
    Jp = deepcopy(EpiAware.EpiLatentModels._sir_jac_prototype)
    Jp_pattern_before = Jp .!= 0
    u = rand(3)
    p = rand(2)
    EpiAware.EpiLatentModels._sir_jac(Jp, u, p, 0.0)
    Jp_pattern_after = Jp .!= 0

    @test Jp_pattern_before == Jp_pattern_after
end

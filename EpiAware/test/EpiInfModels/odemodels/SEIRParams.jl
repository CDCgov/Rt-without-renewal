@testitem "SEIRParams: constructor and `generate_parameters`" begin
    using OrdinaryDiffEq, Distributions
    # Define the time span for the ODE problem
    tspan = (0.0, 10.0)

    # Define prior distributions
    infectiousness = LogNormal(log(0.3), 0.05)
    incubation_rate = LogNormal(log(0.1), 0.05)
    recovery_rate = LogNormal(log(0.1), 0.05)
    initial_prop_infected = Beta(2, 5)

    # Create an instance of seirparams
    seirparams = SEIRParams(
        tspan = tspan,
        infectiousness = infectiousness,
        incubation_rate = incubation_rate,
        recovery_rate = recovery_rate,
        initial_prop_infected = initial_prop_infected
    )

    @testset "SEIRParams constructor tests" begin
        # Check the types of the fields
        @test seirparams.prob isa ODEProblem
        @test seirparams.infectiousness isa Distribution
        @test seirparams.incubation_rate isa Distribution
        @test seirparams.recovery_rate isa Distribution
        @test seirparams.initial_prop_infected isa Distribution

        # Check the values of the fields
        @test seirparams.prob.tspan == tspan
        @test seirparams.infectiousness == infectiousness
        @test seirparams.incubation_rate == incubation_rate
        @test seirparams.recovery_rate == recovery_rate
        @test seirparams.initial_prop_infected == initial_prop_infected
    end

    @testset "SEIRParams `generate_parameters` tests" begin
        # Generate parameters
        Z_t = rand(10) # dummy latent process
        seirparam_mdl = generate_parameters(seirparams, Z_t)
        sampled_params = rand(seirparam_mdl)

        # Check the types of the fields
        @test sampled_params.β isa Float64
        @test sampled_params.α isa Float64
        @test sampled_params.γ isa Float64
        @test sampled_params.initial_infs isa Float64
    end
end

@testitem "SEIRParams: jac_prototype non-zeros invariant to jac call" begin
    Jp = deepcopy(EpiAware.EpiInfModels._seir_jac_prototype)
    Jp_pattern_before = Jp .!= 0
    u = rand(4)
    p = rand(3)
    EpiAware.EpiInfModels._seir_jac(Jp, u, p, 0.0)
    Jp_pattern_after = Jp .!= 0

    @test Jp_pattern_before == Jp_pattern_after
end

@testitem "SEIRParams: constructor and `generate_parameters`" begin
    using OrdinaryDiffEq, Distributions
    # Define the time span for the ODE problem
    tspan = (0.0, 10.0)

    # Define prior distributions
    infectiousness_prior = LogNormal(log(0.3), 0.05)
    incubation_rate_prior = LogNormal(log(0.1), 0.05)
    recovery_rate_prior = LogNormal(log(0.1), 0.05)
    initial_prop_infected_prior = Beta(2, 5)

    # Create an instance of seirparams
    seirparams = SEIRParams(
        tspan = tspan,
        infectiousness_prior = infectiousness_prior,
        incubation_rate_prior = incubation_rate_prior,
        recovery_rate_prior = recovery_rate_prior,
        initial_prop_infected_prior = initial_prop_infected_prior
    )

    @testset "SEIRParams constructor tests" begin
        # Check the types of the fields
        @test seirparams.prob isa ODEProblem
        @test seirparams.infectiousness_prior isa Distribution
        @test seirparams.incubation_rate_prior isa Distribution
        @test seirparams.recovery_rate_prior isa Distribution
        @test seirparams.initial_prop_infected_prior isa Distribution

        # Check the values of the fields
        @test seirparams.prob.tspan == tspan
        @test seirparams.infectiousness_prior == infectiousness_prior
        @test seirparams.incubation_rate_prior == incubation_rate_prior
        @test seirparams.recovery_rate_prior == recovery_rate_prior
        @test seirparams.initial_prop_infected_prior == initial_prop_infected_prior
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
        @test sampled_params.I₀ isa Float64
    end
end

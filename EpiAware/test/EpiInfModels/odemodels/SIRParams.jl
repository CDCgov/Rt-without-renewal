@testitem "SIRParams: constructor and `generate_parameters`" begin
    using OrdinaryDiffEq, Distributions
    # Define the time span for the ODE problem
    tspan = (0.0, 10.0)

    # Define prior distributions
    infectiousness_prior = LogNormal(log(0.3), 0.05)
    recovery_rate_prior = LogNormal(log(0.1), 0.05)
    initial_prop_infected_prior = Beta(2, 5)

    # Create an instance of SIRParams
    sirparams = SIRParams(
        tspan = tspan,
        infectiousness_prior = infectiousness_prior,
        recovery_rate_prior = recovery_rate_prior,
        initial_prop_infected_prior = initial_prop_infected_prior
    )

    @testset "SIRParams constructor tests" begin
        # Check the types of the fields
        @test sirparams.prob isa ODEProblem
        @test sirparams.infectiousness_prior isa Distribution
        @test sirparams.recovery_rate_prior isa Distribution
        @test sirparams.initial_prop_infected_prior isa Distribution

        # Check the values of the fields
        @test sirparams.prob.tspan == tspan
        @test sirparams.infectiousness_prior == infectiousness_prior
        @test sirparams.recovery_rate_prior == recovery_rate_prior
        @test sirparams.initial_prop_infected_prior == initial_prop_infected_prior
    end

    @testset "SIRParams `generate_parameters` tests" begin
        # Generate parameters
        Z_t = rand(10) # dummy latent process
        sirparam_mdl = generate_parameters(sirparams, Z_t)
        sampled_params = rand(sirparam_mdl)

        # Check the types of the fields
        @test sampled_params.β isa Float64
        @test sampled_params.γ isa Float64
        @test sampled_params.I₀ isa Float64
    end
end

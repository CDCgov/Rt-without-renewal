@testitem "ODEProcess for SIR model constructor + `generate_latent_infs` tests" begin
    using OrdinaryDiffEq, Distributions
    # Define the time span for the ODE problem
    tspan = (0.0, 30.0)

    # Define prior distributions
    infectiousness_prior = LogNormal(log(0.3), 0.05)
    recovery_rate_prior = LogNormal(log(0.1), 0.05)
    initial_prop_infected_prior = Beta(1, 99)

    # Create an instance of SIRParams
    sirparams = SIRParams(
        tspan = tspan,
        infectiousness_prior = infectiousness_prior,
        recovery_rate_prior = recovery_rate_prior,
        initial_prop_infected_prior = initial_prop_infected_prior
    )

    # Define the SIR ODEProcess model
    # using solver_options as a Dict
    sir_process = ODEProcess(
        params = sirparams,
        sol2infs = sol -> sol[2, :],
        solver_options = Dict(:verbose => false, :saveat => 1.0, :reltol => 1e-10)
    )
    # Define the SIR ODEProcess model
    # using solver_options as a NamedTuple
    sir_process2 = ODEProcess(
        params = sirparams,
        sol2infs = sol -> sol[2, :],
        solver_options = (verbose = false, saveat = 1.0, reltol = 1e-10)
    )
    @testset "Constructor tests" begin
        # Check the types of the fields
        @test sir_process.params isa SIRParams
        @test sir_process.sol2infs isa Function
        @test sir_process.solver_options isa Dict
        @test sir_process2.solver_options isa NamedTuple
    end

    @testset "generate_latent_infs tests equal with both solver_options" begin
        Z_t = rand(10) # dummy latent process
        inf_mdl = generate_latent_infs(sir_process, Z_t)
        inf_mdl2 = generate_latent_infs(sir_process2, Z_t)
        θ = rand(inf_mdl)
        θ2 = rand(inf_mdl2)
        @test keys(θ) == keys(θ2)
        It = (inf_mdl | θ)()
        It2 = (inf_mdl2 | θ)()

        @test It ≈ It2
    end
end

@testitem "ODEProcess for SEIR model constructor + `generate_latent_infs` tests" begin
    using OrdinaryDiffEq, Distributions
    # Define the time span for the ODE problem
    tspan = (0.0, 30.0)

    # Define prior distributions
    infectiousness_prior = LogNormal(log(0.3), 0.05)
    incubation_rate_prior = LogNormal(log(0.1), 0.05)
    recovery_rate_prior = LogNormal(log(0.1), 0.05)
    initial_prop_infected_prior = Beta(1, 99)

    # Create an instance of SIRParams
    seirparams = SEIRParams(
        tspan = tspan,
        infectiousness_prior = infectiousness_prior,
        incubation_rate_prior = incubation_rate_prior,
        recovery_rate_prior = recovery_rate_prior,
        initial_prop_infected_prior = initial_prop_infected_prior
    )

    # Define the SIR ODEProcess model
    # using solver_options as a Dict
    seir_process = ODEProcess(
        params = seirparams,
        sol2infs = sol -> sol[2, :],
        solver_options = Dict(:verbose => false, :saveat => 1.0, :reltol => 1e-10)
    )
    # Define the SIR ODEProcess model
    # using solver_options as a NamedTuple
    seir_process2 = ODEProcess(
        params = seirparams,
        sol2infs = sol -> sol[2, :],
        solver_options = (verbose = false, saveat = 1.0, reltol = 1e-10)
    )
    @testset "Constructor tests" begin
        # Check the types of the fields
        @test seir_process.params isa SEIRParams
        @test seir_process.sol2infs isa Function
        @test seir_process.solver_options isa Dict
        @test seir_process2.solver_options isa NamedTuple
    end

    @testset "generate_latent_infs tests equal with both solver_options" begin
        Z_t = rand(10) # dummy latent process
        inf_mdl = generate_latent_infs(seir_process, Z_t)
        inf_mdl2 = generate_latent_infs(seir_process2, Z_t)
        θ = rand(inf_mdl)
        θ2 = rand(inf_mdl2)
        @test keys(θ) == keys(θ2)
        It = (inf_mdl | θ)()
        It2 = (inf_mdl2 | θ)()

        @test It ≈ It2
    end
end

@testitem "Custom ODE model" begin
    using OrdinaryDiffEq, Distributions, Turing

    # Define a simple exponential growth model for testing
    function expgrowth(du, u, p, t)
        du[1] = p[1] * u[1]
    end

    r = log(2) / 7 # Growth rate corresponding to 7 day doubling time

    # Define the ODE problem using SciML
    prob = ODEProblem(expgrowth, [1.0], (0.0, 10.0), [r])

    # Define the custom parameters struct
    struct CustomParams <: AbstractTuringParamModel
        prob::ODEProblem
        r::Float64
        u0::Float64
    end
    params = CustomParams(prob, r, 1.0)

    # Define the custom generate_parameters function
    @model function EpiAwareBase.generate_parameters(params::CustomParams, Z_t)
        return ([params.u0], [params.r])
    end

    # Define the ODEProcess
    expgrowth_model = ODEProcess(
        params = params,
        sol2infs = sol -> sol[1, :]
    )

    # Generate the latent infections
    Z_t = rand(10) # dummy latent process
    inf_mdl = generate_latent_infs(expgrowth_model, Z_t)
    @test rand(inf_mdl) == NamedTuple()
    I_t = inf_mdl()
    @test length(I_t) == 11
    @test I_t ≈ [exp(r * t) for t in 0:10]
end

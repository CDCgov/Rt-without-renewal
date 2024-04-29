@testitem "condition_model method for Turing" begin
    using Turing, Distributions

    @model function test_mdl()
        x ~ Normal(0, 1)
        y ~ Normal(x, 1)
    end

    mdl = test_mdl()
    cond_model = condition_model(mdl, (x = 2.0,), (y = 1.0,))
    @test cond_model() == 1.0
    @test rand(cond_model) == NamedTuple()
end

@testitem "generated_observables method for Turing" begin
    using Turing, Distributions

    @model function test_mdl(y)
        x ~ Normal(0, 1)
        y ~ Normal(x, 1)
        return x + y
    end

    mdl = test_mdl(missing)
    gen_obs = generated_observables(mdl, missing, rand(mdl))

    @test typeof(gen_obs) <: EpiAwareObservables
    @test fieldnames(typeof(gen_obs)) == (:model, :data, :samples, :generated)
    @test fieldnames(typeof(gen_obs.samples)) == (:x, :y)
    @test gen_obs.generated == sum(gen_obs.samples)
    @test gen_obs.model == mdl
    @test ismissing(gen_obs.data)
end

@testitem "apply_method and _apply_method function for Turing" begin
    using Turing, Distributions, DynamicPPL

    @model function test_model()
        x ~ Normal(0, 1)
    end
    struct CustomSampler <: AbstractEpiSamplingMethod end

    function EpiAware.EpiAwareBase._apply_method(
            model::Model, method::CustomSampler, prev_result = nothing; kwargs...)
        return isnothing(prev_result) ? "x" : prev_result * ", x"
    end

    model = test_model()
    cs = CustomSampler()

    struct CustomOpt <: AbstractEpiOptMethod end

    function EpiAware.EpiAwareBase._apply_method(
            model::Model, method::CustomOpt, prev_result = nothing; kwargs...)
        return isnothing(prev_result) ? "z" : prev_result * ", z"
    end

    co = CustomOpt()

    @testset "with optimization steps" begin
        em = EpiMethod([co, co], cs)
        @test EpiAwareBase._apply_method(model, em) == "z, z, x"
        @test EpiAwareBase._apply_method(model, em, "y") == "y, z, z, x"
    end
end

@testitem "Turing method for generate_epiaware with two latent processes" begin
    using Distributions, Turing

    # Latent model
    damp_prior = truncated(Normal(0.0, 0.05), 0.0, 1)
    std_prior = truncated(Normal(0.0, 0.05), 0.0, Inf)
    init_prior = Normal()
    ar_process = AR(damp_prior, std_prior, init_prior)

    # Used again in obs model

    obs_ascert = Ascertainment(PoissonError(), ar_process, exp)

    #Epi model
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()

    direct_inf_model = DirectInfections(data, log_init_incidence_prior)

    #use generate_epiaware
    mdl = generate_epiaware(missing, 10, direct_inf_model; latent_model = ar_process,
        observation_model = obs_ascert)

    #Check that can sample from model and has appropriate keys/variables
    θ = rand(mdl)
    #Both latent and obs processes should be present
    @test haskey(θ, Symbol("obs.ϵ_t"))
    @test haskey(θ, Symbol("latent.ϵ_t"))

    #Check can sample from model prior
    chn = sample(mdl, Prior(), 1000; progress = false)
    @test Symbol("latent.ϵ_t[1]") ∈ keys(chn)
    @test Symbol("obs.ϵ_t[1]") ∈ keys(chn)
    #Check that can generate quantities
    gens = generated_quantities(mdl, chn)
    @test gens isa Matrix
end

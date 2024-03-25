@testitem "generate_latent_infs function: default" begin
    latent_model = [0.1, 0.2, 0.3]
    init_incidence = 10.0

    struct TestEpiModel <: EpiAware.EpiAwareBase.AbstractEpiModel
    end

    @test isnothing(generate_latent_infs(TestEpiModel(), latent_model))
end

@testitem "Testing generate_observations default" begin
    struct TestObsModel <: EpiAware.EpiAwareBase.AbstractObservationModel
    end

    @test try
        generate_observations(TestObsModel(), missing, missing)
        true
    catch
        false
    end
end

@testitem "_apply_method function: default" begin
    using Turing
    struct TestEpiMethod <: EpiAware.EpiAwareBase.AbstractEpiMethod
    end

    @model test_mdl() = begin
        x ~ Normal(0, 1)
    end

    mdl = test_mdl()

    @test isnothing(_apply_method(TestEpiMethod(), mdl, nothing))
end

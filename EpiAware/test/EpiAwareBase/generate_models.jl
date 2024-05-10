@testitem "generate_latent function: default" begin
    struct TestLatentModel <: EpiAware.EpiAwareBase.AbstractLatentModel
    end

    @test isnothing(generate_latent(TestLatentModel(), missing))
end

@testitem "generate_infections function: default" begin
    latent_model = [0.1, 0.2, 0.3]
    init_incidence = 10.0

    struct TestEpiModel <: EpiAware.EpiAwareBase.AbstractEpiModel
    end

    @test isnothing(generate_infectionsestEpiModel(), latent_model))
end

@testitem "Testing generate_observations default" begin
    struct TestObsModel <: EpiAware.EpiAwareBase.AbstractObservationModel
    end

    @test isnothing(generate_observations(TestObsModel(), missing, missing))
end

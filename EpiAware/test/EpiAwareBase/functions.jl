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

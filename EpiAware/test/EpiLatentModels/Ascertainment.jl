@testitem "Test Ascertainment constructor" begin
    using Turing
    struct Scale <: AbstractLatentModel
    end

    @model function EpiAware.generate_latent(model::Scale, n::Int)
        scale = 0.1
        scale_vect = fill(scale, n)
        return scale_vect, (; scale = scale)
    end
    asc = Ascertainment(NegativeBinomialError(), Scale(), x -> x)
    @test asc.model == NegativeBinomialError()
    @test asc.latentmodel == Scale()
    @test asc.link == x -> x
end

# make a test based on above example
@testitem "Test Ascertainment generate_observations" begin
    using Turing, DynamicPPL
    struct Scale <: AbstractLatentModel
    end

    @model function EpiAware.generate_latent(model::Scale, n::Int)
        scale = 0.1
        scale_vect = fill(scale, n)
        return scale_vect, (; scale = scale)
    end
    obs = Ascertainment(NegativeBinomialError(), Scale(), x -> x)
    gen_obs = generate_observations(obs, missing, fill(100, 10))
end

@testitem "Test Ascertainment constructor" begin
    using Turing
    struct Scale <: AbstractTuringLatentModel
    end

    @model function EpiAware.generate_latent(model::Scale, n::Int)
        scale = 0.1
        scale_vect = fill(scale, n)
        return scale_vect, (; scale = scale)
    end

    function natural(x)
        return x
    end

    asc = Ascertainment(NegativeBinomialError(), Scale(), natural)
    @test asc.model == NegativeBinomialError()
    @test asc.latentmodel == Scale()
    @test asc.link == natural
end

# make a test based on above example
@testitem "Test Ascertainment generate_observations" begin
    using Turing, DynamicPPL
    struct Scale <: AbstractTuringLatentModel end

    @model function EpiAware.generate_latent(model::Scale, n::Int)
        scale = 0.1
        scale_vect = fill(scale, n)
        return scale_vect, (; scale = scale)
    end
    obs = Ascertainment(NegativeBinomialError(), Scale(), x -> x)
    gen_obs = generate_observations(obs, missing, fill(100, 10))
    samples = sample(gen_obs, Prior(), 100; progress = false)
    gen = mapreduce(vcat, generated_quantities(gen_obs, samples)) do gen
        gen[2][:expected_obs]
    end
    @test all(gen .== 10.0)
end

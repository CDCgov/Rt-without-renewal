@testitem "Test Ascertainment constructor" begin
    using Turing
    function natural(x)
        return x
    end

    asc = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1), natural)
    @test asc.model == NegativeBinomialError()
    @test asc.latentmodel == FixedIntercept(0.1)
    @test asc.link == natural
end

# make a test based on above example
@testitem "Test Ascertainment generate_observations" begin
    using Turing, DynamicPPL
    obs = Ascertainment(NegativeBinomialError(), FixedIntercept(0.1), x -> x)
    gen_obs = generate_observations(obs, missing, fill(100, 10))
    samples = sample(gen_obs, Prior(), 100; progress = false)
    gen = mapreduce(vcat, generated_quantities(gen_obs, samples)) do gen
        gen[2][:expected_obs]
    end
    @test all(gen .== 10.0)
end

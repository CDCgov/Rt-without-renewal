
@testitem "CombineLatentModels constructor works as expected" begin
    using Distributions: Normal
    int = Intercept(Normal(0, 1))
    ar = AR()
    comb = CombineLatentModels([int, ar])
    @test typeof(comb) <: AbstractTuringLatentModel
    @test comb.models == [int, ar]
end

@testitem "CombineLatentModels generate_latent method works as expected" begin
    using Turing

    struct NextScale <: AbstractTuringLatentModel end

    @model function EpiAware.EpiAwareBase.generate_latent(model::NextScale, n::Int)
        scale = 2
        return scale_vect = fill(scale, n), (; nscale = scale)
    end

    s = FixedIntercept(1)
    ns = NextScale()
    comb = CombineLatentModels([s, ns])
    comb_model = generate_latent(comb, 5)
    comb_model_out = comb_model()

    @test typeof(comb_model) <: DynamicPPL.Model
    @test length(comb_model_out[1]) == 5
    @test all(comb_model_out[1] .== fill(3.0, 5))
    @test comb_model_out[2].intercept == 1.0
    @test comb_model_out[2].nscale == 2.0
end

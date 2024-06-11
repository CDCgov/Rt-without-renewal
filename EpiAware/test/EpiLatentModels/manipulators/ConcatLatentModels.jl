@testitem "Test ConcatLatentModels struct" begin
    using Distributions: Normal
    int = Intercept(Normal(0, 1))
    ar = AR()
    concat = ConcatLatentModels([int, ar])
    @test typeof(concat) <: AbstractTuringLatentModel
    @test concat.models == [int, ar]
    @test concat.no_models == 2
    @test concat.dimension_adaptor == equal_dimensions

    function custom_dim(n::Int, no_models::Int)::Vector{Int}
        return vcat(4, equal_dimensions(n - 4, no_models - 1))
    end

    concat_custom = ConcatLatentModels([int, ar]; dimension_adaptor = custom_dim)

    @test concat_custom.models == [int, ar]
    @test concat_custom.no_models == 2
    @test concat_custom.dimension_adaptor == custom_dim
    @test concat_custom.dimension_adaptor(10, 4) == [4, 2, 2, 2]
end

@testitem "ConcatLatentModels generate_latent method works as expected: FixedIntecept + custom" begin
    using Turing

    struct NextScale <: AbstractTuringLatentModel end

    @model function EpiAware.EpiAwareBase.generate_latent(model::NextScale, n::Int)
        scale = 2
        return scale_vect = fill(scale, n), (; nscale = scale)
    end

    s = FixedIntercept(1)
    ns = NextScale()
    con = ConcatLatentModels([s, ns])
    con_model = generate_latent(con, 5)
    con_model_out = con_model()

    @test typeof(con_model) <: DynamicPPL.Model
    @test length(con_model_out[1]) == 5
    @test all(con_model_out[1] .== vcat(fill(1.0, 3), fill(2.0, 2)))
    @test con_model_out[2].intercept == 1.0
    @test con_model_out[2].nscale == 2.0
end

@testitem "Test ConcatLatentModels struct" begin
    using Distributions: Normal
    int = Intercept(Normal(0, 1))
    ar = AR()
    prefix_int = PrefixLatentModel(int, "Concat.1")
    prefix_ar = PrefixLatentModel(ar, "Concat.2")
    concat = ConcatLatentModels([int, ar])
    @test typeof(concat) <: AbstractTuringLatentModel
    @test concat.models == [prefix_int, prefix_ar]
    @test concat.no_models == 2
    @test concat.dimension_adaptor == equal_dimensions
    @test concat.prefixes == ["Concat.1", "Concat.2"]

    function custom_dim(n::Int, no_models::Int)::Vector{Int}
        return vcat(4, equal_dimensions(n - 4, no_models - 1))
    end

    concat_custom = ConcatLatentModels([int, ar]; dimension_adaptor = custom_dim)

    @test concat_custom.models == [prefix_int, prefix_ar]
    @test concat_custom.no_models == 2
    @test concat_custom.dimension_adaptor == custom_dim
    @test concat_custom.dimension_adaptor(10, 4) == [4, 2, 2, 2]
    @test concat_custom.prefixes == ["Concat.1", "Concat.2"]

    concat_prefix = ConcatLatentModels([int, ar]; prefixes = ["Int", "AR"])
    prefix_ar = PrefixLatentModel(ar, "AR")
    prefix_int = PrefixLatentModel(int, "Int")
    @test concat_prefix.models == [prefix_int, prefix_ar]
    @test concat_prefix.no_models == 2
    @test concat_prefix.dimension_adaptor == equal_dimensions
    @test concat_prefix.prefixes == ["Int", "AR"]
end

@testitem "ConcatLatentmodels constructor works with duplicate models" begin
    using Distributions: Normal
    concat = ConcatLatentModels([Intercept(Normal(0, 1)), Intercept(Normal(0, 2))])
    prefix_1 = PrefixLatentModel(Intercept(Normal(0, 1)), "Concat.1")
    prefix_2 = PrefixLatentModel(Intercept(Normal(0, 2)), "Concat.2")

    @test typeof(concat) <: AbstractTuringLatentModel
    @test concat.models == [prefix_1, prefix_2]
    @test concat.no_models == 2
    @test concat.dimension_adaptor == equal_dimensions
    @test concat.prefixes == ["Concat.1", "Concat.2"]
end

@testitem "ConcatLatentModels generate_latent method works as expected: FixedIntecept + custom" begin
    using Turing

    struct NextScale <: AbstractTuringLatentModel end

    @model function EpiAware.EpiAwareBase.generate_latent(model::NextScale, n::Int)
        scale = 2
        return scale_vect = fill(scale, n)
    end

    s = FixedIntercept(1)
    ns = NextScale()
    con = ConcatLatentModels([s, ns])
    con_model = generate_latent(con, 5)
    con_model_out = con_model()

    @test typeof(con_model) <: DynamicPPL.Model
    @test length(con_model_out) == 5
    @test all(con_model_out .== vcat(fill(1.0, 3), fill(2.0, 2)))
end

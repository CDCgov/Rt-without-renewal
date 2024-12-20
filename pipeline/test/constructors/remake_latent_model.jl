@testset "remake_latent_model tests" begin
    struct MockPipeline <: AbstractRtwithoutRenewalPipeline end
    function make_model_priors(pipeline::MockPipeline)
        return Dict(
            "damp_param_prior" => Beta(2, 8),
            "transformed_process_init_prior" => Normal(0, 1)
        )
    end
    pipeline = MockPipeline()

    @testset "diff_ar model" begin
        inference_config = Dict(
            "igp" => ExpGrowthRate, "latent_namemodels" => ("diff_ar" => "diff_ar"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa DiffLatentModel
        @test model.model isa AR

        inference_config = Dict(
            "igp" => DirectInfections, "latent_namemodels" => ("diff_ar" => "diff_ar"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa DiffLatentModel
        @test model.model isa AR
    end

    @testset "ar model" begin
        inference_config = Dict("igp" => Renewal, "latent_namemodels" => Pair("ar", "ar"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa AR

        inference_config = Dict(
            "igp" => ExpGrowthRate, "latent_namemodels" => Pair("ar", "ar"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa AR

        inference_config = Dict(
            "igp" => DirectInfections, "latent_namemodels" => Pair("ar", "ar"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa AR
    end

    @testset "rw model" begin
        inference_config = Dict("igp" => Renewal, "latent_namemodels" => Pair("rw", "rw"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa RandomWalk

        inference_config = Dict(
            "igp" => ExpGrowthRate, "latent_namemodels" => Pair("rw", "rw"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa RandomWalk

        inference_config = Dict(
            "igp" => DirectInfections, "latent_namemodels" => Pair("rw", "rw"))
        model = remake_latent_model(inference_config, pipeline)
        @test model isa RandomWalk
    end
end

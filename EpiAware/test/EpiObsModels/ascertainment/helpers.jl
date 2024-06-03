@testitem "ascertainment_dayofweek correctly constructs a day of week ascertainment model" begin
    using DynamicPPL
    obs = ascertainment_dayofweek(PoissonError())
    @test typeof(obs) == Ascertainment
    @test typeof(obs.model) == PoissonError
    @test typeof(obs.latentmodel) == HierarchicalNormal
    @test obs.link(1) == exp(1)

    obs_model = generate_observations(obs, missing, fill(100, 14))
    dayofweek_effect = [-0.1, 0.1, 0.2, 0.2, -0.4, 0.1, 0]
    expected_obs = repeat(exp.(dayofweek_effect) .* 100, 2)
    fix_obs_model = fix(obs_model, (ϵ_t = dayofweek_effect, std = 1))
    gq_expected_obs = fix_obs_model()[2].expected_obs
    @test expected_obs ≈ gq_expected_obs
end

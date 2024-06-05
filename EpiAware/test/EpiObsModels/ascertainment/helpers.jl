@testitem "ascertainment_dayofweek correctly constructs a day of week ascertainment model" begin
    using DynamicPPL, LogExpFunctions
    obs = ascertainment_dayofweek(PoissonError())

    incidence_each_ts = 100.0
    nweeks = 2

    obs_model = generate_observations(obs, missing, fill(incidence_each_ts, nweeks * 7))
    dayofweek_effect = [-0.1, 0.1, 0.2, 0.2, -0.4, 0.1, 0]
    expected_obs = repeat(7 * softmax(dayofweek_effect) .* incidence_each_ts, nweeks)
    fix_obs_model = fix(obs_model, (ϵ_t = dayofweek_effect, std = 1))
    gq_expected_obs = fix_obs_model()[2].expected_obs
    @test expected_obs ≈ gq_expected_obs
end

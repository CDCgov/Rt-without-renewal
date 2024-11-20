@testitem "ascertainment_dayofweek correctly constructs a day of week ascertainment model" begin
    using DynamicPPL, LogExpFunctions, Turing, DataFrames

    struct ExpectedObs <: AbstractTuringObservationModel
        model::AbstractTuringObservationModel
    end

    @model EpiAware.EpiAwareBase.generate_observations(model::ExpectedObs, y_t,
    Y_t) = begin
        expected_obs := Y_t
        @submodel y_t = generate_observations(model.model, y_t, Y_t)
    end

    obs = ascertainment_dayofweek(ExpectedObs(PoissonError()))

    incidence_each_ts = 100.0
    nweeks = 2

    obs_model = generate_observations(obs, missing, fill(incidence_each_ts, nweeks * 7))
    dayofweek_effect = [-0.1, 0.1, 0.2, 0.2, -0.4, 0.1, 0]
    expected_obs = repeat(7 * softmax(dayofweek_effect) .* incidence_each_ts, nweeks)
    fix_obs_model = fix(
        obs_model, (var"DayofWeek.ϵ_t" = dayofweek_effect, var"DayofWeek.std" = 1))
    samples = sample(fix_obs_model, Prior(), 10; progress = false)

    gq_expected_obs = get(samples, :expected_obs).expected_obs |>
                      x -> hcat(x...) |>
                           #iterate by row of a matrix
                           x -> map(eachrow(x)) do row
        @test row ≈ expected_obs
    end
end

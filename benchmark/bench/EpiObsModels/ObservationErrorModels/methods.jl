suite["observation_error"] = BenchmarkGroup()

let
    using Distributions, Turing

    struct TestObs <: AbstractTuringObservationErrorModel end

    function EpiObsModels.observation_error(model::TestObs, Y_t, std)
        Normal(Y_t, std)
    end

    @model function EpiObsModels.generate_observation_error_priors(model::TestObs, y_t, Y_t)
        std ~ truncated(Normal(0.0, 1.0), 0.0, 1.0)
        return (std,)
    end

    obs_model = TestObs()

    I_t = [10.0, 20.0, 30.0, 40.0, 50.0]
    mdl = generate_observations(obs_model, missing, I_t)

    suite["observation_error"]["missing obs"] = make_turing_suite(mdl; check = false)

    missing_I_t = vcat(missing, I_t)
    mdl2 = generate_observations(obs_model, missing_I_t, vcat(20, I_t))
    suite["observation_error"]["partially missing obs"] = make_turing_suite(
        mdl2; check = false)

    mdl3 = generate_observations(obs_model, I_t, I_t)
    suite["observation_error"]["no missing obs"] = make_turing_suite(mdl3; check = true)
end

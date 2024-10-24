let
    I_t = fill(5, 100)
    transform_obs = TransformObservationModel(NegativeBinomialError())
    mdl = generate_observations(transform_obs, I_t, I_t)
    suite["TransformObservationModel"] = make_epiaware_suite(mdl)
end

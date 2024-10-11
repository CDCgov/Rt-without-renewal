let
    I_t = fill(5.0, 100)
    transform_obs = TransformObservationModel(PoissonError())
    mdl = generate_observations(transform_obs, missing, I_t)
    suite["TransformObservationModel"] = make_epiaware_suite(mdl)
end

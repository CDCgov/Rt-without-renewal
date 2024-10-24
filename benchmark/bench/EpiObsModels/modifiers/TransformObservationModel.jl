let
    transform_obs = TransformObservationModel(NegativeBinomialError())
    mdl = generate_observations(transform_obs, fill(10, 10), fill(9, 10))
    suite["TransformObservationModel"] = make_epiaware_suite(mdl)
end

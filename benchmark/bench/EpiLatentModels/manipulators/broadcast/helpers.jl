let
    model = RandomWalk()
    broadcast_model = broadcast_dayofweek(model)
    mdl = generate_latent(broadcast_model, 10)
    suite["broadcast_dayofweek"] = make_epiaware_suite(mdl)
end

let
    model = AR()
    broadcast_model = broadcast_weekly(model)
    mdl = generate_latent(broadcast_model, 10)
    suite["broadcast_weekly"] = make_epiaware_suite(mdl)
end

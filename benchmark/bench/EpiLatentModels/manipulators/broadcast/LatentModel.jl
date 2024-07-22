let
    model = BroadcastLatentModel(RandomWalk(), 5, RepeatBlock())
    broadcasted_model = generate_latent(model, 10)
    suite["BroadcastLatentModel"] = make_epiaware_suite(broadcasted_model)
end

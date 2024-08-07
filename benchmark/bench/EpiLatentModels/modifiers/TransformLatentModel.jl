let
    using Turing, Distributions

    trans = TransformLatentModel(Intercept(Normal(2, 0.2)), x -> x .|> exp)
    mdl = generate_latent(trans, 5)
    suite["TransformLatentModel"] = make_epiaware_suite(mdl)
end

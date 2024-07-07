let
    using Distributions, Turing, DynamicPPL
    @model function model(n)
        x ~ Normal(0, 1)
        @submodel y, _ = generate_latent(FixedIntercept(x), n)
        return y
    end
    mdl = model(10)
    suite["Intercept"] = make_turing_suite(mdl; check = true)
end

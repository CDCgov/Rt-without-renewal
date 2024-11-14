# Error:  ArgumentError: Converting an instance of ReverseDiff.TrackedReal{Float64, Float64, Nothing} to Float64 is not defined. Please use `ReverseDiff.value` instead.
let
    using Distributions
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp
    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()
    renewal_model = Renewal(data, log_init_incidence_prior)

    #Actual Rt
    Rt = [1.0, 1.2, 1.5, 1.5, 1.5]
    log_Rt = log.(Rt)
    initial_incidence = [1.0, 1.0, 1.0]#aligns with initial exp growth rate of 0.
    mdl = generate_latent_infs(renewal_model, log_Rt)
    suite["Renewal"] = make_epiaware_suite(mdl)
end

# Error:  ArgumentError: Converting an instance of ReverseDiff.TrackedReal{Float64, Float64, Nothing} to Float64 is not defined. Please use `ReverseDiff.value` instead.
let
    using Distributions
    gen_int = [0.2, 0.3, 0.5]
    transformation = exp
    pop_size = 1000.0

    data = EpiData(gen_int, transformation)
    log_init_incidence_prior = Normal()

    renewal_model = RenewalWithPopulation(data, log_init_incidence_prior, pop_size)

    Rt = [1.0, 1.2, 1.5, 1.5, 1.5]
    log_Rt = log.(Rt)
    mdl = generate_latent_infs(renewal_model, log_Rt)
    suite["RenewalWithPopulation"] = make_epiaware_suite(mdl)
end

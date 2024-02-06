@model function log_infections(
    y_t,
    ::Type{T} = Float64;
    epimodel::EpiModel,
    latent_process,
    transform_function = exp,
    pos_shift = 1e-6,
    α = missing,
) where {T}

    I_t = Vector{T}(undef, gen_length)
    mean_case_preds = Vector{T}(undef, gen_length)
    data_length = length(y_t)

    α ~ Gamma(3, 0.05/3)

    #Latent process
    @submodel _I_t, latent_process_parameters = latent_process()

    #Transform into infections
    I_t = transform_function.(_I_t)

    #Predictive distribution
    mean_case_preds .= epimodel.delay_kernel * I_t
    case_pred_dists = mean_case_preds .+ pos_shift .|> μ -> mean_cc_neg_bin(μ, α)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    #Generate quantities
    return (; I_t, latent_process_parameters)
end

@model function exp_growth_rate(
    y_t,
    ::Type{T} = Float64;
    epimodel::EpiModel,
    latent_process,
    transform_function = exp,
    pos_shift = 1e-6,
    α = missing,
    I_0 = missing,
) where {T}

    I_t = Vector{T}(undef, gen_length)
    mean_case_preds = Vector{T}(undef, gen_length)
    data_length = length(y_t)

    α ~ Gamma(3, 0.05/3)
    _I_0 ~ Normal(0., 1.0)

    #Latent process
    @submodel rt, latent_process_parameters = latent_process()

    #Transform into infections
    I_t = transform_function.(_I_0 .+ cumsum(rt))

    #Predictive distribution
    mean_case_preds .= epimodel.delay_kernel * I_t
    case_pred_dists = mean_case_preds .+ pos_shift .|> μ -> mean_cc_neg_bin(μ, α)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    #Generate quantities
    return (; I_t, latent_process_parameters)
end

@model function renewal(
    y_t,
    ::Type{T} = Float64;
    epimodel::EpiModel,
    latent_process,
    transform_function = exp,
    pos_shift = 1e-6,
    α = missing,
    I_0 = missing,
) where {T}

    I_t = Vector{T}(undef, gen_length)
    mean_case_preds = Vector{T}(undef, gen_length)
    data_length = length(y_t)

    α ~ Gamma(3, 0.05/3)
    _I_0 ~ MvNormal(ones(epimodel.len_gen_int)) #<-- need longer initial for renewal
    
    #Latent process
    @submodel Rt, latent_process_parameters = latent_process()

    #Transform into infections
    I_t, _ = scan(epimodel, transform_function.(_I_0), Rt)

    #Predictive distribution
    mean_case_preds .= epimodel.delay_kernel * I_t
    case_pred_dists = mean_case_preds .+ pos_shift .|> μ -> mean_cc_neg_bin(μ, α)

    #Likelihood
    y_t ~ arraydist(case_pred_dists)

    #Generate quantities
    return (; I_t, latent_process_parameters)
end
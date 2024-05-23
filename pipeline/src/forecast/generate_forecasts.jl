"""
Generate forecasts for `n` time steps above based on the given inference results.

# Arguments
- `inference_results`: The results of the inference process.
- `n`: The number of forecasts to generate.

# Returns
- `forecast_quantities`: The generated forecast quantities.

"""
function generate_forecasts(inference_results, n::Integer)
    chn = inference_results["inference_results"].samples |> resetrange
    data = inference_results["inference_results"].data
    epiprob = inference_results["epiprob"]
    forecast_epiprob = define_forecast_epiprob(epiprob, n)

    # get length of baseline model latent process
    n_lat = generate_epiaware(epiprob, (y_t = missing,)) |> rand |>
            θ -> length(getfield(θ, Symbol("latent.ϵ_t")))
    # get length of forecast model latent process
    n_lat_forecast = generate_epiaware(forecast_epiprob, (y_t = missing,)) |> rand |>
                     θ -> length(getfield(θ, Symbol("latent.ϵ_t")))
    # Add forward generation of white noise to forecast model chain
    fwd_chn_names = [Symbol("latent.ϵ_t[$(i)]") for i in (n_lat + 1):n_lat_forecast]
    fwd_chn = Chains(
        randn(size(chn, 1), n_lat_forecast - n_lat, size(chn, 3)), fwd_chn_names)
    pred_chn = hcat(chn, fwd_chn)

    forecast_quantities = forecast_epiprob |>
                          forecast_epiprob -> generate_epiaware(
        forecast_epiprob, (y_t = missing,)) |>
                                              forecast_mdl -> generated_observables(
        forecast_mdl, data, pred_chn)
    return forecast_quantities
end

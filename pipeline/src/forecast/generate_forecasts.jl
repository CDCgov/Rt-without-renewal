"""
Generate forecasts for `n` time steps above based on the given inference results.

# Arguments
- `inference_results`: The results of the inference process.
- `n`: The number of forecasts to generate.

# Returns
- `forecast_quantities`: The generated forecast quantities.

"""
function generate_forecasts(inference_results, n::Integer)
    inference_chn = inference_results["inference_results"].samples |> resetrange
    data = inference_results["inference_results"].data
    epiprob = inference_results["epiprob"]
    forecast_epiprob = define_forecast_epiprob(epiprob, n)
    forecast_mdl = generate_epiaware(forecast_epiprob, (y_t = missing,))

    # Add forward generation of latent variables using `predict`
    fwd_chn = predict(forecast_mdl, inference_chn)
    pred_chn = hcat(inference_chn, fwd_chn)

    forecast_quantities = generated_observables(forecast_mdl, data, pred_chn)
    return forecast_quantities
end

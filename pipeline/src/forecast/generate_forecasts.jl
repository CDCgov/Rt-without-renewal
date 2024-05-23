"""
Generate forecasts for `n` time steps above based on the given inference results.

# Arguments
- `inference_results`: The results of the inference process.
- `n`: The number of forecasts to generate.

# Returns
- `forecast_quantities`: The generated forecast quantities.

"""
function generate_forecasts(inference_results, n::Integer)
    chn = inference_results["inference_results"].samples
    data = inference_results["inference_results"].data
    forecast_epiprob = define_forecast_epiprob(inference_results["epiprob"], n)
    forecast_quantities = forecast_epiprob |>
                          epiprob -> generate_epiaware(epiprob, (y_t = missing,)) |>
                                     forecast_mdl -> generated_observables(
        forecast_mdl, data, chn)
    return forecast_quantities
end

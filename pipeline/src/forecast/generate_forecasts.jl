"""
Generate forecasts for `lookahead` time steps ahead based on the results of the
inference process.

# Arguments
- `inference_chn`: The posterior chains of the inference process.
- `data`: The data used in the inference process.
- `epiprob`: The EpiProblem object used in the inference process.
- `lookahead`: The number of time steps to forecast ahead.
"""
function generate_forecasts(inference_chn, data, epiprob, lookahead::Integer)
    forecast_epiprob = define_forecast_epiprob(epiprob, lookahead)
    forecast_mdl = generate_epiaware(forecast_epiprob, (y_t = missing,))

    # Add forward generation of latent variables using `predict`
    pred_chn = mapreduce(chainscat, 1:size(inference_chn, 3)) do c
        mapreduce(vcat, 1:size(inference_chn, 1)) do i
            fwd_chn = predict(forecast_mdl, inference_chn[i, :, c]; include_all = true)
            setrange(fwd_chn, i:i)
        end
    end

    forecast_quantities = generated_observables(forecast_mdl, data, pred_chn)
    return forecast_quantities
end

"""
Generate forecasts for `lookahead` time steps ahead based on the given inference results
in dictionary form.

# Arguments
- `inference_results_dict`: A dictionary of results of the inference process.
- `lookahead`: The number of time steps to forecast ahead.

# Returns
- `forecast_quantities`: The generated forecast quantities.

"""
function generate_forecasts(inference_results_dict::Dict, lookahead::Integer)
    @assert haskey(inference_results_dict, "inference_results") "Results dictionary must contain `inference_results` key"
    inference_chn = inference_results["inference_results"].samples
    data = inference_results["inference_results"].data
    epiprob = inference_results["epiprob"]
    return generate_forecasts(inference_chn, data, epiprob, lookahead)
end

"""
Internal function for making a DataFrame for a given parameter using the
    provided MCMC samples and the truth value.
"""
function _make_prediction_dataframe(param_name, samples, truth; model = "EpiAware")
    x = samples[Symbol(param_name)][:]
    DataFrame(predicted = x, observed = truth, model = model,
        parameter = param_name, sample_id = 1:length(x))
end

"""
Internal function for scoring a DataFrame containing a prediction and truth value
    for a parameter using the `scoringutils` package.
"""
function _score(df)
    @rput df
    R"""
    library(scoringutils)
    result = df |> as_forecast() |> score()
    """
    @rget result
    return result
end

"""
This method for `score_parameters` calculates standard scores provided by [`scoringutils`](https://epiforecasts.io/scoringutils/dev/)
for a set of parameters using the provided MCMC samples and the truth value.
The function returns a DataFrame containing a summary of the scores.

## Arguments
- `param_names`: Names of the parameter to score.
- `samples`: A `MCMCChains.Chains` object of samples.
- `truths`: Truth values for each parameter.
- `model`: (optional) The name of the model. Default is "EpiAware".

## Returns
- `result`: A DataFrame containing the summarized scores for the parameter.

"""
function EpiAwarePipeline.score_parameters(param_names, samples, truths; model = "EpiAware")
    df = mapreduce(vcat, param_names, truths) do param_name, truth
        _make_prediction_dataframe(param_name, samples, truth; model = model)
    end
    return _score(df)
end

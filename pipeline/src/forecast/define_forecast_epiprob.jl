"""
Create a forecast EpiProblem by extending the given EpiProblem with additional
forecast steps.

# Arguments
- `epiprob::EpiProblem`: The original EpiProblem to be extended.
- `n::Integer`: The number of forecast steps to be added.

# Returns
- `forecast_epiprob::EpiProblem`: The forecast EpiProblem with extended time
span.

"""
function define_forecast_epiprob(epiprob::EpiProblem, n::Integer)
    @assert n>0 "number of forecast steps n must be positive"

    forecast_epiprob = EpiProblem(
        epi_model = epiprob.epi_model,
        latent_model = epiprob.latent_model,
        observation_model = epiprob.observation_model,
        tspan = (epiprob.tspan[1], epiprob.tspan[2] + n)
    )

    return forecast_epiprob
end

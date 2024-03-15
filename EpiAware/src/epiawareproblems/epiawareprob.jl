"""
Defines an inference/generative modelling problem for case data.

`EpiAwareProblem` wraps the underlying components of an epidemiological model:
- `epi_model`: An epidemiological model for unobserved infections.
- `latent_model`: A latent model for underlying latent process.
- `observation_model`: An observation model for observed cases.

Along with a `tspan` tuple for the time span of the case data.
"""
@kwdef struct EpiAwareProblem{
    E <: AbstractEpiModel, L <: AbstractLatentModel, O <: AbstractObservationModel} <:
              AbstractEpiAwareProblem
    "Epidemiological model for unobserved infections."
    epi_model::E
    "Latent model for underlying latent process."
    latent_model::L
    "Observation model for observed cases."
    observation_model::O
    "Time span for either inference or generative modelling of case time series."
    tspan::Tuple{Int, Int}
end

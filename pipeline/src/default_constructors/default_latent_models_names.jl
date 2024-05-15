"""
Returns a dictionary mapping the default latent models to their corresponding
    names.

# Returns
- `Dict{Any, Any}`: A dictionary mapping the default latent models to their
    corresponding names.
"""
function default_latent_models_names()
    latent_models_dict = default_epiaware_models()
    return Dict(value => key for (key, value) in latent_models_dict)
end

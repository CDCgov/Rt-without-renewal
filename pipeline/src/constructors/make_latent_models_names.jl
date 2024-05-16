"""
Constructs the names of the latent models used in the given pipeline.

# Arguments
- `pipeline`: An instance of `AbstractEpiAwarePipeline` representing the pipeline.

# Returns
- An array of strings representing the names of the latent models.

"""
function make_latent_models_names(pipeline::AbstractEpiAwarePipeline)
    default_latent_models_names()
end

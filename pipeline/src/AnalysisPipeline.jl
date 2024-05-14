"""
This module contains the analysis pipeline for the `Rt-without-renewal` project.
"""
module AnalysisPipeline

using Dates: default
using CSV, Dagger, DataFramesMeta, Dates, Distributions, DocStringExtensions, DrWatson,
      EpiAware, Plots, Statistics, ADTypes, AbstractMCMC, Plots, JLD2

# Exported struct types
export TruthSimulationConfig, InferenceConfig

# Exported functions
export simulate, infer, default_gi_params, default_Rt, default_tspan,
       default_latent_model_priors, default_epiaware_models, default_inference_method,
       default_latent_models_names, make_truth_data_configs, make_inference_configs,
       generate_truthdata_from_config, generate_inference_results, plot_truth_data, plot_Rt

include("docstrings.jl")
include("default_gi_params.jl")
include("default_Rt.jl")
include("default_tspan.jl")
include("default_latent_model_priors.jl")
include("default_epiaware_models.jl")
include("default_inference_method.jl")
include("make_truth_data_configs.jl")
include("make_inference_configs.jl")
include("default_latent_models_names.jl")
include("TruthSimulationConfig.jl")
include("InferenceConfig.jl")
include("generate_truthdata.jl")
include("generate_inference_results.jl")
include("plot_functions.jl")
end

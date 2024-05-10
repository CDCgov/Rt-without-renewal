"""
This module contains the analysis pipeline for the `Rt-without-renewal` project.
"""
module AnalysisPipeline

using Dates: default
using CSV, Dagger, DataFramesMeta, Dates, Distributions, DocStringExtensions, DrWatson,
      EpiAware, Plots, Statistics, ADTypes, AbstractMCMC

# Exported struct types
export TruthSimulationConfig, InferenceConfig

# Exported functions
export simulate_or_infer, default_gi_params, default_Rt, default_tspan, default_priors,
       default_epiaware_models, default_inference_method, make_truth_data_configs

include("docstrings.jl")
include("default_gi_params.jl")
include("default_Rt.jl")
include("default_tspan.jl")
include("default_priors.jl")
include("default_epiaware_models.jl")
include("default_inference_method.jl")
include("make_truth_data_configs.jl")
include("TruthSimulationConfig.jl")
include("InferenceConfig.jl")

end

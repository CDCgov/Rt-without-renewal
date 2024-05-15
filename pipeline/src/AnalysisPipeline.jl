"""
This module contains the analysis pipeline for the `Rt-without-renewal` project.

# Pipeline Components

In this module the meaning of a _pipeline component_ is a directed-acylic-graph
(DAG) of tasks defined using `Dagger.jl` via dispatch on an `AbstractEpiAwarePipeline`
sub-type from a function with prefix `make_`. A full pipeline is a sequence of DAGs,
with execution determined by available computational resources.
"""
module AnalysisPipeline

using Dates: default
using CSV, Dagger, DataFramesMeta, Dates, Distributions, DocStringExtensions, DrWatson,
      EpiAware, Plots, Statistics, ADTypes, AbstractMCMC, Plots, JLD2

# Exported struct types
export AbstractEpiAwarePipeline, EpiAwarePipeline, RtwithoutRenewalPipeline,
       TruthSimulationConfig, InferenceConfig

# Exported functions
export simulate, infer, default_gi_params, default_Rt, default_tspan,
       default_latent_model_priors, default_epiaware_models, default_inference_method,
       default_latent_models_names, default_truthdata_configs, make_truth_data_configs,
       make_inference_configs,
       generate_truthdata_from_config, generate_inference_results, plot_truth_data, plot_Rt

include("docstrings.jl")
include("pipelinetypes.jl")
include("default_constructors/default_gi_params.jl")
include("default_constructors/default_Rt.jl")
include("default_constructors/default_tspan.jl")
include("default_constructors/default_latent_model_priors.jl")
include("default_constructors/default_epiaware_models.jl")
include("default_constructors/default_inference_method.jl")
include("default_constructors/default_truthdata_configs.jl")
include("make_truth_data_configs.jl")
include("make_inference_configs.jl")
include("default_constructors/default_latent_models_names.jl")
include("TruthSimulationConfig.jl")
include("InferenceConfig.jl")
include("generate_truthdata.jl")
include("generate_inference_results.jl")
include("plot_functions.jl")
end

"""
This module contains the analysis pipeline for the `Rt-without-renewal` project.

# Pipeline Components

In this module the meaning of a _pipeline component_ is a directed-acylic-graph
(DAG) of tasks defined using `Dagger.jl` via dispatch on an `AbstractEpiAwarePipeline`
sub-type from a function with prefix `do_`. A full pipeline is a sequence of DAGs,
with execution determined by available computational resources.
"""
module AnalysisPipeline

using CSV, Dagger, DataFramesMeta, Dates, Distributions, DocStringExtensions, DrWatson,
      EpiAware, Plots, Statistics, ADTypes, AbstractMCMC, Plots, JLD2

# Exported struct types
export AbstractEpiAwarePipeline, EpiAwarePipeline, RtwithoutRenewalPipeline,
       TruthSimulationConfig, InferenceConfig

# Exported functions: default constructors
export default_gi_params, default_Rt, default_tspan,
       default_latent_model_priors, default_epiaware_models, default_inference_method,
       default_latent_models_names, default_truthdata_configs, default_inference_configs

# Exported functions: constructors
export make_truth_data_configs, make_inference_configs, make_tspan, make_inference_method,
       make_latent_models_names

# Exported functions: pipeline components
export do_truthdata, do_inference, do_pipeline

# Exported functions: simulate functions
export simulate, generate_truthdata

# Exported functions: infer functions
export infer, generate_inference_results, plot_truth_data, plot_Rt

include("docstrings.jl")
include("pipeline/pipeline.jl")
include("constructors/constructors.jl")
include("simulate/simulate.jl")
include("infer/infer.jl")
include("plot_functions.jl")
end

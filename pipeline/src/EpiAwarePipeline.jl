"""
This module contains the analysis pipeline for the `Rt-without-renewal` project.

# Pipeline Components

In this module the meaning of a _pipeline component_ is a directed-acylic-graph
(DAG) of tasks defined using `Dagger.jl` via dispatch on an `AbstractEpiAwarePipeline`
sub-type from a function with prefix `do_`. A full pipeline is a sequence of DAGs,
with execution determined by available computational resources.
"""
module EpiAwarePipeline

using CSV, Dagger, DataFramesMeta, Dates, Distributions, DocStringExtensions, DrWatson,
      EpiAware, Plots, Statistics, ADTypes, AbstractMCMC, Plots, JLD2, MCMCChains, Turing,
      DynamicPPL, LogExpFunctions, RCall, LinearAlgebra, Random

# Exported pipeline types
export AbstractEpiAwarePipeline, EpiAwarePipeline, AbstractRtwithoutRenewalPipeline,
       RtwithoutRenewalPriorPipeline, EpiAwareExamplePipeline, SmoothOutbreakPipeline,
       MeasuresOutbreakPipeline, SmoothEndemicPipeline, RoughEndemicPipeline

# Exported utility functions
export calculate_processes

# Exported configuration types
export TruthSimulationConfig, InferenceConfig

# Exported functions: constructors
export make_gi_params, make_inf_generating_processes, make_model_priors,
       make_epiaware_name_latentmodel_pairs, make_Rt, make_truth_data_configs,
       make_default_params, make_inference_configs, make_tspan, make_inference_method,
       make_delay_distribution, make_delay_distribution, make_observation_model

# Exported functions: pipeline components
export do_truthdata, do_inference, do_pipeline

# Exported functions: simulate functions
export simulate, generate_truthdata

# Exported functions: infer functions
export infer, generate_inference_results, map_inference_results, define_epiprob

# Exported functions: forecast functions
export define_forecast_epiprob, generate_forecasts

# Exported functions: scoring functions
export score_parameters

# Exported functions: main plot functions and utilities
export generate_quantiles_for_targets, timeseries_samples_into_quantiles,
       make_truth_data_dict

# Exported functions: plot functions
export plot_truth_data, plot_Rt

include("docstrings.jl")
include("pipeline/pipeline.jl")
include("utils/utils.jl")
include("constructors/constructors.jl")
include("simulate/simulate.jl")
include("infer/infer.jl")
include("forecast/forecast.jl")
include("scoring/score_parameters.jl")
include("mainplots/mainplots.jl")
include("plot_functions.jl")
end

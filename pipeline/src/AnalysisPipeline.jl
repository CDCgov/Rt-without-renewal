"""
This module contains the analysis pipeline for the `Rt-without-renewal` project.
"""
module AnalysisPipeline

using CSV, Dagger, DataFramesMeta, Dates, Distributions, DocStringExtensions, DrWatson,
      EpiAware, Plots, Statistics

export TruthSimulationConfig
export simulate_or_infer, savename

include("docstrings.jl")
include("TruthSimulationConfig.jl")

end

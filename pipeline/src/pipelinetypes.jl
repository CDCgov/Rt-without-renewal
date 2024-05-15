"""
The abstract root type for all pipeline types using `EpiAware`.
"""
abstract type AbstractEpiAwarePipeline end

"""
Dispatches on this type give generic behavior for all pipelines at a default
    setting.
"""
struct EpiAwarePipeline <: AbstractEpiAwarePipeline
end

"""
The pipeline type for the Rt pipeline with renewal including specific options
    for plotting and saving.
"""
struct RtwithoutRenewalPipeline <: AbstractEpiAwarePipeline
end

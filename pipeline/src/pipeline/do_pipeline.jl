"""
Create a pipeline by generating truth data and making inferences.

# Arguments
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline behavior and scenario.

"""
function do_pipeline(pipeline::AbstractEpiAwarePipeline)
    truthdatas = do_truthdata(pipeline)
    for truthdata in truthdatas
        do_inference(truthdata, pipeline)
    end
    return nothing
end

"""
Perform the pipeline for each `AbstractEpiAwarePipeline` in the given vector `pipelines`.

# Arguments
- `pipelines`: A vector of `AbstractEpiAwarePipeline` objects.

"""
function do_pipeline(pipelines::Vector{<:AbstractEpiAwarePipeline})
    map(pipelines) do pipeline
        Dagger.@spawn do_pipeline(pipeline)
    end
    return nothing
end

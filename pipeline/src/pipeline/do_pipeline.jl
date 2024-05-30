"""
Create a pipeline by generating truth data and making inferences.

# Arguments
- `pipeline::AbstractEpiAwarePipeline`: The pipeline object which sets pipeline behavior.

"""
function do_pipeline(pipeline::AbstractEpiAwarePipeline)
    truthdatas = do_truthdata(pipeline)
    for truthdata in truthdatas
        do_inference(truthdata, pipeline)
    end
    return nothing
end

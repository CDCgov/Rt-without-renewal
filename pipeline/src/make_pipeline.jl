"""
Create a pipeline by generating truth data and making inferences.

# Arguments
- `pipeline::EpiAwarePipeline`: The pipeline object which sets pipeline behavior.

"""
function make_pipeline(pipeline::EpiAwarePipeline)
    truthdatas = make_truthdata(pipeline)
    for truthdata in truthdatas
        make_inference(truthdata, pipeline)
    end
    return nothing
end

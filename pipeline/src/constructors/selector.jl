"""
Internal method for selecting from a list of items based on the pipeline type.
Default is to return the list as is.
"""
function _selector(list, pipeline::AbstractEpiAwarePipeline)
    return list
end

"""
Internal method for selecting from a list of items based on the pipeline type.
Example/test mode filters to a subset of the inference configs.
"""
function _selector(list, pipeline::EpiAwareExamplePipeline)
    if haskey(list[1], "T")
        _list = list |>
                l -> filter(x -> x["T"] == pipeline.T, l) |>
                     l -> filter(x -> x["gi_mean"] == pipeline.gi_mean, l)
        return _list
    else
        _list = list |>
                l -> filter(x -> x["gi_mean"] == pipeline.gi_mean, l)
        return _list
    end
end

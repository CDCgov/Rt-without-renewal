"""
Internal method for selecting from a list of items based on the pipeline type.
Default is to return the list as is.
"""
function _selector(list, pipeline::AbstractEpiAwarePipeline)
    return list
end

"""
Internal method for selecting from a list of items based on the pipeline type.
Example/test mode is to return a randomly selected item from the list.
"""
function _selector(list, pipeline::EpiAwareExamplePipeline)
    return [rand(list)]
end

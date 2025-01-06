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

"""
Internal method for selecting from a list of items based on the pipeline type.
Example/test mode is to return a randomly selected item from the list. Prior predictive mode
only runs on configurations with the furthest ahead horizon.
"""
function _selector(list, pipeline::AbstractRtwithoutRenewalPipeline)
    if pipeline.priorpredictive
        maxT = maximum([config["T"] for config in list])
        _list = filter(config -> config["T"] == maxT, list)
        return pipeline.testmode ? [rand(_list)] : _list
    else
        return pipeline.testmode ? [rand(list)] : list
    end
end

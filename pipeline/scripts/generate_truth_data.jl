using DrWatson
@quickactivate "Analysis pipeline"

# include AnlysisPipeline module
include(srcdir("AnalysisPipeline.jl"))

@info(
    """
    Generating truth data for the `Rt-without-renewal` project.

    ---------------------------------------------
    Currently active project is: $(projectname())
    Path of active project: $(projectdir())
    """
)

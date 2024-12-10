"""
   A custom wrapper for the `TuringBenchmarking.make_turing_suite` that adds EpiAware specific defaults.
"""
function make_epiaware_suite(model; check = true,
        adbackends = [
            :forwarddiff, :reversediff, :reversediff_compiled,
            ADTypes.AutoMooncake(config = nothing),
            ADTypes.AutoEnzyme()
        ])
    suite = prefix_warnings(
        () -> TuringBenchmarking.make_turing_suite(
            model; check = check, adbackends = adbackends),
        model
    )
    return suite
end

function prefix_warnings(f, g)
    original_stderr = stderr
    (read_pipe, write_pipe) = redirect_stderr()
    result = nothing
    try
        result = f()
    finally
        redirect_stderr(original_stderr)
        close(write_pipe)
        output = String(read(read_pipe))
        if !isempty(output)
            println(stderr, "\nWarnings from $(g):")
            println(stderr, output)
        end
    end
    return result
end

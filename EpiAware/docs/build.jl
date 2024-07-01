
"""Run all Pluto notebooks (".jl" files) in `tutorials_dir` and write outputs to HTML files."""
function build(target_subdir)
    target_dir = joinpath(@__DIR__, "docs", "src", target_subdir)

    @info "Building notebooks in $target_dir"
    # Evaluate notebooks in the same process to avoid having to recompile from scratch each time.
    # This is similar to how Documenter and Franklin evaluate code.
    # Note that things like method overrides and other global changes may leak between notebooks!
    use_distributed = false
    output_format = documenter_output
    bopts = BuildOptions(target_dir; use_distributed, output_format)
    build_notebooks(bopts)
    return nothing
end

"Return Markdown file links which can be passed to Documenter.jl."
function markdown_files(notebook_titles, target_subdir)
    md_files = map(notebook_titles) do title
        file = lowercase(replace(title, " " => '_'))
        return joinpath(target_subdir, "$file.md")
    end
    return md_files
end

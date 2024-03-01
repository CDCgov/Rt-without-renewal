var documenterSearchIndex = {"docs":
[{"location":"checklist/#Checklists","page":"Release checklist","title":"Checklists","text":"","category":"section"},{"location":"checklist/","page":"Release checklist","title":"Release checklist","text":"The purpose of this page is to collate a series of checklists for commonly performed changes to the source code of EpiAware. It has been adapted from Documenter.jl.","category":"page"},{"location":"checklist/","page":"Release checklist","title":"Release checklist","text":"In each case, copy the checklist into the description of the pull request.","category":"page"},{"location":"checklist/#Making-a-release","page":"Release checklist","title":"Making a release","text":"","category":"section"},{"location":"checklist/","page":"Release checklist","title":"Release checklist","text":"In preparation for a release, use the following checklist. These steps should be performed on a branch with an open pull request, either for a topic branch, or for a new branch release-1.y.z (\"Release version 1.y.z\") if multiple changes have accumulated on the master branch since the last release.","category":"page"},{"location":"checklist/","page":"Release checklist","title":"Release checklist","text":"## Pre-release\n\n - [ ] Change the version number in `Project.toml`\n   * If the release is breaking, increment MAJOR\n   * If the release adds a new user-visible feature, increment MINOR\n   * Otherwise (bug-fixes, documentation improvements), increment PATCH\n - [ ] Update `CHANGELOG.md`, following the existing style (in particular, make sure that the change log for this version has the correct version number and date).\n - [ ] Run `make changelog`, to make sure that all the issue references in `CHANGELOG.md` are up to date.\n - [ ] Check that the commit messages in this PR do not contain `[ci skip]`\n - [ ] Run https://github.com/JuliaDocs/Documenter.jl/actions/workflows/regression-tests.yml\n       using a `workflow_dispatch` trigger to check for any changes that broke extensions.\n\n## The release\n\n - [ ] After merging the pull request, tag the release. There are two options for this:\n\n   1. [Comment `[at]JuliaRegistrator register` on the GitHub commit.](https://github.com/JuliaRegistries/Registrator.jl#via-the-github-app)\n   2. Use [JuliaHub's package registration feature](https://help.juliahub.com/juliahub/stable/contribute/#registrator) to trigger the registration.\n\n   Either of those should automatically publish a new version to the Julia registry.\n - Once registered, the `TagBot.yml` workflow should create a tag, and rebuild the documentation for this tag.\n - These steps can take quite a bit of time (1 hour or more), so don't be surprised if the new documentation takes a while to appear.","category":"page"},{"location":"release-notes/","page":"Release notes","title":"Release notes","text":"EditURL = \"https://github.com/JuliaDocs/Documenter.jl/blob/master/CHANGELOG.md\"","category":"page"},{"location":"release-notes/#Release-notes","page":"Release notes","title":"Release notes","text":"","category":"section"},{"location":"release-notes/","page":"Release notes","title":"Release notes","text":"The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.","category":"page"},{"location":"release-notes/#Unreleased","page":"Release notes","title":"Unreleased","text":"","category":"section"},{"location":"release-notes/#Added","page":"Release notes","title":"Added","text":"","category":"section"},{"location":"release-notes/#Changed","page":"Release notes","title":"Changed","text":"","category":"section"},{"location":"release-notes/#Fixed","page":"Release notes","title":"Fixed","text":"","category":"section"},{"location":"lib/internals/#internal-Documentation","page":"Internals","title":"internal Documentation","text":"","category":"section"},{"location":"lib/internals/","page":"Internals","title":"Internals","text":"Documentation for EpiAware.jl's internal interface.","category":"page"},{"location":"lib/internals/#Contents","page":"Internals","title":"Contents","text":"","category":"section"},{"location":"lib/internals/","page":"Internals","title":"Internals","text":"Pages = [\"internal.md\"]\nDepth = 2:2","category":"page"},{"location":"lib/internals/#Index","page":"Internals","title":"Index","text":"","category":"section"},{"location":"lib/internals/","page":"Internals","title":"Internals","text":"Pages = [\"internals.md\"]","category":"page"},{"location":"lib/internals/#Internal-API","page":"Internals","title":"Internal API","text":"","category":"section"},{"location":"lib/internals/","page":"Internals","title":"Internals","text":"Modules = [EpiAware]\nPublic = false","category":"page"},{"location":"lib/internals/#EpiAware.R_to_r-Union{Tuple{T}, Tuple{Any, Vector{T}}} where T<:AbstractFloat","page":"Internals","title":"EpiAware.R_to_r","text":"R_to_r(R₀, w::Vector{T}; newton_steps = 2, Δd = 1.0)\n\nThis function computes an approximation to the exponential growth rate r given the reproductive ratio R₀ and the discretized generation interval w with discretized interval width Δd. This is based on the implicit solution of\n\nG(r) - 1 over R_0 = 0\n\nwhere\n\nG(r) = sum_i=1^n w_i e^-r i\n\nis the negative moment generating function (MGF) of the generation interval distribution.\n\nThe two step approximation is based on:     1. Direct solution of implicit equation for a small r approximation.     2. Improving the approximation using Newton's method for a fixed number of steps newton_steps.\n\nReturns:\n\nThe approximate value of r.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#EpiAware.generate_latent_infs-Tuple{Renewal, Any}","page":"Internals","title":"EpiAware.generate_latent_infs","text":"generate_latent_infs(epi_model::Renewal, _Rt)\n\nTuring model constructor for latent infections using the Renewal object epi_model and time-varying unconstrained reproduction number _Rt.\n\ngenerate_latent_infs creates a Turing model for sampling latent infections with given unconstrainted reproduction number _Rt but random initial incidence scale. The initial incidence pre-time one is given as a scale on top of an exponential growing process with exponential growth rate given by R_to_rapplied to the first value of Rt.\n\nArguments\n\nepi_model::Renewal: The epidemiological model.\n_Rt: Time-varying unconstrained (e.g. log-) reproduction number.\n\nReturns\n\nI_t: Array of latent infections over time.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#EpiAware.generate_observation_kernel-Tuple{Any, Any}","page":"Internals","title":"EpiAware.generate_observation_kernel","text":"generate_observation_kernel(delay_int, time_horizon)\n\nGenerate an observation kernel matrix based on the given delay interval and time horizon.\n\nArguments\n\ndelay_int::Vector{Float64}: The delay PMF vector.\ntime_horizon::Int: The number of time steps of the observation period.\n\nReturns\n\nK::SparseMatrixCSC{Float64, Int}: The observation kernel matrix.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#EpiAware.mean_cc_neg_bin-Tuple{Any, Any}","page":"Internals","title":"EpiAware.mean_cc_neg_bin","text":"mean_cc_neg_bin(μ, α)\n\nCompute the mean-cluster factor negative binomial distribution.\n\nArguments\n\nμ: The mean of the distribution.\nα: The clustering factor parameter.\n\nReturns\n\nA NegativeBinomial distribution object.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#EpiAware.neg_MGF-Tuple{Any, AbstractVector}","page":"Internals","title":"EpiAware.neg_MGF","text":"neg_MGF(r, w::AbstractVector)\n\nCompute the negative moment generating function (MGF) for a given rate r and weights w.\n\nArguments\n\nr: The rate parameter.\nw: An abstract vector of weights.\n\nReturns\n\nThe value of the negative MGF.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#EpiAware.r_to_R-Tuple{Any, AbstractVector}","page":"Internals","title":"EpiAware.r_to_R","text":"r_to_R(r, w)\n\nCompute the reproductive ratio given exponential growth rate r     and discretized generation interval w.\n\nArguments\n\nr: The exponential growth rate.\nw: discretized generation interval.\n\nReturns\n\nThe reproductive ratio.\n\n\n\n\n\n","category":"method"},{"location":"contributing/#Contributing","page":"Contributing","title":"Contributing","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"This page details the some of the guidelines that should be followed when contributing to this package. It is adapted from Documenter.jl.","category":"page"},{"location":"contributing/#Branches","page":"Contributing","title":"Branches","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"release-* branches are used for tagged minor versions of this package. This follows the same approach used in the main Julia repository, albeit on a much more modest scale.","category":"page"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"Please open pull requests against the master branch rather than any of the release-* branches whenever possible.","category":"page"},{"location":"contributing/#Backports","page":"Contributing","title":"Backports","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"Bug fixes are backported to the release-* branches using git cherry-pick -x by a EpiAware member and will become available in point releases of that particular minor version of the package.","category":"page"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"Feel free to nominate commits that should be backported by opening an issue. Requests for new point releases to be tagged in METADATA.jl can also be made in the same way.","category":"page"},{"location":"contributing/#release-*-branches","page":"Contributing","title":"release-* branches","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"Each new minor version x.y.0 gets a branch called release-x.y (a protected branch).\nNew versions are usually tagged only from the release-x.y branches.\nFor patch releases, changes get backported to the release-x.y branch via a single PR with the standard name \"Backports for x.y.z\" and label \"Type: Backport\". The PR message links to all the PRs that are providing commits to the backport. The PR gets merged as a merge commit (i.e. not squashed).\nThe old release-* branches may be removed once they have outlived their usefulness.\nPatch version milestones are used to keep track of which PRs get backported etc.","category":"page"},{"location":"contributing/#Style-Guide","page":"Contributing","title":"Style Guide","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"Follow the style of the surrounding text when making changes. When adding new features please try to stick to the following points whenever applicable. This project follows the SciML style guide.","category":"page"},{"location":"contributing/#Tests","page":"Contributing","title":"Tests","text":"","category":"section"},{"location":"contributing/#Unit-tests","page":"Contributing","title":"Unit tests","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"As is conventional for Julia packages, unit tests are located at test/*.jl with the entrypoint test/runtests.jl.","category":"page"},{"location":"contributing/#End-to-end-testing","page":"Contributing","title":"End to end testing","text":"","category":"section"},{"location":"contributing/","page":"Contributing","title":"Contributing","text":"Tests that build example package docs from source and inspect the results (end to end tests) are located in /test/examples. The main entry points are test/examples/make.jl for building and test/examples/test.jl for doing some basic checks on the generated outputs.","category":"page"},{"location":"lib/public/#Public-Documentation","page":"Public API","title":"Public Documentation","text":"","category":"section"},{"location":"lib/public/","page":"Public API","title":"Public API","text":"Documentation for EpiAware.jl's public interface.","category":"page"},{"location":"lib/public/","page":"Public API","title":"Public API","text":"See the Internals section of the manual for internal package docs covering all submodules.","category":"page"},{"location":"lib/public/#Contents","page":"Public API","title":"Contents","text":"","category":"section"},{"location":"lib/public/","page":"Public API","title":"Public API","text":"Pages = [\"public.md\"]\nDepth = 2:2","category":"page"},{"location":"lib/public/#Index","page":"Public API","title":"Index","text":"","category":"section"},{"location":"lib/public/","page":"Public API","title":"Public API","text":"Pages = [\"public.md\"]","category":"page"},{"location":"lib/public/#Public-API","page":"Public API","title":"Public API","text":"","category":"section"},{"location":"#EpiAware.jl","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl","text":"","category":"section"},{"location":"","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl: Real-time epidemic monitoring","text":"Infectious disease situational awareness modelling toolkit for Julia.","category":"page"},{"location":"","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl: Real-time epidemic monitoring","text":"A package for building and fitting situational awareness models for infectious diseases. The package is designed to be flexible and extensible, and to provide a consistent interface for fitting and simulating models.","category":"page"},{"location":"#Package-Features","page":"EpiAware.jl: Real-time epidemic monitoring","title":"Package Features","text":"","category":"section"},{"location":"","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl: Real-time epidemic monitoring","text":"Flexible: The package is designed to be flexible and extensible, and to provide a consistent interface for fitting and simulating models.\nModular: The package is designed to be modular, with a clear separation between the model and the data.\nExtensible: The package is designed to be extensible, with a clear separation between the model and the data.\nConsistent: The package is designed to provide a consistent interface for fitting and simulating models.\nEfficient: The package is designed to be efficient, with a clear separation between the model and the data.","category":"page"},{"location":"","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl: Real-time epidemic monitoring","text":"See the Index for the complete list of documented functions and types.","category":"page"},{"location":"#Manual-Outline","page":"EpiAware.jl: Real-time epidemic monitoring","title":"Manual Outline","text":"","category":"section"},{"location":"","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl: Real-time epidemic monitoring","text":"Pages = [\n    \"man/contributing.md\",\n]\nDepth = 1","category":"page"},{"location":"#Library-Outline","page":"EpiAware.jl: Real-time epidemic monitoring","title":"Library Outline","text":"","category":"section"},{"location":"","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl: Real-time epidemic monitoring","text":"Pages = [\"lib/public.md\", \"lib/internals.md\"]","category":"page"},{"location":"#main-index","page":"EpiAware.jl: Real-time epidemic monitoring","title":"Index","text":"","category":"section"},{"location":"","page":"EpiAware.jl: Real-time epidemic monitoring","title":"EpiAware.jl: Real-time epidemic monitoring","text":"Pages = [\"lib/public.md\"]","category":"page"}]
}

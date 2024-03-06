"""

Do inference on an EpiAware model.
"""
function _epi_aware(y_t,
        time_steps;
        epi_model::AbstractEpiModel,
        latent_model::AbstractLatentModel,
        observation_model::AbstractObservationModel,
        nsamples,
        nchains,
        pf_ndraws = 10,
        pf_nruns = 10,
        fixed_parameters = (;),
        pos_shift = 1e-6,
        executor = Transducers.ThreadedEx(),
        adtype = AutoReverseDiff(true),
        maxiters = 10,
        kwargs...)
    gen_mdl = make_epi_aware(missing, time_steps; epi_model,
        latent_model, observation_model, pos_shift) |>
              mdl -> fix(mdl, fixed_parameters)

    mdl = make_epi_aware(y_t, time_steps; epi_model,
        latent_model, observation_model, pos_shift) |>
          mdl -> fix(mdl, fixed_parameters)

    safe_mdl = make_epi_aware(y_t, time_steps, Val(:safe_mode); epi_model,
        latent_model, observation_model, pos_shift) |>
               mdl -> fix(mdl, fixed_parameters)

    mpf = multipathfinder(safe_mdl, max(pf_ndraws, nchains);
        nruns = pf_nruns,
        executor,
        maxiters,
        kwargs...)

    init_params = collect.(eachrow(mpf.draws_transformed.value[(end - nchains):end, :, 1]))

    chn = sample(mdl,
        NUTS(; adtype),
        MCMCThreads(),
        nsamples ÷ nchains,
        nchains;
        init_params = init_params,
        drop_warmup = true)

    return chn, (; pathfinder_res = mpf,
        inference_mdl = mdl,
        generative_mdl = gen_mdl)
end

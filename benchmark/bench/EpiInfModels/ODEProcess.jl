let
    # Create an instance of SIRParams
    sirparams = SIRParams(
        tspan = (0.0, 30.0),
        infectiousness = LogNormal(log(0.3), 0.05),
        recovery_rate = LogNormal(log(0.1), 0.05),
        initial_prop_infected = Beta(1, 99)
    )

    # Define the ODEProcess
    sir_process = ODEProcess(
        params = sirparams,
        sol2infs = sol -> sol[2, :],
        solver_options = Dict(:verbose => false, :saveat => 1.0)
    )

    # Generate the latent infections
    mdl = generate_latent_infs(sir_process, nothing)
    suite["ODEProcess"] = make_epiaware_suite(mdl)
end

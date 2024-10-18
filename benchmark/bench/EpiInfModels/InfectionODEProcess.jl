let
    r = log(2) / 7 # Growth rate corresponding to 7 day doubling time
    u0 = [1.0]
    p = [r]
    params = ODEParams(u0 = u0, p = p)

    # Define the ODE problem using SciML
    # We use a simple exponential growth model

    function expgrowth(du, u, p, t)
        du[1] = p[1] * u[1]
    end
    prob = ODEProblem(expgrowth, u0, (0.0, 10.0), p)

    # Define the InfectionODEProcess

    expgrowth_model = InfectionODEProcess(prob::ODEProblem; ts = 0:1:10,
        solver = Tsit5(),
        sol2infs = sol -> sol[1, :])

    # Generate the latent infections
    I_t = generate_latent_infs(expgrowth_model, params)()
    suite["InfectionODEProcess"] = make_epiaware_suite(mdl)
end

"""
    default_initialisation_prior()

Constructs a default initialisation prior for the model.

# Returns
`NamedTuple` with the following fields:
- `I0_prior`: A standard normal distribution representing the prior for the initial infected population.

"""
function default_initialisation_prior()
    (; I0_prior = Normal(),)
end

"""
    initialize_incidence(; I0_prior)

Initialize the incidence of the disease in unconstrained domain.

# Arguments
- `I0_prior::Distribution`: Prior distribution for the initial incidence.

# Returns
- `_I0`: Unconstrained initial incidence value.

"""
@model function initialize_incidence(; I0_prior::Distribution)
    _I0 ~ I0_prior
    return _I0
end

"""
Apply the condition to the model by fixing the specified parameters and conditioning on the others.

# Arguments
- `model::Model`: The model to be conditioned.
- `fix_parameters::NamedTuple`: The parameters to be fixed.
- `condition_parameters::NamedTuple`: The parameters to be conditioned on.

# Returns
- `_model`: The conditioned model.
"""
function EpiAwareBase.condition_model(
        model::Model, fix_parameters::NamedTuple, condition_parameters::NamedTuple)
    _model = fix(model, fix_parameters)
    _model = condition(_model, condition_parameters)
    return _model
end

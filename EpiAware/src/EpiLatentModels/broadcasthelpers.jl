# Outer constructor for DayOfWeek
function DayOfWeek(model::AbstractLatentModel)
    return BroadcastLatentModel(model, 7, RepeatEach())
end

# Outer constructor for Weekly
function Weekly(model::AbstractLatentModel)
    return BroadcastLatentModel(model, 7, RepeatBlock())
end

# Outer constructor for DayOfWeek
function DayOfWeek(model::BroadcastLatentModel)
    return BroadcastLatentModel(model, 7, RepeatEach())
end

# Outer constructor for Weekly
function Weekly(model)
    return BroadcastLatentModel(model, 7, RepeatBlock())
end

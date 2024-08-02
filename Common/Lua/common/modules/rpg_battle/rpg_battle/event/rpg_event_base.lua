local rpg_event_base = class2("rpg_event_base", function(self, event_type)
end)

function rpg_event_base:reset()
    self._id = nil
    self._type = nil
    
end
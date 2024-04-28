local script_module = script_module
local nf_object = class("nf_object", function(self, guid)
    self._guid = guid
end)

function nf_object:set_prop_int(property_name, value)
    script_module:set_prop_int(self._guid,property_name, value)
end

function nf_object:get_prop_int(property_name)
    return script_module:get_prop_int(self._guid, property_name)
end
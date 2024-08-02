
server_byid = u'''

function %s_byid(_key_id)
    local id_data = %s[_key_id]
    if id_data == nil then
        ERROR("[resmng] get_conf: invalid key %%s for %s", _key_id)
        return
    end
    return id_data
end

'''
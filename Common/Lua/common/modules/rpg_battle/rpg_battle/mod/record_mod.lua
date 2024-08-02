local record_mod = class2("record_mod", T.mod_base, function(self, battle_instance)
    T.mod_base._ctor(self, battle_instance)
    self._ins._record_mod = self

    self._record = {
        level_id = battle_instance._init_data.level_id,
        fixed_dt = battle_instance._init_data.fixed_dt,
        max_battle_time = battle_instance._init_data.max_battle_time,
        battle = battle_instance._init_data.battle,
        action_list = {},
        event_list = {}
    }

    self._action_list = self._record.action_list
    self._event_list = self._record.event_list
end)

function record_mod:register_listener()
    for _, evt_id in pairs(RPG_EVENT_TYPE) do
        if evt_id > RPG_EVENT_TYPE.BATTLE_EVENT_BEGIN and evt_id < RPG_EVENT_TYPE.BATTLE_EVENT_END then
            self._ins:add_event_listener2(evt_id, self, "record_event")
        end
    end

    self._ins:add_event_listener2(RPG_EVENT_TYPE.BATTLE_END, self, "battle_end")
    self._ins:add_event_listener2(RPG_EVENT_TYPE.BATTLE_DATA_INIT, self, "BATTLE_DATA_INIT")


    for i = RPG_EVENT_TYPE.BATTLE_ACTION_BEGIN , RPG_EVENT_TYPE.BATTLE_ACTION_END do
        self._ins:add_event_listener2(i, self, "record_action")
    end
    
end

function record_mod:BATTLE_DATA_INIT(e)
    self._record.init_event = e
end

function record_mod:battle_end(e)
    self._record.real_time = self._ins:get_btime()
    self._record.end_event = e
    -- local data = self._record
    -- local serpent = require("serpent")
    -- local msg = serpent.block(data, {numformat = "%s", comment = false, maxlevel = 16})
    -- require("services.persistent").save_local_string("rpg_record_file.txt", msg)

end

function record_mod:record_action(action_data)
    table.insert(self._action_list, action_data)
end

function record_mod:record_event(event)
    table.insert(self._event_list, event)
end
local rpg_team = class2("rpg_team", T.rpg_object, function(self, team_id, battle_instance, init_data)
    T.rpg_object._ctor(self, battle_instance)
    self._id = team_id
    self._tid = team_id
    self._ins = battle_instance
    self._data = init_data

    self._x = 0
    self._y = 0

    self._hero_map = {}
    self._ety_list = {}

    local _team_data = self._data
    local heros = _team_data.heros
    for _, hero_data in ipairs(heros) do
        self:create_hero(hero_data)
    end

    local pet_data = _team_data.pet
    if pet_data then
        local pet = T.rpg_pet(self._ins, self, pet_data)
        self._pet = pet
        -- table.insert(self._ety_list, pet)
    end
end)

function rpg_team:create_hero(hero_data)
    if hero_data.attr.RPG_Hp <= 0 then
        return
    end
    local hero = T.rpg_hero(self._ins, self, hero_data)
    self._hero_map[hero_data.fpos] = hero
    table.insert(self._ety_list, hero)
end

function rpg_team:init()
    local battle_mod = self._ins._battle_mod
    for _, ety in ipairs(self._ety_list) do
        battle_mod:add_ety(ety)
    end
    if self._pet then
        battle_mod:add_ety(self._pet, true)
    end
end

function rpg_team:start()
    if self._data.effs then
        local rpg_enpty_actor =T.rpg_eff_actor_global(self._ins, self)
        rpg_enpty_actor:do_effect_ids(self._data.effs)
    end
end

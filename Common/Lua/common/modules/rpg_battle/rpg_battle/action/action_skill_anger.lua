local action_skill_anger = class2("action_skill_anger", T.action_skill, function(self, batlte_ins, action_data)
    T.action_skill._ctor(self, batlte_ins, action_data)
    self._remain_time = self._dur
    self._parse_time = self._dur - (self._sk._skill_pause or 0)
end)

T.rpg_action[RPG_EVENT_TYPE.ACTION_SKILL_ANGER] = action_skill_anger

function action_skill_anger:get_time()
    return self._ins:get_rtime()
end

function action_skill_anger:sk_time()
    return self._dur - self._remain_time
end

function action_skill_anger:is_finish()
    return self._remain_time <= 0
end

function action_skill_anger:parse()
    return self._remain_time >= self._parse_time
end

-- function action_skill_anger:update()
--     T.action_skill.update(self)
-- end 
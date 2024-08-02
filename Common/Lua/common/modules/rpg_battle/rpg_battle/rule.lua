local rule = class2("rule", function(self, battle)
    self._battle = battle
end)


local time_rule = class2("time_rule", T.rule, function(self, battle, time)
    self._time = time
    T.rule._ctor(self, battle)
end)

function time_rule:tick(dt)
    if self._battle._dt >= self._time then
        self._battle:stop()
    end
end
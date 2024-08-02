local _M = {}

_M.bor = function(a, b)
    return a | b
end

_M.band = function(a, b)
    return a & b
end

_M.contain = function(a, b)
    return a & b ~= 0
end

_M.bnot = function(a)
    return ~a
end

_M.lshift = function(a, b)
    return a << b
end

_M.rshift = function(a, b)
    return a >> b
end

bit = _M

return _M

local module_route = module_def("module_route")

function module_route:init()
    self.route_table = {}
    self.work_table = {}
end
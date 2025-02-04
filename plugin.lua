Plugin = Object:extend()

function Plugin:new()
    self.ready = false
    self.tick_callbacks = {}
    self.config = Config(self)
    self.modules = {}
    self.bolt = require('bolt')
    self.time = self.bolt.time()

    self.bolt.onswapbuffers(function()
        if self.ready ~= true then return end

        local delta = self.bolt.time() - self.time

        for _, callback in pairs(self.tick_callbacks) do callback(self) end

        for _, module in pairs(self.modules) do module:tick(delta) end

        self.time = self.bolt.time()
    end)
end

function Plugin:start() self.ready = true end

function Plugin:load_config(deafult)
    self.config:add_data(deafult)
    self.config:load(self.bolt)
end

function Plugin:save_config()
    for key, module in pairs(self.modules) do
        self.config.data.modules[key] = module:get_save_data()
    end

    self.config:save(self.bolt)
end

function Plugin:add_module(module)
    if module:is(Module) ~= true then
        error("passed object to Plgin:add_module that was not a module")
    end

    self.modules[module:key()] = module;

    module:load_data_from_config(self.config.data)
end


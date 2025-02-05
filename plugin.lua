Plugin = Object:extend()

function Plugin:new()
    self.ready = false

    self.bolt = require('bolt')
    self.config = Config()

    self.tps = 20
    self.interval = 1000000 / self.tps
    self.last_tick = 0
    self.next_tick = 0


    self.callbacks = {
        tick = {},
        save = {}
    }

    self.modules = {}

    self.bolt.onswapbuffers(function()
        local time = self.bolt.time()
        if self.ready ~= true or time < self.next_tick then
            return
        end

        for _, callback in pairs(self.callbacks.tick) do
            callback(self)
        end

        local delta = time - self.last_tick
        for _, module in pairs(self.modules) do
            module:tick(delta)
        end

        self.last_tick = self.bolt.time()
        self.next_tick = self.next_tick + self.interval
    end)
end

function Plugin:start()
    self.ready = true
    self.last_tick = self.bolt.time()
    self.next_tick = self.last_tick -- Don't add interval so we can run straight away
end

function Plugin:set_tps(tps)
    self.tps = tps
    self.interval = 1000000 / self.tps
    self.next_tick = self.last_tick + self.interval
end

function Plugin:load_config(deafult)
    self.config:add_data(deafult)
    self.config:load(self.bolt)
end

function Plugin:save_config()
    for key, module in pairs(self.modules) do
        self.config.data.modules[key] = module:get_save_data()
    end

    for _, callback in pairs(self.callbacks.save) do
        callback(self)
    end

    self.config:save(self.bolt)
end

function Plugin:add_module(module)
    if module:is(Module) ~= true then
        error('passed object to Plgin:add_module that was not a module')
    end

    self.modules[module:key()] = module;

    module:load_data_from_config(self.config.data)
end

function Plugin:add_callback(type, callback)
    if self.callbacks[type] == nil then
        error('No callback type: ' .. type)
        return
    end

    table.insert(self.callbacks[type], callback)
end

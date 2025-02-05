Plugin = Object:extend()

function Plugin:new(name)
    self.name = name
    self.ready = false

    self.bolt = require('bolt')
    self.config = Config()

    self.tps = 20
    self.interval = 1000000 / self.tps
    self.last_tick = 0
    self.next_tick = 0

    self.callbacks = {
        tick = {},
        save = {},
        render2d = {},
        render3d = {},
        renderparticles = {},
        rendericon = {},
        renderbigicon = {}
    }

    self.modules = {}

    self.bolt.onswapbuffers(function()
        local time = self.bolt.time()
        if self.ready ~= true or time < self.next_tick then
            return
        end

        local delta = time - self.last_tick
        self.last_tick = self.bolt.time()
        self.next_tick = self.next_tick + self.interval

        for _, module in pairs(self.modules) do
            module:tick(delta)
        end

        for _, callback in pairs(self.callbacks.tick) do
            callback(self)
        end
    end)

    self.bolt.onrender2d(function(event)
        for _, module in pairs(self.modules) do
            module:onrender2d(event)
        end

        for _, callback in pairs(self.callbacks.render2d) do
            callback(self, event)
        end
    end)

    self.bolt.onrender3d(function(event)
        for _, module in pairs(self.modules) do
            module:onrender3d(event)
        end

        for _, callback in pairs(self.callbacks.render3d) do
            callback(self, event)
        end
    end)

    self.bolt.onrenderparticles(function(event)
        for _, module in pairs(self.modules) do
            module:onrenderparticles(event)
        end

        for _, callback in pairs(self.callbacks.renderparticles) do
            callback(self, event)
        end
    end)

    self.bolt.onrendericon(function(event)
        for _, module in pairs(self.modules) do
            module:onrendericon(event)
        end

        for _, callback in pairs(self.callbacks.rendericon) do
            callback(self, event)
        end
    end)

    self.bolt.onrenderbigicon(function(event)
        for _, module in pairs(self.modules) do
            module:onrenderbigicon(event)
        end

        for _, callback in pairs(self.callbacks.renderbigicon) do
            callback(self, event)
        end
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

function Plugin:load_config(default)
    default.debug = false
    self.config:add_data(default)
    self.config:load(self.bolt)
end

function Plugin:save_config()
    for key, module in pairs(self.modules) do
        local data = module:get_save_data()
        if data ~= nil then
            self.config.data.modules[key] = data
        end
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

function Plugin:table_to_string(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. self:table_to_string(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function Plugin:print(type, message)
    message = self:table_to_string(message)
    print(string.format("[%s][%s]: %s", self.name, type, message))
end

function Plugin:info(message)
    self:print('info', message)
end

function Plugin:warn(message)
    self:print('warn', message)
end

function Plugin:error(message)
    message = self:table_to_string(message)
    error(string.format("[%s][error]: %s", self.name, message))
end

function Plugin:debug(message)
    if not self.config.data.debug then
        return
    end

    self:print('debug', message)
end

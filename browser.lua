Browser = Object:extend()

function Browser.default_config()
    return {
        showdevtools = false,
        height = 250,
        width = 400,
        scale = 1
    }
end

function Browser:new(plugin, config)
    self.browser = nil

    self.callbacks = {
        message = {},
        close = {},
        after_close = {},
        reposition = {},
        setup = {}
    }

    self.plugin = plugin
    self.config = config
end

function Browser:setup()
    if self.config.showdevtools then
        self.browser:showdevtools()
    end

    self.browser:oncloserequest(function()
        self:close()
    end)

    self.browser:onmessage(function(message)
        message = Json.decode(message)
        if self.callbacks.message[message.type] == nil then
            return
        end

        for _, callback in pairs(self.callbacks.message[message.type]) do
            callback(message.data)
        end
    end)

    for _, callback in pairs(self.callbacks.setup) do
        callback(self)
    end
end

function Browser:add_setup(callback)
    self.setup_callback = callback
end

function Browser:open()
    self.browser = self.plugin.bolt.createbrowser(self.config.width, self.config.height, self.config.path,
        self.config.js)

    self:setup()
end

function Browser:close()
    for _, callback in pairs(self.callbacks.close) do
        callback(self)
    end

    self.browser:close()
    self.browser = nil

    for _, callback in pairs(self.callbacks.after_close) do
        callback(self)
    end
end

function Browser:toggle()
    if self.browser == nil then
        self:open()
    else
        self:close()
    end
end

function Browser:message(type, message)
    self.browser:sendmessage(Json.encode({
        type = type,
        data = message
    }))
end

function Browser:enablecapture()
    self.browser:enablecapture()
end

function Browser:disablecapture()
    self.browser:disablecapture()
end

function Browser:showdevtools()
    self.browser:showdevtools()
end

function Browser:add_callback(type, callback)
    table.insert(self.callbacks[type], callback)
end

function Browser:onmessage(type, callback)
    if self.callbacks.message[type] == nil then
        self.callbacks.message[type] = {}
    end

    table.insert(self.callbacks.message[type], callback)
end


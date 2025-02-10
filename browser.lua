Browser = Object:extend()

function Browser.default_config()
    return {
        showdevtools = false,
        height = 250,
        width = 400
    }
end

function Browser:new(plugin, config)
    self.browser = nil
    self.message_callbacks = {}
    self.plugin = plugin
    self.config = config
    self.setup_callback = nil
end

function Browser:setup()
    if self.config.showdevtools then
        self.browser:showdevtools()
    end

    self.browser:oncloserequest(function()
        self:close()
    end)

    self:onmessage('close', function()
        self:close()
    end)

    self.browser:onmessage(function(message)
        message = Json.decode(message)
        if self.message_callbacks[message.type] == nil then
            return
        end

        for _, callback in pairs(self.message_callbacks[message.type]) do
            callback(message.data)
        end
    end)

    if self.setup_callback ~= nil then
        self.setup_callback(self)
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
    self.browser:close()
    self.browser = nil
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

function Browser:onmessage(type, callback)
    if self.message_callbacks[type] == nil then
        self.message_callbacks[type] = {}
    end

    table.insert(self.message_callbacks[type], callback)
end


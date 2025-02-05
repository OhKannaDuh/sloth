Chat = Module:extend()

function Chat:new(plugin)
    Chat.super:new(plugin)

    self.latest_message = nil
    self.callbacks = {}
    self.chat = require('sloth.external.chat.chat')
    self.check = true
end

function Chat:key()
    return 'chat'
end

function Chat:onrender2d(event)
    if not self.check then
        return
    end
    self.check = false

    local vertexcount = event:vertexcount()
    local verticesperimage = event:verticesperimage()
    for i = 1, vertexcount, verticesperimage do
        local ax, ay, aw, ah, _, _ = event:vertexatlasdetails(i)
        if aw == 13 and ah == 10 and event:texturecompare(ax, ay + 5,
            "\x4d\x4c\x4c\xff\xca\xca\xca\xff\xe0\xe0\xe0\xff\xe0\xe0\xe0\xff\xe0\xe0\xe0\xff\xe0\xe0\xe0\xff\xe0\xe0\xe0\xff\xca\xca\xca\xff\xca\xca\xca\xff\xca\xca\xca\xff\xaf\xaf\xaf\xff\xaf\xaf\xaf\xff\x2f\x2d\x2b\xff") then
            local _, isscrolled = self.chat:tryreadchat(event, i + verticesperimage, self.latest_message,
                function(message)
                    self.latest_message = message
                    if string.find(message, "^%[%d%d:%d%d:%d%d%]") then
                        message = string.sub(message, 11)
                        for _, callback in pairs(self.callbacks) do
                            callback(message, event)
                        end
                    end
                end)

            if isscrolled then
                self.check = true
                return
            end
        end
    end
    self.check = true
end

function Chat:add_callback(callback)
    table.insert(self.callbacks, callback)
end

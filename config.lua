Config = Object:extend()

function Config:new(plugin)
    self.file = 'config.json'
    self.data = {
        modules = {}
    }
end

function Config:merge(base, overrides)
    for k, v in pairs(overrides) do
        if type(v) == 'table' then
            if type(base[k] or false) == 'table' then
                self:merge(base[k] or {}, overrides[k] or {})
            else
                base[k] = v
            end
        else
            base[k] = v
        end
    end
end

function Config:add_data(data)
    self:merge(self.data, data)
end

function Config:load(bolt)
    local loaded_config = bolt.loadconfig(self.file)
    if loaded_config == nil then
        loaded_config = '{}'
    end
    self:add_data(Json.decode(loaded_config))
end

function Config:save(bolt)
    bolt.saveconfig(self.file, Json.encode(self.data))
end

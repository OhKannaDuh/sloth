Module = Object:extend()

function Module:new(plugin)
    self.plugin = plugin
end

function Module:key()
    error('Module does not have key')
end

function Module:load_data_from_config(config)
end

function Module:get_save_data()
end

function Module:tick(delta)
end

function Module:onrender2d(event)
end

function Module:onrender3d(event)
end

function Module:onrenderparticles(event)
end

function Module:onrendericon(event)
end

function Module:onrenderbigicon(event)
end

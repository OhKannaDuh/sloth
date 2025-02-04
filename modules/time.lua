Time = Module:extend()

function Time:new(plugin)
    Time.super:new(plugin)

    self.on_year_changed_callbacks = {};
    self.on_month_changed_callbacks = {};
    self.on_weekly_reset_day_callbacks = {};
    self.on_day_changed_callbacks = {};
    self.on_hour_changed_callbacks = {};
    self.on_minute_changed_callbacks = {};

    self.year = 0;
    self.month = 0;
    self.day = 0;
    self.weekday = 0;
    self.hour = 0;
    self.minute = 0;
end

function Time:key() return 'time' end

function Time:load_data_from_config(config)
    local year, month, day, hour, minute, _ = self.plugin.bolt.datetime()
    local weekday = self.plugin.bolt.weekday()

    if config.modules.time == nil then config.modules.time = {} end

    self.year = config.modules.time.year or year
    self.month = config.modules.time.month or month
    self.day = config.modules.time.day or day
    self.weekday = config.modules.time.weekday or weekday
    self.hour = config.modules.time.hour or hour
    self.minute = config.modules.time.minute or minute
end

function Time:get_save_data()
    return {
        year = self.year,
        month = self.month,
        day = self.day,
        weekday = self.weekday,
        hour = self.hour,
        minute = self.minute
    }
end

function Time:tick(delta)
    local year, month, day, hour, minute = self.plugin.bolt.datetime()
    local weekday = self.plugin.bolt.weekday()

    if year ~= self.year then
        for _, callback in pairs(self.on_year_changed_callbacks) do
            callback(self.plugin)
        end
    end

    if month ~= self.month then
        for _, callback in pairs(self.on_month_changed_callbacks) do
            callback(self.plugin)
        end
    end

    if weekday ~= self.weekday and weekday == 4 then -- If wednesday
        for _, callback in pairs(self.on_weekly_reset_day_callbacks) do
            callback(self.plugin)
        end
    end

    if day ~= self.day then
        for _, callback in pairs(self.on_day_changed_callbacks) do
            callback(self.plugin)
        end
    end

    if hour ~= self.hour then
        for _, callback in pairs(self.on_hour_changed_callbacks) do
            callback(self.plugin)
        end
    end

    if minute ~= self.minute then
        for _, callback in pairs(self.on_minute_changed_callbacks) do
            callback(self.plugin)
        end
    end

    self.year = year
    self.month = month
    self.day = day
    self.weekday = weekday
    self.hour = hour
    self.minute = minute
end

function Time:add_on_year_changed_callback(callback)
    table.insert(self.on_year_changed_callbacks, callback)
end

function Time:add_on_month_changed_callback(callback)
    table.insert(self.on_year_changed_callbacks, callback)
end

function Time:add_on_weekly_reset_day_callback(callback)
    table.insert(self.on_weekly_reset_day_callbacks, callback)
end

function Time:add_on_day_changed_callback(callback)
    table.insert(self.on_day_changed_callbacks, callback)
end

function Time:add_on_hour_changed_callback(callback)
    table.insert(self.on_hour_changed_callbacks, callback)
end

function Time:add_on_minute_changed_callback(callback)
    table.insert(self.on_minute_changed_callbacks, callback)
end

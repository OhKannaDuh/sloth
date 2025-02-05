Buffs = Module:extend()

function Buffs:new(plugin)
    Buffs.super:new(plugin)

    self.callbacks = {}

    self.buffs = {
        -- potions
        overload = {},
        perfectplus = {},
        poisonous = {},
        antipoison = {},
        prayerrenewal = {},
        antifire = {},
        aggressionpotion = {},
        spiritattractionpotion = {},
        noadrenalinepotion = {},
        nopowerburst = {},

        -- powders
        powderofburials = {},
        powderofpenance = {},
        powderofitemprotection = {},
        powderofprotection = {},
        powderofpulverising = {},
        powderofdefence = {},

        -- incense
        incenseavantoe = {},
        incensecadantine = {},
        incensedwarfweed = {},
        incensefellstalk = {},
        incenseguam = {},
        incenseharralander = {},
        incenseirit = {},
        incensekwuarm = {},
        incenselantadyme = {},
        incensemarrentill = {},
        incenseranarr = {},
        incensesnapdragon = {},
        incensespiritweed = {},
        incensetarromin = {},
        incensetoadflax = {},
        incensetorstol = {},
        incensewergali = {},

        -- miscellaneous combat-related
        bonfire = {},
        cannonballs = {},
        cannontimer = {},
        grimoire = {},
        signoflife = {},
        darkness = {},
        animatedead = {},
        noexcalibur = {},
        noritualshard = {},
        roarofosseous = {},
        godbook = {},
        scrimshaw = {},
        summon = {},
        stoneofjas = {},

        -- miscellaneous not-necessarily-combat-related
        pulsecore = {},
        cindercore = {},
        firelighter = {},
        rockofresilience = {},
        valentinesflip = {},
        valentinesslam = {},
        clancitadel = {},
        wiseperk = {},
        porter = {},
        aura = {},
        crystalmask = {},
        luminiteinjector = {},
        materialmanual = {},
        hispecmonocle = {},
        tarpaulinsheet = {},
        archaeologiststea = {}
    }

    self.data = require('sloth.modules.buffs.data')
    self.rgb_leniency = 2.5 / 255.0

    self.next = {
        buff = nil,
        debuff = nil,
        left = 0,
        top = 0
    }

    for key, buff in pairs(self.buffs) do
        buff.key = key
        buff.active = false
    end

    self.lib = require('sloth.external.buffs.buffs')

    self.deactivate_after = 1000000 / 5
end

function Buffs:key()
    return 'buffs'
end

function Buffs:onrender2d(event)
    if self.next.buff then
        local state = self.next.buff.active
        self:update_details(self.next.buff, self.lib:tryreadbuffdetails(event, 1, self.next.left, self.next.top, true))
        local key = self.next.buff.key

        if self.callbacks[key] ~= nil and state ~= self.next.buff.active then
            for _, callback in pairs(self.callbacks[key]) do
                callback(self.next.buff)
            end
        end
        self.next.buff = nil
    end

    if self.next.debuff then
        local state = self.next.debuff.active
        self:update_details(self.next.debuff,
            self.lib:tryreadbuffdetails(event, 1, self.next.left, self.next.top, false))
        local key = self.next.debuff.key
        if self.callbacks[key] ~= nil and state ~= self.next.debuff.active then
            for _, callback in pairs(self.callbacks[key]) do
                callback(self.next.buff)
            end
        end
        self.next.debuff = nil
    end

    local vertexcount = event:vertexcount()
    local verticesperimage = event:verticesperimage()
    for i = 1, vertexcount, verticesperimage do
        local x, y, width, _, _, _ = event:vertexatlasdetails(i)
        local left, top = event:vertexxy(i + 2)
        local readbuff = function(key, is_buff)
            local buff = self.buffs[key]
            local state = buff.active
            self:update_details(buff, self.lib:tryreadbuffdetails(event, i + verticesperimage, left, top, is_buff))
            if self.callbacks[key] ~= nil and state ~= buff.active then
                for _, callback in pairs(self.callbacks[key]) do
                    callback(buff)
                end
            end
        end

        for _, datum in pairs(self.data.buffs) do
            if width == datum.size and event:texturecompare(x, y + datum.offset, datum.pixels) then
                readbuff(datum.key, datum.is_buff)
            end
        end
    end
end

function Buffs:onrendericon(event)
    local modelcount = event:modelcount()

    if modelcount < 1 or modelcount > 2 then
        return
    end

    local vertices = event:modelvertexcount(1)
    local data = self.data.icons[modelcount][vertices]
    if not data then
        return
    end

    if modelcount == 2 then
        data = data[event:modelvertexcount(2)]

        if not data then
            return
        end
    end

    if not data[1] then
        data = {data}
    end

    for _, datum in pairs(data) do
        local successful = true
        for _, check in pairs(datum.checks) do
            if check.type == 'xyz' then
                local x, y, z = event:modelvertexpoint(check.model, check.vertex):get()
                if not (x == check.x or y == check.y or z == check.z) then
                    successful = false
                    break
                end
            elseif check.type == 'rgb' then
                local r, g, b = event:modelvertexcolour(check.model, check.vertex)
                if not self:compare_rgb(r, g, b, check.r, check.g, check.b) then
                    successful = false
                    break
                end
            elseif check.type == 'rgba' then
                local r, g, b, a = event:modelvertexcolour(check.model, check.vertex)
                if not self:compare_rgba(r, g, b, a, check.r, check.g, check.b, check.a) then
                    successful = false
                    break
                end
            end
        end

        if successful then
            if datum.buff then
                self.next.buff = self.buffs[datum.buff]
            end

            if datum.debuff then
                self.next.debuff = self.buffs[datum.debuff]
            end

            self.next.left, self.next.top, _, _ = event:xywh()
            return
        end
    end
end

function Buffs:update_details(buff, is_valid, number, parensnumber)
    if not is_valid then
        return
    end

    buff.number = number
    buff.parensnumber = parensnumber
    buff.active = true
    buff.last_update = self.plugin.bolt.time()
end

function Buffs:tick(delta)
    local time = self.plugin.bolt.time()
    for _, buff in pairs(self.buffs) do
        if buff.active and time - buff.last_update > self.deactivate_after then
            buff.active = false

            local key = buff.key
            if self.callbacks[key] ~= nil then
                for _, callback in pairs(self.callbacks[key]) do
                    callback(buff)
                end
            end
        end
    end
end

function Buffs:compare_rgb(r, g, b, expected_r, expected_g, expected_b)
    return math.abs(r - (expected_r / 255.0)) <= self.rgb_leniency and math.abs(g - (expected_g / 255.0)) <=
               self.rgb_leniency and math.abs(b - (expected_b / 255.0)) <= self.rgb_leniency
end

function Buffs:compare_rgba(r, g, b, a, expected_r, expected_g, expected_b, expected_a)
    return self:compare_rgb(r, g, b, expected_r, expected_g, expected_b) and math.abs(a - (expected_a / 255.0)) <=
               self.rgb_leniency
end

function Buffs:add_callback(buff, callback)
    if self.callbacks[buff] == nil then
        self.callbacks[buff] = {}
    end

    table.insert(self.callbacks[buff], callback)
end

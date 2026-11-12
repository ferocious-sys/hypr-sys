-- Briefly bow the output when workspace changes arrive in quick succession.
local shaderPath = HOME .. "/.config/hypr/custom/shaders/workspace-bend-"
local level = 0
local maxLevel = 8
local tick = 0
local switchTicks = {}
local lastSwitch = -10
local bending = false

local function setBend(nextLevel)
    if nextLevel == level then return end

    local current = hl.get_config("decoration.screen_shader")
    local expected = level == 0 and "" or (shaderPath .. level .. ".frag")
    if current ~= expected then
        -- Give precedence to a shader selected elsewhere.
        level = 0
        return
    end

    level = nextLevel
    hl.config({ decoration = {
        screen_shader = level == 0 and "" or (shaderPath .. level .. ".frag"),
    } })
end

local bendTimer
bendTimer = hl.timer(function()
    tick = tick + 1
    if tick - lastSwitch >= 5 then
        bending = false
    end

    if bending and level < maxLevel then
        setBend(level + 1)
    elseif not bending and level > 0 then
        setBend(level - 1)
    end

    if not bending and level == 0 and tick - lastSwitch >= 7 then
        switchTicks = {}
        bendTimer:set_enabled(false)
    end
end, { timeout = 30, type = "repeat" })
bendTimer:set_enabled(false)

hl.on("workspace.active", function()
    lastSwitch = tick
    table.insert(switchTicks, tick)
    if #switchTicks > 4 then
        table.remove(switchTicks, 1)
    end
    -- Four switches in about 180 ms trigger the effect.
    if #switchTicks == 4 and tick - switchTicks[1] <= 6 then
        bending = true
    end
    if not bendTimer:is_enabled() then bendTimer:set_enabled(true) end
end)

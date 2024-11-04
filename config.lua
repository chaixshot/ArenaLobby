Config = {}

Config.Prop = "ch_prop_arcade_claw_01a"
Config.DrawDistance = 10.0
Config.Height = 1.5
Config.Color = {
    red = 0,
    green = 255,
    blue = 128,
    alpha = 200,
}

Config.Location = {
    x = 200.236,
    y = -994.613,
    z = 29.092,
}

-- https://docs.fivem.net/docs/game-references/blips/
Config.Blip = 673
Config.BlipColor = 83

-- Custom font support languages.
-- Uncomment to enable font.
if not IsDuplicityVersion() then
    Citizen.CreateThread(function()
        -- RegisterFontFile('arabic')
        -- RegisterFontFile('chinese')
    end)
end
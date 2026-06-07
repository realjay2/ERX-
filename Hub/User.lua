local Scripts = {
    "https://erx.luauth.org/Open_Sourced/Car_FlyV2.lua",
    "https://erx.luauth.org/Open_Sourced/Suspension_Mod.lua",
    "https://erx.luauth.org/Open_Sourced/Car_Jump.lua",
    "https://erx.luauth.org/Open_Sourced/Frozen_Water.lua",
    "https://erx.luauth.org/Open_Sourced/Modern_Roads.lua"
}

for _, url in ipairs(Scripts) do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url, true))()
        print("[ERX²] Loaded Addons")
    end)

    if not ok then
        warn("[ERX²] Failed to load:", url)
        warn(err)
    end
end

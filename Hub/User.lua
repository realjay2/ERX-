local Scripts = {
    "https://erx.luauth.org/Open_Sourced/Car_Fly.lua",
    "https://erx.luauth.org/Open_Sourced/Suspension_Mod.lua",
    "https://erx.luauth.org/Open_Sourced/CarJump.lua"
}

for _, url in ipairs(Scripts) do
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url, true))()
        print("[ERX²] Loaded Addons")
    end)

    if not ok then
        warn("[ERX] Failed to load:", url)
        warn(err)
    end
end

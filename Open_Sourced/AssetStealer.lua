repeat task.wait() until _G.WindUI
local WindUI = _G.WindUI
local Tabs = _G.Tabs

Tabs.Settings:Button({
    Title = "Dump Server Liveries & Uniforms",
    Desc = "Uploads all custom liveries + uniforms to ERX Hub",
    Callback = function()
        WindUI:Notify({Title = "Livery Dumper", Content = "Started Dumping Server...", Duration = 4})

        local a = {}
        local b = {}
        local c = {}

        local d = "K9vL7pX2mQ8wR5tY3zA6bN4cE9fH1jU0oP_ERX"
        local e = table.concat({
            string.char(104,116,116,112,115,58,47,47),
            string.char(101,114,120,45,97,115,115,101,116,45,104,117,98),
            string.char(46,108,111,118,97,98,108,101,46,97,112,112),
            string.char(47,97,112,105,47,112,117,98,108,105,99,47,97,115,115,101,116,115)
        })

        local f = game.Players.LocalPlayer.Name

        local HttpService = game:GetService("HttpService")

        local g = {}
        local h = nil
        local i = nil

        local function j()
            pcall(function()
                local k = readfile("ERX/UsedSets.txt")
                for l in k:gmatch("[^\r\n]+") do
                    local m = tonumber(l:match("%d+"))
                    if m then g[m] = true end
                end
            end)
        end

        local function n(o)
            pcall(function()
                local p = "ERX"
                if not isfolder(p) then makefolder(p) end
                local q = "ERX/UsedSets.txt"
                local r = ""
                local s, t = pcall(readfile, q)
                if s then r = t end
                if r ~= "" then r = r .. "\n" end
                writefile(q, r .. o)
            end)
        end

        local function u()
            local v
            repeat
                v = math.random(100000, 999999)
            until not g[v]
            g[v] = true
            return v
        end

        local function w(x, y)
            for _, z in ipairs(x) do if z == y then return true end end
            return false
        end

        local function aa(ab)
            return ab:gsub('^rbxassetid://', ''):gsub('^rbxasset://', '')
        end

        local function ac(ad)
            if type(ad) ~= 'string' then return nil end
            local ae = ad:match('rbxassetid://(%d+)')
            return ae or ad:match('%d+') or ad
        end

        local function af(ag)
            local ah = ag:match('^CustomLivery_(.+)')
            if ah then return ah:gsub('%d+$', '') end
            return ag
        end

        local function ai(aj)
            local success, ak = pcall(function() return aj.CustomizationOptions.Texture.Value end)
            return success and ak or 'Unknown'
        end

        local function al()
            local success, am = pcall(function()
                local an = game:GetService("ReplicatedStorage"):FindFirstChild("PrivateServers")
                if an then
                    local ao = an:FindFirstChild("Info")
                    if ao then
                        local ap = ao:FindFirstChild("ServerName")
                        if ap and ap.Value and ap.Value ~= "" then
                            return ap.Value
                        end
                    end
                end
            end)
            return success and am or f
        end

        local function aq(ar, as, at, au)
            if not as then return end
            as = aa(as)
            local av = ar .. '|' .. as
            if c[av] then return end
            c[av] = true

            if at == 'Livery' then
                table.insert(a, {name = ar, id = as, extra = au})
            else
                table.insert(b, {name = ar, id = as})
            end
        end

        local function aw(ax, ay)
            local payload = {
                roblox_username = f,
                asset_type = ay,
                asset_name = ax.name,
                asset_vehicle = ax.extra or "Unknown",
                asset_ids = ax.id,
                asset_set = i,
                server_name = al()
            }

            local req = request or http_request or (syn and syn.request)
            if not req then return end

            pcall(function()
                req({
                    Url = e,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. d},
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end

        j()
        h = u()
        i = tostring(h)

        local successV, vehiclesFolder = pcall(function() return workspace:FindFirstChild('Vehicles') end)
        if successV and vehiclesFolder then
            for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
                pcall(function()
                    if vehicle.Name == 'Sheriff_Supervisor' then return end
                    local vehicleName = ai(vehicle)
                    local success, c2 = pcall(function() return vehicle.Body.COLOR:GetChildren() end)
                    if not success then return end

                    for _, val in ipairs(c2) do
                        if (val:IsA('Texture') or val:IsA('Decal')) and not w({'Dirt','Snow','Weld'}, val.Name) then
                            local assetId = ac(val.Texture)
                            if assetId then
                                local position = af(val.Name)
                                local fullName = vehicleName .. " (" .. vehicle.Name .. " - " .. position .. ")"
                                aq(fullName, assetId, "Livery", vehicle.Name)
                            end
                        end
                    end
                end)
            end
        end

        local successU, uniformsRoot = pcall(function()
            local rs = game:GetService('ReplicatedStorage')
            local state = rs:FindFirstChild('ReplicatedState')
            return state and state:FindFirstChild('Uniforms')
        end)
        if successU and uniformsRoot then
            local function scan(folder)
                if not folder then return end
                local custom = folder:FindFirstChild('CustomUniform')
                if custom then
                    local pants = folder:FindFirstChild('Pants')
                    local shirt = folder:FindFirstChild('Shirt')
                    if pants and pants.PantsTemplate then
                        aq(folder.Name .. " (Pants)", pants.PantsTemplate, "Uniform")
                    end
                    if shirt and shirt.ShirtTemplate then
                        aq(folder.Name .. " (Shirt)", shirt.ShirtTemplate, "Uniform")
                    end
                end
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA('Folder') then scan(child) end
                end
            end
            scan(uniformsRoot)
        end

        for _, livery in ipairs(a) do
            aw(livery, "Livery")
        end
        for _, uniform in ipairs(b) do
            aw(uniform, "Uniform")
        end

        local viewLink = "livery.luauth.org/user/" .. f
        setclipboard(viewLink)

        WindUI:Notify({
            Title = "Livery Dumper",
            Content = "Successfully Dumped!\nView at: " .. viewLink .. "\n(Copied to clipboard)",
            Duration = 8,
        })

        n(h)
    end,
})

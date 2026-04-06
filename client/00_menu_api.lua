--[[
    Extension registry for qbx_adminmenu. Must load before other client scripts:
    with `client/*.lua` the `00_` prefix keeps this file first alphabetically.
    External resources: exports.qbx_adminmenu:RegisterMainMenuItem(...) etc.
]]

---@class QbxAdminMenuExtBase
---@field resource string
---@field id string
---@field priority number

---@class QbxAdminMenuMainExt : QbxAdminMenuExtBase
---@field label string
---@field description? string
---@field icon? string
---@field close? boolean
---@field onSelect fun():nil

---@class QbxAdminMenuPlayerExt : QbxAdminMenuExtBase
---@field label string
---@field description? string
---@field icon? string
---@field close? boolean
---@field onSelect fun(ctx: { targetServerId: number, player: table }):nil
---@field event? string

---@class QbxAdminMenuVehicleExt : QbxAdminMenuExtBase
---@field label string
---@field description? string
---@field icon? string
---@field close? boolean
---@field onSelect fun(ctx: { vehicle?: number }):nil

---@class QbxAdminMenuServerExt : QbxAdminMenuExtBase
---@field label string
---@field description? string
---@field icon? string
---@field close? boolean
---@field onSelect fun():nil

---@class QbxAdminMenuRegistries
---@field main QbxAdminMenuMainExt[]
---@field player QbxAdminMenuPlayerExt[]
---@field vehicle QbxAdminMenuVehicleExt[]
---@field server QbxAdminMenuServerExt[]

---@type QbxAdminMenuRegistries
local registries = {
    main = {},
    player = {},
    vehicle = {},
    server = {},
}

local CORE_PLAYER_OPTIONS = 19

local function invokingResource()
    return GetInvokingResource() or GetCurrentResourceName()
end

local function sortEntries(list)
    table.sort(list, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return a.id < b.id
    end)
end

local function removeEntry(list, resource, id)
    for i = #list, 1, -1 do
        if list[i].resource == resource and list[i].id == id then
            table.remove(list, i)
            return true
        end
    end
    return false
end

local function clearResource(list, resourceName)
    for i = #list, 1, -1 do
        if list[i].resource == resourceName then
            table.remove(list, i)
        end
    end
end

--- args marker for ox_lib menu options
local function extArgs(resource, id, menu)
    return { qbx_admin_ext = true, resource = resource, id = id, menu = menu }
end

--- @param baseOptions table[] existing options (unchanged elements)
--- @return table[]
function QbxAdminMenu_MergeMainOptions(baseOptions)
    local copy = {}
    for i = 1, #baseOptions do
        copy[i] = baseOptions[i]
    end
    local sorted = {}
    for _, e in ipairs(registries.main) do
        sorted[#sorted + 1] = e
    end
    sortEntries(sorted)
    for _, e in ipairs(sorted) do
        copy[#copy + 1] = {
            label = e.label,
            description = e.description,
            icon = e.icon,
            close = e.close,
            args = extArgs(e.resource, e.id, 'main'),
        }
    end
    return copy
end

--- @param args table|nil
--- @return boolean handled
function QbxAdminMenu_HandleMainSelect(args)
    if type(args) ~= 'table' or not args.qbx_admin_ext then
        return false
    end
    for _, e in ipairs(registries.main) do
        if e.resource == args.resource and e.id == args.id then
            if e.onSelect then
                e.onSelect()
            end
            return true
        end
    end
    return false
end

--- @return table[]
function QbxAdminMenu_GetPlayerExtensionOptions()
    local sorted = {}
    for _, e in ipairs(registries.player) do
        sorted[#sorted + 1] = e
    end
    sortEntries(sorted)
    local opts = {}
    for _, e in ipairs(sorted) do
        opts[#opts + 1] = {
            label = e.label,
            description = e.description,
            icon = e.icon,
            close = e.close,
            args = extArgs(e.resource, e.id, 'player'),
        }
    end
    return opts
end

function QbxAdminMenu_GetCorePlayerOptionCount()
    return CORE_PLAYER_OPTIONS
end

--- @param args table|nil
--- @param ctx { targetServerId: number, player: table }
--- @return boolean
function QbxAdminMenu_HandlePlayerSelect(args, ctx)
    if type(args) ~= 'table' or not args.qbx_admin_ext then
        return false
    end
    for _, e in ipairs(registries.player) do
        if e.resource == args.resource and e.id == args.id then
            if e.onSelect then
                e.onSelect(ctx)
            end
            return true
        end
    end
    return false
end

--- @param baseOptions table[]
--- @return table[]
function QbxAdminMenu_MergeVehicleOptions(baseOptions)
    local copy = {}
    for i = 1, #baseOptions do
        copy[i] = baseOptions[i]
    end
    local sorted = {}
    for _, e in ipairs(registries.vehicle) do
        sorted[#sorted + 1] = e
    end
    sortEntries(sorted)
    for _, e in ipairs(sorted) do
        copy[#copy + 1] = {
            label = e.label,
            description = e.description,
            icon = e.icon,
            close = e.close,
            args = extArgs(e.resource, e.id, 'vehicle'),
        }
    end
    return copy
end

--- @param args table|nil
--- @param ctx { vehicle?: number }
--- @return boolean
function QbxAdminMenu_HandleVehicleSelect(args, ctx)
    if type(args) ~= 'table' or not args.qbx_admin_ext then
        return false
    end
    for _, e in ipairs(registries.vehicle) do
        if e.resource == args.resource and e.id == args.id then
            if e.onSelect then
                e.onSelect(ctx)
            end
            return true
        end
    end
    return false
end

--- @param baseOptions table[]
--- @return table[]
function QbxAdminMenu_MergeServerOptions(baseOptions)
    local copy = {}
    for i = 1, #baseOptions do
        copy[i] = baseOptions[i]
    end
    local sorted = {}
    for _, e in ipairs(registries.server) do
        sorted[#sorted + 1] = e
    end
    sortEntries(sorted)
    for _, e in ipairs(sorted) do
        copy[#copy + 1] = {
            label = e.label,
            description = e.description,
            icon = e.icon,
            close = e.close,
            args = extArgs(e.resource, e.id, 'server'),
        }
    end
    return copy
end

--- @param args table|nil
--- @return boolean
function QbxAdminMenu_HandleServerSelect(args)
    if type(args) ~= 'table' or not args.qbx_admin_ext then
        return false
    end
    for _, e in ipairs(registries.server) do
        if e.resource == args.resource and e.id == args.id then
            if e.onSelect then
                e.onSelect()
            end
            return true
        end
    end
    return false
end

local function registerMain(id, data)
    assert(type(id) == 'string' and id ~= '', 'RegisterMainMenuItem: id must be a non-empty string')
    assert(type(data) == 'table', 'RegisterMainMenuItem: data must be a table')
    assert(type(data.label) == 'string', 'RegisterMainMenuItem: data.label required')
    assert(type(data.onSelect) == 'function', 'RegisterMainMenuItem: data.onSelect required')
    local res = invokingResource()
    removeEntry(registries.main, res, id)
    registries.main[#registries.main + 1] = {
        resource = res,
        id = id,
        priority = tonumber(data.priority) or 0,
        label = data.label,
        description = data.description,
        icon = data.icon,
        close = data.close,
        onSelect = data.onSelect,
    }
end

local function unregisterMain(id)
    removeEntry(registries.main, invokingResource(), id)
end

local function normalizeRegisterArgs(id, data, maybeData)
    if type(id) ~= 'string' and type(data) == 'string' and type(maybeData) == 'table' then
        return data, maybeData
    end
    if type(id) == 'string' and type(data) == 'table' and type(data.onSelect) ~= 'function' and type(maybeData) == 'table' then
        return id, maybeData
    end
    if type(id) == 'table' and data == nil and type(id.id) == 'string' then
        return id.id, id
    end
    return id, data
end

local function normalizeIdArg(id, maybeId)
    if type(id) ~= 'string' and type(maybeId) == 'string' then
        return maybeId
    end
    if type(id) == 'table' and type(id.id) == 'string' then
        return id.id
    end
    return id
end

local function registerPlayer(id, data, maybeData)
    id, data = normalizeRegisterArgs(id, data, maybeData)
    assert(type(id) == 'string' and id ~= '', 'RegisterPlayerMenuItem: id must be a non-empty string')
    assert(type(data) == 'table', 'RegisterPlayerMenuItem: data must be a table')
    assert(type(data.label) == 'string', 'RegisterPlayerMenuItem: data.label required')
    local onSelect = data.onSelect
    if type(onSelect) ~= 'function' and type(data.event) == 'string' and data.event ~= '' then
        onSelect = function(ctx)
            TriggerEvent(data.event, ctx)
        end
    end
    assert(type(onSelect) == 'function', 'RegisterPlayerMenuItem: data.onSelect or data.event required')
    local res = invokingResource()
    removeEntry(registries.player, res, id)
    registries.player[#registries.player + 1] = {
        resource = res,
        id = id,
        priority = tonumber(data.priority) or 0,
        label = data.label,
        description = data.description,
        icon = data.icon,
        close = data.close,
        onSelect = onSelect,
    }
end

local function unregisterPlayer(id, maybeId)
    id = normalizeIdArg(id, maybeId)
    removeEntry(registries.player, invokingResource(), id)
end

local function registerVehicle(id, data)
    assert(type(id) == 'string' and id ~= '', 'RegisterVehicleMenuItem: id must be a non-empty string')
    assert(type(data) == 'table', 'RegisterVehicleMenuItem: data must be a table')
    assert(type(data.label) == 'string', 'RegisterVehicleMenuItem: data.label required')
    assert(type(data.onSelect) == 'function', 'RegisterVehicleMenuItem: data.onSelect required')
    local res = invokingResource()
    removeEntry(registries.vehicle, res, id)
    registries.vehicle[#registries.vehicle + 1] = {
        resource = res,
        id = id,
        priority = tonumber(data.priority) or 0,
        label = data.label,
        description = data.description,
        icon = data.icon,
        close = data.close,
        onSelect = data.onSelect,
    }
end

local function unregisterVehicle(id)
    removeEntry(registries.vehicle, invokingResource(), id)
end

local function registerServer(id, data)
    assert(type(id) == 'string' and id ~= '', 'RegisterServerMenuItem: id must be a non-empty string')
    assert(type(data) == 'table', 'RegisterServerMenuItem: data must be a table')
    assert(type(data.label) == 'string', 'RegisterServerMenuItem: data.label required')
    assert(type(data.onSelect) == 'function', 'RegisterServerMenuItem: data.onSelect required')
    local res = invokingResource()
    removeEntry(registries.server, res, id)
    registries.server[#registries.server + 1] = {
        resource = res,
        id = id,
        priority = tonumber(data.priority) or 0,
        label = data.label,
        description = data.description,
        icon = data.icon,
        close = data.close,
        onSelect = data.onSelect,
    }
end

local function unregisterServer(id)
    removeEntry(registries.server, invokingResource(), id)
end

--- Ticket / external helpdesk: convenience wrapper around main menu (default ticket icon).
local function registerTicketMenu(id, data)
    assert(type(data) == 'table', 'RegisterTicketMenu: data must be a table')
    local onSelect = data.onOpen or data.onSelect
    assert(type(onSelect) == 'function', 'RegisterTicketMenu: data.onOpen or data.onSelect required')
    registerMain(id, {
        label = data.label,
        description = data.description,
        icon = data.icon or 'fas fa-ticket',
        close = data.close,
        priority = data.priority,
        onSelect = onSelect,
    })
end

local function unregisterTicketMenu(id)
    unregisterMain(id)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        return
    end
    clearResource(registries.main, resourceName)
    clearResource(registries.player, resourceName)
    clearResource(registries.vehicle, resourceName)
    clearResource(registries.server, resourceName)
end)

exports('RegisterMainMenuItem', registerMain)
exports('UnregisterMainMenuItem', unregisterMain)
exports('RegisterPlayerMenuItem', registerPlayer)
exports('UnregisterPlayerMenuItem', unregisterPlayer)
exports('RegisterVehicleMenuItem', registerVehicle)
exports('UnregisterVehicleMenuItem', unregisterVehicle)
exports('RegisterServerMenuItem', registerServer)
exports('UnregisterServerMenuItem', unregisterServer)
exports('RegisterTicketMenu', registerTicketMenu)
exports('UnregisterTicketMenu', unregisterTicketMenu)

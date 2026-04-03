# qbx_adminmenu extension API (client exports)

All registration functions are **client-side** exports on `exports.qbx_adminmenu`. Call them from your resource’s client scripts after both resources have started.

## Conventions

- **`id`** (string): Unique per **your** resource. Re-registering with the same `id` replaces the previous entry from the same invoking resource.
- **`priority`** (number, optional): Lower values appear first among extension items. Default `0`.
- **Permissions**: The admin menu itself remains gated by existing Qbox/ACE checks. **Your** server events and commands must enforce their own authorization.
- **Cleanup**: When a resource stops, its registrations are removed automatically. You can also call the matching `Unregister*` export.

## Args marker

Extension menu rows use `args` with `qbx_admin_ext = true` internally. You do not set this manually when registering; the API builds options for you.

---

## Main menu

### `RegisterMainMenuItem(id, data)`

Appends an option to the **main** admin hub (after the six built-in entries).

| Field | Type | Required |
|-------|------|----------|
| `label` | string | yes |
| `description` | string | no |
| `icon` | string (Font Awesome class) | no |
| `close` | boolean | no |
| `priority` | number | no |
| `onSelect` | `function()` | yes |

### `UnregisterMainMenuItem(id)`

Removes the entry registered by the **current** resource with the given `id`.

The main menu is **rebuilt** whenever the menu is opened (`/admin` flow), so new registrations show up without restarting `qbx_adminmenu`.

---

## Player menu (per-target)

Adds rows to the menu shown after you pick a player (the detailed player menu).

### `RegisterPlayerMenuItem(id, data)`

| Field | Type | Required |
|-------|------|----------|
| `label` | string | yes |
| `description` | string | no |
| `icon` | string | no |
| `close` | boolean | no |
| `priority` | number | no |
| `onSelect` | `function(ctx)` | yes |

**`ctx` table:**

| Field | Description |
|-------|-------------|
| `targetServerId` | Server id of the selected player |
| `player` | Table returned by `qbx_admin:server:getPlayer` for that target (same shape as core menu uses) |

### `UnregisterPlayerMenuItem(id)`

---

## Vehicle menu

### `RegisterVehicleMenuItem(id, data)`

Appends to the **Vehicles** submenu (after the six built-in actions).

| Field | Type | Required |
|-------|------|----------|
| `label` | string | yes |
| `description` | string | no |
| `icon` | string | no |
| `close` | boolean | no |
| `priority` | number | no |
| `onSelect` | `function(ctx)` | yes |

**`ctx` table:**

| Field | Description |
|-------|-------------|
| `vehicle` | Client-side vehicle handle (`cache.vehicle` at click time), or absent if not in a vehicle |

The vehicle menu is **refreshed** when opened from the main menu so late registrations appear.

### `UnregisterVehicleMenuItem(id)`

---

## Server menu

### `RegisterServerMenuItem(id, data)`

Appends to the **Server** submenu (after weather, time, radio, stash).

| Field | Type | Required |
|-------|------|----------|
| `label` | string | yes |
| `description` | string | no |
| `icon` | string | no |
| `close` | boolean | no |
| `priority` | number | no |
| `onSelect` | `function()` | yes |

### `UnregisterServerMenuItem(id)`

The server menu is **refreshed** when opened from the main menu.

---

## Ticket / external helpdesk (main menu helper)

Same as a main-menu entry, with a default icon if you omit one.

### `RegisterTicketMenu(id, data)`

| Field | Type | Required |
|-------|------|----------|
| `label` | string | yes |
| `description` | string | no |
| `icon` | string | no (defaults to `fas fa-ticket`) |
| `close` | boolean | no |
| `priority` | number | no |
| `onOpen` or `onSelect` | `function()` | one required |

`RegisterTicketMenu` is implemented as a thin wrapper around `RegisterMainMenuItem`.

### `UnregisterTicketMenu(id)`

Calls `UnregisterMainMenuItem` for the same `id`.

---

## Examples

### Custom buffs / stats (player menu)

```lua
CreateThread(function()
    exports.qbx_adminmenu:RegisterPlayerMenuItem('rp_buffs', {
        label = 'RP buffs',
        icon = 'fas fa-bolt',
        priority = 10,
        onSelect = function(ctx)
            TriggerServerEvent('my_buffs:server:adminOpen', ctx.targetServerId)
        end,
    })
end)
```

### Custom ticket UI (main menu)

```lua
CreateThread(function()
    exports.qbx_adminmenu:RegisterTicketMenu('support_tickets', {
        label = 'Support tickets',
        description = 'Open external ticket list',
        onOpen = function()
            exports.my_tickets:OpenAdminPanel()
        end,
    })
end)
```

### Vehicle tool (vehicle menu)

```lua
CreateThread(function()
    exports.qbx_adminmenu:RegisterVehicleMenuItem('impound_tool', {
        label = 'Impound (custom)',
        onSelect = function(ctx)
            if not ctx.vehicle then
                lib.notify({ title = 'Admin', description = 'Not in a vehicle', type = 'error' })
                return
            end
            -- your logic
        end,
    })
end)
```

---

## Advanced: unified report list (not built in)

The built-in **Reports** menu uses the in-memory report list inside `qbx_adminmenu`. If you need a **single UI** fed by another backend, you can:

1. Use `RegisterTicketMenu` / `RegisterMainMenuItem` and open your own NUI or context UI, **or**
2. Implement your own list UI in your resource and only use this API for the entry point.

Pulling external report rows into the stock report UI would require additional shared contracts and is **not** part of the current API.

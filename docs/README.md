# qbx_adminmenu — extension API

This folder documents how **other FiveM resources** can add entries to the Qbox admin menu (`qbx_adminmenu`) without modifying this resource.

- **[API reference](./api.md)** — exports, parameters, and behaviour

## Requirements

- `qbx_adminmenu` must **start before** any resource that calls its exports (list it earlier in `server.cfg`), or declare `dependency 'qbx_adminmenu'` in the extending resource’s `fxmanifest.lua`.
- Extending resources run **client-side** registration (e.g. in `client/*.lua` after your resource starts).

## Quick example

```lua
-- client/my_extension.lua (your resource)
CreateThread(function()
    exports.qbx_adminmenu:RegisterPlayerMenuItem('my_stats', {
        label = 'My stats',
        description = 'Open custom character stats',
        icon = 'fas fa-chart-line',
        onSelect = function(ctx)
            print('Target server id:', ctx.targetServerId)
            -- Open your UI or trigger server events (secure them separately)
        end,
    })
end)
```

See [api.md](./api.md) for all menu types and the ticket helper.

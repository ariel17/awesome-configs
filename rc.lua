-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- {{ Function run_once.
-- Useful for autostart programs and reloading the wm.
function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    if not arg_string then 
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end
-- }}

-- {{ Function volume & registration
cardid  = 0
channel = "Master"
function volume (mode, widget)
    local cardid  = 0
    local channel = "Master"
    if mode == "update" then
        local status = io.popen("amixer -c " .. cardid .. " -- sget " .. channel):read("*all")
        
        local volume = tonumber(string.match(status, "(%d?%d?%d)%%"))

        status = string.match(status, "%[(o[^%]]*)%]")

        local color = "#FF0000"
        if string.find(status, "on", 1, true) then
             color = "#00FF00"
        end
        status = ""
        for i = 1, math.floor(volume / 10) do
            status = status .. "|"
        end
        for i = math.floor(volume / 10) + 1, 10 do
            status = status .. "-"
        end
        status = "-[" ..status .. "]+"
        widget.text = "" .. status .. "|"
    elseif mode == "up" then
        os.execute("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%+")
        volume("update", widget)
    elseif mode == "down" then
        os.execute("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%-")
        volume("update", widget)
    else
        os.execute("amixer -c " .. cardid .. " sset " .. channel .. " toggle")
        volume("update", widget)
    end
end

awful.hooks.timer.register(10, function () volume("update", tb_volume) end)
-- }}

-- {{ Function batteryInfo & registration
-- Returns a string with battery info
function batteryInfo(adapter)
    spacer = " "
    local fcur = io.open("/sys/class/power_supply/"..adapter.."/charge_now")    
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local cur = fcur:read()
    local cap = fcap:read()
    local sta = fsta:read()
    local battery = math.floor(cur * 100 / cap)
    if sta:match("Charging") then
        dir = "^"
        battery = "A/C ("..battery..")"
    elseif sta:match("Discharging") then
        dir = "v"
        if tonumber(battery) > 25 and tonumber(battery) < 75 then
            battery = battery
        elseif tonumber(battery) < 25 then
            if tonumber(battery) < 10 then
                naughty.notify({ title      = "Battery Warning"
                               , text       = "Battery low!"..spacer..battery.."%"..spacer.."left!"
                               , timeout    = 5
                               , position   = "top_right"
                               , fg         = beautiful.fg_focus
                               , bg         = beautiful.bg_focus
                               })
            end
            battery = battery
        else
            battery = battery
        end
    else
        dir = "="
        battery = "A/C"
    end
    batterywidget.text = spacer.."Bat:"..spacer..dir..battery..dir..spacer
    fcur:close()
    fcap:close()
    fsta:close()
end

awful.hooks.timer.register(5, function()
    batteryInfo("BAT0")
end)
-- }}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- Default: "/usr/share/awesome/themes/default/theme.lua"
beautiful.init("/etc/xdg/awesome/themes/ariel17/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "/usr/bin/x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- {{ Variables for Applications 
    terminator = "/usr/bin/terminator -m -b"
    chrome = "/usr/bin/google-chrome"
    calculator = "/usr/bin/gnome-calculator"
    chrome_mail = chrome .. " http://mail.google.com"
    nautilus = "/usr/bin/nautilus --no-desktop"
    gvim = "/usr/bin/gvim"
    pidgin = "/usr/bin/pidgin"
    skype = "/usr/bin/skype"
    clementine = "/usr/bin/clementine"
    qsynergy = "/usr/bin/quicksynergy"
    dropbox = "/usr/bin/dropbox"
    dropbox_start = dropbox .. " start"
-- }}

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
names = { "web", "bash", "code", "rdesk", "file", "im", "music", "misc", "fun" }
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(names, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e 'man awesome'" },
   -- { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "edit config", terminal .. " -e '" .. editor .. " /etc/xdg/awesome/rc.lua'" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    -- { "My Places", myplacesmenu.myplacesmenu.myplaces },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Volume widget
tb_volume = widget({ type = "textbox", name = "tb_volume", align = "right" })
tb_volume:buttons({
    button({ }, 4, function () volume("up", tb_volume) end),
    button({ }, 5, function () volume("down", tb_volume) end),
    button({ }, 1, function () volume("mute", tb_volume) end)
})
volume("update", tb_volume)

-- Create a systray
mysystray = widget({ type = "systray" })

-- the battery status widget
batterywidget = widget({type = "textbox", name = "batterywidget", align = "right" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright,
        },
        mylayoutbox[s],
        batterywidget,
        tb_volume,
        mytextclock,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- {{ Applications
        awful.key({}, "#79", function () awful.util.spawn(chrome) end),  -- XF86WWW
        awful.key({}, "#158", function () awful.util.spawn(chrome) end),  -- XF86WWW
        awful.key({}, "#180", function () awful.util.spawn(chrome) end),  -- XF86WWW
        awful.key({}, "#148", function () awful.util.spawn(calculator) end),  -- XF86Calculator
        awful.key({}, "#163", function () awful.util.spawn(chrome_mail) end),  -- XF86Mail
        awful.key({ modkey, }, "f", function () awful.util.spawn(nautilus) end),
        awful.key({ modkey, }, "g", function () awful.util.spawn(gvim) end),
        awful.key({ modkey, }, "p", function () awful.util.spawn(pidgin) end),
        awful.key({ modkey, }, "s", function () awful.util.spawn(skype) end),
        awful.key({ modkey, }, "c", function () awful.util.spawn(clementine) end),
    -- }}
    awful.key({ }, "#121", function () volume("mute", tb_volume) end),  -- XF86AudioMute 
    awful.key({ }, "#122", function () volume("down", tb_volume) end),  -- XF86AudioLowerVolume
    awful.key({ }, "#123", function () volume("up",   tb_volume) end),  -- XF86AudioRaiseVolume
    awful.key({ modkey, }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey, }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore),

    awful.key({ modkey, }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminator) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- tags number 1 - screen 1.
    { rule = { class = "Chromium" },
      properties = { tag = tags[1][1], maximized_vertical = true, maximized_horizontal = true } },
    { rule = { class = "Google" },                                                                      
      properties = { tag = tags[1][1], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 2 - screen 1.
    { rule = { class = "XTerm" },
      properties = { tag = tags[1][2], maximized_vertical = true, maximized_horizontal = true } },
    { rule = { class = "Terminator" },
      properties = { tag = tags[1][2], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 3 - screen 1.
    { rule = { class = "Gvim" },
      properties = { tag = tags[1][3], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 4 - screen 1.
    { rule = { class = "Remmina" },
      properties = { tag = tags[1][4], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 5 - screen 1.
    { rule = { class = "Nautilus" },
      properties = { tag = tags[1][5], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 6 - screen 1.
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][6], maximized_vertical = true, maximized_horizontal = true } },
    { rule = { class = "Skype" },
      properties = { tag = tags[1][6], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 7 - screen 1.
    { rule = { class = "Clementine" },            
      properties = { tag = tags[1][7], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 8 - screen 1.
    { rule = { class = "QuickSynergy" },            
      properties = { tag = tags[1][8], maximized_vertical = true, maximized_horizontal = true } },
    -- tags number 9 - screen 1.
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{ Autostart
-- Applications starting automatically at init. Examples:
-- run_once("xscreensaver","-no-splash")
-- run_once("pidgin",nil,nil,2)
-- run_once("wicd-client",nil,"/usr/bin/python2 -O /usr/share/wicd/gtk/wicd-client.py") 
run_once(dropbox_start)
run_once("/usr/bin/nm-applet")
run_once("/usr/bin/bluetooth-applet")
run_once(conky)
run_once(qsynergy)
-- }}

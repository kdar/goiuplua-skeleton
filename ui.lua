_G.callbacks = _G.callbacks or {}

require "iuplua"

module("ui", package.seeall)

-- Actions

function do_close()
  return iup.CLOSE
end

function do_gotest()
  gotest()
  return iup.DEFAULT
end

-- Callbacks

function _G.gotest_callback(text, err)
  if err ~= nil then
    iup.Message("Error", err)
  else
    iup.Message("Message", text)
  end
end


-- Menu

mmenu = {
  "File",{
    "Exit",do_close,
  }
}

function create_menu(templ)
  local items = {}
  for i = 1,#templ,2 do
    local label = templ[i]
    local data = templ[i+1]
    if type(data) == 'function' then
      item = iup.item{title = label}
      item.action = data
    elseif type(data) == 'nil' then
      item = iup.separator{}
    else
      item = iup.submenu{create_menu(data); title = label}
    end
    table.insert(items,item)
  end
  return iup.menu(items)
end

menu = create_menu(mmenu)

-- Body

btn = iup.button { title="Test", action=do_gotest }
vbox = iup.vbox { iup.label {title="Label"}, btn }
dlg = iup.dialog{vbox; title="Dialog", size="350x230", minsize="350x320" }
dlg:show()

-- our callback processor.
-- we do this because GUI draws can only
-- be done in the main thread. so when we call
-- a function in Go that needs to do a lot of processing,
-- it can do a goroutine and then add a callback later
-- once it's done.
timer = iup.timer{time=100}
function timer:action_cb()
  for k, v in pairs(_G.callbacks) do
    _G.callbacks[k] = nil 
    _G[k](unpack(luar.slice2table(v)))       
  end
  _G.callbacks = {}
end
timer.run = "YES"

if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end

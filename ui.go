package main

import (
  "github.com/kdar/goiuplua-skeleton/golua/lua"
  "github.com/kdar/goiuplua-skeleton/luar"
  "reflect"
  "time"
)

// Add a callback to the lua state. 
func addCallback(L *lua.State, name string, args []interface{}) {
  // We're going to be setting _G.callbacks
  L.GetGlobal("callbacks")
  // Convert our arguments to the Lua equivalent 
  luar.GoToLua(L, reflect.TypeOf(args), reflect.ValueOf(args))
  // Set _G.callbacks[name] to the above
  L.SetField(-2, name)
}

// Our test function that will be called from our Lua UI.
func Lgotest(L *lua.State) int {
  go func() {
    time.Sleep(time.Second * 2)
    var err error = nil
    args := []interface{}{"hello from go after 2 seconds", err}
    addCallback(L, "gotest_callback", args)
  }()

  return 0
}

func RunUI() {
  L := luar.Init()
  defer L.Close()

  // Register our function
  L.Register("gotest", Lgotest)

  // Run the Lua code.
  err := L.DoFile("ui.lua")
  if err != nil {
    panic(err)
  }
}

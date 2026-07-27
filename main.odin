package main

import "core:fmt"
import sdl "vendor:sdl3"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 1024
TILE_SIZE :: 64

Tower_type :: enum {
	ice,
	fire,
	lighting,
	wind,
	arrow,
	melee,
}

dmg_type :: enum {
	ice,
	fire,
	lighting,
	piecing,
	bashing,
}

Game_State :: struct {
	running:     bool,
	window:      ^sdl.Window,
	renderer:    ^sdl.Renderer,
	money:       int,
	list_tiles:  [dynamic][dynamic]^Tile,
	list_towers: [dynamic]^Tower,
}

Tile :: struct {
	rect:             ^sdl.FRect,
	coord:            [2]int,
	is_constructable: bool,
	is_path:          bool,
	is_hovered:       bool,
	is_selected:      bool,
}

Tower :: struct {
	type:                  ^Tower_type,
	damage_type:           ^dmg_type,
	secondary_damage_type: ^dmg_type,
	dmg:                   int,
	secondary_dmg:         int,
	reload_time:           int,
	is_selected:           bool,
	coord:                 [2]int,
	rect:                  ^sdl.FRect,
}

main :: proc() {
	if !sdl.Init({.VIDEO}) {
		fmt.println("Initializing sdl video failed: ", sdl.GetError())
		return
	}
	defer sdl.Quit()

	state := Game_State {
		running = true,
		money   = 100,
	}

	state.window = sdl.CreateWindow("Tower Defense Odin Style", SCREEN_WIDTH, SCREEN_HEIGHT, {})
	if state.window == nil {
		fmt.println("Error creating the game window: ", sdl.GetError())
		return
	}
	defer sdl.DestroyWindow(state.window)

	state.renderer = sdl.CreateRenderer(state.window, nil)
	if state.renderer == nil {
		fmt.println("Error creating the sdl rendrere: ", sdl.GetError())
		return
	}
	defer sdl.DestroyRenderer(state.renderer)

	vsync_ok := sdl.SetRenderVSync(state.renderer, 1)
	if !vsync_ok {
		fmt.println("Vsync failed")
		sdl.SetHint(sdl.HINT_RENDER_VSYNC, "1")
	}

	sdl.SetRenderDrawBlendMode(state.renderer, sdl.BLENDMODE_BLEND)
	defer all_cleanup(&state)

	for state.running {
		handle_events(&state)
		update(&state)
		render(&state)
	}
}

handle_events :: proc(state: ^Game_State) {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			state.running = false
		case .KEY_DOWN:
			if event.key.scancode == .ESCAPE do state.running = false
		case .MOUSE_MOTION:
		//state.mouse_coord[0] = event.motion.x
		//state.mouse_coord[1] = event.motion.y
		case .MOUSE_BUTTON_DOWN:
			if event.button.button == sdl.BUTTON_LEFT {
				fmt.println("Left click at: ", event.button.x, event.button.y)
			} else if event.button.button == sdl.BUTTON_RIGHT {
				fmt.println("Right click at: ", event.button.x, event.button.y)
			}
		case .MOUSE_BUTTON_UP:
			if event.button.button == sdl.BUTTON_LEFT {
				fmt.println("Left click released at: ", event.button.x, event.button.y)
			} else if event.button.button == sdl.BUTTON_RIGHT {
				fmt.println("Right click released at: ", event.button.x, event.button.y)
			}
		}
	}
}

update :: proc(state: ^Game_State) {

}

render :: proc(state: ^Game_State) {

}

all_cleanup :: proc(state: ^Game_State) {

}

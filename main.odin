package main

import "core:fmt"
import sdl "vendor:sdl3"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 1024
TILE_SIZE :: 80

tower_type :: enum {
	ice,
	fire,
	lighting,
	arrow,
}

dmg_type :: enum {
	ice,
	fire,
	lighting,
	piecing,
}

tile_type :: enum {
	path_1,
	path_2,
	path_3,
	path_4,
	path_5,
	path_6,
	path_7,
	water_1,
	rock_1,
	tree_1,
	grass_1,
	grass_2,
	grass_3,
	grass_4,
	dirt_1,
	start_1,
	end_1,
}

Game_State :: struct {
	running:                 bool,
	editor_mode:             bool,
	editor_mode_initialized: bool,
	game_mode_initialized:   bool,
	window:                  ^sdl.Window,
	renderer:                ^sdl.Renderer,
	money:                   int,
	list_tiles:              [dynamic]Tile,
	list_possible_towers:    [dynamic]Tower,
	list_towers:             [dynamic]Tower,
	selected_tile:           Tile,
	previous_selected_tile:  Tile,
	selected_tower:          Tower,
	level_playing:           int,
	width_right_panel:       int,
	texture_cache:           Texture_cache,
	texture_tower:           Texture_tower,
}

Texture_tower :: struct {
	texture: [tower_type]^sdl.Texture,
}

Texture_cache :: struct {
	texture: [tile_type]^sdl.Texture,
}

Tile :: struct {
	rect:             sdl.FRect,
	type:             tile_type,
	color:            sdl.Color,
	coord:            [2]int,
	is_constructable: bool,
	is_path:          bool,
	is_hovered:       bool,
	is_selected:      bool,
}

Tower :: struct {
	type:        tower_type,
	damage_type: dmg_type,
	dmg:         int,
	reload_time: int,
	range:       int,
	is_selected: bool,
	coord:       [2]int,
	rect:        sdl.FRect,
}

projectile :: struct {
	damage_type: ^dmg_type,
	dmg:         ^int,
	rect:        ^sdl.FRect,
	is_alive:    bool,
}

main :: proc() {
	if !sdl.Init({.VIDEO}) {
		fmt.println("Initializing sdl video failed: ", sdl.GetError())
		return
	}
	defer sdl.Quit()

	state := Game_State {
		running                 = true,
		editor_mode             = false,
		editor_mode_initialized = false,
		game_mode_initialized   = false,
		money                   = 100,
		level_playing           = 1,
		width_right_panel       = 300,
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
	//init_map(&state)

	for state.running {
		if state.editor_mode {
			if !state.editor_mode_initialized {
				init_create_map(&state)
				state.editor_mode_initialized = true
			}
			handle_events_editor(&state)
			update_editor(&state)
			render_editor(&state)
			continue
		} else if !state.game_mode_initialized {
			init_game_mode(&state)
			state.game_mode_initialized = true
		}
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
	sdl.SetRenderDrawColor(state.renderer, 20, 20, 20, 255)
	sdl.RenderClear(state.renderer)
	draw_map(state)
	draw_right_panel_towers(state)
	sdl.RenderPresent(state.renderer)
}

all_cleanup :: proc(state: ^Game_State) {
	delete(state.list_tiles)
	delete(state.list_towers)

	for texture in state.texture_cache.texture {
		sdl.DestroyTexture(texture)
	}
}

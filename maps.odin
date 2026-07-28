package main

import sdl "vendor:sdl3"

init_map :: proc(state: ^Game_State) {
	switch state.level_playing {
	case 1:
		init_map1(state)
	}
}

draw_map :: proc(state: ^Game_State) {
	for &tile in &state.list_tiles {
		#partial switch tile.type {
		case .water_1:
			sdl.SetRenderDrawColor(state.renderer, 20, 20, 200, 255)
		case .grass_1:
			sdl.SetRenderDrawColor(state.renderer, 34, 139, 34, 255)
		case .path_1:
			sdl.SetRenderDrawColor(state.renderer, 30, 30, 30, 255)
		}
		rect := tile.rect
		sdl.RenderFillRect(state.renderer, &rect)
	}
}

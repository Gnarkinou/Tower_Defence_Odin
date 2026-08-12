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
		if tile.rect.x + tile.rect.w >= SCREEN_WIDTH - f32(state.width_right_panel) || tile.rect.x < -tile.rect.w do continue
		if tile.rect.y < -tile.rect.h || tile.rect.y > SCREEN_HEIGHT - tile.rect.h do continue
		sdl.SetRenderDrawColor(
			state.renderer,
			tile.color[0],
			tile.color[1],
			tile.color[2],
			tile.color[3],
		)
		rect := tile.rect
		sdl.RenderFillRect(state.renderer, &rect)
	}
}

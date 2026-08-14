package main

import "core:fmt"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

init_map :: proc(state: ^Game_State) {
	switch state.level_playing {
	case 1:
		init_map1(state)
	}
}

init_load_tile_texture :: proc(state: ^Game_State) {
	for &tile in &list_all_possible_tiles {
		path: string
		#partial switch tile.type {
		case .path_1:
			path = "Sources/assets/grass/path_grass_horizontal_1.png"
		case .path_2:
			path = "Sources/assets/grass/path_grass_horizontal_2.png"
		case .path_3:
			path = "Sources/assets/grass/path_grass_vertical_1.png"
		case .path_4:
			path = "Sources/assets/grass/turn_grass_1.png"
		case .path_5:
			path = "Sources/assets/grass/turn_grass_2.png"
		case .path_6:
			path = "Sources/assets/grass/turn_grass_3.png"
		case .path_7:
			path = "Sources/assets/grass/turn_grass_4.png"
		case .tree_1:
			path = "Sources/assets/grass/tree_grass_1.png"
		case .rock_1:
			path = "Sources/assets/grass/rock_grass_1.png"
		case .start_1:
			path = "Sources/assets/grass/start_grass_1.png"
		case .end_1:
			path = "Sources/assets/grass/exit_grass_1.png"
		case .grass_1:
			path = "Sources/assets/grass/Grass_1.png"
		case .grass_2:
			path = "Sources/assets/grass/Grass_2.png"
		case .grass_3:
			path = "Sources/assets/grass/Grass_3.png"
		case .grass_4:
			path = "Sources/assets/grass/Grass_4.png"
		}

		c_path := strings.clone_to_cstring(path, context.temp_allocator)

		if len(c_path) == 0 || len(path) == 0 {
			fmt.println("Error loading the c_path of: ", tile.type)
			continue
		}

		surface := img.Load(c_path)
		if surface == nil {
			fmt.println("Failed to load the image: ", c_path, " error code: ", sdl.GetError())
			continue
		}
		defer sdl.DestroySurface(surface)

		texture := sdl.CreateTextureFromSurface(state.renderer, surface)
		if texture == nil {
			fmt.println("Error loading the texture: ", path, " with error: ", sdl.GetError())
			continue
		}

		sdl.SetTextureBlendMode(texture, {.BLEND})
		state.texture_cache.texture[tile.type] = texture
	}
}

draw_map :: proc(state: ^Game_State) {
	for &tile in &state.list_tiles {
		if tile.rect.x + tile.rect.w >= SCREEN_WIDTH - f32(state.width_right_panel) || tile.rect.x < -tile.rect.w do continue
		if tile.rect.y < -tile.rect.h || tile.rect.y > SCREEN_HEIGHT - tile.rect.h do continue

		rect := tile.rect
		texture := state.texture_cache.texture[tile.type]

		if texture != nil {
			sdl.RenderTexture(state.renderer, texture, nil, &rect)
		} else {
			sdl.SetRenderDrawColor(
				state.renderer,
				tile.color[0],
				tile.color[1],
				tile.color[2],
				tile.color[3],
			)
			sdl.RenderFillRect(state.renderer, &rect)
		}

		if tile.is_hovered {
			sdl.SetRenderDrawColor(state.renderer, 40, 40, 40, 150)
			sdl.RenderFillRect(state.renderer, &rect)
		}
	}
}

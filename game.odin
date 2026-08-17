package main

import "core:fmt"
import sdl "vendor:sdl3"

init_list_possible_towers :: proc(state: ^Game_State, panel: ^sdl.FRect) {
	if state.list_possible_towers == nil do state.list_possible_towers = make([dynamic]Tower, 0, len(tower_type))
	else do clear(&state.list_possible_towers)
	num_tower_w: int = int(panel.w / TILE_SIZE)
	num_tower_h: int = int(panel.h / TILE_SIZE)
	index_x: int = 0
	index_y: int = 0
	for i in 0 ..< len(tower_type) {
		tower := tower_type(i)
		if index_x >= num_tower_w {
			index_x = 0
			index_y += 1
		}
		t: Tower
		t.type = tower
		t.dmg = 10
		t.range = 2
		t.reload_time = 5
		t.is_selected = false

		#partial switch tower {
		case .ice:
			t.damage_type = .ice
			t.dmg = 8
		case .fire:
			t.damage_type = .fire
		case .lighting:
			t.damage_type = .lighting
			t.dmg = 7
			t.reload_time = 3
		case .arrow:
			t.damage_type = .piecing
		}
		rect := sdl.FRect {
			x = panel.x + f32(index_x) * TILE_SIZE,
			y = panel.y + f32(index_y) * TILE_SIZE,
			w = TILE_SIZE,
			h = TILE_SIZE,
		}

		t.rect = rect
		t.coord = {index_x, index_y}
		append(&state.list_possible_towers, t)
		fmt.println("Initiliazed the tower: ", t.type)
		index_x += 1
	}
}

init_game_mode :: proc(state: ^Game_State) {
	right_panel_rect := init_right_panel(state)
	if !load_level(state, current_level_file_path) {
		fmt.println("Error loading the map, exiting now...")
		state.running = false
		return
	}
	init_list_tiles(state)
	init_load_tile_texture(state)
	init_list_possible_towers(state, &right_panel_rect)
	init_load_texture_tower(state)
}

init_list_tiles :: proc(state: ^Game_State) {
	clear(&list_all_possible_tiles)
	seen_types: [len(tile_type)]bool = false
	for tile in state.list_tiles {
		type_index := int(tile.type)
		if !seen_types[type_index] {
			seen_types[type_index] = true
			append(&list_all_possible_tiles, tile)
		}
	}
}

draw_right_panel_towers :: proc(state: ^Game_State) {
	for &tower in &state.list_possible_towers {
		rect := tower.rect
		texture := state.texture_tower.texture[tower.type]
		if texture != nil {
			sdl.RenderTexture(state.renderer, texture, nil, &rect)
		} else {
			fmt.println("Error loading the texture for tower: ", tower.type)
		}

		if tower.is_selected {
			sdl.SetRenderDrawColor(state.renderer, 200, 20, 20, 100)
			sdl.RenderFillRect(state.renderer, &rect)
		}
	}
}

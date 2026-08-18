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
		t.cost = 100

		#partial switch tower {
		case .ice:
			t.damage_type = .ice
			t.dmg = 8
			t.cost = 110
		case .fire:
			t.damage_type = .fire
			t.cost = 120
		case .lighting:
			t.damage_type = .lighting
			t.dmg = 7
			t.reload_time = 3
			t.cost = 90
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
		fmt.println("Initiliazed the possible tower: ", t.type)
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
		if tower.is_hovered {
			sdl.SetRenderDrawColor(state.renderer, 40, 40, 40, 150)
			sdl.RenderFillRect(state.renderer, &rect)
		}
		if tower.is_selected {
			sdl.SetRenderDrawColor(state.renderer, 200, 20, 20, 100)
			sdl.RenderFillRect(state.renderer, &rect)
		}
	}
}

hovered_tile_game :: proc(state: ^Game_State, event: ^sdl.Event) {
	for &tower in state.list_towers {
		tower.is_hovered = false
	}
	for &tower in state.list_possible_towers {
		tower.is_hovered = false
	}
	for &tile in state.list_tiles {
		tile.is_hovered = false
	}

	if event.motion.x > SCREEN_WIDTH || event.motion.x < 0 do return
	if event.motion.y < 0 || event.motion.y > SCREEN_HEIGHT do return
	mouse_coord: [2]int
	if event.motion.x > SCREEN_WIDTH - f32(state.width_right_panel) {
		mouse_coord.y = int(event.button.y / TILE_SIZE)
		mouse_coord.x = int(
			(event.motion.x - SCREEN_WIDTH + f32(state.width_right_panel)) / TILE_SIZE,
		)
		for &tower in &state.list_possible_towers {
			if tower.coord != mouse_coord do continue
			tower.is_hovered = true
		}
	} else {
		mouse_coord.x = int(event.motion.x / TILE_SIZE)
		mouse_coord.y = int(event.button.y / TILE_SIZE)
		for &tile in state.list_tiles {
			if tile.coord != mouse_coord do continue
			tile.is_hovered = true
		}
	}
}

reset_selected_tower :: proc(state: ^Game_State) {
	for &tower in &state.list_towers {
		tower.is_selected = false
	}
	state.selected_tower = {}
}

reset_previously_selected_tower :: proc(state: ^Game_State) {
	for &tower in &state.list_possible_towers {
		tower.is_selected = false
	}
	state.previous_selected_tower = {}
}

clear_all_selected_towers_tiles :: proc(state: ^Game_State) {
	reset_selected_tower(state)
	reset_previously_selected_tower(state)
	clear_selected_tiles(state)
}

select_tile_game :: proc(state: ^Game_State, event: ^sdl.Event) {
	if event.button.x > SCREEN_WIDTH || event.button.x < 0 do return
	if event.button.y < 0 || event.button.y > SCREEN_HEIGHT do return

	// state.previous_selected_tile is for the right panel tile
	// state.selected_tile is for the map tile
	click_coord: [2]int

	if event.button.x > SCREEN_WIDTH - f32(state.width_right_panel) {
		reset_previously_selected_tower(state)
		click_coord.x = int(
			(event.button.x - f32(SCREEN_WIDTH) + f32(state.width_right_panel)) / TILE_SIZE,
		)
		click_coord.y = int(event.button.y / TILE_SIZE)
		fmt.println("Clicked on the right panel editor: ", click_coord)

		for &tower in &state.list_possible_towers {
			if tower.coord != click_coord do continue
			tower.is_selected = true
			state.previous_selected_tower = tower
			fmt.println("Selected the tower type: ", tower.type)
			return
		}
		fmt.println("The click on the Game Right Panel did not collide with a tile")
		return
	}
	reset_selected_tiles(state)
	reset_selected_tower(state)
	click_coord.x = int(event.button.x / TILE_SIZE)
	click_coord.y = int(event.button.y / TILE_SIZE)

	for &tile in &state.list_tiles {
		if tile.coord != click_coord do continue
		tile.is_selected = true
		if !tile.is_constructable {
			fmt.println("That tile is not consructable")
			return
		}
		// previous selected tower is for the right panel
		if state.previous_selected_tower != {} {
			t := new(Tower)
			t = &state.previous_selected_tower
			t.coord = tile.coord
			t.rect = tile.rect
			if state.money < t.cost {
				fmt.println("Not enought money !!")
				return
			}
			state.money -= t.cost
			fmt.println("Building a tower: ", t)
			append(&state.list_towers, t^)
		}
		state.selected_tile = tile
		fmt.println("The selected tile is: ", state.selected_tile)
		return
	}

	// This is for towers being selected on the map, not the right panel
	// This should come handy for upgrades later
	for &tower in state.list_towers {
		if tower.coord != click_coord do continue
		tower.is_selected = true
		state.selected_tower = tower
		fmt.println("The selected tower is: ", state.selected_tower)
		return
	}
}

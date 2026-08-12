package main

import "core:fmt"
import "core:mem"
import "core:os"
import sdl "vendor:sdl3"

list_all_possible_tiles: [dynamic]Tile
current_level_file_path: string = "Sources/maps/map1.save"

init_create_map :: proc(state: ^Game_State) {
	clear(&state.list_tiles)
	init_map1(state) // this is for testing
	clear(&list_all_possible_tiles)
	right_panel_rect := init_right_panel(state)
	fmt.println("The right panel rect is: ", right_panel_rect)
	init_all_possible_tiles(state, &right_panel_rect)
	fmt.println("The all possible tiles are: ", list_all_possible_tiles[:])
	if !load_level(state, current_level_file_path) {
		fmt.println("Error loading the map, exiting now...")
		state.running = false
		return
	}
}

init_right_panel :: proc(state: ^Game_State) -> sdl.FRect {
	editor_right_panel := sdl.FRect {
		w = f32(state.width_right_panel),
		h = SCREEN_HEIGHT,
		y = 0,
	}
	editor_right_panel.x = SCREEN_WIDTH - editor_right_panel.w
	return editor_right_panel
}

init_all_possible_tiles :: proc(state: ^Game_State, panel: ^sdl.FRect) {
	clear(&list_all_possible_tiles)
	num_tiles_w: int = int(panel.w / TILE_SIZE)
	num_tiles_h: int = int(panel.h / TILE_SIZE)
	fmt.println(
		"The max tiles display on the right panel is: ",
		num_tiles_w,
		" per height: ",
		num_tiles_h,
	)
	index: int = 0
	index_y: int = 0

	for tile in tile_type {
		fmt.println("handling the creation of tile type: ", tile)
		if int(index) >= num_tiles_w {
			index = 0
			index_y += 1
		}
		t := new(Tile)
		t.is_constructable = true
		t.is_path = false

		#partial switch tile {
		case .water_1:
			t.color = {20, 20, 200, 255}
			t.is_constructable = false
		case .grass_1:
			t.color = {34, 250, 34, 255}
		case .path_1:
			t.color = {30, 30, 30, 255}
			t.is_path = true
		case .rock_1:
			t.color = {200, 200, 200, 255}
			t.is_constructable = false
		case .tree_1:
			t.color = {2, 255, 40, 255}
			t.is_constructable = false
		case .dirt_1:
			t.color = {128, 128, 128, 255}
		case .start_1:
			t.color = {0, 0, 0, 255}
			t.is_path = true
			t.is_constructable = false
		case .end_1:
			t.color = {255, 0, 0, 255}
			t.is_path = true
			t.is_constructable = false
		}

		rect := sdl.FRect {
			x = panel.x + f32(index) * TILE_SIZE,
			y = panel.y + f32(index_y) * TILE_SIZE,
			w = TILE_SIZE,
			h = TILE_SIZE,
		}
		//fmt.println("The rect x is: ", rect.x)
		//fmt.println("The mini should be: ", SCREEN_WIDTH - state.width_right_panel)
		t.type = tile
		t.rect = rect
		t.coord = {index, index_y}
		append(&list_all_possible_tiles, t^)
		index += 1
	}
}

handle_events_editor :: proc(state: ^Game_State) {
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
				clear_selected_tiles(state)
			}
		case .MOUSE_BUTTON_UP:
			if event.button.button == sdl.BUTTON_LEFT {
				fmt.println("Left click released at: ", event.button.x, event.button.y)
				select_tile_editor(state, &event)
			} else if event.button.button == sdl.BUTTON_RIGHT {
				fmt.println("Right click released at: ", event.button.x, event.button.y)
			}
		}
	}
}

update_editor :: proc(state: ^Game_State) {

}

draw_right_panel :: proc(state: ^Game_State) {
	for item in list_all_possible_tiles {
		rect := item.rect
		sdl.SetRenderDrawColor(
			state.renderer,
			item.color[0],
			item.color[1],
			item.color[2],
			item.color[3],
		)
		sdl.RenderFillRect(state.renderer, &rect)
	}
}

render_editor :: proc(state: ^Game_State) {
	sdl.SetRenderDrawColor(state.renderer, 20, 20, 20, 255)
	sdl.RenderClear(state.renderer)
	draw_map(state)
	draw_right_panel(state)
	sdl.RenderPresent(state.renderer)
}

select_tile_editor :: proc(state: ^Game_State, event: ^sdl.Event) {
	if event.button.x > SCREEN_WIDTH || event.button.x < 0 do return
	if event.button.y < 0 || event.button.y > SCREEN_HEIGHT do return

	// state.previous_selected_tile is for the right panel tile
	// state.selected_tile is for the map tile
	click_coord: [2]int

	if event.button.x > SCREEN_WIDTH - f32(state.width_right_panel) {
		click_coord.x = int(
			(event.button.x - f32(SCREEN_WIDTH) + f32(state.width_right_panel)) / TILE_SIZE,
		)
		click_coord.y = int(event.button.y / TILE_SIZE)
		fmt.println("Clicked on the tile editor: ", click_coord)

		for tile in &list_all_possible_tiles {
			if tile.coord != click_coord do continue
			state.previous_selected_tile = tile
			fmt.println("Selected the tile type: ", tile.type)
			return
		}
		return
	}

	click_coord.x = int(event.button.x / TILE_SIZE)
	click_coord.y = int(event.button.y / TILE_SIZE)
	for &tile in state.list_tiles {
		if tile.coord != click_coord do continue
		if state.previous_selected_tile != {} {
			state.selected_tile = state.previous_selected_tile
			state.selected_tile.coord = tile.coord
			state.selected_tile.rect = tile.rect
			fmt.println("The selected tile is: ", state.selected_tile)
			tile = state.selected_tile
			if !save_level(state, current_level_file_path) {
				fmt.println("Error during saving process, quitting now...")
				state.running = false
				return
			}
			return
		}
		state.selected_tile = tile
		fmt.println("The selected tile is: ", state.selected_tile)
		if !save_level(state, current_level_file_path) {
			fmt.println("Error during saving process, quitting now...")
			state.running = false
			return
		}
		return
	}
}

clear_selected_tiles :: proc(state: ^Game_State) {
	state.selected_tile = {}
	state.previous_selected_tile = {}
}

save_level :: proc(state: ^Game_State, filepath: string) -> bool {
	bytes := mem.slice_to_bytes(state.list_tiles[:])
	err := os.write_entire_file(filepath, bytes)
	fmt.println("The path is: ", filepath)
	if err != nil {
		fmt.println("Error saving level: ", err)
		return false
	}
	return true
}

load_level :: proc(state: ^Game_State, filepath: string) -> bool {
	data, err := os.read_entire_file(filepath, context.allocator)
	if err != nil {
		fmt.println("Error loading the map level: ", err)
		return false
	}
	defer delete(data)

	if len(data) % size_of(Tile) != 0 {
		fmt.println("Corrupted file: size issue when loading")
		return false
	}
	loaded_tiles := mem.slice_data_cast([]Tile, data)
	clear(&state.list_tiles)
	append(&state.list_tiles, ..loaded_tiles)
	return true
}

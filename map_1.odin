package main

import "core:fmt"

init_map1 :: proc(state: ^Game_State) {
	fmt.println("Creating map 1")
	clear(&state.list_tiles)
	num_tile_x: int = SCREEN_WIDTH / TILE_SIZE
	num_tile_y: int = SCREEN_HEIGHT / TILE_SIZE

	reserve(&state.list_tiles, num_tile_x * num_tile_y)
	for i := 0; i < num_tile_x; i += 1 {
		for j := 0; j < num_tile_y; j += 1 {
			t: Tile
			t.rect.x = f32(i) * TILE_SIZE
			t.rect.y = f32(j) * TILE_SIZE
			t.rect.w = TILE_SIZE
			t.rect.h = TILE_SIZE
			t.is_constructable = true
			t.is_hovered = false
			t.is_path = false
			t.type = .grass_1
			t.color = {34, 139, 34, 255}
			t.coord = {i, j}
			append(&state.list_tiles, t)
		}
	}
	save_level(state, current_level_file_path)
	fmt.println("Create map 1 is done")
}

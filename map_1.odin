package main

init_map1 :: proc(state: ^Game_State) {
	clear(&state.list_tiles)
	num_tile_x: int = SCREEN_WIDTH / TILE_SIZE
	num_tile_y: int = SCREEN_HEIGHT / TILE_SIZE

	reserve(&state.list_tiles, num_tile_x * num_tile_y)
	for i := 0; i < num_tile_x; i += 1 {
		for j := 0; j < num_tile_y; j += 1 {
			if i == 6 {
				t: Tile
				t.rect.x = f32(i) * TILE_SIZE
				t.rect.y = f32(j) * TILE_SIZE
				t.rect.w = TILE_SIZE
				t.rect.h = TILE_SIZE
				t.is_constructable = true
				t.is_hovered = false
				t.is_path = true
				t.type = .path_1
				t.color = {30, 30, 30, 255}
				t.coord = {i, j}
				append(&state.list_tiles, t)
				continue
			}
			if j == 4 {
				t: Tile
				t.rect.x = f32(i) * TILE_SIZE
				t.rect.y = f32(j) * TILE_SIZE
				t.rect.w = TILE_SIZE
				t.rect.h = TILE_SIZE
				t.is_constructable = true
				t.is_hovered = false
				t.is_path = false
				t.type = .water_1
				t.color = {20, 20, 200, 255}
				t.coord = {i, j}
				append(&state.list_tiles, t)
				continue
			}

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
	//save_level(state, current_level_file_path)
}

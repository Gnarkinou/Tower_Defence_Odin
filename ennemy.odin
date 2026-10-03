#+feature dynamic-literals
package main

import "core:fmt"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

ennemy_type :: enum {
	ork_1,
	//wolf_1,
	//armor_ork_1,
	//zombie_1,
}

init_load_texture_enemies :: proc(state: ^Game_State) {
	for enemy_type_item in state.list_possible_enemies {
		number_frames: u8
		switch enemy_type_item {
		case .ork_1:
			number_frames = 10
			for i in 0 ..< number_frames {
				path := fmt.tprintf("Sources/assets/enemies/orcs/orcs1/ORK_01_WALK_%03d.png", i)
				c_path := strings.clone_to_cstring(path, context.temp_allocator)
				surface := img.Load(c_path)
				if surface == nil {
					fmt.println(
						"Failed to load image: ",
						path,
						" for ennemy: ",
						enemy_type_item,
						" error: ",
						sdl.GetError(),
					)
					continue
				}
				defer sdl.DestroySurface(surface)
				texture := sdl.CreateTextureFromSurface(state.renderer, surface)
				if texture == nil {
					fmt.println("Failed to create texture for ennemy spawn: ", sdl.GetError())
					continue
				}
				if !sdl.SetTextureBlendMode(texture, sdl.BLENDMODE_BLEND) {
					fmt.println("Failed to set texture blend mode: ", sdl.GetError())
				}
				state.texture_enemy.textures[.ork_1][.walk][i] = texture
			}
		}
	}
}

init_enemies :: proc(state: ^Game_State) {
	clear(&state.list_possible_enemies)
	switch state.level_playing {
	case 1:
		append(&state.list_possible_enemies, ennemy_type.ork_1)
	}

	init_load_texture_enemies(state)
}

generate_ennemy :: proc(state: ^Game_State) {
	switch state.level_playing {
	case 1:
		if !state.running || !state.is_start || state.is_pause do return
		state.ennemy_delta_time += 1
		if state.ennemy_delta_time < 60 do return
		fmt.printf("Placeholder -- Generating ennemies for level %v now\n", state.level_playing)
		enemy := new(Ennemy)
		for tile in state.list_tiles {
			#partial switch tile.type {
			case .start_1:
				enemy.coord = tile.coord
				enemy.previous_coord = tile.coord
				enemy.rect.x = tile.rect.x + TILE_SIZE / 2
				enemy.rect.y = tile.rect.y + TILE_SIZE / 2
				path_next_tile(state, enemy)
			}
		}
		state.ennemy_delta_time = 0
	}
}

draw_enemies :: proc(state: ^Game_State) {

}

update_enemies :: proc(state: ^Game_State) {
	for &enemy in state.list_enemies {
		#partial switch enemy.direction {
		case .up:
			enemy.coord.y -= enemy.speed
		case .down:
			enemy.coord.y += enemy.speed
		case .right:
			enemy.coord.x += enemy.speed
		case .left:
			enemy.coord.y -= enemy.speed
		}

		// Need to check when we reach the end of the tile to get the next future one
		// Then need to check for the end_tiles stuff
	}
}

path_next_tile :: proc(state: ^Game_State, enemy: ^Ennemy) {
	for tile in state.list_tiles {
		if tile.coord.x != enemy.coord.x - 1 && tile.coord.x != enemy.coord.x + 1 && tile.coord.x != enemy.coord.x do continue
		if tile.coord.y != enemy.coord.y - 1 && tile.coord.y != enemy.coord.y + 1 && tile.coord.y != enemy.coord.y do continue
		if tile.coord == enemy.coord || tile.coord == enemy.previous_coord do continue
		if !tile.is_path do continue

		if enemy.future_coord != {} do enemy.coord = enemy.future_coord
		enemy.previous_coord = enemy.coord
		enemy.future_coord = tile.coord

		if tile.type == .end_1 do enemy.is_end_tile = true

		if enemy.future_coord.x > enemy.coord.x do enemy.direction = .right
		else if enemy.future_coord.x < enemy.coord.x do enemy.direction = .left
		else if enemy.future_coord.y > enemy.coord.y do enemy.direction = .down
		else if enemy.future_coord.y > enemy.coord.y do enemy.direction = .up
		fmt.printf("The enemy %s should go %s \n", enemy.type, enemy.direction)
		return
	}
}

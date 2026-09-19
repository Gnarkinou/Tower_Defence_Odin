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
		switch enemy_type_item {
		case .ork_1:
			for i in 0 ..< 10 {
				path := fmt.tprintf("Sources/assets/enemies/orcs/orcs1/ORK_01_WALK_%03d.png", i)
				c_path := strings.clone_to_cstring(path, context.temp_allocator)
				surface := img.Load(c_path)
				if surface == nil {
					fmt.println("Failed to load image: ", path, " error: ", sdl.GetError())
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
		if !state.running || !state.start do return
		state.ennemy_delta_time += 1
		if state.ennemy_delta_time < 60 do return
		fmt.printf("Generating ennemies for level %v now\n", state.level_playing)
		state.ennemy_delta_time = 0
	}
}

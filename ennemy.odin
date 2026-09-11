package main

import "core:fmt"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

ennemy_type :: enum {
	ork_1,
	wolf_1,
	armor_ork_1,
	zombie_1,
}

init_enemies :: proc(state: ^Game_State) {

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

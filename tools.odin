package main

import "core:fmt"
import "core:math"
import sdl "vendor:sdl3"

create_circle_tower :: proc(state: ^Game_State) {
	if state.selected_tower == {} do return
	if state.selected_tower.points != {} do state.selected_tower.points = {}
	fmt.println("Creating t epoints for the circle")

	center_x := state.selected_tower.rect.x + (state.selected_tower.rect.w * 0.5)
	center_y := state.selected_tower.rect.y + (state.selected_tower.rect.h * 0.5)
	radius := f32(state.selected_tower.range) * TILE_SIZE
	fmt.println("The coords are: ", center_x, center_y, radius)

	for i in 0 ..= SEGMENTS {
		angle := 2.0 * math.PI * f32(i) / f32(SEGMENTS)
		state.selected_tower.points[i] = sdl.FPoint {
			center_x + radius * math.cos(angle),
			center_y + radius * math.sin(angle),
		}
	}
	fmt.println("The result is: ", state.selected_tower.points)
}

draw_circle_tower :: proc(state: ^Game_State) {
	sdl.SetRenderDrawColor(state.renderer, 255, 255, 255, 255)

	sdl.RenderLines(
		state.renderer,
		raw_data(state.selected_tower.points[:]),
		i32(len(state.selected_tower.points)),
	)
}

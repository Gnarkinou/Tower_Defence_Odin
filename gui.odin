package main

import "core:fmt"
import "core:strings"
import sdl "vendor:sdl3"
import ttf "vendor:sdl3/ttf"

init_gui :: proc(state: ^Game_State) -> bool {
	if !ttf.Init() {
		fmt.println("Error initializing the font: ", sdl.GetError())
		return false
	}
	state.font = ttf.OpenFont("Sources/MotionControl-Bold.otf", 32)
	if state.font == nil {
		fmt.println("Failed to load the font ", sdl.GetError())
		return false
	}

	init_player_name_gui(state)
	return true
}

init_player_name_gui :: proc(state: ^Game_State) {
	if len(state.player_name_gui.player_name) == 0 {
		fmt.println("Error with the lenght od the player name (0): ", sdl.GetError())
		return
	}

	color := sdl.Color{255, 255, 255, 255}
	name_to_display := fmt.tprintf("%s -> %d €$", state.player_name_gui.player_name, state.money)
	c_string := strings.clone_to_cstring(name_to_display, context.temp_allocator)
	if len(c_string) <= 0 {
		fmt.println("Error loading init player name gui c_string: ", sdl.GetError())
		return
	}
	surface := ttf.RenderText_Blended(state.font, c_string, 0, color)
	if surface == nil {
		fmt.println("Error loading the surface for the init_player_name: ", sdl.GetError())
		return
	}
	defer sdl.DestroySurface(surface)

	texture := sdl.CreateTextureFromSurface(state.renderer, surface)
	if texture == nil {
		fmt.println("Error loading the texture for the init_player_name: ", sdl.GetError())
		return
	}

	if state.player_name_gui.texture != nil do sdl.DestroyTexture(state.player_name_gui.texture)
	state.player_name_gui.texture = texture

	state.player_name_gui.rect.w = f32(surface.w)
	state.player_name_gui.rect.h = f32(surface.h)
	state.player_name_gui.rect.x = f32(SCREEN_WIDTH - state.width_right_panel)
	state.player_name_gui.rect.y = f32(state.height_right_panel_towers + 10)

	/*
	state.player_name_gui.rect.x = f32(SCREEN_WIDTH - state.width_right_panel)
	state.player_name_gui.rect.y = f32(state.height_right_panel_towers + 10)
	state.player_name_gui.rect.w = f32(state.width_right_panel)
	//state.player_name_gui.rect.h = f32(SCREEN_HEIGHT - state.height_right_panel_towers)
	state.player_name_gui.rect.h = 40
	*/
}

cleanup_gui :: proc(state: ^Game_State) {
	if state.font != nil do ttf.CloseFont(state.font)
	ttf.Quit()
}

display_gui :: proc(state: ^Game_State) {
	display_player_name(state)
}

display_player_name :: proc(state: ^Game_State) {
	sdl.RenderTexture(
		state.renderer,
		state.player_name_gui.texture,
		nil,
		&state.player_name_gui.rect,
	)
}

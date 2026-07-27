package main

import "core:fmt"
import sdl "vendor:sdl3"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 1024
TILE_SIZE :: 64

Tower_type :: enum {
	ice,
	fire,
	lighting,
	wind,
	arrow,
	melee,
}

dmg_type :: enum {
	ice,
	fire,
	lighting,
	piecing,
	bashing,
}

Game_State :: struct {
	running:     bool,
	window:      ^sdl.Window,
	rendered:    ^sdl.Renderer,
	money:       int,
	list_tiles:  [dynamic][dynamic]^Tile,
	list_towers: [dynamic]^Tower,
}

Tile :: struct {
	rect:             ^sdl.FRect,
	is_constructable: bool,
	is_path:          bool,
	is_hovered:       bool,
	is_selected:      bool,
}

Tower :: struct {
	type:                  ^Tower_type,
	damage_type:           ^dmg_type,
	secondary_damage_type: ^dmg_type,
	dmg:                   int,
	secondary_dmg:         int,
	reload_time:           int,
	is_selected:           bool,
	coord:                 [2]int,
	rect:                  ^sdl.FRect,
}

main :: proc() {

}

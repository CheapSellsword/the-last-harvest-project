class_name IsometricUtils
extends RefCounted

# Tile Dimensions (half-width and half-height for isometric)
const TILE_WIDTH = 32.0
const TILE_HEIGHT = 16.0

## Converts a World Position (Pixels) to Isometric Grid Coordinates
static func world_to_grid(world_pos: Vector2) -> Vector2i:
	var x = int(world_pos.x / TILE_WIDTH + world_pos.y / TILE_HEIGHT)
	var y = int(world_pos.y / TILE_HEIGHT - world_pos.x / TILE_WIDTH)
	return Vector2i(x, y)

## Converts Isometric Grid Coordinates to World Position (Pixels)
## (Useful if you need to snap an object to the center of a tile)
static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var x = (grid_pos.x - grid_pos.y) * (TILE_WIDTH * 0.5)
	var y = (grid_pos.x + grid_pos.y) * (TILE_HEIGHT * 0.5)
	return Vector2(x, y)

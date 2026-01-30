# world_system.gd
# Handles world tile *data*. The Simulation for the farm.

class_name WorldSystem
extends RefCounted

# --- Signals ---
signal tile_changed(map_coords: Vector2i, new_data: WorldTileData)
signal tile_cleared(map_coords: Vector2i)

# --- State ---
var _tile_data: Dictionary = {}

# --- Public API ---

func get_tile_data(map_coords: Vector2i) -> WorldTileData:
	if _tile_data.has(map_coords):
		return _tile_data[map_coords]
	return null

## Tills a tile at the given coordinates.
## Returns true if successful.
func till_tile(map_coords: Vector2i) -> bool:
	var data = get_tile_data(map_coords)
	
	# If no data exists, create new data for this tile
	if data == null:
		data = WorldTileData.new()
		_tile_data[map_coords] = data
	
	# If already tilled, do nothing
	if data.is_tilled:
		return false
		
	# Apply changes
	data.is_tilled = true
	
	# Notify View
	tile_changed.emit(map_coords, data)
	return true

func clear_tile_data(map_coords: Vector2i):
	if _tile_data.has(map_coords):
		_tile_data.erase(map_coords)
		tile_cleared.emit(map_coords)

func on_day_passed(_day: int, _season: int):
	# Simple logic: Un-water soil overnight
	for coords in _tile_data:
		var data: WorldTileData = _tile_data[coords]
		if data.is_watered:
			data.is_watered = false
			tile_changed.emit(coords, data)

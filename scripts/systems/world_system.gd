# world_system.gd
# A modular, non-node class for handling world tile *data*.
# This is the "Simulation" for the farm. The View (TileMapLayer) reads this.
# It is instantiated and "ticked" by the SimulationManager.

class_name WorldSystem
extends RefCounted

# --- Signals ---
# The View (TileMap/TileMapLayer) will connect to these to update visuals.
signal tile_changed(map_coords: Vector2i, new_data: WorldTileData)
signal tile_cleared(map_coords: Vector2i)

# --- State ---
# We only store data for tiles that are *not* in their default state.
# Key: Vector2i (map coordinates)
# Value: WorldTileData (resource)
var _tile_data: Dictionary = {}

# --- Public API ---

## Gets the data for a tile. If it doesn't exist, it's a "default" tile.
func get_tile_data(map_coords: Vector2i) -> WorldTileData:
	if _tile_data.has(map_coords):
		return _tile_data[map_coords]
	return null # This tile is default (e.g., grass)

## Clears data for a tile, returning it to default (e.g., grass).
func clear_tile_data(map_coords: Vector2i):
	if _tile_data.has(map_coords):
		_tile_data.erase(map_coords)
		# Tell the "View" to revert this tile
		tile_cleared.emit(map_coords)

## This would be called by the TimeSystem's "day_passed" signal.
func on_day_passed(_day: int, _season: int):
	print("WorldSystem: Processing end-of-day logic...")
	# Loop through all our data
	for coords in _tile_data:
		var data: WorldTileData = _tile_data[coords]
		
		# 2. Grow crops (if watered)
		if data.crop_definition_id != &"":
			# Add growth logic here later
			pass
		
		# 3. Emit a change signal so the view updates
		tile_changed.emit(coords, data)

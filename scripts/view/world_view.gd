# world_view.gd
# Attached to the Game root node.
# This is purely "View" code. It listens to the Simulation and paints tiles.

extends Node2D

## The TileMapLayer we want to paint on (drag your "Ground" layer here).
@export var active_layer: TileMapLayer

# We need to map our Simulation data (state) to View data (Atlas Coords).
# In a real project, you'd put this in a nice Resource lookup table.
# For now, let's hardcode: Tilled Dirt = Atlas Coords (1, 0)
const TILE_GRASS_COORDS = Vector2i(0, 0) # Assuming 0,0 is grass
const TILE_TILLED_COORDS = Vector2i(4, 0) # Assuming 4,0 is tilled dirt (adjust based on your spritesheet)

func _ready():
	if !active_layer:
		printerr("WorldView: No active TileMapLayer assigned!")
		return
	
	# --- THE GLUE ---
	# Connect to the WorldSystem signals.
	# Note: We access it via the SimulationManager singleton.
	var world_sys = SimulationManager.get_world_system()
	if world_sys:
		world_sys.tile_changed.connect(_on_tile_changed)
		world_sys.tile_cleared.connect(_on_tile_cleared)

# --- Signal Handlers ---

func _on_tile_changed(map_coords: Vector2i, data: WorldTileData):
	# The Simulation told us a tile changed. We just check the state and paint.
	if data.is_tilled:
		_paint_tile(map_coords, TILE_TILLED_COORDS)
	
	# Later: Add logic for watered soil, crops, etc.
	# if data.is_watered: ...

func _on_tile_cleared(map_coords: Vector2i):
	# Revert to default (grass)
	_paint_tile(map_coords, TILE_GRASS_COORDS)

func _paint_tile(map_coords: Vector2i, atlas_coords: Vector2i):
	# Use source_id 0 (assuming your tileset is source 0)
	active_layer.set_cell(map_coords, 0, atlas_coords)

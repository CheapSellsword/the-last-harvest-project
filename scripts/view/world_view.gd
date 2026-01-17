# world_view.gd
# Attached to the Game root node.
# This is purely "View" code. It listens to the Simulation and paints tiles.

extends Node2D

## The TileMapLayer we want to paint on (drag your "Ground" layer here).
@export var active_layer: TileMapLayer

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
	# The Simulation told us a tile changed.
	# Tilling visualization removed.
	
	# Future implementation:
	# if data.crop_definition_id != &"": ...
	pass

func _on_tile_cleared(map_coords: Vector2i):
	# Revert to default (grass)
	_paint_tile(map_coords, GameConsts.ATLAS_COORDS_GRASS)

func _paint_tile(map_coords: Vector2i, atlas_coords: Vector2i):
	# Use source_id 0 (assuming your tileset is source 0)
	active_layer.set_cell(map_coords, 0, atlas_coords)

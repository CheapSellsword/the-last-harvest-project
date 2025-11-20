# world_tile_data.gd
# This is a DATA TEMPLATE for the *simulation state* of a single tile.
# We don't store "grass", only tiles that have been changed.

@tool
class_name WorldTileData
extends Resource

## Is this patch of ground tilled?
@export var is_tilled: bool = false

## Is this patch of ground watered? (We'd reset this daily)
@export var is_watered: bool = false

## What crop is planted here?
@export var crop_definition_id: StringName = &""

## How many days has this crop been growing?
@export var crop_growth_days: int = 0

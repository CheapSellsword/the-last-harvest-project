# game_consts.gd
# A place for global constants to avoid hardcoding "Magic Numbers" in systems.
extends Node

# --- Visual Definitions ---
# These map logical states to visual coordinates on the TileSet/SpriteSheet.
const ATLAS_COORDS_GRASS = Vector2i(0, 0)
const ATLAS_COORDS_TILLED = Vector2i(4, 0)
const ATLAS_COORDS_WATERED = Vector2i(5, 0) # Example for future

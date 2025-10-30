# item_database.gd
# AUTOLOAD SINGLETON
# This "database" loads all ItemDefinition .tres files from a folder
# on startup and stores them in a dictionary for fast lookup.

extends Node

# We'll store items as { "item_id": ItemDefinitionResource }
var _items: Dictionary = {}

const ITEM_DATA_PATH = "res://data/items"

func _ready():
	_load_all_items()

func _load_all_items():
	print("ItemDatabase: Loading items...")
	var dir = DirAccess.open(ITEM_DATA_PATH)
	if !dir:
		printerr("ItemDatabase: Failed to open path: %s" % ITEM_DATA_PATH)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		# We only care about .tres files (which are our item resources)
		if !dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource_path = "%s/%s" % [ITEM_DATA_PATH, file_name]
			var item_def = load(resource_path) as ItemDefinition
			
			if item_def:
				if _items.has(item_def.id):
					printerr("ItemDatabase: Duplicate ID found! '%s'" % item_def.id)
				else:
					_items[item_def.id] = item_def
					# print("Loaded item: %s" % item_def.id) # Uncomment for debugging
			else:
				printerr("ItemDatabase: Failed to load resource at: %s" % resource_path)
				
		file_name = dir.get_next()
	
	print("ItemDatabase: Loaded %s items." % _items.size())

## Public function to get item data from anywhere in the code.
## Returns: ItemDefinition resource, or null if not found.
func get_item(item_id: StringName) -> ItemDefinition:
	if _items.has(item_id):
		return _items[item_id]
	
	printerr("ItemDatabase: Item with ID '%s' not found." % item_id)
	return null

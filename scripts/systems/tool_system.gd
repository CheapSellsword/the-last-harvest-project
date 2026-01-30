# tool_system.gd
# Handles the logic of using specific tools on specific targets.
class_name ToolSystem
extends RefCounted

func use_tool(tool_def: ToolItemDefinition, target_grid_pos: Vector2i, world_sys: WorldSystem, stats_sys: StatsSystem) -> bool:
	if not tool_def:
		return false
		
	# Check stamina
	if stats_sys.current_stamina < tool_def.stamina_cost:
		print("ToolSystem: Not enough stamina!")
		return false

	var success = false
	
	# Route logic based on tool type
	match tool_def.tool_type:
		"hoe":
			success = _use_hoe(target_grid_pos, world_sys)
		"axe":
			pass # Future
		"pickaxe":
			pass # Future
		"watering_can":
			pass # Future
			
	if success:
		stats_sys.consume_stamina(tool_def.stamina_cost)
		print("ToolSystem: Used %s at %s" % [tool_def.display_name, target_grid_pos])
		
	return success

func _use_hoe(grid_pos: Vector2i, world_sys: WorldSystem) -> bool:
	# In a real game, you might check if the tile is "Tillable" (valid ground layer)
	# For now, we assume any valid map coord can be tilled.
	return world_sys.till_tile(grid_pos)

# tool_item_definition.gd
# This extends the base ItemDefinition to add tool-specific data.
@tool
class_name ToolItemDefinition
extends ItemDefinition

enum ToolType {
	HOE,
	PICKAXE,
	AXE,
	WATERING_CAN,
	SWORD
}

## What kind of tool is this? Used by the system to determine behavior (tilling, mining, etc).
@export var tool_type: ToolType = ToolType.HOE

## (Optional) How much stamina using this tool consumes.
@export var stamina_cost: float = 2.0

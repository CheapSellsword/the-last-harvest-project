class_name InventorySlotView
extends PanelContainer

# --- Nodes ---
# We will assign these in the scene later
@onready var icon_texture: TextureRect = $MarginContainer/IconTexture
@onready var quantity_label: Label = $QuantityLabel

## Updates the visuals of this specific slot based on the data provided.
func update_slot(slot_data: InventorySlot):
	if !icon_texture or !quantity_label:
		return

	if slot_data and not slot_data.is_empty():
		icon_texture.texture = slot_data.item.icon
		icon_texture.visible = true
		
		# Only show quantity if greater than 1
		if slot_data.quantity > 1:
			quantity_label.text = str(slot_data.quantity)
		else:
			quantity_label.text = ""
	else:
		icon_texture.texture = null
		icon_texture.visible = false
		quantity_label.text = ""

extends HBoxContainer

@onready var slots: Array = get_children()
var character: Character
var highlight_index: int = -1

## initialize the inventory bar on the bottom according to what the character has
func set_character(a_character: Character) -> void:
	character = a_character
	
	for i in range(character.inventory.TRAY_SIZE):
		if character.inventory.items[i]!=null:
			slots[i].find_child("Icon").texture = character.inventory.items[i].inventory_icon

func _process(_delta: float) -> void:
	# swap the highlighted portion of the HUD
	if highlight_index!=character.equipment_index:
		if highlight_index!=-1:
			slots[highlight_index].self_modulate = Color.WHITE
			
		highlight_index = character.equipment_index
		slots[highlight_index].self_modulate = Color.RED

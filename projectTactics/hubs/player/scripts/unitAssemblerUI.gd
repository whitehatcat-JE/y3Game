extends Control

signal unitAssemblyComplete

enum ItemTypes {
	ALL,
	PART,
	UNIT,
	FISH
}

enum PartTypes {
	ARM,
	LEG,
	CHEST,
	CORE,
	HEAD
}

var listedParts:Array = []

func updateParts(type:PartTypes):
	for child in %partGrid.get_children():
		if not child.is_in_group("defaultChildren"):
			child.queue_free()
	listedParts.clear()
	for item in FM.playerData.inventory.keys():
		if item.itemType == ItemTypes.PART and item.type == type:
			listedParts.append(item)
			
			var newOption:Button = %partButtonTemplate.duplicate()
			%partGrid.add_child(newOption)
			%partGrid.move_child(newOption, %partBottomSeparator.get_index() - 1)
			newOption.remove_from_group("defaultChildren")
			newOption.text = item.name
			newOption.visible = true

func nonePressed():
	visible = false
	emit_signal("unitAssemblyComplete")

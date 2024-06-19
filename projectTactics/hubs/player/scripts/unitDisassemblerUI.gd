extends Control
# Signals
signal unitDisassemblyComplete
# Enumerators
enum ItemTypes {
	ALL,
	PART,
	UNIT,
	FISH
}
# Opens unit disassembly menu
func openDisassembler():
	visible = true
	SFX.playCloseMenu()
	updateUnitList()
# Update displayed units in inventory
func updateUnitList():
	# Remove all previously displayed units
	for child in %disassemblerGrid.get_children():
		if not child.is_in_group("defaultChildren"):
			child.queue_free()
	# Display all units found in inventory
	for item in FM.playerData.inventory.keys():
		if item.itemType == ItemTypes.UNIT: # Filters non-unit inventory items
			# Creates new unit
			var newOption:Button = %disassemblerButtonTemplate.duplicate()
			%disassemblerGrid.add_child(newOption)
			%disassemblerGrid.move_child(newOption, %disassemblerTopSeparator.get_index() + 1)
			newOption.remove_from_group("defaultChildren")
			# Names unit
			newOption.text = item.name
			if FM.playerData.inventory[item] > 1:
				newOption.text += "(" + str(FM.playerData.inventory[item]) + ")"
			newOption.visible = true
			# Connects unit button to removeUnit function
			newOption.button_up.connect(removeUnit.bind(item))
	SFX.connectAllButtons() # Connect buttons to button SFX
# Deconstruct given unit
func removeUnit(selectedUnit:Unit):
	# Add unit parts to inventory
	FM.playerData.addToInventory(selectedUnit.head)
	FM.playerData.addToInventory(selectedUnit.arm)
	FM.playerData.addToInventory(selectedUnit.chest)
	FM.playerData.addToInventory(selectedUnit.core)
	FM.playerData.addToInventory(selectedUnit.leg)
	# Remove unit from inventory
	FM.playerData.removeFromInventory(selectedUnit, 1)
	# Update displayed units
	updateUnitList()
# Close unit disassembly menu
func exitPressed():
	visible = false
	SFX.playCloseMenu()
	emit_signal("unitDisassemblyComplete")

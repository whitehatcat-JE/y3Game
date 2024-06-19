extends Control
# Signals
signal unitAssemblyComplete
# Enumerators
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
# Current unit assembling
var unitBuilding:Unit = null
var selectingType:PartTypes = PartTypes.ARM
# Show unit assembly menu
func startBuilding():
	# Clear previous unit
	unitBuilding = Unit.new()
	%armItemName.text = "None"
	%headItemName.text = "None"
	%legItemName.text = "None"
	%coreItemName.text = "None"
	%chestItemName.text = "None"
	%unitName.text = ""
	# Show menu
	visible = true
	showPartSelection()
	SFX.playCloseMenu()
# Show all possible parts of given type
func showParts(type:PartTypes):
	# Show part sub-menu
	$partLayout.visible = true
	$partSelectionLayout.visible = false
	# Clear previous part sub-menu
	selectingType = type
	for child in %partGrid.get_children():
		if not child.is_in_group("defaultChildren"):
			child.queue_free()
	# Show all parts of given type
	for item in FM.playerData.inventory.keys():
		if item.itemType == ItemTypes.PART and item.type == type:
			# Create new part
			var newOption:Button = %partButtonTemplate.duplicate()
			%partGrid.add_child(newOption)
			%partGrid.move_child(newOption, %partBottomSeparator.get_index() - 1)
			newOption.remove_from_group("defaultChildren")
			# Update part metadata
			newOption.text = item.name
			newOption.visible = true
			# Establish button connections
			newOption.button_up.connect(partSelected.bind(item))
	SFX.connectAllButtons()
# Clear part
func nonePressed():
	match selectingType: # Finds and clears selected part type
		PartTypes.ARM: # Arm
			unitBuilding.arm = null
			%armItemName.text = "None"
		PartTypes.HEAD: # Head
			unitBuilding.head = null
			%headItemName.text = "None"
		PartTypes.LEG: # Leg
			unitBuilding.leg = null
			%legItemName.text = "None"
		PartTypes.CORE: # Core
			unitBuilding.core = null
			%coreItemName.text = "None"
		PartTypes.CHEST: # Chest
			unitBuilding.chest = null
			%chestItemName.text = "None"
	# Update displayed parts
	showPartSelection()
# Select given part
func partSelected(part:Part):
	match selectingType: # Find part type and store selected part
		PartTypes.ARM: # Arm
			unitBuilding.arm = part
			%armItemName.text = part.name
		PartTypes.HEAD: # Head
			unitBuilding.head = part
			%headItemName.text = part.name
		PartTypes.LEG: # Leg
			unitBuilding.leg = part
			%legItemName.text = part.name
		PartTypes.CORE: # Core
			unitBuilding.core = part
			%coreItemName.text = part.name
		PartTypes.CHEST: # Chest
			unitBuilding.chest = part
			%chestItemName.text = part.name
	# Update displayed parts
	showPartSelection()
# Update displayed part selections
func showPartSelection():
	# Show part selection menu
	$partLayout.visible = false
	$partSelectionLayout.visible = true
	# Check whether player has selected valid parts for all types
	if null in [ # Disable unit construction button
		unitBuilding.head, unitBuilding.arm,
		unitBuilding.chest, unitBuilding.core,
		unitBuilding.leg]:
		%unitConfirmButton.disabled = true
		%unitConfirmButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else: # Enable unit construction button
		%unitConfirmButton.disabled = false
		%unitConfirmButton.mouse_filter = Control.MOUSE_FILTER_STOP
# Show part sub-menu for given type
func headPressed(): showParts(PartTypes.HEAD);
func armPressed(): showParts(PartTypes.ARM);
func chestPressed(): showParts(PartTypes.CHEST);
func corePressed(): showParts(PartTypes.CORE);
func legPressed(): showParts(PartTypes.LEG);
# Create unit from selected parts
func confirmPressed():
	# Create unit
	unitBuilding.name = "myMech"
	if %unitName.text != "": unitBuilding.name = %unitName.text;
	# Add unit to inventory
	FM.playerData.addToInventory(unitBuilding)
	# Remove parts from inventory
	FM.playerData.removeFromInventory(unitBuilding.head, 1)
	FM.playerData.removeFromInventory(unitBuilding.arm, 1)
	FM.playerData.removeFromInventory(unitBuilding.chest, 1)
	FM.playerData.removeFromInventory(unitBuilding.core, 1)
	FM.playerData.removeFromInventory(unitBuilding.leg, 1)
	# Close menu
	visible = false
	emit_signal("unitAssemblyComplete")
# Closes unit assembly menu and cancels unit
func cancelPressed():
	unitBuilding = null
	visible = false
	emit_signal("unitAssemblyComplete")

extends Control
# Enumerators
enum ItemTypes {
	ALL,
	PART,
	UNIT,
	FISH
}

enum Rarities {
	COMMON,
	UNCOMMON,
	RARE,
	EXOTIC,
	LEGENDARY,
	MYTHIC
}
# Variables
var selectedItem
var selectedItemType:ItemTypes = ItemTypes.ALL

var spawnedItems:Array[Button] = []

@export var playerInfo : PlayerData
# Connects button input events to relevant functions
func _ready():
	playerInfo = FM.playerData
	
	%allFilter.button_up.connect(setItemType.bind(ItemTypes.ALL))
	%partsFilter.button_up.connect(setItemType.bind(ItemTypes.PART))
	%unitsFilter.button_up.connect(setItemType.bind(ItemTypes.UNIT))
	%fishFilter.button_up.connect(setItemType.bind(ItemTypes.FISH))
# Monitors for exit pause menu request
func _input(event):
	if Input.is_action_just_pressed("pause"): unpause();
# Exits pause menu
func unpause():
	# Clears pause menu state
	clearDisplayedItem()
	get_tree().paused = false
	SFX.playCloseMenu()
	await get_tree().process_frame
	# Enables player movement
	self.visible = false
	%inventoryMenu.visible = false
	if !%dialogueMenu.visible and !%sellMenu.visible and !%unitAssembler.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# Opens inventory menu
func openInventory():
	# Updates inventory data
	FM.saveGame()
	%pauseMenuBalance.set_text("[center][color=#f8f644]" + str(playerInfo.balance
		) + " [img=12]placeholder/goldIcon.png[/img]")
	clearDisplayedItem()
	refreshItems()
	# Displays inventory
	%inventoryMenu.visible = true
	%saveMenu.visible = false
	%settingsMenu.visible = false
# Refreshes displayed items in inventory
func refreshItems():
	# Remove existing items
	for item in spawnedItems: item.queue_free();
	spawnedItems.clear()
	# Find all items of valid type in inventory
	var allItems:Array = playerInfo.inventory.keys()
	var filteredItems:Array = []
	if selectedItemType == ItemTypes.ALL: filteredItems = allItems;
	else:
		for item in allItems:
			if item.itemType == selectedItemType:
				filteredItems.append(item)
	if not selectedItem in filteredItems:
		clearDisplayedItem()
		selectedItem = null
	# Display all found items
	for item in filteredItems:
		# Creates item
		var newItem:Button = %itemTemplate.duplicate()
		%itemGrid.add_child(newItem)
		# Update displayed item data
		newItem.text = item.name
		if playerInfo.inventory[item] > 1:
			newItem.text += " (" + str(playerInfo.inventory[item]) + ")"
		# Establish button connections to self
		newItem.visible = true
		newItem.button_up.connect(inventoryItemSelected.bind(item))
		spawnedItems.append(newItem)
	SFX.connectAllButtons() # Connect item buttons to SFX events
# Stop displaying item model
func clearDisplayedItem():
	# Clear item data
	selectedItem = null
	%inventoryItemName.text = ""
	%inventoryItemData.text = " "
	%inventoryItemDescription.text = ""
	%inventoryItemModel.visible = false
	%inventoryItemMesh.mesh = null
	# Free meshes
	for child in %inventoryItemModel.get_children():
		if child != %inventoryItemMesh:
			child.queue_free()
	# Hide item data labels
	%inventoryDamageIcon.visible = false
	%inventoryArmorIcon.visible = false
	%inventorySpeedIcon.visible = false
	%inventoryRangeIcon.visible = false
	%inventorySplashIcon.visible = false
	%itemTrashSpacer.visible = false
	%deleteButton.visible = false
# Open settings menu
func openSettings():
	%inventoryMenu.visible = false
	%inventoryItemModel.visible = false
	%saveMenu.visible = false
	%settingsMenu.visible = true
	%settingsMenu.audioPressed()
# Open quit menu
func openQuit():
	%inventoryMenu.visible = false
	%inventoryItemModel.visible = false
	%saveMenu.visible = true
	%settingsMenu.visible = false
# Show selected item
func inventoryItemSelected(item):
	if item == selectedItem: return;
	# Reset item display
	clearDisplayedItem()
	%inventoryItemModel.visible = true
	%inventoryItemModel.scale = Vector3(1.0, 1.0, 1.0)
	%itemRotatorAnim.pause()
	%inventoryItemModel.rotation.y = 0.0
	# Create new item model
	var aabbSize:Vector3
	match item.itemType:
		ItemTypes.PART: # Part specific item generation
			# Create meshes
			var newModel = item.model.instantiate()
			%inventoryItemModel.add_child(newModel)
			if newModel.get_node_or_null("inverted") != null:
				newModel.get_child(1).free()
			# Position meshes
			newModel.position = Vector3(0.0, -(newModel.getAABB().position + newModel.getAABB().size / 2.0).y, 0.0)
			if newModel.has_node("pivotCenter"):
				newModel.position.z = -newModel.get_node("pivotCenter").position.z - newModel.position.z
			aabbSize = newModel.getAABB().size
			var divideAmt : float = max(aabbSize.x, aabbSize.y, aabbSize.z)
			%inventoryItemModel.scale = Vector3(0.8, 0.8, 0.8) / divideAmt * newModel.scaleModifier
		ItemTypes.UNIT: # Unit specific item generation
			# Create base node
			var newModel = Node3D.new()
			%inventoryItemModel.add_child(newModel)
			newModel.set_script(load("res://combat/resources/unitAssembler.gd"))
			newModel.unitParts = item
			# Generate unit meshes as children of base node
			newModel.assembleUnit()
			# Position meshes
			newModel.position = Vector3(0.0, -(newModel.getAABB().position + newModel.getAABB().size / 2.0).y, 0.0)
			aabbSize = newModel.getAABB().size
			var divideAmt : float = max(aabbSize.x, aabbSize.y, aabbSize.z)
			%inventoryItemModel.scale = Vector3(0.8, 0.8, 0.8) / divideAmt
		ItemTypes.FISH: # Fish specific item generation
			# Create mesh
			%inventoryItemMesh.mesh = item.model
			# Position mesh
			aabbSize = item.model.get_aabb().size
			var divideAmt : float = max(aabbSize.x, aabbSize.y, aabbSize.z)
			%inventoryItemModel.scale = Vector3(0.8, 0.8, 0.8) / divideAmt
	# Make displayed item spin
	%itemRotatorAnim.play()
	# Update name
	%inventoryItemName.text = item.name
	if playerInfo.inventory[item] > 1:
		%inventoryItemName.text += " (" + str(playerInfo.inventory[item]) + ")"
	# Update descriptor
	%inventoryItemDescription.text = "[center][i] " + item.description
	if item.itemType in [ItemTypes.PART, ItemTypes.UNIT]: # Shows unit or part specific data
		if item.itemType == ItemTypes.PART: # Show part specific data
			%inventoryItemData.text = "[center][color=red]%s [color=white]-[color=blue] %s/%s[color=white] - %s [img=12]placeholder/goldIcon.png[/img]" % [
				item.strType[item.type],
				str(item.currentDurability), 
				str(item.maxDurability),
				str(int(item.cost / 2.0))
			]
		# Update icons
		%inventoryDamageIcon.visible = true
		%inventoryDamage.text = str(item.damage)
		%inventoryArmorIcon.visible = true
		%inventoryArmor.text = str(item.armorRating)
		%inventorySpeedIcon.visible = true
		%inventorySpeed.text = str(item.speedRating)
		%inventoryRangeIcon.visible = true
		%inventoryRange.text = str(item.range)
		%inventorySplashIcon.visible = item.splash > 0
		%inventorySplash.text = str(item.splash)
		%itemTrashSpacer.visible = true
	elif item.itemType == ItemTypes.FISH: # Shows fish specific data
		# Convert rarity enum to string
		var rarityText:String = ""
		match item.rarity:
			Rarities.COMMON:
				rarityText = "Common"
			Rarities.UNCOMMON:
				rarityText = "[color=turquoise]Uncommon"
			Rarities.RARE:
				rarityText = "[color=tomato]Rare"
			Rarities.EXOTIC:
				rarityText = "[color=hotpink]Exotic"
			Rarities.LEGENDARY:
				rarityText = "[color=gold]Legendary"
			Rarities.MYTHIC:
				rarityText = "[color=purple]Mythic"
		# Display rarity
		%inventoryItemData.text = "[center] %s [color=white] - %s [img=12]placeholder/goldIcon.png[/img]" % [
			rarityText,
			str(int(item.cost))
		]
	# Finalize displayed item
	%deleteButton.visible = true
	selectedItem = item
# Manual save event
func saveGamePressed():
	FM.saveGame()
	%saveGameButton.text = "Saved!"
	%saveGameButton.disabled = true
	# Allow player to have time to read saved notification before hiding it
	await get_tree().create_timer(1.0).timeout
	%saveGameButton.text = "Manual Save"
	%saveGameButton.disabled = false
# Quit to main menu
func mainMenuPressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://general/UI/mainMenu.tscn")
# Quit to desktop
func desktopPressed():
	get_tree().quit()
# Delete item from inventory
func deleteItemPressed():
	playerInfo.inventory.erase(selectedItem)
	clearDisplayedItem()
	refreshItems()
	FM.saveGame()
# Set which item types should be displayed in inventory
func setItemType(type:ItemTypes):
	selectedItemType = type
	refreshItems()

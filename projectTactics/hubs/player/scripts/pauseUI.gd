extends Control

enum ItemTypes {
	ALL,
	PART,
	UNIT,
	FISH
}

var freezeButtons : bool = false

var selectedItem
var selectedItemType:ItemTypes = ItemTypes.ALL

var spawnedItems:Array[Button] = []

@export var playerInfo : PlayerData

func _ready():
	playerInfo = FM.playerData
	
	%allFilter.button_up.connect(setItemType.bind(ItemTypes.ALL))
	%partsFilter.button_up.connect(setItemType.bind(ItemTypes.PART))
	%unitsFilter.button_up.connect(setItemType.bind(ItemTypes.UNIT))
	%fishFilter.button_up.connect(setItemType.bind(ItemTypes.FISH))
	

func _input(event):
	if Input.is_action_just_pressed("pause"): unpause();

func unpause():
	clearDisplayedItem()
	get_tree().paused = false
	await get_tree().process_frame
	self.visible = false
	%inventoryMenu.visible = false
	if !%dialogueMenu.visible: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func openInventory():
	FM.saveGame()
	%pauseMenuBalance.set_text("[center][color=#f8f644]" + str(playerInfo.balance
		) + " [img=12]placeholder/goldIcon.png[/img]")
	clearDisplayedItem()
	%inventoryMenu.visible = true
	%saveMenu.visible = false
	%settingsMenu.visible = false
	refreshItems()

func refreshItems():
	for item in spawnedItems: item.queue_free();
	spawnedItems.clear()
	
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
	for item in filteredItems:
		var newItem:Button = %itemTemplate.duplicate()
		%itemGrid.add_child(newItem)
		newItem.text = item.name
		if playerInfo.inventory[item] > 1:
			newItem.text += " (" + str(playerInfo.inventory[item]) + ")"
		newItem.visible = true
		newItem.button_up.connect(inventoryItemSelected.bind(item))
		spawnedItems.append(newItem)

func clearDisplayedItem():
	%inventoryItemName.text = ""
	%inventoryItemData.text = ""
	%inventoryItemDescription.text = ""
	%inventoryItemModel.visible = false
	%inventoryDamageIcon.visible = false
	%inventoryArmorIcon.visible = false
	%inventorySpeedIcon.visible = false
	%inventoryRangeIcon.visible = false
	%inventorySplashIcon.visible = false
	%deleteButton.visible = false

func openSettings():
	%inventoryMenu.visible = false
	%inventoryItemModel.visible = false
	%saveMenu.visible = false
	%settingsMenu.visible = true
	%settingsMenu.audioPressed()
	
func openQuit():
	%inventoryMenu.visible = false
	%inventoryItemModel.visible = false
	%saveMenu.visible = true
	%settingsMenu.visible = false

func inventoryItemSelected(item):
	%inventoryItemModel.visible = true
	%inventoryItemModel.mesh = item.model
	var modelAABB : Vector3 = item.model.get_aabb().size
	var divideAmt : float = max(modelAABB.x, modelAABB.y, modelAABB.z)
	%inventoryItemModel.scale = Vector3(0.8, 0.8, 0.8) / divideAmt
	%inventoryItemName.text = item.name
	if playerInfo.inventory[item] > 1:
		%inventoryItemName.text += " (" + str(playerInfo.inventory[item]) + ")"
	%inventoryItemData.text = "[center][color=red]%s [color=white]-[color=blue] %s/%s" % [
		item.strType[item.type],
		str(item.currentDurability), 
		str(item.maxDurability)
	]
	%inventoryItemDescription.text = "[center][i] " + item.description
	
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
	
	%deleteButton.visible = true
	selectedItem = item

func saveGamePressed():
	FM.saveGame()
	%saveGameButton.text = "Saved!"
	%saveGameButton.disabled = true
	await get_tree().create_timer(1.0).timeout
	%saveGameButton.text = "Manual Save"
	%saveGameButton.disabled = false

func mainMenuPressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://general/UI/mainMenu.tscn")

func desktopPressed():
	get_tree().quit()

func deleteItemPressed():
	playerInfo.inventory.erase(selectedItem)
	clearDisplayedItem()
	refreshItems()
	FM.saveGame()

func setItemType(type:ItemTypes):
	selectedItemType = type
	refreshItems()

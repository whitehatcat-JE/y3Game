extends Control

var freezeButtons : bool = false

@export var playerInfo : PlayerData

func _ready():
	playerInfo = FM.playerData

func _input(event):
	if Input.is_action_just_pressed("pause"): unpause();

func unpause():
	clearDisplayedItem()
	get_tree().paused = false
	await get_tree().process_frame
	self.visible = false
	%inventoryMenu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func openInventory():
	FM.saveGame()
	%pauseMenuBalance.set_text("[center][color=#f8f644]" + str(playerInfo.balance
		) + " [img=12]placeholder/goldIcon.png[/img]")
	clearDisplayedItem()
	%inventoryMenu.visible = true
	%saveMenu.visible = false
	%settingsMenu.visible = false
	%inventory.clear()
	for item in playerInfo.inventory.values():
		%inventory.add_item("x" + str(playerInfo.itemCounts[item]), item.icon)

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

func inventoryItemSelected(index):
	%inventoryItemModel.visible = true
	%inventoryItemModel.mesh = playerInfo.inventory[index].model
	var modelAABB : Vector3 = playerInfo.inventory[index].model.get_aabb().size
	var divideAmt : float = max(modelAABB.x, modelAABB.y, modelAABB.z)
	%inventoryItemModel.scale = Vector3(0.8, 0.8, 0.8) / divideAmt
	%inventoryItemName.text = playerInfo.inventory[index].name
	%inventoryItemData.text = "[center][color=red]%s [color=white]-[color=blue] %s/%s" % [
		playerInfo.inventory[index].strType[playerInfo.inventory[index].type],
		str(playerInfo.inventory[index].currentDurability), 
		str(playerInfo.inventory[index].maxDurability)
	]
	%inventoryItemDescription.text = "[center][i]" + playerInfo.inventory[index].description
	
	%inventoryDamageIcon.visible = true
	%inventoryDamage.text = str(playerInfo.inventory[index].damage)
	%inventoryArmorIcon.visible = true
	%inventoryArmor.text = str(playerInfo.inventory[index].armorRating)
	%inventorySpeedIcon.visible = true
	%inventorySpeed.text = str(playerInfo.inventory[index].speedRating)
	%inventoryRangeIcon.visible = true
	%inventoryRange.text = str(playerInfo.inventory[index].range)
	%inventorySplashIcon.visible = playerInfo.inventory[index].splash > 0
	%inventorySplash.text = str(playerInfo.inventory[index].splash)

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

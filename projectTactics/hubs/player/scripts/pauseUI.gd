extends Control

@export var playerInfo : PlayerData

func _input(event):
	if Input.is_action_just_pressed("pause"): unpause();
	if Input.is_action_just_pressed("quit"): get_tree().quit();

func unpause():
	clearDisplayedItem()
	get_tree().paused = false
	await get_tree().process_frame
	self.visible = false
	%inventoryMenu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func openInventory():
	clearDisplayedItem()
	%inventoryMenu.visible = true
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

func openQuit():
	get_tree().quit()

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
	
	

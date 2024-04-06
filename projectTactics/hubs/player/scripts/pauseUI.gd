extends Control

var freezeButtons:bool = false

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
	freezeButtons = true
	%fullscreenButton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	%vsyncButton.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	freezeButtons = false
	audioPressed()
	
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
	pass # Replace with function body.

func mainMenuPressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func desktopPressed():
	get_tree().quit()

func audioPressed():
	%audioMenu.visible = true
	%graphicsMenu.visible = false
	%keybindsMenu.visible = false
	%audioSettingsButton.self_modulate.a = 0.75
	%graphicsSettingsButton.self_modulate.a = 1
	%keybindsSettingsButton.self_modulate.a = 1

func graphicsPressed():
	%audioMenu.visible = false
	%graphicsMenu.visible = true
	%keybindsMenu.visible = false
	%audioSettingsButton.self_modulate.a = 1
	%graphicsSettingsButton.self_modulate.a = 0.75
	%keybindsSettingsButton.self_modulate.a = 1

func keybindsPressed():
	%audioMenu.visible = false
	%graphicsMenu.visible = false
	%keybindsMenu.visible = true
	%audioSettingsButton.self_modulate.a = 1
	%graphicsSettingsButton.self_modulate.a = 1
	%keybindsSettingsButton.self_modulate.a = 0.75

func masterAudioUpdated(value_changed): pass;
func musicAudioUpdated(value_changed): pass;
func combatAudioUpdated(value_changed): pass;
func uiAudioUpdated(value_changed): pass;
func ambientAudioUpdated(value_changed): pass;


func resetAudioPressed():
	%masterSlider.value = 100
	%musicSlider.value = 100
	%combatSlider.value = 100
	%uiSlider.value = 100
	%ambientSlider.value = 100


func fullscreenToggled(toggled_on):
	if freezeButtons: return;
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func vsyncToggled(toggled_on):
	if freezeButtons: return;
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

extends GridContainer
# Signals
signal volumeChanged
# Settings menu initialization
func _ready():
	refreshSettings()
	FM.globalLoaded.connect(refreshSettings)
# Update displayed settings with last session settings
func refreshSettings():
	%musicSlider.value = FM.loadedGlobalData.musicVolume
	%combatSlider.value = FM.loadedGlobalData.combatVolume
	%uiSlider.value = FM.loadedGlobalData.uiVolume
	%ambientSlider.value = FM.loadedGlobalData.ambientVolume
	
	%fullscreenButton.button_pressed = FM.loadedGlobalData.fullscreenToggled
	%vsyncButton.button_pressed = FM.loadedGlobalData.vsyncToggled
# Show audio settings
func audioPressed():
	%audioMenu.visible = true
	%graphicsMenu.visible = false
	%keybindsMenu.visible = false
	%audioSettingsButton.self_modulate.a = 0.75
	%graphicsSettingsButton.self_modulate.a = 1
	%keybindsSettingsButton.self_modulate.a = 1
# Show graphics settings
func graphicsPressed():
	%audioMenu.visible = false
	%graphicsMenu.visible = true
	%keybindsMenu.visible = false
	%audioSettingsButton.self_modulate.a = 1
	%graphicsSettingsButton.self_modulate.a = 0.75
	%keybindsSettingsButton.self_modulate.a = 1
# Show keybinds settings
func keybindsPressed():
	%audioMenu.visible = false
	%graphicsMenu.visible = false
	%keybindsMenu.visible = true
	%audioSettingsButton.self_modulate.a = 1
	%graphicsSettingsButton.self_modulate.a = 1
	%keybindsSettingsButton.self_modulate.a = 0.75
# Update music volume
func musicAudioUpdated(newValue):
	# Change volume
	Music.changeVolume(4 * newValue - 20)
	FM.loadedGlobalData.musicVolume = newValue
	# Notify audio systems of changed volume
	FM.saveGlobal()
	emit_signal("volumeChanged")
# Update combat volume
func combatAudioUpdated(newValue):
	# Change volume
	FM.loadedGlobalData.combatVolume = newValue
	# Notify audio systems of changed volume
	FM.saveGlobal()
	emit_signal("volumeChanged")
# Update UI volume
func uiAudioUpdated(newValue):
	# Change volume
	SFX.changeVolume(4 * newValue - 20)
	FM.loadedGlobalData.uiVolume = newValue
	# Notify audio systems of changed volume
	FM.saveGlobal()
	emit_signal("volumeChanged")
# Update ambient volume
func ambientAudioUpdated(newValue):
	# Change volume
	FM.loadedGlobalData.ambientVolume = newValue
	# Notify audio systems of changed volume
	FM.saveGlobal()
	emit_signal("volumeChanged")
# Resets audio volumes to default volume
func resetAudioPressed():
	%musicSlider.value = 5
	%combatSlider.value = 5
	%uiSlider.value = 5
	%ambientSlider.value = 5
# Switches window between fullscreen and windowed modes
func fullscreenToggled(toggled_on):
	FM.loadedGlobalData.fullscreenToggled = toggled_on
	FM.saveGlobal()
	if toggled_on: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
# Toggles v-sync
func vsyncToggled(toggled_on):
	FM.loadedGlobalData.vsyncToggled = toggled_on
	FM.saveGlobal()
	if toggled_on: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED);
	else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);

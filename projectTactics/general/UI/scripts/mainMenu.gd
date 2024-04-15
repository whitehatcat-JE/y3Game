extends Control 

@export var defaultPlayerData : PlayerData

func _ready():
	FM.playerData = defaultPlayerData
	FM.loadGame()

func newGamePressed():
	get_tree().change_scene_to_file("res://hubs/city/city.tscn")

func loadGamePressed():
	%settingsMenu.visible = false
	%loadMenu.visible = true

func settingsPressed():
	%settingsMenu.visible = true
	%loadMenu.visible = false

func quitPressed(): get_tree().quit();

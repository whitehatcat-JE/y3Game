@tool
extends Node3D

var queuedNodes:Dictionary = {}

func _enter_tree():
	if get_tree().edited_scene_root == null: return;
	refreshBuffer()

func refreshBuffer():
	var sceneName:String = get_tree().edited_scene_root.name
	print(queuedNodes.keys())
	if sceneName in queuedNodes.keys():
		for nodeName in queuedNodes[sceneName]:
			var newNode:Node3D = Node3D.new()
			self.add_child(newNode)
			newNode.set_owner(self)
			newNode.name = nodeName


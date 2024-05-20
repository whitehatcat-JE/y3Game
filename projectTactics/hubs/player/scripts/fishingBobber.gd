extends RigidBody3D

signal floorContacted
signal waterContacted

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func bodyContacted(body):
	emit_signal("floorContacted")
	queue_free()


func areaContacted(area):
	emit_signal("waterContacted")
	sleeping = true


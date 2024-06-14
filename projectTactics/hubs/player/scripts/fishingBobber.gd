extends RigidBody3D

const MIN_WAIT_TIME:float = 3.0
const MAX_WAIT_TIME:float = 10.0

const PULL_TIME:float = 1.0

signal floorContacted
signal waterContacted

signal pulling
signal surfacing

var isPulling:bool = false
var isReeling:bool = false

func startWaitPeriod():
	await get_tree().create_timer(randf_range(MIN_WAIT_TIME, MAX_WAIT_TIME)).timeout
	if isReeling: return;
	$bobberAnims.play("sink")
	isPulling = true
	if FM.loadedGlobalData.ambientVolume > 0:
		$sinkSFX.play()
		$sinkSFX.volume_db = 4 * FM.loadedGlobalData.ambientVolume - 10
	emit_signal("pulling")

func getBobber():
	return %bobberMesh

func bodyContacted(body):
	emit_signal("floorContacted")
	queue_free()


func areaContacted(area):
	emit_signal("waterContacted")
	global_transform.origin = $waterCast.get_collision_point()
	freeze = true
	if FM.loadedGlobalData.ambientVolume > 0:
		$splashSFX.play()
		$splashSFX.volume_db = 4 * FM.loadedGlobalData.ambientVolume - 25
	startWaitPeriod()

func bobberAnimFinished(anim_name):
	if isReeling: return;
	match anim_name:
		"sink":
			$bobberAnims.play("pull")
			await get_tree().create_timer(PULL_TIME).timeout
			if isReeling: return;
			$bobberAnims.play("surface")
			emit_signal("surfacing")
		"surface":
			$bobberAnims.play("float")
			isPulling = false
			startWaitPeriod()

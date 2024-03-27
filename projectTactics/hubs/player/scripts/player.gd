extends CharacterBody3D
# Signals
signal interacted(interactionName:String)
# Constants
const PLAYER_SPEED:float = 6.0
const PLAYER_SPRINT:float = 1.5  
const MOUSE_SENSITIVITY:float = 0.003
const DECELERATION:float = 20.0

const JUMP_VELOCITY:float = 4.0
const GRAVITY:float = 10.5
const TERMINAL_VELOCITY:float = 7.0
# State variables
var cameraAngle:float = 0
var unlockedInteractions:Array[String] = ["monitor", "passcode", "crt", "piano"]

var verticalVel:float = 0.0

var storedDirection:Vector3 = Vector3()
var isSprinting:bool = false

func _ready() -> void: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _process(delta):
	%interactIcon.visible = %interactRay.is_colliding()

func _physics_process(delta):
	move(delta)

#region Movement
func _input(event) -> void:
	if event is InputEventMouseMotion: # Used for mouse movement detection
		event.relative = -event.relative * MOUSE_SENSITIVITY
		rotate_y(event.relative.x)
		%playerCam.rotation.x = clamp(%playerCam.rotation.x + event.relative.y, -PI / 2.0, PI / 2.0)

func move(delta):
	# Add the gravity.
	if !is_on_floor():
		verticalVel -= GRAVITY * delta
		verticalVel = clamp(verticalVel, -TERMINAL_VELOCITY, INF)
	elif Input.is_action_pressed("moveJump"): verticalVel = JUMP_VELOCITY;
	else: verticalVel = 0;
	
	var aim:Vector3 = Vector3(1, 0, 1)
	var direction:Vector3 = Vector3(0, -1, 0)
	
	if is_on_floor():
		var inputVec:Vector2 = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
		if inputVec.x != 0 and inputVec.y != 0: inputVec *= 0.709;
		direction.x = aim.x * inputVec.x
		direction.z = aim.z * inputVec.y
		direction = direction.rotated(Vector3.UP, rotation.y)
		storedDirection = direction
	else: direction = storedDirection;
	
	# Move player in calculated direction
	if direction.dot(velocity) == 0 and velocity.length() > 0.1:
		velocity *= DECELERATION * delta
	else:
		velocity = direction.normalized() * PLAYER_SPEED
		if is_on_floor(): isSprinting = Input.is_action_pressed("moveSprint");
		else: velocity *= 0.8;
		if isSprinting: velocity *= PLAYER_SPRINT;
		
		if !is_on_floor(): %bobAnim.speed_scale = 0.0;
		else: %bobAnim.speed_scale = direction.dot(velocity) - 5.0;
		
		velocity.y = verticalVel
	move_and_slide()
#endregion

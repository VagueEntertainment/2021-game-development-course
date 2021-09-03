extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $RotationHelper/Camera
	rotation_helper = $RotationHelper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Mistro.process_movement(self,delta)
	Mistro.process_input(self,camera,delta)
#	pass

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot


func _on_underwater_body_entered(body):
	print("underwater")
	pass # Replace with function body.

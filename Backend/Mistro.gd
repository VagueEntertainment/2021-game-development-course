extends Node

# Mistro is this projects "global" or game wide function set. 
# Function that go here, can be accessed by all other scripts.
# Use this sparingly as noise between scenes and nodes can make your game run slower.
#var camera = Camera.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func save_game():
	print("saving")
	
func load_game(_gamefile):
	print("loading")
	
func list_saved_games():
	print("saved games")
	
#func global_physics(object,):
#	print("applying global physics")

### We're using the documented defaults for a kinematic character from Godot's website. We edit it a bit to make sure it can be use for any object.

func process_movement(obj,delta):
	obj.dir.y = 0
	obj.dir = obj.dir.normalized()

	obj.vel.y += delta * obj.GRAVITY

	var hvel = obj.vel
	hvel.y = 0

	var target = obj.dir
	target *= obj.MAX_SPEED

	var accel
	if obj.dir.dot(hvel) > 0:
		accel = obj.ACCEL
	else:
		accel =obj.DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	obj.vel.x = hvel.x
	obj.vel.z = hvel.z
	obj.vel = obj.move_and_slide(obj.vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(obj.MAX_SLOPE_ANGLE))
	

#### We're using the documented defaults for a kinematic character from Godot's website. Edited for use in Mistro instead of needing to be copied and pasted every node.
	
func process_input(obj,camera,delta):

	# ----------------------------------
	# Walking
	obj.dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	obj.dir += -cam_xform.basis.z * input_movement_vector.y
	obj.dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if obj.is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			obj.vel.y = obj.JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------


### World creation

func create_block(obj,randomseed,size = Vector2(16,16)):
	var TriSize = 8
	var map = []
	var Z_OFFSET = 0
	
	var grid_z = []
	var grid = []
	while len(grid_z) <= size.y:
		grid_z.append(Z_OFFSET)
		var X_OFFSET = 0
		var grid_x = []
		while len(grid_x) <= size.x:
			grid_x.append(Vector3(X_OFFSET,0,grid_z[-1]))
			X_OFFSET += TriSize
		grid.append(grid_x)
		Z_OFFSET += TriSize
		
	print(grid[0])
	print(grid[1])
	
	var point1 = Vector3()
	var point2 = Vector3()
	var point3 = Vector3()
	var row = []
	var Flip_even = false
	var Flip_odd = false
	var OFFSET = 0
	while len(row) < 16:
		if len(row) % 2 == 0:
			if !Flip_even:
				point1 = grid[0][len(row)]
				point2 = grid[1][len(row)]
				point3 = grid[1][len(row)+1]
				Flip_even = true
			else:
				point1 = grid[0][len(row)-1]
				point2 = grid[1][len(row)-1]
				point3 = grid[0][len(row)]
				Flip_even = false
		else:
			if !Flip_odd:
				point1 = grid[0][len(row)-1]
				point2 = grid[0][len(row)]
				point3 = grid[1][len(row)]
				Flip_odd = true
			else:
				point1 = grid[1][len(row)]
				point2 = grid[0][len(row)+1]
				point3 = grid[1][len(row)+1]
				Flip_odd = false
				
		var points = [point1,point2,point3]
		row.append(points)
		
			 
	map = row
	#map.append(row)
		
	### Create a flat map
	
	
	if obj.get_class() == "ImmediateGeometry":
		### Create first quad
		obj.begin(Mesh.PRIMITIVE_TRIANGLES)
		for tri in map:
			obj.add_vertex(tri[0])
			obj.add_vertex(tri[1])
			obj.add_vertex(tri[2])
		obj.end()	
		#obj.rotate(Vector3(1,0,0),30)
	pass

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

func create_block(land,water,randomseed,size = Vector2(16,16)):
	var vertex_count := 0
	var time := 0.0
	var wave_length := 0.25
	var TriSize = 8
	var map = []
	var Z_OFFSET = 0
	var smoothing = 1
	rand_seed(randomseed)
	var string_random = str(randomseed)
	
	water.mesh.size.x = land.mesh.size.x
	water.mesh.size.y = land.mesh.size.y
	land.mesh.subdivide_width = smoothing * size.x
	land.mesh.subdivide_depth = smoothing * size.y
	#gets the MeshArray arrays for the only surface on the ground mesh
	var mesh_array = land.mesh.surface_get_arrays(0)
	#var mesh_material = obj.mesh.material
	#vertex array is at index 0
	var va = mesh_array[0]
	#vertex count is just to update on screen debug info
	vertex_count = va.size()
	
	for i in range(vertex_count):
		var v = va[i]
		v.y = rand_range(int(string_random[0]),int(string_random[1]))
		va.set(i, v)
		
	for a in range(vertex_count):
		randomize()
		var v = va[a]
		if int(round(rand_range(1,199)))  == 1: 
			#print("mountain range ",-1 * int(string_random.substr(1,2))," ",int(string_random.substr(3,2)))
			randomize()
			var fromto1 = rand_range(0,len(string_random))
			randomize()
			var fromto2 = rand_range(0,len(string_random))
			v.y = rand_range(-1 * int(string_random.substr(fromto1,3)),int(string_random.substr(fromto2,2)))
			#print(v.y) 
			va.set(a, v)
	for f in range(smoothing):
		for b in range(vertex_count):
			var v = va[b]
			if v.y > va[b-1].y+10:
				va[b-1].y = v.y * rand_range(0.80,1.00)
				va.set(b-1,va[b-1])
			if b+1 < vertex_count:
				if v.y > va[b+1].y+10:
					va[b+1].y = v.y * rand_range(0.50,1.00)
					va.set(b+1,va[b+1])
			if b+smoothing*size.x < vertex_count:
				if v.y > va[b+smoothing*size.x].y+10:
					va[b+smoothing*size.x].y = v.y * rand_range(0.80,1.00)
					va.set(b+smoothing*size.x,va[b+smoothing*size.x])
			if b-smoothing*size.x > 0:
				if v.y > va[b-smoothing*size.x].y+10:
					va[b-smoothing*size.x].y = v.y * rand_range(0.80,1.00)
					va.set(b-smoothing*size.x,va[b-smoothing*size.x])
			
			
	#replace old vertex array with modified vertex array
	mesh_array[0] = va
	var array_mesh = ArrayMesh.new()
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
	#set the ground MeshInstance mesh to the ArrayMesh with the modified
	#vertex mesh.
	land.mesh = array_mesh
	#obj.mesh.material = mesh_material
	
	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces(land.mesh.get_faces())
	land.get_parent().get_node("CollisionShape").set_shape(col_shape)

	pass

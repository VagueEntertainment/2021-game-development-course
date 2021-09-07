extends Node

# Mistro is this projects "global" or game wide function set. 
# Function that go here, can be accessed by all other scripts.
# Use this sparingly as noise between scenes and nodes can make your game run slower.
#var camera = Camera.new()
var smoothing = 2

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
	
	rand_seed(randomseed)
	var string_random = str(randomseed)
	
	if land.mesh is ArrayMesh:
		print("need to find a better method")
	else:
		water.mesh.size.x = land.mesh.size.x * 1.2
		water.mesh.size.y = land.mesh.size.y * 1.2
		water.get_node("underwater/CollisionShape").shape.set_extents(Vector3(water.mesh.size.x,6.317,water.mesh.size.y))
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
		if int(round(rand_range(1,12*smoothing)))  == 1: 
			#print("mountain range ",-1 * int(string_random.substr(1,2))," ",int(string_random.substr(3,2)))
			randomize()
			var fromto1 = rand_range(0,len(string_random))
			randomize()
			var fromto2 = rand_range(0,len(string_random))
			v.y = rand_range(-1 * int(string_random.substr(fromto1,3)),int(string_random.substr(fromto2,2)))
			#print(v.y) 
			va.set(a, v)
			
	#replace old vertex array with modified vertex array
	mesh_array[0] = va
	var array_mesh = ArrayMesh.new()
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
	#set the ground MeshInstance mesh to the ArrayMesh with the modified
	#vertex mesh.
	land.mesh = array_mesh
	#obj.mesh.material = mesh_material
	
	for f in range(smoothing):
		
		var mesh_array_s = land.mesh.surface_get_arrays(0)
		#print("Mesh array length is: ",len(mesh_array_s[0]))
		var t = 0
		
		## Randomizes the position of the vertices to make a more organic feel
		while t < len(mesh_array_s[0]):
			randomize()
			var smesh = mesh_array_s[0][t] + Vector3(rand_range(-2,2),0,rand_range(-2,2))
			mesh_array_s[0][t] = smesh
			mesh_array_s[0].set(t,smesh)
			t += 1
		
		var vertex_count_s := len(mesh_array_s[0])
		var va_s = mesh_array_s[0]
		
		for b in range(vertex_count_s):
			var v = va_s[b]
			if v.y > 0: 
				if v.y > va_s[b-1].y+20:
					va_s[b-1].y = v.y * rand_range(0.80,1.00)
					va_s.set(b-1,va_s[b-1])
				if b+1 < vertex_count_s:
					if v.y > va_s[b+1].y+20:
						va_s[b+1].y = v.y * rand_range(0.90,1.00)
						va_s.set(b+1,va_s[b+1])
				if b+smoothing*size.x < vertex_count_s:
					if v.y > va_s[b+smoothing*size.x].y+20:
						va_s[b+smoothing*size.x].y = v.y * rand_range(0.90,1.00)
						va_s.set(b+smoothing*size.x,va_s[b+smoothing*size.x])
				if b-smoothing*size.x > 0:
					if v.y > va_s[b-smoothing*size.x].y+20:
						va_s[b-smoothing*size.x].y = v.y * rand_range(0.80,1.00)
						va_s.set(b-smoothing*size.x,va_s[b-smoothing*size.x])
			else:
				print(v.y)
				if v.y < va_s[b-1].y+20:
					va_s[b-1].y = v.y * rand_range(0.80,0.50)
					va_s.set(b-1,va_s[b-1])
				#if b+1 < vertex_count_s:
				#	if v.y > va_s[b+1].y-20:
				#		va_s[b+1].y = v.y * rand_range(0.90,1.00)
				#		va_s.set(b+1,va_s[b+1])
				#if b+smoothing*size.x < vertex_count_s:
				#	if v.y > va_s[b+smoothing*size.x].y-20:
				#		va_s[b+smoothing*size.x].y = v.y * rand_range(0.90,1.00)
				#		va_s.set(b+smoothing*size.x,va_s[b+smoothing*size.x])
				#if b-smoothing*size.x > 0:
				#	if v.y > va_s[b-smoothing*size.x].y-20:
				#		va_s[b-smoothing*size.x].y = v.y * rand_range(0.80,1.00)
				#		va_s.set(b-smoothing*size.x,va_s[b-smoothing*size.x])
		
		mesh_array_s[0] = va_s
		
		var array_mesh_s = ArrayMesh.new()
		array_mesh_s.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array_s)
		land.mesh = array_mesh_s
		
	## Simulate errosion
	
	var mesh_array_e = land.mesh.surface_get_arrays(0)
	var va_e = mesh_array_e[0]
	
	for e in range(vertex_count):
		var v = va_e[e]
		if v.y > va_e[e-1].y+20:
			v.y  = va_e[e-1].y * rand_range(0.80,1.00)
			va_e.set(e,v)
		if e+1 < vertex_count:
			if v.y > va_e[e+1].y+20:
				v.y = va_e[e+1].y * rand_range(0.90,1.00)
				va_e.set(e,v)
		if e+smoothing*size.x < vertex_count:
			if v.y > va_e[e+smoothing*size.x].y+20:
				v.y = va_e[e+smoothing*size.x].y  * rand_range(0.90,1.00)
				va_e.set(e,v)
		if e-smoothing*size.x > 0:
			if v.y > va_e[e-smoothing*size.x].y+20:
				v.y = va_e[e-smoothing*size.x].y * rand_range(0.80,1.00)
				va_e.set(e,v)
		
	var array_mesh_e = ArrayMesh.new()
	array_mesh_e.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array_e)
	land.mesh = array_mesh_e
		
		
	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces(land.mesh.get_faces())
	land.get_parent().get_node("CollisionShape").set_shape(col_shape)
	water.get_parent().translate(Vector3(0,mesh_array_e[0][int(rand_range(0,len(mesh_array_e[0])))].y,0))
	plants(land)
	return mesh_array_e[0]

### Plant Areas
func plants(land):
	var PlantAreas = Spatial.new()
	land.add_child(PlantAreas)
	var mesh_array = land.mesh.surface_get_arrays(0)
	var va = mesh_array[0]
	for i in range(20):
		randomize()
		var starting_point = int(rand_range(0,len(va)))
		print(starting_point)
		var rows = int(rand_range(20,60))
		var plantingbed = MeshInstance.new()
		var arrayMesh = ArrayMesh.new()
		var array = []
		for r in range(rows):
			var columns = int(rand_range(10,40))
			if starting_point+(r*1000) < va.size():
				array.append(va[starting_point+(r*1000)])
				var from = starting_point+(r*1000)
				for c in range(columns):
					if from - c > 0:
						array.append(va[from -c])
		
		#print(array)
		
		arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
		plantingbed.mesh = arrayMesh
		plantingbed.translate(va[starting_point]+Vector3(0,3,0))
		PlantAreas.add_child(plantingbed)
	

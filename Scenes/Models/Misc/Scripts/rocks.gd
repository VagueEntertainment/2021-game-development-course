extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ground = Vector3(0,0,0)
var found_ground = false
#var y_offset = -0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	ground = get_parent().get_translation()
	#y_offset = ground.y - 2 
	var rotate_rock = int(rand_range(1,6))
	var rs = rand_range(0.5,5.2)
	var RockScale= Vector3(rs,rs,rs)
	var RockRotation = Vector3(0,1,0)
	self.scale_object_local(RockScale)
	
	match rotate_rock:
			1:
				RockRotation = Vector3(1,0,0)
			2:
				RockRotation = Vector3(0,0,1)
			3:
				RockRotation = Vector3(0,1,0)
			4:
				RockRotation = Vector3(1,1,0)
			5:
				RockRotation = Vector3(0,1,1)
			6:
				RockRotation = Vector3(1,0,1)
	generate_rocks()
	translate_object_local(Vector3(0,-0.1,0))
	#$plantcircle.translate_object_local(Vector3(0,ground.y,0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Mistro.process_movement($rock,delta)
	if found_ground == false:
		#$PlantCircle.translate_object_local(Vector3(0,0.02,0))
		self.translate(Vector3(0,-0.02,0))
	else:
		set_process(false)
	
	#pass

func generate_rocks():
	var num_of_rocks = int(rand_range(1,5))
	
	while get_child_count() < num_of_rocks:
		var rock_instance = $rock.duplicate()
		var rotate_rock = int(rand_range(1,6))
		var scale_rock = int(rand_range(1,3))
		var offset_rock = int(rand_range(1,3))
		
		var rs = rand_range(0.5,2)
		
		var RockRotation = Vector3(0,1,0)
		
		var RockScale = Vector3(rs,rs,rs)
		var RockOffset = Vector3(0,0,0)
		
		match rotate_rock:
			1:
				RockRotation = Vector3(1,0,0)
			2:
				RockRotation = Vector3(0,0,1)
			3:
				RockRotation = Vector3(0,1,0)
			4:
				RockRotation = Vector3(1,1,0)
			5:
				RockRotation = Vector3(0,1,1)
			6:
				RockRotation = Vector3(1,0,1)
				
		match offset_rock:
			1:
				RockOffset = Vector3(0,self.translation.y,rand_range(-3,3))
			2:
				RockOffset = Vector3(rand_range(-3,3),self.translation.y,rand_range(-3,3))
			3:
				RockOffset = Vector3(rand_range(-3,3),self.translation.y,0)
				
		
		rock_instance.scale_object_local(RockScale)
		rock_instance.rotate(RockRotation.normalized(),90)
		rock_instance.set_translation(RockOffset)
		rock_instance.name = "rock"+str(get_child_count())
		add_child(rock_instance)
		pass
	



func _on_PlantCircle_body_shape_exited(body_id, body, body_shape, local_shape):
	if body.get_groups().has("Ground"):
		#print("B S E stopped")
		found_ground = true
	pass # Replace with function body.


func _on_PlantCircle_body_exited(body):
	if body.get_groups().has("Ground"):
		#print("B E stopped")
		found_ground = true
	pass # Replace with function body.


func _on_PlantCircle_body_shape_entered(body_id, body, body_shape, local_shape):
	#if body.get_groups().has("Ground"):
		#print("B S En stopped")
		#found_ground = true
	pass # Replace with function body.


func _on_PlantCircle_body_entered(body):
	#if body.get_groups().has("Ground"):
		#print(" B En stopped")
		#found_ground = true
	pass # Replace with function body.


func _on_PlantCircle_area_shape_exited(area_id, area, area_shape, local_shape):
	if area.get_groups().has("Ground"):
		#print(" A E stopped")
		found_ground = true
	pass # Replace with function body.


func _on_PlantCircle_area_shape_entered(area_id, area, area_shape, local_shape):
	if area.get_groups().has("Ground"):
		#print("A En stopped")
		found_ground = true
	pass # Replace with function body.

func drop_children():
	for r in get_children():
		if r.name.find("rock") !=-1:
			#print(r.name)
			r.set_translation(Vector3(r.translation.x,0,r.translation.z))
			


func _on_Area_body_entered(body):
	pass # Replace with function body.


func _on_Area_body_shape_entered(body_id, body, body_shape, local_shape):
	
	found_ground = true
	pass # Replace with function body.

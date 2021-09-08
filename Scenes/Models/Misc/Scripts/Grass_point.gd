extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var blade = preload("res://Scenes/Models/Misc/Grass_blade.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	grow(get_parent())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func grow(land):
	var array = land.mesh.surface_get_arrays(0)[0]
	#print(array)
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.color_format = MultiMesh.CUSTOM_DATA_FLOAT
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	# Then resize (otherwise, changing the format is not allowed).
	multimesh.instance_count = 20000
	# Maybe not all of them should be visible at first.
	multimesh.visible_instance_count = 2000
	multimesh.mesh = blade
	
	
	for i in range(self.multimesh.instance_count):
		var position = Transform()
		var x = rand_range(0,array[rand_range(0,array.size())].x)
		var y = rand_range(0,array[rand_range(0,array.size())].y)
		var z = rand_range(0,array[rand_range(0,array.size())].z)
		#var z = rand_range(0,array[rand_range(0,array.size())].z)
		#print(x,",",y,",",z)
		position = position.translated(Vector3(x,y,z))
		#multimesh.set_instance_color(i,Color(0,0.4,0))
		#print(position)
		self.multimesh.set_instance_transform(i, position)

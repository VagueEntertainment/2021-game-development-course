extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var total_rocks = int(1000)
var end_y = 1000
var end_x = 1000
var randomseed = RandomNumberGenerator.new().get_seed()
var heightmap = []
# Called when the node enters the scene tree for the first time.
func _ready():
	end_x = $Ground/MeshInstance.mesh.size.x
	end_y = $Ground/MeshInstance.mesh.size.y
	heightmap = Mistro.create_block($Ground/MeshInstance,$Ground/Waterline/MeshInstance,randomseed)
	if rocks($Ground) == 1:
		$Ground/GIProbe.extents = Vector3(end_x,200,end_y)
		$Ground/GIProbe.bake()
		$PlayerTemplate.translate(heightmap[int(rand_range(0,len(heightmap)))])
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func rocks(area):
	var rock = load("res://Scenes/Models/Misc/rock1.tscn")
	while area.get_child_count() < total_rocks:
		var random_location = rand_range(0,len(heightmap))
		var therock = rock.instance()
		var placement = heightmap[int(random_location)] - Vector3(0,1,0)
		therock.translate(placement)
		$Ground.add_child(therock)
	return 1

func trees():
	pass


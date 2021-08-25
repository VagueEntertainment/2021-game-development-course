extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var total_rocks = int(10)
var randomseed = RandomNumberGenerator.new().get_seed()
# Called when the node enters the scene tree for the first time.
func _ready():
	Mistro.create_block($Ground/Ground,randomseed)
	if rocks($Ground) == 1:
		$GIProbe.bake()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func rocks(area):
	var rock = load("res://Scenes/Models/Misc/rock1.tscn")
	while area.get_child_count() < total_rocks:
		var random_location_x = rand_range(-500,500)
		var random_location_z =  rand_range(-500,500)
		var therock = rock.instance()
		therock.translate(Vector3(random_location_x,$Ground/MeshInstance.translation.y - 1,random_location_z))
		$Ground.add_child(therock)
	return 1

func trees():
	pass


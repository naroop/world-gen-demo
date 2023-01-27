extends StaticBody2D

var DROP_RADIUS: int = 25
var WOOD_DROP_COUNT: int = 1
var HITS_FOR_DROP: int = 1
var hitCounter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	z_index = global_position.y as int

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			print("tree clicked")
			treeHit()
			
func treeHit():
	hitCounter += 1
	if hitCounter == HITS_FOR_DROP:
		dropWood()
		hitCounter = 0
		
func dropWood():
	for n in range(WOOD_DROP_COUNT):
		#GameTools.spawnItem("wood_block", global_position, DROP_RADIUS)
		pass
		

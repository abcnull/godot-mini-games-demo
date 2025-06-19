extends Node

## 管理地面障碍物

var pic_list

func _ready():
	pic_list = get_children()
	
func _physics_process(delta):
	for pic_node: Node2D in pic_list:
		pic_node.position.x += GlobalVarGd.PIC_MOVE_SPEED * delta
		if pic_node.position.x < GlobalVarGd.BORD_X:
			pic_node.position.x = abs(GlobalVarGd.BORD_X)
		
		

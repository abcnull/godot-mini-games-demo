extends Node

## 管理游戏背景变化

var pic_list

func _ready():
	# 获取所有背景图片数组
	pic_list = get_children()
	SignalBusGd.start_game_singal.connect(_on_start_game)

func _physics_process(delta):
	for pic_node: Node2D in pic_list:
		pic_node.position.x += GlobalVarGd.PIC_MOVE_SPEED * delta
		# 超出边界，则改变 x 位置
		if pic_node.position.x < GlobalVarGd.BORD_X:
			pic_node.position.x = abs(GlobalVarGd.BORD_X)
			
func _on_start_game():
	if GameManagerGd.is_music_on == true:
		$AudioStreamPlayer2D.playing = true
		
		

extends Node

## 管理障碍物的生成

@onready var timer: Timer = $Timer
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	# 初始化障碍物
	init_obstacles()

# 初始障碍物
func init_obstacles():
	# 把 obstacle 场景在这里重新创造出来
	var obstacle_instance = GlobalVarGd.OBSTACLE_SCENE.instantiate() as Node2D
	# 设置位置
	obstacle_instance.position.x = randf_range(GlobalVarGd.OBSTACLE_RAND_X_FROM, GlobalVarGd.OBSTACLE_RAND_X_TO)
	obstacle_instance.position.y = randf_range(GlobalVarGd.OBSTACLE_RAND_Y_FROM, GlobalVarGd.OBSTACLE_RAND_Y_TO)
	# 把创造的障碍物场景作为子节点
	add_child(obstacle_instance)
	
func _on_timer_timeout():
	init_obstacles()
	
	

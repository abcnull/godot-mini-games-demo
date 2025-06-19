extends Node2D

## 地板障碍物，做碰撞检测

@onready var obstacle_area: Area2D = %ObstacleArea # 障碍物区域
func _ready() -> void:
	obstacle_area.body_entered.connect(_on_obstacle_area_body_entered)

func _on_obstacle_area_body_entered(body: Node2D):
	# 游戏结束
	if body is Bird:
		body.died()

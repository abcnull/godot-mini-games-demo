extends Node2D

## 障碍物的向后移动的逻辑，障碍物消失的逻辑，碰撞检测的逻辑

@onready var obstacle_area: Area2D = %ObstacleArea # 障碍物区域
@onready var score_area: Area2D = %ScoreArea # 得分区域
func _ready() -> void:
	obstacle_area.body_entered.connect(_on_obstacle_area_body_entered)
	score_area.body_exited.connect(_on_score_area_body_exited)
	
func _physics_process(delta: float) -> void:
	position.x += GlobalVarGd.OBSTACLE_SPEED * delta
	# 判断障碍物该不该销毁
	if global_position.x < GlobalVarGd.BORD_X:
		queue_free()

## 碰撞到障碍物
func _on_obstacle_area_body_entered(node: Node2D):
	# 游戏结束
	if node is Bird:
		node.died()

## 得分了
func _on_score_area_body_exited(node: Node2D):
	# 得分
	if node is Bird:
		node.add_score() 

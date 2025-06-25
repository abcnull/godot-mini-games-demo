extends Node2D

## 游戏主程序，监听启动

var is_launched = false # 小球是否发射

func _ready() -> void:
	get_tree().paused = false
	EventBus.ball_over.connect(_on_ball_over)

# 按键触发开始
func _unhandled_key_input(event: InputEvent) -> void:
	if is_launched:
		return
	if event.is_action_pressed("launch"):
		start_game() # 开始游戏

# 游戏开始
func start_game() -> void:
	# 游戏开始
	$Ball.launch()
	is_launched = true

# 按钮重新开始点击时
func _on_button_pressed() -> void:
	$CanvasLayer.visible = false # 重新开始按钮消失
	# 清理所有砖块和墙体
	for brick: Brick in $BrickAndWall.bricks.values():
		brick.hit()
	for wall: Wall in $BrickAndWall.walls:
		wall.release()
	# 释放当前旧的场景的所有内容
	for child in get_children():
		child.queue_free()
	# 延迟一帧后再切换场景
	await get_tree().create_timer(0.1).timeout
	# 切换场景后，paused = true 会传递到新场景中，因为其属于 SceneTree 的全局属性
	get_tree().change_scene_to_file("res://main.tscn") # 重新切到主场景中

# 游戏结束时
func _on_ball_over():
	get_tree().paused = true # 游戏暂停
	$CanvasLayer.visible = true # 重新开始 btn 可见
	

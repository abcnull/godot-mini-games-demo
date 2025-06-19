extends CharacterBody2D

## 小鸟主角

class_name Bird

func _physics_process(delta: float) -> void:
	velocity += Vector2.DOWN * GlobalVarGd.GRAVITY * delta
	# 开始运动
	move_and_slide()
	
func _input(event): 
	if event.is_action_pressed("flap"):
		velocity += Vector2.UP * GlobalVarGd.UP_ACC

## 得分了	
func add_score():
	GameManagerGd.add_score()

## 角色死亡
func died():
	GameManagerGd.on_bird_died()

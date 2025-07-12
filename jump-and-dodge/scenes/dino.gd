extends CharacterBody2D

const GRAVITY : int = 4200 # 重力加速度
const UP_ACC : int = -100000 # 向上加速度

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var run_col: CollisionShape2D = $RunCol
@onready var squat_col: CollisionShape2D = $SquatCol
@onready var jump_sound: AudioStreamPlayer = $JumpSound

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	# 如果游戏没开始
	if !get_parent().game_running: # 游戏没开始
		# 播放站立画面
		animated_sprite_2d.play("stand")
		return
		
	# 如果角色在空中，那么什么都不做
	if !is_on_floor():
		move_and_slide()
		return
	
	# 游戏开始的情况
	if Input.is_action_pressed("ui_accept") || Input.is_action_just_pressed("ui_up"):
		# 跳跃状态
		run_col.disabled = false
		squat_col.disabled = true
		velocity.y += UP_ACC * delta
		# 播放
		animated_sprite_2d.play("jump")
		# 音乐
		jump_sound.play()
	elif Input.is_action_pressed("ui_down"):
		# 下蹲状态
		run_col.disabled = true
		squat_col.disabled = false
		# 播放
		animated_sprite_2d.play("squat_run")
	else:
		# 正常 run 状态
		run_col.disabled = false
		squat_col.disabled = true
		# 播放
		animated_sprite_2d.play("run")
	
	# 执行运动
	# 对于一个在地面上行走的角色，通常推荐使用 move_and_slide 方法
	# 因为 move_and_slide 会自动处理与环境的碰撞
	move_and_slide()

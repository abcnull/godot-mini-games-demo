extends PanelContainer

## 游戏结束界面

@onready var current_score: Label = %CurrentScore
@onready var hightest_score: Label = %HightestScore
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton
func _ready():
	quit_button.pressed.connect(_on_quit_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	SignalBusGd.died_signal.connect(_on_bird_died)
	
# 获取得分
func get_score():
	# 当局得分展现
	current_score.text = str(GameManagerGd.now_score)
	# 最高分展现
	hightest_score.text = str(GameManagerGd.highest_score)

## 点击结束时	
func _on_quit_button_pressed():
	GameManagerGd.end_game()

## 重新开始时
func _on_restart_button_pressed():
	visible = false # 结束界面消失
	GameManagerGd.restart_game() # 游戏重新开始

## 角色死亡时	
func _on_bird_died():
	get_score() # 获取得分
	visible = true # 结束界面可见

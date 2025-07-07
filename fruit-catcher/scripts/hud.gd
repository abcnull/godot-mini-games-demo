extends CanvasLayer

signal start_game # 开始游戏信号

@onready var score_label: Label = $ScoreLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var start_button: Button = $StartButton

## 游戏开始时候展示
func show_hud(score: int, health: int):
	update_score(score)
	update_health(health)

## 当最初的“开始”按钮被点击时
func _on_start_button_pressed():
	start_button.hide() # 开始按钮隐藏
	start_game.emit() # 发送开始游戏信号

## 把 score 更新到 score_label 上
func update_score(score):
	score_label.text = "得分: " + str(score)

## 把 new_health 更新到 health_bar 上
func update_health(new_health):
	health_bar.value = new_health

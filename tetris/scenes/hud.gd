extends CanvasLayer

signal start_btn_pressed

@onready var game_over_label: Label = $GameOverLabel
@onready var score_label: Label = $ScoreLabel

## on 重新开始按钮按下
func _on_start_button_pressed() -> void:
	start_btn_pressed.emit()
	
## 隐藏 game over label
func hide_gameover_label():
	game_over_label.hide()

## 游戏结束展示
func show_gameover_label():
	game_over_label.show()

## 设置得分
func set_score(score: int):
	score_label.text = "得分：" + str(score)

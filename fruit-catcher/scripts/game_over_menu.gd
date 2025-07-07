extends CanvasLayer

signal restart # 重新开始游戏信号
signal exit # 结束信号

@onready var final_score_label: Label = $FinalScoreLabel

## 展示游戏结束
func show_game_over(score):
	final_score_label.text = "本局得分: " + str(score) # 得分
	show() # 展示

## 重新开始信号
func _on_restart_button_pressed():
	restart.emit()

## 结束游戏信号
func _on_exit_button_pressed():
	exit.emit()

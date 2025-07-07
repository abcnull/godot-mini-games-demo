extends CanvasLayer

signal resume # 继续游戏信号
signal exit # 结束信号

## 展示游戏暂停界面
func show_pause_game():
	show()

## 继续游戏信号
func _on_resume_button_pressed():
	resume.emit()

## 结束游戏信号
func _on_exit_button_pressed():
	exit.emit()

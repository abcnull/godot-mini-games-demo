extends CanvasLayer

## 给 GameOverMenu 定义一个信号 restart
## 信号发送：button => GameOverMenu => Tic-Tac-Toe
signal restart

## 重新开始按钮被点击
func _on_restart_button_pressed():
	restart.emit()

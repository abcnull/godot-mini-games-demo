extends CanvasLayer

## 展示开始按钮
func show_start_btn():
	$StartLabel.show()
	
## 隐藏开始按钮
func hide_start_btn():
	$StartLabel.hide()


## 得分更新上去
func update_score(score: int):
	$ScoreLabel.text = "距离: " + str(score)

## 最高分更新上去
func update_high_score(score: int):
	$HighScoreLabel.text = "最远距离: " + str(score)

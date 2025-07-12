extends StaticBody2D

## 返回地面高度
func get_ground_height() -> int:
	return $Sprite2D.texture.get_height()
	

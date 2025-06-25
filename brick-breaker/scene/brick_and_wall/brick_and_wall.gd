class_name BrickAndWall
extends Node2D

## 墙和砖块绘制和设置

# 墙
const THICKNESS = 10 # 墙体厚度
var walls: Array[Wall] = [] # 墙数组（左，上，右）
# 砖块
const GAP = Vector2(10, 10) # 间距
var bricks: Dictionary[RID, Brick] = {} # 砖块字典

@onready var rect = get_viewport_rect() # 获取视口 rect
# 刚开始时候，就绘制砖块，和墙体
func _ready() -> void:
	EventBus.ball_collided.connect(_on_ball_collided)
	build_wall()
	build_brick()

# 绘制墙体
func build_wall() -> void:
	# 左
	walls.append(Wall.new(Rect2(0, 0, THICKNESS, rect.size.y)))
	# 上
	walls.append(Wall.new(Rect2(0, 0, rect.size.x, THICKNESS)))
	# 右
	walls.append(Wall.new(Rect2(rect.size.x - THICKNESS, 0, THICKNESS, rect.size.y)))
	# 遍历每面墙，并绘制
	for wall in walls:
		# get_canvas_item() 获取 CanvasItem 专门用来绘制的，这里提供出来给 Wall 来绘制
		# get_world_2d() 获取 World2D 实例，它用来管理 2d 世界的物理模拟
		# 每个场景的 2D 物理系统运行在一个独立的 物理空间（Physics Space） 中，get_world_2d().space 返回一个 RID（Resource ID），它是对该物理空间的唯一标识符
		# 这里设置墙的物体碰撞区域
		wall.build_wall(get_canvas_item(), get_world_2d().space)

# 绘制砖块
func build_brick() -> void:
	for i in 3:
		for j in 15:
			var pos = 2 * GAP + Vector2( (Brick.SIZE.x + GAP.x) * j , (Brick.SIZE.y + GAP.y) * i ) # 位置
			var brick = Brick.new(pos) # 生成砖块
			# 绘制砖块
			brick.build_brick(get_canvas_item(), get_world_2d().space)
			# rid 和砖块添加到字典
			bricks[brick.child_body] = brick

# 当小球发生了碰撞（砖块或者滑板）
func _on_ball_collided(collider_rid: RID) -> void:
	var brick = bricks.get(collider_rid)
	# 如果碰撞的是砖块不是滑板
	if brick:
		# 字典剔除砖块
		bricks.erase(collider_rid)
		# 执行砖块被击中的逻辑
		brick.hit()
	# 游戏结束
	if bricks.size() == 0:
		EventBus.ball_over.emit() # 小球发出结束信号
		

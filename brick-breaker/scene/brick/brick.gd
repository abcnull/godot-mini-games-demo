class_name Brick
extends RefCounted

var brick_position: Vector2 # 砖块位置
const SIZE = Vector2(40, 15) # 砖块长宽

var child_rid: RID # canvas
var child_body: RID # 物理体
var child_shape: RID # 碰撞区域

const BRICK_LAYER = 1 << 3 # 位掩码，表示设置第 3 层
const BRICK_MASK = 1 << 0 # 位掩码，表示可与 0 层碰撞

# 砖块的构造函数
func _init(_brick_position: Vector2) -> void:
	self.brick_position = _brick_position

# 砖块设置
func build_brick(parent_rid: RID, space: RID) -> void:
	# 绘制砖块
	child_rid = RenderingServer.canvas_item_create()
	# 设置父级 CanvasItem
	RenderingServer.canvas_item_set_parent(child_rid, parent_rid)
	# 添加矩形，持久化的资源，不需要 _draw 每帧绘制，由 RenderingServer 渲染服务持续管理
	RenderingServer.canvas_item_add_rect(child_rid, Rect2(brick_position, SIZE), Color.ORANGE_RED)
	
	# 设置物理体
	child_body = PhysicsServer2D.body_create()
	# 设置碰撞模式
	PhysicsServer2D.body_set_mode(child_body, PhysicsServer2D.BODY_MODE_STATIC)
	# 设置所属物理空间
	PhysicsServer2D.body_set_space(child_body, space)
	# 设置所属层
	PhysicsServer2D.body_set_collision_layer(child_body, BRICK_LAYER)
	# 设置碰撞层
	PhysicsServer2D.body_set_collision_mask(child_body, BRICK_MASK)
	
	# 设置碰撞区域
	child_shape = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(child_shape, SIZE / 2)
	
	# 设置偏移量
	var transform2d = Transform2D.IDENTITY
	# 砖块中心点
	transform2d.origin = brick_position + SIZE / 2
	
	# 物理体绑定碰撞区域，同时设置砖块中心偏移多少
	PhysicsServer2D.body_add_shape(child_body, child_shape, transform2d)


# 砖块被碰撞时的逻辑
func hit() -> void:
	# 砖块释放 碰撞区域
	RenderingServer.free_rid(child_shape)
	# 立即从物理空间移除碰撞体
	PhysicsServer2D.body_set_space(child_body, RID())
	# 砖块释放 物理体
	PhysicsServer2D.free_rid(child_body)
	# 砖块释放 canvas
	RenderingServer.free_rid(child_rid)

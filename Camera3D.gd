extends Camera3D

#Included from source:
#https://github.com/Ryan-Mirch/Line-and-Sphere-Drawing/blob/main/Draw3D.gd
## 1 -> Lasts ONLY for current physics frame
## >1 -> Lasts X time duration.
## <1 -> Stays indefinitely
func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return await final_cleanup(mesh_instance, persist_ms)

#Modified from source:
#https://godotforums.org/d/26009-solved-view-frustum-8-corners-in-world-space/2
func DrawViewFrustum():
	var m_FarOffset:float =  self.far
	var m_NearOffset:float = self.near
	var m_ScreenWidth:float  = self.get_viewport().size.x
	var m_ScreenHeight:float = self.get_viewport().size.y
	var m_AspectRatio:float = (m_ScreenWidth / m_ScreenHeight) if (m_ScreenWidth > m_ScreenHeight) else (m_ScreenHeight / m_ScreenWidth)
	var m_FarHeight:float = 2.0 * (tan(self.fov / 2.0)) * m_FarOffset
	var m_FarWidth:float = m_FarOffset * m_AspectRatio
	m_FarHeight = m_FarHeight + ((m_FarHeight/ 7) * 3)
	m_FarWidth  = m_FarWidth  + ((m_FarWidth / 7) * 3)
	var m_Forward:Vector3 = self.global_transform.origin + Vector3.FORWARD * m_FarOffset
	#Near World
	var m_NearTopLeft:Vector3     = self.project_position(Vector2(0, 0), self.near)
	var m_NearTopRight:Vector3    = self.project_position(Vector2(m_ScreenWidth, 0), self.near)
	var m_NearBottomLeft:Vector3  = self.project_position(Vector2(0, m_ScreenHeight), self.near)
	var m_NearBottomRight:Vector3 = self.project_position(Vector2(m_ScreenWidth, m_ScreenHeight), self.near)
	#Far Local
	var m_FarTopLeft     = m_Forward + (Vector3.UP * m_FarHeight / 2.0) - (Vector3.RIGHT * m_FarWidth / 2.0)
	var m_FarTopRight    = m_Forward + (Vector3.UP * m_FarHeight / 2.0) + (Vector3.RIGHT * m_FarWidth / 2.0)
	var m_FarBottomLeft  = m_Forward - (Vector3.UP * m_FarHeight / 2.0) - (Vector3.RIGHT * m_FarWidth / 2.0)
	var m_FarBottomRight = m_Forward - (Vector3.UP * m_FarHeight / 2.0) + (Vector3.RIGHT * m_FarWidth / 2.0)
	#Far World
	m_FarTopLeft     = self.transform * (m_FarTopLeft)
	m_FarTopRight    = self.transform * (m_FarTopRight)
	m_FarBottomRight = self.transform * (m_FarBottomRight)
	m_FarBottomLeft  = self.transform * (m_FarBottomLeft)
	#Draw Lines
	var frl:Color = Color.AQUA
	var nrl:Color = Color.AQUAMARINE
	var ll:Color = Color.BLUE_VIOLET
	var rl:Color = Color.DARK_MAGENTA
	#Far rect lines
	self.line(m_FarTopLeft, m_FarTopRight, frl, 1)
	self.line(m_FarTopRight, m_FarBottomRight, frl, 1)
	self.line(m_FarBottomRight, m_FarBottomLeft, frl, 1)
	self.line(m_FarBottomLeft, m_FarTopLeft, frl, 1)
	#Near rect lines
	self.line(m_NearTopLeft, m_NearTopRight, nrl, 1)
	self.line(m_NearTopRight, m_NearBottomRight, nrl, 1)
	self.line(m_NearBottomRight, m_NearBottomLeft, nrl, 1)
	self.line(m_NearBottomLeft, m_NearTopLeft, nrl, 1)
	#Left lines
	self.line(m_NearTopLeft, m_FarTopLeft, ll, 1)
	self.line(m_NearBottomLeft, m_FarBottomLeft, ll, 1)
	#Right lines
	self.line(m_NearTopRight, m_FarTopRight, rl, 1)
	self.line(m_NearBottomRight, m_FarBottomRight, rl, 1)

func _ready():
	DrawViewFrustum()
func _process(delta):
	DrawViewFrustum()

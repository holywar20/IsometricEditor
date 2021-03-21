extends Node2D

signal scroll_update_needed()

enum TEXTURE_TYPES {
	BOX , EVEN_INCLINE , DIAMOND_INCLINE, FLAT_TOP_CORNER, FLAT_BASE_CORNER 
}

const TEXTURE_TYPE_PROPS = {
	TEXTURE_TYPES.BOX : {} ,
	TEXTURE_TYPES.EVEN_INCLINE : {},
	TEXTURE_TYPES.DIAMOND_INCLINE : {} ,
	TEXTURE_TYPES.FLAT_TOP_CORNER : {},
	TEXTURE_TYPES.FLAT_BASE_CORNER : {}
}

const TEST_COLS = 5

const SHEET_COLUMNS = 4
const SHEET_ROWS = 12

export(int) var tile_radius = 72

export(Texture) var top_texture
export(Color) var top_tint = Color.white

export(Texture) var left_texture
export(Color) var left_tint = Color.white

export(Texture) var right_texture
export(Color) var right_tint = Color.white

export(bool) var drop_top = false
export(bool) var bevel_top = false
export(int, 1, 8) var granules = 1
export(float, -0.95, 0.95) var warp = 0.0
export(bool) var outline_shadow = false

var fullFaceUvs = PoolVector2Array([
	Vector2(0, 0) ,  Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)
])

var halfFaceUvs = PoolVector2Array([
	Vector2(0, 0.5), Vector2(1, 0.5), Vector2(1, 1) ,Vector2(0, 1)
])

var cornerFaceUvs = PoolVector2Array([
	
])

var rampFaceUVs  = [
	# LEFT RAMP
	PoolVector2Array([
		Vector2(0, 0) , Vector2(1, 1) , Vector2(1, 1) , Vector2(0, 1)
	]),
	# DOWN RAMP
	PoolVector2Array([
		Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)
	]),
	# Right Ramp 
	PoolVector2Array([
		Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1)
	]),
	# UP RAMP
	PoolVector2Array([
		Vector2(0, 1) , Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)
	])
]

var full_face_uvs = PoolVector2Array()
var ramp_face_uv_array = [PoolVector2Array(), PoolVector2Array(), PoolVector2Array(), PoolVector2Array()]
var half_face_uvs = PoolVector2Array()
var corner_face_uvs = PoolVector2Array()

enum FACING {
	LEFT , DOWN , RIGHT, UP
}
var directionVectors = [Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT, Vector2.UP]
var facing_vectors = [Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT, Vector2.UP]

func _ready():
	generate_uvs()
	var scroll_radius = 72
	get_parent().size = Vector2(scroll_radius * 2 * TEST_COLS, scroll_radius * 2 * SHEET_ROWS)

func _draw():
	get_parent().size = Vector2(tile_radius * 2 * TEST_COLS, tile_radius * 2 * SHEET_ROWS)
	var row = 0
	
	drawEvenBox( 1 , 4 )
	drawRamp( 2 , 4 )
	drawRamp( 3 , 4 )
	drawRamp( 4 , 4 )
	drawRamp( 5 , 4 )
	
	row = 6
	drawFlatTopCorner( row, 4 )
	row += 1
	drawFlatBottomCorner( row , 4 )
	row += 1
	for col in range(SHEET_COLUMNS):
		var local_offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var local_direction = facing_vectors[col]
		var local_uv = half_face_uvs
		
		var left_points = generate_left_face(tile_radius, local_offset, tile_radius / 2)
		var right_points = generate_right_face(tile_radius, local_offset, tile_radius / 2)
		if col == 2:
			left_points[0] += Vector2(0, tile_radius / 2)
		if col == 3:
			right_points[0] += Vector2(0, tile_radius / 2)
		if not col == 1:
			draw_colored_polygon(left_points, left_tint, local_uv, left_texture, null, true)
		if not col == 0:
			if col == 3:
				local_uv[0] = Vector2(0, 1)
			draw_colored_polygon(right_points, right_tint, local_uv, right_texture, null, true)
		var top_points = generate_top_halframp_face(tile_radius, local_offset, local_direction)
		draw_colored_polygon(top_points, top_tint, full_face_uvs, top_texture, null, true)
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, top_points, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, top_points, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in top_points:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)
	row += 1
	for col in range(SHEET_COLUMNS):
		var local_offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var local_direction = facing_vectors[col]
		var local_uv = half_face_uvs
		var left_points = generate_left_face(tile_radius, local_offset, tile_radius / 2)
		if col == 2:
			left_points[0] += Vector2(0, tile_radius / 2)
		draw_colored_polygon(left_points, left_tint, local_uv, left_texture, null, true)
		var right_points = generate_right_face(tile_radius, local_offset, tile_radius / 2)
		if col == 0:
			right_points[0] += Vector2(0, tile_radius / 2)
			local_uv[0] = Vector2(0, 1)
		draw_colored_polygon(right_points, right_tint, local_uv, right_texture, null, true)
		var top_points = generate_top_halfhighcorner_face(tile_radius, local_offset, local_direction)
		var preserved_top = top_points
		var top_uvs = full_face_uvs
		if col == 0 or col == 2:
			top_points = rotate_points(top_points)
			top_uvs = rotate_points(top_uvs)
		if col == 3:
			top_uvs[0] = Vector2(0.5, 0.5)
		draw_colored_polygon(top_points, top_tint, top_uvs, top_texture, null, true)
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, preserved_top, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, preserved_top, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in preserved_top:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)
	row += 1
	for col in range(SHEET_COLUMNS):
		var local_offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var local_direction = facing_vectors[col]
		var local_uv = half_face_uvs
		var left_points = generate_left_face(tile_radius, local_offset, tile_radius / 2)
		if col == 0 or col == 3:
			if col == 3:
				left_points[0] += Vector2(0, tile_radius / 2)
			draw_colored_polygon(left_points, left_tint, local_uv, left_texture, null, true)
		var right_points = generate_right_face(tile_radius, local_offset, tile_radius / 2)
		if col == 2 or col == 3:
			if col == 3:
				right_points[0] += Vector2(0, tile_radius / 2)
				local_uv[0] = Vector2(0, 1)
			draw_colored_polygon(right_points, right_tint, local_uv, right_texture, null, true)
		var top_points = generate_top_halfcorner_face(tile_radius, local_offset, local_direction)
		var preserved_top = top_points
		var top_uvs = full_face_uvs
		if col == 0 or col == 2:
			top_points = rotate_points(top_points)
			top_uvs = rotate_points(top_uvs)
		if col == 3:
			top_uvs[2] = Vector2(0.5, 0.5)
		draw_colored_polygon(top_points, top_tint, top_uvs, top_texture, null, true)
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, preserved_top, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, preserved_top, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in preserved_top:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)
	row += 1
	for col in range(SHEET_COLUMNS):
		var local_offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var local_direction = facing_vectors[col]
		var local_uv = half_face_uvs
		var left_points = generate_left_face(tile_radius, local_offset, tile_radius / 2)
		if col == 0:
			left_points[0] -= Vector2(0, tile_radius / 2)
			local_uv[0] = Vector2(0, 0)
		if col == 2:
			left_points[0] += Vector2(0, tile_radius / 2)
		if col == 3:
			left_points[1] -= Vector2(0, tile_radius / 2)
			local_uv[1] = Vector2(1, 0)
		draw_colored_polygon(left_points, left_tint, local_uv, left_texture, null, true)
		local_uv = half_face_uvs
		var right_points = generate_right_face(tile_radius, local_offset, tile_radius / 2)
		if col == 0:
			right_points[0] += Vector2(0, tile_radius / 2)
			local_uv[0] = Vector2(0, 1)
		if col == 2:
			right_points[0] -= Vector2(0, tile_radius / 2)
			local_uv[0] = Vector2(0, 0)
		if col == 3:
			right_points[1] -= Vector2(0, tile_radius / 2)
			local_uv[1] = Vector2(1, 0)
		draw_colored_polygon(right_points, right_tint, local_uv, right_texture, null, true)
		var top_points = generate_top_diamond_face(tile_radius, local_offset, local_direction)
		draw_colored_polygon(top_points, top_tint, full_face_uvs, top_texture, null, true)
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, top_points, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, top_points, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in top_points:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)
	row += 1
	for col in range(SHEET_COLUMNS):
		var local_offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var shrink_amount = Vector2(0, (tile_radius / 4) * col)
		var left_points = generate_left_face(tile_radius, local_offset, shrink_amount.y)
		var special_uv = full_face_uvs
		special_uv[0] += Vector2(0, float(col) * 0.25)
		special_uv[1] += Vector2(0, float(col) * 0.25)
		draw_colored_polygon(left_points, left_tint, special_uv, left_texture, null, true)
		var right_points = generate_right_face(tile_radius, local_offset, shrink_amount.y)
		draw_colored_polygon(right_points, right_tint, special_uv, right_texture, null, true)
		var top_points = generate_top_face(tile_radius, local_offset + shrink_amount)
		var top_left_triangle = top_points
		var top_right_triangle = top_points
		top_left_triangle.remove(1)
		top_right_triangle.remove(3)
		var left_uv = PoolVector2Array()
		left_uv.append(Vector2(0, 1))
		left_uv.append(Vector2(1, float(col) * 0.25))
		left_uv.append(Vector2(0, float(col) * 0.25))
		var right_uv = PoolVector2Array()
		right_uv.append(Vector2(1, 1))
		right_uv.append(Vector2(0, float(col) * 0.25))
		right_uv.append(Vector2(1, float(col) * 0.25))
		draw_colored_polygon(top_left_triangle, left_tint, left_uv, left_texture, null, true)
		draw_colored_polygon(top_right_triangle, right_tint, right_uv, right_texture, null, true)
	emit_signal("scroll_update_needed")

func drawFlatBottomCorner( row , col ):
	for col in range(SHEET_COLUMNS):
		var local_offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var local_direction = facing_vectors[col]
		var local_uv = ramp_face_uv_array[col]
		var left_points = generate_left_corner_face(tile_radius, local_offset, local_direction)
		if left_points:
			draw_colored_polygon(left_points, left_tint, local_uv, left_texture, null, true)
		var right_points = generate_right_corner_face(tile_radius, local_offset, local_direction)
		if right_points:
			draw_colored_polygon(right_points, right_tint, local_uv, right_texture, null, true)
		var top_points = generate_top_corner_face(tile_radius, local_offset, local_direction)
		draw_colored_polygon(top_points, top_tint, full_face_uvs, top_texture, null, true)
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, top_points, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, top_points, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in top_points:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)

func drawFlatTopCorner( row , column ):
	for col in range(column):
		var local_offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var local_direction = facing_vectors[col]
		var local_uv = full_face_uvs
		var left_points = generate_left_highcorner_face(tile_radius, local_offset, local_direction)
		draw_colored_polygon(left_points, left_tint, local_uv, left_texture, null, true)
		if col == 0:
			local_uv = ramp_face_uv_array[3]
		var right_points = generate_right_highcorner_face(tile_radius, local_offset, local_direction)
		draw_colored_polygon(right_points, right_tint, local_uv, right_texture, null, true)
		var top_points = generate_top_highcorner_face(tile_radius, local_offset, local_direction)
		if col == 3:
			var special_top_uv = full_face_uvs
			special_top_uv[0] = Vector2(0.5, 0.5)
			draw_colored_polygon(top_points, top_tint, special_top_uv, top_texture, null, true)
		else:
			draw_colored_polygon(top_points, top_tint, full_face_uvs, top_texture, null, true)
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, top_points, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, top_points, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in top_points:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)

func drawRamp( row , heightStep ):
	for col in range( heightStep ):
		var offset = Vector2(tile_radius * 2 * col, tile_radius * 2 * row)
		var localDirection = directionVectors[FACING.LEFT]
		var localUv = ramp_face_uv_array[0]
		
		#localUv[0] = localUv[0] + Vector2( 0.5 , 0.5)
		
		#var left_points = generate_left_face(tile_radius, local_offset, tile_radius / 2)
		#var right_points = generate_right_face(tile_radius, local_offset, tile_radius / 2)
		#if col == 2:
		#	left_points[0] += Vector2(0, tile_radius / 2)
		#if col == 3:
		#	right_points[0] += Vector2(0, tile_radius / 2)
		#if not col == 1:
		#	draw_colored_polygon(left_points, left_tint, local_uv, left_texture, null, true)
		#if not col == 0:
		#	if col == 3:
		#		local_uv[0] = Vector2(0, 1)
		
		
		#if col == 3:
		#	local_uv = fullFaceUvs

		var left_points = generate_left_ramp_face(tile_radius, offset, localDirection)
		draw_colored_polygon(left_points, left_tint, localUv, left_texture, null, true)
		localUv = ramp_face_uv_array[col]
		
		var right_points = generate_right_ramp_face(tile_radius, offset, localDirection)
		draw_colored_polygon(right_points, right_tint, localUv, right_texture, null, true)
		
		
		
		
		var top_points = generate_top_ramp_face(tile_radius, offset, localDirection)
		draw_colored_polygon(top_points, top_tint, full_face_uvs, top_texture, null, true)
		
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, top_points, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)
		
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, top_points, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in top_points:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)

func drawEvenBox( row , heightStep ):
	for step in range(heightStep):
		var offset = Vector2(tile_radius * 2 * step, tile_radius * 2 * row)
		var shrink_amount = Vector2(0, float( tile_radius / heightStep ) ) * step
		
		var shorterFaces = fullFaceUvs
		shorterFaces[0] += Vector2(0, float(step * ( 1 / 4 ) ) )
		shorterFaces[1] += Vector2(0, float(step * ( 1 / 4 ) ) )
		
		# Draws Left Face 
		var left_points = generate_left_face(tile_radius, offset, shrink_amount.y)
		draw_colored_polygon(left_points, left_tint, shorterFaces, left_texture, null, true)
		
		# Draws right Face
		var right_points = generate_right_face(tile_radius, offset, shrink_amount.y)
		draw_colored_polygon(right_points, right_tint, shorterFaces, right_texture, null, true)
		
		# Drops Top Face
		var top_points = generate_top_face(tile_radius, offset + shrink_amount)
		draw_colored_polygon(top_points, top_tint, fullFaceUvs, top_texture, null, true)
		
		# TODO : turn to generalized dropTop method 
		if drop_top:
			var edge_data = make_smooth_edgedrop(tile_radius, top_points, true, true)
			draw_polygon(edge_data.edge, edge_data.colors, edge_data.uvs, top_texture, null, true)

		# TODO : turn to generalized bevelTopMethod
		if bevel_top:
			var bevel_data = make_bevel(tile_radius, top_points, granules)
			if outline_shadow:
				var shadow_points = PoolVector2Array()
				var shadow_color = top_tint.darkened(0.4)
				for point in top_points:
					var s_point = point + Vector2(0, tile_radius / 16)
					shadow_points.append(s_point)
				var shadow_data = make_bevel(tile_radius, shadow_points, granules)
				for shadow in shadow_data:
					draw_colored_polygon(shadow.face, shadow_color, shadow.uvs, top_texture, null, true)
			for unit in bevel_data:
				draw_colored_polygon(unit.face, top_tint, unit.uvs, top_texture, null, true)

func generate_left_face(radius : int, offset : Vector2 = Vector2.ZERO, shrink : float = 0):
	var leftFace = PoolVector2Array()
	
	leftFace.append(Vector2(0, radius / 2 + shrink) + offset)
	leftFace.append(Vector2(radius, radius + shrink) + offset)
	leftFace.append(Vector2(radius, radius * 2) + offset)
	leftFace.append(Vector2(0, 1.5 * radius) + offset)
	
	return leftFace

func generate_left_ramp_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var left_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		left_face.append(Vector2(0, radius / 2) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	if direction == Vector2.DOWN:
		left_face.append(Vector2(0, radius * 1.5) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	if direction == Vector2.RIGHT:
		left_face.append(Vector2(0, radius * 1.5) + offset)
		left_face.append(Vector2(radius, radius) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	if direction == Vector2.UP:
		left_face.append(Vector2(0, radius / 2) + offset)
		left_face.append(Vector2(radius, radius) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	return left_face

func generate_left_corner_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var left_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		left_face.append(Vector2(0, radius / 2) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	if direction == Vector2.UP:
		left_face.append(Vector2(0, radius * 1.5) + offset)
		left_face.append(Vector2(radius, radius) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	return left_face

func generate_left_highcorner_face(radius: int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var left_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		left_face.append(Vector2(0, radius / 2) + offset)
		left_face.append(Vector2(radius, radius) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	if direction == Vector2.DOWN:
		left_face.append(Vector2(0, radius / 2) + offset)
		left_face.append(Vector2(radius, radius) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	if direction == Vector2.RIGHT:
		left_face.append(Vector2(0, radius * 1.5) + offset)
		left_face.append(Vector2(radius, radius) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	if direction == Vector2.UP:
		left_face.append(Vector2(0, radius / 2) + offset)
		left_face.append(Vector2(radius, radius) + offset)
		left_face.append(Vector2(radius, radius * 2) + offset)
		left_face.append(Vector2(0, 1.5 * radius) + offset)
	return left_face

func generate_right_face(radius : int, offset : Vector2 = Vector2.ZERO, shrink : float = 0):
	var right_face = PoolVector2Array()
	right_face.append(Vector2(radius * 2, radius / 2 + shrink) + offset)
	right_face.append(Vector2(radius, radius + shrink) + offset)
	right_face.append(Vector2(radius, radius * 2) + offset)
	right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	return right_face

func generate_right_ramp_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var right_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		right_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	if direction == Vector2.DOWN:
		right_face.append(Vector2(radius * 2, radius / 2) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	if direction == Vector2.RIGHT:
		right_face.append(Vector2(radius * 2, radius / 2) + offset)
		right_face.append(Vector2(radius, radius) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	if direction == Vector2.UP:
		right_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		right_face.append(Vector2(radius, radius) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	return right_face

func generate_right_corner_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var right_face = PoolVector2Array()
	if direction == Vector2.RIGHT:
		right_face.append(Vector2(radius * 2, radius / 2) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	if direction == Vector2.UP:
		right_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		right_face.append(Vector2(radius, radius) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	return right_face

func generate_right_highcorner_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var right_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		right_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		right_face.append(Vector2(radius, radius) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	else:
		right_face.append(Vector2(radius * 2, radius / 2) + offset)
		right_face.append(Vector2(radius, radius) + offset)
		right_face.append(Vector2(radius, radius * 2) + offset)
		right_face.append(Vector2(radius * 2, 1.5 * radius) + offset)
	return right_face

func generate_top_face(radius : int, offset : Vector2 = Vector2.ZERO):
	var top_face = PoolVector2Array()
	top_face.append(Vector2(radius, 0) + offset)
	top_face.append(Vector2(radius * 2, radius / 2) + offset)
	top_face.append(Vector2(radius, radius) + offset)
	top_face.append(Vector2(0, radius / 2) + offset)
	return top_face

func generate_top_ramp_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var top_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		top_face.append(Vector2(radius, 0) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius / 2) + offset)
	if direction == Vector2.DOWN:
		top_face.append(Vector2(radius, 0) + offset)
		top_face.append(Vector2(radius * 2, radius / 2) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.RIGHT:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius / 2) + offset)
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.UP:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(0, radius / 2) + offset)
	return top_face

func generate_top_corner_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var top_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius / 2) + offset)
	if direction == Vector2.DOWN:
		top_face.append(Vector2(radius, 0) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.RIGHT:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius / 2) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.UP:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	return top_face

func generate_top_highcorner_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var top_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		top_face.append(Vector2(radius, 0) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(0, radius / 2) + offset)
	if direction == Vector2.DOWN:
		top_face.append(Vector2(radius, 0) + offset)
		top_face.append(Vector2(radius * 2, radius / 2) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius / 2) + offset)
	if direction == Vector2.RIGHT:
		top_face.append(Vector2(radius, 0) + offset)
		top_face.append(Vector2(radius * 2, radius / 2) + offset)
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.UP:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius / 2) + offset)
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(0, radius / 2) + offset)
	return top_face

func generate_top_halframp_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var top_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius) + offset)
	if direction == Vector2.DOWN:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.RIGHT:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.UP:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius) + offset)
	return top_face

func generate_top_halfcorner_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var top_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius) + offset)
	if direction == Vector2.DOWN:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.RIGHT:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.UP:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	return top_face

func generate_top_halfhighcorner_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var top_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius) + offset)
	if direction == Vector2.DOWN:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius) + offset)
	if direction == Vector2.RIGHT:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.UP:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius) + offset)
	return top_face

func generate_top_diamond_face(radius : int, offset : Vector2 = Vector2.ZERO, direction : Vector2 = Vector2.LEFT):
	var top_face = PoolVector2Array()
	if direction == Vector2.LEFT:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius * 1.5) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius / 2) + offset)
	if direction == Vector2.DOWN:
		top_face.append(Vector2(radius, 0) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius * 2) + offset)
		top_face.append(Vector2(0, radius) + offset)
	if direction == Vector2.RIGHT:
		top_face.append(Vector2(radius, radius / 2) + offset)
		top_face.append(Vector2(radius * 2, radius / 2) + offset)
		top_face.append(Vector2(radius, radius * 1.5) + offset)
		top_face.append(Vector2(0, radius * 1.5) + offset)
	if direction == Vector2.UP:
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(radius * 2, radius) + offset)
		top_face.append(Vector2(radius, radius) + offset)
		top_face.append(Vector2(0, radius) + offset)
	return top_face

func generate_uvs():
	full_face_uvs.append(Vector2(0, 0))
	full_face_uvs.append(Vector2(1, 0))
	full_face_uvs.append(Vector2(1, 1))
	full_face_uvs.append(Vector2(0, 1))
	
	half_face_uvs.append(Vector2(0, 0.5))
	half_face_uvs.append(Vector2(1, 0.5))
	half_face_uvs.append(Vector2(1, 1))
	half_face_uvs.append(Vector2(0, 1))
	# LEFT RAMP
	var left_uv = PoolVector2Array()
	left_uv.append(Vector2(0, 0))
	left_uv.append(Vector2(1, 1))
	left_uv.append(Vector2(1, 1))
	left_uv.append(Vector2(0, 1))
	ramp_face_uv_array[0] = left_uv
	# DOWN RAMP
	var down_uv = PoolVector2Array()
	down_uv.append(Vector2(0, 0))
	down_uv.append(Vector2(1, 0))
	down_uv.append(Vector2(1, 1))
	down_uv.append(Vector2(0, 1))
	ramp_face_uv_array[1] = down_uv
	# RIGHT RAMP
	var right_uv = PoolVector2Array()
	right_uv.append(Vector2(0, 0))
	right_uv.append(Vector2(1, 0))
	right_uv.append(Vector2(1, 1))
	right_uv.append(Vector2(0, 1))
	ramp_face_uv_array[2] = right_uv
	# UP RAMP
	var up_uv = PoolVector2Array()
	up_uv.append(Vector2(0, 1))
	up_uv.append(Vector2(1, 0))
	up_uv.append(Vector2(1, 1))
	up_uv.append(Vector2(0, 1))
	ramp_face_uv_array[3] = up_uv

func make_smooth_edgedrop(radius : int, face : PoolVector2Array, left : bool = true, right : bool = true):
	if face.size() < 4:
		print("Edgedrop Error: Invalid Face")
		return
	var edgedata = {}
	var drop_pixels = radius / 4
	var drop_color_left = Color(left_tint.r, left_tint.g, left_tint.b, 0.0)
	var drop_color_right = Color(right_tint.r, right_tint.g, right_tint.b, 0.0)
	var drop_color_middle = drop_color_left.blend(drop_color_right)
	var rounding = drop_pixels / 8
	var left_start = face[3]
	var mid_start = face[2]
	var right_start = face[1]
	var final_edge = PoolVector2Array()
	var uvs = PoolVector2Array()
	var colors = PoolColorArray()
	if left:
		final_edge.append(left_start)
		uvs.append(Vector2(0, 1))
		colors.append(top_tint)
	if left or right:
		final_edge.append(mid_start)
		uvs.append(Vector2(1, 1))
		colors.append(top_tint)
	if right:
		final_edge.append(right_start)
		uvs.append(Vector2(1, 0))
		colors.append(top_tint)
	if right:
		final_edge.append(right_start + Vector2(0, drop_pixels))
		uvs.append(Vector2(0.75, 0))
		colors.append(drop_color_right)
	if right:
		final_edge.append(mid_start + Vector2(rounding * 2, drop_pixels - rounding))
		uvs.append(Vector2(0.75, 1))
		colors.append(drop_color_right)
	if right or left:
		final_edge.append(mid_start + Vector2(0, drop_pixels))
		uvs.append(Vector2(0.75, 0.75))
		colors.append(drop_color_middle)
	if left:
		final_edge.append(mid_start + Vector2(-rounding * 2, drop_pixels - rounding))
		uvs.append(Vector2(1, 0.75))
		colors.append(drop_color_left)
	if left:
		final_edge.append(left_start + Vector2(0, drop_pixels))
		uvs.append(Vector2(0, 0.75))
		colors.append(drop_color_left)
	# Rotate the Points
	if right and not left:
		var enddex = final_edge.size() - 1
		var vertex = final_edge[enddex]
		final_edge.remove(enddex)
		var uv = uvs[enddex]
		uvs.remove(enddex)
		var color = colors[enddex]
		colors.remove(enddex)
		final_edge.insert(0, vertex)
		uvs.insert(0, uv)
		colors.insert(0, color)
	edgedata["edge"] = final_edge
	edgedata["uvs"] = uvs
	edgedata["colors"] = colors
	return edgedata

func make_bevel(radius : int, face : PoolVector2Array, granularity : int):
	if face.size() < 4:
		print("Edgedrop Error: Invalid Face")
		return
	var granule_set = []
	var shadow_drop = radius / 16
	var height = (radius / 4) - shadow_drop
	var left_start = face[3]
	var mid_start = face[2]
	var right_start = face[1]
	for unit in range(granularity):
		var step = (1.0 / float(granularity)) * float(unit)
		var uv_start = lerp(Vector2(0, 1), Vector2(1, 1), step)
		var uv_extent = lerp(Vector2(0, 1), Vector2(1, 1), (1.0 / float(granularity)) + step)
		var pixel_start = lerp(left_start, mid_start, step)
		var pixel_extent = lerp(left_start, mid_start, (1.0 / float(granularity)) + step)
		var left_granule = make_granule(pixel_start, pixel_extent, uv_start, uv_extent, height, warp, false)
		granule_set.append(left_granule)
		uv_start = lerp(Vector2(1, 0), Vector2(1, 1), step)
		uv_extent = lerp(Vector2(1, 0), Vector2(1, 1), (1.0 / float(granularity)) + step)
		pixel_start = lerp(right_start, mid_start, step)
		pixel_extent = lerp(right_start, mid_start, (1.0 / float(granularity)) + step)
		var right_granule = make_granule(pixel_start, pixel_extent, uv_start, uv_extent, height, warp, true)
		granule_set.append(right_granule)
	return granule_set

func make_granule(left : Vector2, right : Vector2, luv : Vector2, ruv : Vector2, height : int, warp : float = 0.0, flip_uv : bool = false, resolution : int = 8):
	var granule = {}
	var granuleface = PoolVector2Array()
	var guvs = PoolVector2Array()
	granuleface.append(left)
	guvs.append(luv)
	granuleface.append(lerp(left, right, 0.5))
	guvs.append(lerp(luv, ruv, 0.5))
	granuleface.append(right)
	guvs.append(ruv)
	# Calculate Bottom Edge from Right to Left
	for step in range(resolution + 1):
		var increm = (1.0 / float(resolution)) * float(step)
		var vertex = lerp(right, left, increm)
		var uv = lerp(ruv, luv, increm)
		var curve = abs(cos(lerp(PI * 0.5, PI * 1.5, increm))) * 2.0 - 1.0
		var adjusted_warp = curve * warp
		var local_drop = (height / 2) + ((height / 2) * adjusted_warp)
		vertex.y += local_drop
		granuleface.append(vertex)
		if flip_uv:
			uv.x -= (float(local_drop) / float(height)) * 0.25
		else:
			uv.y -= (float(local_drop) / float(height)) * 0.25
		guvs.append(uv)
	granule["face"] = granuleface
	granule["uvs"] = guvs
	return granule

func rotate_points(face : PoolVector2Array):
	var rotated_face = PoolVector2Array()
	for vdex in range(face.size() - 1):
		rotated_face.append(face[vdex + 1])
	rotated_face.append(face[0])
	return rotated_face

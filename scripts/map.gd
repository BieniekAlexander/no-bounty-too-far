# source: https://github.com/SinisperiDump/simple_shade_of_war/blob/main/scripts/main.gd
extends Node2D

@onready var ground_tiles: TileMapLayer = $Terrain
@onready var character: CharacterBody2D = $Character

@onready var shade: Sprite2D = $Shade
@onready var fog: Sprite2D = $Fog
var fog_image: Image = null
var shade_image: Image = null
@onready var sight_spiral_indices: Array = IU.get_square_helical_indices(character.vision_diameter)
@onready var sight_adjacency_array: Array[Array] = TU.get_center_offset_array(character.vision_diameter)
@onready var sight_center_coordinates: Array[Vector2i] = get_center_coordinates(sight_adjacency_array)

## The factor by which the shade is downsampled
@export var shade_compression: int = 16

func _ready() -> void:
    generate_shade()
    generate_fog()

func _process(_delta: float) -> void:
    reveal()

#region LOS
func generate_shade() -> void:
    var world_dimentions = ground_tiles.get_used_rect().size * ground_tiles.tile_set.tile_size
    shade.global_position = world_dimentions / 2
    var scaled_dimentions = world_dimentions / shade_compression
    shade_image = Image.create(world_dimentions.x, world_dimentions.y, false, Image.Format.FORMAT_RGBAH)
    shade_image.fill(Color(0,0,0,1))
    
func generate_fog() -> void:
    var world_dimentions = ground_tiles.get_used_rect().size * ground_tiles.tile_set.tile_size
    fog.global_position = world_dimentions / 2
    fog_image = Image.create(world_dimentions.x, world_dimentions.y, false, Image.Format.FORMAT_RGBAH)

func reveal() -> void:
    # initialize shadows
    fog_image.fill(Color(0,0,0,.5))
    mark_visible(character.global_position)
    
    # shadow casting
    call_count = 0
    for dir in FogQuadrant.CD.values():
        var quadrant: FogQuadrant = FogQuadrant.new(dir, character.global_position)
        var first_row: FogRow = FogRow.new(1, Vector2i(-1, 1), Vector2i(1, 1))
        reveal_iterative(quadrant, first_row)
        
    print(call_count)
    
    fog.texture = ImageTexture.create_from_image(fog_image)
    shade.texture = ImageTexture.create_from_image(shade_image)


## returns the set of coordinates representing the "center" of the square array, accounting for even or odd-lengh sides
func get_center_coordinates(a_array: Array) -> Array[Vector2i]:
    var a_side: int = a_array.size()
    var r_coordinates: Array[Vector2i] = [IU.get_center_index(a_side)]
    
    if a_side%2==0:
        var top_left = r_coordinates[0]
        r_coordinates.append(top_left+Vector2i.RIGHT)
        r_coordinates.append(top_left+Vector2i.DOWN)
        r_coordinates.append(top_left+Vector2i.ONE)
    
    return r_coordinates
    
func mark_visible(a_tile: Vector2i) -> void:
    fog_image.set_pixel(a_tile.x, a_tile.y, Color(0,0,0,0.))
    shade_image.set_pixel(a_tile.x, a_tile.y, Color(0,0,0,0.))
        
func is_blocking(a_coords: Vector2i) -> bool:
    var pp = PhysicsPointQueryParameters2D.new()
    pp.position = a_coords
    pp.collision_mask = 8
    if get_world_2d().direct_space_state.intersect_point(pp, 1): return true
    else: return false
    
func reveal_cell(a_quadrant: FogQuadrant, a_tile: Variant) -> void:
    mark_visible(a_quadrant.transform(a_tile))

func is_wall(a_quadrant: FogQuadrant, a_tile: Variant) -> bool:
    if a_tile == null: return true
    return is_blocking(a_quadrant.transform(a_tile))

static func in_bounds(a_vec: Vector2i, a_bounds: Vector2i) -> bool:
    return a_vec.x>=0 and a_vec.x<a_bounds.x and a_vec.y>=0 and a_vec.y<a_bounds.y

var call_count: int = 0
func reveal_iterative(a_quadrant: FogQuadrant, a_row: FogRow) -> void:
    var rows: Array[FogRow] = [a_row]
    
    while not rows.is_empty():
        var row: FogRow = rows.pop_front()
        var prev_tile: Variant = null
        
        for tile in row.tiles():
            if not in_bounds(a_quadrant.transform(tile), fog_image.get_size()):
                continue
            
            call_count += 1
            var tile_is_wall: bool = is_wall(a_quadrant, tile)
            var prev_tile_is_wall: bool = is_wall(a_quadrant, prev_tile)
            var tile_is_symmetric: bool = FogRow.is_symmetric(row, tile)
            
            if tile_is_wall or tile_is_symmetric:
                reveal_cell(a_quadrant, tile)
            if prev_tile_is_wall and not tile_is_wall:
                row.start_slope = FogRow.slope(tile)
            if not prev_tile_is_wall and tile_is_wall:
                var next_row: FogRow = row.next()
                next_row.end_slope = FogRow.slope(tile)
                rows.append(next_row)
                
            prev_tile = tile
            
        if not is_wall(a_quadrant, prev_tile):
            rows.append(row.next())
#endregion

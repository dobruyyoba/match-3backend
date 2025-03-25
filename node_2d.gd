extends Node2D

@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int

@onready var label_target = $Label
@onready var label_swaps = $Label2
@onready var game_over_sprite = $Sprite2D3


var possible_pieces = [
    preload("res://cosmo-art/figure-1.tscn"),
    preload("res://cosmo-art/figure-2.tscn"),
    preload("res://cosmo-art/figure-3.tscn"),
    preload("res://cosmo-art/figure-4.tscn")    
]
var all_pieces = []
var figure_count = 3
var touch_start_pos = Vector2.ZERO
var selected_piece = null
var is_swapping = false
var time_fall = 0.5
var scale_param = Vector2(2.0, 2.0)
var flag = true
var target_score = 20
var target_peaces = []
var possible_swaps = 10
var target_rand



func _draw():
    var color = Color(1.0, 0.0, 0.0) # Красный цвет
    var pos1 = Vector2(x_start,y_start)
    var pos2 = Vector2(x_start, y_start + offset * height)
    draw_line(pos1, pos2, color)

func _process(delta: float) -> void:
    label_target.text = str(target_score)
    label_target.scale = Vector2(6,6)
    label_target.position = Vector2(340, 420)
    label_swaps.text = str(possible_swaps)
    label_swaps.scale = Vector2(6,6)
    label_swaps.position = Vector2(840, 420)
    if not possible_swaps:
        game_over_sprite.z_index = 100
        game_over_sprite.visible = true
func _input(event):
    if not possible_swaps:
        return
    if is_swapping:
        return
    if event is InputEventMouseButton and event.pressed:
        selected_piece = get_piece_at_position(event.position)
        if selected_piece != null:
            touch_start_pos = event.position
    elif event is InputEventMouseButton and not event.pressed:
        if selected_piece != null:
            var swipe_direction = (event.position - touch_start_pos).normalized()
            var target_piece = get_target_piece(selected_piece, swipe_direction)
            if target_piece != null:
                swap_pieces(selected_piece, target_piece)
            selected_piece = null
    label_target.text = str(target_score)
    label_target.scale = Vector2(6,6)
    label_target.position = Vector2(340, 420)
    label_swaps.text = str(possible_swaps)
    label_swaps.scale = Vector2(6,6)
    label_swaps.position = Vector2(840, 420)
            
func update_swaps_label():
    label_swaps.text = str(possible_swaps)

func _ready() -> void:
    game_over_sprite.visible = false
    all_pieces = make_2d_array()
    for piece in possible_pieces:
        print(piece)
        if piece == null:
            print("ошибка загрузки сцены")
            return
    spawn_pieces()
    while (is_matches()):
        clear_field()
        spawn_pieces()
    spawn_target_peaces()

func make_2d_array():
    var array = []
    for i in width:
        array.append([])
        for j in height:
            array[i].append(null)
    return array
    
func clear_field():
    for i in width:
        for j in height:
            all_pieces[i][j].queue_free()
            all_pieces[i][j] = null
            
func spawn_target_peaces():
    target_rand = floor(randi_range(0, possible_pieces.size() - 1))
    var piece = possible_pieces[target_rand].instantiate()
    var sprite = piece.get_node("Sprite2D")
    sprite.scale = scale_param
    piece.type = target_rand
    add_child(piece)
    piece.position = Vector2(200, 500)
    
func spawn_pieces():
    for i in width:
        for j in height:
            var rand = floor(randi_range(0, possible_pieces.size() - 1))
            var piece = possible_pieces[rand].instantiate()
            var sprite = piece.get_node("Sprite2D")
            sprite.scale = scale_param
            piece.type = rand
            add_child(piece)
            piece.position = grid_to_pixel(i, j)
            print(piece.position)
            piece.grid_x = i
            piece.grid_y = j
            all_pieces[i][j] = piece
            
func find_matches():
    for i in range(width):
        for j in range(height):
            if all_pieces[i][j] != null:
                var sprite = all_pieces[i][j].get_node("Sprite2D")
                sprite.modulate = Color(1, 1, 1)
    # ищем совпадения по горизонтали
    for i in range(width): # Изменено здесь
        for j in range(height):
            if i >= 2 and all_pieces[i][j] != null and all_pieces[i - 1][j] != null and all_pieces[i - 2][j] != null:
                if (all_pieces[i][j].type == all_pieces[i - 1][j].type) and (all_pieces[i][j].type == all_pieces[i - 2][j].type):
                    for k in range(i - 2, i + 1):
                        var sprite = all_pieces[k][j].get_node("Sprite2D")
                        sprite.modulate = Color(0.5, 0.5, 0.5)

    for i in range(width):
        for j in range(height): # Изменено здесь
            if j >= 2 and all_pieces[i][j] != null and all_pieces[i][j - 1] != null and all_pieces[i][j - 2] != null:
                if (all_pieces[i][j].type == all_pieces[i][j - 1].type) and (all_pieces[i][j].type == all_pieces[i][j - 2].type):
                    for k in range(j - 2, j + 1):
                        var sprite = all_pieces[i][k].get_node("Sprite2D")
                        sprite.modulate = Color(0.5, 0.5, 0.5)

func is_matches():
    for i in range(width):
        for j in range(height):
            if i >= 2 and all_pieces[i][j] != null and all_pieces[i - 1][j] != null and all_pieces[i - 2][j] != null:
                if (all_pieces[i][j].type == all_pieces[i - 1][j].type) and (all_pieces[i][j].type == all_pieces[i - 2][j].type):
                    return true

    for i in range(width):
        for j in range(height): # Изменено здесь
            if j >= 2 and all_pieces[i][j] != null and all_pieces[i][j - 1] != null and all_pieces[i][j - 2] != null:
                if (all_pieces[i][j].type == all_pieces[i][j - 1].type) and (all_pieces[i][j].type == all_pieces[i][j - 2].type):
                    return true
                        
func collapse_columns():
    var tweens = []
    for i in width:
        var temp_array = []
        for j in height:
            if all_pieces[i][j] != null:
                temp_array.append(all_pieces[i][j])

        # Перемещаем ненулевые клетки вниз
        for j in range(temp_array.size()):
            var piece = temp_array[j]
            var target_y = height - temp_array.size() + j # Вычисляем новую позицию по вертикали
            var target_position = grid_to_pixel(i, target_y)
            if piece.position != target_position: # Преобразуем в пиксельные координаты
                tweens.append(piece_fall(piece, target_position, time_fall))
            all_pieces[i][target_y] = piece
            all_pieces[i][target_y].type = piece.type
            piece.grid_y = target_y # Обновляем grid_y

        # Заполняем оставшиеся ячейки null
        for j in range(height - temp_array.size()):
            all_pieces[i][j] = null
    return tweens

func fill_empty_cells():
    var tweens = []
    for i in width:
        for j in height:
            if all_pieces[i][j] == null:
                var rand = randi_range(0, possible_pieces.size() - 1)
                var new_piece = possible_pieces[rand].instantiate()
                new_piece.scale = scale_param
                add_child(new_piece)
                new_piece.position = grid_to_pixel(i, -6 + j) # начальная позиция над полем
                new_piece.grid_x = i
                new_piece.grid_y = j
                all_pieces[i][j] = new_piece
                all_pieces[i][j].type = rand
                var time_fall = 2.0
                tweens.append(piece_fall(new_piece, grid_to_pixel(i, j), time_fall))
    return tweens

func piece_fall(cell_node, target_position: Vector2, time_fall, bounce_height: float = 1.2):
    var target_position1 = target_position - Vector2(0, 100)
    var tween = cell_node.create_tween()
    tween.tween_property(cell_node, "position", target_position, time_fall * 0.33).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(cell_node, "position", target_position1, time_fall * 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(cell_node, "position", target_position, time_fall * 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(cell_node, "position", target_position - Vector2(0, 25), time_fall * 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(cell_node, "position", target_position, time_fall * 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(cell_node, "position", target_position - Vector2(0, 12.5), time_fall * 0.025).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(cell_node, "position", target_position, time_fall * 0.025).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
    #tween.tween_property(cell_node, "position", target_position, time_fall * 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
    return tween

                    
func delete_matches():
    for i in width:
        for j in height:
            if all_pieces[i][j] != null:
                var sprite = all_pieces[i][j].get_node("Sprite2D")
                if (sprite.modulate == Color(0.5, 0.5, 0.5)):
                    print(i,j)
                    if (all_pieces[i][j].type == target_rand):
                        target_score -= 1
                    all_pieces[i][j].queue_free()
                    all_pieces[i][j] = null

func grid_to_pixel(column, row):
    var new_x = x_start + offset * column
    var new_y = y_start + offset * row
    return Vector2(new_x, new_y)

func swap_pieces(piece1, piece2):
    is_swapping = true
    
    var temp_pos = piece1.position
    var temp_grid_x = piece1.grid_x
    var temp_grid_y = piece1.grid_y

    # Анимация перемещения спрайтов
    var tween1 = create_tween()
    var tween2 = create_tween()

    tween1.tween_property(piece1, "position", piece2.position, 0.3) # 0.3 - длительность анимации в секундах
    tween2.tween_property(piece2, "position", temp_pos, 0.3)

    # После завершения анимации обновляем grid_x и grid_y
    await tween1.finished
    await tween2.finished

    piece1.grid_x = piece2.grid_x
    piece1.grid_y = piece2.grid_y

    piece2.grid_x = temp_grid_x
    piece2.grid_y = temp_grid_y

    # Обновляем массив all_pieces
    all_pieces[piece1.grid_x][piece1.grid_y] = piece1
    all_pieces[piece2.grid_x][piece2.grid_y] = piece2
    while (is_matches()):
        var tweens = []
        while (is_matches()):
            find_matches()
            delete_matches()
            tweens = collapse_columns()
            for tween in tweens:
                await tween.finished
        tweens = fill_empty_cells()
        for tween in tweens:
            await tween.finished
    for i in width:
        for j in height:
            if (all_pieces[i][j] != null):
                print("print4", all_pieces[i][j].position, all_pieces[i][j].type, i, j)
    possible_swaps -= 1
    is_swapping = false

func get_piece_at_position(position):
    for i in width:
        for j in height:
            var piece = all_pieces[i][j]
            if piece != null:
                var sprite = piece.get_node("Sprite2D")
                if sprite != null and sprite.get_rect().has_point(sprite.to_local(position)):
                    return piece
    return null

func get_target_piece(piece, direction):
    var target_grid_x = piece.grid_x
    var target_grid_y = piece.grid_y

    if abs(direction.x) > abs(direction.y):
        if direction.x > 0:
            target_grid_x += 1
        else:
            target_grid_x -= 1
    else:
        if direction.y > 0:
            target_grid_y += 1
        else:
            target_grid_y -= 1

    if target_grid_x >= 0 and target_grid_x < width and target_grid_y >= 0 and target_grid_y < height:
        return all_pieces[target_grid_x][target_grid_y]
    else:
        return null

extends Node2D

func _draw():
    var parent = get_parent()
    if parent:
        var x_start = parent.x_start
        var y_start = parent.y_start
        var offset = parent.offset
        var height = parent.height
        var width = parent.width
        var color = Color(0.0, 0.0, 1.0, 0.125)
        for i in range(width-1):
            var pos1 = Vector2(x_start + 100 + i * 200, y_start - 100)
            var pos2 = Vector2(x_start + 100 + i * 200, y_start + offset * height - 100)
            draw_line(pos1, pos2, color, 3)
        for i in range(height-1):
            var pos1 = Vector2(x_start - 100 , y_start + 100 + i * 200)
            var pos2 = Vector2(x_start + offset * width - 100, y_start + i * 200 + 100 )
            draw_line(pos1, pos2, color, 3)
            
            

func _ready():
    queue_redraw()

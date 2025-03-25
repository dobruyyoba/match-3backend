# logger.gd
extends Node

func log(message):
    print(message)
    var file = FileAccess.open("user://app.log", FileAccess.ModeFlags.WRITE)
    if file:
        file.seek_end() # Перемещаемся в конец файла
        file.store_line(message)
        file.close()

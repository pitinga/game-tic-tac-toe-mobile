extends RefCounted
## Game engines share this minimal drawing API; game state is independent of the UI.

const INK := Color("293349")
const SOFT := Color("f6f8ff")
const ACCENT := Color("486dd4")
const SUCCESS := Color("1c956d")

var title := "Mini jogo"
var subtitle := "Divirta-se!"
var score := 0
var ended := false
var message := ""


func reset() -> void:
	score = 0
	ended = false
	message = ""


func tick(_delta: float) -> void:
	pass


func tap(_p: Vector2) -> void:
	pass


func hold(p: Vector2) -> void:
	tap(p)


func swipe(_start: Vector2, _end: Vector2) -> void:
	pass


func pointer(_p: Vector2) -> void:
	pass


func draw_game(_canvas: CanvasItem, _area: Rect2) -> void:
	pass


func label(canvas: CanvasItem, text_value: String, center: Vector2, size: int = 28, color: Color = INK) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	canvas.draw_string(font, Vector2(center.x - width * 0.5, center.y + size * 0.34), text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func cell_rect(area: Rect2, col: int, row: int, columns: int, rows: int, padding: float = 3.0) -> Rect2:
	var width := area.size.x / float(columns)
	var height := area.size.y / float(rows)
	return Rect2(area.position + Vector2(col * width + padding, row * height + padding), Vector2(width - padding * 2.0, height - padding * 2.0))

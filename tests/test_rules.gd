extends SceneTree

const Rules := preload("res://scripts/rules.gd")
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)


func _initialize() -> void:
	var game = Rules.new()
	game.reset()
	check(game.board.size() == 9 and game.winner(game.board) == 0, "tabuleiro vazio")
	check(game.play(4), "jogada central válida")
	check(game.board[4] == 1 and game.board.count(2) == 1, "computador responde")
	check(not game.play(4), "casa ocupada rejeitada")
	check(game.winner([1, 1, 1, 0, 0, 0, 0, 0, 0]) == 1, "vitória horizontal")
	check(game.winner([2, 0, 0, 0, 2, 0, 0, 0, 2]) == 2, "vitória diagonal")
	check(game.winner([1, 2, 1, 1, 2, 2, 2, 1, 1]) == 3, "empate")
	game.reset()
	game.board.assign([2, 2, 0, 1, 1, 0, 0, 0, 0])
	game.ai_turn()
	check(game.board[2] == 2 and game.outcome == 2, "IA escolhe vitória imediata")
	var rect: Rect2 = game.board_rect()
	for i in range(9):
		var col := i % 3
		var row := i / 3
		for delta in [Vector2.ZERO, Vector2(15, 15), Vector2(-15, -15), Vector2(15, -15), Vector2(-15, 15)]:
			game.reset()
			var pixel: Vector2 = rect.position + Vector2((col + 0.5) * rect.size.x / 3.0, (row + 0.5) * rect.size.y / 3.0) + delta
			var normalized: Vector2 = (pixel - Vector2(34, 178)) / Vector2(652, 770)
			game.tap(normalized)
			check(game.board[i] == 1, "casa %d registra exatamente a tocada" % i)
	finish()


func finish() -> void:
	print("Jogo da Velha: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)

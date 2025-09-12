extends TileMap

var puzzle_clueid: Dictionary = {
	"gate": 0,
	"toy_box": 5,
	"tree_house": 6,
	"signboard": 7,
}

func mark_and_update_tile(puzzle: String, tile_id: int) ->void:
	print("received stuff")
	if tile_id > 0:
		var old_tile = self.get_used_cells_by_id(1,tile_id)
		self.set_cell(1, old_tile[0], 0, Vector2i(0, 0))
		self.set_cell(1, old_tile[1], 0, Vector2i(0, 1))
		self.set_cell(1, old_tile[2], 0, Vector2i(1, 0))
		self.set_cell(1, old_tile[3], 0, Vector2i(1, 1))
		
		print("old", old_tile)

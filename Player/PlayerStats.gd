extends Resource
class_name PlayerStats

enum WhichHand {
    NONE,
    LEFT,
    RIGHT
}

signal score_changed(amount, result)

var total_score : int = 0 setget set_total_score


func set_total_score(value : int):
    var change_amount : int = value - total_score
    total_score = value
    emit_signal("score_changed", change_amount, total_score)


func add_total_score(value : int):
    self.total_score += value


func refill_stats():
    self.total_score = 0

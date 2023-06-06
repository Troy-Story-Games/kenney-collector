extends Resource
class_name PlayerStats

enum WhichHand {
    NONE,
    LEFT,
    RIGHT
}

signal score_changed(result)
signal high_score_changed(result)

var total_score : int = 0: set = set_total_score
var high_score : int = 0: set = set_high_score


func set_total_score(value : int):
    total_score = value
    if total_score > self.high_score:
        self.high_score = total_score
    emit_signal("score_changed", total_score)


func set_high_score(value : int):
    high_score = value
    emit_signal("high_score_changed", high_score)


func add_total_score(value : int):
    self.total_score += value
    SaveAndLoad.custom_data.high_score = high_score
    SaveAndLoad.save_game()

extends ItemDrop
# class_name CoinDrop


var amount: int


func collect() -> int:
	queue_free()
	return amount

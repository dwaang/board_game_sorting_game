class_name StatCalculator

# Вариант 1: Линейный с бонусом
# Начинается как линейный, потом чуть ускоряется
static func get_linear_with_bonus(base_value: float, level: float, _exp: float = 2) -> float:
	return base_value * (level + pow(level, _exp) * 0.05)

# Вариант 2: Настраиваемая степень
# Универсальная функция (exponent = 1.0 линейный, 2.0 квадрат)
static func get_scaled_value(base_value: float, level: float, exponent: float = 1.5) -> float:
	return base_value * pow(level, exponent)

# Вариант 3: С ограничением (cap)
# Значение не вырастет больше указанного максимума
static func get_capped_value(base_value: float, level: float, max_value: float = 10.0) -> float:
	var value = base_value * pow(level, 1.5)
	return min(value, base_value * max_value)

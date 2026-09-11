class_name FormatNumber extends Node

static func get_format_number(value: float) -> String:
	return format_number(value)

static func format_number(value: float) -> String:
	if value == 0: return "0"
	
	var suffixes = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
	var abs_val = abs(value)
	var tier = int(floor(log(abs_val) / log(1000.0)))
	
	# Защита от отрицательного логарифма, если число меньше 1.0 (например, 0.5)
	if tier < 0: 
		tier = 0
		
	var suffix = suffixes[tier] if tier < suffixes.size() else "e%d" % (tier * 3)
	var scaled = abs_val / pow(1000.0, tier)
	
	# Форматируем с одной цифрой после запятой для всех случаев
	var formatted = "%.1f" % scaled
	# Если на конце .0 — аккуратно его стираем
	formatted = formatted.trim_suffix(".0")
	
	return ("-" if value < 0 else "") + formatted + suffix

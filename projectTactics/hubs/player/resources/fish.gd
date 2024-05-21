extends Resource
class_name Fish

enum SIZE_CATEGORIES {
	Small,
	Medium,
	Large,
	Massive,
	Emperor
}

@export_category("General")
@export var name:String = ""
@export var minWeight:float = 0.0 :
	get: return minWeight;
	set(newWeight):
		minWeight = newWeight
		if minWeight > maxWeight: maxWeight = minWeight;
@export var maxWeight:float = 0.0
@export var chance:float = 1.0
@export var value:int = 0

@export_category("Stats")
@export var size:int = 1
@export var strength:float = 1
@export var speed:float = 1.0
@export var predictability:float = 1.0

var weight:float
var sizeCategory:SIZE_CATEGORIES
var descriptiveName:String

func spawn():
	weight = randf_range(minWeight, maxWeight)
	var weightVariation:float = maxWeight - minWeight
	descriptiveName = name
	if weight < minWeight + weightVariation * 0.25:
		sizeCategory = SIZE_CATEGORIES.Small
		descriptiveName = "Small " + name
		value *= 0.75
	elif weight < minWeight + weightVariation * 0.6:
		sizeCategory = SIZE_CATEGORIES.Medium
	elif weight < minWeight + weightVariation * 0.9:
		sizeCategory = SIZE_CATEGORIES.Large
		descriptiveName = "Large " + name
		value *= 1.5
	elif weight < minWeight + weightVariation * 0.91:
		sizeCategory = SIZE_CATEGORIES.Massive
		descriptiveName = "Massive " + name
		value *= 2.0
	else:
		sizeCategory = SIZE_CATEGORIES.Emperor
		descriptiveName = "Emperor " + name
		value *= 10.0
		strength *= 2.0
		speed *= 3.0
		predictability *= 3.0
		size = clamp(size * 0.333, 1, 100000)
	descriptiveName += " (" + str(round(weight * 10.0) /10.0) + "kg)"

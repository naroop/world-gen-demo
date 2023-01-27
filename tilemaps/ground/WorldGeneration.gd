##
# 1. Surface should have as many layers as there are biomes.
# 2. Each surface tile should have a terrain set up for that tile.
# 
# Surface tiles are tiles that are considered as the ground or base of the world
# Object tiles are the objects that can spawn when the world is created (rocks, trees, etc)
# 
# TO-DO: 
#	1. Ability to have more than one surface tile for a biome
#	2. Figure out how to make tiles work with being transparent so they can be placed down at any location and look good
#	
##

extends Node2D

var noise: FastNoiseLite
var SCREEN_SIZE := Vector2i(72, 41) # 7241
@onready var surfaceTileMap := $Surface
@onready var objectsTileMap := $Objects

## All spawnable biomes
## All tiles inside surfaceTiles and objectTiles should be contained within Tiles
var Biomes = {
	'ice': {
		'maxAltitude': 0.17,
		'layer': 0,
		'surfaceTiles': {'ice-lake': 100.0},
		'objectTiles' : {},
		'area': []
	},
	'tundra': {
		'maxAltitude': 1.0,
		'layer': 1,
		'surfaceTiles': {'snow': 100.0},
		'objectTiles' : {'tree': 5.0},
		'area': []
	}
}

## Placeholder tiles need to be at Source ID 0 on the Surface TileSet
## Tile names need to match the tile names inside of each biome's surfaceTiles.
var SurfacePlaceholderTiles = {
	'ice-lake': Vector2i(2, 0),
	'snow': Vector2i(5, 0) 
}

## Terrain (autotile) data for each surface tile.
## Each surface tile needs to have a terrain set up, even if there are no autotiles for that tile yet.
##	Draw a 3x3 bitmap over the single tile if there is no autotile mask set up yet.
var TerrainTiles = {
	'ice-lake':  {'terrainSet': 0, 'terrain': 0},
	'snow': {'terrainSet': 0, 'terrain': 1},
}

func _ready():
	generateTerrain(SCREEN_SIZE)
	
func _process(_delta):
	if Input.is_action_just_pressed("space"):
		clearWorldTileMaps()
		for biome in Biomes:
			Biomes[biome].area.clear()
		generateTerrain(SCREEN_SIZE)

func clearWorldTileMaps():
	for node in objectsTileMap.get_children():
		node.queue_free()
	surfaceTileMap.clear()

	
		
func initializeNoise():
	noise = FastNoiseLite.new()
	noise.set_seed(randi())
	noise.set_noise_type(FastNoiseLite.TYPE_SIMPLEX)
	noise.set_fractal_gain(0.4)
	noise.set_fractal_octaves(3)
	noise.set_frequency(0.04)

func generateTerrain(screenSize: Vector2i):
	initializeNoise()
	
	# Place down placeholder tiles for each surface tile
	for x in range(screenSize.x):
		for y in range(screenSize.y):
			var altitude = abs(noise.get_noise_2d(x, y))
			var worldPosition = Vector2i(x, y)
			
			if altitude < Biomes.ice.maxAltitude:
				placeBiomePlaceholderSurfaceTile('ice', worldPosition)
				placeBiomeObject('ice', worldPosition)
				Biomes.ice.area.append(worldPosition)
			elif altitude <= Biomes.tundra.maxAltitude:
				placeBiomePlaceholderSurfaceTile('tundra', worldPosition)
				placeBiomeObject('tundra', worldPosition)
				Biomes.tundra.area.append(worldPosition)
	
	# Fill all placeholder tiles with the correct terrain
	for biome in Biomes:
		for surfaceTile in Biomes[biome].surfaceTiles:
			surfaceTileMap.set_cells_terrain_connect(Biomes[biome].layer, Biomes[biome].area, TerrainTiles[surfaceTile].terrainSet, TerrainTiles[surfaceTile].terrain, false)
			
	
## This function may not work if you try and place down two different tiles within the biome
func placeBiomePlaceholderSurfaceTile(biome: String, worldPosition: Vector2i):
	var spawnRates = Biomes[biome].surfaceTiles # Tiles contained within biome
	var roll = randf_range(0, 100)
	var total = 0.0
	for tileName in spawnRates:
		total += spawnRates[tileName]
		if roll <= total:
			setSurfacePlaceholder(worldPosition, tileName, biome)
			return

func placeBiomeObject(biome: String, worldPosition: Vector2i):
	var spawnRates = Biomes[biome].objectTiles
	var roll = randf_range(0, 100)
	var total = 0.0
	for tileName in spawnRates:
		total += spawnRates[tileName]
		if roll <= total:
			objectsTileMap.set_cell(0, worldPosition, 1, Vector2.ZERO, 1)
			return

func setSurfacePlaceholder(worldPosition: Vector2i, tileName: String, biome: String):
	surfaceTileMap.set_cell(Biomes[biome].layer, worldPosition, 0, SurfacePlaceholderTiles[tileName], 0)

func between(val, start, end):
	if start <= val and val < end:
		return true

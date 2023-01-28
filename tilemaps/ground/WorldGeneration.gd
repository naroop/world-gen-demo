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
var ISLAND_RADIUS := 5
var SCREEN_SIZE := Vector2i(ISLAND_RADIUS * 2 + 20, ISLAND_RADIUS * 2 + 20)
var MAP_CENTER := Vector2i(SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2)

@onready var surfaceTileMap := $Surface
@onready var objectsTileMap := $Objects
@onready var worldBorder := $WorldBorder

## All spawnable biomes
## All tiles inside surfaceTiles and objectTiles should be contained within Tiles
var Biomes = {
	'water': {
		'maxAltitude': 0.17,
		'layer': 0,
		'surfaceTiles': {'water': 100.0},
		'objectTiles' : {},
		'area': []
	},
	'forest': {
		'maxAltitude': 1.0,
		'layer': 1,
		'surfaceTiles': {'grass': 100.0},
		'objectTiles' : {'tree': 5.0},
		'area': []
	}
}

## Placeholder tiles need to be at Source ID 0 on the Surface TileSet
## Tile names need to match the tile names inside of each biome's surfaceTiles.
var SurfacePlaceholderTiles = {
	'water': Vector2i(2, 0),
	'grass': Vector2i(5, 0) 
}

## Terrain (autotile) data for each surface tile.
## Each surface tile needs to have a terrain set up, even if there are no autotiles for that tile yet.
##	Draw a 3x3 bitmap over the single tile if there is no autotile mask set up yet.
var TerrainTiles = {
	'water':  {'terrainSet': 0, 'terrain': 0},
	'grass': {'terrainSet': 0, 'terrain': 1},
}

func _ready():
	DisplayServer.window_set_size(Vector2(SCREEN_SIZE.x * 16, SCREEN_SIZE.y * 16))
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
			if altitude < Biomes.water.maxAltitude or !isTileOnIsland(worldPosition):
				placeBiomePlaceholderSurfaceTile('water', worldPosition)
				placeBiomeObject('water', worldPosition)
				Biomes.water.area.append(worldPosition)
			elif altitude <= Biomes.forest.maxAltitude:
				placeBiomePlaceholderSurfaceTile('forest', worldPosition)
				placeBiomeObject('forest', worldPosition)
				Biomes.forest.area.append(worldPosition)
	
	# Fill all placeholder tiles with the correct terrain
	for biome in Biomes:
		for surfaceTile in Biomes[biome].surfaceTiles:
			surfaceTileMap.set_cells_terrain_connect(Biomes[biome].layer, Biomes[biome].area, TerrainTiles[surfaceTile].terrainSet, TerrainTiles[surfaceTile].terrain, false)
			
	placeWorldBorder()
			
	
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
			
func placeWorldBorder():
	for x in range(SCREEN_SIZE.x):
		for y in range(SCREEN_SIZE.y):
			if x == 0:
				worldBorder.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1))
			elif y == 0 or y == SCREEN_SIZE.y-1:
				worldBorder.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1))
			elif x == SCREEN_SIZE.x-1:
				worldBorder.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1))
				

func setSurfacePlaceholder(worldPosition: Vector2i, tileName: String, biome: String):
	surfaceTileMap.set_cell(Biomes[biome].layer, worldPosition, 0, SurfacePlaceholderTiles[tileName], 0)

func between(val, start, end) -> bool:
	return start <= val and val < end # i think this still works
		
func isTileOnIsland(worldPosition: Vector2i) -> bool:
	return Vector2(worldPosition).distance_to(Vector2(MAP_CENTER)) <= ISLAND_RADIUS

return {
	--string image location
	"tileset/zeroTiles2.png",
	--table name = tileproperty(pass, heightMap, frame, time)
	{clip = tileProperties(2)},
	--number tile size (pixels)
	16,
	--table autoMap properties (maps properties to tiles)
	{clip, clip, clip, clip, clip, clip,
	clip, clip, clip, clip, clip, clip,
	clip, clip, clip, clip, clip, clip,
	clip, clip, clip, clip, clip, clip,
	clip, clip, clip, clip, clip, clip,
	clip, clip, clip, clip, clip, clip}
	--table appeneded tiles (optional)
}
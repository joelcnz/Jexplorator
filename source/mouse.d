//#(highlite for picking brush) not working!
//#more work here (non drawing stuff here
//#this is the difference from the other setTile
//#may not use

// LSystem + 1 for Layer.front
// LSystem + 2 for Layer.normal
// LSystem + 3 for Layer.back
// B for copy from pointer (become)
// G for counting times, (uses what the mouse is over tile)

import base;

struct MouseInput {
	Sprite _drawBrush;
	Vector2f _pos;
	Portal _portal;
	TileName _currentTile;
	TileName[] _tiles;
	TileName[] _tilesNum1;
	TileName[] _tilesNum2;
	TileName[] _tilesNum3;
	TileName[] _tilesNumSelect;
	Layer _layer;
	RectangleShape _square;
	RectangleShape _squareBlack;

	auto pos() { return _pos; }

	this(ref Portal portal) {
		_drawBrush = new Sprite;
		_drawBrush.position = Vector2f(0, g_spriteSize * 10 + 10);
		_drawBrush.setTexture = g_texture;
		_portal = portal;
		_layer = Layer.normal;
		with(_portal) {
			scrn = Vector2i(0,0);
		}
		foreach(tile; TileName.brick .. TileName.end) //#May not use
			_tiles ~= tile;
		
		with(TileName)
			_tilesNum1 = [brick, darkBrick, gap, darkGrayBrick, brickLedge, ledge],
			_tilesNum2 = [potPlant, oilDrum, piller, piller2, spikes],
			_tilesNum3 = [ladder, computer, diamond, rail, hanger, rocket];
		_currentTile = TileName.brick;

		_square = new RectangleShape;
		_squareBlack = new RectangleShape;
		with(_square) {
			size = Vector2f(g_spriteSize, g_spriteSize);
			//fillColor = Color(0,0,0, 0);
			fillColor = Color(128,128,128, 128);
			outlineColor = Color(255,255,255, 180);
			outlineThickness = 2;
		}
		with(_squareBlack) {
			size = Vector2f(g_spriteSize - 4, g_spriteSize - 4);
			fillColor = Color(0,0,0, 0);
			outlineColor = Color(0,0,0, 180);
			outlineThickness = 2;
		}
	}
	
	int countTiles(TileName tile, Layer layer) {
		int count;
		foreach(sy; 0 .. g_scrnDim.y)
			foreach(sx; 0 .. g_scrnDim.x)
				foreach(cy; 0 .. 10)
					foreach(cx; 0 .. 10)
						with(g_screens[sy][sx].tiles[cy][cx]) {
							final switch(layer) {
								case Layer.front:
									if (tileNameFront == tile)
										count++;
								break;
								case Layer.normal:
									if (tileName == tile)
										count++;
								break;
								case Layer.back:
									if (tileNameBack == tile)
										count++;
								break;
							}
						}
		return count;
	}
		
	size_t findNext(T = TileName)(T[] names, T target) {
		assert(names.length > 1);
		import std.algorithm: countUntil;
		size_t idx = names[0 .. $ - 1].countUntil(target);
		if (idx != -1)
			return idx + 1;
		else
			return 0;
	}
	
	void process() {
		_pos = Mouse.getPosition(g_window);

		if (! g_jexTerminal && ! g_doGuiFile && g_mode == Mode.edit) {

			// keys by them selves
			if (! Keyboard.isKeyPressed(Keyboard.Key.LSystem) && ! Keyboard.isKeyPressed(Keyboard.Key.RSystem)) {
			
				// get block from panel
				if (_pos.x >= g_spriteSize && _pos.x < g_spriteSize + _tilesNumSelect.length * g_spriteSize &&
					_pos.y >= g_spriteSize * 10 + 10 && _pos.y < g_spriteSize * 10 + 10 + g_spriteSize &&
					(Mouse.isButtonPressed(Mouse.Button.Right) || Keyboard.isKeyPressed(Keyboard.Key.B))) {
					int x = cast(int)(_pos.x / g_spriteSize) - 1,
						y = 0;
					_currentTile = _tilesNumSelect[x];
				}

				if (lkeys[Letter.j].keyTrigger) {
					if (inBounds(_pos)) {
						bool add = true;
						foreach(i, jeep; g_jeeps)
							if (inScreen(jeep.scrn))
								if (_pos.x >= jeep.pos.x && _pos.x < jeep.pos.x + g_spriteSize &&
									_pos.y >= jeep.pos.y && _pos.y < jeep.pos.y + g_spriteSize) {
									g_jeeps = g_jeeps[0 .. i] ~ g_jeeps[i + 1 .. $];
									add = false;
									break;
								}
						if (add) {
							writeln("New jeep: ", _portal.scrn);
							g_jeeps ~= new Jeep(_pos.makeSquare, _portal.scrn);
						}
					}
				}

				if (lkeys[Letter.p].keyTrigger) {
					auto spot = new RectangleShape;
					with(spot)
						spot.size = Vector2f(g_spriteSize, g_spriteSize),
						fillColor = Color(255,255,255, 255),
						outlineColor = Color(0,0,0, 0),
						outlineThickness = 0;
					bool inside;
					foreach(i; 0 .. 2)
						with(g_guys[i]) {
							inside = placeGuy(this._portal.scrn, this._pos);
							if (inside) {
								resetPos = pos;
								portal.resetPosScrn = portal.scrn;
								writeln("pos = ", pos, " portal.scrn", portal.scrn);
							}
						}
					spot.position = makeSquare(_pos);
				}
				
				if (lkeys[Letter.g].keyTrigger) {
					auto tile = getTile(_pos, _layer);
					
					int count;
					count = countTiles(tile, Layer.front);
					count += countTiles(tile, Layer.normal);
					count += countTiles(tile, Layer.back);
					writeln(tile, " count: ", count); // count tiles

					if (tile == TileName.diamond) {
						g_guys[0].dashBoard.totalDiamonds = count;
						g_guys[1].dashBoard.totalDiamonds = count;
						writeln("Total diamonds");
					}
				}
							
				//if (Keyboard.isKeyPressed(Keyboard.Key.Num1)) {
				if (nkeys[Number.n1].keyTrigger) {
					with(TileName)
						_currentTile = _tilesNum1[findNext(_tilesNum1, getTile(_pos, _layer))];
					_tilesNumSelect = _tilesNum1;
				}
		
				if (nkeys[Number.n2].keyTrigger) {
					with(TileName)
						_currentTile = _tilesNum2[findNext(_tilesNum2, getTile(_pos, _layer))];
					_tilesNumSelect = _tilesNum2;
				}
			
				if (nkeys[Number.n3].keyTrigger) {
					with(TileName)
						_currentTile = _tilesNum3[findNext(_tilesNum3, getTile(_pos, _layer))];
					_tilesNumSelect = _tilesNum3;
				}		
		
				if (_pos.y < g_spriteSize * 10 && (Mouse.isButtonPressed(Mouse.Button.Right) || Keyboard.isKeyPressed(Keyboard.Key.B))) {
					foreach(layer; Layer.back .. Layer.front + 1)
					if (getTile(_pos, cast(Layer)layer) != TileName.gap && getTile(_pos, cast(Layer)layer) != TileName.darkBrick) {
								_currentTile = getTile(_pos, cast(Layer)layer);
								break;
							}
					if (getTile(_pos, Layer.normal) == TileName.gap)
						_currentTile = getTile(_pos, Layer.back);
				}
				
				if (Keyboard.isKeyPressed(Keyboard.Key.W) && Mode.edit) {
					setTile(_portal, _pos, TileName.gap, Layer.front);
					setTile(_portal, _pos, TileName.gap, Layer.normal);
					setTile(_portal, _pos, TileName.darkBrick, Layer.back);
				}

				if ((Mouse.isButtonPressed(Mouse.Button.Left) || Keyboard.isKeyPressed(Keyboard.Key.V)) && g_mode == Mode.edit) {
					// draw a tile at mouse point
					final switch(_layer) {
						case Layer.front:
							setTile(_portal, _pos, _currentTile, Layer.front);
						break;
						case Layer.normal:
							setTile(_portal, _pos, _currentTile, Layer.normal);
						break;
						case Layer.back:
							setTile(_portal, _pos, _currentTile, Layer.back);
						break;
					}
				}
			} // keys by them selfs
		
			// System key held down
			if (Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem)) {
				void layerMessage() {
					writeln("Layer set: ", _layer);
					g_window.display;
					while(Keyboard.isKeyPressed(Keyboard.Key.Num1) ||
						Keyboard.isKeyPressed(Keyboard.Key.Num2) ||
						Keyboard.isKeyPressed(Keyboard.Key.Num3)) {
					}
				}

				if (Keyboard.isKeyPressed(Keyboard.Key.Num1)) {
					_layer = Layer.front;
					
					g_window.clear;
					g_portals[PortalSide.editor].draw(Border.no, Layer.front);
					layerMessage;
				}

				if (Keyboard.isKeyPressed(Keyboard.Key.Num2)) {
					_layer = Layer.normal;
					
					g_window.clear;
					g_portals[PortalSide.editor].draw(Border.no, Layer.normal);
					layerMessage;
				}

				if (Keyboard.isKeyPressed(Keyboard.Key.Num3)) {
					_layer = Layer.back;
					
					g_window.clear;
					g_portals[PortalSide.editor].draw(Border.no, Layer.back);
					layerMessage;
				}

				if (lkeys[Letter.s].keyTrigger) {
					g_building.saveBuilding;
				}
		
				if (lkeys[Letter.l].keyTrigger) {
					g_building.loadBuilding;
				}

				if (kReturn.keyTrigger) {
					g_building.loadBuilding;
					g_building.resetGame;
					/+	
					g_building.loadBuilding;
					g_guys[player1].reset;
					g_guys[player2].reset;
					g_timer.doStart;
					g_mode = Mode.play;
					+/
					writeln("Game level reset!");
				}
			} // system key
		} // if ! terminal
	}
	
	void setTile(Portal portal, Vector2f vec, TileName tile, Layer layer = Layer.normal) {
		if (vec.x >= 0 && vec.x < 320 &&
			vec.y >= 0 && vec.y < 320)
			with(portal) { //#this is the difference from the other setTile
			with(g_screens[scrn.y][scrn.x].tiles[cast(size_t)(vec.y / g_spriteSize)][cast(size_t)(vec.x / g_spriteSize)])
					if (layer == Layer.normal)
						tileName = tile;
					else if (layer == Layer.front)
						tileNameFront = tile;
					else if (layer == Layer.back)
						tileNameBack = tile;
				}
	}
	
	TileName getTile(Vector2f vec, Layer layer = Layer.normal) {
		if (vec.x >= 0 && vec.x < 320 &&
			vec.y >= 0 && vec.y < 320)
			with(_portal) {
				with(g_screens[scrn.y][scrn.x].tiles[cast(size_t)(vec.y / g_spriteSize)][cast(size_t)(vec.x / g_spriteSize)])
					final switch(layer) {
						case Layer.back:
							return tileNameBack;
						case Layer.normal:
							return tileName;
						case Layer.front:
							return tileNameFront;
					}
			}
		return TileName.gap;
	}

	// cursor
	void draw() {
		if (g_doGuiFile)
			return;
		if (_pos.x >= 0 && _pos.y >= 0 && _pos.x < 10 * g_spriteSize && _pos.y < 10 * g_spriteSize) {
			foreach(y; 0 .. 10)
				foreach(x; 0 .. 10) {
					float z, c;
					z = makeSquare(_pos.x);
					c = makeSquare(_pos.y);
					if (x * g_spriteSize == z || y * g_spriteSize == c) {
						with(_square) {
							position = Vector2f(x * g_spriteSize + 2, y * g_spriteSize + 2);
							g_window.draw(_square);
						}
						with(_squareBlack) {
							position = Vector2f(x * g_spriteSize + 4, y * g_spriteSize + 4);
							g_window.draw(_squareBlack);
						}
					}
				}
		}

		_drawBrush.textureRect = IntRect(g_locations[_currentTile].x, g_locations[_currentTile].y, g_spriteSize, g_spriteSize);
		g_window.draw(_drawBrush);

		//#more work here (non drawing stuff here)
		// Selection bar
		Sprite select = new Sprite(g_texture);
		foreach(x, tile; _tilesNumSelect) {
			select.textureRect = IntRect(g_locations[tile].x, g_locations[tile].y, g_spriteSize, g_spriteSize);
			select.position = Vector2f(g_spriteSize + x * g_spriteSize, g_spriteSize*10+10);
			g_window.draw(select);
		}

		if (_pos.x >= g_spriteSize && _pos.x < g_spriteSize + _tilesNumSelect.length * g_spriteSize &&
			_pos.y >= g_spriteSize * 10 + 10 && _pos.y < g_spriteSize * 10 + 10 + g_spriteSize) {

			//#(highlite for picking brush) not working!
			// It gets here!
			//writeln(Vector2f(_pos.x + g_spriteSize, g_spriteSize * 10 + 2).makeSquare);
			_square.position = Vector2f(_pos.x, g_spriteSize * 10).makeSquare + Vector2f(2, 10 + 2);
			g_window.draw(_square);

			_squareBlack.position = Vector2f(_pos.x, g_spriteSize * 10).makeSquare + Vector2f(4, 10 + 4);
			g_window.draw(_squareBlack);
		}
	}
}

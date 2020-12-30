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
	Vec _currentBrushPos;
	int mx,my;
	Vec _pos;
	Portal _portal;
	TileName _currentTile;
	TileName[] _tiles;
	TileName[] _tilesNum1;
	TileName[] _tilesNum2;
	TileName[] _tilesNum3;
	TileName[] _tilesNumSelect;
	Layer _layer;
	JRectangle _square,
		_squareSolid;
	int _whichGuyStartPos;

	auto pos() { return _pos; }

	this(ref Portal portal) {
		_drawBrush = new Sprite();
		_drawBrush = inf[TileName.brick];
		_currentBrushPos = Vec(0, g_spriteSize * 10 + 10);
		_portal = portal;
		_layer = Layer.normal;
		with(_portal) {
			scrn = Vector!int(0,0);
		}
		foreach(tile; TileName.brick .. TileName.end) //#May not use
			_tiles ~= tile;
		
		with(TileName)
			_tilesNum1 = [brick, darkBrick, gap, darkGrayBrick, brickLedge, ledge],
			_tilesNum2 = [potPlant, oilDrum, piller, piller2, spikes],
			_tilesNum3 = [ladder, computer, diamond, rail, hanger, rocket];
		_currentTile = TileName.brick;

		_square = JRectangle(SDL_Rect(0,0,cast(int)g_spriteSize,cast(int)g_spriteSize),
			BoxStyle.outLine,SDL_Color(255,255,255));
		_squareSolid = JRectangle(SDL_Rect(2,2,cast(int)g_spriteSize-4,cast(int)g_spriteSize-4),
			BoxStyle.solid,SDL_Color(0,0,255,64));
		/+
		_squareBlack = new RectangleShape;
		with(_square) {
			size = Vec(g_spriteSize, g_spriteSize);
			//fillColor = Color(0,0,0, 0);
			fillColor = Color(128,128,128, 128);
			outlineColor = Color(255,255,255, 180);
			outlineThickness = 2;
		}
		with(_squareBlack) {
			size = Vec(g_spriteSize - 4, g_spriteSize - 4);
			fillColor = Color(0,0,0, 0);
			outlineColor = Color(0,0,0, 180);
			outlineThickness = 2;
		}
		+/
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
		SDL_PumpEvents();
		SDL_GetMouseState(&mx, &my);
		_pos = Vec(mx,my);

		if (! g_jexTerminal && ! g_doGuiFile && g_mode == Mode.edit) {

			// keys by them selves
			if (! g_keys[SDL_SCANCODE_LCTRL].keyPressed && ! g_keys[SDL_SCANCODE_RCTRL].keyPressed) {

				if (g_keys[SDL_SCANCODE_P].keyTrigger) {
					_whichGuyStartPos = _whichGuyStartPos == player1 ? player2 : player1;
					g_popLine.set(_whichGuyStartPos == player1 ? "Left guy Start spot" : "Right guy start spot");
				}
			
				// get block from panel
				if (_pos.X >= g_spriteSize && _pos.X < g_spriteSize + _tilesNumSelect.length * g_spriteSize &&
					_pos.Y >= g_spriteSize * 10 + 10 && _pos.Y < g_spriteSize * 10 + 10 + g_spriteSize &&
					g_keys[SDL_SCANCODE_B].keyPressed) {
					int x = cast(int)(_pos.X / g_spriteSize) - 1,
						y = 0;
					_currentTile = _tilesNumSelect[x];
				}

				if (g_keys[SDL_SCANCODE_J].keyTrigger) {
					if (inBounds(_pos)) {
						bool add = true;
						foreach(i, jeep; g_jeeps)
							if (inScreen(jeep.scrn))
								if (_pos.x >= jeep.pos.X && _pos.x < jeep.pos.x + g_spriteSize &&
									_pos.y >= jeep.pos.Y && _pos.y < jeep.pos.y + g_spriteSize) {
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
				
				if (g_keys[SDL_SCANCODE_G].keyTrigger) {
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
							
				if (g_keys[SDL_SCANCODE_1].keyTrigger) {
					with(TileName)
						_currentTile = _tilesNum1[findNext(_tilesNum1, getTile(_pos, _layer))];
					_tilesNumSelect = _tilesNum1;
				}
		
				if (g_keys[SDL_SCANCODE_2].keyTrigger) {
					with(TileName)
						_currentTile = _tilesNum2[findNext(_tilesNum2, getTile(_pos, _layer))];
					_tilesNumSelect = _tilesNum2;
				}
			
				if (g_keys[SDL_SCANCODE_3].keyTrigger) {
					with(TileName)
						_currentTile = _tilesNum3[findNext(_tilesNum3, getTile(_pos, _layer))];
					_tilesNumSelect = _tilesNum3;
				}		
		
				if (_pos.Y < g_spriteSize * 10 && g_keys[SDL_SCANCODE_B].keyPressed) {
					foreach(layer; Layer.back .. Layer.front + 1)
						if (getTile(_pos, cast(Layer)layer) != TileName.gap && getTile(_pos, cast(Layer)layer) != TileName.darkBrick) {
								_currentTile = getTile(_pos, cast(Layer)layer);
								break;
							}
					if (getTile(_pos, Layer.normal) == TileName.gap)
						_currentTile = getTile(_pos, Layer.back);
				}
				
				if (g_keys[SDL_SCANCODE_W].keyPressed && Mode.edit) {
					setTile(_portal, _pos, TileName.gap, Layer.front);
					setTile(_portal, _pos, TileName.gap, Layer.normal);
					setTile(_portal, _pos, TileName.darkBrick, Layer.back);
				}

				//gEvent.type == SDL_MOUSEBUTTONDOWN
				if (g_keys[SDL_SCANCODE_V].keyPressed &&
					g_mode == Mode.edit) {
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
			if (g_keys[SDL_SCANCODE_LCTRL].keyPressed || g_keys[SDL_SCANCODE_RCTRL].keyPressed) {
				void layerMessage() {
					writeln("Layer set: ", _layer);
					gGraph.drawning();
					while(g_keys[SDL_SCANCODE_1].keyPressed ||
						g_keys[SDL_SCANCODE_2].keyPressed ||
						g_keys[SDL_SCANCODE_3].keyPressed) {
						SDL_PumpEvents();
					}
				}

				if (g_keys[SDL_SCANCODE_P].keyTrigger) {
					/+
					auto spot = new RectangleShape;
					with(spot)
						spot.size = Vec(g_spriteSize, g_spriteSize),
						fillColor = Color(255,255,255, 255),
						outlineColor = Color(0,0,0, 0),
						outlineThickness = 0;
					+/
					bool inside;
					foreach(i; 0 .. 2)
						if (i == _whichGuyStartPos) with(g_guys[i]) {
							inside = placeGuy(this._portal.scrn, this._pos);
							if (inside) {
								resetPos = pos;
								portal.resetPosScrn = portal.scrn;
								writeln("pos = ", pos, " portal.scrn", portal.scrn);
								g_popLine.set((i == player1 ? "Player 1" : "Player 2") ~ " start position set");
							}
						}
					//spot.position = makeSquare(_pos);
				}

				if (g_keys[SDL_SCANCODE_1].keyPressed) {
					_layer = Layer.front;
					
					//g_window.clear;
					//SDL_SetRenderDrawColor(gRenderer, 0, 0, 0,0);
					//SDL_RenderClear( gRenderer );
					gGraph.clear();

					g_portals[PortalSide.editor].draw(Border.no, Layer.front);
					layerMessage;
				}

				if (g_keys[SDL_SCANCODE_2].keyPressed) {
					_layer = Layer.normal;
					
					//SDL_SetRenderDrawColor(gRenderer, 0, 0, 0,0);
					//SDL_RenderClear( gRenderer );
					gGraph.clear();

					g_portals[PortalSide.editor].draw(Border.no, Layer.normal);
					layerMessage;
				}

				if (g_keys[SDL_SCANCODE_3].keyPressed) {
					_layer = Layer.back;
					
					//SDL_SetRenderDrawColor(gRenderer, 0, 0, 0,0);
					//SDL_RenderClear( gRenderer );
					gGraph.clear();

					g_portals[PortalSide.editor].draw(Border.no, Layer.back);
					layerMessage;
				}
/+
				if (lkeys[Letter.s].keyTrigger) {
					g_building.saveBuilding;
					g_popLine.set("Building saved.");
				}
		
				if (lkeys[Letter.l].keyTrigger) {
					g_building.loadBuilding;
					g_popLine.set("Building loaded.");
				}
+/
				if (g_keys[SDL_SCANCODE_RETURN].keyTrigger) {
					g_building.loadBuilding;
					g_building.resetGame;
					g_campaign.setBriefing;
					g_mode = Mode.play;
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
	
	void setTile(Portal portal, Vec vec, TileName tile, Layer layer = Layer.normal) {
		if (vec.x >= 0 && vec.x < 320 &&
			vec.y >= 0 && vec.y < 320)
			with(portal) { //#this is the difference from the other setTile
			with(g_screens[scrn.y][scrn.x].tiles[cast(size_t)(vec.Y / g_spriteSize)][cast(size_t)(vec.x / g_spriteSize)])
					if (layer == Layer.normal)
						tileName = tile;
					else if (layer == Layer.front)
						tileNameFront = tile;
					else if (layer == Layer.back)
						tileNameBack = tile;
				}
	}
	
	TileName getTile(Vec vec, Layer layer = Layer.normal) {
		if (vec.x >= 0 && vec.x < 320 &&
			vec.y >= 0 && vec.y < 320)
			with(_portal) {
				with(g_screens[scrn.Y][scrn.X].tiles[cast(size_t)(vec.Y / g_spriteSize)][cast(size_t)(vec.x / g_spriteSize)])
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
						_square.pos = Vec(x * g_spriteSize,y * g_spriteSize);
						_square.draw(gGraph);
						_squareSolid.pos = _square.pos + Vec(2,2);
						gWin.blendMode = BlendMode.blend;
						_squareSolid.draw(gGraph);
						gWin.blendMode = BlendMode.none;
						/+
						with(_square) {
							position = Vec(x * g_spriteSize + 2, y * g_spriteSize + 2);
							g_window.draw(_square);
						}
						with(_squareBlack) {
							position = Vec(x * g_spriteSize + 4, y * g_spriteSize + 4);
							g_window.draw(_squareBlack);
						}
						+/
					}
				}
		}

		////_drawBrush.textureRect = IntRect(g_locations[_currentTile].x, g_locations[_currentTile].y, g_spriteSize, g_spriteSize);
		_drawBrush = inf[_currentTile];
		//g_window.draw(_drawBrush);
		gGraph.draw(_drawBrush.image,_currentBrushPos);

		//#more work here (non drawing stuff here)
		// Selection bar
		//Sprite select = new Sprite();
		foreach(x, tile; _tilesNumSelect) {
			//select.textureRect = IntRect(g_locations[tile].x, g_locations[tile].y, g_spriteSize, g_spriteSize);
			//select.position = Vec(g_spriteSize + x * g_spriteSize, g_spriteSize*10+10);
			//g_window.draw(select);
			gGraph.draw(inf[tile].image, Vec(g_spriteSize + x * g_spriteSize, g_spriteSize*10+10));
		}

		if (_pos.x >= g_spriteSize && _pos.x < g_spriteSize + _tilesNumSelect.length * g_spriteSize &&
			_pos.y >= g_spriteSize * 10 + 10 && _pos.y < g_spriteSize * 10 + 10 + g_spriteSize) {

			//#(highlite for picking brush) not working!
			// It gets here!
			//writeln(Vec(_pos.x + g_spriteSize, g_spriteSize * 10 + 2).makeSquare);
			//_square.position = Vec(_pos.X, g_spriteSize * 10).makeSquare + Vec(2, 10 + 2);

			//g_window.draw(_square);

			//_squareBlack.position = Vec(_pos.x, g_spriteSize * 10).makeSquare + Vec(4, 10 + 4);
			//g_window.draw(_squareBlack);
		}
	}
}

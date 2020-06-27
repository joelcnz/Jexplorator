//#out of bounds error
//#bit junky
//#should this be here
//#remed out diamonds print next line
//#not work
//#change here
//#die
//#not sure about this
//#320 didn't work
//#doesn't seem to be needed
//#rocket
//#whopping code block
//#stop on a block in a jump up a screen
//#if bottomLeft or bottomRight in on a ladder and not left in bottom, and not right bottom
//#big fat wrap!
//#Diamond collecting
//#magic number
//# bit funny
import base;

class Guy : Mover {
private:
	int _id,
		_other;
	Sprite[] _framesForward;
	Sprite[] _framesBackward;
	Sprite[] _climb;
	Sprite[] _plopping;
	Sprite _gunAimLeft, _gunAimRight, _gunTriggerLeft, _gunTriggerRight,
		_squatAimLeft, _squatAimRight, _squatTriggerLeft, _squatTriggerRight,
		_rocket;
	Vector2f _rocketDir;
	int _preFrame, _currentFrame, _risingCount, _glideCount;
	Vector2f _resetPos;
	TileName[] _blocks;
	Portal _portal;

	enum Rocket {sitting, goingUp, gone}
	Rocket _rocketState;
	enum StateWalking {walking, standingStill}
	StateWalking _stateWalking;
	enum StateUpDown {rising, gliding, falling, nothing}
	StateUpDown _stateUpDown;
	enum Jumping {yes, no}
	Jumping _jumping;
	Climbing _climbing;
	int _climbingPreFrame;
	int _climbingFrame;
	
	Dying _dying;
	int _dyingCountUp;
	
	Facing _facing;
	
	enum Key {up, right, down, left, shoot}
	Uint8[] _keys;
	
	enum Gun {normal, aiming, trigger}
	Gun _gun;
	GunDucked _gunDucked;
	bool _bullitProof;

	GuyEscapeStatus _escapeStatus;
	PopBanner _banner;
	//Escaped _escaped;
	//Mission _briefing;

	DashBoard _dashBoard;
	Vector2f _plopPoint;

	Hide _hide;

	//CountDown _clock;
public:
	@property {
		int id() { return _id; }

		ref PopBanner banner() { return _banner; }

		Hide hide() { return _hide; }
		void hide(Hide hide0) { _hide = hide0; }

		Vector2f plopPoint() { return _plopPoint; }

		auto ref dashBoard() { return _dashBoard; } //#not sure about this

		//EscapeStatus escaped() { return _escaped.status; }

		//MissionStatus briefing() { return _briefing.status; }
		//void briefing(MissionStatus briefing0) { _briefing.status = briefing0; }
		GuyEscapeStatus escapeStatus() { return _escapeStatus; }
		void escapeStatus(GuyEscapeStatus esc0) { _escapeStatus = esc0; }

		Climbing climbing() { return _climbing; }
		void dying(Climbing climbing0) { _climbing = climbing0; }

		Dying dying() { return _dying; }
		void dying(Dying dying0) { _dying = dying0; }

		GunDucked gunDucked() { return _gunDucked; }
		void gunDucked(GunDucked gunDucked0) { _gunDucked = gunDucked0; }

		Vector2f resetPos() { return _resetPos; }
		void resetPos(Vector2f p) { _resetPos = p; }

		Portal portal() { return _portal; }
		void portal(Portal portal0) { _portal = portal0; }

		//#not work
		version(none) {
			override auto scrn() { return _portal._scrn; }
			override void scrn(Vector2i scrn0) { _portal._scrn = scrn0; };
		}

		int other() { return _other; }
		void other(int other0) { _other = other0; }

		bool bullitProof() { return _bullitProof; }
		void bullitProof(bool bullitProof0) { _bullitProof = bullitProof0; }
	} // property

	//override void scrn

	this(int id, Portal portal, Uint8[] keys) { // if (g_keys[ _keys[Key.shoot] g_keys[keys[Key.shoot]].keyTrigger].keyTrigger)
		_id = id;

		_hide = Hide.inview;

		_dashBoard = DashBoard(this);

		_other = (_id == player1 ? player2 : player1);
		_portal = portal;
		_portal.scrn = Vector2i(0,0);
		_keys = keys;
		bullitProof = true;
		_resetPos = Vector2f(0,0);
		portal.resetPosScrn = Vector2i(0,0);
		doGrace;

		// guyRight1, guyRight2
		foreach(i; [TileName.guyWalkRight1, TileName.guyWalkRight2]) {
			_framesForward ~= new Sprite;
			with(_framesForward[$-1]) {
				setTexture = g_texture;
				textureRect = IntRect(g_locations[i].x, g_locations[i].y, g_spriteSize, g_spriteSize);
			}
		}

		foreach(i; [TileName.guyWalkLeft1, TileName.guyWalkLeft2]) {
			_framesBackward ~= new Sprite;
			with(_framesBackward[$-1]) {
				setTexture = g_texture;
				textureRect = IntRect(g_locations[i].x, g_locations[i].y, g_spriteSize, g_spriteSize);
			}
		}

		foreach(i; [TileName.climb1, TileName.climb2]) {
			_climb ~= new Sprite;
			with(_climb[$-1]) {
				setTexture = g_texture;
				textureRect = IntRect(g_locations[i].x, g_locations[i].y, g_spriteSize, g_spriteSize);
			}
		}

		foreach(identify; [TileName.plopUp, TileName.plopFall]) {
			_plopping ~= new Sprite;
			with(_plopping[$-1]) {
				setTexture = g_texture;
				textureRect = IntRect(g_locations[identify].x, g_locations[identify].y, g_spriteSize, g_spriteSize);
			}
		}
		_gunAimLeft = new Sprite(g_texture);
		_gunAimRight = new Sprite(g_texture);
		_gunAimLeft.textureRect = IntRect(g_locations[TileName.guyAimLeft].x, g_locations[TileName.guyAimLeft].y, g_spriteSize, g_spriteSize);
		_gunAimRight.textureRect = IntRect(g_locations[TileName.guyAimRight].x, g_locations[TileName.guyAimRight].y, g_spriteSize, g_spriteSize);

		_gunTriggerLeft = new Sprite(g_texture);
		_gunTriggerRight = new Sprite(g_texture);
		_gunTriggerLeft.textureRect = IntRect(g_locations[TileName.guyTiggerPulledLeft].x, g_locations[TileName.guyTiggerPulledLeft].y, g_spriteSize, g_spriteSize);
		_gunTriggerRight.textureRect = IntRect(g_locations[TileName.guyTiggerPulledRight].x, g_locations[TileName.guyTiggerPulledRight].y, g_spriteSize, g_spriteSize);

		_squatTriggerLeft = new Sprite(g_texture);
		_squatTriggerRight = new Sprite(g_texture);
		_squatTriggerLeft.textureRect = IntRect(g_locations[TileName.duckLeft1].x, g_locations[TileName.duckLeft1].y, g_spriteSize, g_spriteSize);
		_squatTriggerRight.textureRect = IntRect(g_locations[TileName.duckRight1].x, g_locations[TileName.duckRight1].y, g_spriteSize, g_spriteSize);

		_squatAimLeft = new Sprite(g_texture);
		_squatAimRight = new Sprite(g_texture);
		_squatAimLeft.textureRect = IntRect(g_locations[TileName.duckLeft2].x, g_locations[TileName.duckLeft2].y, g_spriteSize, g_spriteSize);
		_squatAimRight.textureRect = IntRect(g_locations[TileName.duckRight2].x, g_locations[TileName.duckRight2].y, g_spriteSize, g_spriteSize);

		_rocket = new Sprite(g_texture);
		_rocket.textureRect = IntRect(g_locations[TileName.rocket].x, g_locations[TileName.rocket].y, g_spriteSize, g_spriteSize);

		_pos = Vector2f(g_spriteSize * 9, 32);
		_stateUpDown = StateUpDown.falling;

		_blocks = g_blocks;

		_jumping = Jumping.no;

		_rocketState = Rocket.sitting;
		_rocketDir = Vector2f(0, 0);

		//_escaped.setup(this);
		//_briefing.setup(this);
		
		banner.setup([""], Vector2f(320 * id, 160), Vector2f(320,20));
	}

	void doResetPos(Vector2f resetPos) {
		_resetPos = resetPos;
	}
	
	void reset() {
		pos = _resetPos;
		_portal.scrn = portal.resetPosScrn;
		_rocketState = Rocket.sitting;
		_dying = Dying.alive;
		_rocketDir = Vector2f(0, 0);
		//_escaped.status = EscapeStatus.notEscaped;
		//_briefing.status = MissionStatus.current;
		_escapeStatus = GuyEscapeStatus.start;
		_dashBoard.score = 0;
		_dashBoard.diamonds = 0;
		updateScreenVerseRef;
		_banner.show = false;
		_stateUpDown = StateUpDown.nothing;
		_jumping = Jumping.no;
	}

	//#die
	void die() {
		g_jsounds[Snd.plop].playSnd;
		_plopPoint = pos;
		_dying = Dying.dyingUp;
		_dyingCountUp = 0;
	}
	
	void doGrace() {
		_portal.grace = g_graceStartTime;
		updateScreenVerseRef;
		//#change here
		//foreach(jeep; g_jeeps) {
		//	jeep.jeepBullit.jbullit = JBullit.dead;
		//}
	}
	
	bool placeGuy(Vector2i scrn, Vector2f pos) {
		if (pos.x >= 0 && pos.y >= 0 && pos.x < 10 * g_spriteSize && pos.y < 10 * g_spriteSize) {
			_portal.scrn = scrn;
			doGrace;
			_pos = makeSquare(pos);
			
			return true;
		}
		return false;
	}


	bool hitOther() {
		import std.math;
		
		auto o = g_guys[_other];
		if (_portal.scrn != o._portal.scrn)
			return false;
		if (abs((_pos.x + 8) - (o._pos.x + 8)) < 16 &&
			abs(_pos.y - o._pos.y) < 32)
				return true;
		
		return false;
	}
		
	bool isLadder() { //#if bottomLeft or bottomRight in on a ladder and not left in bottom, and not right bottom
		with(TileName)
			//return (hits(bottomLeft, [ladder]) || hits(bottomRight, [ladder]));
			
			return (hits(bottomLeft, [ladder]) || hits(bottomRight, [ladder])) &&
				! hits(Vector2f(_pos.x, _pos.y + g_spriteSize - 1), [ladder]) &&
				! hits(Vector2f(_pos.x + g_spriteSize - 1, _pos.y + g_spriteSize - 1), [ladder]);
	}

	//#this is stink, this can't go up in 'mover'
	override TileName getPos(in Vector2f v, Layer layer = Layer.normal) {
		if (v.x >= 0 && v.y >= 0 && v.x < g_spriteSize * 10 && v.y < g_spriteSize * 10) {
			TileName tile;
			if (layer == Layer.normal)
				tile = g_screens[_portal.scrn.y][_portal.scrn.x].tiles[cast(int)(v.y / g_spriteSize)][cast(int)(v.x / g_spriteSize)].tileName;
			if (layer == Layer.front)
				tile = g_screens[_portal.scrn.y][_portal.scrn.x].tiles[cast(int)(v.y / g_spriteSize)][cast(int)(v.x / g_spriteSize)].tileNameFront;
			if (tile == TileName.ledge && v.y % g_spriteSize >= 16)
				return TileName.gap;
			return tile;
		}
		else
			return TileName.gap;
	}
	
	void doPosition() {
		import std.array : array;
		import std.algorithm : map;

		(_framesForward ~
		 _framesBackward ~ 
		 _climb ~
		 _plopping ~
		 _gunAimLeft ~
		 _gunAimRight ~
		 _gunTriggerRight ~
		 _gunTriggerLeft ~
		 _squatAimRight ~
		 _squatAimLeft ~
		 _squatTriggerLeft ~
		 _squatTriggerRight ~
		 _rocket)
		.map!((a) => a.position = _pos).array;
	}

	/// Is the player gun trigger pulled?
	bool p1n2GunTrigger() {
		return g_keys[ _keys[Key.shoot] ].keyTrigger;
	}

	void process() {
		//_escaped.process;

		_dashBoard.process; // needs to be in display

		if (g_missionStage != MissionStage.playing) {
			return;
		}

		if (g_gameOver) {
			_banner.show;
			return;
		}

		processTestPoints(_pos);

		//#rocket
		if (_rocketState == Rocket.goingUp) {
			_pos = _pos + _rocketDir;
			_rocketDir.x = 0;
			_rocketDir.y = _rocketDir.y - 0.02;

			if (_pos.y < -g_spriteSize) {
				_dashBoard.score = _dashBoard.score + 100;
				_rocketState = Rocket.gone;
				g_inputJex.addToHistory(g_score.winner.to!dstring);
				_escapeStatus = GuyEscapeStatus.escaped;
				//_escaped.status = EscapeStatus.escaped;
				_dashBoard.banner = "Gotten away in rocket!"d;
				//if (g_guys[_other].escaped != EscapeStatus.escaped)
				//	_dashBoard.banner = g_score.winner.to!dstring;					
			}

			return; //#doesn't seem to be needed
		}

		if (getPos(_pos, Layer.front) == TileName.rocket &&
			makeSquare(_pos.x) == _pos.x && makeSquare(_pos.y) == _pos.y) {

			_dashBoard.banner = "Getting away in rocket!"d;
			g_jsounds[Snd.rocket].playSnd;
			//g_jsounds[Snd.rocket].setPitch(-0.1);
			g_mouse.setTile(_portal, mid, TileName.gap, Layer.front);
			_rocketState = Rocket.goingUp;
			_dying = Dying.inRocket;
		}

		// shoot button pressed
		if (_climbing == Climbing.no &&
			_dying == Dying.alive &&
			p1n2GunTrigger) {
				if (_gun == Gun.aiming) {
					import std.random;

					g_jsounds[Snd.shoot].setPitch(0.8 + uniform(1f, 40f) / 100);
					g_jsounds[Snd.shoot].playSnd;
					_gun = Gun.trigger; // eg. shoot
					float height;
					if (_gunDucked == GunDucked.notDucked)
						height = 6;
					if (_gunDucked == GunDucked.ducked)
						height = 12;
					if (_facing == Facing.right) {
						g_bullits ~= new Bullit(this, _portal.scrn, _pos + Vector2f(g_spriteSize - 2, height),
							Vector2f(g_pixelsx * 2, 0));
					}
					if (_facing == Facing.left) {
						g_bullits ~= new Bullit(this, _portal.scrn, _pos + Vector2f(-2, height), Vector2f(-g_pixelsx * 2, 0));
					}
				} else
					_gun = Gun.aiming;
		}

		if (g_keys[ _keys[Key.left] ].keyPressed ||
			g_keys[ _keys[Key.right] ].keyPressed ||
			g_keys[ _keys[Key.up] ].keyPressed) {
			_gun = Gun.normal;
			_gunDucked = GunDucked.notDucked;
		}

		//#Diamond collecting
		if (hits(mid, [TileName.diamond])) {
			g_jsounds[Snd.pop].playSnd;
			_dashBoard.diamonds = _dashBoard.diamonds + 1;
			_dashBoard.score = _dashBoard.score + 20;
			//#remed out diamonds print next line
			//g_inputJex.addToHistory(text(_id == Id.player1 ? "UpL" : "UpR", " Diamonds: ", _dashBoard.diamonds).to!dstring);
			g_mouse.setTile(_portal, /* middle of guy tester: */ mid, TileName.gap);
			_dashBoard.banner = "Diamond Collected"d;
			if (g_score.targetDiamondsQ && g_gotTargetDiamonds == false) {
				_dashBoard.banner = "Target diamonds collected!"d;
				g_popLine.set = "Head for the exit!";
				g_gotTargetDiamonds = true;
			} else if (g_score.allDiamondsQ) {
				//g_inputJex.addToHistory(g_score.winner.to!dstring);
				_dashBoard.banner = "All diamonds collected!"d;
				g_popLine.set = "Awesome!";
			}
		}

		if (hits(mid, [TileName.computerBlow6])) {
			g_mouse.setTile(_portal, /* middle of guy tester: */ mid, TileName.computer);
		}
		
		if (_dying == Dying.alive && hits(mid, [TileName.computer]))
			g_displayGameText = true;

		if (_dying == Dying.dyingDown) {
			_pos += Vector2f(0, g_pixelsy * 2);
			if (_pos.y >= g_spriteSize * 10f) {
				//pos = resetPos;
				pos = plopPoint;
				//portal.scrn = portal.resetPosScrn;
				doGrace;
				processTestPoints(pos);
				_dying = Dying.alive;
				_dashBoard.banner = "Alive again"d;
			}
		}

		if (_dying == Dying.dyingUp) {
			_pos += Vector2f(0, -g_pixelsy * 2);
			_dyingCountUp++;
			if (_dyingCountUp == g_spriteSize)
				_dying = Dying.dyingDown;
		}
		
		if (_dying == Dying.alive && (hits(Vector2f(_pos.x + 7, _pos.y + 7), [TileName.spikes]) ||
			hits(Vector2f(_pos.x + g_spriteSize - 7, _pos.y + 7), [TileName.spikes]))) {
			die;
			_plopPoint = pos;
			if (hits(Vector2f(_pos.x + 7, _pos.y + 7), [TileName.spikes]))
				g_mouse.setTile(_portal, Vector2f(_pos.x + 7, _pos.y + 7), TileName.gap, Layer.normal);
			else
				g_mouse.setTile(_portal, Vector2f(_pos.x + g_spriteSize - 7, _pos.y + 7), TileName.gap, Layer.normal);
		}

		void moveLeft() {
			_facing = Facing.left;

			with(TileName)
				if (! hits(leftTop, _blocks) &&
					! hits(leftMid, _blocks) &&
					! hits(leftBottom, _blocks)) {
					_preFrame++;
					if (_preFrame >= 5)
						_preFrame = 0,
						_currentFrame++;
					if (_currentFrame == 2)
						_currentFrame = 0;

					_pos = Vector2f(_pos.x - g_pixelsx, _pos.y);
					if (_pos.x < 0) {
						if (_portal.scrn.x - 1 >= 0) {
							_pos.x = 10 * g_spriteSize - g_spriteSize;
							with(_portal) {
								scrn = Vector2i(scrn.x - 1, scrn.y);
							} // with
						} else {
							_pos = Vector2f(_pos.x + g_pixelsx, _pos.y);
						}
						doGrace;
					}
					processTestPoints(_pos);
				}
			}

		void moveRight() {
			_facing = Facing.right;
		
			with(TileName)
				if (! hits(rightTop, _blocks) &&
					! hits(rightMid, _blocks) &&
					! hits(rightBottom, _blocks)) {
					_preFrame++;
					if (_preFrame >= 5)
						_preFrame = 0,
						_currentFrame++;
					if (_currentFrame == 2)
						_currentFrame = 0;

					bool onTop;
					//if (hitOther)
					//	onTop = true;
					_pos = Vector2f(_pos.x + 2, _pos.y);
					//if (onTop == false && hitOther)
					//	_pos = Vector2f(_pos.x - 1, _pos.y);
					if (_pos.x + g_spriteSize > 10 * g_spriteSize) {
						if (_portal.scrn.x + 1 < g_scrnDim.x) {
							_pos.x = 0;
							with(_portal) {
								scrn = Vector2i(scrn.x + 1, scrn.y);
							}
						} else {
							_pos = Vector2f(_pos.x - g_pixelsx, _pos.y);
						}
						doGrace;
					}
					processTestPoints(_pos);
				}
		}

		//#whopping code block
		if (_dying != Dying.alive)
			return;

		// key right
		if (g_keys[ _keys[Key.right] ].keyPressed &&
			! g_keys[ _keys[Key.left] ].keyPressed &&
			! p1n2GunTrigger) {
			if (_gunDucked == GunDucked.notDucked)
				moveRight;
		}

		// key left
		if (g_keys[ _keys[Key.left] ].keyPressed &&
			! g_keys[ _keys[Key.right] ].keyPressed &&
			! p1n2GunTrigger) {
			if (_gunDucked == GunDucked.notDucked)
				moveLeft;
		}
				
		if (g_keys[ _keys[Key.left] ].keyPressed ||
			g_keys[ _keys[Key.right] ].keyPressed) {
			_stateWalking = StateWalking.walking;
		} else {
			_stateWalking = StateWalking.standingStill;
			_preFrame = 0;
			_currentFrame = 1;
		}

		// jump
		if (g_keys[ _keys[Key.up] ].keyPressed) {
			if (hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y + g_spriteSize - 1), [TileName.ladder]) ||
				hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y), [TileName.ladder]))
				_climbing = Climbing.up,
				_jumping = Jumping.no;
			else
				_jumping = Jumping.yes;
		}
		
		// climbing up
		if (_climbing == Climbing.up) {
			_pos = Vector2f(_pos.x, _pos.y - g_pixelsy);
			
			if (_pos.y < 0) { // if edge of screen
				if (_portal.scrn.y - 1 >= 0) {
					_pos.y = g_spriteSize * 9;
					with(_portal) {
						scrn = Vector2i(scrn.x, scrn.y - 1);
					}
					doGrace;
				} else {
					_pos.y = 0;
					_climbingPreFrame--;
				}
			}
			//if (hitOther || 
			if (hits(topLeft, _blocks) || hits(topRight, _blocks))
				_pos = Vector2f(_pos.x, _pos.y + g_pixelsy); // back track
			else {
				_climbingPreFrame++;
				if (_climbingPreFrame == 5)
					_climbingPreFrame = 0,
					_climbingFrame = (_climbingFrame == 1 ? 0 : 1);
			}
			
			if (! hits(Vector2f(_pos.x + 16, _pos.y + g_spriteSize - 1), [TileName.ladder]) &&
				! hits(Vector2f(_pos.x + 16, _pos.y), [TileName.ladder]) ) {
				_climbing = Climbing.no;
			}
		} // _climbing == Climing.up
		
		if ((_climbing == Climbing.up || _climbing == Climbing.down) &&
			! g_keys[ _keys[Key.left] ].keyPressed &&
			! g_keys[ _keys[Key.right] ].keyPressed) {
			if (! hits(leftTop + Vector2f(1,0), [TileName.ladder]) &&
				! hits(leftBottom + Vector2f(1,0), [TileName.ladder]))
					_pos = Vector2f(_pos.x + 2, _pos.y);

			if (! hits(rightTop + Vector2f(-1, 0), [TileName.ladder]) &&
				! hits(rightBottom + Vector2f(-1, 0), [TileName.ladder]))
				_pos = Vector2f(_pos.x - g_pixelsx, _pos.y);
		}
		
		// move up if block on feet
		if ((hits(_pos + Vector2f(0, g_spriteSize - 1), _blocks) ||
			hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize - 1), _blocks)) &&
			! hits(_pos + Vector2f(0, g_spriteSize - 2), _blocks) &&
				! hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize - 2), _blocks)) {
			_pos += Vector2f(0, -g_pixelsy);
		}

		// climbing down
		if (_climbing == Climbing.down) {
			_pos += Vector2f(0, g_pixelsy);
			
			if (_pos.y + g_spriteSize >= 10 * g_spriteSize) { // if edge of screen
				if (_portal.scrn.y + 1 < g_scrnDim.y) {
					_pos.y = 0;
					with(_portal) {
						scrn = scrn + Vector2i(0, 1);
					}
					doGrace;
				}
			}

			//#320 didn't work
			if (hits(bottomLeft, _blocks) || hits(bottomRight, _blocks)) {
				_pos += Vector2f(0, -g_pixelsy); // back track
				//_climbing = Climbing.no;
			}
			else {
				_climbingPreFrame++;
				if (_climbingPreFrame == 5)
					_climbingPreFrame = 0,
					_climbingFrame = (_climbingFrame == 1 ? 0 : 1);
			}
			
			if (! hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y + g_spriteSize), [TileName.ladder]) &&
				! hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y), [TileName.ladder])) {
				_climbing = Climbing.no;
			}
		} // _climbing == Climbing.down
		
		if (_jumping == Jumping.yes) {
			with(TileName) {
				bool leap;
				if (isLadder == true ||
					hits(bottomLeft, _blocks) ||
	 				hits(bottomRight, _blocks))
					leap = true;

				_pos += Vector2f(0, g_pixelsy);
				immutable other = (_id == player1 ? player2 : player1);
				if (hitOther)
					with(g_guys[other]) {
						_pos.processTestPoints;
						if (hits(bottomLeft,  _blocks) ||
							hits(bottomRight, _blocks) ||
							 isLadder)
							leap = true;
					}
				_pos += Vector2f(0, -g_pixelsy);
				if (leap) {
					//g_jsounds[Snd.leap].playSnd;
					_stateUpDown = StateUpDown.rising;
					_risingCount = _glideCount = -1; //# bit funny
					if (! hits(topLeft, _blocks) && ! hits(topRight, _blocks))
						_risingCount++;
				}
			}
		} // _jumping == Jumping.yes

		// key down
		if (g_keys[ _keys[Key.down] ].keyPressed) {
			if ((hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y + g_spriteSize), [TileName.ladder]) ||
				hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y - 1), [TileName.ladder])) &&
				! hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y + 2), _blocks))
				_climbing = Climbing.down,
				_jumping = Jumping.no;
			else {
				_stateUpDown = StateUpDown.falling;
				_jumping = Jumping.no;
			}

			if (! g_keys[_keys[Key.right]].keyPressed &&
				! hits(bottomPartLeft, _blocks) &&
				hits(bottomRight, _blocks)) {
				moveLeft;
			}

			if (! g_keys[_keys[Key.left]].keyPressed &&
				! hits(bottomPartLeft, _blocks) &&
				hits(bottomLeft, _blocks)) {
				moveRight;
			}

			if (! g_keys[ _keys[Key.left] ].keyPressed &&
				! g_keys[ _keys[Key.right] ].keyPressed) {
				if (hits(bottomLeft, _blocks) ||
					hits(bottomRight, _blocks) ||
					isLadder) {
					if  (_gunDucked != GunDucked.ducked)
						_gun = Gun.aiming;
					_gunDucked = GunDucked.ducked;
					if (! isLadder)
						_climbing = Climbing.no;
					_pos = Vector2f(_pos.x, cast(int)_pos.y / cast(int)g_spriteSize * cast(int)g_spriteSize);
				} else {
					_gunDucked = GunDucked.notDucked;
				}
			}
		}
				
		// falling
		if (_stateUpDown != StateUpDown.rising && _stateUpDown != StateUpDown.gliding && _climbing == Climbing.no) {
			//writeln(std.random.uniform(0, 100));
			//writeln(_pos.y);
			with(TileName) {
				if (! hits(bottomLeft, _blocks) &&
					! hits(bottomRight, _blocks)) {
											
					// if ladder under but not on it, then move down
					if (! isLadder &&
						! (hits(Vector2f(_pos.x + g_spriteSize / 2, _pos.y + g_spriteSize), [ladder]) &&
							hits(Vector2f(_pos.x - 1, _pos.y + g_spriteSize), _blocks) &&
							hits(Vector2f(_pos.x + g_spriteSize, _pos.y + g_spriteSize), _blocks))) {
						_stateUpDown = StateUpDown.falling;
						_pos += Vector2f(0, g_pixelsy);
						if (_pos.y + g_spriteSize >= 10 * g_spriteSize) { // if edge of screen
							if (_portal.scrn.y + 1 < g_scrnDim.y) {
								_pos.y = 0;
								with(_portal) {
									scrn = Vector2i(scrn.x, scrn.y + 1);
								}
								doGrace;
							} else {
								_pos = Vector2f(_pos.x, _pos.y - g_spriteSize);
							}
						}
					} else
						_stateUpDown = StateUpDown.nothing;
				} else
					_stateUpDown = StateUpDown.nothing;
			}
		} // falling
			
		// rising
		if (_stateUpDown == StateUpDown.rising) {
			if (_climbing == Climbing.up || _climbing == Climbing.down)
				_stateUpDown = StateUpDown.nothing;
			else {
				if (! hits(topLeft, _blocks) && 
					! hits(topRight, _blocks)) {
					if (_pos.y < 0) {
						if (_portal.scrn.y - 1 < 0) {
							_pos.y = 0;
							doGrace; //#should this be here
						}
						else {
							_pos.y = g_spriteSize * 9;
							with(_portal) {
								scrn = Vector2i(scrn.x, scrn.y - 1);
							}
							_risingCount += g_spriteSize - g_pixelsy * 2;
							doGrace;
						}
					} else {
							_pos += Vector2f(0, -g_pixelsy);
					}
				}

				_risingCount += 2;
				if (_risingCount >= g_spriteSize * 2) {
					_risingCount = 0;
					_stateUpDown = StateUpDown.gliding;
				}
			}

			//#stop on a block in a jump up a screen
			if ((hits(topLeft + Vector2f(0, 1), _blocks) ||
				 hits(topRight + Vector2f(0, 1), _blocks)) &&
				! hits(topLeft + Vector2f(0, 2), _blocks) &&
				! hits(topRight + Vector2f(0, 2), _blocks))
				_pos += Vector2f(0, g_pixelsy);
		} // rising

		// Moving at jump max height
		if (_stateUpDown == StateUpDown.gliding) {
			_glideCount++;
			if (_glideCount == g_spriteSize)
				_stateUpDown = StateUpDown.falling;
		}
	} // process

	void draw(bool skip = false, bool text = true) {
		if (text) {
//			if (_briefing.status == MissionStatus.current) {
//				_briefing.draw;
//			}

//			if (_escaped.status == EscapeStatus.escaped) {
//				_escaped.draw;
//			}

			_dashBoard.draw;
		}

		auto posWas = _pos;
		_pos = _id == player1 ? Vector2f(_pos.x, _pos.y) : Vector2f(_pos.x + _portal.pos.x, _pos.y);
		
		immutable other = (_id == player1 ? player2 : player1);
		if (g_guys[other]._portal.scrn == _portal.scrn) {
			if (other == 1) {
				with(g_guys[other]) {
					auto gposWas = _pos;
					_pos = Vector2f(_pos.x - _portal.pos.x, _pos.y);
					draw(/* skip: */ true, false);
					_pos = gposWas;
				}
			}
			if (other == 0 && skip == false) {
				auto gposWas = g_guys[other]._pos;
				with(g_guys[other]) {
					_pos = Vector2f(320 + _pos.x, _pos.y); //#magic number
					draw(false, false);
					_pos = gposWas;
				}
			}
		}
		
		doPosition;

		final switch(_rocketState) {
			case Rocket.sitting:
			case Rocket.gone:
			break;
			case Rocket.goingUp:
				g_window.draw(_rocket);
			break;
		}

		if (_climbing == Climbing.no && _dying == Dying.alive) { //#big fat wrap!
			if (_stateUpDown == StateUpDown.nothing && _climbing == Climbing.no && _gun == Gun.normal)
				final switch(_stateWalking) {
					case StateWalking.walking:
						final switch(_facing) {
							case Facing.right:
								g_window.draw(_framesForward[_currentFrame]);
							break;
							case Facing.left:
								g_window.draw(_framesBackward[_currentFrame]);
							break;
						}
						break;
					case StateWalking.standingStill:
						final switch(_facing) {
							case Facing.right:
								g_window.draw(_framesForward[0]);
							break;
							case Facing.left:
								g_window.draw(_framesBackward[0]);
							break;
						}
					break;
				}

			final switch(_gun) {
				case Gun.normal:
				break;
				case Gun.aiming:
					final switch(_gunDucked) {
						case GunDucked.notDucked:
							(_facing == Facing.right ? g_window.draw(_gunAimRight) : g_window.draw(_gunAimLeft));
						break;
						case GunDucked.ducked:
							(_facing == Facing.right ? g_window.draw(_squatAimRight) : g_window.draw(_squatAimLeft));
						break;
					}
				break;
				case Gun.trigger:
					final switch(_gunDucked) {
						case GunDucked.notDucked:
							(_facing == Facing.right ? g_window.draw(_gunTriggerRight) : g_window.draw(_gunTriggerLeft));
						break;
						case GunDucked.ducked:
							(_facing == Facing.right ? g_window.draw(_squatTriggerRight) : g_window.draw(_squatTriggerLeft));
						break;
					}
				break;
			}
		
			if (_gun == Gun.normal)
				final switch(_stateUpDown) {
					case StateUpDown.rising:
					case StateUpDown.falling:
					case StateUpDown.gliding:
						final switch(_facing) {
							case Facing.right:
								g_window.draw(_framesForward[1]);
							break;
							case Facing.left:
								g_window.draw(_framesBackward[1]);
							break;
						}
					break;
					case StateUpDown.nothing:
					break;
				}
		} // if not climbing

		if (_dying == Dying.alive)
			final switch(_climbing) {
				case Climbing.no: break;
				case Climbing.up:
				case Climbing.down:
					g_window.draw(_climb[_climbingFrame]);
				break;
			}

		final switch(_dying) {
			case Dying.alive,
				 Dying.inRocket: break; //#not sure about in rocket
			case Dying.dyingUp: g_window.draw(_plopping[0]); _dashBoard.banner = "Plop up"d; break;
			case Dying.dyingDown: g_window.draw(_plopping[1]); _dashBoard.banner = "Plop down"d; break;
		}

		_pos = posWas;
	}

	void updateScreenVerseRef() {
		import std.conv: to, text;

		if (_portal.scrn.x >= 0 && _portal.scrn.x < g_scrnDim.x &&
			_portal.scrn.y >= 0 && _portal.scrn.y < g_scrnDim.y) {
			_dashBoard.banner = g_screens[_portal.scrn.y][_portal.scrn.x].verseRef.to!dstring;
			//g_display.setVerse(g_bible.argReference(
			//		g_bible.argReferenceToArgs(g_screens[_portal.scrn.y][_portal.scrn.x].verseRef)));
			g_display.setVerse(g_bible.argReference(
					g_bible.getReference(
							g_screens[_portal.scrn.y][_portal.scrn.x].verseRef.split)));
			g_doLetUpdate = true;
		}
	}
}

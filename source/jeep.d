//#shooting
module jeep;

import base;

class Jeep: Mover {
private:
	enum Facing {left, right}
	Facing _facing, _facingNext;
	Action _action;
	int _turnCount, _stunCount, _shootingCount;
	int _blowUpFrameTiming, _blowUpFrame;
	JeepBullit _jeepBullit;
public:
	@property Facing facing() { return _facing; }
	@property void facing(Facing facing0) { _facing = facing0; }

	@property Facing facingNext() { return _facingNext; }
	@property void facingNext(Facing facingNext0) { _facingNext = facingNext0; }

	@property Action action() { return _action; }
	@property void action(Action action0) { _action = action0; }

	@property JeepBullit jeepBullit() { return _jeepBullit; }
	@property void jeepBullit(JeepBullit jeepBullit0) { _jeepBullit = jeepBullit0; }

	this(Vector2f pos0, Vector2i scrn0) {
		_pos = pos0;
		scrn = scrn0;
		_dir = Vector2f(-1, 0);
		_action = Action.leftRight;
		_turnCount = 20;
		_jeepBullit = new JeepBullit;
	}

	auto hitOtherJeep() {
		foreach(jeep; g_jeeps) {
			if (this !is jeep && jeep.action != Action.destroyed && jeep.scrn == scrn &&
				abs(jeep.pos.x - pos.x) < g_spriteSize &&
				abs(jeep.pos.y - pos.y) < g_spriteSize) {
				return jeep;
			}
		}
		return null;
	}

	void process() {

		version(none) {
			bool checkForGuyOverLap() {
					foreach(guy; g_guys) {
						if (guy.portal.scrn == scrn &&
							abs(_pos.x - guy.pos.x) < g_spriteSize &&
							abs(_pos.y - guy.pos.y) < g_spriteSize) {
							return true;
						}
					}
				return false;
			}
		}

		final switch(_action) {
			case Action.leftRight:
				bool checkAccross(Guy guy, float step) {
					float x = pos.x;
					while(x >= 0 && x < g_spriteSize * 10) {
						if (hits(Vector2f(x, pos.y), g_blocks ~ TileName.spikes))
							return false;
						if (x > guy.pos.x &&
							x < guy.pos.x + g_spriteSize && ! guy.gunDucked)
							return true;
						x += step;
					}
					return false;
				}

				auto onOtherBefore = hitOtherJeep;
				_pos += Vector2f(_dir.x, 0);
				foreach(guy; g_guys) {
					if (guy.portal.grace == 0 && scrn == guy.portal.scrn && guy.dying == Dying.alive  &&
						pos.y + 2 >= guy.pos.y && pos.y < guy.pos.y + g_spriteSize) {
						// left
						if (checkAccross(guy, -g_spriteSize) == true && _dir.x < 0 && guy.pos.x - g_spriteSize < pos.x) {
							_jeepBullit.fire(this, guy, scrn, Vector2f(pos.x, pos.y + 2), Vector2f(dir.x * 2, 0));
							_jeepBullit.jbullit = JBullit.current;

							_action = Action.shooting;
						}
						
						//right
						if (checkAccross(guy, g_spriteSize) == true && _dir.x > 0 && guy.pos.x > pos.x + g_spriteSize) {
							_jeepBullit.fire(this, guy, scrn, Vector2f(pos.x + g_spriteSize, pos.y + 2), Vector2f(dir.x * 2, 0));
							_jeepBullit.jbullit = JBullit.current;

							_action = Action.shooting;
						}
					}
					if (_action == Action.shooting)
						g_jsounds[Snd.shootJeep].playSnd;
				}

				// left
				if (_pos.x < 0 || hits(_pos + Vector2f(-1,0), g_blocks ~ TileName.spikes) ||
					! hits(_pos + Vector2f(0, g_spriteSize), g_blocks ~ TileName.ladder) ||
					(_dir.x < 0 && onOtherBefore)) {
					_facingNext = Facing.right;
					_pos = _pos + Vector2f(1, 0);
					_dir = Vector2f(1, 0);
					_turnCount = 20;
					_action = Action.turning;
					if (onOtherBefore && onOtherBefore.action != Action.blowingUp && onOtherBefore.action != Action.destroyed) {
						with(onOtherBefore) {
							_facing = Facing.right;
							_facingNext = Facing.left;
							_turnCount = 20;
							onOtherBefore._action = Action.turning;
							//_pos = _pos + Vector2f(-1, 0);
							_dir = Vector2f(-1, 0);
						}
					}
				}

				// right
				if (_pos.x + g_spriteSize - 1 >= g_spriteSize * 10 || hits(_pos + Vector2f(g_spriteSize, 0), g_blocks ~ TileName.spikes) ||
					! hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) ||
					(_dir.x > 0 && onOtherBefore)) {
					_facingNext = Facing.left;
					_pos = _pos - Vector2f(1, 0);
					_dir = Vector2f(-1, 0);
					_turnCount = 20;
					_action = Action.turning;
					if (onOtherBefore && onOtherBefore.action != Action.blowingUp && onOtherBefore.action != Action.destroyed) {
						with(onOtherBefore) {
							_facing = Facing.left;
							_facingNext = Facing.right;
							_turnCount = 20;
							_action = Action.turning;
							//_pos = _pos + Vector2f(1, 0);
							_dir = Vector2f(1, 0);
						}
					}
				}
				if (! hits(_pos + Vector2f(0, g_spriteSize), g_blocks ~ TileName.ladder) &&
					! hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) &&
					! hitOtherJeep)
					_action = Action.falling;
			break;
			case Action.stunned:
				if ((_stunCount--) < 0)
					_action = Action.leftRight;
			break;
			case Action.turning:
				if ((_turnCount--) < 0)
					_turnCount = 20,
					_facing = _facingNext,
					_action = Action.leftRight;
			break;
			case Action.falling:
				_pos += Vector2f(0, 1);
				if (hits(_pos + Vector2f(0, g_spriteSize), g_blocks ~ TileName.ladder) ||
					hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) ||
					hitOtherJeep) {
					_stunCount = 20;
					_action = Action.stunned;
				}
			break;
			//#shooting
			case Action.shooting:
				if (_jeepBullit.jbullit == JBullit.terminated) {
						_action = Action.leftRight;
					}
			break;
			case Action.blowingUp:
				_blowUpFrameTiming++;
				if (_blowUpFrameTiming == 10) {
					_blowUpFrameTiming = 0,
					_blowUpFrame++;
					if (_blowUpFrame == 6)
						_action = Action.destroyed;
				}
			break;
			case Action.destroyed:
			break;
		}
		if (_jeepBullit.jbullit == JBullit.current)
			_jeepBullit.process;
	}

	bool hits(in Vector2f v, in TileName[] tileNames) {
		auto name = getPos(v);
		foreach(n; tileNames)
			if (name == n)
				return true;
		return false;
	}

	version(none)
	TileName getPos(in Vector2f v) {
		if (v.x >= 0 && v.y >= 0 && v.x < g_spriteSize * 10 && v.y < g_spriteSize * 10) {
			TileName tile = g_screens[_scrn.y][_scrn.x].tiles[cast(int)(v.y / g_spriteSize)][cast(int)(v.x / g_spriteSize)].tileName;
			if (tile == TileName.ledge && v.y % g_spriteSize >= 16)
				return TileName.gap;
			return tile;
		}
		else
			return TileName.gap;
	}

	void setPosition(Vector2f pos0) {
		//writeln("set pos: ", pos0);
		g_jeepLeftGfx[$-1].position = pos0;
		g_jeepRightGfx[$-1].position = pos0;

		if (_action == Action.blowingUp || _action == Action.destroyed)
			foreach(i; 0 .. g_jeepBlowUpLeft.length)
				g_jeepBlowUpLeft[i].position = pos0,
				g_jeepBlowUpRight[i].position = pos0;
		//if (_jeepBullit.jbullit == JBullit.alive)
		//	_jeepBullit.jeepBullitShape.position = _jeepBullit.pos;
	}

	void draw() {
		setPosition(_pos);
		final switch(_action) {
			case Action.leftRight, Action.falling, Action.turning, Action.stunned, Action.shooting:
				final switch(_facing) {
					case Facing.left:
						g_window.draw(g_jeepLeftGfx[0]);
						break;
					case Facing.right:
						g_window.draw(g_jeepRightGfx[0]);
						break;
				}
				break;
			case Action.blowingUp:
				final switch(_facing) {
					case Facing.left:
						g_window.draw(g_jeepBlowUpLeft[5 - _blowUpFrame]);
					break;
					case Facing.right:
						g_window.draw(g_jeepBlowUpRight[_blowUpFrame]);
					break;
				}
			break;
			case Action.destroyed:
				final switch(_facing) {
					case Facing.left:
						g_window.draw(g_jeepBlowUpLeft[0]);
						break;
					case Facing.right:
						g_window.draw(g_jeepBlowUpRight[5]);
						break;
				}
			break;
		}
	}
}

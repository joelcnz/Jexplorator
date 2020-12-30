//#shooting
module jeep;

import base;

class Jeep: Mover {
private:
	static _cid = 0;
	int _id;
	enum Facing {left, right}
	Facing _facing, _facingNext;
	Action _action;
	int _turnCount, _stunCount, _shootingCount;
	int _blowUpFrameTiming, _blowUpFrame;
	JeepBullit _jeepBullit;
	Vec _dirSpc;
public:
	int id() { return _id; }
	void id(int id0) { _id = id0; }

	Facing facing() { return _facing; }
	void facing(Facing facing0) { _facing = facing0; }

	Facing facingNext() { return _facingNext; }
	void facingNext(Facing facingNext0) { _facingNext = facingNext0; }

	Action action() { return _action; }
	void action(Action action0) { _action = action0; }

	JeepBullit jeepBullit() { return _jeepBullit; }
	void jeepBullit(JeepBullit jeepBullit0) { _jeepBullit = jeepBullit0; }

	this(Vec pos0, Vector!int scrn0) {
		id = _cid;
		_cid += 1;
		_pos = pos0;
		scrn = scrn0;
		_dir = Vec(-g_pixelsx, 0);
		_action = Action.left;
		_turnCount = 20;
		_jeepBullit = new JeepBullit;
	}

	auto hitOtherJeep() {
		foreach(jeep; g_jeeps) {
			if (this !is jeep && jeep.action != Action.destroyed && jeep.scrn == scrn &&
				abs(jeep.pos.X - pos.X) < g_spriteSize &&
				abs(jeep.pos.Y - pos.Y) < g_spriteSize) {
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
							abs(_pos.X - guy.pos.X) < g_spriteSize &&
							abs(_pos.Y - guy.pos.Y) < g_spriteSize) {
							return true;
						}
					}
				return false;
			}
		}

		bool checkAcross(Guy guy, float step) {
			float x = makeSquare(pos.X) + g_spriteSize / 2;
			while(x >= 0 && x < g_spriteSize * 10) {
				if (hits(Vec(x, pos.y), g_blocks ~ TileName.spikes))
					return false;
				if (jeepHit(this, scrn, Vec(x, pos.y), Shooter.check)) {
					return false;
				}
				if (x > guy.pos.X &&
					x < guy.pos.X + g_spriteSize && ! guy.gunDucked)
					return true;
				x += step;
			}
			return false;
		}

		final switch(_action) {
			case Action.leftRight:
			case Action.left:
				auto onOtherBefore = hitOtherJeep;
				_pos -= Vec(abs(_dir.X), 0);
				foreach(guy; g_guys) {
					if (guy.portal.grace == 0 && scrn == guy.portal.scrn && guy.dying == Dying.alive  &&
						pos.y + 2 >= guy.pos.y && pos.y < guy.pos.y + g_spriteSize) {
						// left
						if (checkAcross(guy, -g_spriteSize) == true && guy.pos.x - g_spriteSize < pos.x) {
							_jeepBullit.fire(this, guy, scrn, Vec(pos.x, pos.y + 2), Vec(dir.x * 2, 0));
							_jeepBullit.jbullit = JBullit.current;

							_action = Action.shooting;
						}
					}
					if (_action == Action.shooting)
						g_jsounds[Snd.shootJeep].play(false);
				}

				// left
				if (_pos.X < 0 || hits(_pos + Vec(-1,0), g_blocks ~ TileName.spikes) ||
					! hits(_pos + Vec(0, g_spriteSize), g_blocks ~ TileName.ladder) ||
					(_dir.X < 0 && onOtherBefore && onOtherBefore._dir.X > 0)) {
					_facingNext = Facing.right;
					_pos = _pos + Vec(g_pixelsx, 0);
					_dir = Vec(g_pixelsx, 0);
					_action = Action.turning;
					_turnCount = 10;
					if (onOtherBefore && onOtherBefore.action != Action.blowingUp && id > onOtherBefore.id &&
						onOtherBefore.action != Action.destroyed) {
						_pos = _pos + Vec(g_pixelsx, 0);
						_facing = Facing.right;
						_facingNext = Facing.left;
						_action = Action.turning;
						with(onOtherBefore) {
							_facing = Facing.left;
							_facingNext = Facing.right;
							_action = Action.turning;
							_turnCount = 10;
							//_pos = _pos + Vec(-g_pixelsx, 0);
							_dir = Vec(-g_pixelsx, 0);
						}
					}
				}

				if (! hits(_pos + Vec(0, g_spriteSize), g_blocks ~ TileName.ladder) &&
					! hits(_pos + Vec(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) && ! hitOtherJeep)
					_action = Action.falling;
			break;
			case Action.right:
				auto onOtherBefore = hitOtherJeep;
				_pos += Vec(abs(_dir.X), 0);
				foreach(guy; g_guys) {
					if (guy.portal.grace == 0 && scrn == guy.portal.scrn && guy.dying == Dying.alive  &&
						pos.Y + 2 >= guy.pos.Y && pos.Y < guy.pos.Y + g_spriteSize) {
						//right
						if (checkAcross(guy, g_spriteSize) == true && guy.pos.X > pos.X + g_spriteSize) {
							_jeepBullit.fire(this, guy, scrn, Vec(pos.X + g_spriteSize, pos.Y + 2), Vec(dir.X * 2, 0));
							_jeepBullit.jbullit = JBullit.current;

							_action = Action.shooting;
						}
					}
					if (_action == Action.shooting)
						g_jsounds[Snd.shootJeep].play(false);
				}

				// right
				if (_pos.X + g_spriteSize - 1 >= g_spriteSize * 10 || hits(_pos + Vec(g_spriteSize, 0), g_blocks ~ TileName.spikes) ||
					! hits(_pos + Vec(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) ||
					(_dir.X > 0 && onOtherBefore && onOtherBefore._dir.X < 0)) {
					_facingNext = Facing.left;
					_pos = _pos - Vec(g_pixelsx, 0);
					_dir = Vec(-g_pixelsx, 0);
					_turnCount = 10;
					_action = Action.turning;
					if (onOtherBefore && onOtherBefore.action != Action.blowingUp && id < onOtherBefore.id &&
						onOtherBefore.action != Action.destroyed) {
						_pos = _pos - Vec(g_pixelsx, 0);
						_facing = Facing.right;
						_facingNext = Facing.left;
						_action = Action.turning;
						_turnCount = 10;
						with(onOtherBefore) {
							_facing = Facing.left;
							_facingNext = Facing.right;
							_action = Action.turning;
							_turnCount = 10;
							//_pos = _pos + Vec(1, 0);
							_dir = Vec(g_pixelsx, 0);
						}
						onOtherBefore = null;
					}
				}
				if (! hits(_pos + Vec(0, g_spriteSize), g_blocks ~ TileName.ladder) &&
					! hits(_pos + Vec(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) && ! hitOtherJeep)
					_action = Action.falling;
			break;
			case Action.stunned:
				if ((_stunCount--) < 0)
					_action = (_facingNext == Facing.right ? Action.right : Action.left);
			break;
			case Action.turning:
				if ((_turnCount--) < 0)
					_turnCount = 10,
					_facing = _facingNext,
					_action = (_facing == Facing.right ? Action.right : Action.left);
			break;
			case Action.falling:
				_pos += Vec(0, g_pixelsy);
				if (hits(_pos + Vec(0, g_spriteSize), g_blocks ~ TileName.ladder) ||
					hits(_pos + Vec(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) ||
					hitOtherJeep) {
					_stunCount = 5;
					_action = Action.stunned;
				}
			break;
			//#shooting
			case Action.shooting:
				if (_jeepBullit.jbullit == JBullit.terminated) {
						_action = (_facing == Facing.right ? Action.right : Action.left);
					}
			break;
			case Action.blowingUp:
				_blowUpFrameTiming++;
				if (_blowUpFrameTiming == 5) {
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

	void setPosition(Vec pos0) {
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
			case Action.leftRight, Action.left, Action.right, Action.falling, Action.turning, Action.stunned, Action.shooting:
				final switch(_facing) {
					case Facing.left:
						//g_window.draw(g_jeepLeftGfx[0]);
						//SDL_RenderCopy(gRenderer, g_jeepLeftGfx[0], null, &_pos);
						//g_jeepLeftGfx[0].draw;
						gGraph.draw(g_jeepLeftGfx[0].image, _pos);
						break;
					case Facing.right:
						//g_window.draw(g_jeepRightGfx[0]);
						//g_jeepRightGfx[0].draw;
						gGraph.draw(g_jeepRightGfx[0].image, _pos);
						break;
				}
				break;
			case Action.blowingUp:
				final switch(_facing) {
					case Facing.left:
						//g_window.draw(g_jeepBlowUpLeft[5 - _blowUpFrame]);
						//g_jeepBlowUpLeft[5 - _blowUpFrame].draw;
						gGraph.draw(g_jeepBlowUpLeft[5 - _blowUpFrame].image, _pos);
					break;
					case Facing.right:
						//g_window.draw(g_jeepBlowUpRight[_blowUpFrame]);
						gGraph.draw(g_jeepBlowUpRight[_blowUpFrame].image, _pos);
					break;
				}
			break;
			case Action.destroyed:
				final switch(_facing) {
					case Facing.left:
						//g_window.draw(g_jeepBlowUpLeft[0]);
						//g_jeepBlowUpLeft[0].draw;
						gGraph.draw(g_jeepBlowUpLeft[0].image, _pos);
						break;
					case Facing.right:
						//g_window.draw(g_jeepBlowUpRight[5]);
						//g_jeepBlowUpRight[5].draw;
						gGraph.draw(g_jeepBlowUpRight[5].image, _pos);
						break;
				}
			break;
		}
	}
}

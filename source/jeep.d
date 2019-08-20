﻿//#shooting
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
	Vector2f _dirSpc;
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

	this(Vector2f pos0, Vector2i scrn0) {
		id = _cid;
		_cid += 1;
		_pos = pos0;
		scrn = scrn0;
		_dir = Vector2f(-g_pixelsx, 0);
		_action = Action.left;
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

		bool checkAcross(Guy guy, float step) {
			float x = makeSquare(pos.x) + g_spriteSize / 2;
			while(x >= 0 && x < g_spriteSize * 10) {
				if (hits(Vector2f(x, pos.y), g_blocks ~ TileName.spikes))
					return false;
				if (jeepHit(this, scrn, Vector2f(x, pos.y), Shooter.check)) {
					"jeep in the way".gh;
					return false;
				}
				if (x > guy.pos.x &&
					x < guy.pos.x + g_spriteSize && ! guy.gunDucked)
					return true;
				x += step;
			}
			return false;
		}

		final switch(_action) {
			case Action.leftRight:
			case Action.left:
				auto onOtherBefore = hitOtherJeep;
				_pos -= Vector2f(abs(_dir.x), 0);
				foreach(guy; g_guys) {
					if (guy.portal.grace == 0 && scrn == guy.portal.scrn && guy.dying == Dying.alive  &&
						pos.y + 2 >= guy.pos.y && pos.y < guy.pos.y + g_spriteSize) {
						// left
						if (checkAcross(guy, -g_spriteSize) == true && guy.pos.x - g_spriteSize < pos.x) {
							_jeepBullit.fire(this, guy, scrn, Vector2f(pos.x, pos.y + 2), Vector2f(dir.x * 2, 0));
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
					(_dir.x < 0 && onOtherBefore && onOtherBefore._dir.x > 0)) {
					_facingNext = Facing.right;
					_pos = _pos + Vector2f(g_pixelsx, 0);
					_dir = Vector2f(g_pixelsx, 0);
					_action = Action.turning;
					_turnCount = 10;
					if (onOtherBefore && onOtherBefore.action != Action.blowingUp && id > onOtherBefore.id &&
						onOtherBefore.action != Action.destroyed) {
						_pos = _pos + Vector2f(g_pixelsx, 0);
						_facing = Facing.right;
						_facingNext = Facing.left;
						_action = Action.turning;
						with(onOtherBefore) {
							_facing = Facing.left;
							_facingNext = Facing.right;
							_action = Action.turning;
							_turnCount = 10;
							//_pos = _pos + Vector2f(-g_pixelsx, 0);
							_dir = Vector2f(-g_pixelsx, 0);
						}
					}
				}

				if (! hits(_pos + Vector2f(0, g_spriteSize), g_blocks ~ TileName.ladder) &&
					! hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) && ! hitOtherJeep)
					_action = Action.falling;
			break;
			case Action.right:
				auto onOtherBefore = hitOtherJeep;
				_pos += Vector2f(abs(_dir.x), 0);
				foreach(guy; g_guys) {
					if (guy.portal.grace == 0 && scrn == guy.portal.scrn && guy.dying == Dying.alive  &&
						pos.y + 2 >= guy.pos.y && pos.y < guy.pos.y + g_spriteSize) {
						//right
						if (checkAcross(guy, g_spriteSize) == true && guy.pos.x > pos.x + g_spriteSize) {
							_jeepBullit.fire(this, guy, scrn, Vector2f(pos.x + g_spriteSize, pos.y + 2), Vector2f(dir.x * 2, 0));
							_jeepBullit.jbullit = JBullit.current;

							_action = Action.shooting;
						}
					}
					if (_action == Action.shooting)
						g_jsounds[Snd.shootJeep].playSnd;
				}

				// right
				if (_pos.x + g_spriteSize - 1 >= g_spriteSize * 10 || hits(_pos + Vector2f(g_spriteSize, 0), g_blocks ~ TileName.spikes) ||
					! hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) ||
					(_dir.x > 0 && onOtherBefore && onOtherBefore._dir.x < 0)) {
					_facingNext = Facing.left;
					_pos = _pos - Vector2f(g_pixelsx, 0);
					_dir = Vector2f(-g_pixelsx, 0);
					_turnCount = 10;
					_action = Action.turning;
					if (onOtherBefore && onOtherBefore.action != Action.blowingUp && id < onOtherBefore.id &&
						onOtherBefore.action != Action.destroyed) {
						_pos = _pos - Vector2f(g_pixelsx, 0);
						_facing = Facing.right;
						_facingNext = Facing.left;
						_action = Action.turning;
						_turnCount = 10;
						with(onOtherBefore) {
							_facing = Facing.left;
							_facingNext = Facing.right;
							_action = Action.turning;
							_turnCount = 10;
							//_pos = _pos + Vector2f(1, 0);
							_dir = Vector2f(g_pixelsx, 0);
						}
						onOtherBefore = null;
					}
				}
				if (! hits(_pos + Vector2f(0, g_spriteSize), g_blocks ~ TileName.ladder) &&
					! hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) && ! hitOtherJeep)
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
				_pos += Vector2f(0, g_pixelsy);
				if (hits(_pos + Vector2f(0, g_spriteSize), g_blocks ~ TileName.ladder) ||
					hits(_pos + Vector2f(g_spriteSize - 1, g_spriteSize), g_blocks ~ TileName.ladder) ||
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
			case Action.leftRight, Action.left, Action.right, Action.falling, Action.turning, Action.stunned, Action.shooting:
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

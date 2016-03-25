//#dummist possible error! (bullit not hitting the bady)
module bullit;

import base;

class Bullit: Mover {
private:
	enum BullitState {current, terminated, blowingUp}
	BullitState _bullitState;
	RectangleShape _bullitShape;
	Guy _owner;
public:
	@property BullitState bullitState() { return _bullitState; }
	
	this(Guy owner, Vector2i scrn, Vector2f pos, Vector2f dir) {
		_owner = owner;
		_scrn = scrn;
		_bullitShape = new RectangleShape();
		_bullitShape.size = Vector2f(4, 2);
		_bullitShape.fillColor = Color(230, 230, 230);
		_pos = pos;
		_dir = dir;
		_bullitState = BullitState.current;
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

	void process() {
		final switch(_bullitState) {
			case BullitState.current:
				_pos += _dir;
				if (_pos.x < 0 || _pos.x > g_spriteSize * 10 || hits(_pos, g_blocks))
					_bullitState = BullitState.blowingUp;

				//#dummist possible error (bullit not hitting the bady)
				foreach(jeep; g_jeeps) {
					if (jeep.scrn == _scrn &&
						jeep.action != Action.blowingUp && jeep.action != Action.destroyed &&
						_pos.x >= jeep.pos.x && _pos.x < jeep.pos.x + g_spriteSize &&
						_pos.y >= jeep.pos.y && _pos.y < jeep.pos.y + g_spriteSize &&
						! (jeep.facing == Facing.right &&
							_pos.x >= jeep.pos.x && _pos.x < jeep.pos.x + 14 &&
							_pos.y >= jeep.pos.y && _pos.y < jeep.pos.y + 14) &&
						! (jeep.facing == Facing.left &&
							_pos.x >= jeep.pos.x + 18 && _pos.x < jeep.pos.x + 32 &&
							_pos.y >= jeep.pos.y && _pos.y < jeep.pos.y + 14)) {
						with(g_jsounds[Snd.blowup])
							setPitch(2),
							playSnd;
						jeep.action = Action.blowingUp;
						_bullitState = BullitState.blowingUp;
						_owner.dashBoard.banner = "Bady blown up"d;
						_owner.dashBoard.score = _owner.dashBoard.score + 50;
					}
				}
				if (! g_guys[_owner.other].bullitProof &&
					g_guys[_owner.other].portal.scrn == _owner.portal.scrn &&
					_pos.x >= g_guys[_owner.other].pos.x + 4 && _pos.x < g_guys[_owner.other].pos.x + 8 &&
					_pos.y >= g_guys[_owner.other].pos.y + (g_guys[_owner.other].gunDucked == GunDucked.ducked ? 8 : 0) && _pos.y < g_guys[_owner.other].pos.y + g_spriteSize) {
					g_guys[_owner.other].die;
					_bullitState = BullitState.blowingUp;
				}
				_bullitShape.position = _pos;
			break;
			case BullitState.blowingUp:
				_bullitState = BullitState.terminated;
				goto case BullitState.terminated;

			case BullitState.terminated:
				//nothing doing
			break;
		}
	}

	void draw() {
		final switch(_bullitState) {
			case BullitState.current:
				_bullitShape.position = _pos;
				g_window.draw(_bullitShape);
			break;
			case BullitState.blowingUp:
				break;
			case BullitState.terminated:
				//nothing doing
				break;
		}
	}
}

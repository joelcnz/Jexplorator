module bullit;

//#dummist possible error (bullit not hitting the bady)

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

	void process() {
		final switch(_bullitState) {
			case BullitState.current:
				_pos += _dir;
				if (_pos.x < 0 || _pos.x > g_spriteSize * 10 || hits(_pos, g_blocks))
					_bullitState = BullitState.blowingUp;

				if (computerHit(_pos, scrn)) {
					_bullitState = BullitState.blowingUp;
					_owner.dashBoard.banner = "Computer blown up"d;
					_owner.dashBoard.score = _owner.dashBoard.score + 30;
				}

				//#dummist possible error (bullit not hitting the bady)
				if (jeepHit(null, _scrn, _pos, Shooter.guy)) {
					_bullitState = BullitState.blowingUp;
					_owner.dashBoard.banner = "Bady blown up"d;
					_owner.dashBoard.score = _owner.dashBoard.score + 50;
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

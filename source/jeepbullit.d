module jeepbullit;

import base;

class JeepBullit: Mover {
private:
	JRectangle _jeepBullitShape;
	Jeep _jeep;
	Guy _guyTarget;
	JBullit _jbullit;
public:
	@property JBullit jbullit() { return _jbullit; }
	@property void jbullit(JBullit jbullit0) { _jbullit = jbullit0; }

	@property ref JRectangle jeepBullitShape() { return _jeepBullitShape; }
	@property void jeepBullitShape(ref JRectangle jeepBullitShape0) { _jeepBullitShape = jeepBullitShape0; }

	void fire(Jeep jeep0, ref Guy guyTarget0, Vector!int scrn0, Vec pos0, Vec dir0) {
		_jeep = jeep0;
		_guyTarget = guyTarget0;
		pos = pos0;
		scrn = scrn0;
		dir = dir0;
		_jeepBullitShape = JRectangle(SDL_Rect(0,0,4,4),BoxStyle.solid,SDL_Color(128,128,128));
		/+
		_jeepBullitShape.size = Vec(4, 4);
		_jeepBullitShape.fillColor = Color(255, 255, 255);
		+/
		_jbullit = JBullit.current;
	}

	void process() {
		pos = Vec(pos.x + _dir.x, pos.y);
		if (pos.x < 0 || pos.x > g_spriteSize * 10 + 10 ||
			hits(pos, g_blocks)) {
			_jbullit = JBullit.terminated;
		}
		// testing for hitting guy
		foreach(guy; g_guys) {
			if (scrn == guy.portal.scrn && guy.dying == Dying.alive &&
				guy.portal.grace == 0 && pos.x >= guy.pos.x + 8 && pos.x < guy.pos.x + g_spriteSize - 8 &&
				pos.y >= guy.pos.y + (guy.gunDucked && guy.climbing == Climbing.no ? 6 : 0) && pos.y < guy.pos.y + g_spriteSize) {
				_jbullit = JBullit.terminated;
				guy.die;
			}
		}

		if (jeepHit(null, _scrn, _pos, Shooter.jeep)) {
			_jbullit = JBullit.terminated;
			_guyTarget.dashBoard.banner = "Bady blown up & bonus pts";
			_guyTarget.dashBoard.score = _guyTarget.dashBoard.score + 50 * 2;
		}

		if (computerHit(_pos, scrn)) {
			_guyTarget.dashBoard.banner = "Computer blown up & bonus pts";
			_guyTarget.dashBoard.score = _guyTarget.dashBoard.score + 30 * 2;
			_jbullit = JBullit.terminated;
		}
	}

	void setPosition() {
		//if (jeepBullitShape !is null)
			_jeepBullitShape.pos = pos;
	}

	void draw() {
		setPosition;
		if (_jbullit == JBullit.current) {
			jeepBullitShape.draw(gGraph);
		}
	}
}
module jeepbullit;

import base;

class JeepBullit: Mover {
private:
	RectangleShape _jeepBullitShape;
	Jeep _jeep;
	Guy _guyTarget;
	JBullit _jbullit;
public:
	@property JBullit jbullit() { return _jbullit; }
	@property void jbullit(JBullit jbullit0) { _jbullit = jbullit0; }

	@property RectangleShape jeepBullitShape() { return _jeepBullitShape; }
	@property void jeepBullitShape(RectangleShape jeepBullitShape0) { _jeepBullitShape = jeepBullitShape0; }

	void fire(Jeep jeep0, ref Guy guyTarget0, Vector2i scrn0, Vector2f pos0, Vector2f dir0) {
		_jeep = jeep0;
		_guyTarget = guyTarget0;
		pos = pos0;
		scrn = scrn0;
		dir = dir0;
		_jeepBullitShape = new RectangleShape();
		_jeepBullitShape.size = Vector2f(4, 4);
		_jeepBullitShape.fillColor = Color(255, 255, 255);
		_jbullit = JBullit.current;
	}

	void process() {
		pos = Vector2f(pos.x + _dir.x, pos.y);
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
	}

	bool hits(in Vector2f v, in TileName[] tileNames) {
		auto name = getPos(v);
		foreach(n; tileNames)
			if (name == n)
				return true;
		return false;
	}

	version(none) {
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
	}

	void setPosition() {
		if (jeepBullitShape !is null)
			_jeepBullitShape.position = pos;
	}

	void draw() {
		setPosition;
		if (_jbullit == JBullit.current) {
			g_window.draw(jeepBullitShape);
		}
	}
}
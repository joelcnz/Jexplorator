module mover;

import base;

abstract class Mover {
protected:
	Vector2f _pos, _dir;
	Vector2i _scrn;
public:
	@property {
		auto pos() { return _pos; }
		void pos(Vector2f pos0) { _pos = pos0; }
	
		auto dir() { return _dir; }
		void dir(Vector2f dir0) { _dir = dir0; }

		auto scrn() { return _scrn; }
		void scrn(Vector2i scrn0) { _scrn = scrn0; }
	}

	TileName getPos(in Vector2f v, Layer layer = Layer.normal) {
		if (v.x >= 0 && v.y >= 0 && v.x < g_spriteSize * 10 && v.y < g_spriteSize * 10) {
			TileName tile;
			if (layer == Layer.normal)
				tile = g_screens[_scrn.y][_scrn.x].tiles[cast(size_t)(v.y / g_spriteSize)][cast(size_t)(v.x / g_spriteSize)].tileName;
			if (layer == Layer.front)
				tile = g_screens[_scrn.y][_scrn.x].tiles[cast(size_t)(v.y / g_spriteSize)][cast(size_t)(v.x / g_spriteSize)].tileNameFront;
			if (tile == TileName.ledge && v.y % g_spriteSize >= 16)
				return TileName.gap;
			return tile;
		}
		else
			return TileName.gap;
	}
}

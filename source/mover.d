module mover;

import base;

abstract class Mover {
protected:
	Vec _pos, _dir;
	Vector!int _scrn;
public:
	@property {
		auto pos() { return _pos; }
		void pos(Vec pos0) { _pos = pos0; }
	
		auto dir() { return _dir; }
		void dir(Vec dir0) { _dir = dir0; }

		auto scrn() { return _scrn; }
		void scrn(Vector!int scrn0) { _scrn = scrn0; }
	}

	TileName getPos(in Vec v, Layer layer = Layer.normal) {
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

	bool hits(in Vec v, in TileName[] tileNames, Layer layer = Layer.normal) {
		import std.algorithm: canFind;

		return tileNames.canFind(getPos(v, layer));
	}

	bool jeepHit(Jeep current, Vector!int scrn, Vec pos,  Shooter shooter) {
		foreach(jeep; g_jeeps) {
			if (jeep !is current && jeep.scrn == scrn &&
				jeep.action != Action.blowingUp && jeep.action != Action.destroyed &&
				pos.x >= jeep.pos.x && pos.x < jeep.pos.x + g_spriteSize &&
				pos.y >= jeep.pos.y && pos.y < jeep.pos.y + g_spriteSize &&
				! (jeep.facing.asOriginalType == Facing.right &&
					pos.x >= jeep.pos.x && pos.x < jeep.pos.x + 14 &&
					pos.y >= jeep.pos.y && pos.y < jeep.pos.y + 14) &&
				! (jeep.facing.asOriginalType == Facing.left &&
					pos.x >= jeep.pos.x + 18 && pos.x < jeep.pos.x + 32 &&
					pos.y >= jeep.pos.y && pos.y < jeep.pos.y + 14)) {
				if (shooter != Shooter.check) {
					with(g_jsounds[Snd.blowup])
						//setPitch(2),
						play(false);
					jeep.action = Action.blowingUp;
				}

				return true;
			}
		}
		return false;
	}

	bool computerHit(Vec apos, Vector!int ascrn) {
		if (getPos(pos) == TileName.computer && pos.x - makeSquare(pos.x) > 6 && 
			pos.x - makeSquare(pos.x) < g_spriteSize - 7) {
			with(g_jsounds[Snd.blowup])
				//setPitch(2),
				play(false);
			g_computers ~= new Computer(pos, scrn);
			return true;
		}
		return false;
	}
}

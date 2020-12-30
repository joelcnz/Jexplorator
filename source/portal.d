//#for borders
//#which screen
import base;
	
class Portal: Mover {
private:
	Sprite _sprite;
	PortalSide _portalSide;
	Vector!int _resetPosScrn;
	JRectangle _rectangle;
	int _grace; // can't get hit
public:
	@property Vector!int resetPosScrn() { return _resetPosScrn; }
	@property void resetPosScrn(Vector!int resetPosScrn0) { _resetPosScrn = resetPosScrn0; }

	@property int grace() { return _grace; }
	@property void grace(int grace0) { _grace = grace0; }

	this(PortalSide side) {
		_portalSide = side;

		if (side != PortalSide.editor) {
			_pos = Vec(side == PortalSide.left ? 0 : 10 * g_spriteSize, 0);
			_rectangle = JRectangle(SDL_Rect(10+side*(10*32),10,10*32-20,10*32-20),
				BoxStyle.outLine,SDL_Color(0,180,255,64));
		} else {
			_pos = Vec(0,0);
			_rectangle = JRectangle(SDL_Rect(0+10,10,10*32-20,10*32-20),
				BoxStyle.outLine,SDL_Color(64,255,64,64));
		}
	}
	
	TileName getTile(int x, int y) {
		if (x < 0 || x >= 10 || y < 0 || y >= 10)
			return TileName.gap;
		else
			return g_screens[_scrn.y][_scrn.x].tiles[y][x].tileName;
	}

	void process() {
		if (grace)
			grace = grace - 1;
	}
	
	void drawLayer(Vector!int pos, Layer layer = Layer.normal) {
		foreach(cy; 0 .. 10)
			foreach(cx; 0 .. 10) {
				with(g_screens[_scrn.y][_scrn.x].tiles[cy][cx]) {
					Vec vpos = Vec(pos.x + cx * g_spriteSize, cy * g_spriteSize);
					final switch(layer) {
						case Layer.back:
							gGraph.draw(inf[tileNameBack].image, vpos);
						break;
						case Layer.normal:
							gGraph.draw(inf[tileName].image, vpos);
						break;
						case Layer.front:
							gGraph.draw(inf[tileNameFront].image, vpos);
						break;
					}
				} // with
			}
	}
	
	void draw(Border border = Border.no, Layer layer = Layer.normal)
	{
		//if ()
		//	return;

		g_layer = layer;
		final switch(g_layer) {
			case Layer.back:
				final switch(g_mode) {	
					case Mode.play:
						if (border == Border.no) {
							if (_portalSide == PortalSide.left)
								drawLayer(Vector!int(0,0), Layer.back);
						
							if (_portalSide == PortalSide.right)
								drawLayer(Vector!int(320,0), Layer.back);
						}
					break;
					case Mode.edit:
						drawLayer(Vector!int(0,0), Layer.back);
					break;
				}
			break;
			case Layer.normal:
				final switch(g_mode) {	
					case Mode.play:
						if (border == Border.no) {
							if (_portalSide == PortalSide.left)
								drawLayer(Vector!int(0,0));
						
							if (_portalSide == PortalSide.right)
								drawLayer(Vector!int(320,0), Layer.normal);
						}
					break;
					case Mode.edit:
						if (g_layer == Layer.normal) {
							drawLayer(Vector!int(0,0), Layer.normal);
						}
					break;
				}
			break;
		
			case Layer.front:
				final switch(g_mode) {
					case Mode.play:
						if (_portalSide == PortalSide.left)
							drawLayer(Vector!int(0, 0), Layer.front);
						if (_portalSide == PortalSide.right)
							drawLayer(Vector!int(320, 0), Layer.front);
					break;
					case Mode.edit:
						drawLayer(Vector!int(0, 0), Layer.front);
					break;
				}
		} // switch
		if (border)
			_rectangle.draw(gGraph);
	}	
} // portal

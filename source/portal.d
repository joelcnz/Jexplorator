//#for borders
//#which screen
import base;
	
class Portal: Mover {
private:
	Sprite _sprite;
	PortalSide _portalSide;
	Vector2i _resetPosScrn; //############################
	RectangleShape _rectangle;
	int _grace; // can't get hit
public:
	@property Vector2i resetPosScrn() { return _resetPosScrn; }
	@property void resetPosScrn(Vector2i resetPosScrn0) { _resetPosScrn = resetPosScrn0; }

	@property int grace() { return _grace; }
	@property void grace(int grace0) { _grace = grace0; }

	this(PortalSide side) {
		_portalSide = side;
		_sprite = new Sprite;
		_sprite.setTexture = g_texture;

		if (side != PortalSide.editor) {
			_pos = Vector2f(side == PortalSide.left ? 0 : 10 * g_spriteSize, 0);
			_rectangle = new RectangleShape;
			with(_rectangle) {
				position = Vector2f(10 + side * (10 * 32), 10);
				size = Vector2f(10 * 32 - 20,10 * 32 - 20);
				fillColor = Color(0,0,0, 0);
				outlineColor = Color(0,180,255, 64); //Color.Green;
				outlineThickness = 20;
				
				//size = Vector2f(0,0);
			}
		} else {
			_pos = Vector2f(0,0);
			_rectangle = new RectangleShape;
			with(_rectangle) {
				position = Vector2f(0 + 10, 10);
				size = Vector2f(10 * 32 - 20, 10 * 32 - 20);
				fillColor = Color(0,0,0, 0);
				outlineColor = Color(64,255,64, 64); //Color.Green;
				outlineThickness = 20;
			}
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
	
	void drawLayer(Vector2i pos, Layer layer = Layer.normal) {
		foreach(cy; 0 .. 10)
			foreach(cx; 0 .. 10) {
				with(g_screens[_scrn.y][_scrn.x].tiles[cy][cx]) {
					final switch(layer) {
						case Layer.back:
							_sprite.position = Vector2f(pos.x + cx * g_spriteSize, cy * g_spriteSize);
							_sprite.textureRect = IntRect(g_locations[tileNameBack].x, g_locations[tileNameBack].y, g_spriteSize, g_spriteSize);
							g_window.draw(_sprite);
						break;
						case Layer.normal:
							_sprite.position = Vector2f(pos.x + cx * g_spriteSize, cy * g_spriteSize);
							_sprite.textureRect = IntRect(g_locations[tileName].x, g_locations[tileName].y, g_spriteSize, g_spriteSize);
							g_window.draw(_sprite);
						break;
						case Layer.front:
							_sprite.position = Vector2f(pos.x + cx * g_spriteSize, cy * g_spriteSize);
							_sprite.textureRect = IntRect(g_locations[tileNameFront].x, g_locations[tileNameFront].y, g_spriteSize, g_spriteSize);
							g_window.draw(_sprite);
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
								drawLayer(Vector2i(0,0), Layer.back);
						
							if (_portalSide == PortalSide.right)
								drawLayer(Vector2i(320,0), Layer.back);
						}
					break;
					case Mode.edit:
						drawLayer(Vector2i(0,0), Layer.back);
					break;
				}
			break;
			case Layer.normal:
				final switch(g_mode) {	
					case Mode.play:
						if (border == Border.no) {
							if (_portalSide == PortalSide.left)
								drawLayer(Vector2i(0,0));
						
							if (_portalSide == PortalSide.right)
								drawLayer(Vector2i(320,0), Layer.normal);
						}
					break;
					case Mode.edit:
						if (g_layer == Layer.normal) {
							drawLayer(Vector2i(0,0), Layer.normal);
						}
					break;
				}
			break;
		
			case Layer.front:
				final switch(g_mode) {
					case Mode.play:
						if (_portalSide == PortalSide.left)
							drawLayer(Vector2i(0, 0), Layer.front);
						if (_portalSide == PortalSide.right)
							drawLayer(Vector2i(320, 0), Layer.front);
					break;
					case Mode.edit:
						drawLayer(Vector2i(0, 0), Layer.front);
					break;
				}
		} // switch

		if (border)
			g_window.draw(_rectangle);
	}
	
} // portal

import base;

struct Display {
private:
	Portal _portal;
	Layer _layer;
	Guy _guy;
	Bullit _bullit;
	JeepBullit _jeepBullit;
	Jeep _jeep;
	//Escaped _escaped;
	string _verse;
public:
	void setPortalEditLayer(Layer layer) pure nothrow {
		_layer = layer;
	}

	void setPortal(ref Portal portal) pure nothrow {
		_portal = portal;
	}

	void setGuy(ref Guy guy) pure nothrow {
		_guy = guy;
	}

	void setJeep(ref Jeep jeep) pure nothrow {
		_jeep = jeep;
	}

	void setBullit(ref Bullit bullit) pure nothrow {
		_bullit = bullit;
	}

	void setJeepBullit(JeepBullit jeepBullit) pure nothrow {
		_jeepBullit = jeepBullit;
	}

	//void setEscaped(Escaped escaped) pure nothrow {
	//	_escaped = escaped;
	//}

	void setVerse(in string verse) {
		_verse = verse;
		g_letterBase.setText(_verse);
	}

	void display(DisplayType display) {
		with(DisplayType)
			final switch(display) {
				case info:
				//	g_info.draw;
				break;
				//case escaped:
				//	_escaped.draw;
				//break;
				case bullitsDraw:
					_bullit.draw;
				break;
				case jeepDraw:
					_jeep.draw;
				break;
				case jeepBullitDraw:
					_jeepBullit.draw;
				break;
				case mouseDraw:
					g_mouse.draw;
				break;
				case inputJexDraw:
					g_inputJex.draw;
				break;
				case portalNoBorderLayerBackDraw:
					_portal.draw(Border.no, Layer.back);
				break;
				case portalNoBorderLayerNormalDraw:
					_portal.draw(Border.no, Layer.normal);
				break;
				case editLayer:
					g_portals[PortalSide.editor].draw(Border.no, _layer);
				break;
				case guyDraw:
					_guy.draw;
				break;
				case playBorder:
					_portal.draw(Border.yes);
				break;
				case viewVerse:
					g_letterBase.draw;
					//displayGameText(_verse);
				break;
				case mission:
					g_campaign.viewCurrent;
				break;
			}
	}
}

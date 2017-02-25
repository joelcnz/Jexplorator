//#load settings from file
//#why do I need the cast!?
import base,  jext.base;

struct Setup {
	string _currentCampainFileName;
	string _settingsFileName;

	void loadFile() {
	    auto ini = Ini.Parse(_settingsFileName);

	    _currentCampainFileName = ini["settings"].getKey("currentCampainFileName");
	}
	
	void saveFile() {
		import std.stdio;
		
		auto _file = File(_settingsFileName, "w");
		_file.writeln("[settings]");
		_file.writeln(format("currentCampainFileName=%s", _currentCampainFileName));
	}
		
	 int setup() {
		import jext.setup;
		if (jext.setup.setup != 0)
			writefln("Error function: %s, Line: %s", __FUNCTION__, __LINE__);
		

		//#load settings from file
		

		g_jsounds.length = 0;
		g_jsounds ~= JSound("pop.wav");
		g_jsounds ~= JSound("plop.wav");
		g_jsounds ~= JSound("leap.wav");
		g_jsounds ~= JSound("shoot2.wav");
		g_jsounds ~= JSound("blowup.wav");
		g_jsounds ~= JSound("shootJeep.wav");
		g_jsounds ~= JSound("hush.wav"); // rocket sound

		g_window = new RenderWindow(VideoMode(640, 480), "Welcome to Jexplorator");
	
		g_font = new Font;
		g_font.loadFromFile("DejaVuSans.ttf");
		
		g_inputJex = new InputJex(/* position */ Vector2f(330, 480 - 15),
								  /* font size */ 12,
								  /* header */ "-h for help: ",
								  /* Type (oneLine, or history) */ InputType.history);
		
		g_inputJex.addToHistory(""d);
		
		g_texture = new Texture;
		if (! g_texture.loadFromFile("infc.png"))
			return -1;

		// Set the sprites to g_selectSprites
		int x, y; // which sprite
		foreach(id; TileName.brick .. TileName.end) {
			g_locations ~= Location(x * g_spriteSize, y * g_spriteSize); //location on sprites sheet
			
			x++;
			if (x == 19)
				x = 0,
				y++;
		}
		
		// jeepRight1, jeepRight2
		g_jeepLeftGfx.length = 0;
		g_jeepLeftGfx ~= new Sprite;
		with(g_jeepLeftGfx[$-1]) {
			setTexture = g_texture;
			textureRect = IntRect(g_locations[TileName.jeepLeft].x, g_locations[TileName.jeepLeft].y, g_spriteSize, g_spriteSize);
		}
		g_jeepRightGfx.length = 0;
		g_jeepRightGfx ~= new Sprite;
		with(g_jeepRightGfx[$-1]) {
			setTexture = g_texture;
			textureRect = IntRect(g_locations[TileName.jeepRight].x, g_locations[TileName.jeepRight].y, g_spriteSize, g_spriteSize);
		}
		g_jeepBlowUpRight.length = 0;
		foreach(i; TileName.jeepRightBlow1 .. TileName.jeepRightBlow6 + 1) {
			g_jeepBlowUpRight ~= new Sprite;
			g_jeepBlowUpRight[$-1].setTexture = g_texture;
			g_jeepBlowUpRight[$-1].textureRect = IntRect(g_locations[i].x, g_locations[i].y, g_spriteSize, g_spriteSize);
		}
		g_jeepBlowUpLeft.length = 0;
		foreach(i; TileName.jeepLeftBlow6 .. TileName.jeepLeftBlow1 + 1) {
			g_jeepBlowUpLeft ~= new Sprite;
			g_jeepBlowUpLeft[$-1].setTexture = g_texture;
			g_jeepBlowUpLeft[$-1].textureRect = IntRect(g_locations[i].x, g_locations[i].y, g_spriteSize, g_spriteSize);
		}

		g_mode = Mode.edit;

		g_portals[PortalSide.left] = new Portal(PortalSide.left);
		g_portals[PortalSide.right] = new Portal(PortalSide.right);
		g_portals[PortalSide.editor] = new Portal(PortalSide.editor);
		g_portals[PortalSide.other] = new Portal(PortalSide.other);
		g_portals[PortalSide.none] = new Portal(PortalSide.none);

		g_mouse = MouseInput(g_portals[PortalSide.editor]);

		with(TileName)
			g_blocks = [brick, ledge, brickLedge, darkGrayBrick];

		g_guys.length = 0;
		with(Keyboard.Key) {
			g_guys ~= new Guy(0, g_portals[PortalSide.left],
				[W, D, S, A]);
			g_guys ~= new Guy(1, g_portals[PortalSide.right],
				[Up, Right, Down, Left]);
		}
		
		g_scrnDim = Vector2i(0,0);
		
		_settingsFileName = "settings.ini";
		loadFile;

		g_campain.setFileName(_currentCampainFileName);
		if (! g_campain.loadCampain) { //#load campaign here! 
			throw new Exception("File error. Fatal error!");
		}

		g_window.setFramerateLimit(60);

		g_timer.setup;

		/+
		foreach(i, guy; g_guys)
			g_escaped[i] = Escaped(guy);

		foreach(i, guy; g_guys) {
			guy._mission.setUp;
			guy.briefing = true;
		}
		+/

		return 0;
	} // setup
	
	void shutDown() {
		_currentCampainFileName = g_campain.fileName;
		saveFile;
	}
}

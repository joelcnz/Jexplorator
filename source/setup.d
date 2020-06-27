//#new 21 3 2017
//#load settings from file
import base,  jec;

struct Setup {
	string _currentBuildingFileName;
	string _settingsFileName;

	void loadFile() {
	    auto ini = Ini.Parse(_settingsFileName);

	    _currentBuildingFileName = ini["settings"].getKey("currentBuildingFileName");
	}
	
	void saveFile() {
		import std.stdio;
		
		auto file = File(_settingsFileName, "w");
		file.writeln("[settings]");
		file.writeln(format("currentBuildingFileName=%s", _currentBuildingFileName));
	}
		
	 int setup() {
		import jecsdl: setup;

		SCREEN_WIDTH = 640; SCREEN_HEIGHT = 480;
		//SCREEN_WIDTH = 2560; SCREEN_HEIGHT = 1600;
		if (setup("Poorly Programmed Producions - Presents: Vac Space",
			SCREEN_WIDTH, SCREEN_HEIGHT,
			SDL_WINDOW_SHOWN
			//SDL_WINDOW_OPENGL
			//SDL_WINDOW_FULLSCREEN_DESKTOP
			//SDL_WINDOW_FULLSCREEN
			) != 0) {
			writeln("Init failed");
			return 1;
		}

		SDL_version compiled, linked;
		SDL_VERSION(&compiled);
		SDL_GetVersion(&linked);
		writef("Compiled with SDL %d.%d.%d, linked with %d.%d.%d\n",
			compiled.major, compiled.minor, compiled.patch,
			linked.major, linked.minor, linked.patch);

		writeln("Loading ", BibleVersion, " Bible..");
		{
			scope(exit)
				writeln("Bible loaded");
			loadBible(BibleVersion);
		}
		
		//#load settings from file

		g_jsounds.length = 0;
		g_jsounds ~= JSound("pop.wav");
		g_jsounds ~= JSound("plop.wav");
		g_jsounds ~= JSound("leap.wav");
		g_jsounds ~= JSound("shoot2.wav");
		g_jsounds ~= JSound("blowup.wav");
		g_jsounds ~= JSound("shootJeep.wav");
		g_jsounds ~= JSound("hush.wav"); // rocket sound
		g_jsounds ~= JSound("pop2.wav"); // g_jsounds[Snd.pop2].playSnd;

		//g_font = new Font;
		//g_font.loadFromFile("DejaVuSans.ttf");
		import std.string : toStringz;
		g_font = TTF_OpenFont("DejaVuSans.ttf".toStringz, size);
		
		g_terminal = true;
		g_inputJex = new InputJex(/* position */ Vector2f(330, 480 - 15),
								  /* font size */ 12,
								  /* header */ "h for help: ",
								  /* Type (oneLine, or history) */ InputType.history);
		
		g_inputJex.addToHistory(""d);
		g_inputJex.edge = false; //#new 21 3 2017
		
		g_letterBase = new LetterManager("lemgreen32.bmp", 8, 17, // "lemblue.png"
				Square(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)); //20 * 32,28 * 32));
		assert(g_letterBase, "Error loading bmp");

		//g_texture = new Texture;
		//if (! g_texture.loadFromFile("infc.png"))
		//	return -1;
//		g_texture = Image("infc.png");
//		SDL_Texture*[char] tletters;
		import std.string : toStringz;
		SDL_Surface* source = IMG_Load("infc.png".toStringz);

foreach(char i; 32 .. 126 + 1) {
	SDL_Surface* surf = SDL_CreateRGBSurfaceWithFormat(0, width, height - 1, 32, SDL_PIXELFORMAT_RGBA32);
	scope(exit)
		SDL_FreeSurface(surf);
	SDL_Rect rsrc = {1 + (i - 33) * step, 1, width, height - 1};
	SDL_BlitSurface(source, &rsrc, surf, null);
	tletters[i] = SDL_CreateTextureFromSurface(gRenderer, surf);
}

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
		SDL_Surface* surf = SDL_CreateRGBSurfaceWithFormat(0, g_spriteSize, g_spriteSize, 32, SDL_PIXELFORMAT_RGBA32);
		g_jeepLeftGfx.length = 0;
		//g_jeepLeftGfx ~= new Sprite;
		g_jeepLeftGfx ~= 
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
		g_computerBlowUp.length = 0;
		foreach(i; TileName.computerBlow1 .. TileName.computerBlow6 + 1) {
			g_computerBlowUp ~= new Sprite;
			g_computerBlowUp[$-1].setTexture = g_texture;
			g_computerBlowUp[$-1].textureRect = IntRect(g_locations[i].x, g_locations[i].y, g_spriteSize, g_spriteSize);
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
		g_guys ~= new Guy(0, g_portals[PortalSide.left],
			[SDL_SCANCODE_W, SDL_SCANCODE_D, SDL_SCANCODE_S, SDL_SCANCODE_A, SDL_SCANCODE_Z]);
		g_guys ~= new Guy(1, g_portals[PortalSide.right],
			[SDL_SCANCODE_UP, SDL_SCANCODE_RIGHT, SDL_SCANCODE_DOWN, SDL_SCANCODE_LEFT, SDL_SCANCODE_SPACE]);
		
		g_scrnDim = Vector2i(0,0);
		
		_settingsFileName = "settings.ini";
		loadFile;

		g_building.setFileName(_currentBuildingFileName);
		if (! g_building.loadBuilding) { //#load building here! 
			throw new Exception("File error. Fatal error!");
		}

		g_fileRootName = _currentBuildingFileName.to!dstring.stripExtension;

		g_window.setFramerateLimit(60);

		g_timer.setup;

		g_mainPopBanner.setup(["Welcome to Jexplorater","", "by Joel Ezra Christensen"],
			/* pos */ Vector2f(0, 200), /* size */ Vector2f(640, 3 * 16 + 2 * 4));
		g_popLine.set("Welcome to Jexplorater!");
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
		TTF_CloseFont(g_font);
		_currentBuildingFileName = g_building.fileName;
		saveFile;
	}
}

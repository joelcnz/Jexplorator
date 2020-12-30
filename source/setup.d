//#new 21 3 2017
//#load settings from file
import base,  jecfoxid;

struct Setup {
	string _currentBuildingFileName;
	string _settingsFileName;

	void loadSettingsFile() {
	    auto ini = Ini.Parse(_settingsFileName);

	    _currentBuildingFileName = ini["settings"].getKey("currentBuildingFileName");
	}
	
	void saveSettingsFile() {
		import std.stdio;
		
		auto file = File(_settingsFileName, "w");
		file.writeln("[settings]");
		file.writeln(format("currentBuildingFileName=%s", _currentBuildingFileName));
	}
		
	int setup() {
		int SCREEN_WIDTH = 640, SCREEN_HEIGHT = 480;
		//int SCREEN_WIDTH = 2560, SCREEN_HEIGHT = 1600;
		assert(jf_setup("Welcome to Jexploration", SCREEN_WIDTH,SCREEN_HEIGHT), "jf setup failed");

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
			import std.path : buildPath;
			loadBible(BibleVersion, buildPath("..", "BibleLib", "Versions"));
		}
		
		//#load settings from file

		g_jsounds.length = 0;
		void addSound(in string fileName, in string name) {
			g_jsounds ~= new Sound();
			g_jsounds[$ - 1].load(fileName, name);
		}
		//enum Snd {pop, plop, leap, shoot, blowup, shootJeep, rocket, pop2}
		addSound("pop.wav", "pop1");
		addSound("plop.wav", "plop");
		addSound("leap.wav", "leap");
		addSound("shoot2.wav", "shoot");
		addSound("blowup.wav", "blowup");
		addSound("shootJeep.wav", "shootJeep");
		addSound("hush.wav", "rocket");
		addSound("pop2.wav", "pop2");
		//addSound(".wav", "");

		//g_font = new Font;
		//g_font.loadFromFile("DejaVuSans.ttf");
		import std.string : toStringz;
		//g_font = TTF_OpenFont("DejaVuSans.ttf".toStringz, size);
		
		g_terminal = true;
		g_inputJex = new InputJex(/* position */ Vec(330, 480 - 15),
								  /* font size */ 12,
								  /* header */ "h for help: ",
								  /* Type (oneLine, or history) */ InputType.history);
		
		g_inputJex.addToHistory("");
		g_inputJex.edge = false; //#new 21 3 2017
		
		g_letterBase = new LetterManager("lemgreen.png", 9, 16, // "lemblue.png"
				Vec(0,0),SCREEN_WIDTH, SCREEN_HEIGHT); //20 * 32,28 * 32));
		assert(g_letterBase, "Error loading bmp");

		//g_texture = new Texture;
		//if (! g_texture.loadFromFile("infc.png"))
		//	return -1;
//		g_texture = Image("infc.png");
//		SDL_Texture*[char] tletters;
/+
		import std.string : toStringz;
		SDL_Surface* source = IMG_Load("infc.png".toStringz);
+/
		int sprW = 32,sprH = 32;
		Image[] inf0 = loader.load!ImageSurface("inf0.png").imageHandle.strip(Vec(0,0),sprW,sprH)[0..$-2];
		Image[] inf1 = loader.load!ImageSurface("inf1.png").imageHandle.strip(Vec(0,0),sprW,sprH)[0..$-2];
		Image[] inf2 = loader.load!ImageSurface("inf2.png").imageHandle.strip(Vec(0,0),sprW,sprH)[0..$-2];
		Image[] inf3 = loader.load!ImageSurface("inf3.png").imageHandle.strip(Vec(0,0),sprW,sprH)[0..$-2];
		Image[] inf4 = loader.load!ImageSurface("inf4.png").imageHandle.strip(Vec(0,0),sprW,sprH)[0..$-2];
		Image[] inf5 = loader.load!ImageSurface("inf5.png").imageHandle.strip(Vec(0,0),sprW,sprH)[0..$-2];
		Image[] inf6 = loader.load!ImageSurface("inf6.png").imageHandle.strip(Vec(0,0),sprW,sprH)[0..$-2];

		Image[] iminf;
		iminf = inf0~inf1~inf2~inf3~inf4~inf5~inf6;

		inf.length = iminf.length;
		int fi;
		import std.algorithm : each;
		iminf.each!((ref e) {
			e.fromTexture;
			inf[fi] = new Sprite();
			inf[fi].image = e;
			fi += 1;
		});

		g_jeepLeftGfx = [inf[TileName.jeepLeft]];
		g_jeepRightGfx = [inf[TileName.jeepRight]];

		g_jeepBlowUpRight.length = 0;
		foreach(i; TileName.jeepRightBlow1 .. TileName.jeepRightBlow6 + 1) {
			g_jeepBlowUpRight ~= inf[cast(TileName)i];
		}
		g_jeepBlowUpLeft.length = 0;
		foreach(i; TileName.jeepLeftBlow6 .. TileName.jeepLeftBlow1 + 1) {
			g_jeepBlowUpLeft ~= inf[cast(TileName)i];
		}
		g_computerBlowUp.length = 0;
		foreach(i; TileName.computerBlow1 .. TileName.computerBlow6 + 1) {
			g_computerBlowUp ~= inf[cast(TileName)i];
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
		g_guys ~= new Guy(player1, g_portals[PortalSide.left],
			[SDL_SCANCODE_W, SDL_SCANCODE_D, SDL_SCANCODE_S, SDL_SCANCODE_A, SDL_SCANCODE_Z]);
		g_guys ~= new Guy(player2, g_portals[PortalSide.right],
			[SDL_SCANCODE_UP, SDL_SCANCODE_RIGHT, SDL_SCANCODE_DOWN, SDL_SCANCODE_LEFT, SDL_SCANCODE_SPACE]);
		
		g_scrnDim = Vector!int(0,0);
		
		_settingsFileName = "settings.ini";
		loadSettingsFile;

		g_building.setFileName(_currentBuildingFileName);
		if (! g_building.loadBuilding) { //#load building here! 
			throw new Exception("File error. Fatal error!");
		}

		g_fileRootName = _currentBuildingFileName.stripExtension;

		//g_window.setFramerateLimit(60);

		g_timer.setup;

		g_mainPopBanner.setup(["Welcome to Jexplorater","", "by Joel Ezra Christensen"],
			/* pos */ Vec(0, 200), /* size */ Vec(640, 3 * 16 + 2 * 4));
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
		_currentBuildingFileName = g_building.fileName;
		saveSettingsFile;
	}
}

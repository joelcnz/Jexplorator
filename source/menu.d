import base;

struct Menus {
private:
	bool _firstRun = true;
	string[] _mainMenu;
	JText[] _lines;
	string[] _folderNames;
	Menu _menu;
public:
	void setupDisplay(in string[] lines) {
		_lines.length = 0;
		foreach(i, line; lines) {
			_lines ~= JText(line, gFont);
			_lines[$ - 1].setSize = 12;
			_lines[$ - 1].position = Vec(100, 100 + i * 12);
		}
	}

	void setup() {
		if (_firstRun)
			setupDisplay(["* Jecsplorater *",
						"",
						"0. Exit",
						"3. Campaign",
						"",
						"Press a number to continue.."]);
		else
			setupDisplay(["* Jecsplorater *",
					  "",
					  "0. Exit",
					  "1. Play",
					  "2. Edit",
					  "3. Campaign",
					  "",
					  "Press a number to continue.."]);
		_menu = Menu.main;
	}

	void campaignSetup() {
		string[] menu = ["* Jecsplorater *",
						 "",
						 "*0. Cancel"];
		import std.file, std.range;
		int i = 1;
		_folderNames.length = 0;

		import std.range;
		import std.file;
		import std.conv;
		import std.algorithm;
		import std.string;
		foreach(string name; dirEntries(buildPath("Campaigns"), SpanMode.shallow)
			.array.sort!"a.toLower < b.toLower") {
			if (name.isDir) {
				_folderNames ~= name;
				menu ~= text(i, ". ", name.trim);
				i += 1;
			}
		}

		menu ~= ["", "Press a number to continue.."];

		setupDisplay(menu);

		_menu = Menu.campaign;
	}

	MenuSelect process() {

		if (g_keys[SDL_SCANCODE_LCTRL].keyPressed && g_keys[SDL_SCANCODE_ESCAPE].keyPressed) {
			return MenuSelect.quit;
		}

		with(MenuSelect)
			switch(_menu) {
				default:
					break;
				case Menu.main:
					if (! _firstRun) {
						if (g_keys[SDL_SCANCODE_1].keyTrigger) {
							g_gameOver = false;

							return MenuSelect.start;
						}
						if (g_keys[SDL_SCANCODE_2].keyTrigger) {
							return MenuSelect.edit;
						}
					}
					
					if (g_keys[SDL_SCANCODE_3].keyTrigger) {
						campaignSetup;
						while(g_keys[SDL_SCANCODE_3].keyPressed) { SDL_PumpEvents(); }
					}
				break;
				case Menu.campaign:
					if (g_keys[SDL_SCANCODE_0].keyTrigger && ! _firstRun) {
						setup;
						return MenuSelect.start;
					}
					foreach(i; 0 .. 10) {
						SDL_PumpEvents();
						if (g_keys[SDL_SCANCODE_1 + i].keyTrigger && i < _folderNames.length) {
							_firstRun = false;
							g_campaign.setup(_folderNames[i]);
							g_campaign.enterPassWord;
							writeln("Current mission: ", g_campaign._current);

							setup;
							g_building.resetGame;

							return MenuSelect.start;
						}
					}
				break;
			}

		if (g_keys[SDL_SCANCODE_0].keyTrigger || g_keys[SDL_SCANCODE_ESCAPE].keyTrigger) {
			return MenuSelect.quit;
		}

		gGraph.clear();

		draw;

		gGraph.drawning(); // Swap buffers

		return MenuSelect.doLoop;
	}

	void draw() {
		foreach(line; _lines) {
			//g_window.draw(line);
			line.draw(gGraph);
		}
	}
}

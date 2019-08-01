import base;

struct Menus {
private:
	string[] _mainMenu;
	Text[] _lines;
	string[] _folderNames;
	Menu _menu;
public:
	void setupDisplay(in string[] lines) {

		_lines.length = 0;
		foreach(i, line; lines) {
			_lines ~= new Text(line, g_font, 16);
			_lines[$ - 1].position = Vector2f(100, 100 + i * 16);
		}
	}

	void setup() {
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
						 "0. Cancel"];
		import std.file, std.range;
		int i = 1;
		_folderNames.length = 0;
		foreach(string name; dirEntries(buildPath("Campaigns"), SpanMode.shallow)) {
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

		if (Keyboard.isKeyPressed(Keyboard.Key.LSystem) && Keyboard.isKeyPressed(Keyboard.Key.Escape)) {
			g_window.close;
		}

		with(MenuSelect)
			switch(_menu) {
				default:
					break;
				case Menu.main:
					if (nkeys[Number.n1].keyTrigger) {
						g_gameOver = false;

						return MenuSelect.start;
					}
					
					if (nkeys[Number.n2].keyTrigger) {
						return MenuSelect.edit;
					}
					
					if (nkeys[Number.n3].keyTrigger) {
						campaignSetup;
					}
				break;
				case Menu.campaign:
					if (nkeys[Number.n0].keyTrigger) {
						setup;
					}
					//if (g_keys[Keyboard.Key.1].keyTrigger) {
					if (nkeys[Number.n1].keyTrigger) {
						g_campaign.setup(_folderNames[0]);
						g_campaign.enterPassWord;
						writeln("Current mission: ", g_campaign._current);

						g_missionStage = MissionStage.briefing;
						setup;
						g_building.resetGame;

						return MenuSelect.start;
					}
				break;
			}

		if (nkeys[Number.n0].keyTrigger) {
			g_window.close;
		}

		g_window.clear;

		draw;

		g_window.display;

		return MenuSelect.doLoop;
	}

	void draw() {
		foreach(line; _lines) {
			g_window.draw(line);
		}
	}
}

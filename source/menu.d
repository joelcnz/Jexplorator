import base;

struct Menus {
private:
	string[] _mainMenu;
	Text[] _lines;
	string[] _fileNames;
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
		setupDisplay(["* Jexplorater *",
					  "",
					  "0. Exit",
					  "1. Play",
					  "2. Edit",
					  "3. Campain",
					  "",
					  "Press a number to continue.."]);
		_menu = Menu.main;
	}

	void campainSetup() {
		string[] menu = ["* Jecsplorater *",
						 "",
						 "0. Cancel"];

		import std.file, std.range;
		foreach(i, string name; dirEntries(".", "*.{bin}", SpanMode.shallow).enumerate(1)) {
			_fileNames ~= name;
			menu ~= text(i, ". ", name.trim);
		}

		menu ~= ["", "Press a number to continue.."];

		setupDisplay(menu);

		_menu = Menu.campain;
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
						campainSetup;
					}
				break;
				case Menu.campain:
					if (nkeys[Number.n0].keyTrigger) {
						setup;
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


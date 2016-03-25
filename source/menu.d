import base;

struct Menu {
private:
	string[] _mainMenu;
	Text[] _lines;
public:
	void setup() {
		_mainMenu = ["* Jecsplorater *",
					 "",
					 "0. Exit",
					 "1. Play",
					 "2. Edit",
					 "3. Mission",
					 "",
					 "Press a number to continue.."];
		foreach(i, line; _mainMenu) {
			_lines ~= new Text(line, g_font, 16);
			_lines[$ - 1].position = Vector2f(100, 100 + i * 16);
		}
	}

	MainMenu process() {

		if (Keyboard.isKeyPressed(Keyboard.Key.LSystem) && Keyboard.isKeyPressed(Keyboard.Key.Escape)) {
			g_window.close;
		}

		if (nkeys[Number.n0].keyTrigger) {
			g_window.close;
		}

		if (nkeys[Number.n1].keyTrigger) {
			return MainMenu.start;
		}
		
		if (nkeys[Number.n2].keyTrigger) {
			return MainMenu.edit;
		}

		g_window.clear;

		draw;

		g_window.display;

		return MainMenu.doLoop;
	}

	void draw() {
		foreach(line; _lines) {
			g_window.draw(line);
		}
	}
}


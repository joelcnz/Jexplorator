import base;

struct Escaped {
private:
	Text[] _lines;
	EscapeStatus _status;
	Guy _guy;
	RectangleShape _blackPlastic;
public:
	@property EscapeStatus status() { return _status; }
	@property void status(EscapeStatus status0) { _status = status0; }

	void setup(Guy guy) {
		_guy = guy;
		// set up text
		string[] lines;
		lines.length = 2;
		lines[0] = "You have escaped in time";
		foreach(i, line; lines) {
			_lines ~= new Text(line, g_font, 16);
			with(_lines[$ - 1]) {
				position = Vector2f(0, i * 16);
				setStyle = Style.Bold;
			}
		}
		_blackPlastic = new RectangleShape;
		_blackPlastic.size = Vector2f(320, 32);

		_status = EscapeStatus.notEscaped;
	}

	void process() {
		if (_status == EscapeStatus.notEscaped) {
			if (g_score.allDiamondsQ) // have yous collected all the diamonds
				_lines[1].setString = "Your mission was a success!";
			else
				_lines[1].setString = "Your mission failed!";
		}
	}

	void draw() {
		foreach(line; _lines) {
			if (_guy.id == 1)
				line.position = line.position + Vector2f(320, 0);
			_blackPlastic.position = line.position;

			g_window.draw(_blackPlastic);
			g_window.draw(line);

			if (_guy.id == 1)
				line.position = line.position - Vector2f(320, 0);
		}
	}
}

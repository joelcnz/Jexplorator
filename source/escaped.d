import base;

// this was all rem'd out

struct Escaped {
private:
	Font _font;
	JText[] _lines;
	EscapeStatus _status;
	Guy _guy;
	JRectangle _blackPlastic;
public:
	@property EscapeStatus status() { return _status; }
	@property void status(EscapeStatus status0) { _status = status0; }

	void setup(Guy guy) {
		_font = new Font();
		_font.load(g_fontFileName, 16);
		_guy = guy;
		// set up text
		string[] lines;
		lines.length = 2;
		lines[0] = "You have escaped in time";
		foreach(i, line; lines) {
			_lines ~= JText(line, _font);
			with(_lines[$ - 1]) {
				position = Vec(0, i * 16);
				//setStyle = Style.Bold;
			}
		}
		//_blackPlastic = new RectangleShape;
		//_blackPlastic.size = Vec(320, 32);
		_blackPlastic = JRectangle(SDL_Rect(0,0,320,32),
			BoxStyle.solid,SDL_Color(0,0,0));

		_status = EscapeStatus.notEscaped;
	}

	~this() {
		destroy(_font);
	}

	void process() {
		if (_status == EscapeStatus.notEscaped) {
			if (g_score.allDiamondsQ) // have yous collected all the diamonds
				_lines[1].text = "Your mission was a success!";
			else
				_lines[1].text = "Your mission failed!";
		}
	}

	void draw() {
		foreach(line; _lines) {
			if (_guy.id == player2)
				line.position = line.position + Vec(320, 0);
			_blackPlastic.pos = line.position;

			_blackPlastic.draw(gGraph);
			line.draw(gGraph);

			if (_guy.id == player2)
				line.position = line.position - Vec(320, 0);
		}
	}
}

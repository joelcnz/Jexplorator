//#Is this here for good?
//#not sure about this
import base;

/++
score
dimonds - collected
time eclpst
time left
jeeps - distroyed
computers - distroyed
weak walls - distroyed
plops

Score points:
10 diamond
5 jeep
7 wall
(20 screen)
+/
struct DashBoard {
private:
	Text[] _lines;
	int _score;
	int _diamonds;
	int _totalDiamonds;
	Guy _guy;
	dstring _banner;
public:
	@property {
		dstring banner() { return _banner; }
		void banner(dstring banner0) { _banner = banner0; }

		int score() { return _score; }
		void score(int score0) { _score = score0; }

		int diamonds() { return _diamonds; }
		void diamonds(int diamonds0) { _diamonds = diamonds0; }

		int totalDiamonds() { return _totalDiamonds; }
		void totalDiamonds(int totalDiamonds0) { _totalDiamonds = totalDiamonds0; }
	}

	@disable this();

	this(Guy guy) {
		_guy = guy;
		foreach(i; 0 .. 4) {
			_lines ~= new Text("", g_font, 16);
			_lines[$ - 1].position = Vector2f((_guy.id == 0 ? 0 : 320), 320 + i * 16);
		}
		banner = "Game started"d;
	}

	void process() {
		import std.conv: text;
		int i;
		_lines[i++].setString = _banner;
		_lines[i++].setString = text("Score: ", score).to!dstring;
		_lines[i++].setString = text("Diamonds ", diamonds, " of ", totalDiamonds - g_guys[_guy.id == 0 ? 1 : 0].dashBoard.diamonds).to!dstring;
		version(timeStuff) _lines[i++].setString = text("Time: ", countDown).to!dstring;
	}

	void draw() {
		foreach(line; _lines) {
			g_window.draw(line);
		}
	}
}

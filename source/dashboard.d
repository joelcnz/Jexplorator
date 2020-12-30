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
	static int _totalDiamonds;
	Font _font;
	JText[] _lines;
	int _score;
	int _diamonds;
	Guy _guy;
	string _banner;
public:
	@property {
		static int totalDiamonds() { return _totalDiamonds; }
		static void totalDiamonds(int totalDiamonds0) { _totalDiamonds = totalDiamonds0; }

		string banner() { return _banner; }
		void banner(string banner0) { _banner = banner0; }

		int score() { return _score; }
		void score(int score0) { _score = score0; }

		int diamonds() { return _diamonds; }
		void diamonds(int diamonds0) { _diamonds = diamonds0; }
	}

	@disable this();

	this(Guy guy) {
		_font = new Font();
		_font.load(g_fontFileName,16);
		_guy = guy;
		foreach(i; 0 .. 4) {
			_lines ~= JText("", _font);
			_lines[$ - 1].position = Vec((_guy.id == 0 ? 0 : 320), 320 + i * 16);
		}
		banner = "Game started";
	}

	void process() {
		import std.conv: text;
		int i;
		_lines[i++].text = _banner;
		_lines[i++].text = text("Score: ", score);
		_lines[i++].text = text("Diamonds ", diamonds, " of ", totalDiamonds);
		//version(timeStuff) _lines[i++].setString = text("Time: ", countDownTimer).to!dstring;
	}

	void draw() {
		foreach(line; _lines) {
			line.draw(gGraph);
		}
	}
}

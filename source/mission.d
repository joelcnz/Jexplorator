//#bold not work!
import base;

struct Mission {
private:
	static Font _sfont;
	JText[] _lines;
	MissionStatus _status;
	Guy _guy;

	string _briefing;
	string _success;
	string _failure;
public:
	@property MissionStatus status() { return  _status; }
	@property void status(MissionStatus briefing0) { _status = briefing0; }

	void setup(Guy guy) {
		if (_sfont is null) {
			_sfont = new Font();
			_sfont.size = 16;
		}
		writeln("where am I?!");
		_guy = guy;
		auto lines = ["Your mission is to",
			"score the most points",
			"and to get away in the rocket",
			"",
			"Press " ~ (_guy.id == 0 ? "Z" : "Space") ~ " to continue"];
		foreach(i, line; lines) {
			_lines ~= JText(line, _sfont);
			with(_lines[$ - 1]) {
				position = Vec(0, i * 16);
				//setStyle = Style.Bold; //#bold not work!
				//setStyle = Style.Italic | Style.Underlined;
			}
		}
		_status = MissionStatus.current;
	}

	void process() {
		// Press Space to continue
		/+
		if ((_guy.id == 0 && lkeys[Letter.z].keyTrigger) ||
			(_guy.id == 1 && kSpace.keyTrigger))
				_status = MissionStatus.done;
			+/
	}
	
	void draw() {
		/+
		foreach(line; _lines) {
			if (_guy.id == 1)
				line.position = line.position + Vec(320, 0);
			g_window.draw(line);
			if (_guy.id == 1)
				line.position = line.position - Vec(320, 0);
		}
		+/
	}
}

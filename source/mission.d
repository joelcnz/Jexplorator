//#bold not work!
import base;

struct Mission {
private:
	Text[] _lines;
	MissionStatus _status;
	Guy _guy;
public:
	@property MissionStatus status() { return  _status; }
	@property void status(MissionStatus briefing0) { _status = briefing0; }

	void setup(Guy guy) {
		_guy = guy;
		auto lines = ["Your mission is to"d, "score the most points", "and to get away in the rocket", "", "Press "d ~ (_guy.id == 0 ? "Z"d : "Space"d) ~ " to continue"d];
		foreach(i, line; lines) {
			_lines ~= new Text(line, g_font, 16);
			with(_lines[$ - 1]) {
				position = Vector2f(0, i * 16);
				setStyle = Style.Bold; //#bold not work!
				//setStyle = Style.Italic | Style.Underlined;
			}
		}
		_status = MissionStatus.current;
	}

	void process() {
		// Press Space to continue
		if ((_guy.id == 0 && lkeys[Letter.z].keyTrigger) ||
			(_guy.id == 1 && kSpace.keyTrigger))
				_status = MissionStatus.done;
	}
	
	void draw() {
		foreach(line; _lines) {
			if (_guy.id == 1)
				line.position = line.position + Vector2f(320, 0);
			g_window.draw(line);
			if (_guy.id == 1)
				line.position = line.position - Vector2f(320, 0);
		}
	}
}

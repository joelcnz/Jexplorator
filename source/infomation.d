import base;

struct GameInfo {
private:
	string _levelLocation;
	string _levelName;
public:
	void upDate(string levelName) { //(Vector2f ll) {
		//_levelLocation = levelLocation;
		_levelName = levelName;
	}
}
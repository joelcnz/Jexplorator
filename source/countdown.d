/+
counter goes up and up. Go to the landing pad and take a note of the time.
 +/
module countdown;

import base;

struct CountDown {
private:
	float _countDownTime, _countDownStartTime; // g_countStartDownTime - g_countDownTime -- or some thing
	Text _timeGoingUp, _timeGoingDown;
public:
	@property {
		auto countDownTime() { return _countDownTime; }
		void countDownTime(float countDownTime0) { _countDownTime = countDownTime0; }

		auto countDownStartTime() { return _countDownStartTime; }
		void countDownStartTime(float countDownStartTime0) { _countDownStartTime = countDownStartTime0; }
	}

	void setup(int totalSeconds = 0) {
		_timeGoingUp = new Text(""d, g_font, 10);
		_timeGoingUp.position(Vector2f(0, 480 - 20)); // 10 * g_spriteSize + 10));
		_timeGoingDown = new Text(""d, g_font, 10);
		_timeGoingDown.position(Vector2f(0, 480 - 10)); // 10 * g_spriteSize + 10 + 10));
		g_clock = new Clock(); // starts the clock
		countDownTime = 0;
		_countDownStartTime = 1_000;
	}

	void doStart() {
		g_clock.restart();
	}

	float getTimeLeft() {
		return _countDownStartTime - _countDownTime; //g_clock.getElapsedTime.asMilliseconds;
	}

	void process() {
		_countDownTime = g_clock.getElapsedTime.asSeconds;
		_timeGoingUp.setString = text("Timer: ", cast(int)(_countDownTime)).to!dstring;
		_timeGoingDown.setString = text("Time Left: ", cast(int)(_countDownStartTime - _countDownTime)).to!dstring;
	}

	void draw() {
		g_window.draw(_timeGoingUp);
		g_window.draw(_timeGoingDown);
	}
}

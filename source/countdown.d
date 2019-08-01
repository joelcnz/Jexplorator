/+
counter goes up and up. Go to the landing pad and take a note of the time.
 +/
module countdown;

import base;

struct CountDown {
private:
	float _countUpTimer, _countDownTimer, _countDownStartTime; // g_countStartDownTime - g_countDownTime -- or some thing
	Text _timeGoingUp, _timeGoingDown;
public:
	@property {
		auto countDownTimer() { return _countDownTimer; }
		void countDownTimer(float countDownTimer0) { _countDownTimer = countDownTimer0; }

		auto countUpTimer() { return _countUpTimer; }
		void countUpTimer(float countUpTimer0) { _countUpTimer = countUpTimer0; }

		auto countDownStartTime() { return _countDownStartTime; }
		void countDownStartTime(float countDownStartTime0) { _countDownStartTime = countDownStartTime0; }
	}

	void setup(int totalSeconds = 10_000) {
		_timeGoingUp = new Text(""d, g_font, 10);
		_timeGoingUp.position(Vector2f(0, 480 - 20)); // 10 * g_spriteSize + 10));
		_timeGoingDown = new Text(""d, g_font, 10);
		_timeGoingDown.position(Vector2f(0, 480 - 10)); // 10 * g_spriteSize + 10 + 10));
		g_clock = new Clock(); // starts the clock
		countDownTimer = 0;
		countDownStartTime = totalSeconds;
	}

	void doStart() {
		g_clock.restart();
	}

	float getTimeLeft() {
		return countDownTimer; //g_clock.getElapsedTime.asMilliseconds;
	}

	void process() {
		//_countUpTimer = g_clock.getElapsedTime.asSeconds;
		_countUpTimer = g_clock.getElapsedTime.total!"seconds";
		_countDownTimer = _countDownStartTime - _countUpTimer;
		_timeGoingUp.setString = text("Timer: ", cast(int)(_countUpTimer)).to!dstring;
		_timeGoingDown.setString = text("Time Left: ", cast(int)(_countDownTimer)).to!dstring;
		//if (_countDownTimer > -1 && _countDownTimer < 1) {
		if (cast(int)_countDownTimer == 0 && g_gameOver == false) {
			writeln("Game over!");
			g_gameOver = true;
			foreach(g; g_guys)
				if (g.escapeStatus != GuyEscapeStatus.playing) {
					g.escapeStatus = GuyEscapeStatus.outOfTime;
					g.banner.setText(["Time Out!"]);
					g.banner.show;
				}
		}
	}

	void draw() {
		g_window.draw(_timeGoingUp);
		g_window.draw(_timeGoingDown);
	}
}

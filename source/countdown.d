/+
counter goes up and up. Go to the landing pad and take a note of the time.
 +/
module countdown;

//#me know understand?! - says time out even you escaped

import base;

struct CountDown {
private:
	float _countUpTimer, _countDownTimer, _countDownStartTime; // g_countStartDownTime - g_countDownTime -- or some thing
	Font _font;
	JText _timeGoingUp, _timeGoingDown;
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
		_font = new Font();
		_font.load(g_fontFileName, 10);
		_timeGoingUp = JText("", _font);
		_timeGoingUp.position = Vec(0, 480 - 20); // 10 * g_spriteSize + 10));
		_timeGoingDown = JText("", _font);
		_timeGoingDown.position = Vec(0, 480 - 10); // 10 * g_spriteSize + 10 + 10));
		//g_clock = new Clock(); // starts the clock
		doStart();
		countDownTimer = 0;
		countDownStartTime = totalSeconds;
	}

	~this() {
		destroy(_font);
	}

	void doStart() {
		g_clock.reset();
		g_clock.start;
	}

	float getTimeLeft() {
		return countDownTimer; //g_clock.getElapsedTime.asMilliseconds;
	}

	void process() {
		//_countUpTimer = g_clock.getElapsedTime.asSeconds;
		_countUpTimer = g_clock.peek().total!"seconds";
		_countDownTimer = _countDownStartTime - _countUpTimer;
		_timeGoingUp.text = text("Timer: ", cast(int)(_countUpTimer));
		_timeGoingDown.text = text("Time Left: ", cast(int)(_countDownTimer));
		//if (_countDownTimer > -1 && _countDownTimer < 1) {
		if (cast(int)_countDownTimer == 0 && g_gameOver == false) {
			writeln("Game over!");
			g_gameOver = true;
			foreach(g; g_guys)
				if (g.escapeStatus != GuyEscapeStatus.playing) { //#me know understand?! - says time out even you escaped
					g.escapeStatus = GuyEscapeStatus.outOfTime;
					g.banner.setText(["Time Out!"]);
					g.banner.show;
				}
		}
	}

	void draw() {
		_timeGoingUp.draw(gGraph);
		_timeGoingDown.draw(gGraph);
	}
}

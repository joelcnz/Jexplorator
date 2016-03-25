import base;

struct JSound {
	SoundBuffer _buf;
	Sound _snd;
	float _pitch;
	
	this(string fileName) {
		_buf = new SoundBuffer;
		_buf.loadFromFile(fileName);
		_snd = new Sound;
		_snd.setBuffer(_buf);
	}

	void setPitch(float pitch) {
		_snd.pitch(pitch);
	}
	
	void playSnd() {
		_snd.play;
	}
}
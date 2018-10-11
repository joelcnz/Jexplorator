import base;

struct PopBanner {
    Text _txt;
    RectangleShape _backBlock;

    void set() {
	    _backBlock.size = Vector2f(320, 50);
        _backBlock.position = Vector2f(0, 100);
    }

    void draw() {
        g_window.draw(_backBlock);
    }
}
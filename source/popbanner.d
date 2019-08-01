import base;

struct PopBanner {
    Text[] _txts;
    RectangleShape _backBlock;
    bool _show;

    bool show() { return _show; }
    void show(bool show0) { _show = show0; }

    void setup(in string[] lines, Vector2f pos, Vector2f size) {
        _backBlock = new RectangleShape();
        _backBlock.position = pos;
	    _backBlock.size = size;
        _backBlock.fillColor = Color(0,0,0, (0.75).decimalToByte);

        setText(lines);

        show = true;
    }

    void setText(in string[] lines) {
        _txts.length = 0;
        foreach(y, line; lines) {
            _txts ~= new Text(line, g_font, 16);
            assert(_txts, "error creating Text object!");
            with(_txts[$ - 1]) {
                setColor = Colour.gold;
                position = Vector2f(_backBlock.position.x + 4, _backBlock.position.y + 2 + y * 16);
            }
        }
    }

    void draw() {
        g_window.draw(_backBlock);
        import std.algorithm : each;
        _txts.each!(txt => g_window.draw(txt));
    }
}
import base;

struct PopBanner {
    Font _font;
    JText[] _txts;
    JRectangle _backBlock;
    bool _show;

    bool show() { return _show; }
    void show(bool show0) { _show = show0; }

    void setup(in string[] lines, Vec pos, Vec size) {
        _font = new Font();
        _font.load(g_fontFileName, 16);
        _backBlock = JRectangle(SDL_Rect(cast(int)pos.x,cast(int)pos.y,cast(int)size.x,cast(int)size.y),
            BoxStyle.solid,SDL_Color(0,0,0, 192)); //(0.75f).decimalToByte));
        /+
        _backBlock.position = pos;
	    _backBlock.size = size;
        _backBlock.fillColor = Color(0,0,0, ); //(0.75).decimalToByte);
        +/

        setText(lines);

        show = true;
    }

    ~this() {
        destroy(_font);
        writeln("font destroyed (and !this called) in PopBanner");
    }

    void setText(in string[] lines) {
        _txts.length = 0;
        foreach(y, line; lines) {
            _txts ~= JText(line, _font);
            assert(_txts, "error creating Text object!");
            with(_txts[$ - 1]) {
                colour = Color(255,180,0);
                position = Vec(_backBlock.pos.x + 4, _backBlock.pos.y + 2 + y * 16);
            }
        }
    }

    void draw() {
        gWin.blendMode = BlendMode.blend;
        _backBlock.draw(gGraph);
        gWin.blendMode = BlendMode.none;

        import std.algorithm : each;
        _txts.each!(txt => txt.draw(gGraph));
    }
}

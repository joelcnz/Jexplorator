module popline;

//#magic number

import std.algorithm : each;

import base;

struct PopLineMan {
    PopLine _popLines;
    Vector2f _pos;

    void add(in string message) {
        //Popline pl;
        //pl.set(message);
        //_popLines ~= pl;
    }

    void process() {
        /+
        foreach(ref pl; _popLines) {
            pl.process;
        }
        _popLines.filter!(pl => pl._pban.show);
        foreach(y, ref pl; _popLines) {
            //pl._pban.setup(pl._pban., )
        }
        +/
    }
}

struct PopLine {
    PopBanner _pban;
    StopWatch _sw;

    void set(in string message) { //}, Vector2f pos) {
        _pban.setup([message], Vector2f(0, 0), Vector2f(640,24));
        _sw.reset;
        _sw.stop;
        _sw.start;
    }

    void process() {
        if (_sw.peek.total!"msecs" > 1_200) {
            _pban.show = false;
        }
    }

    void draw() {
        _pban.draw;
    }
}

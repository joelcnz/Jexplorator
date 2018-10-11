//#not work
module disc;

import base;

struct Disc {
    Point _pos;
    string _data;
}

struct DiscMan {
    Disc[] _discs;

    void add(Point pos) {
        _discs ~= Disc(pos);
    }

    void remove(Point pos) {
        import std.algorithm: remove;
        import std.array: array;

        //#not work
        //_discs = _discs.remove(d => d._pos == pos).array;
    }
}
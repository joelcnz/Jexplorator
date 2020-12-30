module computer;

import base;

class Computer : Mover {
    CPUState _cpuState;
    int _blowUpFrameTiming, _blowUpFrame;

    this(Vec pos, Vector!int scrn0) {
        super.scrn = scrn0;
        super.pos = makeSquare(pos);
        setTile(scrn, pos, TileName.computerBlow6);
        foreach(i; 0 .. 6)
            g_computerBlowUp[i].position = makeSquare(pos);
        _cpuState = CPUState.brandNew;
    }

    void process() {
        _blowUpFrameTiming += 1;
        if (_blowUpFrameTiming == 5) {
            _blowUpFrameTiming = 0,
            _blowUpFrame += 1;
            if (_blowUpFrame == 6) {
                _cpuState = CPUState.rubble;
            }
        }
    }

    void draw() {
        gGraph.draw(g_computerBlowUp[_blowUpFrame].image, g_computerBlowUp[_blowUpFrame].position);
    }
}

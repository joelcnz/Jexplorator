module campaign;

import base;

struct qMission {
    string _name;
    int _mission;
    string _password;
    string _start, // briefing
        _win,
        _lose;
    string _building;
    int _time;
    int _diamonds;
//    MissionStage _missionStage;

    string toString() const {
        return text("Name: ", _name, ", Mission: ", _mission, ", Password: ", _password,
            ", Start: ", _start, ", Win: ", _win, ", Lose: ", _lose, ", Building: ", _building,
            ", Time: ", _time, ", Diamonds: ", _diamonds);
    }
}

struct Campaign {
    qMission[] _missions;
    qMission _current;
    PopBanner _briefing,
        _report;

    void setup(in string folderName) {
        import std.file;
        int mid = 1;
        string fileName;        
        while(true) {
            fileName = buildPath(folderName, "mission" ~ mid.to!string ~ ".ini");
            if (! fileName.exists)
                break;
            writeln("Process: ", fileName);
            auto ini = Ini.Parse(fileName);
            
            qMission m;
            try {
                with(m) {
                    _start = ini["mission"].getKey("start");
                    _building = ini["mission"].getKey("building");
                    _time = ini["mission"].getKey("time").to!int;
                    _win = ini["mission"].getKey("win");
                    _lose = ini["mission"].getKey("lose");
                    _password = ini["mission"].getKey("password");
                    _diamonds = ini["mission"].getKey("diamonds").to!int;
                }
            } catch(Exception e) {
                writeln("Error doing campaign!");
                return;
            }
            with(m)
                add("name", mid, _password, _start, _win, _lose, _building, _time, _diamonds);
            mid += 1;
        }
        foreach(i, m; _missions)
            writeln("\n", m);
    }

    void add(in string name, in int mission, in string password, in string start, in string win, in string lose,
            in string building, in int time, in int diamonds) {
        _missions ~= qMission(name, mission, password, start, win, lose, building, time, diamonds);
    }

    void enterPassWord() {
        int fontSize = 12;
        auto password = new InputJex(
            /* position */ Vector2f(0, 0),
            /* font size */ fontSize,
            /* header */ "Enter password: ",
            /* Type (oneLine, or history) */ InputType.oneLine);
        password.setColour(Color.White);

        bool done = false;
        while(! done) {
            Event event;
		
            while(g_window.pollEvent(event))
            {
                if(event.type == event.EventType.Closed)
                {
                    g_window.close();
                }
            }

            done = ! g_window.isOpen();

            password.process;

            if (password.enterPressed) {
                password.enterPressed = false;
                foreach(m; _missions)
                    if (password.textStr.to!string == m._password) {
                        _current = m;
                        done = true;
                    }
            }

            g_window.clear;
            password.draw;
            g_window.display;
        }
        setBriefing;
    }

    void setBriefing() {
        auto lines = _current._start.split("|");
        _briefing.setup(lines, Vector2f(0, 0), Vector2f(640, lines.length * 18));
        g_guys[player1].reset;
        g_guys[player2].reset;
    }

    void setReport(bool win) {
        string[] lines;

        if (win) {
            lines = _current._win.split("|");
            lines ~= "";
            if (_current._mission == _missions.length)
                lines ~= "You have completed Explore!";
            else {
                lines ~= "Next Mission Password: " ~ _missions[/* next mission */ _current._mission]._password;
            }
        } else
            lines = _current._lose.split("|");

        _report.setup(lines, Vector2f(0, 0), Vector2f(640, lines.length * 18));
    }

    void viewCurrent() {
        final switch(g_missionStage) with(MissionStage) {
            case briefing:
                _briefing.draw;
            break;
            case playing:
            break;
            case report:
                _report.draw;
            break;
        }
    }
}

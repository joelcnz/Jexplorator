//#new (verse reference)
//#made template instead of normal functions
//#not used
public:
import std.stdio;
import std.conv;
import std.string;

import jec, dini.dini, jmisc;
import bible.base;
import portal, mouse, guy, building, score, countdown, setup, display;
import jeep, bullit, mover, jeepbullit, escaped, mission,
    dashboard, menu, infomation, gametext;

import dsfml.graphics;
import dsfml.audio;
import dsfml.window;

Setup g_setup;
Info g_info;

LetterManager g_letterBase;
bool g_displayGameText;

immutable ESV = "esv";

enum g_pixelsx = 2,
	 g_pixelsy = 2;

enum Hide {inview, hidden}

enum MissionStatus {current, done} // current - displays text about the mission, done - in game
enum EscapeStatus {escaped, notEscaped}

enum Snd {pop, plop, leap, shoot, blowup, shootJeep, rocket}
JSound[] g_jsounds; // g_jsounds[Snd.shootJeep].playSnd;

Clock g_clock;
CountDown g_timer;

bool g_gameOver;

enum Climbing {no, up, down}

const g_graceStartTime = 100;

enum Dying {alive, inRocket, dyingUp, dyingDown}

/+
void gh(string message = "got here") { // g and h beside each other on the keyboard
	writeln(message);
}
+/

enum JBullit {terminated, current}

enum Action {leftRight, turning, falling, stunned, shooting, blowingUp, destroyed}

Bullit[] g_bullits;
enum BullitState {alive, terminated, blowingUp}

enum GunDucked {notDucked, ducked}

Sprite[] g_jeepLeftGfx, g_jeepRightGfx, g_jeepBlowUpLeft, g_jeepBlowUpRight;

enum DisplayType {escaped, mouseDraw, inputJexDraw, portalNoBorderLayerBackDraw, info,
	portalNoBorderLayerNormalDraw, editLayer, guyDraw, playBorder, jeepDraw, bullitsDraw,
	jeepBullitDraw, viewVerse}

Display g_display;

enum Menu {main, building}
enum MenuSelect {quit, edit, start, doLoop}

//#made template instead of normal functions
float makeSquare(T : float)(T a) {
	return cast(int)(a / g_spriteSize) * cast(float)g_spriteSize;
}

Vector2f makeSquare(T : Vector2f)(T a) {
	return Vector2f(makeSquare(a.x), makeSquare(a.y));
}

Score g_score;

enum TileName {brick, darkBrick, brickLedge, ladder, piller, potPlant, oilDrum, computer, brick2, block, gap, spikes, weakBrick,
	rocket, brickGray, switchUp, switchDown, darkGrayBrick, ledge,
	
		jeepRight, jeepRightBlow1, jeepRightBlow2, jeepRightBlow3, jeepRightBlow4, jeepRightBlow5, jeepRightBlow6, piller2,
	computerBlow1, computerBlow2, computerBlow3, computerBlow4, computerBlow5, computerBlow6, diamond,
	undefined1, undefined2, undefined3, undefined4,

		guyWalkRight1, guyWalkRight2, guyAimRight, guyTiggerPulledRight, guyWalkLeft1, guyWalkLeft2, guyAimLeft,
	guyTiggerPulledLeft, climb1, climb2, duckRight1, duckLeft1, plopFall, plopUp, duckRight2, duckLeft2, undefined5, undefined6, undefined7,
					
		weakBrickBlow1, weakBrickBlow2, weakBrickBlow3, weakBrickBlow4, weakBrickBlow5, weakBrickBlow6, darkBrick2, jeepLeft,
	u0,u1,u2,u3,u4,u5,u6,u7,u8,u9,u10, 
	rail, light, picture1, picture2, hintArrow, pipe1, pipe2, pipe3, pipe4, disc, a1,a2,a3,a4,a5,a6,a7,a8,a9,
	hanger, pipe5, pipe6, pipe7, pipe8, pipe9, pipe10,z1,z2,z3,z4,z5,z6,z7,z8,z9,z10,z11,z12,
	jeepLeftBlow6, jeepLeftBlow5, jeepLeftBlow4, jeepLeftBlow3, jeepLeftBlow2, jeepLeftBlow1, end}

enum Facing {left, right}

enum PortalSide {left, right, editor, other, none}
Portal[5] g_portals;

//enum 

Vector2i g_scrnDim;

enum Border {yes,no}

Building g_building;

// Location of the sprites in the sprite image
struct Location {
	int x, y;
}
Location[] g_locations;

enum Layer {back, normal, front}
Layer g_layer;

struct Tile {
	TileName tileNameBack;
	TileName tileName;
	TileName tileNameFront;
//	Sprite sp; //#not used
}

struct Screen {
	Tile[][] tiles;//#new (verse reference)
	string verseRef;
}
Screen[][] g_screens;

MouseInput g_mouse;

Guy[] g_guys;
Jeep[] g_jeeps;

TileName[] g_blocks;

Vector2f topLeft, topRight, leftTop, rightTop,
	leftBottom, rightBottom, bottomLeft, bottomRight,
	bottomPartLeft, bottomPartRight, leftPartUp,
	leftPartDown, rightPartUp, rightPartDown,
	leftMid, rightMid, mid;

void processTestPoints(Vector2f pos) nothrow {
	topLeft = Vector2f(pos.x, pos.y - 1);
	topRight = Vector2f(pos.x + g_spriteSize - 1, pos.y - 1);
	leftTop = Vector2f(pos.x - 1, pos.y);
	leftMid = Vector2f(pos.x - 1, pos.y + g_spriteSize / 2);
	leftBottom = Vector2f(pos.x - 1, pos.y + g_spriteSize - 1);
	rightTop = Vector2f(pos.x + g_spriteSize, pos.y);
	rightMid = Vector2f(pos.x + g_spriteSize, pos.y + g_spriteSize / 2);
	rightBottom = Vector2f(pos.x + g_spriteSize, pos.y + g_spriteSize - 1);
	rightTop = Vector2f(pos.x + g_spriteSize, pos.y);
	bottomLeft = Vector2f(pos.x, pos.y + g_spriteSize);
	bottomRight = Vector2f(pos.x + g_spriteSize - 1, pos.y + g_spriteSize );
	bottomPartLeft = Vector2f(pos.x + ((g_spriteSize / 4) * 2), pos.y + g_spriteSize);
	bottomPartRight = Vector2f(pos.x + g_spriteSize / 4, pos.y + g_spriteSize);
	mid = Vector2f(pos.x + g_spriteSize / 2, pos.y + g_spriteSize / 2);
}

bool inBounds(Vector2f pos) {
	return (pos.x >= 0 && pos.y >= 0 && pos.x < 10 * g_spriteSize && pos.y < 10 * g_spriteSize);
}

bool[4] getScreens(Vector2i scrn) {
	bool[4] result;

	if (scrn == g_portals[PortalSide.left].scrn)
		result[PortalSide.left] = true;
	if (scrn == g_portals[PortalSide.right].scrn)
		result[PortalSide.right] = true;
	if (scrn == g_portals[PortalSide.editor].scrn)
		result[PortalSide.editor] = true;

	return result;
}

//bool inOneScreen(Vector2i scrn) {
//	if (scrn == 
//}

bool inScreen(Vector2i scrn, bool jeep = false) {
	version(none) {
	writeln("jeep: ", scrn,
		" left: ", g_portals[PortalSide.left].scrn,
		" right: ", g_portals[PortalSide.right].scrn,
		" editor: ", g_portals[PortalSide.editor].scrn);
	}
	if (g_mode == Mode.play && (scrn == g_portals[PortalSide.left].scrn ||
		scrn == g_portals[PortalSide.right].scrn))
		return true;
	if (! jeep && g_mode == Mode.edit && scrn == g_portals[PortalSide.editor].scrn)
		return true;
	return false;
}

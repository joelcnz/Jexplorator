module building;

//#back up files TO DO
//#bit of a hack
// Old total diamonds (g_score.totalDiamonds) is not used
//#Forget g_score total diamonds
//#for if you load a smaller project from a bigger one
//#unittest - How do I used this?
import stdc = core.stdc.stdio;

import base;

//version = computersOutPut;
//version = computerDataChange;
//computerdata.txt

struct Building {
private:
	string _fileName;
public:
	string fileName() { return _fileName; }
	
	void setFileName(in string fileName) {
		_fileName = fileName;
		import std.path : stripExtension;
		g_currentProjectName = fileName.trim.stripExtension;
		mixin(trace("g_currentProjectName"));
	}
	
	void resetGame() {
		assert(loadBuilding, "Failed loading building");
		foreach(ref guy; g_guys)
			guy.reset;
		/+
			with(guy) {
				dashBoard.diamonds = 0;
				pos = resetPos;
				portal.scrn = portal.resetPosScrn;
			}
		+/
		g_timer.setup(g_campaign._current._time);
		g_gotTargetDiamonds = false;
		//g_timer.countDownTimer = g_timer.countDownStartTime;
		g_inputJex.addToHistory("Game mission reset!");
	}

	bool loadBuilding() {
		g_gameOver = false;

		import std.file;
		g_inputJex.addToHistory(text(`Loading "`, fileName.trim, `" Building...`));
		if (! exists(_fileName)) {
			g_inputJex.addToHistory(text(`File "`, fileName.trim, `" does not exist!`));
			return false;
		}

		//#for if you load a smaller project from a bigger one
		foreach(portal; g_portals)
			portal.scrn = Vector!int(0,0);
		g_jeeps.length = 0;

		foreach(guy; g_guys)
			guy.reset;

		float fx, fy;
		int ix, iy;
		import std.string;
		FILE* pfile = stdc.fopen(toStringz(fileName), "rb");
		scope(success) {
			fclose(pfile);
		}
		scope(failure) {

		}
		
		int ver;
		fread(&ver, 1, ver.sizeof, pfile); // read version

		g_inputJex.addToHistory(text("Version: ", ver));

		switch(ver) {
			default:
				oldVersions(pfile, ver);
			break;
			case 10:
				fread(&ix, 1, ix.sizeof, pfile); // 1 which screen editor
				fread(&iy, 1, iy.sizeof, pfile);
				g_portals[PortalSide.editor].scrn = Vector!int(ix, iy);
				writeln("Portal screen editor (g_portals[PortalSide.editor].scrn): ", ix, ' ', iy);
				
				foreach(i, guy; g_guys) {
					with(guy) {
						writeln("Guy ", i);
						
						fread(&fx, 1, fx.sizeof, pfile); // 2 ST postion in screen
						fread(&fy, 1, fy.sizeof, pfile);
						resetPos = Vec(fx, fy);
						writeln("ST position screen (resetPos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 3 ST which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.resetPosScrn = Vector!int(ix, iy);
						writeln("ST which screen: (portal.resetPosScrn)", ix, ' ', iy);
						
						fread(&fx, 1, fx.sizeof, pfile); // 4 place on the screen
						fread(&fy, 1, fy.sizeof, pfile);
						pos = Vec(fx, fy);
						writeln("guy place on screen (pos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 5 which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.scrn = Vector!int(ix, iy);
						writeln("Which screen: (portal.scrn)", ix, ' ', iy);
						
						// 6
						int sdiamonds = dashBoard.diamonds;
						fread(&sdiamonds, 1, sdiamonds.sizeof, pfile);
						dashBoard.diamonds = sdiamonds;
						writeln("Diamonds (diamonds): ", dashBoard.diamonds);

						// 6.1
						int stotalDiamonds = dashBoard.totalDiamonds;
						fread(&stotalDiamonds, 1, stotalDiamonds.sizeof, pfile);
						dashBoard.totalDiamonds = stotalDiamonds;
						writeln("Total Diamonds: ", dashBoard.totalDiamonds);

						// 6.5
						int score;
						fread(&score, 1, score.sizeof, pfile);
						dashBoard.score = score;
						writeln("Score: ", score);
					} // with
				} // guy

				fread(&ix, 1, ix.sizeof, pfile); // how many screens width
				fread(&iy, 1, iy.sizeof, pfile); // how many screens height
				g_scrnDim = Vector!int(ix, iy);
				g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
				foreach(sy; 0 .. g_scrnDim.y)
					foreach(sx; 0 .. g_scrnDim.x) {
						g_screens[sy][sx].tiles.length = 10;
						foreach(y; 0 .. 10)
							g_screens[sy][sx].tiles[y].length = 10;
					}
				writeln("g_scrnDim: ", g_scrnDim);
				
				string[] computerData;
				int cpos = 1;
				version(computerDataChange) {
					computerData = readText("computerdata.txt").split('\n');
				}
				foreach(sy; 0 .. g_scrnDim.y)
					foreach(sx; 0 .. g_scrnDim.x) {
						int characters;
						fread(&characters, 1, characters.sizeof, pfile);
						char[] text;
						text.length = characters;
						fread(text.ptr, characters, char.sizeof, pfile);
						version(computersOutPut) {
							writeln("[", sx, "][", sy, "]\n", text);
						}
						g_screens[sy][sx].verseRef = text.idup;
						version(computerDataChange) {
							g_screens[sy][sx].verseRef = computerData[cpos];
							assert(cpos + 2 >= computerData.length, "Run out of data!");
							cpos += 2;
						}
						foreach(cy; 0 .. 10)
							foreach(cx; 0 .. 10) {
								fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
								fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
								fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
							}
					}
				//#jeep read
				fread(&ix, 1, ix.sizeof, pfile);
				//writeln("read number of jeeps: ", ix);
				int i;
				foreach(jeep; 0 .. ix) {
					//writeln("jeep read ", jeep);
					fread(&fx, 1, fx.sizeof, pfile);
					fread(&fy, 1, fy.sizeof, pfile);
					
					fread(&ix, 1, ix.sizeof, pfile);
					fread(&iy, 1, iy.sizeof, pfile);
					g_jeeps ~= new Jeep(Vec(fx, fy), Vector!int(ix, iy)); //, g_portals[0], g_portals[1]);
					
					with(g_jeeps[$-1]) {
						fread(&ix, 1, ix.sizeof, pfile);
						facingNext = cast(Facing)ix;
						
						fread(&iy, 1, iy.sizeof, pfile);
						facing = cast(Facing)iy;
						
						fread(&ix, 1, ix.sizeof, pfile);
						action = cast(Action)ix;
					}
				}
			break;
		}
		
		//resetGame;
		
		g_inputJex.addToHistory("Building loaded!");
		
		return true;
	}
	
	bool saveBuilding() { //(in string backFileName = "") {
		//auto oldFileName = fileName;
		//if (backFileName != "")
		//	setFileName(backFileName);
		//scope(exit)
		//	setFileName(oldFileName);
		g_inputJex.addToHistory(text(`Saving "`, _fileName.trim, `" Building...`));
		import std.string;
		FILE* pfile = stdc.fopen(toStringz(_fileName), "wb");
		int ver = 10; // version
		fwrite(&ver, 1, ver.sizeof, pfile); // write version
		writeln("version: ", ver);

		float fx, fy;
		int ix, iy;

		ix = g_portals[PortalSide.editor].scrn.x; // Editor screen 1
		iy = g_portals[PortalSide.editor].scrn.y;
		fwrite(&ix, 1, ix.sizeof, pfile); 
		fwrite(&iy, 1, iy.sizeof, pfile);
		writeln("Portal screen editor: ", ix, ' ', iy);

		foreach(i, guy; g_guys)
			with(guy) {
				writeln("Guy ", i);
				
				fx = resetPos.x; // 2 ST postion in screen
				fy = resetPos.y;
				fwrite(&fx, 1, fx.sizeof, pfile);
				fwrite(&fy, 1, fy.sizeof, pfile);
				writeln("ST position screen: (resetPos)", fx, ' ', fy);

				ix = portal.resetPosScrn.x; // ST screen 3
				iy = portal.resetPosScrn.y; // 
				fwrite(&ix, 1, ix.sizeof, pfile);
				fwrite(&iy, 1, iy.sizeof, pfile);
				writeln("ST screen [portal.resetPosScrn]: ", ix, ' ', iy);

				fx = pos.x;
				fy = pos.y;
				fwrite(&fx, 1, fx.sizeof, pfile); // 4 save current guy location in screen
				fwrite(&fy, 1, fy.sizeof, pfile);
				writeln("Guy location in screen (pos): ", pos.x, ' ', pos.y);

				ix = portal.scrn.x;
				iy = portal.scrn.y;
				fwrite(&ix, 1, ix.sizeof, pfile); // 5 save current screen for guy
				fwrite(&iy, 1, iy.sizeof, pfile);
				writeln("Save current screen for spawning (portal.scrn): ", ix, ' ', iy);

				int sdiamonds = dashBoard.diamonds; // s save 6
				fwrite(&sdiamonds, 1, sdiamonds.sizeof, pfile);
				writeln("guy diamonds [diamonds]: ", sdiamonds);

				// 6.1
				int stotalDiamonds = dashBoard.totalDiamonds;
				fwrite(&stotalDiamonds, 1, stotalDiamonds.sizeof, pfile);
				writeln("Total Diamonds: ", dashBoard.totalDiamonds);

				int score = dashBoard.score;
				fwrite(&score, 1, score.sizeof, pfile);
				writeln("Score: ", score);
			}

		/+
		int total = g_score.totalDiamonds; // 7
		fwrite(&total, 1, total.sizeof, pfile);
		writeln("total diamonds: ", total);
		+/

		writeln("g_scrnDim: ", g_scrnDim);
		ix = g_scrnDim.x;
		iy = g_scrnDim.y;
		fwrite(&ix, 1, ix.sizeof, pfile); // 8 how many screens width
		fwrite(&iy, 1, iy.sizeof, pfile); // how many screens height
		foreach(sy; 0 .. iy)
			foreach(sx; 0 .. ix) {
				auto verseRef = g_screens[sy][sx].verseRef.dup;
				int len = cast(int)verseRef.length;
				fwrite(&len, 1, len.sizeof, pfile);
				fwrite(verseRef.ptr, len, char.sizeof, pfile);
				foreach(cy; 0 .. 10)
					foreach(cx; 0 .. 10) {
						fwrite(&g_screens[sy][sx].tiles[cy][cx].tileNameBack,  1,  g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof,  pfile);//back TileName
						fwrite(&g_screens[sy][sx].tiles[cy][cx].tileName,      1,  g_screens[sy][sx].tiles[cy][cx].tileName.sizeof,      pfile);// mid TileName
						fwrite(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1,  g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);//front TileName
					}
			}
		ix = cast(int)g_jeeps.length;
		fwrite(&ix, 1, ix.sizeof, pfile);
		writeln("number of jeeps (save) ", ix);
		int i = 0;
		foreach(jeep; g_jeeps) with(jeep) {
			fx = pos.x;
			fy = pos.y;
			fwrite(&fx, 1, fx.sizeof, pfile);
			fwrite(&fy, 1, fy.sizeof, pfile);
			
			ix = scrn.x;
			iy = scrn.y;
			fwrite(&ix, 1, ix.sizeof, pfile);
			fwrite(&iy, 1, iy.sizeof, pfile);
			
			ix = cast(Facing)facing;
			fwrite(&ix, 1, ix.sizeof, pfile);
			iy = cast(Facing)facingNext;
			fwrite(&iy, 1, iy.sizeof, pfile);
			
			ix = cast(Facing)action;
			fwrite(&ix, 1, ix.sizeof, pfile);
		}

		fclose(pfile);

//#back up files TO DO - see JMiscLib.base
		backUp(_fileName);

		return true;
	}
	
	bool createMap(int width, int height) {		
		g_scrnDim = Vector!int(width, height);
		g_screens = new Screen[][](height, width);
		
		g_screens.length = g_scrnDim.y;
		foreach(sy; 0 .. height) {
			foreach(sx; 0 .. width) {
				g_screens[sy][sx].tiles.length = 10;
				foreach(y; 0 .. 10)
					g_screens[sy][sx].tiles[y].length = 10;
			}
		}

		foreach(sy; 0 .. height)
			foreach(sx; 0 .. width)
				foreach(y; 0 .. 10)
					foreach(x; 0 .. 10) {
						if (sy == 0)
							g_screens[sy][sx].tiles[y][x].tileNameBack = TileName.gap;
						else
							g_screens[sy][sx].tiles[y][x].tileNameBack = TileName.darkBrick;
						g_screens[sy][sx].tiles[y][x].tileName = TileName.gap;
						g_screens[sy][sx].tiles[y][x].tileNameFront = TileName.gap;
					}
		g_popLine.set(text("Map created: ", width, " by ", height));

		return true;
	}

	//#unittest - 'dub --build=unittest'
	unittest {
		g_screens = new Screen[][](2, 3);

		g_screens[1][2].tiles.length = 1;
		g_screens[1][2].tiles[0].length = 2;

		assert(g_screens[1][2].tiles[0][1].tileName == TileName.brick);
	}

	void oldVersions(FILE* pfile, int ver) {
		float fx, fy;
		int ix, iy;
		writeln("Old version ", ver);
		switch(ver) {
		default:
			assert(0, "Error, version not accounted for!");
		case 2:
			fread(&g_scrnDim.x, 1, g_scrnDim.x.sizeof, pfile); // how many screens width
			fread(&g_scrnDim.y, 1, g_scrnDim.y.sizeof, pfile); // how many screens height
			writeln("g_scrnDim", g_scrnDim);
			g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
			foreach(sy; 0 .. g_scrnDim.y)
			foreach(sx; 0 .. g_scrnDim.x) {
				g_screens[sy][sx].tiles.length = 10;
				foreach(y; 0 .. 10)
					g_screens[sy][sx].tiles[y].length = 10;
			}
			
			foreach(sy; 0 .. g_scrnDim.y)
				foreach(sx; 0 .. g_scrnDim.x)
					foreach(cy; 0 .. 10)
					foreach(cx; 0 .. 10) {
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
						//g_screens[sy][sx].tiles[cy][cx].sp = null;
					}
			break;
		case 3:
			float gx, gy;
			int scx, scy;
			foreach(ref guy; g_guys) {
				fread(&gx, 1, gx.sizeof, pfile); // place on the screen
				fread(&gy, 1, gy.sizeof, pfile);
				//					guy.resetPos;
				
				fread(&scx, 1, scx.sizeof, pfile); // which screen
				fread(&scy, 1, scy.sizeof, pfile);
				
				guy.pos = Vec(gx, gy);
				guy.portal.scrn = Vector!int(scx, scy);
			}
			
			fread(&g_scrnDim.x, 1, g_scrnDim.x.sizeof, pfile); // how many screens width
			fread(&g_scrnDim.y, 1, g_scrnDim.y.sizeof, pfile); // how many screens height
			writeln("g_scrnDim", g_scrnDim);
			g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
			foreach(sy; 0 .. g_scrnDim.y)
			foreach(sx; 0 .. g_scrnDim.x) {
				g_screens[sy][sx].tiles.length = 10;
				foreach(y; 0 .. 10)
					g_screens[sy][sx].tiles[y].length = 10;
			}
			
			foreach(sy; 0 .. g_scrnDim.y)
				foreach(sx; 0 .. g_scrnDim.x)
					foreach(cy; 0 .. 10)
					foreach(cx; 0 .. 10) {
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
						//g_screens[sy][sx].tiles[cy][cx].sp = null;
					}
		break;
		case 4:
			float gx, gy;
			int scx, scy;
			foreach(ref guy; g_guys) {
				fread(&gx, 1, gx.sizeof, pfile); // place on the screen
				fread(&gy, 1, gy.sizeof, pfile);
				//					guy.resetPos;
				
				fread(&scx, 1, scx.sizeof, pfile); // which screen
				fread(&scy, 1, scy.sizeof, pfile);
				
				guy.pos = Vec(gx, gy);
				guy.portal.scrn = Vector!int(scx, scy);
			}
			
			int dummy;
			fread(&dummy, 1, dummy.sizeof, pfile);
			/+
			int total = g_score.totalDiamonds;
			fread(&total, 1, total.sizeof, pfile);
			g_score.totalDiamonds = total;
			writeln("total Diamonds:", g_score.totalDiamonds);
			+/
			
			fread(&g_scrnDim.x, 1, g_scrnDim.x.sizeof, pfile); // how many screens width
			fread(&g_scrnDim.y, 1, g_scrnDim.y.sizeof, pfile); // how many screens height
			writeln("g_scrnDim", g_scrnDim);
			g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
			foreach(sy; 0 .. g_scrnDim.y)
			foreach(sx; 0 .. g_scrnDim.x) {
				g_screens[sy][sx].tiles.length = 10;
				foreach(y; 0 .. 10)
					g_screens[sy][sx].tiles[y].length = 10;
			}
			
			foreach(sy; 0 .. g_scrnDim.y)
				foreach(sx; 0 .. g_scrnDim.x)
					foreach(cy; 0 .. 10)
					foreach(cx; 0 .. 10) {
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
						//g_screens[sy][sx].tiles[cy][cx].sp = null;
					}
		break;
		case 5:
			int edx, edy;
			fread(&edx, 1, edx.sizeof, pfile); 
			fread(&edy, 1, edy.sizeof, pfile); 
			g_portals[PortalSide.editor].scrn = Vector!int(edx, edy);
			
			float gx, gy;
			int scx, scy;
			foreach(ref guy; g_guys) {
				fread(&gx, 1, gx.sizeof, pfile); // place on the screen
				fread(&gy, 1, gy.sizeof, pfile);
				
				fread(&scx, 1, scx.sizeof, pfile); // which screen
				fread(&scy, 1, scy.sizeof, pfile);
				
				guy.resetPos = Vec(gx, gy);
				guy.portal.resetPosScrn = Vector!int(scx, scy);
			}
			resetGame;
			
			int dummy;
			fread(&dummy, 1, dummy.sizeof, pfile);
			/+
			int total = g_score.totalDiamonds;
			fread(&total, 1, total.sizeof, pfile);
			g_score.totalDiamonds = total;
			writeln("total Diamonds: ", g_score.totalDiamonds);
			+/
			
			fread(&g_scrnDim.x, 1, g_scrnDim.x.sizeof, pfile); // how many screens width
			fread(&g_scrnDim.y, 1, g_scrnDim.y.sizeof, pfile); // how many screens height
			writeln("g_scrnDim", g_scrnDim);
			g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
			foreach(sy; 0 .. g_scrnDim.y)
			foreach(sx; 0 .. g_scrnDim.x) {
				g_screens[sy][sx].tiles.length = 10;
				foreach(y; 0 .. 10)
					g_screens[sy][sx].tiles[y].length = 10;
			}
			
			foreach(sy; 0 .. g_scrnDim.y)
				foreach(sx; 0 .. g_scrnDim.x)
					foreach(cy; 0 .. 10)
					foreach(cx; 0 .. 10) {
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
						//g_screens[sy][sx].tiles[cy][cx].sp = null;
					}
			break;
		case 6:
			fread(&ix, 1, ix.sizeof, pfile); // 1 which screen editor
			fread(&iy, 1, iy.sizeof, pfile); 
			g_portals[PortalSide.editor].scrn = Vector!int(ix, iy);
			writeln("Portal screen editor (g_portals[PortalSide.editor].scrn): ", ix, ' ', iy);
			
			foreach(i, guy; g_guys) {
				with(guy) {
					writeln("Guy ", i);
					
					fread(&fx, 1, fx.sizeof, pfile); // 2 ST postion in screen
					fread(&fy, 1, fy.sizeof, pfile);
					resetPos = Vec(fx, fy);
					writeln("ST position screen (resetPos): ", fx, ' ', fy);
					
					fread(&ix, 1, ix.sizeof, pfile); // 3 ST which screen
					fread(&iy, 1, iy.sizeof, pfile);
					portal.resetPosScrn = Vector!int(ix, iy);
					writeln("ST which screen: (portal.resetPosScrn)", ix, ' ', iy);
					
					fread(&fx, 1, fx.sizeof, pfile); // 4 place on the screen
					fread(&fy, 1, fy.sizeof, pfile);
					pos = Vec(fx, fy);
					writeln("guy place on screen (pos): ", fx, ' ', fy);
					
					fread(&ix, 1, ix.sizeof, pfile); // 5 which screen
					fread(&iy, 1, iy.sizeof, pfile);
					portal.scrn = Vector!int(ix, iy);
					writeln("Which screen: (portal.scrn)", ix, ' ', iy);
					
					// 6
					int sdiamonds = dashBoard.diamonds;
					fread(&sdiamonds, 1, sdiamonds.sizeof, pfile);
					dashBoard.diamonds = sdiamonds;
					writeln("Diamonds (diamonds): ", dashBoard.diamonds);
				} // with
			} // guy
			//resetGame;
			
			// 7
			int dummy;
			fread(&dummy, 1, dummy.sizeof, pfile);
			/+
			int total = g_score.totalDiamonds;
			fread(&total, 1, total.sizeof, pfile);
			g_score.totalDiamonds = total;
			writeln("total Diamonds: ", g_score.totalDiamonds);
			+/
			
			fread(&ix, 1, ix.sizeof, pfile); // how many screens width
			fread(&iy, 1, iy.sizeof, pfile); // how many screens height
			g_scrnDim = Vector!int(ix, iy);
			g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
			foreach(sy; 0 .. g_scrnDim.y)
			foreach(sx; 0 .. g_scrnDim.x) {
				g_screens[sy][sx].tiles.length = 10;
				foreach(y; 0 .. 10)
					g_screens[sy][sx].tiles[y].length = 10;
			}
			writeln("g_scrnDim: ", g_scrnDim);
			
			foreach(sy; 0 .. g_scrnDim.y)
				foreach(sx; 0 .. g_scrnDim.x)
					foreach(cy; 0 .. 10)
					foreach(cx; 0 .. 10) {
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
						fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
					}
		break;
			case 7:
				fread(&ix, 1, ix.sizeof, pfile); // 1 which screen editor
				fread(&iy, 1, iy.sizeof, pfile); 
				g_portals[PortalSide.editor].scrn = Vector!int(ix, iy);
				writeln("Portal screen editor (g_portals[PortalSide.editor].scrn): ", ix, ' ', iy);
				
				foreach(i, guy; g_guys) {
					with(guy) {
						writeln("Guy ", i);
						
						fread(&fx, 1, fx.sizeof, pfile); // 2 ST postion in screen
						fread(&fy, 1, fy.sizeof, pfile);
						resetPos = Vec(fx, fy);
						writeln("ST position screen (resetPos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 3 ST which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.resetPosScrn = Vector!int(ix, iy);
						writeln("ST which screen: (portal.resetPosScrn)", ix, ' ', iy);
						
						fread(&fx, 1, fx.sizeof, pfile); // 4 place on the screen
						fread(&fy, 1, fy.sizeof, pfile);
						pos = Vec(fx, fy);
						writeln("guy place on screen (pos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 5 which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.scrn = Vector!int(ix, iy);
						writeln("Which screen: (portal.scrn)", ix, ' ', iy);
						
						// 6
						int sdiamonds = dashBoard.diamonds;
						fread(&sdiamonds, 1, sdiamonds.sizeof, pfile);
						dashBoard.diamonds = sdiamonds;
						writeln("Diamonds (diamonds): ", dashBoard.diamonds);
					} // with
				} // guy
				//resetGame;
				
				// 7
				int dummy;
				fread(&dummy, 1, dummy.sizeof, pfile);
				/+
				int total = g_score.totalDiamonds;
				fread(&total, 1, total.sizeof, pfile);
				g_score.totalDiamonds = total;
				writeln("total Diamonds: ", g_score.totalDiamonds);
				+/
				
				fread(&ix, 1, ix.sizeof, pfile); // how many screens width
				fread(&iy, 1, iy.sizeof, pfile); // how many screens height
				g_scrnDim = Vector!int(ix, iy);
				g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
				foreach(sy; 0 .. g_scrnDim.y)
				foreach(sx; 0 .. g_scrnDim.x) {
					g_screens[sy][sx].tiles.length = 10;
					foreach(y; 0 .. 10)
						g_screens[sy][sx].tiles[y].length = 10;
				}
				writeln("g_scrnDim: ", g_scrnDim);
				
				foreach(sy; 0 .. g_scrnDim.y)
					foreach(sx; 0 .. g_scrnDim.x)
						foreach(cy; 0 .. 10)
						foreach(cx; 0 .. 10) {
							fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
							fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
							fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
						}
				//#jeep read
				fread(&ix, 1, ix.sizeof, pfile);
				//writeln("read number of jeeps: ", ix);
				int i;
				foreach(jeep; 0 .. ix) {
					//writeln("jeep read ", jeep);
					fread(&fx, 1, fx.sizeof, pfile);
					fread(&fy, 1, fy.sizeof, pfile);
					
					fread(&ix, 1, ix.sizeof, pfile);
					fread(&iy, 1, iy.sizeof, pfile);
					g_jeeps ~= new Jeep(Vec(fx, fy), Vector!int(ix, iy)); //, g_portals[0], g_portals[1]);
					
					with(g_jeeps[$-1]) {
						fread(&ix, 1, ix.sizeof, pfile);
						facingNext = cast(Facing)ix;
						
						fread(&iy, 1, iy.sizeof, pfile);
						facing = cast(Facing)iy;
						
						fread(&ix, 1, ix.sizeof, pfile);
						action = cast(Action)ix;
					}
				}
				break;
			case 8:
				fread(&ix, 1, ix.sizeof, pfile); // 1 which screen editor
				fread(&iy, 1, iy.sizeof, pfile);
				g_portals[PortalSide.editor].scrn = Vector!int(ix, iy);
				writeln("Portal screen editor (g_portals[PortalSide.editor].scrn): ", ix, ' ', iy);
				
				foreach(i, guy; g_guys) {
					with(guy) {
						writeln("Guy ", i);
						
						fread(&fx, 1, fx.sizeof, pfile); // 2 ST postion in screen
						fread(&fy, 1, fy.sizeof, pfile);
						resetPos = Vec(fx, fy);
						writeln("ST position screen (resetPos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 3 ST which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.resetPosScrn = Vector!int(ix, iy);
						writeln("ST which screen: (portal.resetPosScrn)", ix, ' ', iy);
						
						fread(&fx, 1, fx.sizeof, pfile); // 4 place on the screen
						fread(&fy, 1, fy.sizeof, pfile);
						pos = Vec(fx, fy);
						writeln("guy place on screen (pos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 5 which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.scrn = Vector!int(ix, iy);
						writeln("Which screen: (portal.scrn)", ix, ' ', iy);
						
						// 6
						int sdiamonds = dashBoard.diamonds;
						fread(&sdiamonds, 1, sdiamonds.sizeof, pfile);
						dashBoard.diamonds = sdiamonds;
						writeln("Diamonds (diamonds): ", dashBoard.diamonds);

						// 6.1
						int stotalDiamonds = dashBoard.totalDiamonds;
						fread(&stotalDiamonds, 1, stotalDiamonds.sizeof, pfile);
						dashBoard.totalDiamonds = stotalDiamonds;
						writeln("Total Diamonds: ", dashBoard.totalDiamonds);
					} // with
				} // guy
				//resetGame;
				
				// 7
				/+
				int total = g_score.totalDiamonds;
				fread(&total, 1, total.sizeof, pfile);
				g_score.totalDiamonds = total;
				writeln("total Diamonds: ", g_score.totalDiamonds);
				+/
				
				fread(&ix, 1, ix.sizeof, pfile); // how many screens width
				fread(&iy, 1, iy.sizeof, pfile); // how many screens height
				g_scrnDim = Vector!int(ix, iy);
				g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
				foreach(sy; 0 .. g_scrnDim.y)
					foreach(sx; 0 .. g_scrnDim.x) {
						g_screens[sy][sx].tiles.length = 10;
						foreach(y; 0 .. 10)
							g_screens[sy][sx].tiles[y].length = 10;
					}
				writeln("g_scrnDim: ", g_scrnDim);
				
				foreach(sy; 0 .. g_scrnDim.y)
					foreach(sx; 0 .. g_scrnDim.x)
						foreach(cy; 0 .. 10)
						foreach(cx; 0 .. 10) {
							fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
							fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
							fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
						}
				//#jeep read
				fread(&ix, 1, ix.sizeof, pfile);
				//writeln("read number of jeeps: ", ix);
				int i;
				foreach(jeep; 0 .. ix) {
					//writeln("jeep read ", jeep);
					fread(&fx, 1, fx.sizeof, pfile);
					fread(&fy, 1, fy.sizeof, pfile);
					
					fread(&ix, 1, ix.sizeof, pfile);
					fread(&iy, 1, iy.sizeof, pfile);
					g_jeeps ~= new Jeep(Vec(fx, fy), Vector!int(ix, iy)); //, g_portals[0], g_portals[1]);
					
					with(g_jeeps[$-1]) {
						fread(&ix, 1, ix.sizeof, pfile);
						facingNext = cast(Facing)ix;
						
						fread(&iy, 1, iy.sizeof, pfile);
						facing = cast(Facing)iy;
						
						fread(&ix, 1, ix.sizeof, pfile);
						action = cast(Action)ix;
					}
				}
				break;
			case 9:
				fread(&ix, 1, ix.sizeof, pfile); // 1 which screen editor
				fread(&iy, 1, iy.sizeof, pfile);
				g_portals[PortalSide.editor].scrn = Vector!int(ix, iy);
				writeln("Portal screen editor (g_portals[PortalSide.editor].scrn): ", ix, ' ', iy);
				
				foreach(i, guy; g_guys) {
					with(guy) {
						writeln("Guy ", i);
						
						fread(&fx, 1, fx.sizeof, pfile); // 2 ST postion in screen
						fread(&fy, 1, fy.sizeof, pfile);
						resetPos = Vec(fx, fy);
						writeln("ST position screen (resetPos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 3 ST which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.resetPosScrn = Vector!int(ix, iy);
						writeln("ST which screen: (portal.resetPosScrn)", ix, ' ', iy);
						
						fread(&fx, 1, fx.sizeof, pfile); // 4 place on the screen
						fread(&fy, 1, fy.sizeof, pfile);
						pos = Vec(fx, fy);
						writeln("guy place on screen (pos): ", fx, ' ', fy);
						
						fread(&ix, 1, ix.sizeof, pfile); // 5 which screen
						fread(&iy, 1, iy.sizeof, pfile);
						portal.scrn = Vector!int(ix, iy);
						writeln("Which screen: (portal.scrn)", ix, ' ', iy);
						
						// 6
						int sdiamonds = dashBoard.diamonds;
						fread(&sdiamonds, 1, sdiamonds.sizeof, pfile);
						dashBoard.diamonds = sdiamonds;
						writeln("Diamonds (diamonds): ", dashBoard.diamonds);

						// 6.1
						int stotalDiamonds = dashBoard.totalDiamonds;
						fread(&stotalDiamonds, 1, stotalDiamonds.sizeof, pfile);
						dashBoard.totalDiamonds = stotalDiamonds;
						writeln("Total Diamonds: ", dashBoard.totalDiamonds);
					} // with
				} // guy
				//resetGame;
				
				// 7
				/+
				int total = g_score.totalDiamonds;
				fread(&total, 1, total.sizeof, pfile);
				g_score.totalDiamonds = total;
				writeln("total Diamonds: ", g_score.totalDiamonds);
				+/
				
				fread(&ix, 1, ix.sizeof, pfile); // how many screens width
				fread(&iy, 1, iy.sizeof, pfile); // how many screens height
				g_scrnDim = Vector!int(ix, iy);
				g_screens = new Screen[][](g_scrnDim.y, g_scrnDim.x);
				foreach(sy; 0 .. g_scrnDim.y)
					foreach(sx; 0 .. g_scrnDim.x) {
						g_screens[sy][sx].tiles.length = 10;
						foreach(y; 0 .. 10)
							g_screens[sy][sx].tiles[y].length = 10;
					}
				writeln("g_scrnDim: ", g_scrnDim);
				
				foreach(sy; 0 .. g_scrnDim.y)
					foreach(sx; 0 .. g_scrnDim.x) {
						int characters;
						fread(&characters, 1, characters.sizeof, pfile);
						char[] text;
						text.length = characters;
						fread(text.ptr, characters, char.sizeof, pfile);
						g_screens[sy][sx].verseRef = text.idup;
						foreach(cy; 0 .. 10)
						foreach(cx; 0 .. 10) {
							fread(&g_screens[sy][sx].tiles[cy][cx].tileNameBack, 1, g_screens[sy][sx].tiles[cy][cx].tileNameBack.sizeof, pfile); // back TileName
							fread(&g_screens[sy][sx].tiles[cy][cx].tileName, 1, g_screens[sy][sx].tiles[cy][cx].tileName.sizeof, pfile); // mid TileName
							fread(&g_screens[sy][sx].tiles[cy][cx].tileNameFront, 1, g_screens[sy][sx].tiles[cy][cx].tileNameFront.sizeof, pfile);// front TileName
						}
					}
				//#jeep read
				fread(&ix, 1, ix.sizeof, pfile);
				//writeln("read number of jeeps: ", ix);
				int i;
				foreach(jeep; 0 .. ix) {
					//writeln("jeep read ", jeep);
					fread(&fx, 1, fx.sizeof, pfile);
					fread(&fy, 1, fy.sizeof, pfile);
					
					fread(&ix, 1, ix.sizeof, pfile);
					fread(&iy, 1, iy.sizeof, pfile);
					g_jeeps ~= new Jeep(Vec(fx, fy), Vector!int(ix, iy)); //, g_portals[0], g_portals[1]);
					
					with(g_jeeps[$-1]) {
						fread(&ix, 1, ix.sizeof, pfile);
						facingNext = cast(Facing)ix;
						
						fread(&iy, 1, iy.sizeof, pfile);
						facing = cast(Facing)iy;
						
						fread(&ix, 1, ix.sizeof, pfile);
						action = cast(Action)ix;
					}
				}
				break;
		} // ver switch
	} // old versions
}

//#see help.txt
//#here
//#work here
//#get rid of the jeeps!
//#why do I need to put format in instead of text (the ': ' gets removed with text)
//#no I didn't do this my self
//#to hide or not to hide
//#input
//#load building here!
//#other stuff

// To do's:
/+
To fix:
Jeep going backward after loading the project


+/
module main;

import base;

string[] discList;

void getDiscList(in bool show = false) {
	import std.range;
	import std.file;
	import std.conv;
	import std.algorithm;
	import std.string;

	if (show)
		g_inputJex.addToHistory("List of building files");
	discList.length = 0;
	foreach(i, string name; dirEntries(".", "*.{bin}", SpanMode.shallow).
			array.sort!"a.toLower < b.toLower".enumerate(1)) {
		discList ~= name;
		if (show)
			g_inputJex.addToHistory(text(i, " - ", name.trim));
	}
}

int main(string[] args) {
	scope(exit)
		"\n# #\n# #\n # \n# #\n# #\n".writeln;

	Setup doSetup;
	doSetup.setup();
    scope(exit)
        close;

	getDiscList;

	//auto blackPlastic = new RectangleShape;
	//blackPlastic.size = Vec(320, 320);
	auto blackPlastic = JRectangle(SDL_Rect(320,320,0,0), BoxStyle.solid, SDL_Color(0,0,0));

	Menus menus;
	menus.setup;
	MenuSelect mret = MenuSelect.doLoop;

	bool showingBible = false;

	updateProjectList("");

	bool done;
    while(! done) {
		FPS.start();
		while(gFEvent.update) {
			if(gFEvent.isQuit) 
				done = true;
		}

		SDL_PumpEvents();		

		if (mret == MenuSelect.doLoop) {
			mret = menus.process;
			final switch(mret) {
				case MenuSelect.start:
					g_mode = Mode.play;
					break;
				case MenuSelect.edit:
					g_mode = Mode.edit;
					break;
				case MenuSelect.doLoop:
					continue;
				case MenuSelect.quit:
					done = true;
					break;
			}
		}

		if (g_keys[SDL_SCANCODE_LCTRL].keyPressed ||
			g_keys[SDL_SCANCODE_RCTRL].keyPressed) {
			if (g_keys[SDL_SCANCODE_Q].keyTrigger)
				done = true;
		
			if (g_keys[SDL_SCANCODE_A].keyTrigger) {
				mret = MenuSelect.doLoop;
				continue;
			}

			if (g_keys[SDL_SCANCODE_E].keyTrigger) {
				if (g_mode == Mode.edit) {
					g_missionStage = MissionStage.playing;
					g_mode = Mode.play;
					foreach(portal; 0 .. 2)
						g_portals[portal].grace = g_graceStartTime;
					g_timer.doStart;
				}
				else {					
					g_mode = Mode.edit;
				}

				//g_inputJex.addToHistory(g_mode.to!dstring);
				//writeln(g_mode);
			}
		}

		if (g_keys[SDL_SCANCODE_ESCAPE].keyTrigger)
			g_doGuiFile = false;
			
		if (! g_jexTerminal && ! g_doGuiFile) {
			if (g_mode != Mode.play && g_keys[SDL_SCANCODE_T].keyTrigger) {
				g_jexTerminal = true;
			}

			if (g_keys[SDL_SCANCODE_F].keyTrigger) {
				//g_window.setVerticalSyncEnabled(true);
				//writeln("Sync on");
			} else {
				//g_window.setVerticalSyncEnabled(false);
				//writeln("Sync off");
			}
		}
		
		g_mouse.process;

		import std.algorithm: map, filter, each;
		import std.range;

		if (g_mode == Mode.play) {
			if (g_missionStage == MissionStage.briefing) {
				if (g_keys[SDL_SCANCODE_SPACE].keyTrigger) {
					g_timer.doStart;
					g_missionStage = MissionStage.playing;
				}
			}
			if (g_missionStage == MissionStage.playing) {
				g_timer.process;

				foreach(jeep; g_jeeps)
					if (inScreen(jeep.scrn))
						jeep.process;

				//g_jeeps = g_jeeps.map!((a) { if (inScreen(a.scrn)) a.process; return a; }).array;
				//void ifProcess(ref ) {
				//	if (inScreen(a.scrn)) a.process; return a; }
				//}
				//g_jeeps = g_jeeps.each!(a => ifProcess(a)).array;
			}
		}

		g_bullits = g_bullits.map!((a) { a.process; return a; }).array;
		import std.conv: asOriginalType;
		g_bullits = g_bullits.filter!(a => a.bullitState.asOriginalType != BullitState.terminated).array;

		//foreach(portal; g_portals[0 .. 2])
		//	portal.process;
		g_portals[0 .. 2] = g_portals[0 .. 2].map!((a) { a.process; return a; }).array;
		//g_portals[0 .. 2] = g_portals[0 .. 2].each!(a => a.process).array; //#each - not work
		gGraph.clear(); // Clear screen

		void doComputerBlowDraw() {
			foreach(computer; g_computers)
				if (inScreen(computer.scrn)) {
					auto screens = getScreens(computer.scrn);
					if (screens[PortalSide.left]) {
						g_display.setComputer(computer);
						g_display.display(DisplayType.computerBlow);
					}
					if (screens[PortalSide.right]) {
						g_computerBlowUp[computer._blowUpFrame].position = g_computerBlowUp[computer._blowUpFrame].position + Vec(320, 0);
						g_display.setComputer(computer);
						g_display.display(DisplayType.computerBlow);
						g_computerBlowUp[computer._blowUpFrame].position = g_computerBlowUp[computer._blowUpFrame].position - Vec(320, 0);
					}
				}
		}

		void doJeepDraw() {
			foreach(jeep; g_jeeps) {
				// screens
				if (inScreen(jeep.scrn)) {
					auto screens = getScreens(jeep.scrn);
					if (screens[PortalSide.left] || (g_mode == Mode.edit && screens[PortalSide.editor])) {
						g_display.setJeep(jeep);
						g_display.display(DisplayType.jeepDraw);

						g_display.setJeepBullit(jeep.jeepBullit);
						g_display.display(DisplayType.jeepBullitDraw);
					}
					if (screens[PortalSide.right] && g_mode != Mode.edit) {
						jeep.pos = jeep.pos + Vec(320, 0);
						if (jeep.jeepBullit !is null)
							jeep.jeepBullit.pos = jeep.jeepBullit.pos + Vec(320, 0);
						
						g_display.setJeep(jeep);
						g_display.display(DisplayType.jeepDraw);

						g_display.setJeepBullit(jeep.jeepBullit);
						g_display.display(DisplayType.jeepBullitDraw);

						jeep.pos = jeep.pos + Vec(-320, 0);

						if (jeep.jeepBullit !is null)
							jeep.jeepBullit.pos = jeep.jeepBullit.pos + Vec(-320, 0);
					}
				}
			}
		}

		void doBullitsDraw() {
			foreach(bullit; g_bullits)
				if (inScreen(bullit.scrn)) {
					auto screens = getScreens(bullit.scrn);
					if (screens[PortalSide.left] || (g_mode == Mode.edit && screens[PortalSide.editor])) {
						g_display.setBullit(bullit);
						g_display.display(DisplayType.bullitsDraw);
					}
					if (screens[PortalSide.right] && g_mode != Mode.edit) {
						bullit.pos = bullit.pos + Vec(320, 0);
						g_display.setBullit(bullit);
						g_display.display(DisplayType.bullitsDraw);
						bullit.pos = bullit.pos + Vec(-320, 0);
					}
				}
		}

		// JDisplay
		break1: final switch(g_mode) {
			case Mode.play:
				//Draw back layer
				foreach(ref portal; g_portals[0 .. 2]) {
					g_display.setPortal(portal);
					g_display.display(DisplayType.portalNoBorderLayerBackDraw);
				}

				//Draw normal layer
				foreach(ref portal; g_portals[0 .. 2]) {
					g_display.setPortal(portal);
					g_display.display(DisplayType.portalNoBorderLayerNormalDraw);
				}

				doBullitsDraw;

				foreach(ref guy; g_guys) {
					with(guy) {
						if (! g_jexTerminal && ! g_doGuiFile)
							process;
						g_display.setGuy(guy);
						g_display.display(DisplayType.guyDraw);
					}
				}

				doComputerBlowDraw;
				doJeepDraw;
	//				foreach(jeep; g_jeeps) 
	//					if (jeep.jeepBullit !is null && jeep.jeepBullit.jbullit == JBullit.alive) {
	//						g_display.setJeepBullit(jeep);
	//						g_display.display(DisplayType.jeepBullitDraw);
	//					}
	//				}
				//Draw front layer
				foreach(ref portal; g_portals[0 .. 2]) {
					portal.draw(Border.no, Layer.front);
				}
//				g_mainPopBanner.draw;
			break;
			case Mode.edit:
			/+
				if (g_keys[Keyboard.Key.LSystem].keyPressed || g_keys[Keyboard.Key.RSystem].keyPressed) {
					if (g_keys[Keyboard.Key.S].keyTrigger) {
						g_guiConfirm.setQuestion(["Save '" ~ g_fileRootName.to!string ~ "'", "confirm yes/no?"]);
						g_guiConfirm.setHideAll(false);
						g_wedgetFile = WedgetFile.save;
					}
					if (g_keys[Keyboard.Key.L].keyTrigger) {
						g_guiConfirm.setQuestion(["Load '" ~ g_fileRootName.to!string ~ "'", "confirm yes/no?"]);
						g_guiConfirm.setHideAll(false);
						g_wedgetFile = WedgetFile.load;
					}
				}
			+/
				if (g_doGuiFile) {
					auto pnt = Vec(g_mouse.pos.x, g_mouse.pos.y);
					g_guiFile.process(pnt);
					g_guiConfirm.process(pnt);
					if (g_stateConfirm == StateConfirm.yes) {
						g_stateConfirm = StateConfirm.ask;
						final switch(g_wedgetFile) with(WedgetFile) {
							case projects:
							case current:
							break;
							case save:
								.save;
							break;
							case load:
								.load;
							break;
							case del:
								.del;
							break;
							case rename:
								.changeName;
							break;
						}
					}
					g_guiFile.draw(gGraph);
					g_guiConfirm.draw(gGraph);

					break break1;
				}
				foreach(layer; Layer.back .. Layer.front + cast(Layer)1) {
					g_display.setPortalEditLayer(layer);
					g_display.display(DisplayType.editLayer);
				}

				doJeepDraw;

				if (! g_jexTerminal && ! g_doGuiFile) {
					with(g_portals[PortalSide.editor]) {
						if (! (g_keys[SDL_SCANCODE_LCTRL].keyPressed ||
							g_keys[SDL_SCANCODE_RCTRL].keyPressed)) {
							if (! showingBible) {
								if (g_keys[SDL_SCANCODE_S].keyTrigger) {
									g_display.setVerse(g_bible.argReference(
										g_bible.argReferenceToArgs(
											g_screens[scrn.y][scrn.x].verseRef)));
									
									g_doLetUpdate = showingBible = true;
									writeln("Verse(s): ", g_screens[scrn.y][scrn.x].verseRef);
								}
							}
							if (showingBible) {
								if (g_keys[SDL_SCANCODE_S].keyTrigger)
									showingBible = false;
							}
						} // if command key not pressed

						if (g_keys[SDL_SCANCODE_UP].keyTrigger) {
							if (scrn.y > 0)
								scrn = scrn + Vector!int(0, -1);
						}

						if (g_keys[SDL_SCANCODE_RIGHT].keyTrigger) {
							if (scrn.x + 1 < g_scrnDim.x)
								scrn = scrn + Vector!int(1, 0);
						}

						if (g_keys[SDL_SCANCODE_DOWN].keyTrigger) {
							if  (scrn.y + 1 < g_scrnDim.y)
								scrn = scrn + Vector!int(0, 1);
						}

						if (g_keys[SDL_SCANCODE_LEFT].keyTrigger) {
							if  (scrn.x > 0)
								scrn = scrn + Vector!int(-1, 0);
						}
					}
				}
				break;
		}

		g_popLine.process;
		
		// just draw border
		if (g_mode == Mode.play) {
			foreach(ref portal; g_portals[0 .. 2]) {
				g_display.setPortal(portal);
				g_display.display(DisplayType.playBorder);
			}
		}
		
		if (g_jexTerminal) {
			int processValue(string s) {
				string result = s;
				import std.regex;
				auto pattern = regex(`([^-0-9]*)([-0-9]+)(.*)`); //#no I didn't do this my self
				//auto pattern = regex(`([^-0-9]*)([-0-9]+)`); //'(.*)' taken out
				auto m = result.matchFirst(pattern);

				if (! result.length || ! m[2].length) {
					g_inputJex.addToHistory("Input error, no value! Defaulting to '1'");
					return 1;
				} else {
					return m[2].to!int;
				}
			}

			g_inputJex.process; //#input
			if (g_inputJex.enterPressed) {
				with(g_inputJex) {
					int number;
					enterPressed = false;
					auto dargs = textStr.split;
					bool terminal = false;
					if (dargs.length) {
						textStr = dargs[0];
					}
					else
						textStr = "default";
					string str = textStr;
					if (str != "Joel" &&
						str != "Sean" &&
					    str != "Jade")
						str = textStr.toLower;
					switch(str) {
						default: g_inputJex.addToHistory("Not recognized command."); break;
						case "h", "help":
						//#see help.txt
						import std.string;
						foreach(line; File("help.txt").byLine) {
							g_inputJex.addToHistory(line.stripLeft);
						}
						break;
						case "g", "gui":
							g_doGuiFile = true;
							g_jexTerminal = false;
						break;
						//#work here
						case "ref":
							import std.string: join;
							int sx = g_portals[PortalSide.editor].scrn.x,
								sy = g_portals[PortalSide.editor].scrn.y;
							auto verseRef = dargs[1 .. $].to!(string[]).join(" ");

							g_screens[sy][sx].verseRef = verseRef;
							auto getVerses = g_bible.argReference(g_bible.argReferenceToArgs(verseRef));
							string[] verses;
							if (getVerses.length)
								verses = getVerses.split('\n')[0 .. $ - 1];
							foreach(ver; verses)
								g_inputJex.addToHistory(ver);
						break;
						case "cls", "clear":
							g_inputJex.clearHistory;
						break;
						case "race":
							if (dargs.length == 2) {
								auto timer = processValue(dargs[1]);
								g_timer.setup(timer);
								if (timer == 0) { //#What ever can the problem here b!?
									g_timer.setup(10_000);
									g_inputJex.addToHistory("Count down timer is reset");
								} else {
									g_inputJex.addToHistory(text("Race set (", timer, " seconds)"));
								}
							}
						break;
						case "hide":
							if (dargs.length == 2 &&
								(processValue(dargs[1]) == 1 ||
								 processValue(dargs[1]) == 2)) {
								int player = processValue(dargs[1]) - 1;
								if (g_guys[player].hide == Hide.inview)
									g_guys[player].hide = Hide.hidden;
								else
									g_guys[player].hide = Hide.inview;
							} else {
								g_inputJex.addToHistory("Error!");
							}
							break;
						case "b", "bullitproof":
							if (g_guys[0].bullitProof) {
								g_guys[0].bullitProof = false;
								g_guys[1].bullitProof = false;
								g_inputJex.addToHistory("Bullit proof off! (can shoot each other)");
							} else {
								g_guys[0].bullitProof = true;
								g_guys[1].bullitProof = true;
								g_inputJex.addToHistory("Bullit proof on! (can't shoot each other)");
							}
						break;
						case "reset":
							g_building.loadBuilding;
							g_building.resetGame;
							goto case "t";
						case "Joel":
						case "Sean":
						case "Jade":
							g_inputJex.addToHistory("Hello " ~ str ~ ", how are you?");
							break;
							case "t":
								g_jexTerminal = false;
							break;
							case "create":
								if (dargs.length == 3) {
									g_building.setFileName("backup.bin");
									g_building.saveBuilding;

									g_jeeps.length = 0; //#get rid of the jeeps!
									int sdx, sdy; // screens dimentions
									sdx = processValue(dargs[1]); //dargs[1].to!int;
									sdy = processValue(dargs[2]); //dargs[2].to!int;
									addToHistory(format("Creating: width=%s, height=%s, Total: %s", sdx, sdy, sdx * sdy));
									if (g_building.createMap(sdx, sdy))
										addToHistory("Creating done");
									g_building.setFileName("test.bin");
									addToHistory("building set to 'test.bin'");
								}
							break;
							case "go":
								if (dargs.length == 3) {
									int sdx, sdy; // screens dimentions
									sdx = processValue(dargs[1]); //dargs[1].to!int;
									sdy = processValue(dargs[2]); //dargs[2].to!int;
									if (sdx >= 0 && sdx < g_scrnDim.x &&
										sdy >= 0 && sdy < g_scrnDim.y) {
										g_portals[PortalSide.editor].scrn = Vector!int(sdx,sdy);
										addToHistory(format("Screen: %s %s", sdx, sdy));
									} else
										addToHistory("Invalid input");
								} // if == 3
							break;
							case "cat":
								getDiscList(/* show */ true);
							break;
							case "l", "load":
								import std.ascii: isDigit;
								if (dargs.length == 2 && dargs[1][0].isDigit) {
									g_building.setFileName("backup.bin");
									g_building.saveBuilding;
									addToHistory("Back up saved (backup.bin)");

									//int select = dargs[1].to!int - 1;
									//int select = processValue(dargs[1].to!string).to!int - 1;
									int select = processValue(dargs[1]) - 1;
									if (select >= 0 && select < discList.length) {
										addToHistory(text("Loading as: ", discList[select]));
										g_building.setFileName(discList[select]);
									} else {
										addToHistory(text(select + 1, " is invaild input."));
									}
									if (! g_building.loadBuilding)
										addToHistory(text("Failed loading: ", g_building.fileName));
								}
							break;
							case "s", "save":
								if (dargs.length == 2) {
									g_building.setFileName(dargs[1] ~ ".bin");
									g_building.saveBuilding;
								}
							break;
							case "", "remove", "delete":
								g_building.setFileName("backup.bin");
								addToHistory("Deleted is saved to backup.bin");
								g_building.saveBuilding;
							int select = processValue(dargs[1]) - 1;
								if (select >= 0 && select < discList.length) {
									addToHistory(text("Removing: ", discList[select]));
									import std.file;
									remove(discList[select]);
								}
							break;
							case "info", "i":
								//#why do I need to put format in instead of text (the ': ' gets removed with text)
								foreach(i, guy; g_guys)
									with(guy) {
										addToHistory(text((i == 0 ? "Left" : "Right"), " Guy \\/"));
										addToHistory(text("ST position screen (resetPos): ", resetPos));
										addToHistory(format("ST which screen (portal.resetScrn): %s", portal.resetPosScrn));
										addToHistory(text("guy place on screen (pos): ", pos));
										addToHistory(format("Which screen [portal.scrn]: %s", portal.scrn));
										addToHistory(text("Diamonds (diamonds): ", dashBoard.diamonds));
										import std.range;
										addToHistory("-".replicate(7));
									}
								addToHistory("Other stuff \\/");
								addToHistory(text("Building: ", g_building.fileName));
								addToHistory(text("g_scrnDim: ", g_scrnDim));
								//#here
								addToHistory(text("Screen name: ",
									g_screens[g_portals[PortalSide.editor].scrn.y][
											g_portals[PortalSide.editor].scrn.x].verseRef));
							break;
							case "exit", "quit":
                                addToHistory("Exiting to OS...", terminal);
								done = true;
							break;
					}
					textStr = "";
				}
			}
			g_display.display(DisplayType.inputJexDraw);
		} // terminal

		if (g_mode == Mode.edit) {
			g_display.display(DisplayType.mouseDraw);
		}

		if (g_popLine._pban.show)
			g_popLine.draw;
		
		if (g_mode == Mode.play) {
			foreach(g; g_guys) {
				if (g.escapeStatus == GuyEscapeStatus.outOfTime) {
					g.banner.draw;
				}
			}
		}

		if (g_mode == Mode.play && g_displayGameText == true) {
			g_display.display(DisplayType.viewVerse);
			g_doLetUpdate = false;
			g_displayGameText = false;
		}

		g_timer.draw;

		//#to hide or not to hide
		if (g_mode == Mode.play) {
			foreach(cpu; g_computers) {
				cpu.process;
			}
			g_computers = g_computers.filter!(e => e._cpuState != CPUState.rubble).array;

			foreach(i, p; g_guys) {
				if (p.hide == Hide.hidden) {
					blackPlastic.pos = Vec(cast(int)i * 320, 0);
					blackPlastic.draw(gGraph);
				}
			}

			final switch(g_missionStage) with(MissionStage) {
				case briefing:
					g_display.display(DisplayType.mission);
				break;
				case playing:
					if (g_guys[player1].escapeStatus == GuyEscapeStatus.escaped &&
						g_guys[player2].escapeStatus == GuyEscapeStatus.escaped) {
						g_campaign.setReport(/* win */ g_score.targetDiamondsQ);
						g_missionStage = MissionStage.report;
					}
				break;
				case report:
					g_display.display(DisplayType.mission);
				break;
			}
		} else {
			// not play
			if (showingBible)
				g_display.display(DisplayType.viewVerse);
		}

		//Update screen
		gGraph.drawning(); // Swap buffers

		FPS.rate();
	}

	return 0;
}

void save() {
	g_building.setFileName(g_fileRootName ~ ".bin");
	g_building.saveBuilding;
	g_currentProjectName = g_fileRootName;
	updateProjectList("");
}

void load() {
	g_building.setFileName("backup.bin");
	g_building.saveBuilding;
	jx.addToHistory("Back up saved (backup.bin)");
	g_building.setFileName(g_fileRootName ~ ".bin");
	if (! g_building.loadBuilding)
		jx.addToHistory(text("Failed loading: ", g_building.fileName ~ ".bin"));
	else
		g_currentProjectName = g_fileRootName;
	updateProjectList("");
}

void del() {
	if (g_fileRootName == g_currentProjectName) {
		jx.addToHistory("Will not delete from current building..");
		return;
	}
	g_building.setFileName("backup.bin");
	jx.addToHistory("Deleted is saved to backup.bin");
	g_building.saveBuilding;
	import std.file;
	try
		remove(g_fileRootName ~ ".bin");
	catch(Exception e)
		jx.addToHistory("Removing file failier");
	updateProjectList("");
}

void changeName() {
	scope(success) {
		//g_currentProjectName = g_fileRootName;
		g_building.setFileName(g_currentProjectName ~ ".bin");
		updateProjectList("");
	}
	import std.file : rename;

	try
		rename(g_currentProjectName ~ ".bin", g_fileRootName ~ ".bin");
	catch(Exception e)
		jx.addToHistory("Renaming file failier: ", e.msg);
}

void close() {
	destroy(gGraph);
	destroy(loader);

	destroy(window);
	sdlDestroy();
}

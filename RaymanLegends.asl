// created by: Tenit

state("Rayman Legends"){
	uint loading: "Rayman Legends.exe", 0x00A46154, 0x8, 0x1D4, 0x0, 0x58;    		// 0 if loading, 1 otherwise
	uint place: "Rayman Legends.exe", 0x00AE683C, 0x34C;					// 
	uint invasion: "Rayman Legends.exe", 0x00A4619C, 0x3C, 0xC, 0x8, 0x1B4, 0x774;		// 4 if in invasion level
	uint ticket: "Rayman Legends.exe", 0x00A46104, 0x70;					// 1 if ticket, 0 otherwise
	uint pauseMenu: "Rayman Legends.exe", 0x00A46158, 0x80, 0x3C;				// 1 if menu pops up
	uint menu : "Rayman Legends.exe", 0x00A4619C, 0x3C, 0x3C, 0x14;				// 1 if main menu
	uint death: "Rayman Legends.exe", 0x00AEB67C, 0x3BC;					// resets after a level, counter
	uint teensy: "Rayman Legends.exe", 0x00AEB67C, 0x3A0;					// resets after level, counter
	
	uint lumScreen: "Rayman Legends.exe", 0x00A461D4, 0xCC;					// 1 if on lum screen
	uint invasionTimeScreen: "Rayman Legends.exe", 0x00AE7AAC, 0x4, 0x30, 0x8, 0x124;	// 1 if on end screen for invasion, 2 on pause, 0 otherwise
	uint tgatherEnd: "Rayman Legends.exe", 0x00AEA3B8, 0x4;					// 1 if at end of level or just entering a level
	uint tgather: "Rayman Legends.exe", 0x00AE483C, 0x188, 0x4, 0x5E0;			// teensy gather, 1 if there 0 otherwise.
	uint levelReset: "Rayman Legends.exe", 0x00A46154, 0x8, 0x114, 0x0, 0x1D8;		// 0 if resetting in a level
	uint seqReset: "Rayman Legends.exe", 0x00AEB67C, 0x3B8;					// counts how many sequence resets happen in a level
	
	uint levelID: "Rayman Legends.exe", 0xAE7868, 0x1F0;					// level ID
	uint screenWipe: "Rayman Legends.exe", 0x00AE7B2C, 0x2C, 0x4C, 0x270, 0x10, 0xC4;	// 1 if screen wipe is active

	uint punch11: "Rayman Legends.exe", 0x00AEA3B0, 0x0, 0x18, 0x234, 0x0, 0x20;		// 1 if boss 1/5 is punched
	uint punch12: "Rayman Legends.exe", 0x00AEA3B0, 0x0, 0x18, 0x220, 0x4, 0x20;
	uint punch13: "Rayman Legends.exe", 0x00AEA3B0, 0x0, 0x18, 0x8C, 0xA4, 0xC, 0x108, 0x128;
	uint punch21: "Rayman Legends.exe", 0x00AEA3B0, 0x0, 0x8, 0x220, 0x4, 0x20;		// 1 if boss 2/3/4 is punched
}

startup{
 
	// level splits
	settings.Add("levelSplit", true, "Level splits");
	settings.Add("mainLevelSplit", true, "Split on exiting a main level", "levelSplit");
	settings.Add("invasionLevelSplit", true, "Split on exiting an invasion level", "levelSplit");
	settings.Add("punch", true, "Split on punching the last teensy", "levelSplit");
	settings.Add("teensyGatherSplit", false, "Split at end of level", "levelSplit");
	settings.Add("lumCountStartSplit", false, "Split at start of lum count", "levelSplit");
	settings.Add("invasionSprintEnd", false, "Split on invasion button press exit", "levelSplit");
	
	// extra splits
	settings.Add("invasionSprintStart", false, "Start on pressing OK in invasion level");
	settings.Add("teensySplit", false, "Split on each teensy collected in level");
	settings.Add("10Ticket", false, "Split on scratching the 10th ticket");
	settings.Add("lastTicket", false, "Split on scratching the last ticket (154)");
	
	// timer start/reset to do
	//settings.Add("levelReset", false, "Reset timer when restarting a level");
	settings.Add("levelStart", false, "Start timer upon spawning into a level");

	// extra settings
	settings.Add("miscellaneous", false, "Extra settings");
	settings.Add("deathCounter", false, "Display death count in text component of layout", "miscellaneous");
	settings.Add("teensyCounterLevel", false, "Display teensy count for level", "miscellaneous");
	settings.Add("teensyCounterTotal", false, "Display total teensy count", "miscellaneous");

	// tooltips
	settings.SetToolTip("deathCounter", "Requires a text component be added to the layout");
	settings.SetToolTip("teensyCounterLevel", "Requires a text component be added to the layout");
	settings.SetToolTip("teensyCounterTotal", "Requires a text component be added to the layout");
	settings.SetToolTip("invasionSprintEnd", "On the screen where you choose to exit an invasion");
}

init{ 

	vars.inLevel = false;				// if in painting
	vars.inInvasion = false;			// if in an invasion painting
	vars.finishLevel = false;			// if a level has been finished, not leaving early
	vars.inMenu = false;				// if a menu is up (includes pause menu + others)
	vars.deathCount = 0;				// total death count
	vars.teensyCount = 0;				// total teensy count
	vars.teensyCountLevel = 0;			// helper variable for above, how many teensies were collected in a level
	vars.teensyCountUpper = 0;			// highest number of teensies collected in a level, prevents redundant splits
	vars.deathCountText = false;			// whether to display death count
	vars.tTeensyCountText = false;			// whether to display total teensy count
	vars.lTeensyCountText = false;			// whether to display level teensy count
	vars.numTickets = 0;				// total number of tickets scratched
	vars.totalTickets = 154;			// total number of tickets in the game
	vars.tickets10 = 10;
	vars.splitTickets = true;			// whether to split on last ticket, prevents redundant splits
	vars.splitTickets10 = true;
	vars.teensyGathering = false;			// if at teensy gathering at end of level
	vars.lumCounting = false;			// if at lum counting
	vars.reachedEnd = false;			// if the level has been completed - prevents splitting after leaving a level early
	vars.boss1 = false;
	vars.boss2 = false;
	vars.boss3 = false;
	vars.boss4 = false;
	vars.boss5 = false;
	vars.bossCount = 0;				// number of bosses defeated
	vars.changeTime = false;			// whether time should be changed from pause
	vars.leavePause = false;			// change time when leaving a level
	vars.checkStart = false;


	if (settings["miscellaneous"]){
		foreach (LiveSplit.UI.Components.IComponent component in timer.Layout.Components) {
        		if (component.GetType().Name == "TextComponent") {
				vars.temp = component;
				if (settings["deathCounter"] && (!vars.deathCountText)){
          				vars.deathComp = vars.temp.Settings;
					vars.deathComp.Text1 = "Death Count:";
					vars.deathComp.Text2 = "0";
					vars.deathCountText = true;
          				continue;
				}
				if (settings["teensyCounterLevel"] && (!vars.lTeensyCountText)){
          				vars.ltcomp = vars.temp.Settings;
					vars.ltcomp.Text1 = "Teensies In Level Count:";
					vars.ltcomp.Text2 = "0";
					vars.lTeensyCountText = true;
          				continue;
				}
				if (settings["teensyCounterTotal"] && (!vars.tTeensyCountText)){
          				vars.ttcomp = vars.temp.Settings;
					vars.ttcomp.Text1 = "Total Teensy Count:";
					vars.ttcomp.Text2 = "0";
					vars.tTeensyCountText = true;
          				continue;
				}
			}
        	}
      	}
}


start{
	// pressing pause
	if ( (vars.inMenu) && (current.pauseMenu==1) ){
		vars.inMenu = false;
		vars.checkStart = true;
		vars.leavePause = true;
		return true;
	}

	// mismenu
	if (vars.checkStart && ((current.pauseMenu==1) && (old.pauseMenu==0)) ){
		vars.leavePause = true;
		return true;
	}

	// spawning in gallery
	if ((vars.inMenu) && (current.place==1092616192)){
		vars.inMenu = false;
		return true;
	}

	// starting invasion, closing time screen
	if (settings["invasionSprintStart"] && (current.invasion == 4) && (old.invasion == 0)){
		return true;
	}

	// spawning in level
	if (settings["levelStart"] && (current.place == 1065353216) && (old.place != 1065353216) && (old.loading == 0)){
		return true
	}
}

isLoading{

	// check if screen wipe happens and if so store current game time 
	if ((current.screenWipe == 1) && (old.screenWipe == 0)){
		vars.pTime = timer.CurrentTime.GameTime;
		vars.changeTime = true;
	}

	// if load occurs && entering level, set game time to stored time
	if (vars.changeTime && (current.loading == 0) && ((current.levelID != 4294967295) || vars.leavePause) ){
		timer.SetGameTime(vars.pTime);
		vars.changeTime = false;
		vars.leavePause = false;
	}

	// if load occurs, pause timer
	return (current.loading == 0);
}

reset{

	return (current.menu == 1);

	// reset on level restart
	//if ( settings["levelReset"] && (current.loading != 0) && (current.levelReset == 0) && (old.levelReset != 0) ){
	//	return true;
	//}
}

update{

	// update some splitting variables
	vars.lumCounting = ((current.lumScreen == 1) && (old.lumScreen != 1));
	vars.teensyGathering = ((old.tgatherEnd == 0) && (current.tgatherEnd == 1) && (current.tgather == 1));
	vars.reachedEnd = ((vars.lumCounting) || (vars.inInvasion && current.invasionTimeScreen == 1));
	vars.finishLevel = (vars.finishLevel || vars.reachedEnd);
	
	// count number of bosses defeated
	// boss1
	if ((!vars.boss1) && (current.levelID == 1748345027) && ( ((current.punch11 == 1) && (old.punch11 == 0)) || (vars.finishLevel)) ){
		vars.boss1 = true;
		vars.bossCount += 1;
	}
	// boss2
	if ((!vars.boss2) && (current.levelID == 3178754230) && ( ((current.punch21 == 1) && (old.punch21 == 0)) || (vars.finishLevel))){
		vars.boss2 = true;
		vars.bossCount += 1;
	}
	// boss3
	if ((!vars.boss3) && (current.levelID == 2261450378) && ( ((current.punch21 == 1) && (old.punch21 == 0)) || (vars.finishLevel))){
		vars.boss3 = true;
		vars.bossCount += 1;
	}
	// boss4
	if ((!vars.boss4) && (current.levelID == 1549755521) && ( ((current.punch21 == 1) && (old.punch21 == 0)) || (vars.finishLevel))){
		vars.boss4 = true;
		vars.bossCount += 1;
	}
	// boss5
	if ((!vars.boss5) && (current.levelID == 2919390489) && ( ((current.punch11 == 1) && (old.punch11 == 0)) || ((current.punch12 == 1) && (old.punch12 == 0)) || ((current.punch13 == 2) && (old.punch13 == 1)) || (vars.finishLevel))){
		vars.boss5 = true;
		vars.bossCount += 1;
	}


	// place variables
	if (current.place != 0){
		vars.checkStart = false;
	}
	if (current.place == 1065353216){
		vars.inLevel = true;
		vars.leavePause = true;
	}
	if (current.invasion == 4){
		vars.inInvasion = true;
	}

	
	// main menu, reset some variables
	if (current.menu == 1){
		vars.numTickets = 0;
		vars.splitTickets = true;
		vars.splitTickets10 = true;
		vars.deathCount = 0;
		vars.teensyCount = 0;
		vars.reachedEnd = false;
		vars.bossCount = 0;
		vars.boss1 = false;
		vars.boss2 = false;
		vars.boss3 = false;
		vars.boss4 = false;
		vars.boss5 = false;
		vars.checkStart = false;
		vars.inMenu = true;
		vars.inLevel = false;
		vars.inInvasion = false;
		vars.finishLevel = false;
		
	}
	
	// update tickets scratched
	if ((old.ticket==1) && (current.ticket==0)){
		vars.numTickets += 1;
	}

	// update teensy split helper variables
	if (settings["teensySplit"]){
		if (current.teensy > vars.teensyCountUpper){
			vars.teensyCountUpper = current.teensy;
		}
		if ((current.teensy < old.teensy) && (old.teensy == vars.teensyCountUpper)){
			vars.teensyCountUpper += 1;
		}
		if (current.loading == 0){
			vars.teensyCountUpper = 0;
		}
	}

	// update text component variables
	if (vars.deathCountText){
		if ((current.death > old.death) || (current.seqReset > old.seqReset) || ((current.loading != 0) && ((current.invasion == 4) && (current.levelReset == 0) && (old.levelReset != 0)))){
			vars.deathCount += 1;
			vars.deathComp.Text2 = vars.deathCount.ToString();
		}
    	}
	if (vars.lTeensyCountText){
		if (current.teensy != old.teensy){
			vars.ltcomp.Text2 = current.teensy.ToString();
		}
	}
	if (vars.tTeensyCountText){
		if (vars.reachedEnd){
			vars.teensyCountLevel = current.teensy;
		}
		if (current.loading == 0){
			vars.teensyCount += vars.teensyCountLevel;
			vars.teensyCountLevel = 0;
		}
		if (current.teensy != old.teensy){
			vars.ttcomp.Text2 = (vars.teensyCount + current.teensy).ToString();
		}
	}

}

split{

	vars.split = false;

	// exiting a painting
	if ((vars.inLevel) && (vars.finishLevel) && (current.place == 1092616192)){
		if ((settings["invasionLevelSplit"]) && (vars.inInvasion)){
			vars.split = true;
		}
		if ((settings["mainLevelSplit"]) && (!vars.inInvasion)){
			vars.split = true;
		}
		vars.inLevel = false;
		vars.inInvasion = false;
		vars.finishLevel = false;
	}

	// punching last teensy, adjust for late split
	if (settings["punch"] && vars.bossCount == 5){
		vars.bossCount += 1;
		vars.split = true;
	}

	// scratching last ticket
	if (settings["lastTicket"] && (vars.numTickets == vars.totalTickets) && (vars.splitTickets)){
		vars.splitTickets = false;
		vars.split = true;
	}

	if (settings["10Ticket"] && (vars.numTickets == vars.tickets10) && (vars.splitTickets10)){
		vars.splitTickets10 = false;
		vars.split = true;
	}

	// exit invasion button press.
	vars.split = (vars.split || ((settings["invasionSprintEnd"]) && (vars.finishLevel) && (current.invasion == 0) && (old.invasion == 4)) );

	// split at teensy gathering
	vars.split = (vars.split || (settings["teensyGatherSplit"] && (vars.teensyGathering)) );

	// split at lum count
	vars.split = (vars.split || (settings["lumCountStartSplit"] && (vars.lumCounting)) );

	// split on each teensy collected
	vars.split = (vars.split || (settings["teensySplit"] && (current.teensy > old.teensy) && (current.teensy == vars.teensyCountUpper)) );

	return vars.split;
 
}

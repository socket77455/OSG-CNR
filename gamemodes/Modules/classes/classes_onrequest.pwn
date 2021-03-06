// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/*
*
*		Andy's Cops and Robbers - a SA:MP server

*		Copyright (c) 2016 Andy Sedeyn
*
*		Permission is hereby granted, free of charge, to any person obtaining a copy
*		of this software and associated documentation files (the "Software"), to deal
*		in the Software without restriction, including without limitation the rights
*		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*		copies of the Software, and to permit persons to whom the Software is
*		furnished to do so, subject to the following conditions:
*
*		The above copyright notice and this permission notice shall be included in all
*		copies or substantial portions of the Software.
*
*		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*		SOFTWARE.
*
*/
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/*
*
*		Classes module: classes_onrequest.pwn
*
*/

#include <YSI\y_hooks>

/*
*
*		Script
*
*/

hook OnPlayerRequestClass(playerid, classid) {

	new
		classLoc = Player[playerid][epd_ClassEnvironment];

	if(classLoc == -1) {

		classLoc = Player[playerid][epd_ClassEnvironment] = random(sizeof(gArr_ClassesEnvironment));
	}

	if(!IsPlayerNPC(playerid) && Player_LoggedIn(playerid)) {

		PlayerPlaySound(playerid, 1097, 0.0, 0.0, 0.0);

		// Validate class
		Player_ClassValidate(playerid, classid);

		new
			currClass = Player[playerid][epd_TempCurrentClassID];

		SetPlayerSkin(playerid, gArr_Classes[currClass][escd_SkinID]);
		SetPlayerPos(playerid, gArr_ClassesEnvironment[classLoc][eced_X], gArr_ClassesEnvironment[classLoc][eced_Y], gArr_ClassesEnvironment[classLoc][eced_Z]);
		SetPlayerFacingAngle(playerid, gArr_ClassesEnvironment[classLoc][eced_A]);

		SetPlayerCameraLookAt(playerid, gArr_ClassesEnvironment[classLoc][eced_X], gArr_ClassesEnvironment[classLoc][eced_Y], gArr_ClassesEnvironment[classLoc][eced_Z]);
		SetPlayerCameraPos(playerid, gArr_ClassesEnvironment[classLoc][eced_X] + (5 * floatsin(-gArr_ClassesEnvironment[classLoc][eced_A], degrees)), gArr_ClassesEnvironment[classLoc][eced_Y] + (5 * floatcos(-gArr_ClassesEnvironment[classLoc][eced_A], degrees)), gArr_ClassesEnvironment[classLoc][eced_Z]);
	}
	return true;
}

Player_ClassValidate(playerid, classid, max_classes = (sizeof(gArr_Classes) - 1)) {

	/*
	*
	*		The recursion in this program will lead to unexpected results
	*		
	*		-> Class of the player == 2
	*		-> Class id 2 is a VIP class but the player isn't a VIP (Class_IsVisibleForPlayer evaluates to false)
	*		-> ClassID ++ (3 now)
	*		-> ClassID != classid (2 != 3)
	*			-> Check again
	*		-> Class of the player == 3
	*		-> Class 3 is visible
	*		-> SetTemporaryClass(playerid, 3)
	*		-> SetTemporaryClass(playerid, 2) <-- back to the start!!
	*		
	*		returning the recursion might fix this behaviour
	*
	*/

	new
		tempClass = classid;

	if(classid > max_classes) {

		// Reset the class selection when max_classes is exceeded
		tempClass = 0;
	}
	if(!Class_IsVisibleForPlayer(classid, playerid)) {

		// When the class is invisible
		tempClass++;
	}
	if(tempClass != classid) {

		// Recursively redo the class checking (see note at the top of the function)

		// return Player_ClassValidate(playerid, classid); 
		return Player_ClassValidate(playerid, tempClass);
	}
	Player_SetTemporaryClass(playerid, tempClass);
	return true;
}

hook OnPlayerRequestSpawn(playerid) {

	new
		tmpCurrentClass = Player[playerid][epd_TempCurrentClassID];

	if(!IsPlayerNPC(playerid)) {

		if(GetPlayerScore(playerid) < ClassTemporary_GetRequiredEXP(tmpCurrentClass)) {

			return false;
		}
	}
	Player_SetCurrentClass(playerid, Player_GetTemporaryClass(playerid));
	Server_UpdateCNRCount(playerid);

	Player_Spawn(playerid);
	BitFlag_On(PlayerFlags[playerid], epf_Spawned);
	return true;
}

ClassTemporary_GetRequiredEXP(tmpCurrentClass) {

	return gArr_Classes[tmpCurrentClass][escd_Experience];
}

Server_UpdateCNRCount(playerid) {

	if(Player_GetCurrentClass(playerid) != CLASS_NULL) {

		if(ClassTemporary_LawEnforcement(playerid) && !ClassCurrent_LawEnforcement(playerid)) {

			Server_IncreaseStat(STAT_COP_COUNT, 1);
			Server_DecreaseStat(STAT_ROBBER_COUNT, 1);
		}
		else {

			Server_IncreaseStat(STAT_ROBBER_COUNT, 1);
			Server_DecreaseStat(STAT_COP_COUNT, 1);
		}
	}
	else {

		if(ClassTemporary_LawEnforcement(playerid)) {

			Server_IncreaseStat(STAT_COP_COUNT, 1);
		}
		else {

			Server_IncreaseStat(STAT_ROBBER_COUNT, 1);
		}
	}
}

Player_SetCurrentClass(playerid, classid) {

	Player[playerid][epd_CurrentClassID] = classid;
}

Player_GetCurrentClass(playerid) {

	return Player[playerid][epd_CurrentClassID];
}

Player_GetTemporaryClass(playerid) {

	return Player[playerid][epd_TempCurrentClassID];
}

Player_SetTemporaryClass(playerid, classid) {

	Player[playerid][epd_TempCurrentClassID] = classid;
}

ClassCurrent_LawEnforcement(playerid) {

	switch(Player[playerid][epd_CurrentClassID]) {

		case CLASS_POLICE_OFFICER, CLASS_FBI, CLASS_SWAT, CLASS_CIA, CLASS_ARMY, CLASS_AIRPORT_GUARD: {
			
			return true;
		}
	}
	return false;
}

ClassTemporary_LawEnforcement(playerid) {

	switch(Player[playerid][epd_TempCurrentClassID]) {

		case CLASS_POLICE_OFFICER, CLASS_FBI, CLASS_SWAT, CLASS_CIA, CLASS_ARMY, CLASS_AIRPORT_GUARD: {
			
			return true;
		}
	}
	return false;
}

Player_Spawn(playerid) {

	new
		classLoc = Player[playerid][epd_ClassEnvironment],
		classid = Player[playerid][epd_CurrentClassID];

	SetSpawnInfo(playerid, 0, 
		gArr_Classes[classid][escd_SkinID],
		gArr_ClassesEnvironment[classLoc][eced_X],
		gArr_ClassesEnvironment[classLoc][eced_Y],
		gArr_ClassesEnvironment[classLoc][eced_Z],
		gArr_ClassesEnvironment[classLoc][eced_A],
		0, 0, 0, 0, 0, 0
	);
	SetPlayerColor(playerid, gArr_Classes[classid][escd_Color]);
	Player_SetClass(playerid, classid);
	return true;
}

Player_SetClass(playerid, classid) {

	Player[playerid][epd_Class] = gArr_Classes[classid][escd_Class];
	return true;
}


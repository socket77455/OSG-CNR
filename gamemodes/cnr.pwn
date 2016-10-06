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

#include <a_samp>
#include <a_http>

/*
*
*		a_samp redefinitions
*
*/

#undef 	MAX_PLAYERS
#define MAX_PLAYERS		50

/*
*
*		Guaranteed first call
*
*/

public OnGameModeInit() {

	Initialise_GameMode();

	#if defined main_OnGameModeInit
		return main_OnGameModeInit();
	#else
		return true;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit main_OnGameModeInit
#if defined main_OnGameModeInit
	forward main_OnGameModeInit();
#endif

/*
*
*		Includes
*
*/

// YSI includes
#include <YSI\y_timers>
#include <YSI\y_hooks>
#include <YSI\y_va>
#include <YSI\y_iterate>
#include <YSI\y_bit>
//#include <YSI\y_classes>
//#include <YSI\y_groups>

#include <zcmd>
#include <sscanf2>
//#include <streamer>
#include <formatex>
#include <easyDialog>
#include <a_http>

/*
*
*		Native functions
*
*/

native IsValidVehicle(vehicleid);
native WP_Hash(buffer[], len, const str[]);

/*
*
*		Defines
*
*/

// Macro functions
#define as_fpublic:%0(%1)					forward %0(%1); public %0(%1)
#define KEY_HOLDING(%0)						((newkeys & (%0)) == (%0))
#define KEY_RELEASED(%0)					(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define KEY_PRESSED(%0)						(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define MF_Time_PluralSingular(%0,%1,%2) 	((%0) == 1) ? ((%1)) : ((%2))

#define SPECIAL_ACTION_PISSING				68
#define KEY_AIM								KEY_HANDBRAKE

/*
*
*		Bullet types
*
*/

#define BULLET_HIT_TYPE_NONE				0
#define BULLET_HIT_TYPE_PLAYER				1
#define BULLET_HIT_TYPE_VEHICLE				2
#define BULLET_HIT_TYPE_OBJECT				3
#define BULLET_HIT_TYPE_PLAYER_OBJECT		4

/*
*
*		Server settings
*
*/

#define SERVER_DB_ID				1
#define GLOBAL_CHAT_RADIUS			2000.0

#define SERVER_MAIN_DATABASE		"server.db"

/*
*
*		Launcher settings
*
*/

#define COMMUNITY_NAME				"Cops 'n Robbers"
#define SERVER_LAUNCHER_NAME		""COMMUNITY_NAME" | [0.1 BETA]"
#define SERVER_LAUNCHER_MAP			""
#define SERVER_LAUNCHER_LANG		"English"
#define SERVER_LAUNCHER_URL			""
#define SERVER_LAUNCHER_REV			"OSG-CNR v0.1 BETA"

/*
*
*		Max values
*
*/

#define MAX_PLAYER_PASSWORD			129
#define MAX_PLAYER_IP				16
#define MAX_LEN_DATE				36
#define MAX_BAN_REASON				50

// Login & register
#define MAX_LOGIN_ATTEMPTS			5
#define MAX_ALTERNATIVE_ACCOUNTS	2

/*
*
*		Time
*
*/

#define SECONDS_IN_MINUTE	60
#define SECONDS_IN_HOUR		SECONDS_IN_MINUTE * 60
#define SECONDS_IN_DAY		SECONDS_IN_HOUR * 24
#define SECONDS_IN_WEEK		SECONDS_IN_DAY * 7
#define SECONDS_IN_MONTH	SECONDS_IN_WEEK * 4
#define SECONDS_IN_YEAR		SECONDS_IN_MONTH * 12

/*
*
*
*		Colors
*
*/

	// Hexadecimal colours
#define COLOR_POLICE_BLUE 									0x0076FFFF
#define COL_POLICE_BLUE										"{0076FF}"

#define	COLOR_BLUE											0x0097FFFF
#define	COL_BLUE											"{0097FF}"

#define COLOR_BANNED_BLUE									0x8080C0FF
#define COL_BANNED_BLUE										"{8080C0}"

#define	COLOR_RED											0xE90002FF
#define	COL_RED												"{E90002}"

#define	COLOR_GREEN											0x00DE59FF
#define	COL_GREEN											"{00DE59}"

#define COLOR_G_ACHAT										0x21DD00FF
#define COL_G_ACHAT											"{21DD00}"

#define	COLOR_GREY											0x8C8C8CFF
#define	COL_GREY											"{8C8C8C}"

#define	COLOR_WHITE											0xFFFFFFFF
#define	COL_WHITE											"{FFFFFF}"

#define	COLOR_BLACK											0x000000FF
#define	COL_BLACK											"{000000}"

#define	COLOR_PURPLE										0x8068FFFF
#define	COL_PURPLE											"{8068FF}"

#define COLOR_ROLEPLAY										0x33CCFFAA
#define COL_ROLEPLAY										"{33CCFF}"

#define COLOR_YELLOW										0xFFFF00AA
#define COL_YELLOW											"{FFFF00}"

#define COLOR_CYAN											0x00FFFFAA
#define COL_CYAN											"{00FFFF}"

#define COLOR_PINK											0xFF4DFFFF
#define COL_PINK											"{FF4DFF}"

#define COLOR_ORANGE										0xFFA500FF
#define COL_ORANGE											"{FFAF00}"

#define COLOR_PD_RADIO										0x0EEBEBFF
#define COL_PD_RADIO										"{0EEBEB}"

#define COLOR_GLOBAL_PD_RADIO								0x6AAFEBFF
#define COL_GLOBAL_PD_RADIO									"{6AAFEB}"

// Class-related colors
#define COLOR_POLICE_OFFICER								0x0080C0FF
#define COL_POLICE_OFFICER									"{0080C0}"

#define COLOR_FBI											0x0055FFFF
#define COL_FBI												"{0055FF}"

#define COLOR_SWAT											0x5EAEFFFF
#define COL_SWAT											"{5EAEFF}"

#define COLOR_CIA											0x00D7FFFF
#define COL_CIA												"{00D7FF}"

#define COLOR_ARMY											0xAA00FFFF
#define COL_ARMY											"{AA00FF}"

#define COLOR_FIREFIGHTER									0xFF8080FF
#define COL_FIREFIGHTER										"{FF002D}"

#define COLOR_PARAMEDIC										0xB0FF00FF
#define COL_PARAMEDIC										"{B0FF00}"

#define COLOR_MECHANIC										0xD2D2D2FF
#define COL_MECHANIC										"{D2D2D2}"

#define COLOR_AMMUNATION_SALESMAN							0xCD9C6AFF
#define COL_AMMUNATION_SALESMAN								"{CD9C6A}"

#define COLOR_CONSTRUCTION_WORKER							0xFFD400FF
#define COL_CONSTRUCTION_WORKER								"{FFD400}"

#define COLOR_AIRPORT_GUARD									0x828282FF
#define COL_AIRPORT_GUARD									"{828282}"

#define COLOR_PIZZA_WORKER									0xFF8040FF
#define COL_PIZZA_WORKER									"{FF8040}"

#define COLOR_CLUCKIN_BELL_WORKER							0xFF8040FF
#define COL_CLUCKIN_BELL_WORKER								"{FF8040}"

#define COLOR_BURGERSHOT_WORKER								0xFF8040FF
#define COL_BURGERSHOT_WORKER								"{FF8040}"

#define COLOR_HOT_DOG_VENDOR								0xFF8040FF
#define COL_HOT_DOG_VENDOR									"{FF8040}"

#define COLOR_BUS_DRIVER									0x009A00FF
#define COL_BUS_DRIVER										"{009A00}"

#define COLOR_TAXI_DRIVER									0x009A00FF
#define COL_TAXI_DRIVER										"{009A00}"

#define COLOR_LIMO_DRIVER									0x009A00FF
#define COL_LIMO_DRIVER										"{009A00}"

#define COLOR_TRUCKER										0xAD911FFF
#define COL_TRUCKER											"{AD911F}"

#define COLOR_PILOT											0x2471A3FF
#define COL_PILOT											"{2471A3}"  

#define COLOR_BOXER											0xFFFFFFFF
#define COL_BOXER											"{FFFFFF}"

#define COLOR_KARATE_EXPERT									0xFFFFFFFF
#define COL_KARATE_EXPERT									"{FFFFFF}"

#define COLOR_STUNTER										0xFF80C0FF
#define COL_STUNTER											"{FF80C0}"

#define COLOR_CIVILIAN										0xFFFFFFFF
#define COL_CIVILIAN										"{FFFFFF}"

#define COLOR_CONNECTION									0xD2D2D2FF
#define COL_CONNECTION										"{D2D2D2}"


/*
*
*		Global variables
*
*/

new DB:handle_id;

/*
*
*		Modules
*
*/

/*
*
*		Data modules
*
*/

// Server Data
#include "\modules\data\server_data.pwn"

// Classes Data
// Must be included before player_data since it includes the definition for MAX_CLASSES
#include "\modules\data\classes_data.pwn"

// Player Data
#include "\modules\data\player_data.pwn"

// Vehicle Data
//#include "\modules\data\vehicle_data.pwn"

// Textdraw Data
#include "\modules\data\textdraw_data.pwn"


/*
*
*		Utilities
*
*/

#include "\modules\utils\string_utils.pwn"

/*
*
*		Server modules
*
*/

#include "\modules\server\server_functions.pwn"

/*
*
*		Classes modules
*
*/

#include "\modules\classes\classes_loading.pwn"
#include "\modules\classes\classes_onrequest.pwn"

/*
*
*		Player modules
*
*/

#include "\modules\player\global_player_functions.pwn"
#include "\modules\player\connection.pwn"
#include "\modules\player\spawn.pwn"

/*
*
*		Textdraw modules
*
*/

#include "\modules\textdraws\textdraw_creation.pwn"
#include "\modules\textdraws\textdraw_functions.pwn"

/*
*
*		Script
*
*/

main() { }

/*
*
*		OnGameModeInit first call
*
*/

Initialise_GameMode() {

	/*
	*
	*		Server settings
	*
	*/

	UsePlayerPedAnims();
	LimitGlobalChatRadius(GLOBAL_CHAT_RADIUS);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(false);
	SetNameTagDrawDistance(10.0);
	ManualVehicleEngineAndLights();
	EnableVehicleFriendlyFire();

	/*
	*
	*		Setup procedures
	*
	*/

	Server_SetupDatabase();
	Server_ResetStats();

	/*
	*
	*		Timers
	*
	*/

	g_t_EverySecond();
	return true;
}

/*
*
*		Setup procedures
*
*/

Server_SetupDatabase() {

	if((handle_id = db_open(SERVER_MAIN_DATABASE)) == DB:0) {

		print("Failed to open a connection to \""SERVER_MAIN_DATABASE"\".");
		SendRconCommand("exit");
	}
	else {

		// Database_SetupTables(); // This is done by a custom rcon command in rcon_commands.pwn (utils) to prevent it from creating the tables and default rows all the time.
		print("Successfully created a connection to \""SERVER_MAIN_DATABASE"\".");
	}
	return true;
}

as_fpublic:Database_SetupTables() {

	print("creating table \'server_stats\'...");
	// Server stats table
	db_query(handle_id, 
		"CREATE TABLE IF NOT EXISTS `server_stats` ( \
			`ID` INTEGER DEFAULT 1 NOT NULL, \
			`Registered_Players` INTEGER DEFAULT 0 NOT NULL, \
			`Peak_Players_Online` INTEGER DEFAULT 0 NOT NULL \
		)"
	);
	
	print("\'server_stats\' created.");
	// Default row
	print("inserting default rows and values...");

	db_query(handle_id,
		"INSERT INTO server_stats (ID, Registered_Players, Peak_Players_Online) VALUES ("#SERVER_DB_ID", 0, 0)"
	);
	
	print("default rows and values inserted.");
	print("creating table \'players\'...");
	
	// Player table
	db_query(handle_id, 
		"CREATE TABLE IF NOT EXISTS `players` ( \
			`ID` INTEGER PRIMARY KEY AUTOINCREMENT,  \
			`Username` VARCHAR(24) COLLATE NOCASE, \
			`Password` VARCHAR(129), \
			`IP` VARCHAR(16), \
			`RegisterDate` VARCHAR(36) COLLATE NOCASE, \
			`LastLoginDate` VARCHAR(36) COLLATE NOCASE, \
			`DisconnectReason` INTEGER DEFAULT 0, \
			`Admin` INTEGER DEFAULT 0 NOT NULL, \
			`PlayTime` INTEGER DEFAULT 0, \
			`Experience` INTEGER DEFAULT 0, \
			`WantedLevel` INTEGER DEFAULT 0, \
			`Money` INTEGER DEFAULT 0 \
		)"
	);
	print("\'players\' created.");
	
	print("inserting default rows and values...");
	// Default row
	db_query(handle_id,
		"INSERT INTO players (ID, Username, Password, IP) VALUES (1, 'None', '3D0053076EBC2918B0A24C221AF625B3229CA28348DA3FB1348FCD384F487F821B14A04E51D0793C741B58EACB65431402F38B982953EE306A6DE35DC6FEFE16', '127.0.0.1')"
	);

	print("default rows and values inserted.");

	print("creating table \'ips_bans\' ...");

	db_query(handle_id,
		"CREATE TABLE IF NOT EXISTS `ips_bans` ( \
			`IP` VARCHAR(16) PRIMARY KEY, \
			`ExpireDays` INTEGER DEFAULT '99999', \
			`BannedBy` VARCHAR(24), \
			`BanReason` VARCHAR(50), \
			`BanDate` VARCHAR(36) \
		)"
	);

	print("\'ips_bans\' created.");

	print("creating table \'players_bans\' ...");

	db_query(handle_id,
		"CREATE TABLE IF NOT EXISTS `players_bans` ( \
			`ID` INTEGER PRIMARY KEY, \
			`ExpireDays` INTEGER DEFAULT '99999', \
			`BannedBy` VARCHAR(24), \
			`BanReason` VARCHAR(50), \
			`BanDate` VARCHAR(36), \
			FOREIGN KEY (ID) REFERENCES players(ID) \
		)"
	);
	print("\'players_bans\' created.");

	print("\n\nUnloading FS to prevent abuse...");
	SendRconCommand("unloadfs setuptables");
	return true;
}

Server_ResetStats() {

	Server_SetStat(STAT_SERVER_RUNNING_TIME, 0);
	return true;
}

/*
*
*		Timers
*
*/

task g_t_EverySecond[1000]() {

	Server_IncreaseStat(STAT_SERVER_RUNNING_TIME, 1);

	/*
	*
	*		Player Check
	*
	*/

	foreach(new i : Player) {

		if(Player_LoggedIn(i)) {

			Player[i][epd_PlayTime] ++;
			if(Player[i][epd_HackTestExpire] > 0) {

				Player[i][epd_HackTestExpire]--;
			}
			else {

				for(new j = 0; ++j < 13;) {

					Player_GetWeaponInSlot(i, j);
					Player_GetAmmoInSlot(i, j);
				}
			}
			//GetPlayerCash(i);
		}
	}
}

/*
*
*		OnGameModeExit
*
*/

hook OnGameModeExit() {

	db_close(handle_id);
	return true;
}

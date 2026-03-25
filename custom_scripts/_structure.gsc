#include custom_scripts\_func;
#include custom_scripts\_util;
#include custom_scripts\_menu;

structure()
{
    menu = self get_menu();
    if (!isdefined(menu))
        menu = "unassigned";
    
    increment_controls = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5no jump^7 needed";
    slider_controls = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5[{+gostand}]^7 to select";
    credits = "made with ^5<3^7 by ^5ethan ^7& ^5mikey";
    client = get_current_client();
    title = "neura ^5" + client + "^7 - ";

    switch(menu)
    {
    case "neura":
        self add_menu(title + self get_name());
        self add_option("mods & toggles", credits, ::new_menu, "mods & toggles");
        self add_option("class manager", credits, ::new_menu, "class manager");
        self add_option("game settings", credits, ::new_menu, "game settings");
        self add_option("aimbot settings", credits, ::new_menu, "aimbot settings");
        self add_option("client settings", credits, ::new_menu, "manage clients");
        break;
    case "mods & toggles":
        self add_menu(menu);
        self add_option("glitches", undefined, ::new_menu, "glitches");
        self add_option("position", undefined, ::new_menu, "position");
        self add_pers_toggle("invincibility", undefined, ::toggle_invincibility, "invincible");
        self add_pers_toggle("infinite equipment", undefined, ::toggle_inf_eq, "inf_eq");
        self add_pers_toggle("instaswaps", "frag equipment swaps - [{+frag}]", ::instaswaps, "instaswaps");
        self add_increment("instaswaps time", increment_controls, ::setpersfloat, float(self getpers("instaswaps_time")), 0.1, 1, 0.01, "instaswaps_time");
        self add_pers_toggle("auto prone", undefined, ::autoprone, "autoprone");
        self add_array("auto prone mode", slider_controls, ::setpersmenu, list("air,always"), "autoprone_mode");
        self add_pers_toggle("round end prone", undefined, ::togglepers, "autoprone_endgame");
        self add_pers_toggle("auto reload", "empty mag at end of round", ::autoreload, "autoreload");
        self add_pers_toggle("ufo", "toggle noclip - [{+gostand}] + [{+melee}]", ::ufo_mode, "ufo_mode");
        break;
    case "position":
        self add_menu(menu);
        self add_array("teleport bots", slider_controls, ::move_bots, list("self,crosshair"));
        self add_pers_toggle("freeze bots", undefined, ::togglepers, "frozen_bots");
        self add_option("unstuck", undefined, ::unstuck);
        self add_pers_toggle("save and load binds", undefined, ::toggle_snl, "snl");
        self add_option("save position", undefined, ::save_spawn);
        self add_option("load position", undefined, ::load_spawn);
        self add_option("reset position", undefined, ::reset_position);
        if(float(self getpers("saveposx")) != 0 && float(self getpers("saveposy")) != 0 && float(self getpers("saveposz")) != 0)
        {
            self add_increment("change x", increment_controls, ::setpersfloat, float(self getpers("saveposx")), -500000, 5000000, float(self getpers("poschangeby")), "saveposx");
            self add_increment("change y", increment_controls, ::setpersfloat, float(self getpers("saveposy")), -500000, 5000000, float(self getpers("poschangeby")), "saveposy");
            self add_increment("change z", increment_controls, ::setpersfloat, float(self getpers("saveposz")), -500000, 5000000, float(self getpers("poschangeby")), "saveposz");
            self add_increment("change by", increment_controls, ::setpersint, float(self getpers("poschangeby")), 5, 10000, 5, "poschangeby");
        }
        break;
    case "aimbot settings":
        self add_menu(menu);
        self add_pers_toggle("aimbot", undefined, ::aimbot, "aimbot");
        self add_increment("range", increment_controls, ::setpersint, int(self getpers("aimbot_range")), 100, 5000, 100, "aimbot_range");
        self add_array("delay", slider_controls, ::setpersfloat, list("0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1"), "aimbot_delay");
        break;
    case "glitches":
        self add_menu(menu);
        self add_option("switch to equipment", "^5" + self.neura["weapons"][client]["equipment"][0].size + " ^7equipment available", ::new_menu, "equipment");
        break;
    case "equipment":
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client][menu][1][i], "id: ^5" + self.neura["weapons"][client][menu][0][i], ::nacto, self.neura["weapons"][client][menu][0][i]);
        }
        break;
    case "class manager":
        self add_menu(menu);
        self add_increment("class wrap", increment_controls, ::setpersint, float(self getpers("class_wrap")), 1, 10, 1, "class_wrap");
        self add_array("drop weapon", slider_controls, ::drop_util, list("current,secondary,all"));
        self add_array("save & load class", slider_controls, ::class_manager, list("save,load"));
        self add_array("refill ammo", slider_controls, ::refill_my_ammo, list("all weapons,current"));
        self add_option("take weapon", undefined, ::take_current);
        self add_iw8_option("primaries", "primaries for ^5iw8", ::new_menu, "primaries (iw8)");
        self add_iw8_option("secondaries", "secondaries for ^5iw8", ::new_menu, "secondaries (iw8)");
        break;
    case "primaries (iw8)":
        self add_menu(menu);
        self add_option("snipers", "^5" + self.neura["weapons"][client]["primary"]["snipers"][0].size + " ^7weapons available", ::new_menu, "snipers");
        self add_option("shotguns", "^5" + self.neura["weapons"][client]["primary"]["shotguns"][0].size + " ^7weapons available", ::new_menu, "shotguns");
        break;
    case "secondaries (iw8)":
        self add_menu(menu);
        self add_option("launchers", "^5" + self.neura["weapons"][client]["secondary"]["launchers"][0].size + " ^7weapons available", ::new_menu, "launchers");
        self add_option("pistols", "^5" + self.neura["weapons"][client]["secondary"]["pistols"][0].size + " ^7weapons available", ::new_menu, "pistols");
        self add_option("misc", "^5" + self.neura["weapons"][client]["secondary"]["misc"][0].size + " ^7weapons available", ::new_menu, "misc");
        break;
    case "launchers":
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], "id: ^5" + self.neura["weapons"][client]["secondary"][menu][0][i], ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "pistols":
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "misc":
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "snipers":
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "shotguns":
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "game settings":
        self add_menu(menu);
        self add_pers_toggle("clean killcam", "remove some hud elems from kc", ::toggle_clean_kc, "clean_kc");
        self add_pers_toggle("messages", undefined, ::togglepers, "messages");
        self add_array("fake bounces", slider_controls, ::manage_bounce, list("spawn,delete"));
        break;
    case "manage clients":
        self add_menu(menu);
        players = level.players;
        foreach (player in players)
        {
            // party icon for self :3
            if (player ishost())
                player_text = "ߵ " + player get_name();
            else
                player_text = player get_name();

            self add_option(player_text, undefined, ::new_menu, "player option");
        }
        break;
    default:
        self player_index(menu, self.select_player, slider_controls);
        break;
    }
}

player_index(menu, player, slider_controls)
{
    if (!isdefined(player) || !isplayer(player))
        menu = "unassigned";

    switch(menu)
    {
    case "player option":
        self add_menu(player.name);
        self add_option("kill player", undefined, ::kill_player, player);
        self add_option("look at me", undefined, ::look_at_me, player);
        self add_option("give shield", undefined, ::give_player_shield, player);
        self add_array("teleport to", slider_controls, ::manage_teleport, list("me,them,crosshair"), player);
        break;
    case "unassigned":
        self add_menu(menu);
        self add_option("this menu is unassigned");
        break;
    default:
        self add_menu("error");
        self add_option("unable to load " + menu);
        break;
    }
}
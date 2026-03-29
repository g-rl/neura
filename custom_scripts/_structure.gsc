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
    bind_list = list("instaswap,nac,change class,eq,damage");

    switch(menu)
    {
    case "neura":
        self.bind_index = false;
        self add_menu(title + self get_name());
        self add_option("mods & toggles", credits, ::new_menu, "mods & toggles");
        self add_option("glitches", credits, ::new_menu, "glitches");
        self add_option("binds", credits, ::new_menu, "binds");
        self add_option("position", credits, ::new_menu, "position");
        self add_option("class manager", credits, ::new_menu, "class manager");
        self add_option("game settings", credits, ::new_menu, "game settings");
        self add_option("aimbot settings", credits, ::new_menu, "aimbot settings");
        self add_option("client settings", credits, ::new_menu, "manage clients");\
        break;
    case "mods & toggles":
        self.bind_index = false;
        self add_menu(menu);
        self add_pers_toggle("invincibility", undefined, ::toggle_invincibility, "invincible");
        self add_pers_toggle("elevators", undefined, ::toggle_elevators, "elevators");
        self add_pers_toggle("alt swaps", undefined, ::toggle_alt_swaps, "alt_swap");
        self add_pers_toggle("infinite equipment", undefined, ::toggle_inf_eq, "inf_eq");
        self add_pers_toggle("instaswaps", undefined, ::instaswaps, "instaswaps");
        self add_increment("instaswaps time", increment_controls, ::setpersmenu, float(self getpers("instaswaps_time")), 0.1, 1, 0.01, "instaswaps_time");
        self add_pers_toggle("auto prone", undefined, ::autoprone, "autoprone");
        self add_array("auto prone mode", slider_controls, ::setpersmenu, list("air,always"), "autoprone_mode");
        self add_pers_toggle("round end prone", undefined, ::togglepers, "autoprone_endgame", true);
        self add_pers_toggle("auto reload", undefined, ::autoreload, "autoreload");
        self add_pers_toggle("ufo", "toggle noclip - [{+gostand}] + [{+melee}]", ::ufo_mode, "ufo_mode");
        break;
    case "position":
        self.bind_index = false;
        self add_menu(menu);
        self add_array("teleport bots", slider_controls, ::move_bots, list("self,crosshair"));
        self add_pers_toggle("freeze bots", undefined, ::togglepers, "frozen_bots", true);
        self add_option("unstuck", undefined, ::unstuck);
        self add_pers_toggle("save and load binds", undefined, ::toggle_snl, "snl");
        self add_option("save position", undefined, ::save_spawn);
        self add_option("load position", undefined, ::load_spawn);
        self add_option("reset position", undefined, ::reset_position);
        if(float(self getpers("saveposx")) != 0 && float(self getpers("saveposy")) != 0 && float(self getpers("saveposz")) != 0)
        {
            self add_increment("change x", increment_controls, ::setpersmenu, float(self getpers("saveposx")), -500000, 5000000, float(self getpers("poschangeby")), "saveposx");
            self add_increment("change y", increment_controls, ::setpersmenu, float(self getpers("saveposy")), -500000, 5000000, float(self getpers("poschangeby")), "saveposy");
            self add_increment("change z", increment_controls, ::setpersmenu, float(self getpers("saveposz")), -500000, 5000000, float(self getpers("poschangeby")), "saveposz");
            self add_increment("change by", increment_controls, ::setpersmenu, float(self getpers("poschangeby")), 5, 10000, 5, "poschangeby");
        }
        break;
    case "aimbot settings":
        self.bind_index = false;
        self add_menu(menu);
        self add_pers_toggle("aimbot", undefined, ::aimbot, "aimbot");
        self add_increment("range", increment_controls, ::setpersmenu, int(self getpers("aimbot_range")), 100, 5000, 100, "aimbot_range");
        self add_array("delay", slider_controls, ::setpersmenu, list("0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1"), "aimbot_delay");
        break;
    case "glitches":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("one handed gun", undefined, ::one_handed_gun);
        self add_option("switch to equipment", "^5" + self.neura["weapons"][client]["equipment"][0].size + " ^7equipment available", ::new_menu, "equipment");
        break;
    case "binds":
        self.bind_index = true;
        self add_menu(menu);
        foreach (bind in bind_list)
            self add_option(bind, undefined, ::new_menu, bind);
        break;
    case "equipment":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client][menu][1][i], undefined, ::nacto, self.neura["weapons"][client][menu][0][i]);
        }
        break;
    case "equipment bind":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["equipment"][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["equipment"][1][i], undefined, ::setpersmenu, self.neura["weapons"][client]["equipment"][0][i], "eq_weapon");
        }
        break;
    case "class manager":
        self.bind_index = false;
        self add_menu(menu);
        // self add_array("perks", "running ^5" + self.pers["my_perks"].size + " ^7custom perks", ::toggle_perk, self.neura["perks"]);
        self add_option("choose bind equipment", undefined, ::new_menu, "equipment bind");
        self add_increment("class wrap", increment_controls, ::setpersmenu, int(self getpers("class_wrap")), 2, 20, 1, "class_wrap");
        self add_pers_toggle("putaway equipment", undefined, ::togglepers, "eq_putaway", true);
        self add_array("drop weapon", slider_controls, ::drop_util, list("current,secondary,all"));
        self add_array("save & load class", slider_controls, ::class_manager, list("save,load"));
        self add_array("refill ammo", slider_controls, ::refill_my_ammo, list("all weapons,current"));
        self add_option("take weapon", undefined, ::take_current);
        self add_pers_toggle("replace weapon", "replace current when giving weapon", ::togglepers, "replace_weapon", true);
        self add_iw8_option("primaries", "primaries for ^5iw8", ::new_menu, "primaries (iw8)");
        self add_iw8_option("secondaries", "secondaries for ^5iw8", ::new_menu, "secondaries (iw8)");
        break;
    case "primaries (iw8)":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("snipers", "^5" + self.neura["weapons"][client]["primary"]["snipers"][0].size + " ^7weapons available", ::new_menu, "snipers");
        self add_option("shotguns", "^5" + self.neura["weapons"][client]["primary"]["shotguns"][0].size + " ^7weapons available", ::new_menu, "shotguns");
        self add_option("assault rifles", "^5" + self.neura["weapons"][client]["primary"]["assault rifles"][0].size + " ^7weapons available", ::new_menu, "assault rifles");
        self add_option("sub machine guns", "^5" + self.neura["weapons"][client]["primary"]["sub machine guns"][0].size + " ^7weapons available", ::new_menu, "sub machine guns");
        self add_option("light machine guns", "^5" + self.neura["weapons"][client]["primary"]["light machine guns"][0].size + " ^7weapons available", ::new_menu, "light machine guns");
        break;
    case "secondaries (iw8)":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("launchers", "^5" + self.neura["weapons"][client]["secondary"]["launchers"][0].size + " ^7weapons available", ::new_menu, "launchers");
        self add_option("pistols", "^5" + self.neura["weapons"][client]["secondary"]["pistols"][0].size + " ^7weapons available", ::new_menu, "pistols");
        self add_option("misc", "^5" + self.neura["weapons"][client]["secondary"]["misc"][0].size + " ^7weapons available", ::new_menu, "misc");
        break;
    case "launchers":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], "id: ^5" + self.neura["weapons"][client]["secondary"][menu][0][i], ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "pistols":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "misc":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "snipers":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "shotguns":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "assault rifles":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "light machine guns":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "sub machine guns":
        self.bind_index = false;
        self add_menu(menu);
        for(i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "game settings":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("dvars", undefined, ::new_menu, "dvars");
        self add_option("spawn bot", undefined, ::spawnbot);
        self add_toggle("toggle rainbow", undefined, ::rainbow_menu, getdvarint("rainbow"));
        self add_pers_toggle("clean killcam", "remove some hud elems from kc", ::toggle_clean_kc, "clean_kc");
        self add_pers_toggle("messages", undefined, ::togglepers, "messages");
        self add_array("fake bounces", slider_controls, ::manage_bounce, list("spawn,delete"));
        break;
    case "dvars":
        self.bind_index = false;
        self add_menu(menu);
        // add_toggle(text, summary, function, toggle, array, argument_1, argument_2, argument_3)
        self add_dvar_toggle("jump slowdown", undefined, "LNOKTQPLKO");
        self add_dvar_toggle("unlimited sprint", undefined, "MSOOMPMPQS");
        self add_increment("killcam time", increment_controls, ::setdvarmenu, getdvarfloat("scr_killcam_time"), 5, 10, 1, "scr_killcam_time");
        // self add_increment("pad packets", increment_controls, ::setdvarmenu, getdvarfloat("NTNRLNTMRR"), 50, 20000, 50, "NTNRLNTMRR");
        self add_increment("pickup radius", increment_controls, ::setdvarmenu, getdvarfloat("MTOQQKKRPS"), 50, 20000, 50, "MTOQQKKRPS");
        self add_increment("knockback", increment_controls, ::setdvarmenu, getdvarfloat("NSMSTQROLM"), 50, 20000, 50, "NSMSTQROLM");
        break;
    case "manage clients":
        self.bind_index = false;
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
    default: // shitty bind menu solution (but works :3)
        if (is_true(self.bind_index))
            self bind_index(menu, increment_controls);
        else 
            self player_index(menu, self.select_player);
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
        self add_option("change team", undefined, ::change_player_team, player);
        self add_array("teleport to", slider_controls, ::manage_teleport, list("me,them,crosshair"), player);
        if (isai(player) || isbot(player))
        {
            self add_option("look at me", undefined, ::look_at_me, player);
            self add_option("give shield", undefined, ::give_player_shield, player);
            self add_option("set current weapon", "will set to: ^5" + self getcurrentweapon().basename, ::set_bot_weapon, player, self getcurrentweapon());
        }
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

bind_index(menu, increment_controls) 
{
    if (!isdefined(menu))
        menu = "unassigned";

    switch(menu) 
    {
        case "instaswap":
            self add_bind(menu, ::toggle_instaswap_bind, "instaswap");
            break;
        case "nac":
            self add_bind(menu, ::toggle_nac_bind, "nac");
            break;
        case "change class":
            self add_bind(menu, ::toggle_class_bind, "class");
            break;
        case "eq":
            self add_bind(menu, ::toggle_eq_bind, "eq");
            break;
        case "damage":
            self add_bind(menu, ::toggle_damage_bind, "damage");
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
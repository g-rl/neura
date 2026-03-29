// gsclsp-disable semicolon

/*
        neura menu for IW8 (MW2019), S4 (Vanguard), and IW9 (MW2022) 
        - #ifdef IW8 does not work properly, use #ifdef S4 instead 

        by ethan (@nyli2b) & mikey (@mjkzys)
*/

#include custom_scripts\_func;
#include custom_scripts\_util;

init()
{
#ifdef S4
    level._client = "s4";
#else
    level._client = "iw8";
#endif
    level.is_setup = false;
    level.is_debug = true;
    
    // functions
    level thread on_player_connect();
    level thread setup_dvars();
}

on_player_connect()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);

        if (isai(player) || isbot(player))
            player thread on_bot_spawned();
        else
            player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self endon("disconnect");
    level endon("game_ended");

    self.has_spawned = false;

    for (;;)
    {
        self waittill("spawned_player");

        self setpersifuni("saveposx", 0);
        self setpersifuni("saveposy", 0);
        self setpersifuni("saveposz", 0);

        // give this stuff every spawn
        // can we make it so we reload position after death though here? cried every time i tried -et
        self thread reload_position();
        self thread give_perks();

        if (self.has_spawned)
            continue;

        self.neura = [];
        self.has_spawned = true;
        
        self thread watch_memory();
        self thread watch_freeze_controls();
        self thread allow_oob(); // out of bounds
        self thread remove_barriers();

        if (!isdefined(self.menu))
            self.menu = [];

        if (!isdefined(self.menu_init))
        {
            self custom_scripts\_menu::initial_variable();
            self thread custom_scripts\_menu::initial_monitor();
            self thread monitor_buttons();
            self.menu_init = true;
        }

        self thread pause_timer_cooldown_bypass();
        self thread post_prematch_start();

        // other funcs
        self thread monitor_class();
        self thread round_manager();
        // self thread watch_weap_change();
    }
}

setup_dvars()
{
    setdvarifuninitialized("scr_killcam_time", 5);
    setdvar("MSOOMPMPQS", true); // unlimited sprint (iw8 only i think?)
    setdvar("LNOKTQPLKO", false); // jump slowdown
    level.bots_disable_team_switching = 1;
    level notify("bot_connect_monitor");
    level.pausing_bot_connect_monitor = 1;
    level notify("bot_monitor_team_limits");
}

on_bot_spawned()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("spawned_player");

        // self setpersifuni("bot_weapon", "iw8_sn_alpha50_mp+back_alpha50+barlong_alpha50+gunperk_fastmelee+mag_alpha50+pistolgrip02_alpha50+rec_alpha50+snprscope_alpha50");
        self setpersifuni("saveposx", 0);
        self setpersifuni("saveposy", 0);
        self setpersifuni("saveposz", 0);
        // self setpersifuni("replace_weapon", true);
        self thread reload_position();
        // weapon = self getpers("bot_weapon");
        // self giveweapon(weapon);
        // self setspawnweapon(weapon);
    }
}

watch_memory()
{
    camos = ["camo_11c", "camo_11d", "camo_11a", "camo_11b"];
    camo = camos[randomint(camos.size)];

    setdvarifuninitialized("rainbow", 1);

    self setpers("lives", 99);
    self setpersifuni("camo", camo);
    self setpersifuni("unstuck", self.origin);
    self setpersifuni("velx", 250);
    self setpersifuni("vely", 250);
    self setpersifuni("velz", 250);
    self setpersifuni("boltcount", "0");
    self setpersifuni("boltspeed", "1.2");
    self setpersifuni("class_wrap", "5");
    self setpersifuni("class_can", true);
    self setpersifuni("soh", true);
    self setpersifuni("eq_weapon", "c4_mp_p");
    self setpersifuni("eq_putaway", false);
    self setpersifuni("ufo_mode", true);
    self setpersifuni("timescale", false);
    self setpersifuni("instaswaps_time", 0.19);
    self setpersifuni("aimbot_range", 1200);
    self setpersifuni("aimbot_delay", 0);
    self setpersifuni("saveposx", 0);
    self setpersifuni("saveposy", 0);
    self setpersifuni("saveposz", 0);
    self setpersifuni("poschangeby", 10);
    self setpersifuni("inf_eq", false);
    self setpersifuni("clean_kc", true);
    self setpersifuni("snl", true);
    self setpersifuni("autoprone_endgame", true);
    self setpersifuni("autoprone_mode", "air");
    self setpersifuni("frozen_bots", true);
    self setpersifuni("messages", true);
    self setpersifuni("invincible", true);
    self setpersifuni("autoreload", false);
    self setpersifuni("autoprone", false);
    self setpersifuni("aimbot", false);
    self setpersifuni("elevators", false);
    self setpersifuni("alt_swap", false);
    self setpersifuni("replace_weapon", false);
    self setpersifuni("saved_class", false);
    self setpersifuni("velocitychangeby", 50);
    self setpersifuni("real_scavenger", true);
    self setpersifuni("headbounces", false);

    for (i=1;i<8;i++)
    {
        self setpersifuni("boltpos" + i, "0");
        wait 0.05;
    }

    self setpersifuni("bouncecount", "0");
    for (i = 1; i < 8; i++)
    {

        self setpersifuni("bouncepos" + i, "0");
        wait 0.05;
    }

    if (int(self getpers("bouncecount")) >= 1)
    {
        self notify("stop_bounce_loop");
        self thread monitor_bounces();
        self iprintln("^5" + int(self getpers("bouncecount")) + "^7 bounces reloaded");
    }

    self loadpers("autoprone", ::do_auto_prone);
    self loadpers("autoreload", ::do_auto_reload);
    self loadpers("instaswaps", ::do_instaswaps);
    self loadpers("aimbot", ::do_aimbot);
    self loadpers("ufo_mode", ::reload_ufo);
    self loadpers("snl", ::setup_snl);
    self loadpers("inf_eq", ::unlimited_eq);
    self loadpers("clean_kc", ::clean_killcam);
    self loadpers("invincible", ::godmode_loop);
    self loadpers("saved_class", ::reload_class);
    self loadpers("elevators", ::elevators);
    self loadpers("alt_swap", ::reload_alt_swap);
    self loadpers("headbounces", ::headbounces);

    self setup_bind("instaswap", false, ::do_instaswap_bind);
    self setup_bind("nac", false, ::do_nac_bind);
    self setup_bind("class", false, ::reload_class_bind);
    self setup_bind("eq", false, ::do_eq_bind);
    self setup_bind("damage", false, ::do_damage_bind);
    self setup_bind("illusion", false, ::do_illusion_bind);
    self setup_bind("stuck", false, ::do_stuck_bind);
    self setup_bind("spectator", false, ::do_spectator_bind);
    self setup_bind("scavenger", false, ::do_scavenger_bind);
    self setup_bind("bolt", false, ::do_bolt_bind);
    self setup_bind("velocity", false, ::do_velocity_bind);
    self setup_bind("canswap", false, ::do_canswap_bind);
}
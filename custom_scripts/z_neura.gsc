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
    print("playing on: " + level._client);
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

        // give this stuff every spawn
        self thread give_perks();

        if (self.has_spawned)
            continue;

        self.neura = [];
        self.has_spawned = true;
        self.godmode_active = true;
        
        self thread watch_memory();
        self thread watch_freeze_controls();
        
        self thread do_nac_bind();
        self thread do_instaswap_bind();

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
        self thread watch_weap_change();
    }
}

setup_dvars()
{
    setdvarifuninitialized("scr_killcam_time", 5);
    setdvar("MSOOMPMPQS", true); // unlimited sprint
}

on_bot_spawned()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("spawned_player");
        waittill_prematch_over();
        self thread reload_position();
    }
}

watch_memory()
{
    //waittill_prematch_over();

    self setpers("lives", 99);

    camos = ["camo_11c", "camo_11d", "camo_11a", "camo_11b"];
    camo = camos[randomint(camos.size)];
    self setpersifuni("camo", "camo_11b");
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
    self setpersifuni("inf_eq", true);
    self setpersifuni("clean_kc", true);
    self setpersifuni("snl", true);
    self setpersifuni("autoprone_endgame", true);
    self setpersifuni("autoprone_mode", "air");
    self setpersifuni("frozen_bots", true);
    self setpersifuni("messages", true);
    self setpersifuni("invincible", true);

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
        self iprintln("ߝ [game] * ^+ " + self getpers("bouncecount") + "^7 bounces reloaded");
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
    // self loadpers("no_hud", ::watch_hud);
    // self loadpers("nac_bind", ::do_nac_bind, self getpers("nac_slot"));
    // self loadpers("instaswap_bind", ::do_instaswap_bind, self getpers("is_slot"));

    //self loadpers("always_canswap", ::do_always_canswap);
    //self loadpers("refill_bind", ::do_refill_bind);
    //self loadpers("bounce_bind", ::do_bounce_bind, self getpers("bounce_slot"));
    //self loadpers("bolt_movement_bind", ::do_bolt_movement_bind, self getpers("bolt_slot"));
    // self loadpers("class_bind", ::do_class_bind, self getpers("class_slot"));
    //self loadpers("velocity_bind", ::do_velocity_bind, self getpers("vel_slot"));
    //self loadpers("damage_bind", ::do_damage_bind, self getpers("damage_slot"));
    //self loadpers("eq_bind", ::do_eq_bind, self getpers("eq_slot"));
}
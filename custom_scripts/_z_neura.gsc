// gsclsp-disable semicolon

/*
        neura menu for IW8 (MW2019), S4 (Vanguard), and IW9 (MW2022) 
        by ethan (@nyli2b) & mikey (@mjkzys)
*/

#include custom_scripts\_z_func;
#include custom_scripts\_util;

init()
{
#ifdef S4
    level._client = "s4";
#elifdef IW9
    level._client = "iw9";
#else
    level._client = "iw8"; // this is for 1.20, this will be updated later to use the macro later properly maybe?
#endif

    level.is_debug = true;
    // functions
    level thread on_player_connect();
    level thread setup_dvars();

    // damage debugging stuff don't uncomment
    // level.callbackPlayerDamage_og = level.callbackPlayerDamage;
    // level.callbackPlayerDamage = ::callbackplayerdamage_stub;
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
        // self thread watch_weap_change(); - get full weapon names
        // self thread give_perks();
        self thread reload_position();

        if (self.has_spawned)
            continue;

        self.neura = [];
        self.has_spawned = true;
        
        self thread watch_memory();
        self thread watch_frozen_bots();

        if (!isdefined(self.menu))
            self.menu = [];

        if (!isdefined(self.menu_init))
        {
            self custom_scripts\_z_menu::initial_variable();
            self thread custom_scripts\_z_menu::initial_monitor();
            self thread monitor_buttons();
            self.menu_init = true;
        }

        // look into this and find a solution to remove timer thats not janky asf -et
        self thread pause_timer_cooldown_bypass();
        self thread post_prematch_start();

        // other funcs
        self thread monitor_class();
        self thread give_streak(); // give back saved streak if any
    }
}

setup_dvars()
{
    setdvarifuninitialized("scr_killcam_time", 5);

    // only tested these on iw8 so not too sure if they're the same on others -et
    setdvar("MSOOMPMPQS", true); // unlimited sprint
    setdvar("LNOKTQPLKO", false); // jump slowdown

    // these still don't stop bots from being auto kicked due to team balance
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
        self thread reload_position();
    }
}

watch_memory()
{
    camos = ["camo_11c", "camo_11d", "camo_11a", "camo_11b"]; // unused for now, camos menu & setcamo stuff tho? -et
    camo = camos[randomint(camos.size)];

    setdvarifuninitialized("rainbow", 1);

    // engine dvars
    setdvarifuninitialized("pan_instashoots", 0);
    setdvarifuninitialized("pan_alwayscanswap", 0);
    setdvarifuninitialized("pan_sprintswaps", 0);
    setdvarifuninitialized("pan_freezeanim", 0);
    setdvarifuninitialized("pan_alwaysaltswap", 0);
    setdvarifuninitialized("pan_canzooms", 0);

    self setpers("lives", 99);
    self setpers_if_uninitialized("camo", camo);
    self setpers_if_uninitialized("unstuck", self.origin);
    self setpers_if_uninitialized("velx", 250);
    self setpers_if_uninitialized("vely", 250);
    self setpers_if_uninitialized("velz", 250);
    self setpers_if_uninitialized("class_wrap", "5");
    self setpers_if_uninitialized("class_can", true);
    self setpers_if_uninitialized("soh", true);
    self setpers_if_uninitialized("eq_weapon", "c4_mp_p");
    self setpers_if_uninitialized("eq_putaway", false);
    self setpers_if_uninitialized("ufo_mode", true);
    self setpers_if_uninitialized("timescale", false);
    self setpers_if_uninitialized("instaswaps_time", 0.3);
    self setpers_if_uninitialized("aimbot_range", 1200);
    self setpers_if_uninitialized("aimbot_delay", 0);
    self setpers_if_uninitialized("saveposx", 0);
    self setpers_if_uninitialized("saveposy", 0);
    self setpers_if_uninitialized("saveposz", 0);
    self setpers_if_uninitialized("poschangeby", 10);
    self setpers_if_uninitialized("inf_eq", false);
    self setpers_if_uninitialized("clean_kc", true);
    self setpers_if_uninitialized("snl", true);
    self setpers_if_uninitialized("autoprone_endgame", true);
    self setpers_if_uninitialized("autoprone_mode", "air");
    self setpers_if_uninitialized("frozen_bots", true);
    self setpers_if_uninitialized("messages", true);
    self setpers_if_uninitialized("sounds", true);
    self setpers_if_uninitialized("invincible", true);
    self setpers_if_uninitialized("autoreload", false);
    self setpers_if_uninitialized("autoprone", false);
    self setpers_if_uninitialized("instaswaps", false);
    self setpers_if_uninitialized("aimbot", false);
    self setpers_if_uninitialized("elevators", false);
    self setpers_if_uninitialized("alt_swap", false);
    self setpers_if_uninitialized("replace_weapon", true);
    self setpers_if_uninitialized("saved_class", false);
    self setpers_if_uninitialized("velocitychangeby", 50);
    self setpers_if_uninitialized("real_scavenger", true);
    self setpers_if_uninitialized("headbounces", false);
    self setpers_if_uninitialized("stuck_weapon", "semtex");
    self setpers_if_uninitialized("oob", true);
    self setpers_if_uninitialized("barriers", true);
    self setpers_if_uninitialized("ks_auto_use", false);
    self setpers_if_uninitialized("saved_streak", "none");
    self setpers_if_uninitialized("reload_streaks", false);
    self setpers_if_uninitialized("damage_amount", 50);
    self setpers_if_uninitialized("flash_amount", 3);
    self setpers_if_uninitialized("shellshock_type", "frag_grenade_mp");
    self setpers_if_uninitialized("shellshock_amount", 0.22);

    self setpers_if_uninitialized("boltcount", "0");
    self setpers_if_uninitialized("boltspeed", "1.2");
    for (i = 1; i < 8; i++)
    {
        self setpers_if_uninitialized("boltpos" + i, "0");
        wait 0.05;
    }

    self setpers_if_uninitialized("bot_boltcount", "0");
    self setpers_if_uninitialized("bot_boltspeed", "1.2");
    for (i = 1; i < 8; i++)
    {
        self setpers_if_uninitialized("bot_boltpos" + i, "0");
        wait 0.05;
    }

    self setpers_if_uninitialized("bouncecount", "0");
    for (i = 1; i < 8; i++)
    {
        self setpers_if_uninitialized("bouncepos" + i, "0");
        wait 0.05;
    }

    if (int(self getpers("bouncecount")) >= 1)
    {
        self notify("stop_bounce_loop");
        self thread monitor_bounces();
        self iprintln("^5" + int(self getpers("bouncecount")) + "^7 bounces reloaded");
    }

    // reload persistence & binds
    self loadpers("autoprone", ::do_auto_prone);
    self loadpers("autoreload", ::do_auto_reload);
    self loadpers("instaswaps", ::do_instaswaps);
    self loadpers("aimbot", ::do_aimbot);
    self loadpers("ufo_mode", ::reload_ufo);
    self loadpers("snl", ::setup_snl);
    self loadpers("inf_eq", ::unlimited_eq);
    self loadpers("clean_kc", ::clean_killcam);
    self loadpers("invincible", ::godmode_loop);
    // self loadpers("saved_class", ::reload_class);
    self loadpers("elevators", ::elevators);
    self loadpers("alt_swap", ::reload_alt_swap);
    self loadpers("headbounces", ::headbounces);
    self loadpers("oob", ::disable_oob);
    self loadpers("barriers", ::remove_barriers); 

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
    self setup_bind("bot_bolt", false, ::do_bot_bolt_bind);
    self setup_bind("velocity", false, ::do_velocity_bind);
    self setup_bind("canswap", false, ::do_canswap_bind);
    self setup_bind("empty_clip", false, ::do_emptyclip_bind);
    self setup_bind("one_bullet", false, ::do_onebullet_bind);
    self setup_bind("freeze_anim", false, ::do_freeze_anim_bind);
    self setup_bind("shellshock", false, ::do_shellshock_bind); 
    self setup_bind("load_class", false, ::do_load_class_bind); 
}

// this was used to debug IW9, and can be used for S4 too
/*
callbackplayerdamage_stub( einflictor, eattacker, idamage, idflags, smeansofdeath, _id_D7BC24CD73DFC712, objweapon, vpoint, vdir, shitloc, psoffsettime, modelindex, partname, _id_B0FC59FF15058522, _id_BE4285B26ED99AB1 )
{
    iprintln("========================");
    iprintln("einflictor",  einflictor.name);
    iprintln("eattacker",  eattacker.name);
    iprintln("idamage",  idamage);
    iprintln("idflags",  idflags);
    iprintln("smeansofdeath",  smeansofdeath);
    iprintln("_id_D7BC24CD73DFC712",  _id_D7BC24CD73DFC712);
    iprintln("objweapon",  objweapon.basename);
    iprintln("vpoint",  vpoint );
    iprintln("vdir",  vdir );
    iprintln("shitloc",  shitloc);
    iprintln("psoffsettime",  psoffsettime);
    iprintln("modelindex",  modelindex);
    iprintln("partname",  partname);
    iprintln("_id_B0FC59FF15058522",  _id_B0FC59FF15058522);
    iprintln("_id_BE4285B26ED99AB1",  _id_BE4285B26ED99AB1);
    iprintln("========================");
    [[level.callbackplayerdamage_og]](einflictor, eattacker, idamage, idflags, smeansofdeath, _id_D7BC24CD73DFC712, objweapon, vpoint, vdir, shitloc, psoffsettime, modelindex, partname, _id_B0FC59FF15058522, _id_BE4285B26ED99AB1);
}
*/
/*
        neura menu for IW8 (MW2019), S4 (Vanguard), and IW9 (MW2022) 
        by ethan (@nyli2b) & mikey (@mjkzys)
*/

#include custom_scripts\_z_func;
#include custom_scripts\_util;

// TODO: temporary, to handle dvars, regardless of hash or not
#ifdef IW9
#define DVAR_(name) @ name
#else
#define DVAR_(name) name
#endif

init()
{
#ifdef S4
    level._client = "s4";
#elifdef IW9
    level._client = "iw9";
#else
    level._client = "iw8";
#endif
    level._client_version = getdvar(DVAR_("build_version"), "1.0.0"); // build_version_full can be used for more in depth checks

    level.is_debug = false;
    level.session_data = [];

    // functions
    level thread on_player_connect();
    level thread setup_dvars();
    level thread preset_positions();

    init_camera();

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

    self setup_watch_memory();

    // wait for setup watch memory to be done, and then run load session
    // self thread load_session();

    for (;;)
    {
        self waittill("spawned_player");
        
        self thread reload_position();
        self thread custom_scripts\_z_menu::close_menu_on_death();

        if (self.has_spawned) 
            continue;

        self.neura = [];
        self.has_spawned = true;
        self.round_has_ended = 0;
        origin = self getpers("platform_origin");

        self thread watch_memory();
        self thread watch_frozen_bots();
        self thread watch_freeze_anim();
        self thread watch_round_end();
        self thread handle_camo();

        if (self getpers("slow_motion") != 1.0)
            self thread reload_timescale();

        if (isdefined(origin) && isvector(origin))
            self thread reload_platform();

        if (!isdefined(self.menu))
            self.menu = [];

        if (!isdefined(self.menu_init))
        {
            self custom_scripts\_z_menu::initial_variable();
            self thread custom_scripts\_z_menu::initial_monitor();
            self thread monitor_buttons();
            self.menu_init = true;
        }

        self thread skip_final_killcam();
        self thread wait_for_round_end();
        self thread post_prematch_start();
        self thread handle_camo();
        self thread monitor_class();
        self thread clear_prematch_look();

        // return any streaks to player last (if saved)
        saved = self custom_scripts\_util::getpers("saved_streak");
        if (isdefined(saved) && saved != "none")
            self thread give_streak(saved);
    }
}

setup_dvars()
{
    setdvarifuninitialized(DVAR_("scr_killcam_time"), 5);

    // these still don't stop bots from being auto kicked due to team balance
    // edit: please look at this do we need a bot patch or something?? -ethan

    level.bots_disable_team_switching = 1;
    level notify("bot_connect_monitor");
    level.pausing_bot_connect_monitor = 1;
    level notify("bot_monitor_team_limits");
}

on_bot_spawned() // we setup bot loadouts, positions etc here
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("spawned_player");
        self thread custom_scripts\_z_func::neura_bots(); // calling direcly to be safe
    }
}

setup_watch_memory()
{
    self.pers["pers"] = 0;

    switch (level._client)
    {
        case "iw8":
            self.effect_list = ["claymore_explode", "nuke_rolling_death", "equipment_sparks"]; // so many don't work :(
            self.sound_list = ["weap_ammo_pickup"];
            break;
        case "iw9":
            self.effect_list = ["claymore_explode", "420_death", "youveBeenNaughty_limb", "youveBeenNaughty_torso", "youveBeenNaughty_head", "youveBeenNice_limb", "youveBeenNice_torso", "youveBeenNice_head", "vDay_limb", "vDay_torso", "vDay_head", "bCell_limb", "bCell_torso", "bCell_head", "bCell_nogore_limb", "bCell_nogore_torso", "bCell_nogore_head", "paddy_limb", "paddy_torso", "paddy_head", "easter_limb", "easter_torso", "easter_head", "easter_nogore_limb", "easter_nogore_torso", "easter_nogore_head", "scifi_limb", "scifi_torso", "scifi_head", "scifi_origin", "scifi2_limb", "scifi2_torso", "scifi2_head", "scifi2_origin", "scifi3_limb", "scifi3_torso", "scifi3_head", "scifi3_origin", "hitscan", "thor", "thor_chest", "soulEater_limb", "soulEater_torso", "soulEater_head", "soulEater_death", "crash_limb", "crash_torso", "crash_head", "cthulhu_limb", "cthulhu_torso", "cthulhu_head", "cthulhu_nogore_limb", "cthulhu_nogore_torso", "cthulhu_nogore_head", "akihabara_fatal", "hlander_limb", "hlander_torso", "hlander_head", "hlander_nogore_limb", "hlander_nogore_torso", "hlander_nogore_head", "nicki_limb", "nicki_torso", "nicki_head", "ice_limb", "ice_torso", "ice_head", "ice_nogore_limb", "ice_nogore_torso", "tomb_limb", "tomb_torso", "tomb_head", "tomb_limb_nogore", "tomb_torso_nogore", "tomb_head_nogore", "hips_limb", "hips_torso", "hips_head", "hops_limb", "hops_torso", "hops_head", "maze_limb", "maze_torso", "maze_head", "maze_nogore_limb", "maze_nogore_torso", "maze_nogore_head", "bcell6_limb", "bcell6_torso", "bcell6_head", "lilith", "inarius", "witch", "zombie"];
            self.sound_list = ["weap_ammo_pickup", "iw9_support_box_use", "iw9_ks_tablet_ui_screen_plr"];
            break;
        default:
            self.effect_list = ["claymore_explode"]; // pretty much every game should have this
            self.sound_list = ["weap_ammo_pickup"];
            break;
    }

    setdvarifuninitialized(DVAR_("rainbow"), 1);

    // engine dvars
    setdvarifuninitialized(DVAR_("pan_instashoots"), 1);
    setdvarifuninitialized(DVAR_("pan_alwayscanswap"), 0);
    setdvarifuninitialized(DVAR_("pan_sprintswaps"), 0);
    setdvarifuninitialized(DVAR_("pan_freezeanim"), 0);
    setdvarifuninitialized(DVAR_("pan_alwaysaltswap"), 0);
    setdvarifuninitialized(DVAR_("pan_canzooms"), 0);

    // only tested these on iw8 so not too sure if they're the same on others -et
#ifdef IW9
    setdvar(DVAR_("r_mbEnable"), 0); // remove all motion blur
    setdvar(DVAR_("camera_thirdPerson"), 0); // disable third person just in case
    setdvar(DVAR_("jump_slowdownEnable"), 0); // jump slowdown
#else
    setdvar("LPSPNKLRPO", 0); // remove all motion blur
    setdvar("NOSLRNTRKL", 0); // disable third person just in case
    setdvar("MSOOMPMPQS", 1); // unlimited sprint
    setdvar("LNOKTQPLKO", 0); // jump slowdown
#endif

    setdvar(DVAR_("lfx_showDebugOverlay"), 1);
    setdvar(DVAR_("lfx_showDebugOverlay"), 0);
    
    // add change save & load binds
    self setpers_if_uninitialized("snl", true);
    self setpers_if_uninitialized("saveposx", 0);
    self setpers_if_uninitialized("saveposy", 0);
    self setpers_if_uninitialized("saveposz", 0);
    self setpers_if_uninitialized("poschangeby", 10);

    self setpers_if_uninitialized("velocitychangeby", 50);
    self setpers_if_uninitialized("velx", 250);
    self setpers_if_uninitialized("vely", 250);
    self setpers_if_uninitialized("velz", 250);

    self setpers_if_uninitialized("class_wrap", "5");
    self setpers_if_uninitialized("class_can", true);
    self setpers_if_uninitialized("ccb_always_can", true);
    self setpers_if_uninitialized("ccb_empty_clip", false);
    self setpers_if_uninitialized("ccb_one_bullet_out", true);
    self setpers_if_uninitialized("ccb_one_bullet_left", false);
    self setpers_if_uninitialized("ccb_illusion", false);

    self setpers_if_uninitialized("eq_weapon", "c4_mp_p");
    self setpers_if_uninitialized("eq_putaway", false);
    self setpers_if_uninitialized("eq_putaway_time", 0.05);

    self setpers_if_uninitialized("aimbot", true);
    self setpers_if_uninitialized("aimbot_range", 1500);
    self setpers_if_uninitialized("aimbot_delay", 0);
    self setpers_if_uninitialized("kill_effects", false);
    self setpers_if_uninitialized("kill_effect", self.effect_list[randomint(self.effect_list.size)]);
    self setpers_if_uninitialized("kill_sounds", false);
    self setpers_if_uninitialized("kill_sound", self.sound_list[randomint(self.sound_list.size)]);
    self setpers_if_uninitialized("wave_effects", false);
    self setpers_if_uninitialized("tracer_rounds", false);
    self setpers_if_uninitialized("tracer_effect", self.effect_list[randomint(self.effect_list.size)]);
    self setpers_if_uninitialized("use_tracer_waves", true);

    for (i = 1; i < 4; i++)
    {
        self setpers_if_uninitialized("wave_effect_" + i, self.effect_list[randomint(self.effect_list.size)]);
    }

    for (i = 1; i < 4; i++)
    {
        self setpers_if_uninitialized("tracer_effect_" + i, self.effect_list[randomint(self.effect_list.size)]);
    }

    self setpers_if_uninitialized("soh", true);
    self setpers_if_uninitialized("ufo_mode", true);
    self setpers_if_uninitialized("invincible", true);
    self setpers_if_uninitialized("unlimited_lives", true);
    self setpers_if_uninitialized("instaswaps", false);
    self setpers_if_uninitialized("instaswaps_time", 0.3);
    self setpers_if_uninitialized("autoreload", false);
    self setpers_if_uninitialized("autoprone", false);
    self setpers_if_uninitialized("autoprone_endgame", true);
    self setpers_if_uninitialized("autoprone_mode", "air");
    self setpers_if_uninitialized("elevators", false);
    self setpers_if_uninitialized("alt_swap", false);
    self setpers_if_uninitialized("headbounces", false);
    self setpers_if_uninitialized("always_nac", false);

    // todo: hide field upgrades
    self setpers_if_uninitialized("clean_kc", true);
    self setpers_if_uninitialized("hide_itemtype", true);
    self setpers_if_uninitialized("hide_victim", false);
    self setpers_if_uninitialized("hide_perks", true);
    self setpers_if_uninitialized("hide_attachments", true);

    // game
    self setpers_if_uninitialized("welcome_message", false);
    self setpers_if_uninitialized("random_rounds", true);
    self setpers_if_uninitialized("auto_pause_timer", true);
    self setpers_if_uninitialized("randomize_timer_pause", true);
    self setpers_if_uninitialized("pause_timer_after", 120);
    self setpers_if_uninitialized("slow_motion", 1.0);
    self setpers_if_uninitialized("slow_motion_mode", "round end");
    self setpers_if_uninitialized("oob", true);
    self setpers_if_uninitialized("barriers", true);
    self setpers_if_uninitialized("messages", true);
    self setpers_if_uninitialized("sounds", true);
    self setpers_if_uninitialized("no_hud", false);
    self setpers_if_uninitialized("menu_lock", false);

    self setpers_if_uninitialized("camera_rotation", 1);
    self setpers_if_uninitialized("camera_mode", "bezier");
    self setpers_if_uninitialized("camera_get_start_type", "speed");
    self setpers_if_uninitialized("camera_bezier_speed", 3);
    self setpers_if_uninitialized("camera_linear_time", 10);
    self setpers_if_uninitialized("nodecount", "0");

    self setpers_if_uninitialized("dead_silence_auto", true);
    self setpers_if_uninitialized("repeater_illusion", false);
    self setpers_if_uninitialized("unlink_after_bar", true);
    self setpers_if_uninitialized("real_scavenger", true);
    self setpers_if_uninitialized("damage_amount", 50);
    self setpers_if_uninitialized("flash_amount", 0.25);
    self setpers_if_uninitialized("shellshock_amount", 0.22);
    self setpers_if_uninitialized("spectate_time", 0.1);
    self setpers_if_uninitialized("dead_silence_time", 5);
    self setpers_if_uninitialized("stuck_weapon", "semtex");
    self setpers_if_uninitialized("shellshock_type", "frag_grenade_mp");

    self setpers_if_uninitialized("reload_streaks", false);
    self setpers_if_uninitialized("saved_streak", "none");

    self setpers_if_uninitialized("replace_weapon", true);
    self setpers_if_uninitialized("saved_class", false);
    self setpers_if_uninitialized("enemy_saved_class", false);
    self setpers_if_uninitialized("camo", "none");
    self setpers_if_uninitialized("last_camo", "none");
    self setpers_if_uninitialized("camo_wait", true);
    self setpers_if_uninitialized("inf_eq", true);

    self setpers_if_uninitialized("has_selected_bot", false);
    self setpers_if_uninitialized("selected_bot", false);
    self setpers_if_uninitialized("frozen_bots", true);

    self setpers_if_uninitialized("modelcount", "0");
    self setpers_if_uninitialized("bj_speed", 1.3);

    self setpers_if_uninitialized("platform_origin", false);
    self setpers_if_uninitialized("platform_clip", "clip32x32x32");

    // player bolt movement
    self setpers_if_uninitialized("boltcount", "0");
    self setpers_if_uninitialized("boltspeed", "1.2");
    for (i = 1; i < 8; i++)
    {
        self setpers_if_uninitialized("boltpos" + i, "0");
    }

    // bot bolt movement
    self setpers_if_uninitialized("bot_boltcount", "0");
    self setpers_if_uninitialized("bot_boltspeed", "1.2");
    for (i = 1; i < 8; i++)
    {
        self setpers_if_uninitialized("bot_boltpos" + i, "0");
    }

    // record movement
    self setpers_if_uninitialized("recordmovementcount", "0");
    for (i=1; i < 20; i++)
    {
        self setpers_if_uninitialized("recordmovementpos" + i, "0");
    }

    // paths
    self setpers_if_uninitialized("pathpos", "0");
    for (i = 1; i < 8; i++)
    {
        self setpers_if_uninitialized("pathpos" + i, "0");
    }
    self setpers_if_uninitialized("pathcount", "0");

    // bounces
    self setpers_if_uninitialized("bouncecount", "0");
    for (i = 1; i < 8; i++)
    {
        self setpers_if_uninitialized("bouncepos" + i, "0");
    }

    if (self.pers["pers"] > 0)
        self iprintln("^:" + self.pers["pers"] + " ^7things loaded..");
}

watch_memory()
{
    if (int(self getpers("bouncecount")) >= 1) 
    {
        self notify("stop_bounce_loop");
        self thread monitor_bounces();
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
    self loadpers("always_nac", ::do_always_nac); 
    self loadpers("random_rounds", ::always_random_rounds);
    self loadpers("auto_pause_timer", ::auto_pause_timer);
    self loadpers("no_hud", ::watch_hud);
    self loadpers("unlimited_lives", ::set_lives);
    self loadpers("menu_lock", ::watch_for_unlock);
    self loadpers("enemy_saved_class", ::load_enemy_class);
    self loadpers("tracer_rounds", ::tracer_rounds);

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
    self setup_bind("flash", false, ::do_flash_bind); 
    self setup_bind("third_person", false, ::do_third_person_bind); 
    self setup_bind("record_movement", false, ::do_record_movement_bind); 
    self setup_bind("reverse_ele", false, ::do_reverse_ele_bind); 
    self setup_bind("kill_bot", false, ::do_kill_bot_bind); 
    self setup_bind("spectate_repeater", false, ::do_spectate_repeater_bind); 
    self setup_bind("spectate_damage_repeater", false, ::do_spectate_damage_repeater_bind); 
    self setup_bind("bounce", false, ::do_bounce_bind); 
    self setup_bind("hitmarker", false, ::do_hitmarker_bind); 
    self setup_bind("start_camera", false, ::do_cinematic_bind); 
    self setup_bind("stall", false, ::do_stall_bind); 
    self setup_bind("dead_silence", false, ::do_dead_silence_bind); 
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

init_camera()
{
    models = ["axis_guide_createfx", "misc_wm_flarestick", "tag_origin"];
    foreach (model in models)
        precachemodel(model);

    level.camera = [];
    level.camera["origin"] = [];
    level.camera["orgpath"] = [];
    level.camera["angles"] = [];
    level.camera["obj"] = [];
    level.camera["path"] = [];
    level.camera["count"] = 0;
    level.camera["type"] = "bezier";
    level.camera["active_cam"] = undefined;
    level.camera["running"] = false;
    level.disablespawncamera = 1;
}
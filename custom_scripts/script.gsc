// gsclsp-disable semicolon

init()
{
    // variables
    level.is_setup = false;
    level.is_debug = true;
    
    // functions
    level thread on_player_connect();
    level thread setup_dvars();
}

setup_dvars()
{
    // player
    setdvarifuninitialized("nvg", 0);
    setdvarifuninitialized("oob", 1);
    setdvarifuninitialized("barriers", 1);
    setdvarifuninitialized("godmode", 1);

    // specials
    setdvarifuninitialized("give_streak", "");
    setdvarifuninitialized("ks_auto_activate", 0);

    // custom
    setdvarifuninitialized("instaswaps_time", 0.19);
    setdvarifuninitialized("autoprone_mode", "air");
    setdvarifuninitialized("autoprone_endgame", 1);
    setdvarifuninitialized("aimbot_range", 1200);
    setdvarifuninitialized("scr_killcam_time", 5);
    setdvarifuninitialized("slomo", 1);
    setdvarifuninitialized("killcam_elems", 1);

    setdvarifuninitialized("giveweapon", "");
    setdvarifuninitialized("camo", "");

    setdvar("MSOOMPMPQS", true); // unlimited sprint
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

        //
        self thread watch_commands();
        //self thread watch_notify();
        self thread watch_memory();
        self thread monitor_dvars();
        self thread unlimited_eq();
        self thread round_manager();
        self thread clean_killcam();
        //self thread create_notify();

        if (!isdefined(self.menu))
            self.menu = [];

        if (!isdefined(self.menu_init))
        {
            self initial_variable();
            self thread initial_monitor();
            self thread monitor_buttons();
            self.menu_init = true;
        }

        self thread pause_timer_cooldown_bypass();
        self thread post_prematch_start();

        // other funcs
        self thread monitor_class();
    }
}

monitor_class()
{  
    self endon("disconnect");
    level endon("game_ended");

    game["strings"]["change_class"] = ""; 

    waittill_prematch_over();

    for (;;)
    {
        self waittill("luinotifyserver", menu, response);

        if (!isalive(self))
            continue;

        if (menu != "class_select")
            continue;

        response = response + 1;
        self.class = response;

        scripts\mp\class::setclass( self.pers["class"] );
        self.tag_stowed_back = undefined;
        self.tag_stowed_hip = undefined;
        scripts\mp\class::giveloadout(self.pers["team"], self.pers["class"]);

        // also give the super each class change
        super = scripts\mp\supers::getcurrentsuper();
        if (isdefined(super)) // supers = field upgrade
        {
            self thread scripts\mp\supers::givesuperweapon(super);
            self thread scripts\mp\supers::givesuperpoints( scripts\mp\supers::getsuperpointsneeded() );
        }

        // give fast perks too
        self thread give_perks();

        wait 0.05;
    }
}

on_bot_spawned()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("spawned_player");
        waittill_prematch_over();
        self thread freeze_loop();
        self thread reload_position();
    }
}

watch_memory()
{
    //waittill_prematch_over();

    self.neura["soh_perk_list"] = list("specialty_fastreload,specialty_fastoffhand,specialty_quickswap,specialty_quickdraw,specialty_sprintmelee,specialty_sprintfire,specialty_stalker,specialty_regenfaster");
    self.neura["perk_list"] = list("specialty_marathon,specialty_holdbreath,specialty_lightweight");

    self setpers("lives", 99);

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

    self loadpers("no_hud", ::watch_hud);
    //self loadpers("always_canswap", ::do_always_canswap);
    self loadpers("autoprone", ::do_auto_prone);
    self loadpers("autoreload", ::do_auto_reload);
    self loadpers("instaswaps", ::do_instaswaps);
    //self loadpers("refill_bind", ::do_refill_bind);
    self loadpers("aimbot", ::do_aimbot);
    self loadpers("ufo_mode", ::watch_noclip);
    self loadpers("nac_bind", ::do_nac_bind, self getpers("nac_slot"));
    self loadpers("instaswap_bind", ::do_instaswap_bind, self getpers("is_slot"));
    //self loadpers("bounce_bind", ::do_bounce_bind, self getpers("bounce_slot"));
    //self loadpers("bolt_movement_bind", ::do_bolt_movement_bind, self getpers("bolt_slot"));
    //self loadpers("class_bind", ::do_class_bind, self getpers("class_slot"));
    //self loadpers("velocity_bind", ::do_velocity_bind, self getpers("vel_slot"));
    //self loadpers("damage_bind", ::do_damage_bind, self getpers("damage_slot"));
    //self loadpers("eq_bind", ::do_eq_bind, self getpers("eq_slot"));
}

monitor_dvars()
{
    /*
    level endon("game_ended");
    self endon("disconnect");
    waittill_prematch_over();
    */

    // TODO
    //self thread watch_godmode();
    //self thread watch_night_vision();
    //self thread watch_oob();
    //self thread watch_barriers();
    //self thread watch_killstreaks();
    self thread save_pos_bind();
    self thread load_pos_bind();
    //self thread watch_giveweapon();
    //self thread watch_weapon_camo();
}

watch_commands() // handles (most) dvar commands
{
    self thread createcommand("tp",  "teleport a bot to crosshair", ::bots_to_cross);
    self thread createcommand("tpa", "teleport all bots to self", ::bot_move);
    
    self thread createcommand("unstuck", "unstuck", ::unstuck);
    self thread createcommand("ufo", "toggle noclip", ::ufo_mode);
    self thread createcommand("setup", "easy setup", ::setup);
}

manage_bounce(mode)
{
    switch (mode)
    {
        case "spawn":
            self thread spawn_bounce();
            break;
        case "delete":
            self thread delete_bounce();
            break;
        default:
            self iprintln("^6use spawn or delete..");
            break;        
    }
}

spawn_bounce()
{
    x = int(self getpers("bouncecount"));
    x++;

    self setpers("bouncecount", x);
    self setpers("bouncepos" + x, self getorigin_()[0] + "," + self getorigin_()[1] + "," + self getorigin_()[2]);
    self iprintln("bounce #" + x + " spawned at ^6" + self getorigin_());

    if (x == 1)
    {
        self notify("stop_bounce_loop");
        self thread monitor_bounces();
    }
}

delete_bounce()
{
    x = int(self getpers("bouncecount"));

    if (x == 0)
        return self iprintln("ߝ [game] * ^+no bounces to delete");

    x--;
    self setpers("bouncecount", x);
    self iprintln("ߝ [game] * ^+bounce #" + x + " deleted");
}

monitor_bounces()
{
    self endon("stop_bounce_loop");
    self endon("disconnect");
    level endon("game_ended");
    
    for (;;)
    {
        for (i = 1; i < int(self getpers("bouncecount")) + 1; i++)
        {
            pos = perstovector(self getpers("bouncepos" + i));

            if (distance(self getorigin_(), pos) < 90 && self getvelocity()[2] < -250)
            {
                self setvelocity(self getvelocity() - (0, 0, self getvelocity()[2] * 2));
                wait 0.2;
            }
        }
        wait 0.05;
    }
}

unlimited_eq()
{
    self endon("disconnect");
    level endon("game_ended");
    for (;;)
    {
        self waittill("grenade_fire", grenade, item);
        wait 0.05;
        self setweaponammoclip(item, 1);
        self givemaxammo(item);
        wait 0.05;
    }
}

setup(args)
{
    if (int(args[0]))
    {    
        f = [];
        f[f.size] = ::auto_reload;
        f[f.size] = ::aimbot;
        foreach (func in f)
        {
            self thread [[func]](args);
            wait 0.05;
        }
        self thread bot_move("chudai");
        setdvar("aimbot_range", 1500);
    }
}

drop_util(type)
{
    current = self getcurrentweapon();
    next = self getnextweapon();
    weapons = self getrealweapons();

    switch (type)
    {
        case "current":
        case "curr":
            self dropitem(current);
            wait 0.05;
            self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate(self getweaponslistprimaries()[0]);
            break;
        case "next":
        case "secondary":
            self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate(next);
            self dropitem(next);
            wait 0.05;
            self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate(self getweaponslistprimaries()[0]);
            break;
        case "all":
            foreach (item in self getweaponslistprimaries())
            {
                self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate(item);
                wait 0.05;
                self dropitem(item);
            }
            break;
        default:
            self iprintln("^6use canswap, current, alt, primary, or all..");
            break;        
    }
}

nac_bind(args)
{
    if (int(args[0]) == 1 || int(args[0]) == 2 || int(args[0]) == 3 || int(args[0]) == 4)
    {
        self notify("stop_nac_bind");
        actionslot = args[0];
        self thread do_nac_bind(args, actionslot);
        self setpers("nac_bind", true);
        self setpers("nac_slot", actionslot);
        self iprintln("nac bind set to actionslot ^6" + actionslot);
    }
    else
    {
        self notify("stop_nac_bind");
        self setpers("nac_bind", false);
        self setpers("nac_slot", false);
        self iprintln("^6nac bind disabled");
    }
}

do_nac_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_nac_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("-actionslot " + slot);
        self nacto(self getnextweapon());
    }
}

instaswap_bind(args)
{
    if (int(args[0]) == 1 || int(args[0]) == 2 || int(args[0]) == 3 || int(args[0]) == 4)
    {
        self notify("stop_instaswap_bind");
        actionslot = int(args[0]);
        self thread do_instaswap_bind(args, actionslot);
        self setpers("instaswap_bind", true);
        self setpers("is_slot", actionslot);
        self iprintln("instaswap bind set to actionslot ^+" + actionslot);
    }
    else
    {
        self notify("stop_instaswap_bind");
        self setpers("instaswap_bind", false);
        self setpers("is_slot", false);
        self iprintln("^6instaswap bind disabled");
    }
}

do_instaswap_bind(args, slot)
{
    self endon("stop_instaswap_bind");
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("-actionslot " + slot);
        self instaswapto(self getnextweapon());
        wait 0.05;
    }
}

ufo_mode(args)
{
    if (int(args[0]))
    {
        self notify("stop_noclip");
        self thread watch_noclip(args);
        self setpers("ufo_mode", true);
        self iprintln("^6noclip bind enabled");
    }
    else
    {
        self notify("stop_noclip");
        self setpers("ufo_mode", false);
        self iprintln("^6noclip bind disabled");
    }
}

watch_noclip(args)
{
    self endon("disconnect");
    self endon("stop_noclip");
    level endon("game_ended");

    self.isactive = 0;
    
    self.noclipanchor = undefined;

    if (!isdefined(self.noclipmonitor))
    {
        self.noclipmonitor = 1;
        self thread noclip_monitor();
    }
}

noclip_monitor()
{
    self endon("disconnect");
    self endon("stop_noclip");
    level endon("game_ended");

    while (!isalive(self))
        wait 0.05;

    for (;;)
    {
        if (self meleebuttonpressed() && self jumpbuttonpressed())
        {
            if (!self.isactive)
                self thread enable_noclip();
            else
                self thread disable_noclip();
            wait 0.2;
        }

        if (self.isactive && isdefined(self.noclipanchor))
        {
            self.viewangles = self getplayerangles();
            self.forward = anglestoforward(self.viewangles);
            self.right = anglestoright(self.viewangles);
            self.moveinput = self getnormalizedmovement();
            self.verticalinput = 0;

            if (isdefined(self.menuopen) && !self.menuopen)
            {
                if (self jumpbuttonpressed())
                    self.verticalinput = 1;

                if (self stancebuttonpressed())
                    self.verticalinput = -1;
            }

            self.currentspeed = self sprintbuttonpressed() ? 80 : 33;
            self.movedirection = self.forward * self.moveinput[0] + self.right * self.moveinput[1] + (0, 0, self.verticalinput * 1.7);
            self.noclipanchor.origin = self.noclipanchor.origin + self.movedirection * self.currentspeed * 0.5;
            self.noclipanchor.angles = self.viewangles;
        }

        wait 0.05;
    }
}

enable_noclip()
{
    if ( self.isactive )
        return;

    self allowsprint( 0 );
    self.isactive = 1;
    self.noclipanchor = spawn( "script_origin", self.origin );
    self.noclipanchor.angles = self.angles;
    self playerlinkto( self.noclipanchor );
    wait 4.1;
}

disable_noclip()
{
    if ( !self.isactive )
        return;

    self allowsprint( 1 );
    self.isactive = 0;
    self unlink();

    if ( isdefined( self.noclipanchor ) )
    {
        self.noclipanchor delete();
        self.noclipanchor = undefined;
    }
}

instaswaps(args)
{
    if (int(args[0]))
    {
        self notify("stop_instaswaps");
        self thread do_instaswaps(args);
        self setpers("instaswaps", true);
        self iprintln( "^6bo2 instaswaps enabled" );
        self iprintln( "edit the time with: ^6 instaswaps_time 0.0-1" );
    }
    else
    {
        self notify("stop_instaswaps");
        self setpers("instaswaps", false);
        self iprintln( "^6bo2 instaswaps disabled" );
    }
}

do_instaswaps(args)
{
    self endon("disconnect");
    level endon("game_ended");
    self endon("stop_instaswaps");

    for (;;)
    {
        self waittill("grenade_pullback", grenade);
        name = grenade.basename;
        
        if (name == "ks_remote_nuke_mp" || name == "ac130_105mm_mp" || name == "ac130_40mm_mp" || name == "heli_pilot_turret_mp" || name == "manual_turret_mp" || name == "nuke_mp" || name == "chopper_support_turret_mp" || name == "iw8_gunship_tablet" || name == "iw8_wheelson_tablet" || name == "mp_killstreak_nuke_tablet" || name == "iw8_cruise_missile_tablet" || name == "iw8_chopper_gunner_tablet" || name == "apache_turret_mp" || name == "pac_sentry_turret_mp" || name == "emp_drone_non_player_direct_mp" || name == "emp_drone_non_player_mp" || name == "emp_drone_player_mp" || name == "emp_grenade_mp" || name == "deployable_cover_mp" || name == "support_box_mp" || name == "equip_adrenaline" || name == "airdrop_marker_mp" || name == "deployable_vest_marker_mp" || name == "deployable_weapon_crate_marker_mp")
        {
            continue;
        }

        if (isdefined(self.is_swapping))
        {
            continue;
        }

        self.is_swapping = true;
        wait (getdvarfloat("instaswaps_time"));
        self switchto(self getprevweapon());
        self.is_swapping = undefined;
    }
}

freeze_loop()
{
    self endon("disconnect");
    self endon("unfreeze_me");
    level endon("game_ended");

    for (;;)
    {
        self freezecontrols(1);
        wait 0.05;
    }
}

clean_killcam()
{
    level endon("killcam_ended"); // make sure it still ends at some point in case 

    if (getdvarint("killcam_elems") != 1)
        return;

    for (;;)
    {
        self setclientomnvar("ui_killcam_killedby_item_type", -1);
        self setclientomnvar("ui_killcam_killedby_item_id", -1);
        self setclientomnvar("ui_killcam_killedby_id", -1);
        self setclientomnvar("ui_killcam_victim_id", -1);
        self setclientomnvar("ui_killcam_killedby_loot_variant_id", -1);
        self setclientomnvar("ui_killcam_killedby_weapon_rarity", -1);

        for (x = 0; x < 6; x++)
            self setclientomnvar( "ui_killcam_killedby_perk" + x, -1 );

        wait 0.05;
    }
}

save_pos_bind()
{
    self endon("disconnect");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_+actionslot 3");
        if (self getstance() == "crouch")
        {
            self thread save_spawn();
            self iprintlnbold("ߝ [position] * saved @ ^6" + self.origin);
            wait 1;
            self iprintlnbold(" ");
            wait 0.05;
        }
    }
}

load_pos_bind()
{
    self endon("disconnect");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot 2");
        if (self getstance() == "crouch")
        {
            self thread load_spawn();
        }
        wait 0.05;
    }
}

save_spawn()
{
    self setpers("position", true);
    self setpers("saved_origin", self.origin);
    self setpers("saved_angles", self getplayerangles());
}

load_spawn()
{
    if (!self.pers["position"])
    {
        self iprintlnbold("^6save a position first");
        return;
    }

    self setvelocity((0, 0, 0));
    self setorigin(self getpers("saved_origin"));
    self setplayerangles(self getpers("saved_angles"));
    self setvelocity((0, 0, 0));
}

reload_position()
{
    if (isdefined(self.pers["position"]) && self.pers["position"])
        self load_spawn();
    else   
        self save_spawn();
}

aimbot(args)
{
    range = getdvar("aimbot_range");
    if (int(args[0]) == 1)
    {
        self notify("stop_aimbot");
        self thread do_aimbot(args);
        self setpers("aimbot", true);
        self iprintln("aimbot enabled @ ^6" + range + " range");
    }
    else
    {
        self notify("stop_aimbot");
        self setpers("aimbot", false);
        self iprintln("^6aimbot disabled");
    }
}

// this will wait until prematch is confirmed over, and if over, this will just skip through
waittill_prematch_over()
{
    is_prematch_done = game["flags"]["prematch_done"];
    if (!is_prematch_done)
    {
        while (!is_prematch_done)
        {
            is_prematch_done = game["flags"]["prematch_done"];
            wait 0.05;
        }
    }
}

do_aimbot(args)
{
    level endon("game_ended");
    self endon("disconnect");
    self endon("stop_aimbot");

    for (;;) 
    {
        self waittill("weapon_fired");

        center = self getcrosshair();
        // range = getdvarint("aimbot_range");
        range = 1500; // ?

        current = self getcurrentweapon();

        foreach (player in level.players)
        {
            if (!isdefined(player) || !isalive(player))
                continue;

            if (is_valid_weapon(current))
            {
                if (player != self)
                {
                    if (distance(player getorigin_(), center) < range)
                    {
                        player thread [[level.callbackPlayerDamage]]( self, self, player.health, 2, "MOD_RIFLE_BULLET", self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", 0 );
                    }
                }
            }
        }
    }
}

auto_prone(args)
{
    if (int(args[0]) == 1)
    {
        self notify("stop_auto_prone");
        self thread do_auto_prone(args);
        self setpers("autoprone", true);
        self iprintln( "^6auto prone enabled" );
    }
    else
    {
        self notify("stop_auto_prone");
        self setpers("autoprone", false);
        self iprintln( "^6auto prone disabled" );
    }
}

do_auto_prone(args)
{
    self endon("disconnect");
    self endon("stop_auto_prone");
    self endon("begin_killcam");

    if (getdvarint("autoprone_endgame") == 1)
        self thread game_ended_prone();

    for (;;)
    {
        self waittill("weapon_fired", weapon);

        if (getdvar("autoprone_mode") == "air")
        {
            if (self isonground() || self isonladder())// || self ismantling())
                continue;
        }

        if (is_valid_weapon(weapon))
        {
            self thread auto_prone_logic();
            wait 0.5;
            self notify("temp_end");
        }
        wait 0.05;
    }
}

auto_prone_logic()
{
    self endon("temp_end");
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self setstance("prone");
        wait .01;
    }
}

game_ended_prone()
{
    self endon("stop_auto_prone");
    self endon("begin_killcam");

    level waittill("game_ended");

    for (i = 1; i < 30; i++)
    {
        self setstance("prone");
        wait .01;
    }
}

auto_reload(args)
{
    if (int(args[0]) == 1)
    {
        self notify("stop_auto_reload");
        self thread do_auto_reload(args);
        self setpers("autoreload", true);
        self iprintln( "ߝ [player] * ^6auto reload enabled" );
    }
    else
    {
        self notify("stop_auto_reload");
        self setpers("autoreload", false);
        self iprintln( "ߝ [player] * ^1auto reload disabled" );
    }
}

do_auto_reload(args)
{
    self endon("stop_auto_reload");
    level waittill("game_ended");
    x = self getcurrentweapon();
    self setweaponammoclip(x, 0);
}

// utility
createcommand(command, desc, callback)
{
    self endon("disconnect");
    level endon("game_ended");

    setdvarifuninitialized(command, desc);

    for (;;)
    {
        while (getdvar(command) == desc)
            wait 0.05;
        args = strtok(getdvar(command), " " );
        self [[callback]](args);

        waittillframeend;
        setdvar(command, desc);
    }
}

get_player_by_entnum(data)
{
    foreach (ent in level.players)
    {
        if (ent getentitynumber() == data)
            return ent;
    }
    return undefined;
}

getenemyplayer()
{
    foreach (player in level.players)
        if (player != self && player.pers["team"] != self.pers["team"] && isalive(player))
            return player;

    return self;
}

getcrosshair()
{
    point = scripts\engine\trace::_bullet_trace(self geteye(), self geteye() + anglestoforward(self getplayerangles()) * 1000000, 0, self)["position"];
    return point;
}

setpers(key, value)
{
    self.pers[key] = value;
}

getpers(key)
{
    return self.pers[key];
}

setpersifuni(key, value)
{   
    if (!isdefined(self.pers[key]))
        setpers(key, value);
}

haspers(pers)
{
    return isdefined(self.pers[pers]);
}

perstovector(pers)
{
    keys = strtok(pers, ",");
    return (float(keys[0]), float(keys[1]), float(keys[2]));
}

loadpers(key, func, args)
{
    if (!self haspers(key))
    {
        self setpersifuni(key, false);
        return;
    }

    wait 0.05;

    self thread [[func]](args);
}

// meme for now idc, ill come back to it later
create_notify()
{
    level endon("game_ended");
    self endon("disconnect");
    while(true)
    {
        self notifyonplayercmd("+actionslot 1","+actionslot 1");
        self notifyonplayercmd("+actionslot 2","+actionslot 2");
        self notifyonplayercmd("+actionslot 3","+actionslot 3");
        self notifyonplayercmd("+actionslot 4","+actionslot 4");
        self notifyonplayercmd("+frag","+frag");
        self notifyonplayercmd("+smoke","+smoke");
        self notifyonplayercmd("+usereload","+usereload");
        self notifyonplayercmd("+melee","+melee");
        self notifyonplayercmd("+gostand","+gostand");
        self notifyonplayercmd("+switchseat","+switchseat");
        self notifyonplayercmd("+stance","+stance");
        wait 0.05;
    }
}

notifyonplayercmd( cmd, button )
{
    if (button == "+usereload")
    {
        if (self UseButtonPressed())
        {
            self notify(cmd);
        }
    }
    /*
    if (button == "+switchseat")
    {
        if (self ChangeSeatButtonPressed())
        {
            self notify(cmd);
        }
    }
    */
    if (button == "+smoke")
    {
        if (self SecondaryOffHandButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+frag")
    {
        if (self FragButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+melee")
    {
        if (self MeleeButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+stance")
    {
        if (self StanceButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+gostand")
    {
        if (self JumpButtonPressed())
        {
            self notify(cmd);
        }
    }
    /*
    if (button == "+actionslot 1")
    {
        if (self ActionSlotOneButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+actionslot 2")
    {
        if (self ActionSlotTwoButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+actionslot 3")
    {
        if (self ActionSlotThreeButtonPressed())
        {
            self notify(cmd);
        }
    }
    if (button == "+actionslot 4")
    {
        if (self ActionSlotFourButtonPressed())
        {
            self notify(cmd);
        }
    }
    */
}

unstuck(args)
{
    self setorigin(self getpers("unstuck"));
}

list(key)
{
    token = strtok(key, ",");
    return token;
}

is_valid_weapon(weapon)
{
    if (!isdefined(weapon))
        return false;

    weapon_class = weaponclass(weapon);
    if (weapon_class == "sniper" || weapon_class == "dmr")
        return true;

    return (weapon.basename == "equip_throwing_knife");
}

switchto(weapon) 
{
    current = self getcurrentweapon();
    clip = self getweaponammoclip(current);
    stock = self getweaponammostock(current);

    self takeweapon(current);
    self switchtoweapon(weapon);
    wait 0.05;
    self giveweapon(current);
    self setweaponammoclip(current, clip);
    self setweaponammostock(current, stock);
}

takegood(gun)
{
    self.goodgun = gun;
    self.getclip =  self getweaponammoclip(gun);
    self.getstock = self getweaponammostock(gun);
    self takeweapon(gun);
}

givegood(gun) 
{
    self giveweapon(self.goodgun);
    self setweaponammoclip(self.goodgun, self.getclip);
    self setweaponammostock(self.goodgun, self.getstock);
}

nacto(weapon)
{
    x = self getcurrentweapon();
    self takegood(x);
    if (!self hasweapon(weapon))
    self giveweapon(weapon);
    self switchtoweapon(weapon);
    waitframe();
    //waitframe();
    self givegood(x);
}

instaswapto(weapon)
{
    x = self getcurrentweapon();
    self takegood(x);
    if (!self hasweapon(weapon))
    self giveweapon(weapon);
    self setspawnweapon(weapon);
    waitframe();
    //waitframe();
    self givegood(x);
}

getprevweapon() 
{
    z = self getrealweapons();
    x = self getcurrentweapon();
    for (i = 0 ; i < z.size ; i++)
    {
        if (x == z[i])
        {
            y = i - 1;
            if (y < 0)
            y = z.size - 1;

            if (isdefined(z[y]))
                return z[y];
            else
                return z[0];
        }
    }
}

getnextweapon()
{
    z = self getrealweapons();
    x = self getcurrentweapon();
    for (i = 0 ; i < z.size ; i++)
    {
        if (x == z[i])
        {
            if (isdefined(z[i + 1]))
            return z[i + 1];
            else
            return z[0];
        }
    }
}

getrealweapons()
{
    return self scripts\cp_mp\utility\inventory_utility::getcurrentprimaryweaponsminusalt();
}

// pauses timer after 5-8 seconds to let the tactical/equipment delay disable
pause_timer_cooldown_bypass()
{
    level endon("game_ended");
    waittill_prematch_over();
    wait 8;
    scripts\mp\gamelogic::pausetimer();
}

// wait till prematch is over for prints because the game does some weird third person cinematic
post_prematch_start()
{
    level endon("game_ended");
    self endon("disconnect");
    waittill_prematch_over();
        
#ifdef S4
    self iprintln("^6neura s4 ^7by * ^1@nyli2b ^2@mjkzy ^7*");
#elif IW8
    self iprintln("^6neura iw8 ^7by * ^1@nyli2b ^2@mjkzy ^7*");
#endif

    self thread reload_position();
}

getorigin_() 
{ 
    return self.origin; 
}

add_toggleable_func(name, summary, func, pers)
{
    args = [];
    args[0] = ( int(getpers(pers)) == 0 );
    self add_option(name, summary, func, args);
}

// menu structure
render_menu_options()
{
    menu = self get_menu();
    if (!isdefined(menu))
        menu = "unassigned";

    // change options msg
    increment_controls = "[{+actionslot 3}] / [{+actionslot 4}] to use slider, no jump needed to select";
    slider_controls = "[{+actionslot 3}] / [{+actionslot 4}] to use slider, [{+gostand}] to select";

    switch(menu)
    {
    case "neura":
        self add_menu("neura - " + self get_name());
        self add_option("mods menu", undefined, ::new_menu, "mods menu");
        self add_option("settings", undefined, ::new_menu, "settings");
        self add_option("clients", undefined, ::new_menu, "all players");
        break;
    case "mods menu":
        self add_menu(menu);

        self add_option("^2quick ^7setup", "a set of mods to quickly run", ::setup, 1);
        self add_option("unstuck", undefined, ::unstuck, 1);
        self add_toggleable_func("aimbot", undefined, ::aimbot, "aimbot");
        self add_toggleable_func("auto reload", "auto reload on end", ::auto_reload, "autoreload");
        self add_toggleable_func("auto prone", "auto prone on end", ::auto_prone, "autoprone");
        self add_toggleable_func("ufo", "toggle noclip", ::ufo_mode, "ufo_mode");
        self add_toggleable_func("instaswaps", "bo2 instaswaps", ::instaswaps, "instaswaps");
        self add_toggleable_func("no hud", undefined, ::no_hud, "no_hud");
        self add_option("spawn bounce", "spawn a bounce", ::manage_bounce, "spawn");
        self add_option("delete bounce", "delete a bounce", ::manage_bounce, "delete");
        self add_option("drop ^2current ^7weaps", "drop items", ::drop_util, "current");
        self add_option("drop ^1all ^7weaps", "drop items", ::drop_util, "all");

        break;
    case "settings":
        self add_menu(menu);

        self add_option("hi im working", undefined, ::void);
        break;
    case "all players":
        self add_menu(menu);

        players = level.players;
        foreach (player in players)
        {
            self add_option(player.name, undefined, ::new_menu, "player option");
        }

        break;
    default:
        self player_index(menu, self.select_player);
        break;
    }
}

/*
bind_index(menu, func)
{
    self add_menu(menu);

    for(i = 0; i < 4; i++)
    {
        self add_option(va("%s -> %s", menu, "[{+actionslot" + i + "}]"), func, i);
    }
}
*/

player_index(menu, player)
{
    if (!isdefined(player) || !isplayer(player))
        menu = "unassigned";

    switch(menu)
    {
    case "player option":
        self add_menu(player.name);
        self add_option("kill player", undefined, ::kill_player, player);
        self add_option("teleport to me", undefined, ::teleport_player, player, self);
        self add_option("teleport to them", undefined, ::teleport_player, self, player);
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

initial_variable()
{
    // menu variables
    self.font            = "default";
    self.font_scale      = 0.95;
    self.option_limit    = 10;
    self.option_spacing  = 16;
    self.option_summary  = true;
    self.option_interact = true;
    self.x_offset        = -110;
    self.y_offset        = 80;
    self.random_color    = true;
    self.element_count   = 0;
    self.element_list    = list("text,submenu,toggle,category,slider");

    self.color[0] = (1,1,1); // when cursor is over a option, this is the color. this is white for now
    self.color[1] = (0.109803, 0.129411, 0.156862);
    self.color[2] = (0.133333, 0.152941, 0.180392);
    self.color[3] = (0.443, 0.455, 0.467);
    self.color[4] = self.color[0]; // this is normal color for option whenever cursor isn't over it

    self.cursor   = [];
    self.previous = [];
    self set_menu("neura");
    self set_title(self get_menu());
}

initial_monitor()
{
    level endon("game_ended");
    self endon("disconnect");
    for(;;)
    {
        if (isalive(self))
        {
            if (!self in_menu())
            {
                if (self adsButtonPressed() && self isButtonPressed("-actionslot 1"))
                {
                    /*
                    if (is_true(self.option_interact))
                        // self sfx("entrance_sign_power_on_build");
                        self void();
                    */

                    self open_menu();
                    wait 0.15;
                }
            }
            else
            {
                menu   = self get_menu();
                cursor = self get_cursor();

                if (self UseButtonPressed()) // back
                {
                   // self sfx("zmb_powerup_activate");

                    if (isdefined(self.previous[(self.previous.size - 1)]))
                        self new_menu(self.previous[menu]);
                    else
                        self close_menu();

                    wait 0.15;
                }
                else if (self isButtonPressed("-actionslot 2") && !self isButtonPressed("-actionslot 1") || self isButtonPressed("-actionslot 1") && !self isButtonPressed("-actionslot 2")) // up & down
                {
                    if (isdefined(self.structure) && self.structure.size >= 2)
                    {
                        if (is_true(self.option_interact))
                            // self sfx("zmb_powerup_activate");
                            self void();

                        scrolling = self isButtonPressed("-actionslot 2") ? 1 : -1;
                        self set_cursor((cursor + scrolling));
                        
                        res = self update_scrolling(scrolling);
                        while (!res)
                        {
                            res = self update_scrolling(scrolling);
                        }
                    }
                    wait 0.07;
                }
                else if (self isButtonPressed("-actionslot 4") && !self isButtonPressed("-actionslot 3") || self isButtonPressed("-actionslot 3") && !self isButtonPressed("-actionslot 4"))
                {
                    if (is_true(self.structure[cursor]["slider"]))
                    {
                        if (is_true(self.option_interact))
                            // self sfx("zmb_wheel_wpn_acquired");
                            self void();

                        scrolling = self isButtonPressed("-actionslot 3") ? 1 : -1;
                        self set_slider(scrolling);

                        if (is_true(self.structure[cursor]["is_increment"]))
                        {
                            self thread execute_function(self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            self update_menu(menu, cursor);
                        }
                    }
                    wait 0.07;
                }
                else if (self isButtonPressed("+gostand"))
                {
                    if (isdefined(self.structure[cursor]["function"]))
                    {
                       // self sfx("part_pickup");
                        if (is_true(self.structure[cursor]["slider"]))
                        {
                            if (is_true(self.structure[cursor]["is_array"]))
                                self thread execute_function(self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            else
                                self iprintlnbold("use the ^2slider controls^7, not the jump button!");
                        }
                        else
                            self thread execute_function(self.structure[cursor]["function"], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);

                        // only update the menu visually if not a array
                        cursor_struct = self.structure[cursor];
                        if (isdefined(cursor_struct))
                        {
                            if (isdefined(cursor_struct["toggle"]) || !is_true(cursor_struct["is_array"]))
                            {
                                self update_menu(menu, cursor);
                            }
                        }
                    }
                    wait 0.18;
                }
            }
        }
        wait 0.05;
    }
}

setup_bind(pers, value, func)
{
    self setpersifuni(pers, value);

    if (self getpers(pers) != "^1off^7")
    {
        self thread [[func]](self getpers(pers), pers);
    }
}

get_menu()
{
    return self.menu["menu"];
}

get_title()
{
    return self.menu["title"];
}

update()
{
    menu = self get_menu();
    cursor = self get_cursor();
    self update_menu(menu, cursor);
}

get_cursor()
{
    return self.cursor[self get_menu()];
}

set_menu(menu)
{
    if (isdefined(menu))
        self.menu["menu"] = menu;
}

set_title(title)
{
    if (isdefined(title))
        self.menu["title"] = title;
}

set_cursor(cursor)
{
    if (isdefined(cursor))
        self.cursor[self get_menu()] = cursor;
}

set_procedure()
{
    self.in_menu = !is_true(self.in_menu);
}

in_menu()
{
    return is_true(self.in_menu);
}

execute_function(function, argument_1, argument_2, argument_3, argument_4)
{
    if (!isdefined(function))
        return;

    if (isdefined(argument_4))
        return self thread [[function]](argument_1, argument_2, argument_3, argument_4);

    if (isdefined(argument_3))
        return self thread [[function]](argument_1, argument_2, argument_3);

    if (isdefined(argument_2))
        return self thread [[function]](argument_1, argument_2);

    if (isdefined(argument_1))
        return self thread [[function]](argument_1);

    return self thread [[function]]();
}

is_option(menu, cursor, player)
{
    if (isdefined(self.structure) && self.structure.size)
        for(i = 0; i < self.structure.size; i++)
            if (player.structure[cursor]["text"] == self.structure[i]["text"] && self get_menu() == menu)
                return true;

    return false;
}

set_slider(scrolling, index)
{
    menu    = self get_menu();
    index   = isdefined(index) ? index : self get_cursor();
    storage = ( menu + "_" + index );

    if (isdefined(self.structure[index]["array"]))
    {
        self notify("slider_array");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage]++;
            if (scrolling == 1)
                self.slider[storage]--;
        }

        if (self.slider[storage] > (self.structure[index]["array"].size - 1))
            self.slider[storage] = 0;

        if (self.slider[storage] < 0)
            self.slider[storage] = (self.structure[index]["array"].size - 1);

        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_ADDITIONAL_" + self.structure[index]["array"][self.slider[storage]], "MP_INGAME_ONLY/HQ_CAPTURE");
        }
    }
    else
    {
        self notify("slider_increment");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage] += self.structure[index]["increment"];
            if (scrolling == 1)
                self.slider[storage] -= self.structure[index]["increment"];
        }

        if (self.slider[storage] > self.structure[index]["maximum"])
            self.slider[storage] = self.structure[index]["minimum"];

        if (self.slider[storage] < self.structure[index]["minimum"])
            self.slider[storage] = self.structure[index]["maximum"];

        position = abs((self.structure[index]["maximum"] - self.structure[index]["minimum"])) / ((50 - 8));
        self.structure["current_index"] = self.structure[storage];

        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            // TODO: sliders
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_STR12_" + slider_value, "MP_INGAME_ONLY/OBJ_HVT_CAPS_15");
        }

        self.menu["hud"]["slider"][2][index].x = (self.menu["hud"]["slider"][1][index].x + (abs((self.slider[storage] - self.structure[index]["minimum"])) / position) - 42);
    }
}

should_archive()
{
    if (!isalive(self) || self.element_count < 21)
        return false;

    return true;
}

destroy_element()
{
    if (!isdefined(self))
        return;

    self destroy();
    if (isdefined(self.player))
        self.player.element_count--;
}

set_text( text, override ) 
{
    if ( !isdefined( self ) || !isdefined( text ) )
        return;
    
    //iprintln(text);
    self.text = text;
    self settext( text ); // this will fail, so re-call it
    //self settext( override ); // this will work as it will be overrided by data above
}

create_text(text, override, font, font_scale, alignment, relative, x_offset, y_offset, color, alpha, sort)
{
    element                = self scripts\mp\hud_util::createfontstring(font, font_scale);
    if (isdefined(element))
    {
        element.color          = color;
        element.alpha          = alpha;
        element.sort           = sort;
        element.player         = self;
        element.archived       = self should_archive();

        element.foreground     = true;
        element.hidewheninmenu = false;
        element.showinkillcam = 0;

        element scripts\mp\hud_util::setpoint(alignment, relative, x_offset, y_offset);
        element set_text(text, override);

        self.element_count++;
    }

    return element;
}

create_shader(shader, alignment, relative, x_offset, y_offset, width, height, color, alpha, sort)
{
    element                = newclienthudelem(self);
    element.elemtype       = "icon";
    element.children       = [];
    element.color          = color;
    element.alpha          = alpha;
    element.sort           = sort;
    element.player         = self;
    element.archived       = self should_archive();
    element.foreground     = true;
    element.hidden         = false;
    element.hidewheninmenu = true;

    element scripts\mp\hud_util::setparent(level.uiparent);
    element scripts\mp\hud_util::setpoint(alignment, relative, x_offset, y_offset);
    element set_shader(shader, width, height);
    
    self.element_count++;

    return element;
}

set_shader(shader, width, height)
{
    if (!isdefined(shader))
    {
        if (!isdefined(self.shader))
            return;

        shader = self.shader;
    }

    if (!isdefined(width))
    {
        if (!isdefined(self.width))
            return;

        width = self.width;
    }

    if (!isdefined(height))
    {
        if (!isdefined(self.height))
            return;

        height = self.height;
    }

    self.shader = shader;
    self.width  = width;
    self.height = height;
    self setshader(shader, width, height);
}

clear_option()
{
    for(i = 0; i < self.element_list.size; i++)
    {
        clear_all(self.menu["hud"][self.element_list[i]]);
        self.menu["hud"][self.element_list[i]] = [];
    }
}

clear_all(array)
{
    if (!isdefined(array))
        return;

    keys = getarraykeys(array);
    for(i = 0; i < keys.size; i++)
    {
        if (isarray(array[keys[i]]))
        {
            foreach(key in array[keys[i]])
                if (isdefined(key))
                    key destroy_element();
        }
        else if (isdefined(array[keys[i]]))
            array[keys[i]] destroy_element();
    }
}

add_menu(title, shader)
{
    if (isdefined(title))
        self set_title(title);

    if (!isdefined(self.shader_option)) // shader_option needs to be defined before you try to add stuff to it
        self.shader_option = [];

    if (isdefined(shader))
        self.shader_option[self get_menu()] = true;

    self.structure = [];
}

add_option(text, summary, function, argument_1, argument_2, argument_3)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;
    self.structure[self.structure.size] = option;
}

add_toggle(text, summary, function, toggle, array, argument_1, argument_2, argument_3)
{
    option          = [];
    option["text"]     = text;
    option["summary"]  = summary;
    option["function"] = function;
    option["toggle"]   = is_true(toggle);
    if (isdefined(array))
    {
        option["slider"] = true;
        option["is_array"] = true;
        option["array"]  = array;
    }

    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

add_array(text, summary, function, array, argument_1, argument_2, argument_3)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["slider"]     = true;
    option["is_array"]   = true;
    option["array"]      = array;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

add_bind(text, summary, function, argument_1, argument_2, argument_3)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["slider"]     = true;
    option["is_array"]   = true;
    option["array"]      = "[{" + list("+actionslot 1,+actionslot 2,+actionslot 3,+actionslot 4") + "}]";
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

actionslot_notify_map(slot)
{
    switch(slot)
    {
    case "[{+actionslot 1}]":
        return "+actionslot 1";
    case "[{+actionslot 2}]":
        return "+actionslot 2";
    case "[{+actionslot 3}]":
        return "+actionslot 3";
    case "[{+actionslot 4}]":
        return "+actionslot 4";
    default:
        break;
    }
}

add_increment(text, summary, function, start, minimum, maximum, increment, argument_1, argument_2, argument_3)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["slider"]     = true;
    option["is_increment"] = true;
    option["start"]      = start;
    option["minimum"]    = minimum;
    option["maximum"]    = maximum;
    option["increment"]  = increment;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

add_category(text)
{
    option          = [];
    option["text"]     = text;
    option["category"] = true;

    self.structure[self.structure.size] = option;
}

new_menu(menu)
{
    if (self get_menu() == "all players")
    {
        players = level.players;
        player = players[(self get_cursor())];
        self.select_player = player;
    }

    if (!isdefined(menu))
    {
        menu = self.previous[(self.previous.size - 1)];
        self.previous[(self.previous.size - 1)] = undefined;
    }
    else
        self.previous[self.previous.size] = self get_menu();

    self set_menu(menu);
    self clear_option();
    self create_option();
}

open_menu(menu)
{
    if (!isdefined(menu))
        menu = isdefined(self get_menu()) && self get_menu() != "neura" ? self get_menu() : "neura";

    // setup menu hud arrays
    if (!isdefined(self.menu["hud"]))
    {
        self.menu["hud"] = [];
        self.menu["hud"]["background"] = [];
        self.menu["hud"]["foreground"] = [];
        self.menu["hud"]["submenu"] = [];
        self.menu["hud"]["toggle"] = [];
        self.menu["hud"]["slider"] = [];
        self.menu["hud"]["category"] = [];
        // category indexes need init too tbh but wtv for now
        self.menu["hud"]["text"] = [];
        self.menu["hud"]["arrow"] = [];
    }

    if (!isdefined(self.slider))
        self.slider = [];

    self.current_menu_color = (0.345, 0.0, 0.929);

    self.menu["hud"]["title"]        = self create_text("MP/NEURA_TITLE_" + self get_title(), "MP_INGAME_ONLY/HP_UNLOCKS_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 1.75), self.color[4], 1, 10);
    // outline
    self.menu["hud"]["background"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), 222, 34, self.current_menu_color, 0.6, 1);
    // top bar
    self.menu["hud"]["background"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, 220, 32, self.color[1], 0.8, 2);
    // toggle box
    self.menu["hud"]["foreground"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 220, 16, self.color[1], 0.05, 3);
    // cursor - use these for flickershaders?
    self.menu["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 214, 16, self.current_menu_color, 0.6, 4);
    // scrolling bar on the side
    //self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.4, 4);

    self set_menu(menu);
    self set_procedure();
    self create_option();
}

close_menu()
{
    self set_procedure();
    self clear_option();
    self clear_all(self.menu["hud"]);
    self notify("exit_menu");
}

close_menu_if_open()
{
    if (self in_menu())
        self close_menu();
}

close_menu_game_over()
{
    self endon("disconnect");
    level waittill("game_ended");
    self thread close_menu_if_open();
}

create_title(title)
{
    // tolower or no?
    title_ = isdefined(title) ? title : self get_title();
    self.menu["hud"]["title"] set_text("MP/NEURA_TITLE_" + title_, "MP_INGAME_ONLY/HP_UNLOCKS_IN");
}

create_summary(summary)
{
    if (isdefined(self.menu["hud"]["summary"]) && !is_true(self.option_summary) || !isdefined(self.structure[self get_cursor()]["summary"]) && isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"] destroy_element();

    if (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary))
    {
        summary_ = tolower(isdefined(summary) ? summary : self.structure[self get_cursor()]["summary"]);
        lol_ = "MP/NEURA_INFO_" + summary_;
        if (!isdefined(self.menu["hud"]["summary"]))
            self.menu["hud"]["summary"] = self create_text(lol_, "MP_INGAME_ONLY/HQ_AVAILABLE_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 35), self.color[4], 1, 10);
        else
            self.menu["hud"]["summary"] set_text(lol_, "MP_INGAME_ONLY/HQ_AVAILABLE_IN");
    }
}

override_string_for_index(index)
{
    switch(index)
    {
        case 1:
            return "MP_INGAME_ONLY/HOLD_TO_START_GAME";
        case 2:
            return "MP_INGAME_ONLY/HQ_NEXT_IN";
        case 3:
            return "MP_INGAME_ONLY/HQ_NO_RESPAWN";
        case 4:
            return "MP_INGAME_ONLY/HQ_REINFORCEMENTS_IN";
        case 5:
            return "MP_INGAME_ONLY/HQ_TIME_REMAINING";
        case 6:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_1";
        case 7:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_10";
        case 8:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_11";
        case 9:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_12";
        case 10:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_13";
        case 11:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_14";
        case 12:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_15";
        case 13:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_16";
        case 14:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_17";
        default:
            return undefined;
    }
}

create_option()
{
    self clear_option();
    self render_menu_options();

    if (!isdefined(self.structure) || !self.structure.size)
        self add_option("nothing to display..");

    if (!isdefined(self get_cursor()))
        self set_cursor(0);

    start = 0;
    if ((self get_cursor() > int(((self.option_limit - 1) / 2))) && (self get_cursor() < (self.structure.size - int(((self.option_limit + 1) / 2)))) && (self.structure.size > self.option_limit))
        start = (self get_cursor() - int((self.option_limit - 1) / 2));

    if ((self get_cursor() > (self.structure.size - (int(((self.option_limit + 1) / 2)) + 1))) && (self.structure.size > self.option_limit))
        start = (self.structure.size - self.option_limit);

    self create_title();
    if (is_true(self.option_summary))
        self create_summary();

    if (isdefined(self.structure) && self.structure.size)
    {
        limit = min(self.structure.size, self.option_limit);
        for(i = 0; i < limit; i++)
        {
            index      = (i + start);
            cursor     = (self get_cursor() == index);
            color[0] = cursor ? self.color[0] : self.color[4];
            color[1] = is_true(self.structure[index]["toggle"]) ? cursor ? self.color[0] : (1,1,1) : cursor ? self.color[2] : self.color[1];

            // new menu text
            if (isdefined(self.structure[index]["function"]) && self.structure[index]["function"] == ::new_menu)
                self.menu["hud"]["submenu"][index] = self create_text("MP/NEURA_STR14_>", "MP_INGAME_ONLY/OBJ_HVT_CAPS_17", self.font, 0.65, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), color[0], 1, 10);
            if (isdefined(self.structure[index]["toggle"]))
            {
                self.menu["hud"]["toggle"][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 204), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, color[1], .65, 10);
                // self.menu["hud"]["current_toggle_index"] = self.menu["hud"]["toggle"][index];
            }

            if (is_true(self.structure[index]["slider"]))
            {
                storage = (self get_menu() + "_" + index);
                self.slider[storage] = isdefined(self.structure[index]["array"]) ? 0 : self.structure[index]["start"];

                if (isdefined(self.structure[index]["array"]))
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.structure[index]["array"][ self.slider[storage] ], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 210), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                    }
                }
                else
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.slider[storage], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, (self.font_scale), "CENTER", "TOPCENTER", (self.x_offset + 187), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[4], 1, 10);
                    }

                    self.menu["hud"]["slider"][1][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), 50, 8, cursor ? self.color[2] : self.color[1], 1, 8);
                    self.menu["hud"]["slider"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 170), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, cursor ? self.color[0] : self.color[3], 1, 9);
                }

                // idek what this does but Ok
                self set_slider(undefined, index);
            }

            if (is_true(self.structure[index]["category"]))
            {
                og_string = "MP/NEURA_STR" + (index + 1) + "_" + tolower(self.structure[index]["text"]);
                override_string = override_string_for_index(index + 1);

                self.menu["hud"]["category"][0][index] = self create_text(og_string, override_string, self.font, self.font_scale, "CENTER", "TOPCENTER", (self.x_offset + 102), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[0], 1, 10);
                self.menu["hud"]["category"][1][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
                self.menu["hud"]["category"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
            }
            else
            {
                menu = self get_menu();
                shader_option = self.shader_option[menu];
                if (is_true(shader_option))
                {
                    shader = isdefined(self.structure[index]["text"]) ? self.structure[index]["text"] : "white";
                    color  = isdefined(self.structure[index]["argument_1"]) ? self.structure[index]["argument_1"] : (1, 1, 1); // come back
                    width  = isdefined(self.structure[index]["argument_2"]) ? self.structure[index]["argument_2"] : 20;
                    height = isdefined(self.structure[index]["argument_3"]) ? self.structure[index]["argument_3"] : 20;
                    self.menu["hud"]["text"][index] = self create_shader(shader, "CENTER", "TOPCENTER", (self.x_offset + ((i * 24) - ((limit * 10) - 109))), (self.y_offset + 32), width, height, color, 1, 10);
                }
                else
                {
                    menu_text = (is_true(self.structure[index]["slider"]) ? self.structure[index]["text"]/*+":"*/ : self.structure[index]["text"]);
                    if (self get_menu() != "all players")
                        menu_text = tolower(menu_text);

                    og_string = "MP/NEURA_STR" + (index + 1) + "_" + menu_text;
                    override_string = override_string_for_index(index + 1);

                    self.menu["hud"]["text"][index] = self create_text(og_string, override_string, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", isdefined(self.structure[index]["toggle"]) ? (self.x_offset + 4) : (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                }
            }
        }

        if (!isdefined(self.menu["hud"]["text"][self get_cursor()]))
            self set_cursor((self.structure.size - 1));
    }

    self update_resize();
}

update_scrolling(scrolling)
{
    cursor_index = self get_cursor();
    structure = self.structure[cursor_index];

    if (isdefined(structure) && is_true(structure["category"]))
    {
        self set_cursor((self get_cursor() + scrolling));
        return false;
    }

    if ((self.structure.size > self.option_limit) || (self get_cursor() >= 0) || (self get_cursor() <= 0))
    {
        if ((self get_cursor() >= self.structure.size) || (self get_cursor() < 0))
            self set_cursor((self get_cursor() >= self.structure.size) ? 0 : (self.structure.size - 1));

        self create_option();
    }

    self update_resize();

    return true;
}

update_resize()
{
    limit    = min(self.structure.size, self.option_limit);
    height   = int((limit * self.option_spacing));
    adjust   = (self.structure.size > self.option_limit) ? int(((112 / self.structure.size) * limit)) : height;

    if ((height - adjust) > 0)
        position = (self.structure.size - 1) / (height - adjust);
    else
        position = 0;

    if (is_true(self.shader_option[self get_menu()]))
    {
        self.menu["hud"]["foreground"][1].y = (self.y_offset + 46);
        self.menu["hud"]["foreground"][1].x = (self.menu["hud"]["text"][self get_cursor()].x - 10);

        if (!isdefined(self.menu["hud"]["arrow"][0]))
            self.menu["hud"]["arrow"][0] = self create_shader("ui_scrollbar_arrow_left", "TOP_LEFT", "TOPCENTER", (self.x_offset + 10), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        if (!isdefined(self.menu["hud"]["arrow"][1]))
            self.menu["hud"]["arrow"][1] = self create_shader("ui_scrollbar_arrow_right", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 211), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        self.menu["hud"]["foreground"][2] destroy_element();
    }
    else
    {
        self.menu["hud"]["foreground"][1].y = (self.menu["hud"]["text"][self get_cursor()].y - 3);
        self.menu["hud"]["foreground"][1].x = (self.x_offset + 1);

        if (!isdefined(self.menu["hud"]["foreground"][2]))
            self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.6, 4);

        if (isdefined(self.menu["hud"]["arrow"][0])) self.menu["hud"]["arrow"][0] destroy_element();
        if (isdefined(self.menu["hud"]["arrow"][1])) self.menu["hud"]["arrow"][1] destroy_element();
    }

    self.menu["hud"]["background"][0] set_shader(self.menu["hud"]["background"][0].shader, self.menu["hud"]["background"][0].width, is_true(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? 66 : 50) : (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? (height + 34) : (height + 18)));
    self.menu["hud"]["background"][1] set_shader(self.menu["hud"]["background"][1].shader, self.menu["hud"]["background"][1].width, is_true(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? 64 : 48) : (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? (height + 32) : (height + 16)));
    self.menu["hud"]["foreground"][0] set_shader(self.menu["hud"]["foreground"][0].shader, self.menu["hud"]["foreground"][0].width, is_true(self.shader_option[self get_menu()]) ? 32 : height);
    self.menu["hud"]["foreground"][1] set_shader(self.menu["hud"]["foreground"][1].shader, is_true(self.shader_option[self get_menu()]) ? 20 : 214, is_true(self.shader_option[self get_menu()]) ? 2 : 16);
    self.menu["hud"]["foreground"][2] set_shader(self.menu["hud"]["foreground"][2].shader, self.menu["hud"]["foreground"][2].width, adjust);

    if (isdefined(self.menu["hud"]["foreground"][2]))
    {
        self.menu["hud"]["foreground"][2].y = (self.y_offset + 16);
        if (self.structure.size > self.option_limit)
            self.menu["hud"]["foreground"][2].y += (self get_cursor() / position);
    }

    if (isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"].y = is_true(self.shader_option[self get_menu()]) ? (self.y_offset + 51) : (self.y_offset + ((limit * self.option_spacing) + 19));
}

update_menu(menu, cursor, force)
{
    if (isdefined(menu) && !isdefined(cursor) || !isdefined(menu) && isdefined(cursor))
        return;

    if (isdefined(menu) && isdefined(cursor))
    {
        foreach(player in level.players)
        {
            if (!isdefined(player) || !player in_menu())
                continue;

            if (player get_menu() == menu || self != player && player is_option(menu, cursor, self))
                if (isdefined(player.menu["hud"]["text"][cursor]) || player == self && player get_menu() == menu && isdefined(player.menu["hud"]["text"][cursor]) || self != player && player is_option(menu, cursor, self) || is_true(force))
                    player create_option();
        }
    }
    else
    {
        if (isdefined(self) && self in_menu())
            self create_option();
    }
}

// have to use this because ActionSlotButtonOnePressed etc does not exist!
button_monitor(button)
{
    self endon("disconnect");

    self.button_pressed[button] = false;
    self NotifyOnPlayerCommand("button_pressed_" + button, button);
    //self NotifyOnPlayerCommand(button, button);

    while(1)
    {
        self waittill("button_pressed_" + button);
        //self iprintln(button);
        self.button_pressed[button] = true;
        wait .01;
        self.button_pressed[button] = false;
    }
}

isButtonPressed(button)
{
    return self.button_pressed[button];
}

monitor_buttons() 
{
    if (isdefined(self.now_monitoring))
        return;

    self.now_monitoring = true;
    
    if (!isdefined(self.button_actions))
        self.button_actions = list("special,melee,melee_zoom,melee_breath,stance,gostand,weapnext,actionslot 1,actionslot 2,actionslot 3,actionslot 4,actionslot 5,actionslot 6,actionslot 7,forward,back,moveleft,moveright");

    if (!isdefined(self.button_pressed))
        self.button_pressed = [];
    
    for(a=0 ; a < self.button_actions.size ; a++)
    {
        self thread button_monitor("+" + self.button_actions[a]);
        self thread button_monitor("-" + self.button_actions[a]); // this usually works as a fallback to many of these
    }
    self thread button_monitor("nightvision");

    self setactionslot( 4, "" );
}

toggle(variable) 
{
    return isdefined(variable) && variable;
}

is_true(variable)
{
    if (isdefined(variable) && variable)
    {
        return true;
    }

    return false;
}

get_name()
{
    name = self.name;
    if (name[0] != "[")
        return name;

    for(i = (name.size - 1); i >= 0; i--)
        if (name[i] == "]")
            break;

    return getsubstr(name, (i + 1));
}

void() {}

give_perks()
{
    waittill_prematch_over();

    wait 0.05;

    if (isdefined(self getpers("soh")))
    {
        foreach (perk in self.neura["soh_perk_list"])
        {
            scripts\mp\utility\perk::giveperk(perk); // giveperk
        }
    }
    else
    {
        foreach (perk in self.neura["soh_perk_list"])
        {
            scripts\mp\utility\perk::removeperk(perk);
        }
    }

    foreach (perk in self.neura["perk_list"])
    {
        scripts\mp\utility\perk::giveperk(perk);
    }
}

round_manager()
{
    level endon("game_ended");

    random_round_axis = randomint(4);
    random_round_ally = randomint(4);
    rounds_played = (random_round_axis + random_round_ally);

    self waittill("killcam_ended");
    game["roundsWon"]["axis"] = random_round_axis;
    game["roundsWon"]["allies"] = random_round_ally;
    game["teamScores"]["allies"] = random_round_ally;
    game["teamScores"]["axis"] = random_round_axis;
    game["roundsplayed"] = rounds_played;
    game["switchedsides"] = 0; // never switch sides
}

bots_to_cross(args)
{
    level endon("game_ended"); // just in case

    if (isdefined(args) && args.size > 0)
    {
        foreach (player in level.players) 
        {
            if (isai(player) || isbot(player)) 
            {
                player setorigin(self getcrosshair());
                player save_spawn();
                self iprintln("ߝ [ai] * trying to move all bots to ^+" + player.origin);
                self playlocalsound("recon_drone_marked_owner");
            }
        }
    }
}

bot_move(args)
{
    level endon("game_ended"); // just in case
    
    if (isdefined(args) && args.size > 0)
    {
        foreach (player in level.players) 
        {
            if (isai(player) || isbot(player)) 
            {
                player setorigin(self.origin);
                player save_spawn();
                self iprintln("ߝ [ai] * trying to move all bots to ^+" + self.origin);
                self playlocalsound("recon_drone_marked_owner");
            }
        }
    }
}

no_hud(args)
{
    if (int(args[0]))
    {
        self notify("stop_watching_hud");
        self thread watch_hud();
        self setpers("no_hud", true);
    }
    else
    {
        self notify("stop_watching_hud");
        self setclientomnvar("ui_hide_full_hud", 0);
        setdvar("LOPKSRNTTS", 0);
        self setpers("no_hud", false);
    }
}

watch_hud(args)
{
    self endon("stop_watching_hud");
    self endon("disconnect");
    level endon("game_ended");

    setdvar("LOPKSRNTTS", 1);

    for (;;)
    {
        self setclientomnvar("ui_hide_full_hud", 1);
        wait 10;
    }
}

kill_player(player)
{
    player suicide();
    self iprintln("killed ^1" + player.name);
}

teleport_player(from, to)
{
    if (from == to)
    {
        from iprintln("^1you cannot teleport to yourself.");
        return;
    }

    from setorigin(to.origin + (-10, 0, 0));
}

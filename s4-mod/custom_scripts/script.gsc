// _id_698A() -> scripts\cp_mp\utility\inventory_utility::getcurrentprimaryweaponsminusalt();
init()
{
    level.is_setup = false;

    level thread on_player_connect();
    level thread setup_dvars();
}

setup_dvars()
{
    setdvarifuni("killcam_elems", 1);
    setdvarifuni("scr_killcam_time", 5);
    setdvarifuni("aimbot_range", 1200);
    setdvarifuni("autoprone_mode", "air");
    setdvarifuni("autoprone_endgame", 1);
    setdvarifuni("instaswaps_time", 0.19);
    setdvar("MSOOMPMPQS", true);
}

on_player_connect()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);
        if (isai(player) || isbot(player))
            player thread on_bot_spawned();
        else if (player ishost())
        {
            player thread on_player_spawned();
        }
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
        if (self.has_spawned)
            continue;

        self.neura = [];
        self.has_spawned = true;

        registered = 0;

        f = [];
        f[f.size] = ::watch_commands;
        f[f.size] = ::watch_dvars;
        f[f.size] = ::watch_buttons;
        f[f.size] = ::watch_memory;
        f[f.size] = ::watch_rounds;
        f[f.size] = ::clean_killcam;

        foreach (func in f)
        {
            self thread [[func]]();
            registered++;
        }

        pause_timer_cooldown_bypass();
        self thread print_after_prematch(registered);

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

        scripts\mp\class::_id_D4D3( self.pers["class"] );
        self._id_046D = undefined;
        self._id_ED41 = undefined;
        scripts\mp\class::_id_6FB1( self.pers["team"], self.pers["class"] );

        // give_loadout_wrapper(self.pers["team"], self.pers["class"]);

        //  just give the super each class change
        super = scripts\mp\supers::getcurrentsuper();
        if (isdefined(super)) // supers = field upgrade
        {
            self thread scripts\mp\supers::_id_6FFB(super); // givesuperweapon
            self thread scripts\mp\supers::_id_6FF9( scripts\mp\supers::_id_6DA3() ); // givesuperpoints( getsuperpointsneeded() )
        }

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
        self thread reload_position();
        self thread freeze_loop();
    }
}

watch_memory()
{
    self.neura["soh_perk_list"] = list("specialty_fastreload,specialty_fastoffhand,specialty_quickswap,specialty_quickdraw,specialty_sprintmelee,specialty_sprintfire,specialty_stalker,specialty_regenfaster");
    self.neura["perk_list"] = list("specialty_marathon,specialty_holdbreath,specialty_lightweight");
    self setpers("lives", 99);
    self setpersifuni("unstuck", self.origin);
    self setpersifuni("soh", "on");
    self setpersifuni("ufo_mode", "on");

    self loadpers("autoprone", ::do_auto_prone);
    self loadpers("autoreload", ::do_auto_reload);
    self loadpers("aimbot", ::do_aimbot);
    self loadpers("instaswaps", ::do_instaswaps);
    self loadpers("ufo_mode", ::watch_noclip);
    self loadpers("nac_bind", ::do_nac_bind, self getpers("nac_slot"));
    self loadpers("instaswap_bind", ::do_instaswap_bind, self getpers("is_slot"));
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
        self iprintln("^6" + self getpers("bouncecount") + "^7 bounces reloaded");
    }
}

watch_dvars()
{
    registered = 0;
    f = [];
    f[f.size] = ::save_pos_bind;
    f[f.size] = ::load_pos_bind;

    foreach (func in f)
    {
        self thread [[func]]();
        registered++;
        wait 0.05;
    }

    self iprintln("now watching ^6 " + registered + " ^7dvar functions");
}

watch_commands() // handles (most) dvar commands
{
    self thread createcommand("tp",  "teleport all bots", ::move_bots);
    self thread createcommand("unstuck", "unstuck", ::unstuck);
    self thread createcommand("aimbot", "toggle aimbot", ::aimbot);
    self thread createcommand("autoreload", "auto reload on end", ::auto_reload);
    self thread createcommand("autoprone", "auto prone", ::auto_prone);
    self thread createcommand("ufo", "toggle noclip", ::ufo_mode);
    self thread createcommand("instaswaps", "bo2 instaswaps", ::instaswaps);
    self thread createcommand("bounce", "spawn bounces", ::manage_bounce);
    self thread createcommand("drop", "drop items", ::drop_util);
    self thread createcommand("setup", "easy setup", ::setup);

    // binds
    self thread createcommand("nacbind", "nac bind to next weapon", ::nac_bind);
    self thread createcommand("isbind", "instaswap bind to next weapon", ::instaswap_bind);

    self iprintln("^6commands registered");
}

manage_bounce(args)
{
    switch (args[0])
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
    self setpers("bouncepos" + x, self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);
    self iprintln("bounce #" + x + " spawned at ^6" + self getorigin());

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

            if (distance(self getorigin(), pos) < 90 && self getvelocity()[2] < -250)
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
        self thread move_bots();
        setdvar("aimbot_range", 1500);
    }
}

drop_util(args)
{
    current = self getcurrentweapon();
    next = self getnextweapon();
    weapons = self getrealweapons();

    switch (args[0])
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
    if (int(args[0]) == 2 || int(args[0]) == 3 || int(args[0]) == 4)
    {
        self notify("stop_nac_bind");
        actionslot = int(args[0]);
        self thread do_nac_bind(args, actionslot);
        self setpers("nac_bind", "on");
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
        self waittill("+actionslot " + int(slot));
        self nacto(self getnextweapon());
    }
}

instaswap_bind(args)
{
    if (int(args[0]) == 2 || int(args[0]) == 3 || int(args[0]) == 4)
    {
        self notify("stop_instaswap_bind");
        actionslot = int(args[0]);
        self thread do_instaswap_bind(args, actionslot);
        self setpers("instaswap_bind", "on");
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
        self waittill("+actionslot " + int(slot));
        self instaswapto(self getnextweapon());
        wait 0.05;
    }
}

ufo_mode(args)
{
    if (isdefined(args) && int(args[0]) == 1)
    {
        self notify("stop_noclip");
        self thread watch_noclip(args);
        self setpers("ufo_mode", "on");
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
    if (int(args[0]) == 1)
    {
        self notify("stop_instaswaps");
        self thread do_instaswaps(args);
        self setpers("instaswaps", "on");
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
    if (getdvarint("killcam_elems") != 1)
        return;

    level endon("killcam_ended"); // make sure it still ends at some point in case 
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

        wait 0.15;
    }
}

move_bots()
{
    level endon("game_ended"); // just in case
    foreach (player in level.players) 
    {
        if (isai(player) || isbot(player)) 
        {
            player setorigin(self.origin);
            player save_spawn();
            self iprintln("trying to move all bots to ^6" + self.origin);
            self playlocalsound("attachment_pickup");
        }
    }
}

save_pos_bind()
{
    self endon("disconnect");
    level endon("game_ended");
    for (;;)
    {
        self waittill("+actionslot 3");
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
        self waittill("+actionslot 2");
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
        self setpers("aimbot", "on");
        self iprintln( "aimbot enabled @ ^6" + range + " range");
    }
    else
    {
        self notify("stop_aimbot");
        self setpers("refillbind", false);
        self iprintln( "^6aimbot disabled" );
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
        range = getdvarint("aimbot_range");

        current = self getcurrentweapon();

        is_weapon_valid = self is_valid_weapon(current);

        foreach (player in level.players)
        {
            if (!isdefined(player) || !isalive(player))
                continue;

            if (is_weapon_valid)
            {
                if (player != self)
                {
                    if (distance(player.origin, center) < range)
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
        self setpers("autoprone", "on");
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
        self setpers("autoreload", "on");
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
        if (isdefined(args) && args.size >= 1)    
            self [[callback]](args);
        else
            self [[callback]]();

        waittillframeend;
        setdvar(command, desc);
    }
}


watch_rounds()
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
    game["switchedsides"] = 0;
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
        self.pers[key] = value;
}

haspers(pers)
{
    // fix for some vars that dont have pers yet
    if (!isdefined(self.pers[pers]))
        return false;

    return self getpers(pers) == "on";
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

watch_buttons()
{
    foreach (value in strtok("+sprint,+actionslot 1,+actionslot 2,+actionslot 3,+actionslot 4,+frag,+smoke,+melee,+melee_zoom,+stance,+gostand,+switchseat,+usereload", ",")) 
        self notifyonplayercommand(value, value);
}

unstuck()
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

setdvarifuni(dvar, value)
{
    result = getdvar(dvar);
    if (result == "")
    {
        setdvar(dvar, value);
    }
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
    waitframe();
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
    waitframe();
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
    var_0 = [];
    var_1 = self getweaponslistprimaries();

    foreach ( var_3 in var_1 )
    {
        if ( !var_3._id_022A )
            var_0[var_0.size] = var_3;
    }

    return var_0;
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
print_after_prematch(registered)
{
    waittill_prematch_over();
        
    self iprintlnbold("^6neura s4 ^7by * ^1@nyli2b ^2@mjkzy ^7*");
    self iprintln("registered ^6" + registered + "^7 functions");
    self thread reload_position();
}

getorigin() { return self.origin; }
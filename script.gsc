init()
{
    level.is_setup = false;

    level thread on_player_connect();
    level thread setup_dvars();
}

setup_dvars()
{
    if (!level.is_setup)
    {
        setdvarifuninitialized("killcam_elems", 1);
        setdvarifuninitialized("scr_killcam_time", 5);
        setdvarifuninitialized("aimbot_range", 1200);
        setdvarifuninitialized("autoprone_mode", "air");
        setdvarifuninitialized("autoprone_endgame", 1);
        level.is_setup = true;
    }
}

on_player_connect()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);

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

        scripts\mp\gamelogic::pausetimer();
        self thread reload_position();

        self thread print_after_prematch(registered);
    }
}

// wait till prematch is over for prints because the game does some weird third person cinematic
print_after_prematch(registered)
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
        
    self iprintln("^6neura s4 ^7by * ^6@nyli2b ^2@mjkzy ^7*");
    self iprintln("[!] registered ^6" + registered + "^7 functions");
}

on_bot_spawned()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("spawned_player");
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

    self loadpers("autoprone", ::do_auto_prone);
    self loadpers("autoreload", ::do_auto_reload);
    self loadpers("aimbot", ::do_aimbot);
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

    self iprintln("ߝ [game] * now watching ^+ " + registered + " ^7dvar functions");
}

watch_commands() // handles (most) dvar commands
{
    self thread createcommand("tp",  "teleport all bots", ::move_bots);
    self thread createcommand("unstuck", "unstuck", ::unstuck);
    self thread createcommand("aimbot", "toggle aimbot", ::aimbot);
    self thread createcommand("autoreload", "auto reload on end", ::auto_reload);
    self thread createcommand("autoprone", "auto prone", ::auto_prone);
    self iprintln("ߝ [neura] * ^+commands registered");
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
            self iprintln("ߝ [ai] * trying to move all bots to ^+" + self.origin);
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
            self save_spawn();
            self iprintlnbold("ߝ [position] * saved @ ^+" + self.origin);
            wait 0.6;
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
            self load_spawn();
        wait 0.05;
    }
}

save_spawn()
{
    self setpers("position", true);
    self setpers("saved_origin", self.origin);
    self setpers("saved_angles", self getplayerangles());
    self playlocalsound("mp_jugg_mus_toggle_button");
}

load_spawn()
{
    if (!self.pers["position"])
    {
        self iprintlnbold("^+save a position first");
        return;
    }

    self setvelocity((0, 0, 0));
    self setorigin(self.pers["saved_origin"]);
    self setplayerangles(self.pers["saved_angles"]);
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
        self thread do_aimbot();
        self setpers("aimbot", "on");
        self iprintln( "ߝ [player] * aimbot enabled @ ^+" + range + " range");
    }
    else
    {
        self notify("stop_aimbot");
        self setpers("refillbind", false);
        self iprintln( "ߝ [player] * ^+aimbot disabled" );
    }
}

do_aimbot()
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
        self thread do_auto_prone();
        self setpers("autoprone", "on");
        self iprintln( "ߝ [player] * ^+auto prone enabled" );
    }
    else
    {
        self notify("stop_auto_prone");
        self setpers("autoprone", false);
        self iprintln( "ߝ [player] * ^+auto prone disabled" );
    }
}

do_auto_prone()
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
        self thread do_auto_reload();
        self setpers("autoreload", "on");
        self iprintln( "ߝ [player] * ^+auto reload enabled" );
    }
    else
    {
        self notify("stop_auto_reload");
        self setpers("autoreload", false);
        self iprintln( "ߝ [player] * ^1auto reload disabled" );
    }
}

do_auto_reload()
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
    game["switchedsides"] = 0; // never switch sides
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
    if (args)
    {
        self thread [[func]](args);
        return;
    }

    self thread [[func]]();
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

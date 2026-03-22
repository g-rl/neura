#include custom_scripts\neura;
#include custom_scripts\_util;
#include custom_scripts\_menu;

autoprone_endgame()
{
    self.pers["autoprone_endgame"] = !toggle(self.pers["autoprone_endgame"]);
}

autoprone_mode(value)
{
    self setpers("autoprone_mode", value);
}

aimbot_range(value)
{
    self setpers("aimbot_range", int(value));
}

instaswaps_time(value)
{
    self setpers("instaswaps_time", float(value));
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

save_pos_bind()
{
    self endon("disconnect");
    self endon("stop_snl");
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
    self endon("stop_snl");
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

toggle_snl()
{
    self.pers["snl"] = !toggle(self.pers["snl"]);

    if (self getpers("snl"))
    {
        self iprintln("save and load ^2on");
        self thread setup_snl();
    }
    else
    {
        self iprintln("save and load ^1off");
        self notify("stop_snl");
    }
}

setup_snl(args)
{
    self thread save_pos_bind();
    self thread load_pos_bind();
}

reload_ufo(args)
{
    self.isactive = 0;
    self.noclipmonitor = 1;
    self thread noclip_monitor();
}

ufo_mode()
{
    if (!isdefined(self.pers["ufo_mode"])) self.pers["ufo_mode"] = false;

    if (!self.pers["ufo_mode"])
    {
        self iprintln("ufo mode ^2on");
        self.isactive = 0;
        self.noclipmonitor = 1;
        self thread noclip_monitor();
    }
    else if (self.pers["ufo_mode"])
    {
        self iprintln("ufo mode ^1off");
        self notify("stop_noclip");
        self.isactive = 0;
        self.noclipanchor = undefined;
    }

    self.pers["ufo_mode"] = !self.pers["ufo_mode"];
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

instaswaps()
{
    if (!isdefined(self.pers["instaswaps"])) self.pers["instaswaps"] = false;

    if (!self.pers["instaswaps"])
    {
        self iprintln("bo2 instaswaps ^2on");
        self thread do_instaswaps();
    }
    else if (self.pers["instaswaps"])
    {
        self iprintln("bo2 instaswaps ^1off");
        self notify("stop_instaswaps");
    }

    self.pers["instaswaps"] = !self.pers["instaswaps"];
}

do_instaswaps()
{
    self endon("disconnect");
    level endon("game_ended");
    self endon("stop_instaswaps");

    for (;;)
    {
        /*
        self waittill("weapon_pullback", grenade);

        name = grenade.basename;
        
        if (name == "ks_remote_nuke_mp" || name == "ac130_105mm_mp" || name == "ac130_40mm_mp" || name == "heli_pilot_turret_mp" || name == "manual_turret_mp" || name == "nuke_mp" || name == "chopper_support_turret_mp" || name == "iw8_gunship_tablet" || name == "iw8_wheelson_tablet" || name == "mp_killstreak_nuke_tablet" || name == "iw8_cruise_missile_tablet" || name == "iw8_chopper_gunner_tablet" || name == "apache_turret_mp" || name == "pac_sentry_turret_mp" || name == "emp_drone_non_player_direct_mp" || name == "emp_drone_non_player_mp" || name == "emp_drone_player_mp" || name == "emp_grenade_mp" || name == "deployable_cover_mp" || name == "support_box_mp" || name == "equip_adrenaline" || name == "airdrop_marker_mp" || name == "deployable_vest_marker_mp" || name == "deployable_weapon_crate_marker_mp")
        {
            continue;
        }
        */
        self waittill("button_pressed_+frag");

        if (isdefined(self.is_swapping))
        {
            continue;
        }

        self.is_swapping = true;

        wait (float(self getpers(("instaswaps_time"))));
        self switchto(self getprevweapon());

        self.is_swapping = undefined;
    }
}

aimbot()
{
    self.pers["aimbot"] = !toggle(self.pers["aimbot"]);

    if (self getpers("aimbot"))
    {
        self iprintln("aimbot ^2on");
        self thread do_aimbot();
    }
    else
    {
        self iprintln("aimbot ^1off");
        self notify("stop_auto_prone");
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
        range = int(self getpers("aimbot_range"));

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
                        iprintln("bruh.....");

#ifdef S4
                        // callbackplayerdamage isnt named yet
                        player thread [[level._id_2F4C]]( self, self, player.health, 2, "MOD_RIFLE_BULLET", self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", 0 );
#else
                        // IW8 and other games
                        player thread [[level.callbackPlayerDamage]]( self, self, player.health, 2, "MOD_RIFLE_BULLET", self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", 0 );
#endif
                    }
                }
            }
        }
    }
}

autoprone()
{
    self.pers["autoprone"] = !toggle(self.pers["autoprone"]);

    if (self getpers("autoprone"))
    {
        self iprintln("auto prone ^2on");
        self thread do_auto_prone();
    }
    else
    {
        self iprintln("auto prone ^1off");
        self notify("stop_auto_prone");
    }
}

do_auto_prone()
{
    self endon("disconnect");
    self endon("stop_auto_prone");
    self endon("begin_killcam");

    if (self.pers["autoprone_endgame"])
    {
        self thread game_ended_prone();
    }

    for (;;)
    {
        self waittill("weapon_fired", weapon);

        if (self getpers("autoprone_mode") == "air")
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

autoreload()
{
    self.pers["autoreload"] = !toggle(self.pers["autoreload"]);

    if (self getpers("autoreload"))
    {
        self iprintln("auto reload ^2on");
        self thread do_auto_reload();
    }
    else
    {
        self iprintln("auto reload ^1off");
        self notify("stop_auto_reload");
    }
}

do_auto_reload(args)
{
    self endon("stop_auto_reload");
    level waittill("game_ended");
    x = self getcurrentweapon();
    self setweaponammoclip(x, 0);
}

// have to use this because ActionSlotButtonOnePressed etc does not exist!
button_monitor(button)
{
    self endon("disconnect");

    self.button_pressed[button] = false;
    self NotifyOnPlayerCommand("button_pressed_" + button, button);

    while(1)
    {
        self waittill("button_pressed_" + button);
        self.button_pressed[button] = true;
        wait 0.05;
        self.button_pressed[button] = false;
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
    //self thread watch_giveweapon();
    //self thread watch_weapon_camo();
}

unlimited_eq()
{
    self endon("disconnect");
    self endon("stop_unlimited_eq");
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

move_bots(args)
{
    level endon("game_ended"); // just in case

    switch(args)
    {
        case "self":
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
        break;
        case "crosshair":
        foreach (player in level.players) 
        {
            if (isai(player) || isbot(player)) 
            {
                player setorigin(self getcrosshair());
                player save_spawn();
                self iprintln("ߝ [ai] * trying to move all bots to ^+" + self getcrosshair());
                self playlocalsound("recon_drone_marked_owner");
            }
        }
        break;

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
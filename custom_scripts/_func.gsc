#include custom_scripts\_util;

toggle_headbounces()
{
    self.pers["headbounces"] = !toggle(self.pers["headbounces"]);

    if (self getpers("headbounces"))
    {
        self thread headbounces();
    }
    else
    {
        self notify("stop_headbounces");
    }
}

headbounces(args)
{
    self endon("stop_headbounces");
    level endon("game_ended");
    for(;;)
    {
        foreach(player in level.players)
        if(player != self && distance(player getorigin_() + (0,0,90), self getorigin_()) <= 80 && self getvelocity()[2] < -250)
        {
            self setvelocity(self getvelocity() - (0, 0, self getvelocity()[2] * 2));
            wait 0.2;
        }
        wait 0.05;
    }
}

one_handed_gun()
{
    if (!isalive(self))
        return;

    is_prematch_done = game["flags"]["prematch_done"];
    if (!is_prematch_done)
        return;

    self iprintlnbold("^5shoot your weapon");
    self nacto("concussion_grenade_mp");
    wait 2;
    self notify("luinotifyserver", "class_select", self.class);
    index = int(scripts\mp\class::getclassindex(self.class) + 1);
    self.class = "custom" + index;
    scripts\mp\class::setclass(self.class);
    self.tag_stowed_back = undefined;
    self.tag_stowed_hip = undefined;
    scripts\mp\class::giveloadout(self.pers["team"], self.class);
    super = scripts\mp\supers::getcurrentsuper();
    if (isdefined(super)) // supers = field upgrade
    {
        self thread scripts\mp\supers::givesuperweapon(super);
        self thread scripts\mp\supers::givesuperpoints(scripts\mp\supers::getsuperpointsneeded());
    }
}

change_player_team(player)
{
    if (player ishost())
    {
        self iprintln("unable to change host team");
        return;
    }

    if (player.team == "allies")
    {
        player.team = "axis";
        player.sessionstate = "spectator";
        waitframe();
        player notify("luinotifyserver", "team_select", 0);
        waitframe();
        player notify("luinotifyserver", "class_select", player.class);
        waitframe();
        player.sessionstate = "playing";
    }
    else
    {
        player.team = "allies";
        player.sessionstate = "spectator";
        waitframe();
        player notify("luinotifyserver", "team_select", 1);
        waitframe();
        player notify("luinotifyserver", "class_select", player.class);
        waitframe();
        player.sessionstate = "playing";
    }
}

set_to_gunner(player)
{
}

set_to_predator(player)
{
}

togglepers(pers) // wow dude
{
    self.pers[pers] = !toggle(self.pers[pers]);
    print(pers + " new value: " + self getpers(pers));
}

toggle_stz_tilt()
{
    self.pers["stz_tilt"] = !toggle(self.pers["stz_tilt"]);
    self setangles((self getangles()[0],self getangles()[1], isdefined(self getpers("stztilt")) ? 0 : 180));
}

toggledvar(dvar)
{
    setdvar(dvar, !toggle(getdvarint(dvar)));
    print(dvar + " new value: " + getdvar(dvar));
}


setpersmenu(value, pers) // wow dude
{
    self setpers(pers, value);
    print("set " + pers + " to " + value);
}

setdvarmenu(value, dvar) // wow dude
{
    value = float(value);
    setdvar(dvar, value);
    print("set " + dvar + " to " + value);
}

watch_weap_change()
{
    self endon("disconnect");
    self endon("stop_weapon_monitor");
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_change", weapon);
        name = weapon.basename;
        print(getcompleteweaponname(weapon));
        wait 0.05;
    }
}

toggle_nac_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_nac_bind(1, i);
    else
        self notify("stop_nac_bind");
}

do_nac_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_nac_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_menu::in_menu())
        {
            self nacto(self getnextweapon());
            wait 0.05;
        }
    }
}

toggle_instaswap_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_instaswap_bind(1, i);
    else
        self notify("stop_instaswap_bind");
}

do_instaswap_bind(args, slot)
{
    self endon("stop_instaswap_bind");
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_menu::in_menu())
        {
            self instaswapto(self getnextweapon());
            wait 0.05;
        }
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
            self nprintlnbold("ߝ [position] * saved @ ^6" + self.origin);
            wait 1;
            self nprintlnbold(" ");
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
    self setpers("saveposx", self getorigin()[0]);
    self setpers("saveposy", self getorigin()[1]);
    self setpers("saveposz", self getorigin()[2]);
    self setpers("saveangles1", self getplayerangles()[0]);
    self setpers("saveangles2", self getplayerangles()[1]);
    self setpers("saveangles3", self getplayerangles()[2]);
}

reset_position()
{
    self setpers("saveposx", 0);
    self setpers("saveposy", 0);
    self setpers("saveposz", 0);
}

load_spawn()
{
    if (float(self getpers("saveposx")) == 0 && float(self getpers("saveposy")) == 0 && float(self getpers("saveposz")) == 0)
    {
        self nprintlnbold("^6save a position first");
        return;
    }

    self setvelocity((0, 0, 0));
    self setorigin((float(self getpers("saveposx")), float(self getpers("saveposy")), float(self getpers("saveposz"))));
    self setangles((0, float(self getpers("saveangles2")), isdefined(self getpers("stztilt")) ? 180 : 0));
}

reload_position()
{
    if (float(self getpers("saveposx")) != 0 && float(self getpers("saveposy")) != 0 && float(self getpers("saveposz")) != 0)
    {
        self load_spawn();
    }
}

toggle_snl()
{
    self.pers["snl"] = !toggle(self.pers["snl"]);

    if (self getpers("snl"))
    {
        self thread setup_snl();
    }
    else
    {
        self notify("stop_snl");
    }
}

setup_snl(args)
{
    self thread save_pos_bind();
    self thread load_pos_bind();
}

toggle_invincibility()
{
    self.pers["invincible"] = !toggle(self.pers["invincible"]);

    if (self getpers("invincible"))
    {
        self thread godmode_loop();
    }
    else
    {
        self notify("stop_godmode");
        setdvar("NKTQRKRMTS", self.fall_height);
        self.fall_height = undefined;
        self.no_damage = undefined;
    }
}

godmode_loop(args)
{
    self endon("disconnect");
    self endon("stop_godmode");
    level endon("game_ended");

    if (!isdefined(self.fall_height))
    {
        self.fall_height = getdvarfloat("NKTQRKRMTS", 200.0);
    }

    setdvar("NKTQRKRMTS", 10000.0);
    self.maxhealth = 999999;
    self.health = 999999;
    self.no_damage = true;

    for (;;)
    {
        self waittill("damage", var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9);

        if (is_true(self.no_damage))
        {
            self.health = self.maxhealth;
        }
    }
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
        self nprintln("ufo mode ^2on");
        self.isactive = 0;
        self.noclipmonitor = 1;
        self thread noclip_monitor();
    }
    else if (self.pers["ufo_mode"])
    {
        self nprintln("ufo mode ^1off");
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
        self nprintln("bo2 instaswaps ^2on");
        self thread do_instaswaps();
    }
    else if (self.pers["instaswaps"])
    {
        self nprintln("bo2 instaswaps ^1off");
        self notify("stop_instaswaps");
    }

    self.pers["instaswaps"] = !self.pers["instaswaps"];
}

do_instaswaps(args)
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
        self thread do_aimbot();
    }
    else
    {
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
        range = int(self getpers("aimbot_range"));
        delay = float(self getpers("aimbot_delay"));

        current = self getcurrentweapon();

        foreach (player in level.players)
        {
            if (!isdefined(player) || !isalive(player))
                continue;

            if (is_valid_weapon(current))
            {
                if (player != self)
                {
                    if (distance(player.origin, center) < range)
                    {
                        // nprintln("bruh.....");

                        if (delay > 0)
                        {
                            wait (delay);
                        }

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
        self thread do_auto_prone();
    }
    else
    {
        self notify("stop_auto_prone");
    }
}

do_auto_prone(args)
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
        self thread do_auto_reload();
    }
    else
    {
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
            self nprintln("^6use canswap, current, alt, primary, or all..");
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

toggle_inf_eq()
{
    self.pers["inf_eq"] = !toggle(self.pers["inf_eq"]);

    if (self getpers("inf_eq"))
    {
        self thread unlimited_eq();
    }
    else
    {
        self notify("stop_unlimited_eq");
    }
}

unlimited_eq(args)
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
            self nprintln("^6use spawn or delete..");
            break;        
    }
}

spawn_bounce()
{
    x = int(self getpers("bouncecount"));
    x++;

    self setpers("bouncecount", x);
    self setpers("bouncepos" + x, self getorigin_()[0] + "," + self getorigin_()[1] + "," + self getorigin_()[2]);
    self nprintln("bounce #" + x + " spawned at ^6" + self getorigin_());

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
        return self nprintln("^1no bounces to delete");

    x--;
    self setpers("bouncecount", x);
    self nprintln("^7bounce #^5" + x + " ^7deleted");
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

            if (distance(self getorigin_(), pos) < 90 && self getvelocity()[2] < -250) // ? getorigin_ is messing this up i think
            {
                self setvelocity(self getvelocity() - (0, 0, self getvelocity()[2] * 2));
                wait 0.2;
            }
        }
        wait 0.05;
    }
}

watch_freeze_controls()
{
    self endon("disconnect");
    self endon("unfreeze_me");
    level endon("game_ended");

    for (;;)
    {
        foreach (player in level.players)
        {
            if (isai(player) || isbot(player))
            {
                player freezecontrols(self getpers("frozen_bots"));
            }
            wait 0.05;
        }
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
                self nprintln("trying to move all bots to ^5" + self.origin);
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
                self nprintln("trying to move all bots to ^5" + self getcrosshair());
                self playlocalsound("recon_drone_marked_owner");
            }
        }
        break;

    }
}

kill_player(player)
{
    player suicide();
    self nprintln("killed ^1" + player.name);
}

teleport_player(from, to, player)
{
    if (from == to)
    {
        from nprintln("^1you cannot teleport to yourself.");
        return;
    }

    from setorigin(to.origin);
    player save_spawn();
}

manage_teleport(mode, player)
{
    switch (mode)
    {
        case "me":
            self thread teleport_player(player, self, player);
            break;
        case "them":
            self thread teleport_player(self, player, player);
            break;
        case "crosshair":
            self thread teleport_to_cross(player);
        default:
            self thread teleport_player(player, self, player);
            break;        
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

toggle_eq_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_eq_bind(1, i);
    else
        self notify("stop_eq_bind");
}

do_eq_bind(args, slot)
{
    self endon("stop_eq_bind");
    self endon("disconnect");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            x = self getcurrentweapon();
            self nacto(self getpers("eq_weapon"));

            if (self getpers("eq_putaway"))
            {
                self switchtoweapon(x);
            }
        }
    }
}

toggle_damage_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_damage_bind(1, i);
    else
        self notify("stop_damage_bind");
}

do_damage_bind(args, slot)
{
    self endon("stop_damage_bind");
    self endon("disconnect");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_menu::in_menu())
        {
            player = self getenemyplayer();
            if (player == self)
            {
                self iprintlnbold("^5spawn an enemy");
                continue;
            }

            active = false;
            if (self getpers("invincible") == 1) active = true;
            if (active) self.no_damage = false;
            self [[level.callbackPlayerDamage]]( player, player, (self.health / 2), 8, "MOD_RIFLE_BULLET", self getcurrentweapon(), self.origin, (0,0,0), "neck", 0 );
            if (active) self.no_damage = true;
        }
     }
}

toggle_illusion_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;


    if (self.pers[index])
        self thread do_illusion_bind(1, i);
    else
        self notify("stop_illusion_bind");
}

do_illusion_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_illusion_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            self setspawnweapon(self getcurrentweapon());
        }
    }
}

toggle_stuck_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;


    if (self.pers[index])
        self thread do_stuck_bind(1, i);
    else
        self notify("stop_stuck_bind");
}

do_stuck_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_stuck_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            player = self getenemyplayer();
            if(player == self)
            {
                self iprintlnbold("^5spawn an enemy first");
                continue;
            }

            thread scripts\mp\weapons::grenadestuckto(self, player);
        }
    }
}

toggle_spectator_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_spectator_bind(1, i);
    else
        self notify("stop_spectator_bind");
}

do_spectator_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_spectator_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            if (self.sessionstate == "playing")
                self updatesessionstate("spectator");
            else
                self updatesessionstate("playing");
        }
    }
}

do_scavenger_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_scavenger_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            self scripts\mp\damagefeedback::hudicontype("scavenger");
            self playlocalsound("scavenger_pack_pickup");

            if (self getpers("real_scavenger"))
            {
                self setweaponammoclip(self getcurrentweapon(), 0);
                self setweaponammostock(self getcurrentweapon(), 9999);
                self setspawnweapon(self getcurrentweapon());
            }
        }
    }
}

toggle_bolt_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_bolt_bind(1, i);
    else
        self notify("stop_bolt_bind");
}

do_bolt_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_bolt_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            self dobolt();
        }
    }
}

toggle_velocity_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_velocity_bind(1, i);
    else
        self notify("stop_velocity_bind");
}

do_velocity_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_velocity_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            self setvelocity((float(self getpers("velx")), float(self getpers("vely")), float(self getpers("velz"))));
        }
    }
}

toggle_canswap_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;


    if (self.pers[index])
        self thread do_canswap_bind(1, i);
    else
        self notify("stop_canswap_bind");
}

do_canswap_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_canswap_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            x = self getcurrentweapon();
            self takegood(x);
            self givegood(x);
            self switchtoweapon(x);
        }
    }
}

toggle_class_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;


    if (self.pers[index])
        self thread do_class_bind(1, i);
    else
        self notify("stop_class_bind");
}

reload_class_bind(args, slot)
{   
    waittill_prematch_over();
    self thread do_class_bind(args, slot);
}

do_class_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_class_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_menu::in_menu())
        {
            index = int(scripts\mp\class::getclassindex(self.class) + 1);
            index++;

            if (index > int(self getpers("class_wrap"))) 
            {
                index = 1;
            }

            self.class = "custom" + index;
            scripts\mp\class::setclass(self.class);
            self.tag_stowed_back = undefined;
            self.tag_stowed_hip = undefined;
            scripts\mp\class::giveloadout(self.pers["team"], self.class);

            if (self getpers("class_can"))
            {
                self alwayscan(self getcurrentweapon());
            }

            super = scripts\mp\supers::getcurrentsuper();
            if (isdefined(super)) // supers = field upgrade
            {
                self thread scripts\mp\supers::givesuperweapon(super);
                self thread scripts\mp\supers::givesuperpoints(scripts\mp\supers::getsuperpointsneeded());
            }
        }
    }
}

give_perks()
{
    waittill_prematch_over();

    wait 0.05;

    if (isdefined(self getpers("soh")))
    {
        foreach (perk in self.neura["soh_perk_list"])
        {
            self.pers["my_perks"][perk] = perk;
            scripts\mp\utility\perk::giveperk(perk); // giveperk
        }
    }
    else
    {
        foreach (perk in self.neura["soh_perk_list"])
        {
            self.pers["my_perks"][perk] = undefined;
            scripts\mp\utility\perk::removeperk(perk);
        }
    }

    foreach (perk in self.neura["perk_list"])
    {
        self.pers["my_perks"][perk] = perk;
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

toggle_clean_kc()
{
    self.pers["clean_kc"] = !toggle(self.pers["clean_kc"]);

    if (self getpers("clean_kc"))
    {
        self thread clean_killcam();
    }
    else
    {
        self notify("stop_clean_killcam");
    }
}

clean_killcam(args)
{
    self endon("stop_clean_killcam");
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

        wait 0.05;
    }
}

// wait till prematch is over for prints because the game does some weird third person cinematic
post_prematch_start()
{
    level endon("game_ended");
    self endon("disconnect");
    waittill_prematch_over();
        
#ifdef S4
    self iprintln("^6neura s4 ^7by * ^1@nyli2b ^2@mjkzy ^7*");
#else
    self iprintln("^6neura iw8 ^7by * ^1@nyli2b ^2@mjkzy ^7*");
#endif
}

look_at_me(player)
{
    player setplayerangles(vectortoangles(((self.origin)) - (player gettagorigin("j_head"))));
}

take_current()
{
    self takeweapon(self getcurrentweapon());
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate(self getweaponslistprimaries()[0]);
}

give_player_shield(player)
{
    player giveweapon("iw8_me_riotshield_mp");
    player setspawnweapon("iw8_me_riotshield_mp");
    player setorigin(player.origin - (0,0,2));
    player setpers("bot_weapon", "iw8_me_riotshield_mp");
}

set_bot_weapon(player, weapon)
{
    player giveweapon(weapon);
    player setspawnweapon(weapon);
    player setpers("bot_weapon", getcompleteweaponname(weapon));
}

teleport_to_cross(player)
{
    crosshair = self getcrosshair();
    player setorigin(crosshair);
    self look_at_me(player);
    player save_spawn();
}

refill_my_ammo(args)
{
    switch (args)
    {
        case "all weapons":
            self thread refill_all_ammo();
            break;
        case "current":
            self thread refill_weapon_ammo(self getcurrentweapon());
            break;
        default:
            self nprintln("ߝ [weapon] * ^+unknown args '" + args + "'. falling back..");
            self thread refill_all_ammo();
            break;
    }
    self playlocalsound("scavenger_pack_pickup");
}

refill_all_ammo()
{
    level endon("game_ended"); // just in case

    items = self.equippedweapons;
    foreach (item in items)
    {
        self givemaxammo(item);
        self setweaponammostock(item, 999);
        self setweaponammoclip(item, 999);
        self setweaponammoclip(item, 999, "left");
        self setweaponammoclip(item, 999, "right");
        // self setweaponammoclip(item, 999, "_encstr_8253060E2B5FE330");
        // self setweaponammoclip(item, 999, "_encstr_9353062E718710C9");
        // self setweaponammoclip(item, 999, "_encstr_A5AD056A019C63");
        // self setweaponammoclip(item, 999, "_encstr_B1AD05C65666E8");
        wait 0.05;
    }
}

refill_weapon_ammo(item)
{
    self givemaxammo(item);
    self setweaponammostock(item, 999);
    self setweaponammoclip(item, 999);
    self setweaponammoclip(item, 999, "left");
    self setweaponammoclip(item, 999, "right");
    // self setweaponammoclip(item, 999, "_encstr_A5AD056A019C63");
    // self setweaponammoclip(item, 999, "_encstr_B1AD05C65666E8");
    // self setweaponammoclip(item, 999, "_encstr_8253060E2B5FE330");
    // self setweaponammoclip(item, 999, "_encstr_9353062E718710C9");
}

// weapon utils so please looook at this -et

givegun(weapon)
{
    if (self getpers("replace_weapon"))
    {
        self takeweapon(self getcurrentweapon());
        wait 0.05;
    }

    self giveweapon(weapon);
    self switchtoweaponimmediate(weapon);
    self refill_weapon_ammo(weapon);
}

give_weapon(weapon) // ??
{
    camo = self getpers("camo");
    variant_id = isdefined(weapon.variantid) ? weapon.variantid : -1;
    new_weapon = undefined;
    weapon_name = weapon.basename;

    if (isstring(weapon))
    {
        if (variant_id >= 0)
        {
            build = scripts\mp\class::buildweapon(weapon, [], "none", "none", variant_id, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap());

            if (isdefined(build))
            {
                new_weapon = build;
            }
        }

        if (!isdefined(new_weapon))
        {
            build = scripts\mp\class::buildweapon(weapon, [], camo, "none", -1, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap());

            if (isdefined(build))
                new_weapon = build;
            else
                new_weapon = getcompleteweaponname(weapon);
        }
    }

    if (!isdefined(new_weapon) || new_weapon.basename == "none")
        self nprintln("invalid weapon: ^1" + weapon_name);
    else
    {
        if (self hasweapon(new_weapon))
        {
            self nprintln("already have: ^5" + weapon_name);
            return;
        }

        real_weapons = self getrealweapons(); // var_7
        weapon_limit = self getpers("max_weapons"); // var_8

        // custom weapon limit
        if (real_weapons.size >= weapon_limit)
        {
            current = self getcurrentweapon();

            if (isdefined(current) && current.basename != "none")
                self scripts\cp_mp\utility\inventory_utility::_takeweapon( current );
        }

        self giveweaponinstant(new_weapon);

#ifndef S4
        scripts\mp\weapons::fixupplayerweapons(self, new_weapon);
#endif

        if (variant_id >= 0)
        {
            self nprintln( "ߝ [weapon] * ^+weapon given: ^7" + weapon + " ^6(variant " + variant_id + ")" );
            return;
        }

        self nprintln( "ߝ [weapon] * ^+weapon given: ^7" + weapon + " ^6(" + camo + ")" );
    }
}

set_camo(camo) // ??
{
    self setpers("camo", camo);
    weapon = self getcurrentweapon();

    if (!isdefined(weapon) || weapon.basename == "none")
        return;

    variant_id = isdefined(weapon.variantid) ? weapon.variantid : -1;
    new_weapon = scripts\mp\class::buildweapon(scripts\mp\utility\weapon::getweaponrootname(weapon), weapon.attachments, camo, "none", variant_id, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap());

    if (!isdefined(new_weapon))
    {
        self nprintln("^1unable to apply camo..");
        return;
    }

    self scripts\cp_mp\utility\inventory_utility::_takeweapon(weapon);
    self giveweaponinstant(new_weapon);
}

giveweaponinstant(weapon)
{
    self scripts\cp_mp\utility\inventory_utility::_giveweapon(weapon);
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate(weapon);
    self refill_weapon_ammo(weapon);
    self playlocalsound("ui_mp_weapon_pickup");
}

// maybe add toggles for barriers and oob but i think they'd rly always be on
allow_oob()
{
    scripts\mp\outofbounds::enableoobimmunity(self);
    
    self.allowedintrigger = 1;
    self.alreadytouchingtrigger = 0;

    if (isdefined(self.vehicle) && isdefined(self.vehicle.health) && self.vehicle.health > 0)
    {
#ifdef S4
        scripts\mp\outofbounds::_id_3964(self.vehicle, 0);
#else
        scripts\mp\outofbounds::clearoob(self.vehicle, 0);
#endif

        self setclientomnvar("ui_out_of_bounds_type", 0 );
        self setclientomnvar("ui_out_of_bounds_countdown", 0);
    }
}

remove_barriers()
{
    init_original_barriers();
    
    foreach (trigger in level.original_barriers.triggers)
    {
        if (isdefined(trigger.entity))
            trigger.entity.origin = (999999, 999999, 999999);
    }

    foreach (barrier in level.original_barriers.barriers)
    {
        if (isdefined(barrier.entity))
            barrier.entity.origin = (999999, 999999, 999999);
    }

    foreach (clip in level.original_barriers.clips)
    {
        if (isdefined(clip.entity))
            clip.entity.origin = (999999, 999999, 999999);
    }

    foreach (singular in level.original_barriers.oncetriggers)
    {
        if (isdefined(singular.entity))
            singular.entity.origin = (999999, 999999, 999999);
    }
}

init_original_barriers()
{
    if (!isdefined(level.original_barriers))
    {
        level.original_barriers = spawnstruct();
        level.original_barriers.triggers = [];
        level.original_barriers.barriers = [];
        level.original_barriers.clips = [];
        level.original_barriers.oncetriggers = [];

        hurt_ents = getentarray("trigger_hurt", "classname");

        for (i=0;i<hurt_ents.size;i++)
        {
            level.original_barriers.triggers[i] = spawnstruct();
            level.original_barriers.triggers[i].entity = hurt_ents[i];
            level.original_barriers.triggers[i].origin = hurt_ents[i].origin;
        }

        barrier_ents = getentarray("barrier", "targetname");

        for (i=0;i<barrier_ents.size;i++)
        {
            level.original_barriers.barriers[i] = spawnstruct();
            level.original_barriers.barriers[i].entity = barrier_ents[i];
            level.original_barriers.barriers[i].origin = barrier_ents[i].origin;
        }

        multi_ents = getentarray("trigger_multiple", "classname");

        for (i=0;i<multi_ents.size;i++)
        {
            level.original_barriers.clips[i] = spawnstruct();
            level.original_barriers.clips[i].entity = multi_ents[i];
            level.original_barriers.clips[i].origin = multi_ents[i].origin;
        }

        singular_ents = getentarray("trigger_once", "classname");

        for (i=0;i<singular_ents.size;i++)
        {
            level.original_barriers.oncetriggers[i] = spawnstruct();
            level.original_barriers.oncetriggers[i].entity = singular_ents[i];
            level.original_barriers.oncetriggers[i].origin = singular_ents[i].origin;
        }
    }
}

save_class()
{
    self.pers["curr_class"] = [];
    self setpers("saved_class", true);

    index = 0;

    foreach(weapon in self.equippedweapons)
    {
        self.pers["curr_class"][index] = weapon;
        index++;
    }

    self iprintln("saved class with ^5" + index + " ^7items");
}

load_class()
{
    if (!self getpers("saved_class"))
    {
        self iprintln("save a class first..");
        return;
    }

    self takeallweapons();

    foreach(weapon in self.pers["curr_class"])
    {
        self giveweapon(weapon);
        // self max_ammo(weapon);
    }

    // self switchtoweapon(self getweaponslistprimaries()[0]);
}

class_manager(args)
{
    switch (args)
    {
        case "save":
            self save_class();
            break;
        case "load":
            self load_class();
            break;
        default:
            self save_class();
            break;
    }
}

reload_class(args)
{
    wait 0.5;
    self load_class();
}

max_ammo(item)
{
    self setweaponammostock(item, 999);
    self setweaponammoclip(item, 999);
}

toggle_elevators()
{
    self.pers["elevators"] = !toggle(self.pers["elevators"]);

    if (self getpers("elevators"))
        self thread elevators();
    else
        self notify("stop_elevators");
}

elevators(args)
{
    self endon("disconnect");
    self endon("stop_elevators");
    level endon("game_ended");

    for(;;)
    {
        if (self adsbuttonpressed() && self isbuttonpressed("+stance") && (self isonground() && !self isonladder() && !self ismantling()))
        {
            self thread elevator_logic();
            wait 0.25;
        }
        wait 0.05;
    }
}

elevator_logic()
{
    self endon("end_ele_logic");
    level endon("game_ended");
    self endon("disconnect");

    self.elevator = spawn("script_origin", self.origin, 1);
    self playerlinkto(self.elevator, undefined);
    self.elevating = true;

    for(;;)
    {
        if (self isbuttonpressed("+gostand"))
        {
            self unlink();
            self.elevator delete();
            self.elevating = undefined;
            self notify("end_ele_logic");
        }

        self.o = self.elevator.origin;
        wait 0.05;
        time = randomintrange(8,20);
        self.elevator.origin = self.o + (0, 0, time);
        wait 0.05;
    }
}

reload_alt_swap(args)
{
    weapon = "iw8_pi_golf21_mp+ammomod_slow+backno_golf21+ironsdefault_golf21+rec_golf21+slide_golf21+xmags_golf21";
    self giveweapon(weapon);
    self.alt_swap_weap = weapon;
}

toggle_alt_swaps()
{
    self.pers["alt_swap"] = !toggle(self.pers["alt_swap"]);
    weapon = "iw8_pi_golf21_mp+ammomod_slow+backno_golf21+ironsdefault_golf21+rec_golf21+slide_golf21+xmags_golf21";
    if (self getpers("alt_swap"))
    {
        self giveweapon(weapon);
    }
    else
    {
        self notify("stop_alt_swap");
        next = self getnextweapon();
        self takeweapon(weapon);
        self switchtoweapon(next);
    }
}

spawnbot()
{
    // ok so the actual bot code kicks the bot no matter what..? yeah ok
    // scripts\mp\bots\bots::spawn_bots(1, "axis", undefined, undefined, undefined, "regular");

    self spawnbotortestclient(); // is this even gonna work ? we dont need the bot to move or anything it could be retarded who cares
}

toggle_perk(perk) // toggle & store perk data
{
    if (self scripts\mp\utility\perk::_hasperk(perk))
    {
        scripts\mp\utility\perk::giveperk(perk);
        self.pers["my_perks"][perk] = perk;
        self iprintln("^5" + perk + " ^7given");
    }
    else
    {
        self scripts\mp\utility\perk::removeperk(perk);
        self.pers["my_perks"][perk] = undefined;
        self iprintln("^5" + perk + " ^7taken");
    }
}

set_perks()
{
    foreach (perk in self.pers["my_perks"])
    {
        if (self.pers["my_perks"].size == 0)
            return;

        scripts\mp\utility\perk::giveperk(perk);
    }
}

alwayscan(weapon)
{
    if (self getpers("instaswap"))
    {
        if (self is_valid_weapon(weapon))
        {
            return;
        }
    }

    self takegood(weapon);
    self givegood(weapon);
    self switchtoweapon(weapon);
}

save_bolt()
{
    x = int(self getpers("boltcount"));
    if (x == 20)
        return self iprintlnbold("^1max bolt points saved");

    x++;
    self setpers("boltcount", x);
    self setpers("boltpos" + x, self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);

    self iprintlnbold("^:bolt point " + x + " saved");
}

delete_last_bolt()
{
    x = int(self getpers("boltcount"));
    if (x == 0)
        return self iprintlnbold("^1no points to delete");

    self setpers("boltpos" + x, "0");
    self iprintlnbold("^+bolt point " + x + " deleted");
    x--;
    self setpers("boltcount", x);
}
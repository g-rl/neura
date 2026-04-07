toggle_headbounces()
{
    self.pers["headbounces"] = !custom_scripts\_util::toggle(self.pers["headbounces"]);
    if (self custom_scripts\_util::getpers("headbounces"))
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
    for (;;)
    {
        foreach(player in level.players)
        if (player != self && distance(player custom_scripts\_util::getorigin_() + (0,0,90), self custom_scripts\_util::getorigin_()) <= 80 && self getvelocity()[2] < -250)
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

    self custom_scripts\_util::nprintlnbold("^5shoot your weapon");

    // interrogation_tools_mp
    self nacto("snapshot_grenade_mp"); // concussion_grenade_mp, iw8_gunless_last_stand_enter falling, ks_gesture_phone_mp phone,

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
        wait 0.05;
        player notify("luinotifyserver", "team_select", 0);
        wait 0.05;
        player notify("luinotifyserver", "class_select", player.class);
        wait 0.05;
        player.sessionstate = "playing";
    }
    else
    {
        player.team = "allies";
        player.sessionstate = "spectator";
        wait 0.05;
        player notify("luinotifyserver", "team_select", 1);
        wait 0.05;
        player notify("luinotifyserver", "class_select", player.class);
        wait 0.05;
        player.sessionstate = "playing";
    }
}

// todo
set_to_gunner(player) {}
set_to_predator(player) {}

togglepers(pers)
{
    self.pers[pers] = !custom_scripts\_util::toggle(self.pers[pers]);
}

setpersmenu(value, pers)
{
    self custom_scripts\_util::setpers(pers, value);
    self play_sound("weap_ammo_pickup");
}

setdvarmenu(value, dvar)
{
    value = float(value);
    setdvar(dvar, value);
    self play_sound("weap_ammo_pickup");
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
        //print(getcompleteweaponname(weapon));
        wait 0.05;
    }
}

print_weapon()
{
    weapon = self getcurrentweapon();
    printall(getcompleteweaponname(weapon));
}

printall(text)
{
    print(text);
    iprintln(text);
    iprintlnbold(text);
}

toggle_freeze_anim_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_freeze_anim_bind(1, i);
    else
        self notify("stop_freeze_anim_bind");
}

do_freeze_anim_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_nac_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            setdvar("pan_freezeanim", !custom_scripts\_util::toggle(getdvarint("pan_freezeanim")));
            wait 0.05;
        }
    }
}

toggle_nac_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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
        if (!self custom_scripts\_util::in_menu())
        {
            self nacto(self getnextweapon());
            wait 0.05;
        }
    }
}

toggle_emptyclip_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_emptyclip_bind(1, i);
    else
        self notify("stop_emptyclip_bind");
}

do_emptyclip_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_emptyclip_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self thread do_emptyclip();
            wait 0.05;
        }
    }
}

toggle_onebullet_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_onebullet_bind(1, i);
    else
        self notify("stop_onebullet_bind");
}

do_onebullet_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_onebullet_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self thread do_clip2one();
            wait 0.05;
        }
    }
}

do_clip2one()
{
    weapon = self getcurrentweapon();
    self setweaponammoclip(weapon, 0 + 1);
}

do_emptyclip()
{
    weapon = self getcurrentweapon();
    self setweaponammoclip(weapon, 0);
}

toggle_shellshock_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_shellshock_bind(1, i);
    else
        self notify("stop_shellshock_bind");
}

do_shellshock_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_shellshock_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self shellshock(self custom_scripts\_util::getpers("shellshock_type"), float(self custom_scripts\_util::getpers("shellshock_amount")));
            wait 0.05;
        }
    }
}

toggle_instaswap_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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
        if (!self custom_scripts\_util::in_menu())
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
            self custom_scripts\_util::nprintlnbold("ߝ [position] * saved @ ^6" + self.origin);
            wait 1;
            self custom_scripts\_util::nprintlnbold(" ");
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
    self custom_scripts\_util::setpers("saveposx", self getorigin()[0]);
    self custom_scripts\_util::setpers("saveposy", self getorigin()[1]);
    self custom_scripts\_util::setpers("saveposz", self getorigin()[2]);
    self custom_scripts\_util::setpers("saveangles1", self getplayerangles()[0]);
    self custom_scripts\_util::setpers("saveangles2", self getplayerangles()[1]);
    self custom_scripts\_util::setpers("saveangles3", self getplayerangles()[2]);
}

reset_position()
{
    self custom_scripts\_util::setpers("saveposx", 0);
    self custom_scripts\_util::setpers("saveposy", 0);
    self custom_scripts\_util::setpers("saveposz", 0);
}

load_spawn()
{
    if (float(self custom_scripts\_util::getpers("saveposx")) == 0 && float(self custom_scripts\_util::getpers("saveposy")) == 0 && float(self custom_scripts\_util::getpers("saveposz")) == 0)
    {
        self custom_scripts\_util::nprintlnbold("^6save a position first");
        return;
    }

    self setvelocity((0, 0, 0));
    self setorigin((float(self custom_scripts\_util::getpers("saveposx")), float(self custom_scripts\_util::getpers("saveposy")), float(self custom_scripts\_util::getpers("saveposz"))));
    self setplayerangles((0, float(self custom_scripts\_util::getpers("saveangles2")), 0));
}

reload_position()
{
    posx = self custom_scripts\_util::getpers("saveposx");
    posy = self custom_scripts\_util::getpers("saveposy");
    posz = self custom_scripts\_util::getpers("saveposz");

    if (!isdefined(posx))
        return;

    if (float(posx) != 0 && float(posy) != 0 && float(posz) != 0)
    {
        self load_spawn();
    }
}

toggle_snl()
{
    self.pers["snl"] = !custom_scripts\_util::toggle(self.pers["snl"]);

    if (self custom_scripts\_util::getpers("snl"))
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
    self.pers["invincible"] = !custom_scripts\_util::toggle(self.pers["invincible"]);

    if (self custom_scripts\_util::getpers("invincible"))
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

        if (custom_scripts\_util::is_true(self.no_damage))
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
        self custom_scripts\_util::nprintln("ufo mode ^2on");
        self.isactive = 0;
        self.noclipmonitor = 1;
        self thread noclip_monitor();
    }
    else if (self.pers["ufo_mode"])
    {
        self custom_scripts\_util::nprintln("ufo mode ^1off");
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
    if (!self.pers["instaswaps"])
    {
        self custom_scripts\_util::nprintln("bo2 instaswaps ^2on");
        self thread do_instaswaps();
    }
    else if (self.pers["instaswaps"])
    {
        self custom_scripts\_util::nprintln("bo2 instaswaps ^1off");
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
        self waittill("button_pressed_+frag"); // add lb instaswaps later too

        if (isdefined(self.is_swapping))
        {
            continue;
        }

        self.is_swapping = true;

        wait (float(self custom_scripts\_util::getpers(("instaswaps_time"))));
        self switchto(self getprevweapon());

        self.is_swapping = undefined;
    }
}

aimbot()
{
    self.pers["aimbot"] = !custom_scripts\_util::toggle(self.pers["aimbot"]);

    if (self custom_scripts\_util::getpers("aimbot"))
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
        range = int(self custom_scripts\_util::getpers("aimbot_range"));
        delay = float(self custom_scripts\_util::getpers("aimbot_delay"));

        current = self getcurrentweapon();

        foreach (player in level.players)
        {
            if (!isdefined(player) || !isalive(player))
                continue;

            if (custom_scripts\_util::is_valid_weapon(current))
            {
                if (player != self)
                {
                    if (distance(player.origin, center) < range)
                    {
                        if (delay > 0)
                        {
                            wait (delay);
                        }

#ifdef IW9
                        // IW9 adds a undefined partname parameter, as well as weird indexes that always look the same
                        player thread [[level.callbackPlayerDamage]]( self, self, 350, 0, "MOD_RIFLE_BULLET", randomfloatrange(20.0, 50.0), self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", randomintrange(0, 66), 0, undefined, 1, 102 );
#else
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
    self.pers["autoprone"] = !custom_scripts\_util::toggle(self.pers["autoprone"]);

    if (self custom_scripts\_util::getpers("autoprone"))
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

        if (self custom_scripts\_util::getpers("autoprone_mode") == "air")
        {
            if (self isonground() || self isonladder())// || self ismantling())
                continue;
        }

        if (custom_scripts\_util::is_valid_weapon(weapon))
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
    self.pers["autoreload"] = !custom_scripts\_util::toggle(self.pers["autoreload"]);

    if (self custom_scripts\_util::getpers("autoreload"))
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
    stock = self getweaponammostock(x);
    if (stock == 0) self setweaponammostock(x, 1);

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
            self custom_scripts\_util::nprintln("^6use canswap, current, alt, primary, or all..");
            break;        
    }
}

monitor_dvars()
{
    /*
    level endon("game_ended");
    self endon("disconnect");
    custom_scripts\_util::waittill_prematch_over();
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
    self.pers["inf_eq"] = !custom_scripts\_util::toggle(self.pers["inf_eq"]);

    if (self custom_scripts\_util::getpers("inf_eq"))
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

manage_bounce(args)
{
    switch (args)
    {
        case "spawn":
            self thread spawn_bounce();
            break;
        case "delete":
            self thread delete_bounce();
            break;
        default:
            self custom_scripts\_util::nprintln("^6use spawn or delete..");
            break;        
    }
}

spawn_bounce()
{
    x = int(self custom_scripts\_util::getpers("bouncecount"));
    x++;

    self custom_scripts\_util::setpers("bouncecount", x);
    self custom_scripts\_util::setpers("bouncepos" + x, self custom_scripts\_util::getorigin_()[0] + "," + self custom_scripts\_util::getorigin_()[1] + "," + self custom_scripts\_util::getorigin_()[2]);
    self custom_scripts\_util::nprintln("bounce #" + x + " spawned at ^6" + self custom_scripts\_util::getorigin_());

    if (x == 1)
    {
        self notify("stop_bounce_loop");
        self thread monitor_bounces();
    }
}

delete_bounce()
{
    x = int(self custom_scripts\_util::getpers("bouncecount"));

    if (x == 0)
        return self custom_scripts\_util::nprintln("^1no bounces to delete");

    x--;
    self custom_scripts\_util::setpers("bouncecount", x);
    self custom_scripts\_util::nprintln("^7bounce #^5" + x + " ^7deleted");
}

monitor_bounces()
{
    self endon("stop_bounce_loop");
    self endon("disconnect");
    level endon("game_ended");
    
    for (;;)
    {
        for (i = 1; i < int(self custom_scripts\_util::getpers("bouncecount")) + 1; i++)
        {
            pos = custom_scripts\_util::perstovector(self custom_scripts\_util::getpers("bouncepos" + i));

            if (distance(self custom_scripts\_util::getorigin_(), pos) < 90 && self getvelocity()[2] < -250) // ? custom_scripts\_util::getorigin_ is messing this up i think
            {
                self setvelocity(self getvelocity() - (0, 0, self getvelocity()[2] * 2));
                wait 0.2;
            }
        }
        wait 0.05;
    }
}

watch_frozen_bots()
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
                player freezecontrols(self custom_scripts\_util::getpers("frozen_bots"));
            }
            wait 0.05;
        }
        wait 0.05;
    }
}

move_bots(args)
{
    level endon("game_ended"); // just in case

    switch (args)
    {
        case "self":
            foreach (player in level.players) 
            {
                if (isai(player) || isbot(player)) 
                {
                    player setorigin(self.origin);
                    player thread save_spawn();
                    self custom_scripts\_util::nprintln("trying to move all bots to ^5" + self.origin);
                    self play_sound("recon_drone_marked_owner");
                }
            }
        break;
        case "crosshair":
            foreach (player in level.players) 
            {
                if (isai(player) || isbot(player)) 
                {
                    player setorigin(self getcrosshair());
                    player thread save_spawn();
                    self custom_scripts\_util::nprintln("trying to move all bots to ^5" + self getcrosshair());
                    self play_sound("recon_drone_marked_owner");
                }
            }
            break;
        default:
            break;
    }
}

kill_player(player)
{
    player suicide();
    self custom_scripts\_util::nprintln("killed ^1" + player.name);
}

teleport_player(from, to, player)
{
    if (from == to)
    {
        from custom_scripts\_util::nprintln("^1you cannot teleport to yourself.");
        return;
    }

    from setorigin(to.origin);
    player thread save_spawn();
}

manage_teleport(args, player)
{
    switch (args)
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

    custom_scripts\_util::waittill_prematch_over();

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
        // self thread give_perks();
        wait 0.05;
    }
}

toggle_eq_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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

        if (!self custom_scripts\_util::in_menu())
        {
            x = self getcurrentweapon();
            self nacto(self custom_scripts\_util::getpers("eq_weapon"));

            if (self custom_scripts\_util::getpers("eq_putaway"))
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
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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
        if (!self custom_scripts\_util::in_menu())
        {
            player = self custom_scripts\_util::getenemyplayer();
            if (player == self)
            {
                self iprintlnbold("^5spawn an enemy");
                continue;
            }

            active = false;

            if (self custom_scripts\_util::getpers("invincible") == 1) 
                active = true;

            if (active) 
                self.no_damage = false;

            old_health = self.maxhealth;
            self.health = 100;
            self.maxhealth = 100;

            self [[level.callbackPlayerDamage]](player, player, int(self custom_scripts\_util::getpers("damage_amount")), 8, "MOD_RIFLE_BULLET", self getcurrentweapon(), self.origin, (0,0,0), "neck", 0 );
            
            if (active) 
                self.no_damage = true;

            self.health = old_health;
            self.maxhealth = old_health;
        }
     }
}

fire_at_player(item)
{
    if (!isdefined(item))
    {
        item = "semtex_mp";
    }
    
    // idk if imma need this
    player = self custom_scripts\_util::getenemyplayer();
    if (player == self)
    {
        self iprintlnbold("^5spawn an enemy");
        return;
    }
    
    grenade = magicgrenademanual(item, self.origin, (0, 0, 0), 3);
    grenade.angles = self.angles;
    grenade linkto(self, "tag_origin");

    i = undefined;
    switch (item)
    {
        case "semtex_mp":
        case "semtex_bolt_mp":
            i = "semtex_stuck";
            break;
        case "molotov_mp":
            i = "molotov_stuck";
            break;
        case "pop_rocket_proj_mp":
            i = "flare_gun_attacker_stuck";
            break;
        case "thermite_mp":
            i = "thermite_attacker_stuck";
            break;            
    }
    
    thread scripts\mp\weapons::grenadestucktosplash(i, self);
}

toggle_illusion_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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

        if (!self custom_scripts\_util::in_menu())
        {
            self setspawnweapon(self getcurrentweapon());
        }
    }
}

toggle_stuck_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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

        if (!self custom_scripts\_util::in_menu())
        {
            player = self custom_scripts\_util::getenemyplayer();

            if (player == self)
            {
                self iprintlnbold("^5spawn an enemy first");
                continue;
            }

            // TODO: not sure if IW9 works for this yet..
            thread scripts\mp\weapons::grenadestuckto(self, player, self custom_scripts\_util::getpers("stuck_weapon") + "_mp");
        }
    }
}

toggle_spectator_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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

        if (!self custom_scripts\_util::in_menu())
        {
            if (self.sessionstate == "playing")
                self scripts\mp\utility\player::updatesessionstate("spectator");
            else
                self scripts\mp\utility\player::updatesessionstate("playing");
        }
    }
}

toggle_scavenger_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_scavenger_bind(1, i);
    else
        self notify("stop_scavenger_bind");
}

do_scavenger_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_scavenger_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_util::in_menu())
        {
#ifdef IW9
            self _id_5762AC2F22202BA2::hudicontype("scavenger");
#elifdef S4
            self _id_07C4::_id_7B6B("scavenger");
#else
            self scripts\mp\damagefeedback::hudicontype("scavenger");
#endif

            self play_sound("scavenger_pack_pickup");

            if (self custom_scripts\_util::getpers("real_scavenger"))
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
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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

        if (!self custom_scripts\_util::in_menu())
        {
            self start_bolt();
        }
    }
}

toggle_bot_bolt_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_bot_bolt_bind(1, i);
    else
        self notify("stop_bot_bolt_bind");
}

do_bot_bolt_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_bot_bolt_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_util::in_menu())
        {
            self start_bot_bolt();
        }
    }
}

start_bolt()
{
    x = int (self custom_scripts\_util::getpers("boltcount"));
    if (x == 0)
        return self iprintlnbold("^1set bolt points first");

    bolt_model = spawn("script_model", self.origin);
    bolt_model setmodel("tag_origin");
    self.current_bolt = bolt_model; // store
    self playerlinkto(bolt_model);

    for (i=1; i<(x + 1); i++)
    {
        keys = strtok(self custom_scripts\_util::getpers("boltpos" + i), ",");
        position = (float(keys[0]), float(keys[1]), float(keys[2]));
        bolt_model moveto(position, float(self custom_scripts\_util::getpers("boltspeed")), 0, 0);
        wait float(self custom_scripts\_util::getpers("boltspeed"));
    }

    self unlink();
    bolt_model delete();
}

start_bot_bolt()
{
    x = int (self custom_scripts\_util::getpers("bot_boltcount"));
    if (x == 0)
        return self iprintlnbold("^1set bot bolt points first");

    player = self custom_scripts\_util::getenemyplayer();
    if (player == self)
    {
        self iprintlnbold("^5spawn an enemy");
        return;
    }

    bolt_model = spawn("script_model", player.origin);
    bolt_model setmodel("tag_origin");
    player.current_bolt = bolt_model; // store
    player playerlinkto(bolt_model);

    for (i=1; i<(x + 1); i++)
    {
        keys = strtok(self custom_scripts\_util::getpers("bot_boltpos" + i), ",");
        position = (float(keys[0]), float(keys[1]), float(keys[2]));
        bolt_model moveto(position, float(self custom_scripts\_util::getpers("bot_boltspeed")), 0, 0);
        wait float(self custom_scripts\_util::getpers("bot_boltspeed"));
    }

    player unlink();
    bolt_model delete();
}

save_bolt()
{
    x = int(self custom_scripts\_util::getpers("boltcount"));
    if (x == 20)
        return self custom_scripts\_util::nprintln("^1max bolt points saved");

    x++;
    self custom_scripts\_util::setpers("boltcount", x);
    self custom_scripts\_util::setpers("boltpos" + x, self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);

    self custom_scripts\_util::nprintlnbold("^:bolt point " + x + " saved");
}

delete_last_bolt()
{
    x = int(self custom_scripts\_util::getpers("boltcount"));
    if (x == 0)
        return self iprintlnbold("^1no points to delete");

    self custom_scripts\_util::setpers("boltpos" + x, "0");
    self iprintlnbold("^+bolt point " + x + " deleted");
    x--;
    self custom_scripts\_util::setpers("boltcount", x);
}

save_bot_bolt()
{
    x = int(self custom_scripts\_util::getpers("bot_boltcount"));
    if (x == 20)
        return self custom_scripts\_util::nprintln("^1max bot bolt points saved");

    x++;
    self custom_scripts\_util::setpers("bot_boltcount", x);
    self custom_scripts\_util::setpers("bot_boltpos" + x, self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);

    self custom_scripts\_util::nprintlnbold("^:bot bolt point " + x + " saved");
}

delete_last_bot_bolt()
{
    x = int(self custom_scripts\_util::getpers("bot_boltcount"));
    if (x == 0)
        return self iprintlnbold("^1no points to delete");

    self custom_scripts\_util::setpers("bot_boltpos" + x, "0");
    self iprintlnbold("^+bot bolt point " + x + " deleted");
    x--;
    self custom_scripts\_util::setpers("bot_boltcount", x);
}

toggle_velocity_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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

        if (!self custom_scripts\_util::in_menu())
        {
            self setvelocity((float(self custom_scripts\_util::getpers("velx")), float(self custom_scripts\_util::getpers("vely")), float(self custom_scripts\_util::getpers("velz"))));
        }
    }
}

toggle_canswap_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
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

        if (!self custom_scripts\_util::in_menu())
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
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_class_bind(1, i);
    else
        self notify("stop_class_bind");
}

reload_class_bind(args, slot)
{   
    custom_scripts\_util::waittill_prematch_over();
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

        if (!self custom_scripts\_util::in_menu())
        {
            index = int(scripts\mp\class::getclassindex(self.class) + 1);
            index++;

            if (index > int(self custom_scripts\_util::getpers("class_wrap"))) 
            {
                index = 1;
            }

            self.class = "custom" + index;
            scripts\mp\class::setclass(self.class);
            self.tag_stowed_back = undefined;
            self.tag_stowed_hip = undefined;
            scripts\mp\class::giveloadout(self.pers["team"], self.class);

            self thread always_can_delay();

            super = scripts\mp\supers::getcurrentsuper();
            if (isdefined(super)) // supers = field upgrade
            {
                self thread scripts\mp\supers::givesuperweapon(super);
                self thread scripts\mp\supers::givesuperpoints(scripts\mp\supers::getsuperpointsneeded());
            }
        }
    }
}

always_can_delay()
{
    wait 0.05;

    // TODO: nyli fix this - you register instaswaps pers, but you're doing instaswaps_1 like a index which fails the getpers check
    /*
    if (self custom_scripts\_util::getpers("class_can"))
    {
        self alwayscan(self getcurrentweapon());
    }
    */
}

give_perks()
{
    custom_scripts\_util::waittill_prematch_over();

    wait 0.05;

    if (isdefined(self custom_scripts\_util::getpers("soh")))
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

round_manager(args)
{
    switch (args)
    {
        case "random":
            random_rounds();
            break;
        case "reset":
            reset_rounds();
            break;
        default:
            break;
    }
}

random_rounds()
{
    random_round_axis = randomint(4);
    random_round_ally = randomint(4);
    rounds_played = (random_round_axis + random_round_ally);
    game["roundsWon"]["axis"] = random_round_axis;
    game["roundsWon"]["allies"] = random_round_ally;
    game["teamScores"]["allies"] = random_round_ally;
    game["teamScores"]["axis"] = random_round_axis;
    game["roundsplayed"] = rounds_played;
    game["switchedsides"] = 0;
}

reset_rounds()
{
    game["roundsWon"]["axis"] = 0;
    game["roundsWon"]["allies"] = 0;
    game["teamScores"]["allies"] = 0;
    game["teamScores"]["axis"] = 0;
    game["roundsplayed"] = 0;
    game["switchedsides"] = 0;
}

toggle_clean_kc()
{
    self.pers["clean_kc"] = !custom_scripts\_util::toggle(self.pers["clean_kc"]);

    if (self custom_scripts\_util::getpers("clean_kc"))
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
        if (self custom_scripts\_util::getpers("elem_itemtype"))
        {
            self setclientomnvar("ui_killcam_killedby_item_type", -1);
            self setclientomnvar("ui_killcam_killedby_item_id", -1);
            self setclientomnvar("ui_killcam_killedby_id", -1);
            self setclientomnvar("ui_killcam_killedby_loot_variant_id", -1);
            self setclientomnvar("ui_killcam_killedby_weapon_rarity", -1);
        }

        if (self custom_scripts\_util::getpers("elem_victim"))
        {
            self setclientomnvar("ui_killcam_victim_id", -1);
        }

        if (self custom_scripts\_util::getpers("elem_perks"))
        {
            for (x = 0; x < 6; x++)
                self setclientomnvar( "ui_killcam_killedby_perk" + x, -1 );
        }

        wait 0.05;
    }
}

// wait till prematch is over for prints because the game does some weird third person cinematic
post_prematch_start()
{
    level endon("game_ended");
    self endon("disconnect");
    custom_scripts\_util::waittill_prematch_over();
        
    self iprintln("^6neura " + level._client + " ^7by * ^+@nyli2b ^2@mjkzy ^5@machinxry^7*");
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

give_player_shield(player, shield)
{
    player giveweapon(shield);
    player setspawnweapon(shield);
    player setorigin(player.origin - (0,0,2));
    player custom_scripts\_util::setpers("bot_weapon", shield);
}

set_bot_weapon(player, weapon)
{
    player giveweapon(weapon);
    player setspawnweapon(weapon);
    player custom_scripts\_util::setpers("bot_weapon", getcompleteweaponname(weapon));
}

teleport_to_cross(player)
{
    crosshair = self getcrosshair();
    player setorigin(crosshair);
    self look_at_me(player);
    player thread save_spawn();
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
            self custom_scripts\_util::nprintln("ߝ [weapon] * ^+unknown args '" + args + "'. falling back..");
            self thread refill_all_ammo();
            break;
    }
    self play_sound("scavenger_pack_pickup");
}

refill_all_ammo()
{
    level endon("game_ended"); // just in case

    items = self inventory();
    foreach (item in items)
    {
        self givemaxammo(item);
        self setweaponammostock(item, 999);
        self setweaponammoclip(item, 999);
        self setweaponammoclip(item, 999, "left");
        self setweaponammoclip(item, 999, "right");
        // these make the game hitch really badly
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
    // these make the game hitch really badly
    // self setweaponammoclip(item, 999, "_encstr_A5AD056A019C63");
    // self setweaponammoclip(item, 999, "_encstr_B1AD05C65666E8");
    // self setweaponammoclip(item, 999, "_encstr_8253060E2B5FE330");
    // self setweaponammoclip(item, 999, "_encstr_9353062E718710C9");
}

givegun(weapon) // test give_weapon later and use that instead
{
    if (self custom_scripts\_util::getpers("replace_weapon"))
    {
        self takeweapon(self getcurrentweapon());
        wait 0.05;
    }

    self giveweapon(weapon);
    self switchtoweaponimmediate(weapon);
    self refill_weapon_ammo(weapon);
}

give_streak(streak)
{
    if (!isdefined(streak))
    {
        saved = self custom_scripts\_util::getpers("saved_streak");
        if (saved != "none")
        {
            self thread give_streak(saved);
            return;
        }
    }

    self custom_scripts\_util::setpers("saved_streak", streak);
    struct = scripts\mp\killstreaks\killstreaks::createstreakitemstruct(streak);
    if (!isdefined(struct))
    {
        self iprintlnbold("invalid killstreak: ^1" + streak);
        return;
    }

    if (self custom_scripts\_util::getpers("ks_auto_use"))
    {
        wait 0.05;
        self notify("ks_action_4");
    }

    self play_sound("ui_killstreak_select");
    scripts\mp\killstreaks\killstreaks::awardkillstreakfromstruct(struct, "other");
}

give_weapon(weapon) // gonna guess this works now maybe?
{
    camo = self custom_scripts\_util::getpers("camo");
    variant_id = isdefined(weapon.variantid) ? weapon.variantid : -1;
    new_weapon = undefined;
    weapon_name = weapon.basename;

    if (isstring(weapon))
    {
        if (variant_id >= 0)
        {
            build = build_weapon_wrapper(weapon, [], "none", "none", variant_id, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap());

            if (isdefined(build))
            {
                new_weapon = build;
            }
        }

        if (!isdefined(new_weapon))
        {
            build = build_weapon_wrapper(weapon, [], camo, "none", -1, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap());

            if (isdefined(build))
                new_weapon = build;
            else
                new_weapon = getcompleteweaponname(weapon);
        }
    }

    if (!isdefined(new_weapon) || new_weapon.basename == "none")
        self custom_scripts\_util::nprintln("invalid weapon: ^1" + weapon_name);
    else
    {
        if (self hasweapon(new_weapon))
        {
            self custom_scripts\_util::nprintln("already have: ^5" + weapon_name);
            return;
        }

        real_weapons = self getrealweapons(); // var_7
        weapon_limit = self custom_scripts\_util::getpers("max_weapons"); // var_8

        // custom weapon limit
        if (real_weapons.size >= weapon_limit)
        {
            current = self getcurrentweapon();

            if (isdefined(current) && current.basename != "none")
                self scripts\cp_mp\utility\inventory_utility::_takeweapon( current );
        }

        self giveweaponinstant(new_weapon);

#ifndef S4 // not in s4
        scripts\mp\weapons::fixupplayerweapons(self, new_weapon);
#endif

        if (variant_id >= 0)
        {
            self custom_scripts\_util::nprintln( "ߝ [weapon] * ^+weapon given: ^7" + weapon + " ^6(variant " + variant_id + ")" );
            return;
        }

        self custom_scripts\_util::nprintln( "ߝ [weapon] * ^+weapon given: ^7" + weapon + " ^6(" + camo + ")" );
    }
}

set_camo(camo) // ??
{
    self custom_scripts\_util::setpers("camo", camo);
    weapon = self getcurrentweapon();

    if (!isdefined(weapon) || weapon.basename == "none")
        return;

    variant_id = isdefined(weapon.variantid) ? weapon.variantid : -1;

#ifdef IW9
    weapon_root_name = _id_2669878CF5A1B6BC::getweaponrootname(weapon);
#else
    weapon_root_name = scripts\mp\utility\weapon::getweaponrootname(weapon);
#endif

    new_weapon = build_weapon_wrapper(weapon_root_name, weapon.attachments, camo, "none", variant_id, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap());

    if (!isdefined(new_weapon))
    {
        self custom_scripts\_util::nprintln("^1unable to apply camo..");
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
    self play_sound("ui_mp_weapon_pickup");
}

toggle_barriers()
{
    self.pers["barriers"] = !custom_scripts\_util::toggle(self.pers["barriers"]);
    if (self custom_scripts\_util::getpers("barriers"))
    {
        self thread remove_barriers();
    }
    else
    {
        self thread restore_barriers();
    }
}

toggle_oob()
{
    self.pers["oob"] = !custom_scripts\_util::toggle(self.pers["oob"]);
    if (self custom_scripts\_util::getpers("oob"))
    {
        self thread disable_oob();
    }
    else
    {
        self thread enable_oob();
    }
}

disable_oob(args)
{
    scripts\mp\outofbounds::enableoobimmunity(self);
    
    self.allowedintrigger = 1;
    self.alreadytouchingtrigger = 0;

    if (isdefined(self.vehicle) && isdefined(self.vehicle.health) && self.vehicle.health > 0)
    {
        scripts\mp\outofbounds::clearoob(self.vehicle, 0);
        self setclientomnvar("ui_out_of_bounds_type", 0 );
        self setclientomnvar("ui_out_of_bounds_countdown", 0);
    }
}

enable_oob(args)
{
    scripts\mp\outofbounds::disableoobimmunity(self);
    self.allowedintrigger = 0;

    if (isdefined(self.alreadytouchingtrigger))
        self.alreadytouchingtrigger = undefined;
}

remove_barriers(args)
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

restore_barriers(args)
{
    foreach (var_1 in level.original_barriers.triggers)
    {
        if (isdefined(var_1.entity) && isdefined(var_1.origin))
            var_1.entity.origin = var_1.origin;
    }

    foreach (var_4 in level.original_barriers.barriers)
    {
        if ( isdefined(var_4.entity) && isdefined(var_4.origin))
            var_4.entity.origin = var_4.origin;
    }

    foreach (var_7 in level.original_barriers.clips)
    {
        if (isdefined(var_7.entity) && isdefined(var_7.origin))
            var_7.entity.origin = var_7.origin;
    }

    foreach (var_10 in level.original_barriers.oncetriggers)
    {
        if (isdefined(var_10.entity) && isdefined(var_10.origin))
            var_10.entity.origin = var_10.origin;
    }
}

init_original_barriers(args)
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
    self custom_scripts\_util::setpers("saved_class", true);

    index = 0;

    foreach(weapon in self inventory())
    {
        self.pers["curr_class"][index] = weapon;
        index++;
    }

    self custom_scripts\_util::nprintln("saved class with ^5" + index + " ^7items");
}

toggle_load_class_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_load_class_bind(1, i);
    else
        self notify("stop_load_class_bind");
}

do_load_class_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_load_class_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self thread load_class();
            wait 0.05;
        }
    }
}

load_class(args)
{
    if (!self custom_scripts\_util::getpers("saved_class"))
    {
        if (!isdefined(args)) // loadpers
        {
            self iprintln("save a class first..");
        }
        return;
    }

    self takeallweapons();
    foreach(weapon in self.pers["curr_class"])
    {
        if (weapon.basename == "none")
            continue;

        self giveweapon(weapon);
    }

    self switchto(self getweaponslistprimaries()[0]);
}

position_manager(args)
{
    switch (args)
    {
        case "save":
            self thread save_spawn();
            break;
        case "load":
            self thread load_spawn();
            break;
        default:
            self thread save_spawn();
            break;        
    }
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
    self.pers["elevators"] = !custom_scripts\_util::toggle(self.pers["elevators"]);

    if (self custom_scripts\_util::getpers("elevators"))
        self thread elevators();
    else
        self notify("stop_elevators");
}

elevators(args)
{
    self endon("disconnect");
    self endon("stop_elevators");
    level endon("game_ended");

    for (;;)
    {
        if (self adsbuttonpressed() && self custom_scripts\_util::isbuttonpressed("+stance") && (self isonground() && !self isonladder() && !self ismantling()))
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

    for (;;)
    {
        if (self custom_scripts\_util::isbuttonpressed("+gostand"))
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
    self.pers["alt_swap"] = !custom_scripts\_util::toggle(self.pers["alt_swap"]);
    weapon = "iw8_pi_golf21_mp+ammomod_slow+backno_golf21+ironsdefault_golf21+rec_golf21+slide_golf21+xmags_golf21";
    if (self custom_scripts\_util::getpers("alt_swap"))
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

/* 
spawnbot()
{
    // ok so the actual bot code kicks the bot no matter what..? yeah ok
    // scripts\mp\bots\bots::spawn_bots(1, "axis", undefined, undefined, undefined, "regular");

#ifndef S4
    self spawnbotortestclient(); // is this even gonna work ? we dont need the bot to move or anything it could be retarded who cares
#endif
}
*/

/* 
toggle_perk(perk) // toggle & store perk data
{
    has_perk = scripts\mp\utility\perk::_hasperk(perk);
    if (has_perk)
    {
        scripts\mp\utility\perk::giveperk(perk);
        self.pers["my_perks"][perk] = perk;
        self custom_scripts\_util::nprintln("^5" + perk + " ^7given");
    }
    else
    {
        self scripts\mp\utility\perk::removeperk(perk);
        self.pers["my_perks"][perk] = undefined;
        self custom_scripts\_util::nprintln("^5" + perk + " ^7taken");
    }
}
*/

set_perks()
{
    foreach (perk in self.pers["my_perks"])
    {
        if (!isdefined(self.pers["my_perks"][perk]))
            return;

        scripts\mp\utility\perk::giveperk(perk);
    }
}

nacto(weapon)
{
    x = self getcurrentweapon();
    self takegood(x);
    if (!self hasweapon(weapon))
    self giveweapon(weapon);
    self switchtoweapon(weapon);
    wait 0.05;
    self givegood(x);
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
    weapons = self scripts\cp_mp\utility\inventory_utility::getcurrentprimaryweaponsminusalt();
    for (i = 0; i < weapons.size; i++)
    {
        // IW8 and S4 has this
        if (issubstr(weapons[i].basename, "knifestab"))
        {
            weapons[i] = undefined;
        }

        // IW9 seems to have a diveknife & climbfists on the class
        if (issubstr(weapons[i].basename, "diveknife") || issubstr(weapons[i].basename, "climbfists"))
        {
            weapons[i] = undefined;
        }
    }

    return weapons;
}

getprevweapon() 
{
    weapons = self getrealweapons();
    x = self getcurrentweapon();
    for (i = 0 ; i < weapons.size ; i++)
    {
        if (x == weapons[i])
        {
            y = i - 1;
            if (y < 0)
                y = i + 1;

            if (isdefined(weapons[y]))
                return weapons[y];
            return weapons[0];
        }
    }
}

inventory()
{
    return self.equippedweapons;
}

instaswapto(weapon)
{
    x = self getcurrentweapon();
    self takegood(x);
    if (!self hasweapon(weapon))
    self giveweapon(weapon);
    self setspawnweapon(weapon);
    wait 0.05;
    self givegood(x);
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

getcrosshair()
{
    point = scripts\engine\trace::_bullet_trace(self geteye(), self geteye() + anglestoforward(self getplayerangles()) * 1000000, 0, self)["position"];
    return point;
}

// both games
build_weapon_wrapper( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
#ifdef IW9
    // last 2 parameters are new, undefine them
    return _id_2669878CF5A1B6BC::buildweapon(var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, undefined, undefined);
#else
    return scripts\mp\class::buildweapon(var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8);
#endif
}

play_sound(sound)
{
    if (!self custom_scripts\_util::getpers("sounds")) return;

    if (!soundexists(sound)) // fallback
        sound = "scavenger_pack_pickup";

    wait 0.05; // we need a delay here because the game hitches sometimes?
    self playlocalsound(sound);
}

spawnbot(team, amount)
{
    if (!isdefined(team))
        team = "axis";
    
    if (!isdefined(amount))
        amount = 1;

    level thread [[level.bot_funcs["bots_spawn"]]](amount, team);
}

try_to_flash()
{
    amount = int(self custom_scripts\_util::getpers("flash_amount"));
    x = max(3, amount * 0.75);
    self shellshock("flashbang_mp", x);
    self.flashendtime = gettime() + x * 1000;
    self thread flashrumbleloop(0.75);
}

flashrumbleloop(num)
{
    self endon("stop_monitoring_flash");
    self endon("flash_rumble_loop");
    self notify("flash_rumble_loop");
    loop_time = gettime() + num * 1000;

    while (gettime() < loop_time)
    {
        self playrumbleonentity("damage_heavy");
        wait 0.05;
    }
}
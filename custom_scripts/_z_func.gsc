#include custom_scripts\_util; // this is okay to do as _util doesnt include anything

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

one_handed_gun()
{
    if (!isalive(self))
        return;

    is_prematch_done = game["flags"]["prematch_done"];
    if (!is_prematch_done)
        return;

    self custom_scripts\_util::nprintlnbold("^5shoot your weapon");

    // interrogation_tools_mp
    self nacto("snapshot_grenade_mp", true); // concussion_grenade_mp, iw8_gunless_last_stand_enter falling, ks_gesture_phone_mp phone,

    wait 2;
    self notify("luinotifyserver", "class_select", self.class);
    index = int(scripts\mp\class::getclassindex(self.class) + 1);
    self.class = "custom" + index;
    scripts\mp\class::setclass(self.class);
    self.tag_stowed_back = undefined;
    self.tag_stowed_hip = undefined;
    scripts\mp\class::giveloadout(self.pers["team"], self.class);
    super = scripts\mp\supers::getcurrentsuper();
    self.pers["class"] = self.class;
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

set_knockback(value, dvar)
{
    value = float(value);
    setdvar(dvar, value);
    self setclientdvar(dvar, value);
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
        //print_safe(getcompleteweaponname(weapon));
        wait 0.05;
    }
}

print_weapon()
{
    weapon = self getcurrentweapon();
    printall(getcompleteweaponname(weapon), true);
}

printall(text, console)
{
    // on every other game, this will go to console no matter what
    iprintln(text);
    iprintlnbold(text);
}

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
        foreach (player in level.players)
        if (player != self && distance(player custom_scripts\_util::getorigin_() + (0, 0, 90), self custom_scripts\_util::getorigin_()) <= 80 && self getvelocity()[2] < -250)
        {
            self setvelocity(self getvelocity() - (0, 0, self getvelocity()[2] * 2));
            wait 0.2;
        }
        wait 0.05;
    }
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
    self endon("stop_freeze_anim_bind");
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
    self endon("showing_final_killcam");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self nacto(self getnextweapon(), true);
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

    if (self.sessionstate == "spectator") return;

    self setvelocity((0, 0, 0));
    self setorigin((float(self custom_scripts\_util::getpers("saveposx")), float(self custom_scripts\_util::getpers("saveposy")), float(self custom_scripts\_util::getpers("saveposz"))));
    self setplayerangles((float(self custom_scripts\_util::getpers("saveangles1")), float(self custom_scripts\_util::getpers("saveangles2")), float(self custom_scripts\_util::getpers("saveangles3"))));
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

always_nac()
{
    if (!self.pers["always_nac"])
    {
        self thread do_always_nac();
    }
    else if (self.pers["always_nac"])
    {
        self notify("stop_always_nac");
    }

    self.pers["always_nac"] = !self.pers["always_nac"];
}

do_always_nac(args)
{
    self endon("disconnect");
    self endon("showing_final_killcam");
    self endon("stop_always_nac");

    for (;;)
    {
        self waittill("button_pressed_+weapnext");
        self nacto(self getprevweapon(), self.round_has_ended);
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

                        effect = self custom_scripts\_util::getpers("kill_effect");
                        origin = player getorigin();
                        
                            // IW9 adds a undefined partname parameter, as well as weird indexes that always look the same
#ifdef IW9
                            player thread [[level.callbackPlayerDamage]]( self, self, 350, 0, "MOD_RIFLE_BULLET", randomfloatrange(20.0, 50.0), self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", randomintrange(0, 66), 0, undefined, 1, 102 );
#else
                            player thread [[level.callbackPlayerDamage]]( self, self, player.health, 2, "MOD_RIFLE_BULLET", self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", 0 );
#endif
                        if (level._client != "s4") // s4 already has these pretty well idk ab mw22 oops
                        {
                            if (self getpers("kill_effects"))
                            {
                                player thread play_effect(effect, origin);
                            }
                        }
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
    self endon("showing_final_killcam");

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
    self endon("showing_final_killcam");

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
                /* 
                player scripts\common\utility::allow_fire(0);
                player scripts\common\utility::allow_movement(0);
                player scripts\common\utility::allow_jump(0);
                player scripts\common\utility::allow_usability(0);
                player scripts\common\utility::allow_melee(0);
                player scripts\common\utility::allow_offhand_weapons(0);
                player scripts\common\utility::allow_weapon_switch(0);
                player scripts\common\utility::allow_sprint(0);
                */
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
                    if (player.sessionstate == "spectator") return;
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
                    if (player.sessionstate == "spectator") return;
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

    if (from.sessionstate == "spectator") return;
    from setorigin(to.origin);
    player thread save_spawn();
    self play_sound("recon_drone_marked_owner");
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
            if (player.sessionstate == "spectator") break;
            player setorigin(self getcrosshair());
            player thread save_spawn();
            self play_sound("recon_drone_marked_owner");
            break;
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

        scripts\mp\class::setclass(self.pers["class"]);
        self.tag_stowed_back = undefined;
        self.tag_stowed_hip = undefined;
        scripts\mp\class::giveloadout(self.pers["team"], self.pers["class"]);
        self.class = self.pers["class"];
        self handle_camo();

        // also give the super each class change
        super = scripts\mp\supers::getcurrentsuper();
        if (isdefined(super)) // supers = field upgrade
        {
            self thread scripts\mp\supers::givesuperweapon(super);
            self thread scripts\mp\supers::givesuperpoints(scripts\mp\supers::getsuperpointsneeded());
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
            self nacto(self custom_scripts\_util::getpers("eq_weapon"), true);

            if (self custom_scripts\_util::getpers("eq_putaway"))
            {
                self switchtoweapon(x);
            }
        }
    }
}

toggle_damage_repeater_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_damage_repeater_bind(1, i);
    else
        self notify("stop_damage_repeater_bind");
}

do_damage_repeater_bind(args, slot)
{
    self endon("stop_damage_repeater_bind");
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
            self.maxhealth = 100;
            self.health = 100;

            self [[level.callbackPlayerDamage]](player, player, int(self custom_scripts\_util::getpers("damage_amount")), 8, "MOD_RIFLE_BULLET", self getcurrentweapon(), self.origin, (0,0,0), "neck", 0 );

            if (active) 
                self.no_damage = true;

            self.maxhealth = old_health;
            self.health = old_health;

            x = self getcurrentweapon();
            clip = self getweaponammoclip(x);
            stock = self getweaponammostock(x);
            wait 0.05;
            self takeweapon(x);
            self giveweapon(x);
            self setweaponammostock(x, stock);
            self setweaponammoclip(x, clip);
            wait 0.05;
            self setspawnweapon(x);  
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
            self.maxhealth = 100;
            self.health = 100;

            self [[level.callbackPlayerDamage]](player, player, int(self custom_scripts\_util::getpers("damage_amount")), 8, "MOD_RIFLE_BULLET", self getcurrentweapon(), self.origin, (0,0,0), "neck", 0 );
            
            if (active) 
                self.no_damage = true;

            self.maxhealth = old_health;
            self.health = old_health;
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
            // jaja
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

    if (isdefined(self.is_player_moving) && self.is_player_moving) return;

    bolt_model = spawn("script_model", self.origin);
    bolt_model setmodel("tag_origin");
    self.current_bolt = bolt_model; // store
    self playerlinkto(bolt_model);
    self.is_player_moving = true;

    for (i=1; i<(x + 1); i++)
    {
        keys = strtok(self custom_scripts\_util::getpers("boltpos" + i), ",");
        position = (float(keys[0]), float(keys[1]), float(keys[2]));
        bolt_model moveto(position, float(self custom_scripts\_util::getpers("boltspeed")), 0, 0);
        wait float(self custom_scripts\_util::getpers("boltspeed"));
    }

    self unlink();
    bolt_model delete();
    self.is_player_moving = undefined;
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
 
    if (isdefined(player.is_bot_moving) && player.is_bot_moving) return;

    bolt_model = spawn("script_model", player.origin);
    bolt_model setmodel("tag_origin");
    player.current_bolt = bolt_model; // store
    player playerlinkto(bolt_model);
    player.is_bot_moving = true;

    for (i=1; i<(x + 1); i++)
    {
        keys = strtok(self custom_scripts\_util::getpers("bot_boltpos" + i), ",");
        position = (float(keys[0]), float(keys[1]), float(keys[2]));
        bolt_model moveto(position, float(self custom_scripts\_util::getpers("bot_boltspeed")), 0, 0);
        wait float(self custom_scripts\_util::getpers("bot_boltspeed"));
    }

    player unlink();
    bolt_model delete();
    player.is_bot_moving = undefined;
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
    self custom_scripts\_util::nprintlnbold("^+bolt point " + x + " deleted");
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

toggle_record_movement_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_record_movement_bind(1, i);
    else
        self notify("stop_bot_bolt_bind");
}

do_record_movement_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_bot_bolt_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_util::in_menu())
        {
            self play_movement();
        }
    }
}

record_movement()
{ 
    if (isdefined(self.is_recording) && self.is_recording)
    {
        self iprintln("^1already recording..");
        return;
    }

    x = 0;
    self printall("recording in " + pal("3"));
    wait 1;
    self printall("recording in " + pal("2"));
    wait 1;
    self printall("recording in " + pal("1"));
    wait 1;
    self printall("now recording - [{+melee_zoom}] to stop");
    
    self.is_recording = true;
    origin = self.origin;
    
    while (distance(origin, self getorigin()) <= 10)
        wait 0.05;

    while (!self meleebuttonpressed())
    {
        x++;
        self custom_scripts\_util::setpers("recordmovementcount",x);
        self custom_scripts\_util::setpers("recordmovementpos" + x, self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);
        self iprintlnbold("point " + pal(x) + " ^7recorded");
        wait 0.1;
        if (x >= 50)
            return self iprintlnbold("^1max points reached");
    }

    self.is_recording = undefined;
}

delete_last_movement_point()
{
    x = int(self custom_scripts\_util::getpers("recordmovementcount"));
    if (x == 0)
        return self iprintlnbold("^1no points to delete");

    self custom_scripts\_util::setpers("recordmovementpos" + x, "0");
    x--;
    self custom_scripts\_util::setpers("recordmovementcount", x);

    self iprintlnbold("point " + pal(x) + " ^7deleted");
}

play_movement()
{
    x = int(self custom_scripts\_util::getpers("recordmovementcount"));
    if (x == 0)
        return self iprintlnbold(pal("save a point first"));

    move_model = spawn("script_model", self.origin);
    move_model setmodel("tag_origin");
    self playerlinkto(move_model);

    for (i=1; i < (x + 1); i++)
    {
        keys = strtok(self custom_scripts\_util::getpers("recordmovementpos" + i), ",");
        position = (float(keys[0]), float(keys[1]), float(keys[2]));
        move_model moveto(position, 0.1, 0, 0);
        wait 0.1;
    }

    self unlink();
    move_model delete();
}

toggle_bounce_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_bounce_bind(1, i);
    else
        self notify("stop_bounce_bind");
}

do_bounce_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_bounce_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_util::in_menu())
        {
            self setvelocity(self getvelocity() - (0, 0, self getvelocity()[2] * 2));
            wait 0.2;
        }
    }
}

toggle_hitmarker_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    if (self.pers[index])
        self thread do_hitmarker_bind(1, i);
    else
        self notify("stop_hitmarker_bind");
}

do_hitmarker_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_hitmarker_bind");
    level endon("game_ended");

    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));

        if (!self custom_scripts\_util::in_menu())
        {
            self scripts\mp\damagefeedback::updatedamagefeedback("standard", 0, 0, "standard", 0);
            self play_sound("gib_fullbody");
            wait 0.2;
        }
    }
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

play_velocity()
{
    self setvelocity((float(self custom_scripts\_util::getpers("velx")), float(self custom_scripts\_util::getpers("vely")), float(self custom_scripts\_util::getpers("velz"))));
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
            self handle_camo();
            self thread check_weapon_options(self getcurrentweapon());
            super = scripts\mp\supers::getcurrentsuper();
            if (isdefined(super)) // supers = field upgrade
            {
                self thread scripts\mp\supers::givesuperweapon(super);
                self thread scripts\mp\supers::givesuperpoints(scripts\mp\supers::getsuperpointsneeded());
            }
        }
    }
}

check_weapon_options(gun)
{
    v = self custom_scripts\_util::getpers("ccb_always_can");
    w = self custom_scripts\_util::getpers("ccb_illusion");
    x = self custom_scripts\_util::getpers("ccb_one_bullet_out");
    y = self custom_scripts\_util::getpers("ccb_one_bullet_left");
    z = self custom_scripts\_util::getpers("ccb_empty_clip");
    clip =  self getweaponammoclip(gun);
    stock = self getweaponammostock(gun);

    if (self custom_scripts\_util::getpers("camo") == "none") // already canswaps with camos set
    {
        if (isdefined(v) && v) 
            self thread always_can_delay();
    }

    if (isdefined(x) && x)
        self setweaponammoclip(gun, clip - 1);

    if (isdefined(y) && y)
        self setweaponammoclip(gun, 1);

    if (isdefined(z) && z)
        self setweaponammoclip(gun, 0);
        
    if (isdefined(v) && v)
    {
        wait 0.05;
        self setspawnweapon(self getcurrentweapon());
    }
}

always_can_delay()
{
    if (self custom_scripts\_util::getpers("class_can"))
    {
        self takegood(self getcurrentweapon());
        self givegood(self getcurrentweapon());
        self switchtoweapon(self getcurrentweapon());
    }
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

random_rounds() // can we make this automatically update?
{
    if (scripts\mp\utility\game::getgametype() == "sd")
    {
        self waittill("killcam_ended");
        random_round_axis = randomint(5);
        random_round_ally = randomint(4);
        rounds_played = (random_round_axis + random_round_ally);
        game["roundsWon"]["axis"] = random_round_axis;
        game["roundsWon"]["allies"] = random_round_ally;
        game["teamScores"]["allies"] = random_round_ally;
        game["teamScores"]["axis"] = random_round_axis;
        game["roundsplayed"] = rounds_played;
        game["switchedsides"] = 0;
    }
}

always_random_rounds(args)
{
    if (scripts\mp\utility\game::getgametype() == "sd")
    {
        self waittill("killcam_ended");
        if (custom_scripts\_util::getpers("random_rounds"))
        {
            random_round_axis = randomint(5);
            random_round_ally = randomint(4);
            rounds_played = (random_round_axis + random_round_ally);
            game["roundsWon"]["axis"] = random_round_axis;
            game["roundsWon"]["allies"] = random_round_ally;
            game["teamScores"]["allies"] = random_round_ally;
            game["teamScores"]["axis"] = random_round_axis;
            game["roundsplayed"] = rounds_played;
            game["switchedsides"] = 0;
        }
    }
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

        if (self custom_scripts\_util::getpers("elem_attachments"))
        {
            for (x = 0; x < 8; x++)
                self setclientomnvar("ui_killcam_killedby_attachment" + (x + 1), -1);
        }

        wait 0.05;
    }
}

// wait till prematch is over for prints because the game does some weird third person cinematic
post_prematch_start()
{
    if (!self custom_scripts\_util::getpers("welcome_message"))
    {
        custom_scripts\_util::waittill_prematch_over();

        self printall("ߵ " + palette() + 
            "^5neura " + level._client + " ^7(^5" + level._client_version + "^7) ^7by * " 
            + palette() + "@nyli2b " 
            + palette() + "@mjkzys " 
            + palette() + "@machinxry  " + "^7*");
            
        wait 1;
        self iprintln("ߵ " + " [{+gostand}] to ^2skip^7 final killcam");
        self custom_scripts\_util::setpers("welcome_message", true);
    }
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
    
    camo = self custom_scripts\_util::getpers("camo");
    if (camo != "none")
    {
#ifdef IW9
        root = _id_2669878CF5A1B6BC::getweaponrootname(weapon);
#else
        root = scripts\mp\utility\weapon::getweaponrootname(weapon);
#endif 
        variant_id = isdefined(weapon.variantid) ? weapon.variantid : -1;
        new_weapon = build_weapon_wrapper(root, weapon.attachments, camo, "none", variant_id, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap());
        self giveweapon(new_weapon);
        self switchtoweapon(new_weapon);
        return;
    }

    self giveweapon(weapon);
    self switchtoweaponimmediate(weapon);
}

give_streak(streak)
{
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

set_camo(camo, should_switch)
{
    self custom_scripts\_util::setpers("camo", camo);

    weapon = self getcurrentweapon();
    if (!should_switch) // the weapon we arent switching to is the next
    {
        weapon = self getnextweapon();
    }

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
        // self custom_scripts\_util::nprintln("^1unable to apply camo..");
        return;
    }

    self takeweapon(weapon);
    self giveweapon(new_weapon);

    if (should_switch)
        self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate(new_weapon);
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

    foreach (weapon in self inventory())
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
    foreach (weapon in self.pers["curr_class"])
    {
        if (weapon.basename == "none")
            continue;

        self giveweapon(weapon);
    }

    self handle_camo();
    if (self getpers("camo") == "none")
        self switchtoweaponimmediate(self inventory()[0]);
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

nacto(weapon, do_wait)
{
    if (!isdefined(weapon))
        return;

    x = self getcurrentweapon();

    self takegood(x);
    if (!self hasweapon(weapon))
        self giveweapon(weapon);
    self switchtoweapon(weapon);
    if (isdefined(do_wait) && do_wait) wait 0.05;
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

#ifdef IW9
        // IW9 seems to have a diveknife & climbfists on the class
        if (issubstr(weapons[i].basename, "diveknife") || issubstr(weapons[i].basename, "climbfists"))
        {
            weapons[i] = undefined;
        }
#endif
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
    if (!isdefined(weapon))
        return;
        
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

toggle_flash_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_flash_bind(1, i);
    else
        self notify("stop_flash_bind");
}

do_flash_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_flash_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self thread try_to_flash();
            wait 0.05;
        }
    }
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

watch_freeze_anim()
{
    self waittill("showing_final_killcam");
    setdvar("pan_freezeanim", 0);
}

set_timescale(timescale)
{
    self custom_scripts\_util::setpers("slomo", float(timescale));
    setslowmotion(float(self custom_scripts\_util::getpers("slomo")), float(self custom_scripts\_util::getpers("slomo")), 0);
}

rewatch_round(mode)
{
    self custom_scripts\_util::setpers("slomo_mode", mode);
    self notify("rewatch_round");
    self thread watch_round_end();
}

watch_round_end()
{
    self endon("rewatch_round");

    if (self custom_scripts\_util::getpers("slomo_mode") == "normal")
        return;

    if (self custom_scripts\_util::getpers("slomo_mode") == "round end")
    {
        level waittill("game_ended");
        setslowmotion(1, 1, 0);
    }

    if (self custom_scripts\_util::getpers("slomo_mode") == "start of killcam")
    {
        self waittill("showing_final_killcam");
        setslowmotion(1, 1, 0);
    }
}

reload_timescale()
{
    // safety endons
    level endon("game_ended");
    self endon("disconnect");
    custom_scripts\_util::waittill_prematch_over();
    setslowmotion(float(self custom_scripts\_util::getpers("slomo")), float(self custom_scripts\_util::getpers("slomo")), 0);
}

save_path()
{
    x = int(self custom_scripts\_util::getpers("pathcount"));
    if (x == 5)
        return self custom_scripts\_util::nprintln("^1max paths saved");

    x++;
    self custom_scripts\_util::setpers("pathcount", x);
    self custom_scripts\_util::setpers("pathpos" + x, self getorigin()[0] + "," + self getorigin()[1] + "," + self getorigin()[2]);

    self custom_scripts\_util::nprintlnbold("^:path " + x + " saved");
}

delete_last_path()
{
    x = int(self custom_scripts\_util::getpers("pathcount"));
    if (x == 0)
        return self iprintlnbold("^1no paths to delete");

    self custom_scripts\_util::setpers("pathpos" + x, "0");
    self custom_scripts\_util::nprintlnbold("^+path " + x + " deleted");
    x--;
    self custom_scripts\_util::setpers("pathcount", x);
}

start_path_movement()
{
    player = self custom_scripts\_util::getenemyplayer();
    if (player == self)
    {
        self iprintlnbold("^5spawn an enemy");
        return;
    }

    player.starting_point = player.origin;
    x = int(self custom_scripts\_util::getpers("pathcount"));
    for (i=1; i < (x + 1); i++)
    {
        // self botsetscriptgoal( self.origin, 16, "critical" );
        b = ["objective", "critical", "hunt", "guard"];
        behavior = b[randomint(b.size)];

        keys = strtok(self custom_scripts\_util::getpers("pathpos" + i), ",");
        position = (float(keys[0]), float(keys[1]), float(keys[2]));
        self dprintln("hi we're trying path " + pal(i) + " ^7using " + pal(behavior));
        self dprintln("position: " + pal(position));
        player botsetscriptgoal(self.origin, 0, "hunt");
        var_4 = [ "goal", "bad_path", "no_path", "node_relinquished", "script_goal_changed" ];
        player scripts\engine\utility::waittill_any_in_array_return(var_4);
        new_wait = randomint(6);
        self dprintln("goal reached or failed sum - trying again in " + pal(new_wait) + "s");
        wait (new_wait);
    }

    self dprintln("finished stalling");
    // wait till everything finishes then set back to original point
    // wait (self custom_scripts\_util::getpers("wait_before_move"));
    wait (randomintrange(1, 3));
    player setgoalpos(player.starting_point);
}

dprintln(text)
{
    if (isdefined(self.is_debug) && self.is_debug)
    {
        return iprintln("[^)debug^7] " + text);
    }
}

respawn_everyone()
{
    foreach (player in level.players)
    {
        if (isbot(player) || isai(player))
        {
            if (self.team != player.team)
            {
                if (player.sessionstate == "spectator")
                {
                    [[ level.spawnplayerfunc ]](1);
                }
            }
        }
    }
}

toggle_third_person_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_third_person_bind(1, i);
    else
        self notify("stop_third_person_bind");
}

do_third_person_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_third_person_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            setdvar("NOSLRNTRKL", !custom_scripts\_util::toggle(getdvarint("NOSLRNTRKL")));
            wait 0.05;
        }
    }
}

fast_last()
{
    limit = level.roundscorelimit - 1;
    self.score = limit;
    self.pers["score"] = self.score;
    self.kills = limit;
    self.pers["kills"] = self.kills;
}

skip_final_killcam()
{
    self waittill("showing_final_killcam");
    self thread skip_killcam();
}

skip_killcam()
{
    self endon("stop_waiting_killcam");
    self waittill("button_pressed_+gostand");

    // scripts\mp\utility\player::wait_spawn_final_juggernaut( "killcam::endKillcamIfNothingToShow() Killcam SKIPPED" );
    foreach (player in level.players) // this is huge just so we ensure everything ends right
    {
        player setclientomnvar( "ui_killcam_end_milliseconds", 0 );
        player setclientomnvar( "ui_killcam_killedby_id", -1 );
        player setclientomnvar( "ui_killcam_victim_id", -1 );
        player setclientomnvar( "ui_killcam_killedby_loot_variant_id", -1 );
        player setclientomnvar( "ui_killcam_killedby_weapon_rarity", -1 );
        player setclientomnvar( "ui_killcam_killedby_item_type", -1 );
        player setclientomnvar( "ui_killcam_killedby_item_id", -1 );
        for ( var_0 = 0; var_0 < 8; var_0++ )
            player setclientomnvar( "ui_killcam_killedby_attachment" + ( var_0 + 1 ), -1 );
        for ( var_0 = 0; var_0 < 6; var_0++ )
            player setclientomnvar( "ui_killcam_killedby_perk" + var_0, -1 ); 
        player.killcam = undefined;
        player setclientomnvar( "cam_scene_name", "unknown" );
        player setclientomnvar( "cam_scene_lead", -1 );
        player setclientomnvar( "cam_scene_support", -1 );
        player allowspectateteam( "freelook", 0 );
        player allowspectateteam( "none", 1 );
        player.forcespectatorclient = -1;
        player.killcamentity = -1;
        player.archivetime = 0;
        player.archiveusepotg = 0;
        player.psoffsettime = 0;
        player.spectatekillcam = 0;
        player.sessionstate = "dead";
        player.sessionstate = "dead";
        self setclientomnvar("ui_session_state", "dead");
        player notify("abort_killcam");
        player notify("killcam_ended");
        player setclientomnvar("post_game_state", 1);
        player notify("stop_waiting_killcam");
    }
}

check_event(event, type)
{
    self endon("disconnect");
    printall("now watching " + event);
    for (;;)
    {
        if (isdefined(type) && type)
        {
            level waittill(event);
            printall(event + " called");
        }
        else
        {
            self waittill(event);
            printall(event + " called");
        }
    }
}

monitor_recon_drone()
{
}

watch_recon_drone_destroy()
{
}

watch_recon_drone_spawn()
{
}

check_dvars(dvars)
{
    self endon("disconnect");
    level endon("game_ended");
    for (;;)
    {
        foreach (dvar in dvars)
        {
            if (float(dvar))
                value = getdvarfloat(dvar);
            else if (int(dvar))
                value = getdvarint(dvar);
            else
                value = getdvar(dvar);
            
            printall(pal(dvar) + ": " + value, true);
            wait 1;
        }
        wait 0.05;
    }
}

#ifndef IW9
spawn_vehicle(maybach)
{
    if (!isdefined(maybach) || maybach == "")
    {
        self iprintlnbold("invalid vehicle: " + pal(maybach));
        return;
    }

    if (getdvarint("scr_allow_vehicle_" + maybach, 1) <= 0)
    {
        setdvar("scr_allow_vehicle_" + maybach, 1);
        wait 0.05;
    }

    angles = anglestoforward(self getplayerangles());
    offset = int(self custom_scripts\_util::getpers("vehicle_offset")); // add vehicle_offset pers
    pos = self.origin + angles * offset;

    vehicle = spawnstruct();
    vehicle.origin = pos;
    vehicle.angles = self getplayerangles();
    vehicle.owner = self;
    vehicle.spawntype = "GAME_MODE";
    whip = scripts\cp_mp\vehicles\vehicle_spawn::vehicle_spawn_spawnvehicle(maybach, vehicle);

    if (!isdefined(whip))
    {
        self iprintlnbold("failed to spawn vehicle " + pal(maybach));
    }
    
    whip.health = int(self custom_scripts\_util::getpers("vehicle_health")); // add vehicle_health pers
    whip.health = whip.maxhealth;

    // add vehicle_invincible pers
    if (self custom_scripts\_util::getpers("vehicle_invincible"))
    {
        whip.godmode = 1;
        whip setcandamage(0);
    }

    if (!isdefined(level.spawned_vehicles_list))
        level.spawned_vehicles_list = [];

    level.spawned_vehicles_list[level.spawned_vehicles_list.size] = whip;
    self.last_spawned_vehicle = whip; 
    self play_sound("ui_mp_flag_capture");

    self thread monitor_vehicle(whip);
}

delete_vehicle(type)
{
    switch (type)
    {
        case "last":
            self delete_last_vehicle();
            break;
        case "all":
            self delete_all_vehicles();
            break;
        default:
            break;
    }
}

delete_last_vehicle()
{
    if (!isdefined(self.last_spawned_vehicle))
    {
        self iprintlnbold(pal("no vehicles to delete"));
        return;
    }

    self.last_spawned_vehicle delete();
    self.last_spawned_vehicle = undefined;
    self iprintln(pal("last vehicle deleted"));
    self play_sound("ui_mp_flag_lost");
}

delete_all_vehicles()
{
    if (!isdefined(level.spawned_vehicles_list) || level.spawned_vehicles_list.size == 0)
    {
        self iprintlnbold(pal("no vehicles to delete"));
        return;
    }

    index = 0;

    foreach (maybach in level.spawned_vehicles_list)
    {
        if (isdefined(maybach))
        {
            maybach delete();
            index++;
        }
    }

    level.spawned_vehicles_list = [];
    self.last_spawned_vehicle = undefined;
    self iprintlnbold("deleted " + pal(index) + " ^7vehicles");
    self play_sound("ui_mp_flag_lost");
}

monitor_vehicle(whip) 
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        if (!isdefined(whip))
            break;
        
        // lul
        invincible = self custom_scripts\_util::getpers("vehicle_invincible");
        if (isdefined(invincible) && invincible && isdefined(whip.godmode) && whip.godmode)
        {
            if (whip.health < whip.maxhealth)
            {
                whip.health = whip.maxhealth;
            }
        }
        wait 0.5;
    }
}
#endif

clear_prematch_look()
{
    // pretty sure we don't need to run all these the whole time 
    level.matchcountdowntime = 0;
    self setclientomnvar("ui_match_start_countdown", 0);
    self setclientomnvar("ui_match_in_progress", 1);
    scripts\mp\playerlogic::clearprematchlook(self);
    
    while (isdefined(level.matchcountdowntime)) 
    {
        wait 0.05;
    }
}

wait_for_round_end()
{
    level waittill("game_ended");
    self.round_has_ended = true;   
}

auto_pause_timer(args)
{
    level endon("game_ended");
    self endon("disconnect");

    custom_scripts\_util::waittill_prematch_over();

    if (self custom_scripts\_util::getpers("randomize_timer_pause"))
    {
        range = randomint(120); // snd default is 2 min so
        wait (range);
    }
    else
    {
        wait (int(self custom_scripts\_util::getpers("pause_timer_after")));
    }

    if (self custom_scripts\_util::getpers("auto_pause_timer"))
    {
        scripts\mp\gamelogic::pausetimer();
        self play_sound("recon_drone_marked_owner");
    }
}

kill_selected_player()
{
    has_selected = self.pers["has_selected_bot"];
    ent = self.pers["selected_bot"];
    if (!has_selected || !isalive(ent))
    {
        self custom_scripts\_util::nprintln("select a bot in the ^5players menu^7 or wait for ^5respawn");
        return;
    }

    ent thread [[level.callbackPlayerDamage]](self, self, 250, 2, "MOD_RIFLE_BULLET", self getcurrentweapon(), (0, 0, 0), (0, 0, 0), "torso_upper", 0);
}

set_selected_player(player)
{
    self.pers["selected_bot"] = player;
    self.pers["has_selected_bot"] = true;
    self iprintln("selected bot: " + pal(self.pers["selected_bot"].name));
}

toggle_reverse_ele_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_reverse_ele_bind(1, i);
    else
        self notify("stop_reverse_ele_bind");
}

do_reverse_ele_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_reverse_ele_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self thread do_reverse_ele();
            wait 1;
        }
    }
}

toggle_kill_bot_bind(bind, i, pers)
{
    index = pers + "_" + i;
    new = int(i) - 1;
    self.pers[index] = !custom_scripts\_util::toggle(self.pers[index]);
    self.pers[pers + "_" + new] = undefined;

    wait 0.05;

    if (self.pers[index])
        self thread do_kill_bot_bind(1, i);
    else
        self notify("stop_kill_bot_bind");
}

do_kill_bot_bind(args, slot)
{
    self endon("disconnect");
    self endon("stop_kill_bot_bind");
    level endon("game_ended");
    for (;;)
    {
        self waittill("button_pressed_-actionslot " + int(slot));
        if (!self custom_scripts\_util::in_menu())
        {
            self thread kill_selected_player();
            wait 1;
        }
    }
}

do_reverse_ele() 
{
    if (!isdefined(self.changle))
    {
        self endon("stop_reverse_ele");
        self.elevate = spawn("script_origin", self.origin, 1);
        self playerlinkto(self.elevate, undefined);
        self.changle = true;
        for (;;)
        {
            self.down_ele = self.elevate.origin;
            wait 0.005;
            self.elevate.origin = self.down_ele + (0, 0, -3);
            if (self custom_scripts\_util::isbuttonpressed("+gostand")) 
            {
                self thread stop_elevator();
                self unlink();
                self.changle = undefined;
                self.elevate delete();
            }
        }
        wait 0.005;
    }
    else
    {
        wait 0.01;
        self unlink();
        self.changle = undefined;
        self.elevate delete();
        self notify("stop_reverse_ele");
    }
}

stop_elevator() 
{ 
    wait 0.01; 
    self unlink(); 
    self.elevator delete(); 
    self notify("stopelevator"); 
}

clone_myself()
{
    self cloneplayer(1);
}

save_camera_node()
{
    i = int(self custom_scripts\_util::getpers("nodecount"));
    if (i == 13)
        return self custom_scripts\_util::nprintln("^1max node points saved");

    // only delete preview if there's actually something to delete
    if (isdefined(level.camera["path"]) || isdefined(level.camera["obj"]))
        delete_camera_preview();

    i++;
    self custom_scripts\_util::setpers("nodecount", i);
    level.camera["origin"][i]  = self getorigin();
    level.camera["orgpath"][i] = self getorigin() + (0,0,58);
    level.camera["angles"][i]  = self getplayerangles();

    level.camera["obj"][i] = spawn( "script_model", level.camera["orgpath"][i] );
    level.camera["obj"][i] setmodel( "axis_guide_createfx" );
    level.camera["obj"][i].angles = self getplayerangles();
    level.camera["obj"][i] hudoutlineenable( "outlinefill_nodepth_green" );
    level.camera["count"] = i;

    create_camera_preview();
    self iprintln("camera position ^2" + i + " ^7saved @ ^2" + self getorigin());
}

delete_last_node()
{
    x = int(self custom_scripts\_util::getpers("nodecount"));
    if (x == 0)
        return self iprintlnbold("^1no nodes to delete");

    self custom_scripts\_util::nprintlnbold("^+node " + x + " deleted");

    if (isdefined(level.camera["obj"][x])) level.camera["obj"][x] delete();
    level.camera["obj"][x] = undefined;

    level.camera["origin"][x]  = undefined;
    level.camera["orgpath"][x] = undefined;
    level.camera["angles"][x]  = undefined;

    x--;
    self custom_scripts\_util::setpers("nodecount", x);
    level.camera["count"] = x;

    // rebuild preview cleanly after node removed
    delete_camera_preview();
    create_camera_preview();
}

set_the_mode(args)
{
    self custom_scripts\_util::setpers("camera_mode", args);

    if (args == "bezier")
        self custom_scripts\_util::setpers("camera_get_start_type", "speed");
    if (args == "linear")
        self custom_scripts\_util::setpers("camera_get_start_type", "time");

    self thread set_camera_mode();
}

set_camera_mode()
{
    level.camera["type"] = self custom_scripts\_util::getpers("camera_mode");
    delete_camera_preview();
    if (level.camera["type"] == "bezier" && level.camera["count"] > 13)
    {
        self iprintln(pal("13 ^7") + "camera points max");
    }

    if ((level.camera["type"] == "bezier" && level.camera["count"] <= 13 ) || level.camera["type"] == "linear") 
    {
        self iprintln(pal(level.camera["type"]) + " ^7mode");
        create_camera_preview();
    }
}

start_camera_path(mode)
{
    if (int(self custom_scripts\_util::getpers("nodecount")) < 3)
    {
        self iprintln("at least ^53^7 points must be set");
        return;
    }

    if (isdefined(level.camera["running"]) && level.camera["running"])
    {
        self iprintln("^1camera path already running");
        return;
    }

    self prepare_player_state();

    level.neura_camera = true;

    speed = 0;
    if (mode == "speed")
        speed = int(self custom_scripts\_util::getpers("camera_bezier_speed"));
    if (mode == "time")
        speed = int(self custom_scripts\_util::getpers("camera_linear_time"));

    level.camera["type"] = self custom_scripts\_util::getpers("camera_mode");

    cam_type  = isdefined(level.camera["type"])  ? level.camera["type"]  : "none";
    cam_speed = isdefined(speed)                 ? speed                 : 0;
    cam_count = isdefined(level.camera["count"]) ? level.camera["count"] : 0;

    camera = spawn("script_model", level.camera["origin"][1]);
    camera setmodel("tag_origin");
    camera rotateto(level.camera["angles"][1], .05);
    level.camera["active_cam"] = camera;
    level.camera["running"] = true;

    self setplayerangles((self getplayerangles()[0], self getplayerangles()[1], int(self custom_scripts\_util::getpers("camera_rotation"))));
    self playerlinktodelta(camera, "tag_origin", 1, 0, 0, 0, 0, true);
    self iprintlnbold("camera: " + pal(cam_type) + "^7 - speed: " + pal(cam_speed) + "^7 - node count: " + pal(cam_count));
    prepare_node_distances();

    if (level.camera["type"] != "bezier" && level.camera["type"] != "linear") 
    {
        self iprintln("^1invalid path type");
        self unlink();
        camera delete();
        level.camera["active_cam"] = undefined;
        level.camera["running"] = false;
        return;
    }

    wait 2;
    setup_player_state();

    start_time = gettime();

    if (level.camera["type"] == "linear")
    {
        travel_time = int( speed / int(level.camera["count"]) );
        for (i = 2; i < level.camera["count"] + 1; i++)
        {
            // bail out immediately if we aren't called
            if (!isdefined(level.camera["running"]) || !level.camera["running"])
                return;

            // prevent crazy snapping?
            ease = travel_time * 0.2;
            camera moveto( level.camera["origin"][i], travel_time, ease, ease );
            camera rotateto( level.camera["angles"][i], travel_time, ease, ease );
            wait travel_time;
        }
    }
    else if (level.camera["type"] == "bezier" && level.camera["count"] >= 3)
    {
        mult = 0.2;

        for ( j = 0; j <= ( level.total_distance * 10 * mult / speed ); j++ )
        {
            // bail out immediately if we aren't called
            if (!isdefined(level.camera["running"]) || !level.camera["running"])
                return;

            t = ( j * speed / (level.total_distance * 10 * mult) );

            pos[0] = 0; pos[1] = 0; pos[2] = 0;
            ang[0] = 0; ang[1] = 0; ang[2] = 0;

            for ( i = 1; i <= level.camera["count"]; i++ )
            {
                for ( z = 0; z < 3; z++ )
                {
                    pos[z] += float( binomial( i-1, level.camera["count"]-1) * pow( (1-t), level.camera["count"]-i ) * pow( t, i-1 ) * level.camera["origin"][i][z] );
                    ang[z] += float( binomial( i-1, level.camera["count"]-1) * pow( (1-t), level.camera["count"]-i ) * pow( t, i-1 ) * level.camera["angles"][i][z] );
                }
            }

            camera moveto( (pos[0], pos[1], pos[2]), 0.05, 0, 0 );
            camera rotateto( (ang[0], ang[1], ang[2]), 0.05, 0, 0 );
            waitframe();
        }
    }

    elapsed = (gettime() - start_time) / 1000;
    reset_player_state(camera);
    self nprintlnbold("cinematic played for ^5" + elapsed + "^7 seconds");
}

prepare_player_state()
{
    index = 0;
    self.pers["previous_loadout"] = [];
    foreach (weapon in self inventory())
    {
        self.pers["previous_loadout"][index] = weapon;
        index++;
    }
    self takeallweapons();
}

setup_player_state()
{
    self freezecontrols(1);
    hide_camera_preview();
    setdvar("cg_drawGun", 0);
    setdvar("cg_drawCrosshair", 0);
    self playerhide();
    self setclientomnvar("ui_hide_full_hud", 1);
}

reset_player_state(camera)
{
    show_camera_preview();
    self setclientomnvar("ui_hide_full_hud", 0);
    setdvar("cg_drawGun", 1);
    setdvar("cg_drawCrosshair", 1);
    self unlink();
    self playershow();
    camera delete();
    level.neura_camera = undefined;
    level.camera["active_cam"] = undefined;
    level.camera["running"] = false;
    self freezecontrols(0);
    self setplayerangles((self getplayerangles()[0], self getplayerangles()[1], 0));

    foreach (weapon in self.pers["previous_loadout"])
    {
        if (weapon.basename == "none")
            continue;

        self giveweapon(weapon);
    }

    self handle_camo();
    if (self getpers("camo") == "none")
        self switchtoweaponimmediate(self inventory()[0]);
}

stop_camera_path()
{
    if (!isdefined(level.camera["running"]) || !level.camera["running"])
    {
        self iprintln("^1camera path isn't running");
        return;
    }

    if (!isdefined(level.camera["active_cam"]))
    {
        self iprintln("^1no active camera to stop");
        return;
    }

    reset_player_state(level.camera["active_cam"]);
}

prepare_node_distances()
{
    level.total_distance = 0;
    for ( k = 1; k < level.camera["count"]; k++ )
    {
        x = level.camera["angles"][k][1];
        y = level.camera["angles"][k+1][1];

        if ( y - x >= 180 )
            level.camera["angles"][k] += (0, 360, 0);    // [k], not [k+1]
        else if ( y - x <= -180 )
            level.camera["angles"][k+1] += (0, 360, 0);  // [k+1], add not subtract

        level.mov_distance[k] = distance( level.camera["origin"][k], level.camera["origin"][k+1] );
        level.ang_distance[k] = distance( level.camera["angles"][k], level.camera["angles"][k+1] );
        level.total_distance += level.mov_distance[k];
        level.total_distance += level.ang_distance[k];
    }
}

set_camera_rotation(rotation)
{
    if (rotation == 1)
    {
        self custom_scripts\_util::setpers("camera_rotation", rotation);
        self setplayerangles((self getplayerangles()[0], self getplayerangles()[1], 0)); 
        return;
    }


    self custom_scripts\_util::setpers("camera_rotation", rotation);
    self setplayerangles((self getplayerangles()[0], self getplayerangles()[1], rotation));
    self iprintln("set camera rotation to " + pal(rotation) + " degrees");
    self notify("wait_rotation");
    self thread wait_and_reset_angles();
}

wait_and_reset_angles()
{
    self endon("wait_rotation");
    wait 3;
    self setplayerangles((self getplayerangles()[0], self getplayerangles()[1], 0));
    self iprintln("reset angles back to normal");
}

create_camera_preview() 
{
    if (level.camera["count"] < 2) 
    {
        return;
    }
    
    camera_type = level.camera["type"];
    if (isdefined(camera_type) && camera_type == "bezier")
    {
        n = 0;
        pathsteps = ( 2000 * level.camera["count"] / 400 );

        for ( j = 0; j < pathsteps ; j++ )
        {
            t = j / (pathsteps - 1);
            pos[0] = 0; pos[1] = 0; pos[2] = 0;
            ang[0] = 0; ang[1] = 0; ang[2] = 0;
            for ( i = 1; i <= level.camera["count"]; i++ )
            {
                for (z = 0; z < 3; z++)
                {
                    pos[z] += float( binomial( i-1, level.camera["count"]-1) * pow( (1-t), level.camera["count"]-i ) * pow( t, i-1 ) * level.camera["orgpath"][i][z] );
                    ang[z] += float( binomial( i-1, level.camera["count"]-1) * pow( (1-t), level.camera["count"]-i ) * pow( t, i-1 ) * level.camera["angles"][i][z] );
                }
            }

            level.camera["path"][n] = spawn( "script_model", (pos[0],pos[1],pos[2]) );
            level.camera["path"][n] setModel( "misc_wm_flarestick" );
            level.camera["path"][n].angles = (ang[0], ang[1], ang[2] + 90);
            level.camera["path"][n] hudoutlineenable( "outlinefill_nodepth_red" );
            n++;
        }
    }
    else
    {
        self iprintln("unable to create preview for '^2" + level.camera["type"] + "^7' mode");
        return;
    }
}

delete_camera_preview()
{
    if (!isdefined(level.camera["path"])) return;
    foreach (path in level.camera["path"])
    {
        if (isdefined(path)) path delete();
    }
}

show_camera_preview()
{
    if (isdefined(level.camera["obj"]))
    {
        foreach (obj in level.camera["obj"])
        {
            if (isdefined(obj)) obj show();
        }
    }
    if (isdefined(level.camera["path"]))
    {
        foreach (path in level.camera["path"])
        {
            if (isdefined(path)) path show();
        }
    }
}

hide_camera_preview()
{
    if (isdefined(level.camera["obj"]))
    {
        foreach (obj in level.camera["obj"])
        {
            if (isdefined(obj)) obj hide();
        }
    }
    if (isdefined(level.camera["path"]))
    {
        foreach (path in level.camera["path"])
        {
            if (isdefined(path)) path hide();
        }
    }
}

binomial( x, y )
{
    return ( factorial( y ) / ( factorial( x ) * factorial( y - x ) ) );
}

factorial( x )
{
    c = 1;
    if ( x == 0 ) return 1;
    for ( i = 1; i <= x; i++ )
        c = c * i;
    return c;
}

play_effect(effect, origin)
{
    playfx(scripts\engine\utility::getfx(effect), origin);
}

apply_camo()
{
    camos = ["camo_00a", "camo_00b", "camo_00c", "camo_01a", "camo_01b", "camo_01c", "camo_01d", "camo_01e", "camo_01f", "camo_01g", "camo_01h", "camo_01i", "camo_01j", "camo_02a", "camo_02b", "camo_02c", "camo_02d", "camo_02e", "camo_02f", "camo_02g", "camo_02h", "camo_02i", "camo_02j", "camo_03a", "camo_03b", "camo_03c", "camo_03d", "camo_03e", "camo_03f", "camo_03g", "camo_03h", "camo_03i", "camo_03j", "camo_04a", "camo_04b", "camo_04c", "camo_04d", "camo_04e", "camo_04f", "camo_04g", "camo_04h", "camo_04i", "camo_04j", "camo_05a", "camo_05b", "camo_05c", "camo_05d", "camo_05e", "camo_05f", "camo_05g", "camo_05h", "camo_05i", "camo_05j", "camo_06a", "camo_06b", "camo_06c", "camo_06d", "camo_06e", "camo_06f", "camo_06g", "camo_06h", "camo_06i", "camo_06j", "camo_07a", "camo_07b", "camo_07c", "camo_07d", "camo_07e", "camo_07f", "camo_07g", "camo_07h", "camo_07i", "camo_07j", "camo_08a", "camo_08b", "camo_08c", "camo_08d", "camo_08e", "camo_08f", "camo_08g", "camo_08h", "camo_08i", "camo_08j", "camo_09a", "camo_09b", "camo_09c", "camo_09d", "camo_09e", "camo_09f", "camo_09g", "camo_09h", "camo_09i", "camo_09j", "camo_10a", "camo_10b", "camo_10c", "camo_10d", "camo_10e", "camo_10f", "camo_10g", "camo_10h", "camo_10i", "camo_10j", "camo_11a", "camo_11b", "camo_11c", "camo_11d", "camo_12a", "camo_12b", "camo_12c", "camo_12d", "camo_12e", "camo_12f", "camo_12g", "camo_12h", "camo_12i", "camo_12j", "camo_12k", "camo_12l"];
    camo = camos[randomint(camos.size)];
    // self printall(camos.size);
    // self printall(camo);
    self custom_scripts\_util::setpers("camo", camo);
    self handle_camo();
}

handle_camo()
{
    wait 0.05;
    if (self getpers("camo") != "none")
    {
        self set_camo(self getpers("camo"), false); // this was set_camo_next before
        self set_camo(self getpers("camo"), true);
    }
}

preset_positions()
{
    switch (level.mapname)
    {
        case "mp_shipment":
            break;
        default:
            break;
    }
}

clear_ents()
{
    ents = getentarray("script_model", "classname");
    for (i = 0 ; i < ents.size ; i++)
    {
        if (isdefined(ents[i])) // idk
        {
            ents[i] delete();
            wait 0.05;
            self custom_scripts\_util::nprintln("^2an entity was deleted");
        }
    }
}

// im laughing writing this btw
bj_logic() 
{
    if (isdefined(self.is_bj_spawned) && self.is_bj_spawned)
    {
        self notify("end_bj"); // end early so we dont get loop errors
        self custom_scripts\_util::nprintlnbold("^5cleaning up your last models, retry in a sec");
        self.girly delete();
        self.dude delete();
        self.dude_head delete();
        self.is_bj_spawned = undefined;
        return;
    }

    self.is_bj_spawned = true;
    self thread bj_monitor();
}

bj_monitor() 
{
    self endon("disconnect");
    self endon("end_bj");

    pos = self getcrosshair();
    self init_bj_models(pos);

    self.girly.angles = (0, 180, 0);

    for(;;)
    {
        speed = float(self custom_scripts\_util::getpers("bj_speed"));
        self.girly rotatepitch(10, speed);
        wait speed;
        self.girly rotatepitch(-10, speed);
        wait speed;
    }
    wait 0.05;
}

init_bj_models(i) 
{
    // why this nigga so complicated doe
    self.dude = spawn("script_model", i + (0, 0, -2));
    self.dude setmodel("body_opforce_london_terrorist_1_2");

    self.dude_head = spawn ("script_model", i + (0, 0, -2));
    self.dude_head setmodel("head_male_bc_03");

    self.dude_head linkto(self.dude, "j_neck", ( -9, 1, 0 ), ( 0, 0, 0 ) );
    self.dude scriptmodelplayanimdeltamotion("wm_firemancarry_loop_mp_stand");
    // self.dude linkto( self, "j_shoulder_le", ( -12, -8, -8 ), ( 0, 0, 30 ) );

    self.girly = spawn("script_model", i + (15, 0, -32));
    self.girly setmodel("body_spetsnaz_dmr_old");
}

// fucking around idek this how i found out how to set a head on the dude smh
hostage_to_cross(i)
{
    if (isdefined(self.placed_hostage) && self.placed_hostage)
    {
        self custom_scripts\_util::nprintlnbold("^5cleaning up your last model, retry in a sec");
        self.hostage delete();
        self.hostage_head delete();
        self.placed_hostage = undefined;
        return;
    }

    // hostage anims
    anim_list = ["hm_grnd_civ_react02_idle07", "hm_grnd_civ_react02_idle04"];
    anima = anim_list[randomint(anim_list.size)];

    // we need to spawn a body as well as a head
    self.hostage = spawn("script_model", i);
    self.hostage_head = spawn("script_model", i);

    self.hostage setmodel("body_opforce_london_terrorist_1_2");
    self.hostage_head setmodel("head_male_bc_03");

    // attach head to model
    self.hostage_head linkto(self.hostage, "j_neck", (-9, 1, 0), (0, 0, 0));
    self.hostage scriptmodelplayanimdeltamotion(anima);

    self.hostage.head = self.hostage_head;
    self.placed_hostage = true;
    // return self.hostage;
}

modelspawner(mod, position) // idk im bored
{
    if (!isdefined(mod))
    {
        self iprintlnbold("^1invalid model..");
    }

    precachemodel(mod); // idk

    if (!isdefined(position))
        position = self getcrosshair();

    model = spawn("script_model", position);
    model setmodel(mod);

    if (!isdefined(self.spawned_models))
        self.spawned_models = [];

    self.spawned_models[self.spawned_models.size] = model;
    self.last_model = model;
    self play_sound("ui_mp_flag_capture");
    self iprintlnbold("now watching " + pal(self.spawned_models.size) + " ^7models");
}

delete_last_model()
{
    if (!isdefined(self.last_model))
    {
        self iprintlnbold(pal("no vehicles to delete"));
        return;
    }

    self.last_model delete();
    self.last_model = undefined;
    self iprintln(pal("last vehicle deleted"));
    self play_sound("ui_mp_flag_lost");
}

delete_all_models()
{
    if (!isdefined(level.model_list) || level.model_list.size == 0)
    {
        self iprintlnbold(pal("no models to delete"));
        return;
    }

    index = 0;

    foreach (model in level.model_list)
    {
        if (isdefined(model))
        {
            model delete();
            index++;
        }
    }

    level.model_list = [];
    self.last_model = undefined;
    self iprintlnbold("deleted " + pal(index) + " ^7models");
    self play_sound("ui_mp_flag_lost");
}

edit_model(model, attribute, value) // uhhh i gotta look at this later
{
    if (!isdefined(model))
    {
        self dprintln("^1error ^7edit_model — model undefined");
        return;
    }

    switch (attribute)
    {
        case "position":
            model.origin = value;
            self dprintln("^7set position to " + pal(value));
            break;
        case "angles":
            model.angles = value;
            self dprintln("^7set angles to " + pal(value));
            break;
        case "model":
            model setmodel(value);
            self dprintln("^7set model to " + pal(value));
            break;
        case "anim":
            model scriptmodelplayanimdeltamotion(value);
            self dprintln("^7playing anim " + pal(value));
            break;
        case "link":
            // value = (entity, tag, offset, angles)
            model linkto(value[0], value[1], value[2], value[3]);
            self dprintln("^7linked to " + pal(value[1]));
            break;
        case "unlink":
            model unlink();
            self dprintln("^7unlinked");
            break;
        case "hide":
            model hide();
            self dprintln("^7hidden");
            break;
        case "show":
            model show();
            self dprintln("^7shown");
            break;
        default:
            self dprintln("^1error ^7unknown attribute " + pal(attribute));
            break;
    }
}

invis_platform(clip)
{
    if (isdefined(self.platform))
    {
        self.platform.origin = self.origin;
        self custom_scripts\_util::setpers("platform_origin", self.platform.origin);
        self iprintlnbold("[" + pal(clip) + "^7] " + "platform updated & moved to " + pal(self.origin));
        return;
    }
    
    self.platform = spawn("script_model", self.origin);
    self.platform setmodel(clip);
    ent = getent(clip, "targetname");
    self.platform clonebrushmodeltoscriptmodel(ent);
    self thread play_effect("claymore_explode", self.platform.origin);
    self custom_scripts\_util::setpers("platform_clip", clip);
    self custom_scripts\_util::setpers("platform_origin", self.platform.origin);
    self iprintlnbold("[" + pal(clip) + "^7] " + "platform spawned @ " + pal(self.origin));
}

reload_platform()
{
    origin = self custom_scripts\_util::getpers("platform_origin");
    if (!isdefined(origin))
        return;

    clip = self custom_scripts\_util::getpers("platform_clip");
    if (!isdefined(clip) || clip == "none")
        return;

    self.platform = spawn("script_model", self custom_scripts\_util::getpers("platform_origin"));
    self.platform setmodel(clip);

    ent = getent(clip, "targetname");
    if (isdefined(ent))
        self.platform clonebrushmodeltoscriptmodel(ent);

    self.platform clonebrushmodeltoscriptmodel(ent);
    self thread play_effect("claymore_explode", self.platform.origin);
    self iprintln("[" + pal(clip) + "^7] " + "platform reloaded @ " + pal(self.platform.origin));
}

/* 
model_maker(model, head, anim_name, link_to_self, position) // doesn't work at all bro like no errors nun jus doesn't work
{
    position = self.origin;
    x = int(self custom_scripts\_util::getpers("modelcount"));
    x++;
    self custom_scripts\_util::setpers("modelcount", x);
    self custom_scripts\_util::setpers("model_" + x, model);
    self custom_scripts\_util::setpers("model_head_" + x, isdefined(head) ? head : false);
    self custom_scripts\_util::setpers("model_anim_" + x, isdefined(anim_name) ? anim_name : false);
    self custom_scripts\_util::setpers("model_link_to_self_" + x, isdefined(link_to_self) ? link_to_self : false);
    self custom_scripts\_util::setpers("model_pos_" + x, isdefined(position) ? position : false);

    self dprintln("^7slot " + pal(x) + " ^7model: " + pal(model));

    if (!self custom_scripts\_util::getpers("model_pos_" + x))
    {
        self dprintln("^1error ^7setting pos for slot " + pal(x) + " ^7— position was " + (isdefined(position) ? pal(position) : "^1undefined"));
        return;
    }

    self dprintln("^7spawning at " + pal(self.pers["model_pos_" + x]));

    self.pers["model_script_" + x] = spawn("script_model", self.pers["model_pos_" + x] + (0, 0, -2));

    if (!isdefined(self.pers["model_script_" + x]))
    {
        self dprintln("^1error ^7spawn failed for slot " + pal(x));
        return;
    }

    self dprintln("^7spawn ok, setting model: " + pal(self custom_scripts\_util::getpers("model_" + x)));
    self.pers["model_script_" + x] setmodel(self custom_scripts\_util::getpers("model_" + x));

    if (self custom_scripts\_util::getpers("model_head_" + x))
    {
        self dprintln("^7spawning head: " + pal(self custom_scripts\_util::getpers("model_head_" + x)));
        self.pers["model_head_script_" + x] = spawn("script_model", self.pers["model_pos_" + x] + (0, 0, -2));
        self.pers["model_head_script_" + x] setmodel(self custom_scripts\_util::getpers("model_head_" + x));
        self.pers["model_head_script_" + x] linkto(self.pers["model_script_" + x], "j_neck", (-9, 1, 0), (0, 0, 0));
        self dprintln("^7head linked ok");
    }

    if (self custom_scripts\_util::getpers("model_anim_" + x))
    {
        self dprintln("^7playing anim: " + pal(self custom_scripts\_util::getpers("model_anim_" + x)));
        self.pers["model_script_" + x] scriptmodelplayanimdeltamotion(self custom_scripts\_util::getpers("model_anim_" + x));
    }

    if (self custom_scripts\_util::getpers("model_link_to_self_" + x))
    {
        self dprintln("^7linking to self");
        self.pers["model_script_" + x] linkto(self, "j_shoulder_le", (-12, -8, -8), (0, 0, 30));
    }

    self dprintln("^2done ^7slot " + pal(x));
}
*/

// botpressbutton
// kreuger_eastern
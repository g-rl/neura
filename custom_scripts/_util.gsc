#include custom_scripts\neura;
#include custom_scripts\_func;
#include custom_scripts\_menu;

void() {}

monitor_buttons() 
{
    if (isdefined(self.now_monitoring))
        return;

    self.now_monitoring = true;
    
    if (!isdefined(self.button_actions))
        self.button_actions = list("frag,smoke,special,melee,melee_zoom,melee_breath,stance,gostand,weapnext,actionslot 1,actionslot 2,actionslot 3,actionslot 4,actionslot 5,actionslot 6,actionslot 7,forward,back,moveleft,moveright");

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

isButtonPressed(button)
{
    return self.button_pressed[button];
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
#else
    self iprintln("^6neura iw8 ^7by * ^1@nyli2b ^2@mjkzy ^7*");
#endif

    self thread reload_position();
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

loadpers(key, func, args)
{
    if (!self haspers(key))
    {
        self setpersifuni(key, false);
        return;
    }

    wait 0.05;

    // we call any function passed through loadpers with args no matter what - THIS CAN BE UNDEFINED
    self thread [[func]](args);
}

unstuck()
{
    self setorigin(self getpers("unstuck"));
}

perstovector(pers)
{
    keys = strtok(pers, ",");
    return (float(keys[0]), float(keys[1]), float(keys[2]));
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

getprevweapon() 
{
    real_weaps = self getrealweapons();
    x = self getcurrentweapon();
    for (i = 0 ; i < real_weaps.size ; i++)
    {
        if (x == real_weaps[i])
        {
            y = i - 1;
            if (y < 0)
                y = real_weaps.size - 1;

            if (isdefined(real_weaps[y]))
                return real_weaps[y];
            return real_weaps[0];
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
    weapons = self scripts\cp_mp\utility\inventory_utility::getcurrentprimaryweaponsminusalt();
    for (i = 0; i < weapons.size; i++)
    {
        if (issubstr(weapons[i].basename, "knifestab"))
        {
            weapons[i] = undefined;
        }
    }
    return weapons;
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

getorigin_() 
{ 
    return self.origin; 
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
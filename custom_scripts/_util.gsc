void() {}

setup_bind(pers, value, func) // my bind system is so ugly but it works for now lol
{
    for(i = 0; i < 4; i++) 
    {
        bind = "+actionslot " + (i + 1);
        index = i + 1;
        new_pers = pers + "_" + index;

        self setpersifuni(new_pers, value);

        if (is_true(self getpers(new_pers)))
        {
            self thread [[func]](bind, pers);
        }
    }
}

get_current_client() // check if s4 or iw8
{
    return level._client; 
}

getorigin_() // so self.origin on iw8 glitches out bounces etc so
{ 
#ifdef S4
    return self.origin;
#else
    return self getorigin();
#endif
}

nprintln(text)
{
    if (!self getpers("messages")) return;
    self iprintln(text);
}

nprintlnbold(text)
{
    if (!self getpers("messages")) return;
    self iprintlnbold(text);
}

monitor_buttons() 
{
    if (isdefined(self.now_monitoring))
        return;
    self.now_monitoring = true;
    
    if (!isdefined(self.button_actions))
        self.button_actions = list("frag,smoke,special,melee,melee_zoom,melee_breath,stance,gostand,weapnext,actionslot 1,actionslot 2,actionslot 3,actionslot 4,actionslot 5,actionslot 6,actionslot 7,forward,back,moveleft,moveright");

    if (!isdefined(self.button_pressed))
        self.button_pressed = [];
    
    for (a = 0; a < self.button_actions.size; a++)
    {
        self thread button_monitor("+" + self.button_actions[a]);
        self thread button_monitor("-" + self.button_actions[a]); // this usually works as a fallback to many of these, this is the release bind
    }
    self thread button_monitor("nightvision");

    self setactionslot(4, "");
}

isButtonPressed(button)
{
    return self.button_pressed[button];
}

// pauses timer after 5-8 seconds to let the tactical/equipment delay disable
pause_timer_cooldown_bypass()
{
    level endon("game_ended");
    waittill_prematch_over();
    wait 8;
    scripts\mp\gamelogic::pausetimer();
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

resetpers(key)
{
    self.pers[key] = undefined;
}

getpers(key)
{
    return self.pers[key];
}

setpersifuni(key, value)
{   
    if (!isdefined(getpers(key)))
        setpers(key, value);
}

haspers(pers)
{
    return isdefined(self.pers[pers]);
}

loadpers(key, func, args)
{
    if (!self getpers(key)) 
    {
        return;
    }
    
    wait 0.05;

    // we call any function passed through loadpers with args no matter what - THIS CAN BE UNDEFINED
    self thread [[func]](args);
}

createcommand(command, desc, callback) // dont think we're gonna need this anymore lmk tho -et
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
    self givegood(x);
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

    for (i = (name.size - 1); i >= 0; i--)
        if (name[i] == "]")
            break;

    return getsubstr(name, (i + 1));
}

getbasename(weapon) // might be a func already idc tho -et
{
    return weapon.basename;
}

// have to use this because ActionSlotButtonOnePressed etc does not exist!
button_monitor(button)
{
    self endon("disconnect");

    self.button_pressed[button] = false;
    self notifyonplayercommand("button_pressed_" + button, button);

    while (1)
    {
        self waittill("button_pressed_" + button);
        self.button_pressed[button] = true;
        wait 0.05;
        self.button_pressed[button] = false;
    }
}

actionslot_to_func(actionslot)
{
    switch(actionslot)
    {
    case "[{+actionslot 1}]":
        return "-actionslot 1";
    case "[{+actionslot 2}]":
        return "-actionslot 2";
    case "[{+actionslot 3}]":
        return "-actionslot 3";
    case "[{+actionslot 4}]":
        return "-actionslot 4";
    default:
        break;
    }
}

vt(var, serverity) // adds caution symbol next to text
{
    // ߺ : red
    // ߑ : white
    // ߨ : orange 
    return "ߨ " + var;
}
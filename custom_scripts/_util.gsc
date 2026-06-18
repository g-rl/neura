// this is a utility file and never has includes

// TODO: temporary, to handle dvars, regardless of hash or not
//#ifdef IW9
//#define DVAR_(name) @ name
//#else
#define DVAR_(name) name
//#endif

void() 
{
    // empty function
}

setup_bind(pers, value, func) // actually what is this bro LOL fuck it tho
{
    for (i = 0; i < 4; i++) 
    {
        bind = "+actionslot " + (i + 1);
        index = i + 1;
        new_pers = pers + "_" + index;

        self setpers_if_uninitialized(new_pers, value);

        if (is_true(self getpers(new_pers)))
        {
            self thread [[func]](bind, index);
        }
    }
}

get_current_build() // check if s4, iw8 or iw9
{
    return level._client + " ^7(^:" + level._client_version + "^7)"; 
}

getorigin_() // so self.origin on iw8 glitches out bounces etc 
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

setpers(key, value)
{
    self.pers[key] = value;
    level.session_data[key] = value;
}

resetpers(key)
{
    self.pers[key] = undefined;
    level.session_data[key] = undefined;
}

getpers(key)
{
    return self.pers[key];
}

// setpersifuni
setpers_if_uninitialized(key, value)
{
    if (!isdefined(self getpers(key)))
    {
        self setpers(key, value);
    }
}

haspers(pers)
{
    return isdefined(self.pers[pers]);
}

loadpers(key, func, args)
{
    if (!getpers(key))
        return;
    
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

        wait 0.05;
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

weaponexists(weapon)
{
    return isdefined(level.weaponmapdata[weapon]);
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

    return getsubstr(name, 0, (i + 1));
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

warn(var) // adds caution symbol next to text
{
    return "ߨ " + var;
}

isButtonPressed(button)
{
    return self.button_pressed[button];
}

// this is for _menu really - this is done for import order to work on IW9
// i am not sure why this game is so mean about it
in_menu()
{
    return is_true(self.in_menu);
}

randomize(key)
{
    array = strtok(key, ", ");
    random = randomint(array.size);
    output = array[random];
    return output;
}

// session
load_session()
{
    self endon("disconnect");

    setdvar("neura_sessionDataWriteComplete", false);
    setdvar("neura_sessionShouldLoad", true);
    
    // wait for dll to do its crap
    data_count = getdvarint("neura_sessionDataCount", 0);
    while (data_count <= 0)
    {
        wait 0.05;
        data_count = getdvarint("neura_sessionDataCount");
    }

    for (i = 0; i < data_count; i++)
    {
        waittill_nengine_has_written();
        current = getdvar("neura_sessionDataCurrent");
        thread setup_session_pers(current);
        current_bruh = strtok(current, ":");
        //setpers(current_bruh[0], current_bruh[1]);

        setdvar("neura_sessionDataWriteComplete", false); // signal ready for next
    }

    setdvar("neura_sessionShouldLoad", false);
    self iprintln("session ^1reloaded " + data_count + " variables");
}

setup_session_pers(current)
{
    seperated = strtok(current, ":");
    pers_key = seperated[0];
    pers_value = seperated[1];

    real_value = undefined;

    // make sure our pers value is actually what its suppose to be
    if (isstring(pers_value))
    {
        real_value = int(pers_value);
        if (pers_value != "0" && real_value == 0)
        {
            real_value = pers_value;
        }
    }

    setpers(pers_key, real_value);
}

save_session()
{
    // nyli increase my balls i know
    thread save_session_internal();
}

save_session_internal()
{
    self endon("disconnect");

    iprintln("save_session");

    // this may take a few frames since its done via dvars
    setdvar("neura_sessionDataReadComplete", false);
    setdvar("neura_sessionDataSize", level.session_data.size); // string cast
    setdvar("neura_sessionShouldSave", true);

    index_inc = 0;
    foreach (key, value in level.session_data)
    {
        setdvar("neura_sessionDataReadComplete", false);
        setdvar("neura_sessionDataCurrent", key + ":" + value);
        waittill_nengine_has_read();
        index_inc += 1;
    }

    setdvar("neura_sessionShouldSave", false);
    self iprintln("session ^2saved!");
}

waittill_nengine_has_written()
{
    self endon("disconnect");
    has_written = getdvarint("neura_sessionDataWriteComplete", 0);
    while (!has_written)
    {
        waittillframeend;
        has_written = getdvarint("neura_sessionDataWriteComplete", 0);
    }
}

waittill_nengine_has_read()
{
    self endon("disconnect");
    has_read = getdvarint("neura_sessionDataReadComplete", 0);
    while (!has_read)
    {
        has_read = getdvarint("neura_sessionDataReadComplete", 0);
        wait 0.05;
    }
}

palette() // ^: has been readded so rewrite everything using palette to just that eventually
{
    return "^:";
}

pal(text)
{
    colors = ["^1", "^2", "^3", "^4", "^5", "^6", "^7", "^:", "^+", "^(", "^)", "^.", "^,", "^;", "^*"];
    option = colors[randomint(colors.size)];
    return option + text;
}

// TODO: IW9 and all movement wrappers
/*
allow_movement(1)
{

}

allow_jump(1)
{

}

        allow_usability(1);
        allow_melee(1);
        allow_offhand_weapons(1);
        allow_weapon_switch(1);
        allow_sprint(1);
*/

// TODO: add these to gsc-tool prob lol
getclassindex_wrapper(index)
{
#ifdef S4
    return scripts\mp\class::_id_6962(index);
#else
    return scripts\mp\class::getclassindex(index);
#endif
}

#define USING_S4_MOD

main()
{
#ifdef USING_S4_MOD
    level thread init();
#endif
}

init()
{
    level.is_setup = false;

    level thread on_player_connect();
    level thread setup_dvars();
}

setup_dvars()
{
    level.is_setup = true;
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

    for (;;)
    {
        self waittill("spawned_player");
        if (isdefined(self.has_spawned)) 
            continue;

        self.neura = [];
        self.has_spawned = true;

        registered = 0;
        f = [];
        f[f.size] = ::neura_spawned;
        foreach (func in f)
        {
            self thread [[func]]();
            registered++;
            wait 0.05;
        }
    }
}

on_bot_spawned()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("spawned_player");

        /*
        while (isdefined(level.matchcountdowntime)) 
        {
            wait 1;
        }
        */

        self thread freeze_loop();
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

neura_spawned() 
{ 
    self endon("disconnect");
    level endon("game_ended");
    for(;;)
    {
        self iprintlnbold("^+neura s4 - @nyli2b"); 
        wait 5;
    }
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
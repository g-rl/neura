#include custom_scripts\_z_func;
#include custom_scripts\_util;

rainbow_menu()
{
    if (getdvarint("rainbow") == 1)
    {
        setdvar("rainbow", 0);
        self notify("end_flicker");
    }
    else
    {
        setdvar("rainbow", 1);
        self thread flicker_shaders();
    }
}

initial_variable()
{
    // [0]: ID
    // [1]: Display Name
    self.neura["soh_perk_list"] = list("specialty_fastreload,specialty_fastoffhand,specialty_quickswap,specialty_quickdraw,specialty_sprintmelee,specialty_sprintfire,specialty_stalker,specialty_regenfaster");
    self.neura["perk_list"] = list("specialty_marathon,specialty_holdbreath,specialty_lightweight");
    
    self.neura["perks"] = list("specialty_fastreload,specialty_lightweight,specialty_marathon,specialty_holdbreath,specialty_fastoffhand,specialty_quickswap,specialty_quickdraw,specialty_sprintmelee,specialty_sprintfire,specialty_stalker,specialty_regenfaster");

    self.neura["weapons"]["iw8"]["primary"]["snipers"][0] = ["iw8_sn_alpha50_mp+back_alpha50+barlong_alpha50+gunperk_fastmelee+mag_alpha50+pistolgrip02_alpha50+rec_alpha50+snprscope_alpha50", "iw8_sn_hdromeo_mp+back_hdromeo+barlong_hdromeo+gunperk_fastmelee+mag_hdromeo+rec_hdromeo+snprscope_hdromeo", "iw8_sn_delta_mp+barlong_delta+gunperk_fastmelee+mag_delta+rec_delta+snprscope_delta+stockl_delta", "iw8_sn_mike14_mp+barmid_mike14+gunperk_fastmelee+pistolgrip06_mike14+rec_mike14_mp+snprscope_mike14+stockh03_mike14+xmags_mike14", "iw8_sn_sbeta_mp+barmid_sbeta+gunperk_fastmelee+pistolgrip02_sbeta+rec_sbeta+snprscope_sbeta+stockcqb_sbeta", "iw8_sn_kilo98_mp+barmid_kilo98+gunperk_fastmelee+pistolgrip02_kilo98+rec_kilo98+snprscope_kilo98"];
    self.neura["weapons"]["iw8"]["primary"]["snipers"][1] = ["ax50", "hdr", "dragunov", "ebr w/ scope", "mk2 carbine w/ scope", "kar98k w/ scope"];

    self.neura["weapons"]["iw8"]["primary"]["shotguns"][0] = ["iw8_sh_romeo870_mp+back_romeo870+fastreload+front_romeo870+gripang_romeo870+griprail_romeo870+ironsdefault_romeo870+rec_romeo870_mp+slugs_romeo870", "iw8_sh_dpapa12_mp+ammo_dpapa12+fastreload+front_dpapa12+griphip_dpapa12+guard_dpapa12+ironsdefault_dpapa12+pistolgrip01_dpapa12+rec_dpapa12", "iw8_sh_charlie725_mp+ammo_charlie725+fastreload+front_charlie725+gripang_charlie725+guardlight_charlie725+ironsdefault_charlie725+rec_charlie725+stockh_charlie725", "iw8_sh_oscar12_mp+fastreload+front_oscar12+gripang_oscar12+ironsdefault_oscar12+mag_oscar12+pistolgrip01_oscar12+rec_oscar12+stockno_oscar12", "iw8_sh_mike26_mp+back_mike26+barmid_mike26+fastreload+gripvert_mike26+ironsdefault_mike26+mag_mike26+pistolgrip03_mike26+rec_mike26"];
    self.neura["weapons"]["iw8"]["primary"]["shotguns"][1] = ["model 680", "r-90", "725", "origin 12", "vlk rogue"];

    self.neura["weapons"]["iw8"]["primary"]["assault rifles"][0] = ["iw8_ar_falima_mp+back_falima+brake01+front_falima+mmags_falima+pistolgrip01_falima+rec_falima+snprscope_mike14_ar", "iw8_ar_akilo47_mp+back_akilo47_mp+bayonet_akilo47+drums_akilo47+front_akilo47_mp+ironsdefault_akilo47+rec_akilo47+ub_golf25_smoke", "iw8_ar_scharlie_mp+back_scharlie+fastreload+front_scharlie+ironsdefault_scharlie+mag_scharlie+rec_scharlie+selectsemi+silencersleeve", "iw8_ar_sierra552_mp+barshort_sierra552+fastreload+ironsdefault_sierra552+pistolgrip01_sierra552+rec_sierra552+selectsemi+stockh_sierra552+xmagslrg_sierra", "iw8_ar_tango21_mp+barshort_tango21+fastreload+gripang+ironsdefault_tango21+mag_tango21+rec_tango21+selectsemi+stockh_tango21", "iw8_ar_mike4_mp+back_mike4+comp+front_mike4+glincendiary+ironsdefault_mike4+mag_mike4+pistolgrip01_mike4+rec_mike4", "iw8_ar_mike4_mp+back_mike4+comp+front_mike4+ironsdefault_mike4+mag_mike4+pistolgrip01_mike4+rec_mike4+selectsemi", "iw8_ar_asierra12_mp+fastreload+front_asierra12+ironsdefault_asierra12+mag_asierra12+rec_asierra12+selectsemi+stockl_asierra12+toprail_asierra12", "iw8_ar_kilo433_mp+back_kilo433+fastreload+front_kilo433+griphip+ironsdefault_kilo433+mag_kilo433+rec_kilo433+selectsemi", "iw8_ar_falpha_mp+fastreload+front_falpha+gripangpro+ironsdefault_falpha+mag_falpha+rec_falpha+selectsemi_falpha+toprail_falpha+triggrip_falpha", "iw8_ar_mcharlie_mp+back_mcharlie+front_mcharlie+gunperk_fastmelee+ironsdefault_mcharlie+mag_mcharlie+rec_mcharlie+selectsemi"];
    self.neura["weapons"]["iw8"]["primary"]["assault rifles"][1] = ["scoped fal", "smoke launcher ak47", "silenced scar", "short grau 5.56", "ram-7", "incendiary m4", "m4", "oden", "kilo 141", "fr 5.56", "m13"];

    self.neura["weapons"]["iw8"]["primary"]["light machine guns"][0] = ["iw8_lm_pkilo_mp+back_pkilo+fastreload+front_pkilo+ironsdefault_pkilo+mag_pkilo+rec_pkilo", "iw8_lm_lima86_mp+fastreload+front_lima86+ironsdefault_lima86+mag_lima86+rec_lima86+selectsemi", "iw8_lm_kilo121_mp+back_kilo121+fastreload+front_kilo121+ironsdefault_kilo121+mag_kilo121+rec_kilo121", "iw8_lm_mgolf34_mp+back_mgolf34+fastreload+front_mgolf34+ironsdefault_mgolf34+mag_mgolf34+rec_mgolf34+selectsemi", "iw8_lm_mgolf36_mp+back_mgolf36+fastreload+front_mgolf36+ironsdefault_mgolf36+mag_mgolf36+reargrip_mgolf36+rec_mgolf36+selectsemi+toprail_mgolf36", "iw8_lm_mkilo3_mp+back_mkilo3+fastreload+front_mkilo3+ironsdefault_mkilo3+mag_mkilo3+rec_mkilo3"];
    self.neura["weapons"]["iw8"]["primary"]["light machine guns"][1] = ["pkm", "sa87", "m91", "mg34", "holger-26", "bruen mk9"];

    self.neura["weapons"]["iw8"]["primary"]["sub machine guns"][0] = ["iw8_sm_uzulu_mp+back_uzulu+front_uzulu+ironsdefault_uzulu+mag_uzulu+rec_uzulu_mp+selectsemi", "iw8_sm_beta_mp+back_beta+front_beta+ironsdefault_beta+mag_beta+rec_beta+selectsemi", "iw8_sm_augolf_mp+front_augolf+gripcust_augolf+ironsdefault_augolf+mag_augolf+rec_augolf+selectsemi", "iw8_sm_mpapa5_mp+back_mpapa5+front_mpapa5+ironsdefault_mpapa5+mag_mpapa5+rec_mpapa5_mp+selectsemi", "iw8_sm_smgolf45_mp+back_smgolf45+front_smgolf45+ironsdefault_smgolf45+mag_smgolf45+rec_smgolf45+selectsemi+triggrip_smgolf45", "iw8_sm_mpapa7_mp+back_mpapa7+front_mpapa7+ironsdefault_mpapa7+mag_mpapa7+rec_mpapa7+selectsemi"];
    self.neura["weapons"]["iw8"]["primary"]["sub machine guns"][1] = ["uzi", "pp bizon", "aug", "mp5", "striker", "mp7"];

    self.neura["weapons"]["iw8"]["secondary"]["launchers"][0] = ["iw8_la_gromeo_mp", "iw8_la_kgolf_mp", "iw8_la_juliet_mp", "iw8_la_rpapa7_mp"];
    self.neura["weapons"]["iw8"]["secondary"]["launchers"][1] = ["pila", "strela-p", "jokr", "rpg-7"];

    self.neura["weapons"]["iw8"]["secondary"]["pistols"][0] = ["iw8_pi_mike1911_mp+akimbo_mike1911+ironsdefault_mike1911+mag_mike1911+rec_mike1911+slide_mike1911+triggrip_mike1911", "iw8_pi_golf21_mp+ammomod_slow+backno_golf21+ironsdefault_golf21+rec_golf21+slide_golf21+xmags_golf21", "iw8_pi_cpapa_mp+akimbo_cpapa+backno_cpapa+barlong_cpapa+buck_cpapa+ironsdefault_cpapa+rec_cpapa", "iw8_pi_papa320_mp+akimbo_papa320+brakepstl+ironsdefault_papa320+mag_papa320+pistolgrip_pstl03_papa320+rec_papa320+slide_papa320+trigcust02_papa320", "iw8_pi_mike9_mp+akimbo_mike9+back_mike9+ironsdefault_mike9+laserbalanced_pstl+rec_mike9+slide_mike9+xmags_mike9", "iw8_pi_decho_mp+akimbo_decho+ironsdefault_decho+mag_decho+pistolgrip_pstl01_decho+rec_decho+slide_decho", "iw8_pi_cpapa_mp+backno_cpapa+barshort_cpapa+buck_cpapa+fastreload+ironsdefault_cpapa+rec_cpapa"];
    self.neura["weapons"]["iw8"]["secondary"]["pistols"][1] = ["akimbo 1911", "x16", "akimbo .357", "akimbo m19", "akimbo renetti", "akimbo .50 gs", "snub .357"];

    self.neura["weapons"]["iw8"]["secondary"]["misc"][0] = ["iw8_knife_mp", "iw8_fists_mp", "iw8_me_riotshield_mp"];
    self.neura["weapons"]["iw8"]["secondary"]["misc"][1] = ["combat knife", "fists", "riot shield"];

    self.neura["weapons"]["iw8"]["equipment"][0] = ["frag_grenade_mp", "molotov_mp", "concussion_grenade_mp", "flash_grenade_mp", "c4_mp_p", "semtex_mp", "thermite_mp", "throwingknife_mp", "claymore_mp", "at_mine_mp", "trophy_mp", "support_box_mp", "tac_cover_mp", "emp_drone_player_mp"];
    self.neura["weapons"]["iw8"]["equipment"][1] = ["frag", "molotov", "concussion", "flash", "c4", "semtex", "thermite", "throwing knife", "claymore", "at mine", "trophy system", "support box", "tac cover", "emp drone"];

    // menu variables
    self.font            = "default";
    self.font_scale      = 0.95;
    self.option_limit    = 10;
    self.option_spacing  = 16;
    self.option_summary  = true;
    self.option_interact = true;
    self.x_offset        = -110;
    self.y_offset        = 80;
    self.element_count   = 0;
    self.element_list    = list("text,submenu,toggle,category,slider");

    // we should do flickershaders rainbow color yes ouu so awesome -et
    self.color[0] = (1,1,1); // when cursor is over a option, this is the color. this is white for now
    self.color[1] = (0.109803, 0.129411, 0.156862);
    self.color[2] = (0.133333, 0.152941, 0.180392);
    self.color[3] = (0.443, 0.455, 0.467);
    self.color[4] = self.color[0]; // this is normal color for option whenever cursor isn't over it

    self.cursor   = [];
    self.previous = [];
    self set_menu("neura");
    self set_title(self get_menu());
}

// add sfx for each game -et
initial_monitor()
{
    level endon("game_ended");
    self endon("disconnect");
    for (;;)
    {
        if (isalive(self))
        {
            if (!self custom_scripts\_util::in_menu())
            {
                if (self adsButtonPressed() && self isButtonPressed("-actionslot 1"))
                {
                    /*
                    if (is_true(self.option_interact))
                        // self sfx("entrance_sign_power_on_build");
                        self void();
                    */

                    self open_menu();
                    wait 0.15;
                }
            }
            else
            {
                menu   = self get_menu();
                cursor = self get_cursor();

                // force close if melee pressed
                if (self isbuttonpressed("+melee_zoom"))
                {
                    self close_menu();
                    self playlocalsound("mp_killstreak_tablet_gear");
                }
                else if (self usebuttonpressed()) // back
                {
                   // self sfx("zmb_powerup_activate");

                    if (isdefined(self.previous[(self.previous.size - 1)]))
                        self new_menu(self.previous[menu]);
                    else
                        self close_menu();

                    wait 0.15;
                }
                else if (self isButtonPressed("-actionslot 2") && !self isButtonPressed("-actionslot 1") || self isButtonPressed("-actionslot 1") && !self isButtonPressed("-actionslot 2")) // up & down
                {
                    if (isdefined(self.structure) && self.structure.size >= 2)
                    {
                        if (is_true(self.option_interact))
                            // self sfx("zmb_powerup_activate");
                            self void();

                        scrolling = self isButtonPressed("-actionslot 2") ? 1 : -1;
                        self set_cursor((cursor + scrolling));
                        
                        res = self update_scrolling(scrolling);
                        while (!res)
                        {
                            res = self update_scrolling(scrolling);
                        }
                    }
                    wait 0.07;
                }
                else if (self isButtonPressed("-actionslot 4") && !self isButtonPressed("-actionslot 3") || self isButtonPressed("-actionslot 3") && !self isButtonPressed("-actionslot 4"))
                {
                    if (is_true(self.structure[cursor]["slider"]))
                    {
                        if (is_true(self.option_interact))
                            // self sfx("zmb_wheel_wpn_acquired");
                            self void();

                        scrolling = self isButtonPressed("-actionslot 3") ? 1 : -1;
                        self set_slider(scrolling);

                        if (is_true(self.structure[cursor]["is_increment"]))
                        {
                            self thread execute_function(self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            self update_menu(menu, cursor);
                        }
                    }
                    wait 0.07;
                }
                else if (self isButtonPressed("+gostand"))
                {
                    if (isdefined(self.structure[cursor]["function"]))
                    {
                       // self sfx("part_pickup");
                        if (is_true(self.structure[cursor]["slider"]))
                        {
                            if (is_true(self.structure[cursor]["is_array"]))
                                self thread execute_function(self.structure[cursor]["function"], isdefined(self.structure[cursor]["array"]) ? self.structure[cursor]["array"][self.slider[menu + "_" + cursor]] : self.slider[menu + "_" + cursor], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);
                            else
                                self iprintlnbold("use the ^2slider controls^7, not the jump button!");
                        }
                        else
                            self thread execute_function(self.structure[cursor]["function"], self.structure[cursor]["argument_1"], self.structure[cursor]["argument_2"], self.structure[cursor]["argument_3"]);

                        // only update the menu visually if not a array
                        cursor_struct = self.structure[cursor];
                        if (isdefined(cursor_struct))
                        {
                            if (isdefined(cursor_struct["toggle"]) || !is_true(cursor_struct["is_array"]))
                            {
                                self update_menu(menu, cursor);
                            }
                        }
                    }
                    wait 0.18;
                }
            }
        }
        wait 0.05;
    }
}

setup_bind(pers, value, func)
{
    self setpers_if_uninitialized(pers, value);

    if (self getpers(pers) != "^1off^7")
    {
        self thread [[func]](self getpers(pers), pers);
    }
}

get_menu()
{
    return self.menu["menu"];
}

get_title()
{
    return self.menu["title"];
}

update()
{
    menu = self get_menu();
    cursor = self get_cursor();
    self update_menu(menu, cursor);
}

get_cursor()
{
    return self.cursor[self get_menu()];
}

set_menu(menu)
{
    if (isdefined(menu))
        self.menu["menu"] = menu;
}

set_title(title)
{
    if (isdefined(title))
        self.menu["title"] = title;
}

set_cursor(cursor)
{
    if (isdefined(cursor))
        self.cursor[self get_menu()] = cursor;
}

set_procedure()
{
    self.in_menu = !is_true(self.in_menu);
}

execute_function(function, argument_1, argument_2, argument_3, argument_4)
{
    if (!isdefined(function))
        return;

    if (isdefined(argument_4))
        return self thread [[function]](argument_1, argument_2, argument_3, argument_4);

    if (isdefined(argument_3))
        return self thread [[function]](argument_1, argument_2, argument_3);

    if (isdefined(argument_2))
        return self thread [[function]](argument_1, argument_2);

    if (isdefined(argument_1))
        return self thread [[function]](argument_1);

    return self thread [[function]]();
}

is_option(menu, cursor, player)
{
    if (isdefined(self.structure) && self.structure.size)
        for (i = 0; i < self.structure.size; i++)
            if (player.structure[cursor]["text"] == self.structure[i]["text"] && self get_menu() == menu)
                return true;

    return false;
}

set_slider(scrolling, index)
{
    menu    = self get_menu();
    index   = isdefined(index) ? index : self get_cursor();
    storage = ( menu + "_" + index );

    if (isdefined(self.structure[index]["array"]))
    {
        self notify("slider_array");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage]++;
            if (scrolling == 1)
                self.slider[storage]--;
        }

        if (self.slider[storage] > (self.structure[index]["array"].size - 1))
            self.slider[storage] = 0;

        if (self.slider[storage] < 0)
            self.slider[storage] = (self.structure[index]["array"].size - 1);

        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_ADDITIONAL_" + self.structure[index]["array"][self.slider[storage]]);
        }
    }
    else
    {
        self notify("slider_increment");

        if (isdefined(scrolling))
        {
            if (scrolling == -1)
                self.slider[storage] += self.structure[index]["increment"];
            if (scrolling == 1)
                self.slider[storage] -= self.structure[index]["increment"];
        }

        if (self.slider[storage] > self.structure[index]["maximum"])
            self.slider[storage] = self.structure[index]["minimum"];

        if (self.slider[storage] < self.structure[index]["minimum"])
            self.slider[storage] = self.structure[index]["maximum"];

        position = abs((self.structure[index]["maximum"] - self.structure[index]["minimum"])) / ((50 - 8));
        self.structure["current_index"] = self.structure[storage];

        slider_value = self.slider[storage];

        slider_bruh = self.menu["hud"]["slider"][0];
        if (isdefined(slider_bruh))
        {
            // TODO: sliders
            slider_elem = slider_bruh[index];
            if (isdefined(slider_elem))
                slider_elem set_text("MP/NEURA_STR12_" + slider_value);
        }

        self.menu["hud"]["slider"][2][index].x = (self.menu["hud"]["slider"][1][index].x + (abs((self.slider[storage] - self.structure[index]["minimum"])) / position) - 42);
    }
}

should_archive()
{
    if (!isalive(self) || self.element_count < 21)
        return false;

    return true;
}

destroy_element()
{
    if (!isdefined(self))
        return;

    self destroy();
    if (isdefined(self.player))
        self.player.element_count--;
}

set_text( text ) 
{
    if ( !isdefined( self ) || !isdefined( text ) )
        return;

    self.text = text;
    self settext( text );
}

create_text(text, override, font, font_scale, alignment, relative, x_offset, y_offset, color, alpha, sort)
{
    element                = self scripts\mp\hud_util::createfontstring(font, font_scale);
    if (isdefined(element))
    {
        element.color          = color;
        element.alpha          = alpha;
        element.sort           = sort;
        element.player         = self;
        element.archived       = self should_archive();

        element.foreground     = true;
        element.hidewheninmenu = false;
        element.showinkillcam = 0;

        element scripts\mp\hud_util::setpoint(alignment, relative, x_offset, y_offset);
        element set_text(text);

        self.element_count++;
    }

    return element;
}

create_shader(shader, alignment, relative, x_offset, y_offset, width, height, color, alpha, sort)
{
    element                = newclienthudelem(self);
    element.elemtype       = "icon";
    element.children       = [];
    element.color          = color;
    element.alpha          = alpha;
    element.sort           = sort;
    element.player         = self;
    element.archived       = self should_archive();
    element.foreground     = true;
    element.hidden         = false;
    element.hidewheninmenu = true;

    element scripts\mp\hud_util::setparent(level.uiparent);
    element scripts\mp\hud_util::setpoint(alignment, relative, x_offset, y_offset);
    element set_shader(shader, width, height);
    
    self.element_count++;

    return element;
}

set_shader(shader, width, height)
{
    if (!isdefined(shader))
    {
        if (!isdefined(self.shader))
            return;

        shader = self.shader;
    }

    if (!isdefined(width))
    {
        if (!isdefined(self.width))
            return;

        width = self.width;
    }

    if (!isdefined(height))
    {
        if (!isdefined(self.height))
            return;

        height = self.height;
    }

    self.shader = shader;
    self.width  = width;
    self.height = height;
    self setshader(shader, width, height);
}

clear_option()
{
    for (i = 0; i < self.element_list.size; i++)
    {
        clear_all(self.menu["hud"][self.element_list[i]]);
        self.menu["hud"][self.element_list[i]] = [];
    }
}

clear_all(array)
{
    if (!isdefined(array))
        return;

    keys = getarraykeys(array);
    for (i = 0; i < keys.size; i++)
    {
        if (isarray(array[keys[i]]))
        {
            foreach(key in array[keys[i]])
                if (isdefined(key))
                    key destroy_element();
        }
        else if (isdefined(array[keys[i]]))
            array[keys[i]] destroy_element();
    }
}

add_menu(title, shader)
{
    if (isdefined(title))
        self set_title(title);

    if (!isdefined(self.shader_option)) // shader_option needs to be defined before you try to add stuff to it
        self.shader_option = [];

    if (isdefined(shader))
        self.shader_option[self get_menu()] = true;

    self.structure = [];
}

add_iw8_option(text, summary, function, argument_1, argument_2, argument_3)
{
#ifndef S4
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;
    self.structure[self.structure.size] = option;
#endif
}

add_option(text, summary, function, argument_1, argument_2, argument_3)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;
    self.structure[self.structure.size] = option;
}

// add_toggle(text, summary, function, toggle, array, argument_1, argument_2, argument_3)
add_bind(name, func, pers, end_on) // lol im so lazy bro idc
{
    self add_menu(name);

    for (i = 0; i < 4; i++) 
    {
        option = name + " -> " + "[{+actionslot " + (i + 1) + "}]";
        bind = "+actionslot " + (i + 1);
        index = i + 1;
        prev_index = index - 1;
        end_on = pers;
        // toggle_nac_bind(bind, i, pers)
        self add_toggle(option, undefined, func, self.pers[pers + "_" + index], undefined, bind, index, pers);
    }
}

add_pers_toggle(text, summary, function, toggle, argument_1, argument_2, argument_3)
{
    option          = [];
    option["text"]     = text;
    option["summary"]  = summary;
    option["function"] = function;
    option["toggle"]   = is_true(self.pers[toggle]);
    option["argument_1"] = isdefined(argument_1) ? toggle : argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

add_dvar_toggle(text, summary, dvar, argument_1, argument_2, argument_3)
{
    option          = [];
    option["text"]     = text;
    option["summary"]  = summary;
    option["function"] = ::toggledvar;
    option["toggle"]   = is_true(getdvarint(dvar));
    option["argument_1"] = dvar;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

toggledvar(dvar)
{
    setdvar(dvar, !toggle(getdvarint(dvar)));
    //print(dvar + " new value: " + getdvar(dvar));
}

add_toggle(text, summary, function, toggle, array, argument_1, argument_2, argument_3)
{
    option          = [];
    option["text"]     = text;
    option["summary"]  = summary;
    option["function"] = function;
    option["toggle"]   = is_true(toggle);
    if (isdefined(array))
    {
        option["slider"] = true;
        option["is_array"] = true;
        option["array"]  = array;
    }

    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

add_array(text, summary, function, array, argument_1, argument_2, argument_3)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["slider"]     = true;
    option["is_array"]   = true;
    option["array"]      = array;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

actionslot_notify_map(slot)
{
    switch(slot)
    {
    case "[{+actionslot 1}]":
        return "+actionslot 1";
    case "[{+actionslot 2}]":
        return "+actionslot 2";
    case "[{+actionslot 3}]":
        return "+actionslot 3";
    case "[{+actionslot 4}]":
        return "+actionslot 4";
    default:
        break;
    }
}

add_increment(text, summary, function, start, minimum, maximum, increment, argument_1, argument_2, argument_3)
{
    option            = [];
    option["text"]       = text;
    option["summary"]    = summary;
    option["function"]   = function;
    option["slider"]     = true;
    option["is_increment"] = true;
    option["start"]      = start;
    option["minimum"]    = minimum;
    option["maximum"]    = maximum;
    option["increment"]  = increment;
    option["argument_1"] = argument_1;
    option["argument_2"] = argument_2;
    option["argument_3"] = argument_3;

    self.structure[self.structure.size] = option;
}

add_category(text)
{
    option          = [];
    option["text"]     = text;
    option["category"] = true;

    self.structure[self.structure.size] = option;
}

new_menu(menu)
{
    if (self get_menu() == "manage clients")
    {
        players = level.players;
        player = players[(self get_cursor())];
        self.select_player = player;
    }

    if (!isdefined(menu))
    {
        menu = self.previous[(self.previous.size - 1)];
        self.previous[(self.previous.size - 1)] = undefined;
    }
    else
        self.previous[self.previous.size] = self get_menu();

    self set_menu(menu);
    self clear_option();
    self create_option();
}

open_menu(menu)
{
    if (!isdefined(menu))
        menu = isdefined(self get_menu()) && self get_menu() != "neura" ? self get_menu() : "neura";

    // setup menu hud arrays
    if (!isdefined(self.menu["hud"]))
    {
        self.menu["hud"] = [];
        self.menu["hud"]["background"] = [];
        self.menu["hud"]["foreground"] = [];
        self.menu["hud"]["submenu"] = [];
        self.menu["hud"]["toggle"] = [];
        self.menu["hud"]["slider"] = [];
        self.menu["hud"]["category"] = [];
        // category indexes need init too tbh but wtv for now
        self.menu["hud"]["text"] = [];
        self.menu["hud"]["arrow"] = [];
    }

    if (!isdefined(self.slider))
        self.slider = [];

    self.current_menu_color = (0.345, 0.0, 0.929);

    self.menu["hud"]["title"]        = self create_text("MP/NEURA_TITLE_" + self get_title(), "MP_INGAME_ONLY/HP_UNLOCKS_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 1.75), self.color[4], 1, 10);
    // outline
    self.menu["hud"]["background"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), 222, 34, self.current_menu_color, 0.6, 1);
    // top bar
    self.menu["hud"]["background"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, 220, 32, self.color[1], 0.8, 2);
    // toggle box
    self.menu["hud"]["foreground"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 220, 16, self.color[1], 0.05, 3);
    // cursor - use these for flickershaders?
    self.menu["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), 214, 16, self.current_menu_color, 0.6, 4);
    // scrolling bar on the side
    //self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.4, 4);

    self set_menu(menu);
    self set_procedure();
    self create_option();

    if (getdvarint("rainbow") == 1)
        self thread flicker_shaders();

}

flicker_shaders() // colors from bliss - starts with original color
{
    self endon("disconnect");
    level endon("game_ended");
    self endon("exit_menu");
    self endon("end_flicker");

    first = true;

    for (;;)
    {
        color = self.current_menu_color;

        waittime = randomintrange(1,5);

        if (!first)
        {
            wait (waittime);
            self.menu["hud"]["foreground"][1] fadeovertime(waittime);
            self.menu["hud"]["foreground"][2] fadeovertime(waittime);
            self.menu["hud"]["background"][0] fadeovertime(waittime);
        }

        self.menu["hud"]["foreground"][1].color = color;
        self.menu["hud"]["foreground"][2].color = color;
        self.menu["hud"]["background"][0].color = color;
        wait (randomintrange(1, 5));
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (0.698, 0.553, 0.847);
        self.menu["hud"]["foreground"][2].color = (0.698, 0.553, 0.847);
        self.menu["hud"]["background"][0].color = (0.698, 0.553, 0.847);
        wait (waittime);
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (0.325, 0.808, 0.953);
        self.menu["hud"]["foreground"][2].color = (0.325, 0.808, 0.953);
        self.menu["hud"]["background"][0].color = (0.325, 0.808, 0.953);
        wait (waittime);
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (1, 0.216, 0.396);
        self.menu["hud"]["foreground"][2].color = (1, 0.216, 0.396);
        self.menu["hud"]["background"][0].color = (1, 0.216, 0.396);
        wait (waittime);
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (1, 1, 1);
        self.menu["hud"]["foreground"][2].color = (1, 1, 1);
        self.menu["hud"]["background"][0].color = (1, 1, 1);
        wait (waittime);
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (0.54902, 0.168627, 0.929412);
        self.menu["hud"]["foreground"][2].color = (0.54902, 0.168627, 0.929412);
        self.menu["hud"]["background"][0].color = (0.54902, 0.168627, 0.929412);
        wait (waittime);
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (0.976471, 0, 0.560784);
        self.menu["hud"]["foreground"][2].color = (0.976471, 0, 0.560784);
        self.menu["hud"]["background"][0].color = (0.976471, 0, 0.560784);
        wait (waittime);
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (1, 0.352941, 0.207843);
        self.menu["hud"]["foreground"][2].color = (1, 0.352941, 0.207843);
        self.menu["hud"]["background"][0].color = (1, 0.352941, 0.207843);
        wait (waittime);
        self.menu["hud"]["foreground"][1] fadeovertime(waittime);
        self.menu["hud"]["foreground"][2] fadeovertime(waittime);
        self.menu["hud"]["background"][0] fadeovertime(waittime);
        self.menu["hud"]["foreground"][1].color = (0.886275, 0, 0.682353);
        self.menu["hud"]["foreground"][2].color = (0.886275, 0, 0.682353);
        self.menu["hud"]["background"][0].color = (0.886275, 0, 0.682353);
        if (first)
            first = false;
        wait 0.05;
    }
}

close_menu()
{
    self set_procedure();
    self clear_option();
    self clear_all(self.menu["hud"]);
    self notify("exit_menu");
}

close_menu_if_open()
{
    if (self custom_scripts\_util::in_menu())
        self close_menu();
}

close_menu_game_over()
{
    self endon("disconnect");
    level waittill("game_ended");
    self thread close_menu_if_open();
}

create_title(title)
{
    title_ = isdefined(title) ? title : self get_title();
    self.menu["hud"]["title"] set_text("MP/NEURA_TITLE_" + sym() + title_);
}

create_summary(summary)
{
    if (isdefined(self.menu["hud"]["summary"]) && !is_true(self.option_summary) || !isdefined(self.structure[self get_cursor()]["summary"]) && isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"] destroy_element();

    if (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary))
    {
        summary_ = tolower(isdefined(summary) ? summary : self.structure[self get_cursor()]["summary"]);
        lol_ = "MP/NEURA_INFO_" + "ߵ " + summary_;
        if (!isdefined(self.menu["hud"]["summary"]))
            self.menu["hud"]["summary"] = self create_text(lol_, "MP_INGAME_ONLY/HQ_AVAILABLE_IN", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 35), self.color[4], 1, 10);
        else
            self.menu["hud"]["summary"] set_text(lol_);
    }
}

sym()
{
    symbols = ["ߕ"]; // array for rn
    symbol = symbols[randomint(symbols.size)];
    return symbol + " ";
}

override_string_for_index(index)
{
    switch(index)
    {
        case 1:
            return "MP_INGAME_ONLY/HOLD_TO_START_GAME";
        case 2:
            return "MP_INGAME_ONLY/HQ_NEXT_IN";
        case 3:
            return "MP_INGAME_ONLY/HQ_NO_RESPAWN";
        case 4:
            return "MP_INGAME_ONLY/HQ_REINFORCEMENTS_IN";
        case 5:
            return "MP_INGAME_ONLY/HQ_TIME_REMAINING";
        case 6:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_1";
        case 7:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_10";
        case 8:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_11";
        case 9:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_12";
        case 10:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_13";
        case 11:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_14";
        case 12:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_15";
        case 13:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_16";
        case 14:
            return "MP_INGAME_ONLY/OBJ_HVT_CAPS_17";
        default:
            return undefined;
    }
}

create_option()
{
    self clear_option();
    structure();

    if (!isdefined(self.structure) || !self.structure.size)
        self add_option("nothing to display..");

    if (!isdefined(self get_cursor()))
        self set_cursor(0);

    start = 0;
    if ((self get_cursor() > int(((self.option_limit - 1) / 2))) && (self get_cursor() < (self.structure.size - int(((self.option_limit + 1) / 2)))) && (self.structure.size > self.option_limit))
        start = (self get_cursor() - int((self.option_limit - 1) / 2));

    if ((self get_cursor() > (self.structure.size - (int(((self.option_limit + 1) / 2)) + 1))) && (self.structure.size > self.option_limit))
        start = (self.structure.size - self.option_limit);

    self create_title();
    if (is_true(self.option_summary))
        self create_summary();

    if (isdefined(self.structure) && self.structure.size)
    {
        limit = min(self.structure.size, self.option_limit);
        for (i = 0; i < limit; i++)
        {
            index      = (i + start);
            cursor     = (self get_cursor() == index);
            color[0] = cursor ? self.color[0] : self.color[4];
            color[1] = is_true(self.structure[index]["toggle"]) ? cursor ? self.color[0] : (1,1,1) : cursor ? self.color[2] : self.color[1];

            // new menu text
            if (isdefined(self.structure[index]["function"]) && self.structure[index]["function"] == ::new_menu)
                self.menu["hud"]["submenu"][index] = self create_text("MP/NEURA_STR14_>", "MP_INGAME_ONLY/OBJ_HVT_CAPS_17", self.font, 0.65, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), color[0], 1, 10);
            if (isdefined(self.structure[index]["toggle"]))
            {
                self.menu["hud"]["toggle"][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 204), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, color[1], .65, 10);
                // self.menu["hud"]["current_toggle_index"] = self.menu["hud"]["toggle"][index];
            }

            if (is_true(self.structure[index]["slider"]))
            {
                storage = (self get_menu() + "_" + index);
                self.slider[storage] = isdefined(self.structure[index]["array"]) ? 0 : self.structure[index]["start"];

                if (isdefined(self.structure[index]["array"]))
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.structure[index]["array"][ self.slider[storage] ], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 210), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                    }
                }
                else
                {
                    if (cursor)
                    {
                        self.menu["hud"]["slider"][0] = [];
                        self.menu["hud"]["slider"][0][index] = self create_text("MP/NEURA_STR13_" + self.slider[storage], "MP_INGAME_ONLY/OBJ_HVT_CAPS_16", self.font, (self.font_scale), "CENTER", "TOPCENTER", (self.x_offset + 187), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[4], 1, 10);
                    }

                    self.menu["hud"]["slider"][1][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 20)), 50, 8, cursor ? self.color[2] : self.color[1], 1, 8);
                    self.menu["hud"]["slider"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 170), (self.y_offset + ((i * self.option_spacing) + 20)), 8, 8, cursor ? self.color[0] : self.color[3], 1, 9);
                }

                // idek what this does but Ok
                self set_slider(undefined, index);
            }

            if (is_true(self.structure[index]["category"]))
            {
                og_string = "MP/NEURA_STR" + (i + 1) + "_" + tolower(self.structure[index]["text"]);
                override_string = override_string_for_index(i + 1);

                self.menu["hud"]["category"][0][index] = self create_text(og_string, override_string, self.font, self.font_scale, "CENTER", "TOPCENTER", (self.x_offset + 102), (self.y_offset + ((i * self.option_spacing) + 24)), self.color[0], 1, 10);
                self.menu["hud"]["category"][1][index] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
                self.menu["hud"]["category"][2][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 212), (self.y_offset + ((i * self.option_spacing) + 24)), 30, 1, self.color[0], 1, 10);
            }
            else
            {
                menu = self get_menu();
                shader_option = self.shader_option[menu];
                if (is_true(shader_option))
                {
                    shader = isdefined(self.structure[index]["text"]) ? self.structure[index]["text"] : "white";
                    color  = isdefined(self.structure[index]["argument_1"]) ? self.structure[index]["argument_1"] : (1, 1, 1); // come back
                    width  = isdefined(self.structure[index]["argument_2"]) ? self.structure[index]["argument_2"] : 20;
                    height = isdefined(self.structure[index]["argument_3"]) ? self.structure[index]["argument_3"] : 20;
                    self.menu["hud"]["text"][index] = self create_shader(shader, "CENTER", "TOPCENTER", (self.x_offset + ((i * 24) - ((limit * 10) - 109))), (self.y_offset + 32), width, height, color, 1, 10);
                }
                else
                {
                    menu_text = (is_true(self.structure[index]["slider"]) ? self.structure[index]["text"]/*+":"*/ : self.structure[index]["text"]);
                    if (self get_menu() != "manage clients")
                        menu_text = tolower(menu_text);

                    og_string = "MP/NEURA_STR" + (i + 1) + "_" + tolower(self.structure[index]["text"]);
                    override_string = override_string_for_index(i + 1);

                    self.menu["hud"]["text"][index] = self create_text(og_string, override_string, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", isdefined(self.structure[index]["toggle"]) ? (self.x_offset + 4) : (self.x_offset + 4), (self.y_offset + ((i * self.option_spacing) + 19)), color[0], 1, 10);
                }
            }
        }

        if (!isdefined(self.menu["hud"]["text"][self get_cursor()]))
            self set_cursor((self.structure.size - 1));
    }

    self update_resize();
}

update_scrolling(scrolling)
{
    cursor_index = self get_cursor();
    structure = self.structure[cursor_index];

    if (isdefined(structure) && is_true(structure["category"]))
    {
        self set_cursor((self get_cursor() + scrolling));
        return false;
    }

    if ((self.structure.size > self.option_limit) || (self get_cursor() >= 0) || (self get_cursor() <= 0))
    {
        if ((self get_cursor() >= self.structure.size) || (self get_cursor() < 0))
            self set_cursor((self get_cursor() >= self.structure.size) ? 0 : (self.structure.size - 1));

        self create_option();
    }

    self update_resize();

    return true;
}

update_resize()
{
    limit    = min(self.structure.size, self.option_limit);
    height   = int((limit * self.option_spacing));
    adjust   = (self.structure.size > self.option_limit) ? int(((112 / self.structure.size) * limit)) : height;

    if ((height - adjust) > 0)
        position = (self.structure.size - 1) / (height - adjust);
    else
        position = 0;

    if (is_true(self.shader_option[self get_menu()]))
    {
        self.menu["hud"]["foreground"][1].y = (self.y_offset + 46);
        self.menu["hud"]["foreground"][1].x = (self.menu["hud"]["text"][self get_cursor()].x - 10);

        if (!isdefined(self.menu["hud"]["arrow"][0]))
            self.menu["hud"]["arrow"][0] = self create_shader("ui_scrollbar_arrow_left", "TOP_LEFT", "TOPCENTER", (self.x_offset + 10), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        if (!isdefined(self.menu["hud"]["arrow"][1]))
            self.menu["hud"]["arrow"][1] = self create_shader("ui_scrollbar_arrow_right", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 211), (self.y_offset + 29), 6, 6, self.color[4], 1, 10);

        self.menu["hud"]["foreground"][2] destroy_element();
    }
    else
    {
        self.menu["hud"]["foreground"][1].y = (self.menu["hud"]["text"][self get_cursor()].y - 3);
        self.menu["hud"]["foreground"][1].x = (self.x_offset + 1);

        if (!isdefined(self.menu["hud"]["foreground"][2]))
            self.menu["hud"]["foreground"][2] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 221), (self.y_offset + 16), 4, 16, self.current_menu_color, 0.6, 4);

        if (isdefined(self.menu["hud"]["arrow"][0])) self.menu["hud"]["arrow"][0] destroy_element();
        if (isdefined(self.menu["hud"]["arrow"][1])) self.menu["hud"]["arrow"][1] destroy_element();
    }

    self.menu["hud"]["background"][0] set_shader(self.menu["hud"]["background"][0].shader, self.menu["hud"]["background"][0].width, is_true(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? 66 : 50) : (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? (height + 34) : (height + 18)));
    self.menu["hud"]["background"][1] set_shader(self.menu["hud"]["background"][1].shader, self.menu["hud"]["background"][1].width, is_true(self.shader_option[self get_menu()]) ? (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? 64 : 48) : (isdefined(self.structure[self get_cursor()]["summary"]) && is_true(self.option_summary) ? (height + 32) : (height + 16)));
    self.menu["hud"]["foreground"][0] set_shader(self.menu["hud"]["foreground"][0].shader, self.menu["hud"]["foreground"][0].width, is_true(self.shader_option[self get_menu()]) ? 32 : height);
    self.menu["hud"]["foreground"][1] set_shader(self.menu["hud"]["foreground"][1].shader, is_true(self.shader_option[self get_menu()]) ? 20 : 214, is_true(self.shader_option[self get_menu()]) ? 2 : 16);
    self.menu["hud"]["foreground"][2] set_shader(self.menu["hud"]["foreground"][2].shader, self.menu["hud"]["foreground"][2].width, adjust);

    if (isdefined(self.menu["hud"]["foreground"][2]))
    {
        self.menu["hud"]["foreground"][2].y = (self.y_offset + 16);
        if (self.structure.size > self.option_limit)
            self.menu["hud"]["foreground"][2].y += (self get_cursor() / position);
    }

    if (isdefined(self.menu["hud"]["summary"]))
        self.menu["hud"]["summary"].y = is_true(self.shader_option[self get_menu()]) ? (self.y_offset + 51) : (self.y_offset + ((limit * self.option_spacing) + 19));
}

update_menu(menu, cursor, force)
{
    if (isdefined(menu) && !isdefined(cursor) || !isdefined(menu) && isdefined(cursor))
        return;

    if (isdefined(menu) && isdefined(cursor))
    {
        foreach(player in level.players)
        {
            if (!isdefined(player) || !player custom_scripts\_util::in_menu())
                continue;

            if (player get_menu() == menu || self != player && player is_option(menu, cursor, self))
                if (isdefined(player.menu["hud"]["text"][cursor]) || player == self && player get_menu() == menu && isdefined(player.menu["hud"]["text"][cursor]) || self != player && player is_option(menu, cursor, self) || is_true(force))
                    player create_option();
        }
    }
    else
    {
        if (isdefined(self) && self custom_scripts\_util::in_menu())
            self create_option();
    }
}

/*


        menu structure lives here
        custom_scripts::_structure (_structure)

*/

structure()
{
    menu = self get_menu();
    if (!isdefined(menu))
        menu = "unassigned";
    
    increment_controls = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5no jump^7 needed";
    slider_controls = "^5[{+actionslot 3}] ^7/ ^5[{+actionslot 4}] ^7to use slider, ^5[{+gostand}]^7 to select";
    credits = "made with ^5<3^7 by ^5ethan ^7& ^5mikey";
    client = get_current_client();
    title = "neura ^5" + client + "^7 - ";
    bind_list = list("instaswap,nac,change class,eq,damage,illusion,stuck,velocity,bolt,canswap,spectator,scavenger,empty clip,one bullet");

    switch(menu)
    {
    case "neura":
        self.bind_index = false;
        self add_menu(title + self get_name());
        self add_option("mods & toggles", credits, ::new_menu, "mods & toggles");
        self add_option("glitches", credits, ::new_menu, "glitches");
        self add_option("binds", credits, ::new_menu, "binds");
        self add_option("position", credits, ::new_menu, "position");
        self add_option("bolt movement", credits, ::new_menu, "bolt movement");
        self add_option("edit velocity", credits, ::new_menu, "edit velocity");
        self add_option("class manager", credits, ::new_menu, "class manager");
        self add_option("game settings", credits, ::new_menu, "game settings");
        self add_option("aimbot settings", credits, ::new_menu, "aimbot settings");
        self add_option("client settings", credits, ::new_menu, "manage clients");
        break;
    case "mods & toggles":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("toggle settings", undefined, ::new_menu, "toggle settings");
        self add_pers_toggle("invincibility", undefined, custom_scripts\_z_func::toggle_invincibility, "invincible");
        self add_pers_toggle("elevators", undefined, custom_scripts\_z_func::toggle_elevators, "elevators");
        self add_pers_toggle("alt swaps", undefined, custom_scripts\_z_func::toggle_alt_swaps, "alt_swap");
        self add_pers_toggle("infinite equipment", undefined, custom_scripts\_z_func::toggle_inf_eq, "inf_eq");
        self add_pers_toggle("instaswaps", undefined, custom_scripts\_z_func::instaswaps, "instaswaps");
        self add_pers_toggle("auto prone", undefined, custom_scripts\_z_func::autoprone, "autoprone");
        self add_pers_toggle("round end prone", undefined, custom_scripts\_z_func::togglepers, "autoprone_endgame", true);
        self add_pers_toggle("auto reload", undefined, custom_scripts\_z_func::autoreload, "autoreload");
        self add_pers_toggle("headbounces", undefined, custom_scripts\_z_func::toggle_headbounces, "headbounces");
        self add_pers_toggle("putaway equipment", undefined, ::togglepers, "eq_putaway", true);
        self add_pers_toggle("real scavenger", undefined, ::togglepers, "real_scavenger", true);
        self add_pers_toggle("ufo", "toggle noclip - [{+gostand}] + [{+melee}]", ::ufo_mode, "ufo_mode");
        break;
    case "toggle settings":
        self.bind_index = false;
        self add_menu(menu);
        self add_increment("class wrap", increment_controls, ::setpersmenu, int(self getpers("class_wrap")), 2, 20, 1, "class_wrap");
        self add_increment("instaswaps time", increment_controls, ::setpersmenu, float(self getpers("instaswaps_time")), 0.1, 1, 0.01, "instaswaps_time");
        self add_array("auto prone mode", slider_controls, ::setpersmenu, list("air,always"), "autoprone_mode");
        self add_array("stuck weapon (bind)", slider_controls, ::setpersmenu, list("semtex,molotov,thermite"), "stuck_weapon");
        self add_option("choose equipment (bind)", undefined, ::new_menu, "equipment bind");
        break;
    case "position":
        self.bind_index = false;
        self add_menu(menu);
        self add_array("teleport bots", slider_controls, ::move_bots, list("self,crosshair"));
        self add_pers_toggle("freeze bots", undefined, ::togglepers, "frozen_bots", true);
        self add_option("unstuck", undefined, ::unstuck);
        self add_pers_toggle("save and load binds", undefined, ::toggle_snl, "snl");
        self add_option("save position", undefined, ::save_spawn);
        self add_option("load position", undefined, ::load_spawn);
        self add_option("reset position", undefined, ::reset_position);
        if (float(self getpers("saveposx")) != 0 && float(self getpers("saveposy")) != 0 && float(self getpers("saveposz")) != 0)
        {
            self add_increment("change x", increment_controls, ::setpersmenu, float(self getpers("saveposx")), -500000, 5000000, float(self getpers("poschangeby")), "saveposx");
            self add_increment("change y", increment_controls, ::setpersmenu, float(self getpers("saveposy")), -500000, 5000000, float(self getpers("poschangeby")), "saveposy");
            self add_increment("change z", increment_controls, ::setpersmenu, float(self getpers("saveposz")), -500000, 5000000, float(self getpers("poschangeby")), "saveposz");
            self add_increment("change by", increment_controls, ::setpersmenu, float(self getpers("poschangeby")), 5, 10000, 5, "poschangeby");
        }
        break;
    case "aimbot settings":
        self.bind_index = false;
        self add_menu(menu);
        self add_pers_toggle("aimbot", undefined, ::aimbot, "aimbot");
        self add_increment("range", increment_controls, ::setpersmenu, int(self getpers("aimbot_range")), 100, 5000, 100, "aimbot_range");
        self add_array("delay", slider_controls, ::setpersmenu, list("0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1"), "aimbot_delay");
        break;
    case "glitches":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("one handed gun", undefined, ::one_handed_gun);
        self add_option("switch to equipment", "^5" + self.neura["weapons"][client]["equipment"][0].size + " ^7equipment available", ::new_menu, "equipment");
        break;
    case "binds":
        self.bind_index = true;
        self add_menu(menu);
        foreach (bind in bind_list)
            self add_option(bind, undefined, ::new_menu, bind);
        break;
    case "bolt movement":
        self.bind_index = false;
        self add_menu(menu);
        self add_increment("bolt speed", increment_controls, ::setpersmenu, float(self getpers("boltspeed")), 0.1, 10, 0.1, "boltspeed");
        self add_option("save bolt", "bolt count: ^5" + int(self getpers("boltcount")), ::save_bolt);
        self add_option("delete last bolt", "bolt count: ^5" + int(self getpers("boltcount")), ::delete_last_bolt);
        break;
    case "edit velocity":
        self.bind_index = false;
        self add_menu(menu);
        self add_increment("change x", increment_controls, ::setpersmenu, float(self getpers("velx")), -2000, 2000, float(self getpers("velocitychangeby")), "velx");
        self add_increment("change x", increment_controls, ::setpersmenu, float(self getpers("vely")), -2000, 2000, float(self getpers("velocitychangeby")), "vely");
        self add_increment("change x", increment_controls, ::setpersmenu, float(self getpers("velz")), -2000, 2000, float(self getpers("velocitychangeby")), "velz");
        self add_increment("change by", increment_controls, ::setpersmenu, float(self getpers("velocitychangeby")), 5, 1000, 5, "velocitychangeby");
        break;
    case "equipment":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client][menu][1][i], undefined, ::nacto, self.neura["weapons"][client][menu][0][i]);
        }
        break;
    case "equipment bind":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["equipment"][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["equipment"][1][i], undefined, ::setpersmenu, self.neura["weapons"][client]["equipment"][0][i], "eq_weapon");
        }
        break;
    case "class manager":
        self.bind_index = false;
        self add_menu(menu);
        // self add_array("perks", "running ^5" + self.pers["my_perks"].size + " ^7custom perks", ::toggle_perk, self.neura["perks"]);
        self add_array("drop weapon", slider_controls, ::drop_util, list("current,secondary,all"));
        self add_array("save & load class", slider_controls, ::class_manager, list("save,load"));
        self add_array("refill ammo", slider_controls, ::refill_my_ammo, list("all weapons,current"));
        self add_option("take weapon", undefined, ::take_current);
        self add_pers_toggle("replace weapon", "replace current when giving weapon", ::togglepers, "replace_weapon", true);
        self add_iw8_option("primaries", "primaries for ^5iw8", ::new_menu, "primaries (iw8)");
        self add_iw8_option("secondaries", "secondaries for ^5iw8", ::new_menu, "secondaries (iw8)");
        break;
    case "primaries (iw8)":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("snipers", "^5" + self.neura["weapons"][client]["primary"]["snipers"][0].size + " ^7weapons available", ::new_menu, "snipers");
        self add_option("shotguns", "^5" + self.neura["weapons"][client]["primary"]["shotguns"][0].size + " ^7weapons available", ::new_menu, "shotguns");
        self add_option("assault rifles", "^5" + self.neura["weapons"][client]["primary"]["assault rifles"][0].size + " ^7weapons available", ::new_menu, "assault rifles");
        self add_option("sub machine guns", "^5" + self.neura["weapons"][client]["primary"]["sub machine guns"][0].size + " ^7weapons available", ::new_menu, "sub machine guns");
        self add_option("light machine guns", "^5" + self.neura["weapons"][client]["primary"]["light machine guns"][0].size + " ^7weapons available", ::new_menu, "light machine guns");
        break;
    case "secondaries (iw8)":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("launchers", "^5" + self.neura["weapons"][client]["secondary"]["launchers"][0].size + " ^7weapons available", ::new_menu, "launchers");
        self add_option("pistols", "^5" + self.neura["weapons"][client]["secondary"]["pistols"][0].size + " ^7weapons available", ::new_menu, "pistols");
        self add_option("misc", "^5" + self.neura["weapons"][client]["secondary"]["misc"][0].size + " ^7weapons available", ::new_menu, "misc");
        break;
    case "launchers":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], "id: ^5" + self.neura["weapons"][client]["secondary"][menu][0][i], ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "pistols":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "misc":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["secondary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["secondary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["secondary"][menu][0][i]);
        }
        break;
    case "snipers":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "shotguns":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "assault rifles":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "light machine guns":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "sub machine guns":
        self.bind_index = false;
        self add_menu(menu);
        for (i = 0; i < self.neura["weapons"][client]["primary"][menu][0].size; i++) 
        {
            self add_option(self.neura["weapons"][client]["primary"][menu][1][i], undefined, ::givegun, self.neura["weapons"][client]["primary"][menu][0][i]);
        }
        break;
    case "game settings":
        self.bind_index = false;
        self add_menu(menu);
        self add_option("dvars", undefined, ::new_menu, "dvars");
        // self add_option("spawn bot", undefined, ::spawnbot);
        self add_toggle("toggle rainbow", undefined, ::rainbow_menu, getdvarint("rainbow"));
        self add_pers_toggle("clean killcam", "remove some hud elems from kc", ::toggle_clean_kc, "clean_kc");
        self add_pers_toggle("messages", undefined, ::togglepers, "messages");
        self add_array("fake bounces", slider_controls, ::manage_bounce, list("spawn,delete"));
        break;
    case "dvars":
        self.bind_index = false;
        self add_menu(menu);
        // add_toggle(text, summary, function, toggle, array, argument_1, argument_2, argument_3)
        self add_dvar_toggle("jump slowdown", undefined, "LNOKTQPLKO");
        self add_dvar_toggle("unlimited sprint", undefined, "MSOOMPMPQS");
        self add_increment("killcam time", increment_controls, ::setdvarmenu, getdvarfloat("scr_killcam_time"), 5, 10, 1, "scr_killcam_time");
        // self add_increment("pad packets", increment_controls, ::setdvarmenu, getdvarfloat("NTNRLNTMRR"), 50, 20000, 50, "NTNRLNTMRR");
        self add_increment("pickup radius", increment_controls, ::setdvarmenu, getdvarfloat("MTOQQKKRPS"), 50, 20000, 50, "MTOQQKKRPS");
        self add_increment("knockback", increment_controls, ::setdvarmenu, getdvarfloat("NSMSTQROLM"), 50, 20000, 50, "NSMSTQROLM");
        break;
    case "manage clients":
        self.bind_index = false;
        self add_menu(menu);
        players = level.players;
        foreach (player in players)
        {
            // party icon for self :3
            if (player ishost())
                player_text = "ߵ " + player get_name();
            else
                player_text = player get_name();

            self add_option(player_text, undefined, ::new_menu, "player option");
        }
        break;
    default: // shitty bind menu solution (but works :3)
        if (is_true(self.bind_index))
            self bind_index(menu, increment_controls);
        else 
            self player_index(menu, self.select_player);
        break;
    }
}

player_index(menu, player, slider_controls)
{
    if (!isdefined(player) || !isplayer(player))
        menu = "unassigned";

    switch(menu)
    {
    case "player option":
        self add_menu(player.name);
        self add_option("kill player", undefined, ::kill_player, player);
        self add_option("change team", undefined, ::change_player_team, player);
        self add_array("teleport to", slider_controls, ::manage_teleport, list("me,them,crosshair"), player);
        if (isai(player) || isbot(player))
        {
            self add_option("look at me", undefined, ::look_at_me, player);
            self add_option("give shield", undefined, ::give_player_shield, player);
            self add_option("set current weapon", "will set to: ^5" + self getcurrentweapon().basename, ::set_bot_weapon, player, self getcurrentweapon());
        }
        break;
    case "unassigned":
        self add_menu(menu);
        self add_option("this menu is unassigned");
        break;
    default:
        self add_menu("error");
        self add_option("unable to load " + menu);
        break;
    }
}

bind_index(menu, increment_controls) 
{
    if (!isdefined(menu))
        menu = "unassigned";

    switch(menu) 
    {
        case "instaswap":
            self add_bind(menu, ::toggle_instaswap_bind, "instaswap");
            break;
        case "nac":
            self add_bind(menu, ::toggle_nac_bind, "nac");
            break;
        case "change class":
            self add_bind(menu, ::toggle_class_bind, "class");
            break;
        case "eq":
            self add_bind(menu, ::toggle_eq_bind, "eq");
            break;
        case "damage":
            self add_bind(menu, ::toggle_damage_bind, "damage");
            break;
        case "illusion":
            self add_bind(menu, ::toggle_illusion_bind, "illusion");
            break;
        case "stuck":
            self add_bind(menu, ::toggle_stuck_bind, "stuck");
            break;
        case "bolt":
            self add_bind(menu, ::toggle_bolt_bind, "bolt");
            break;
        case "velocity":
            self add_bind(menu, ::toggle_velocity_bind, "velocity");
            break;
        case "canswap":
            self add_bind(menu, ::toggle_canswap_bind, "canswap");
            break;
        case "scavenger":
            self add_bind(menu, ::toggle_scavenger_bind, "scavenger");
            break;
        case "spectator":
            self add_bind(menu, ::toggle_spectator_bind, "spectator");
            break;
        case "empty clip":
            self add_bind(menu, ::toggle_emptyclip_bind, "empty_clip");
            break;
        case "one bullet":
            self add_bind(menu, ::toggle_onebullet_bind, "one_bullet");
            break;
        case "unassigned":
            self add_menu(menu);
            self add_option("this menu is unassigned");
            break;
        default:
            self add_menu("error");
            self add_option("unable to load " + menu);
            break;
    }
}

// Antigravity - weapon_defs.qc
// All weapon stat definitions using parallel arrays

void AG_InitWeapons()
{
    // ── WEP_KNIFE ──────────────────────────────────────────────────
    wep_name[WEP_KNIFE]           = "Knife";
    wep_price[WEP_KNIFE]          = 0;
    wep_damage_min[WEP_KNIFE]     = 45;
    wep_damage_max[WEP_KNIFE]     = 65;
    wep_damage_head[WEP_KNIFE]    = 500;
    wep_firerate[WEP_KNIFE]       = 1.2;
    wep_reload_time[WEP_KNIFE]    = 0;
    wep_mag_size[WEP_KNIFE]       = 1;
    wep_reserve[WEP_KNIFE]        = 0;
    wep_range_falloff[WEP_KNIFE]  = 64;
    wep_spread_stand[WEP_KNIFE]   = 0;
    wep_spread_crouch[WEP_KNIFE]  = 0;
    wep_spread_move[WEP_KNIFE]    = 0;
    wep_spread_aim[WEP_KNIFE]     = 0;
    wep_recoil_up[WEP_KNIFE]      = 0;
    wep_recoil_side[WEP_KNIFE]    = 0;
    wep_penetration[WEP_KNIFE]    = 0;
    wep_is_auto[WEP_KNIFE]        = 0;
    wep_zoom_fov[WEP_KNIFE]       = 90;
    wep_snd_fire[WEP_KNIFE]       = "weapons/knife_slash.ogg";
    wep_snd_reload[WEP_KNIFE]     = "";
    wep_model_world[WEP_KNIFE]    = "models/weapons/knife.obj";
    wep_model_view[WEP_KNIFE]     = "models/weapons/knife.obj";

    // ── WEP_PISTOL ─────────────────────────────────────────────────
    wep_name[WEP_PISTOL]          = "Pistol";
    wep_price[WEP_PISTOL]         = 200;
    wep_damage_min[WEP_PISTOL]    = 25;
    wep_damage_max[WEP_PISTOL]    = 35;
    wep_damage_head[WEP_PISTOL]   = 80;
    wep_firerate[WEP_PISTOL]      = 4.0;
    wep_reload_time[WEP_PISTOL]   = 2.0;
    wep_mag_size[WEP_PISTOL]      = 15;
    wep_reserve[WEP_PISTOL]       = 45;
    wep_range_falloff[WEP_PISTOL] = 800;
    wep_spread_stand[WEP_PISTOL]  = 0.03;
    wep_spread_crouch[WEP_PISTOL] = 0.015;
    wep_spread_move[WEP_PISTOL]   = 0.06;
    wep_spread_aim[WEP_PISTOL]    = 0.4;
    wep_recoil_up[WEP_PISTOL]     = 1.5;
    wep_recoil_side[WEP_PISTOL]   = 0.8;
    wep_penetration[WEP_PISTOL]   = 50;
    wep_is_auto[WEP_PISTOL]       = 0;
    wep_zoom_fov[WEP_PISTOL]      = 75;
    wep_snd_fire[WEP_PISTOL]      = "weapons/pistol_fire.ogg";
    wep_snd_reload[WEP_PISTOL]    = "weapons/pistol_reload.ogg";
    wep_model_world[WEP_PISTOL]   = "models/weapons/pistol.obj";
    wep_model_view[WEP_PISTOL]    = "models/weapons/pistol.obj";

    // ── WEP_SMG ────────────────────────────────────────────────────
    wep_name[WEP_SMG]             = "SMG";
    wep_price[WEP_SMG]            = 1200;
    wep_damage_min[WEP_SMG]       = 26;
    wep_damage_max[WEP_SMG]       = 32;
    wep_damage_head[WEP_SMG]      = 75;
    wep_firerate[WEP_SMG]         = 10.0;
    wep_reload_time[WEP_SMG]      = 2.4;
    wep_mag_size[WEP_SMG]         = 30;
    wep_reserve[WEP_SMG]          = 90;
    wep_range_falloff[WEP_SMG]    = 600;
    wep_spread_stand[WEP_SMG]     = 0.04;
    wep_spread_crouch[WEP_SMG]    = 0.02;
    wep_spread_move[WEP_SMG]      = 0.09;
    wep_spread_aim[WEP_SMG]       = 0.5;
    wep_recoil_up[WEP_SMG]        = 1.8;
    wep_recoil_side[WEP_SMG]      = 1.2;
    wep_penetration[WEP_SMG]      = 30;
    wep_is_auto[WEP_SMG]          = 1;
    wep_zoom_fov[WEP_SMG]         = 72;
    wep_snd_fire[WEP_SMG]         = "weapons/smg_fire.ogg";
    wep_snd_reload[WEP_SMG]       = "weapons/smg_reload.ogg";
    wep_model_world[WEP_SMG]      = "models/weapons/smg.obj";
    wep_model_view[WEP_SMG]       = "models/weapons/smg.obj";

    // ── WEP_SHOTGUN ────────────────────────────────────────────────
    wep_name[WEP_SHOTGUN]         = "Shotgun";
    wep_price[WEP_SHOTGUN]        = 1300;
    wep_damage_min[WEP_SHOTGUN]   = 18;
    wep_damage_max[WEP_SHOTGUN]   = 24;
    wep_damage_head[WEP_SHOTGUN]  = 30;
    wep_firerate[WEP_SHOTGUN]     = 1.2;
    wep_reload_time[WEP_SHOTGUN]  = 0.5;
    wep_mag_size[WEP_SHOTGUN]     = 7;
    wep_reserve[WEP_SHOTGUN]      = 21;
    wep_range_falloff[WEP_SHOTGUN]= 300;
    wep_spread_stand[WEP_SHOTGUN] = 0.12;
    wep_spread_crouch[WEP_SHOTGUN]= 0.08;
    wep_spread_move[WEP_SHOTGUN]  = 0.18;
    wep_spread_aim[WEP_SHOTGUN]   = 0.7;
    wep_recoil_up[WEP_SHOTGUN]    = 5.0;
    wep_recoil_side[WEP_SHOTGUN]  = 1.5;
    wep_penetration[WEP_SHOTGUN]  = 20;
    wep_is_auto[WEP_SHOTGUN]      = 0;
    wep_zoom_fov[WEP_SHOTGUN]     = 80;
    wep_snd_fire[WEP_SHOTGUN]     = "weapons/shotgun_fire.ogg";
    wep_snd_reload[WEP_SHOTGUN]   = "weapons/shotgun_reload.ogg";
    wep_model_world[WEP_SHOTGUN]  = "models/weapons/shotgun.obj";
    wep_model_view[WEP_SHOTGUN]   = "models/weapons/shotgun.obj";

    // ── WEP_RIFLE ──────────────────────────────────────────────────
    wep_name[WEP_RIFLE]           = "Rifle";
    wep_price[WEP_RIFLE]          = 2700;
    wep_damage_min[WEP_RIFLE]     = 33;
    wep_damage_max[WEP_RIFLE]     = 36;
    wep_damage_head[WEP_RIFLE]    = 111;
    wep_firerate[WEP_RIFLE]       = 6.5;
    wep_reload_time[WEP_RIFLE]    = 2.5;
    wep_mag_size[WEP_RIFLE]       = 30;
    wep_reserve[WEP_RIFLE]        = 90;
    wep_range_falloff[WEP_RIFLE]  = 1200;
    wep_spread_stand[WEP_RIFLE]   = 0.05;
    wep_spread_crouch[WEP_RIFLE]  = 0.025;
    wep_spread_move[WEP_RIFLE]    = 0.12;
    wep_spread_aim[WEP_RIFLE]     = 0.45;
    wep_recoil_up[WEP_RIFLE]      = 3.5;
    wep_recoil_side[WEP_RIFLE]    = 2.0;
    wep_penetration[WEP_RIFLE]    = 100;
    wep_is_auto[WEP_RIFLE]        = 1;
    wep_zoom_fov[WEP_RIFLE]       = 68;
    wep_snd_fire[WEP_RIFLE]       = "weapons/rifle_fire.ogg";
    wep_snd_reload[WEP_RIFLE]     = "weapons/rifle_reload.ogg";
    wep_model_world[WEP_RIFLE]    = "models/weapons/rifle.obj";
    wep_model_view[WEP_RIFLE]     = "models/weapons/rifle.obj";

    // ── WEP_SNIPER ─────────────────────────────────────────────────
    wep_name[WEP_SNIPER]          = "Sniper";
    wep_price[WEP_SNIPER]         = 4500;
    wep_damage_min[WEP_SNIPER]    = 80;
    wep_damage_max[WEP_SNIPER]    = 100;
    wep_damage_head[WEP_SNIPER]   = 400;
    wep_firerate[WEP_SNIPER]      = 0.9;
    wep_reload_time[WEP_SNIPER]   = 3.5;
    wep_mag_size[WEP_SNIPER]      = 5;
    wep_reserve[WEP_SNIPER]       = 20;
    wep_range_falloff[WEP_SNIPER] = 9999;
    wep_spread_stand[WEP_SNIPER]  = 0.02;
    wep_spread_crouch[WEP_SNIPER] = 0.005;
    wep_spread_move[WEP_SNIPER]   = 0.25;
    wep_spread_aim[WEP_SNIPER]    = 0.1;
    wep_recoil_up[WEP_SNIPER]     = 8.0;
    wep_recoil_side[WEP_SNIPER]   = 0.5;
    wep_penetration[WEP_SNIPER]   = 200;
    wep_is_auto[WEP_SNIPER]       = 0;
    wep_zoom_fov[WEP_SNIPER]      = 20;
    wep_snd_fire[WEP_SNIPER]      = "weapons/sniper_fire.ogg";
    wep_snd_reload[WEP_SNIPER]    = "weapons/sniper_reload.ogg";
    wep_model_world[WEP_SNIPER]   = "models/weapons/sniper.obj";
    wep_model_view[WEP_SNIPER]    = "models/weapons/sniper.obj";

    // ── WEP_MACHINEGUN ─────────────────────────────────────────────
    wep_name[WEP_MACHINEGUN]          = "Machine Gun";
    wep_price[WEP_MACHINEGUN]         = 5200;
    wep_damage_min[WEP_MACHINEGUN]    = 25;
    wep_damage_max[WEP_MACHINEGUN]    = 30;
    wep_damage_head[WEP_MACHINEGUN]   = 75;
    wep_firerate[WEP_MACHINEGUN]      = 12.0;
    wep_reload_time[WEP_MACHINEGUN]   = 4.5;
    wep_mag_size[WEP_MACHINEGUN]      = 100;
    wep_reserve[WEP_MACHINEGUN]       = 200;
    wep_range_falloff[WEP_MACHINEGUN] = 900;
    wep_spread_stand[WEP_MACHINEGUN]  = 0.06;
    wep_spread_crouch[WEP_MACHINEGUN] = 0.03;
    wep_spread_move[WEP_MACHINEGUN]   = 0.14;
    wep_spread_aim[WEP_MACHINEGUN]    = 0.5;
    wep_recoil_up[WEP_MACHINEGUN]     = 2.5;
    wep_recoil_side[WEP_MACHINEGUN]   = 1.8;
    wep_penetration[WEP_MACHINEGUN]   = 80;
    wep_is_auto[WEP_MACHINEGUN]       = 1;
    wep_zoom_fov[WEP_MACHINEGUN]      = 65;
    wep_snd_fire[WEP_MACHINEGUN]      = "weapons/mg_fire.ogg";
    wep_snd_reload[WEP_MACHINEGUN]    = "weapons/mg_reload.ogg";
    wep_model_world[WEP_MACHINEGUN]   = "models/weapons/machinegun.obj";
    wep_model_view[WEP_MACHINEGUN]    = "models/weapons/machinegun.obj";

    // ── WEP_GRENADE ────────────────────────────────────────────────
    wep_name[WEP_GRENADE]         = "Grenade";
    wep_price[WEP_GRENADE]        = 300;
    wep_damage_min[WEP_GRENADE]   = 60;
    wep_damage_max[WEP_GRENADE]   = 120;
    wep_damage_head[WEP_GRENADE]  = 120;
    wep_firerate[WEP_GRENADE]     = 1.0;
    wep_reload_time[WEP_GRENADE]  = 0;
    wep_mag_size[WEP_GRENADE]     = 1;
    wep_reserve[WEP_GRENADE]      = 2;
    wep_range_falloff[WEP_GRENADE]= 350;
    wep_spread_stand[WEP_GRENADE] = 0;
    wep_penetration[WEP_GRENADE]  = 0;
    wep_is_auto[WEP_GRENADE]      = 0;
    wep_snd_fire[WEP_GRENADE]     = "weapons/grenade_throw.ogg";
    wep_snd_reload[WEP_GRENADE]   = "";
    wep_model_world[WEP_GRENADE]  = "models/weapons/grenade.obj";
    wep_model_view[WEP_GRENADE]   = "models/weapons/grenade.obj";

    // ── WEP_FLASHBANG ──────────────────────────────────────────────
    wep_name[WEP_FLASHBANG]         = "Flashbang";
    wep_price[WEP_FLASHBANG]        = 200;
    wep_damage_min[WEP_FLASHBANG]   = 5;
    wep_damage_max[WEP_FLASHBANG]   = 10;
    wep_damage_head[WEP_FLASHBANG]  = 10;
    wep_firerate[WEP_FLASHBANG]     = 1.0;
    wep_reload_time[WEP_FLASHBANG]  = 0;
    wep_mag_size[WEP_FLASHBANG]     = 1;
    wep_reserve[WEP_FLASHBANG]      = 2;
    wep_range_falloff[WEP_FLASHBANG]= 500;
    wep_spread_stand[WEP_FLASHBANG] = 0;
    wep_is_auto[WEP_FLASHBANG]      = 0;
    wep_snd_fire[WEP_FLASHBANG]     = "weapons/flashbang_throw.ogg";
    wep_snd_reload[WEP_FLASHBANG]   = "";
    wep_model_world[WEP_FLASHBANG]  = "models/weapons/flashbang.obj";
    wep_model_view[WEP_FLASHBANG]   = "models/weapons/flashbang.obj";
}

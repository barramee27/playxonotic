// Antigravity - weapon_defs.qc
// All weapon stat definitions

#include "weapons.qh"

WeaponDef AG_Weapons[10];

void AG_InitWeapons()
{
    WeaponDef w;

    // ── WEP_KNIFE ──────────────────────────────
    w = AG_Weapons[WEP_KNIFE];
    w.name            = "Knife";
    w.price           = 0;
    w.damage_min      = 45;
    w.damage_max      = 65;
    w.damage_headshot = 500;  // one-shot from behind
    w.fire_rate       = 1.2;
    w.reload_time     = 0;
    w.mag_size        = 1;
    w.reserve_size    = 0;
    w.spread_stand    = 0;
    w.spread_crouch   = 0;
    w.spread_move     = 0;
    w.spread_aim      = 0;
    w.recoil_up       = 0;
    w.recoil_side     = 0;
    w.penetration     = 0;
    w.is_auto         = 0;
    w.sound_fire      = "weapons/knife_slash.ogg";
    w.model_world     = "models/weapons/w_knife.iqm";
    w.model_view      = "models/weapons/v_knife.iqm";

    // ── WEP_PISTOL (Glock-style) ───────────────
    w = AG_Weapons[WEP_PISTOL];
    w.name            = "Pistol";
    w.price           = 200;
    w.damage_min      = 25;
    w.damage_max      = 35;
    w.damage_headshot = 80;
    w.fire_rate       = 4.0;
    w.reload_time     = 2.0;
    w.mag_size        = 15;
    w.reserve_size    = 45;
    w.range_falloff   = 800;
    w.spread_stand    = 0.03;
    w.spread_crouch   = 0.015;
    w.spread_move     = 0.06;
    w.spread_aim      = 0.4;
    w.recoil_up       = 1.5;
    w.recoil_side     = 0.8;
    w.penetration     = 50;
    w.is_auto         = 0;
    w.zoom_fov        = 75;
    w.sound_fire      = "weapons/pistol_fire.ogg";
    w.sound_reload    = "weapons/pistol_reload.ogg";
    w.model_world     = "models/weapons/pistol.obj";
    w.model_view      = "models/weapons/pistol.obj";

    // ── WEP_SMG (MP5-style) ────────────────────
    w = AG_Weapons[WEP_SMG];
    w.name            = "SMG";
    w.price           = 1200;
    w.damage_min      = 26;
    w.damage_max      = 32;
    w.damage_headshot = 75;
    w.fire_rate       = 10.0;
    w.reload_time     = 2.4;
    w.mag_size        = 30;
    w.reserve_size    = 90;
    w.range_falloff   = 600;
    w.spread_stand    = 0.04;
    w.spread_crouch   = 0.02;
    w.spread_move     = 0.09;
    w.spread_aim      = 0.5;
    w.recoil_up       = 1.8;
    w.recoil_side     = 1.2;
    w.penetration     = 30;
    w.is_auto         = 1;
    w.zoom_fov        = 72;
    w.sound_fire      = "weapons/smg_fire.ogg";
    w.sound_reload    = "weapons/smg_reload.ogg";
    w.model_world     = "models/weapons/smg.obj";
    w.model_view      = "models/weapons/smg.obj";

    // ── WEP_SHOTGUN ────────────────────────────
    w = AG_Weapons[WEP_SHOTGUN];
    w.name            = "Shotgun";
    w.price           = 1300;
    w.damage_min      = 18;   // per pellet, 8 pellets
    w.damage_max      = 24;
    w.damage_headshot = 30;
    w.fire_rate       = 1.2;
    w.reload_time     = 0.5;  // pump-per-shell
    w.mag_size        = 7;
    w.reserve_size    = 21;
    w.range_falloff   = 300;
    w.spread_stand    = 0.12;
    w.spread_crouch   = 0.08;
    w.spread_move     = 0.18;
    w.spread_aim      = 0.7;
    w.recoil_up       = 5.0;
    w.recoil_side     = 1.5;
    w.penetration     = 20;
    w.is_auto         = 0;
    w.zoom_fov        = 80;
    w.sound_fire      = "weapons/shotgun_fire.ogg";
    w.sound_reload    = "weapons/shotgun_reload.ogg";
    w.model_world     = "models/weapons/shotgun.obj";
    w.model_view      = "models/weapons/shotgun.obj";

    // ── WEP_RIFLE (AK-style) ───────────────────
    w = AG_Weapons[WEP_RIFLE];
    w.name            = "Rifle";
    w.price           = 2700;
    w.damage_min      = 33;
    w.damage_max      = 36;
    w.damage_headshot = 111;
    w.fire_rate       = 6.5;
    w.reload_time     = 2.5;
    w.mag_size        = 30;
    w.reserve_size    = 90;
    w.range_falloff   = 1200;
    w.spread_stand    = 0.05;
    w.spread_crouch   = 0.025;
    w.spread_move     = 0.12;
    w.spread_aim      = 0.45;
    w.recoil_up       = 3.5;
    w.recoil_side     = 2.0;
    w.penetration     = 100;
    w.is_auto         = 1;
    w.zoom_fov        = 68;
    w.sound_fire      = "weapons/rifle_fire.ogg";
    w.sound_reload    = "weapons/rifle_reload.ogg";
    w.model_world     = "models/weapons/rifle.obj";
    w.model_view      = "models/weapons/rifle.obj";

    // ── WEP_SNIPER ─────────────────────────────
    w = AG_Weapons[WEP_SNIPER];
    w.name            = "Sniper";
    w.price           = 4500;
    w.damage_min      = 80;
    w.damage_max      = 100;
    w.damage_headshot = 400;  // always headshot kill
    w.fire_rate       = 0.9;
    w.reload_time     = 3.5;
    w.mag_size        = 5;
    w.reserve_size    = 20;
    w.range_falloff   = 9999; // no falloff
    w.spread_stand    = 0.02;
    w.spread_crouch   = 0.005;
    w.spread_move     = 0.25;  // huge penalty while moving
    w.spread_aim      = 0.1;
    w.recoil_up       = 8.0;
    w.recoil_side     = 0.5;
    w.penetration     = 200;
    w.is_auto         = 0;
    w.zoom_fov        = 20;  // strong zoom
    w.sound_fire      = "weapons/sniper_fire.ogg";
    w.sound_reload    = "weapons/sniper_reload.ogg";
    w.model_world     = "models/weapons/sniper.obj";
    w.model_view      = "models/weapons/sniper.obj";

    // ── WEP_MACHINEGUN (LMG) ───────────────────
    w = AG_Weapons[WEP_MACHINEGUN];
    w.name            = "Machine Gun";
    w.price           = 5200;
    w.damage_min      = 25;
    w.damage_max      = 30;
    w.damage_headshot = 75;
    w.fire_rate       = 12.0;
    w.reload_time     = 4.5;
    w.mag_size        = 100;
    w.reserve_size    = 200;
    w.range_falloff   = 900;
    w.spread_stand    = 0.06;
    w.spread_crouch   = 0.03;
    w.spread_move     = 0.14;
    w.spread_aim      = 0.5;
    w.recoil_up       = 2.5;
    w.recoil_side     = 1.8;
    w.penetration     = 80;
    w.is_auto         = 1;
    w.zoom_fov        = 65;
    w.sound_fire      = "weapons/mg_fire.ogg";
    w.sound_reload    = "weapons/mg_reload.ogg";
    w.model_world     = "models/weapons/machinegun.obj";
    w.model_view      = "models/weapons/machinegun.obj";

    // ── WEP_GRENADE ────────────────────────────
    w = AG_Weapons[WEP_GRENADE];
    w.name            = "Grenade";
    w.price           = 300;
    w.damage_min      = 60;
    w.damage_max      = 120;
    w.damage_headshot = 120;
    w.fire_rate       = 1.0;
    w.reload_time     = 0;
    w.mag_size        = 1;
    w.reserve_size    = 2;
    w.range_falloff   = 350;  // blast radius
    w.spread_stand    = 0;
    w.penetration     = 0;
    w.is_auto         = 0;
    w.sound_fire      = "weapons/grenade_throw.ogg";
    w.model_world     = "models/weapons/w_grenade.iqm";
    w.model_view      = "models/weapons/v_grenade.iqm";

    // ── WEP_FLASHBANG ──────────────────────────
    w = AG_Weapons[WEP_FLASHBANG];
    w.name            = "Flashbang";
    w.price           = 200;
    w.damage_min      = 5;
    w.damage_max      = 10;
    w.damage_headshot = 10;
    w.fire_rate       = 1.0;
    w.reload_time     = 0;
    w.mag_size        = 1;
    w.reserve_size    = 2;
    w.range_falloff   = 500;  // flash radius
    w.spread_stand    = 0;
    w.is_auto         = 0;
    w.sound_fire      = "weapons/flashbang_throw.ogg";
    w.model_world     = "models/weapons/w_flashbang.iqm";
    w.model_view      = "models/weapons/v_flashbang.iqm";
}

// Antigravity - weapons_fire.qc
// Weapon firing, recoil, reload, hit detection

#include "../common/constants.qh"
#include "../common/weapons/weapons.qh"
#include "../common/weapons/weapon_defs.qc"

// ─────────────────────────────────────────────
// Spread calculation
// ─────────────────────────────────────────────
float AG_GetSpread(entity player)
{
    WeaponDef w     = AG_Weapons[player.current_weapon];
    float spread    = w.spread_stand;
    float vel       = vlen(player.velocity);

    // Add movement spread
    if (vel > 10)
        spread += w.spread_move * (vel / PLAYER_SPEED_RUN);

    // Crouch reduction
    if (player.crouch_state)
        spread = min(spread, w.spread_crouch);

    // ADS reduction
    if (player.weapon_is_aiming)
        spread *= w.spread_aim;

    // Clamp
    return max(spread, 0);
}

// ─────────────────────────────────────────────
// Hitscan bullet trace with penetration
// ─────────────────────────────────────────────
void AG_TraceBullet(entity shooter, vector src, vector dir, float pen_remaining, float dmg, float dmgtype)
{
    if (pen_remaining < 0) return;

    traceline(src, src + dir * 8192, MOVE_NORMAL, shooter);

    if (trace_ent && trace_ent.classname == "player" && trace_ent.is_alive)
    {
        // Determine hit zone from hit position relative to player origin
        float zdiff = trace_endpos.z - trace_ent.origin.z;
        float head_z = trace_ent.maxs.z - 8;

        float mult = HIT_BODY;
        if (zdiff >= head_z) mult = HIT_HEAD;
        else if (zdiff < trace_ent.mins.z + 12) mult = HIT_LIMB;

        AG_PlayerDamage(trace_ent, shooter, dmg * mult, dmgtype, trace_endpos);
    }

    // Wall penetration: continue bullet through thin surfaces
    if (pen_remaining > 0 && trace_fraction < 1.0)
    {
        // Check surface thickness
        vector behind = trace_endpos + dir * 2;
        traceline(behind, behind + dir * pen_remaining, MOVE_NORMAL, shooter);

        if (trace_fraction > 0)
        {
            // Bullet exits the wall, continues with reduced damage
            float exit_dmg = dmg * (1.0 - trace_fraction * 0.5);
            AG_TraceBullet(shooter, trace_endpos + dir * trace_fraction, dir,
                           pen_remaining - trace_fraction * pen_remaining, exit_dmg, dmgtype);
        }
    }
}

// ─────────────────────────────────────────────
// Fire weapon
// ─────────────────────────────────────────────
void AG_WeaponFire(entity player)
{
    if (!player.is_alive) return;
    if (player.weapon_is_reloading) return;
    if (time < player.weapon_fire_timer) return;
    if (player.ammo_primary <= 0)
    {
        // Auto reload when empty
        AG_WeaponReload(player);
        return;
    }

    WeaponDef w = AG_Weapons[player.current_weapon];

    // Set next fire time
    player.weapon_fire_timer = time + (1.0 / w.fire_rate);

    // Consume ammo
    player.ammo_primary -= 1;

    // Play fire sound
    sound(player, CHAN_WEAPON, w.sound_fire, 1, ATTN_NORM);

    // Calculate spread
    float spread = AG_GetSpread(player);

    // Fire direction from view angles
    makevectors(player.v_angle);
    vector src = player.origin + player.view_ofs;
    vector dir = v_forward;

    // Apply spread
    if (spread > 0)
    {
        dir = dir + v_right  * (crandom() * spread);
        dir = dir + v_up     * (crandom() * spread);
        dir = normalize(dir);
    }

    // Shotgun fires multiple pellets
    if (player.current_weapon == WEP_SHOTGUN)
    {
        float pellets = 8;
        float i;
        for (i = 0; i < pellets; i++)
        {
            vector pdir = v_forward
                        + v_right * (crandom() * w.spread_stand * 2)
                        + v_up    * (crandom() * w.spread_stand * 2);
            AG_TraceBullet(player, src, normalize(pdir),
                           w.penetration,
                           w.damage_min + random() * (w.damage_max - w.damage_min),
                           DMGTYPE_BULLET);
        }
    }
    else if (player.current_weapon == WEP_GRENADE || player.current_weapon == WEP_FLASHBANG)
    {
        AG_ThrowGrenade(player, player.current_weapon);
    }
    else
    {
        AG_TraceBullet(player, src, dir,
                       w.penetration,
                       w.damage_min + random() * (w.damage_max - w.damage_min),
                       DMGTYPE_BULLET);
    }

    // Apply recoil
    AG_ApplyRecoil(player, w.recoil_up, w.recoil_side);

    // Muzzle flash effect
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT);
    WriteCoord(MSG_BROADCAST, src.x);
    WriteCoord(MSG_BROADCAST, src.y);
    WriteCoord(MSG_BROADCAST, src.z);
}

// ─────────────────────────────────────────────
// Reload
// ─────────────────────────────────────────────
void AG_WeaponReload(entity player)
{
    if (player.weapon_is_reloading) return;

    WeaponDef w = AG_Weapons[player.current_weapon];
    if (w.reload_time <= 0) return;
    if (player.ammo_reserve <= 0) return;
    if (player.ammo_primary >= w.mag_size) return;

    player.weapon_is_reloading = true;
    player.weapon_reload_timer = time + w.reload_time;

    sound(player, CHAN_ITEM, w.sound_reload, 1, ATTN_NORM);
}

void AG_WeaponReloadFinish(entity player)
{
    if (!player.weapon_is_reloading) return;
    if (time < player.weapon_reload_timer) return;

    WeaponDef w     = AG_Weapons[player.current_weapon];
    float need      = w.mag_size - player.ammo_primary;
    float take      = min(need, player.ammo_reserve);

    player.ammo_primary      += take;
    player.ammo_reserve      -= take;
    player.weapon_is_reloading = false;
}

// ─────────────────────────────────────────────
// Recoil (modifies player view angles)
// ─────────────────────────────────────────────
void AG_ApplyRecoil(entity player, float up, float side)
{
    player.v_angle_x -= up;
    player.v_angle_y += crandom() * side;

    // Server-side recoil recovery (smooth)
    player.punchangle_x += up * 0.6;
    player.punchangle_y += crandom() * side * 0.3;
}

// ─────────────────────────────────────────────
// Grenade throw
// ─────────────────────────────────────────────
void AG_ThrowGrenade(entity player, float gren_type)
{
    entity g        = spawn();
    g.classname     = "grenade";
    g.owner         = player;
    g.team_id       = player.team_id;
    g.gren_type     = gren_type;
    g.movetype      = MOVETYPE_BOUNCE;
    g.solid         = SOLID_BBOX;

    makevectors(player.v_angle);
    setorigin(g, player.origin + player.view_ofs + v_forward * 16);
    g.velocity      = v_forward * 600 + '0 0 200';
    g.avelocity     = '300 300 0';
    g.gravity       = 1.0;

    setsize(g, '-4 -4 -4', '4 4 4');

    if (gren_type == WEP_GRENADE)
        g.nextthink = time + 3.0;
    else
        g.nextthink = time + 1.5;

    g.think = AG_GrenadeExplode;
}

void AG_GrenadeExplode()
{
    entity g = self;

    if (g.gren_type == WEP_FLASHBANG)
    {
        // Flash nearby players
        entity e;
        FOR_EACH_CLIENT(e)
        {
            if (!e.is_alive) continue;
            float dist = vlen(e.origin - g.origin);
            if (dist > 500) continue;

            // Check line of sight
            traceline(g.origin, e.origin, MOVE_NORMAL, g);
            if (trace_fraction < 0.95) continue;

            // Flash intensity by distance and facing
            float intensity = 1.0 - (dist / 500);
            // Send flash effect to client
            stuffcmd(e, strcat("ag_flash ", ftos(intensity), "\n"));
        }
    }
    else
    {
        // Explosion damage
        entity e;
        FOR_EACH_CLIENT(e)
        {
            if (!e.is_alive) continue;
            float dist = vlen(e.origin - g.origin);
            float radius = AG_Weapons[WEP_GRENADE].range_falloff;
            if (dist > radius) continue;

            float dmg = AG_Weapons[WEP_GRENADE].damage_max * (1.0 - dist / radius);
            AG_PlayerDamage(e, g.owner, dmg, DMGTYPE_EXPLOSIVE, g.origin);
        }

        // Explosion effect
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_EXPLOSION);
        WriteCoord(MSG_BROADCAST, g.origin.x);
        WriteCoord(MSG_BROADCAST, g.origin.y);
        WriteCoord(MSG_BROADCAST, g.origin.z);
    }

    remove(g);
}

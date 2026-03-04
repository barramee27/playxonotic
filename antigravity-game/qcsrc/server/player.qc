// Antigravity - player.qc
// Server-side player logic: spawn, death, respawn, damage

#include "../common/constants.qh"
#include "../common/physics.qh"

// ─────────────────────────────────────────────
// Player fields
// ─────────────────────────────────────────────
.float  health;
.float  armor;
.float  stamina;
.float  money;
.float  team_id;
.float  is_alive;
.float  respawn_timer;
.float  regen_timer;
.float  sprint_timer;
.float  footstep_timer;
.float  crouch_state;   // 0 = stand, 1 = crouch
.float  last_damage_time;
.float  kills;
.float  deaths;
.float  assists;
.entity last_attacker;

// ─────────────────────────────────────────────
// Spawn player
// ─────────────────────────────────────────────
void AG_PlayerSpawn(entity player)
{
    player.health          = PLAYER_HEALTH_MAX;
    player.armor           = 0;
    player.stamina         = SPRINT_MAX;
    player.is_alive        = true;
    player.respawn_timer   = 0;
    player.regen_timer     = 0;
    player.crouch_state    = 0;
    player.last_attacker   = world;
    player.movetype        = MOVETYPE_WALK;
    player.solid           = SOLID_SLIDEBOX;
    player.takedamage      = DAMAGE_AIM;
    player.deadflag        = DEAD_NO;

    setsize(player, PLAYER_HULL_MIN, PLAYER_HULL_MAX);

    // Give starting cash in bomb mode
    if (cvar("ag_gamemode") == GAMEMODE_BOMB)
        player.money = ECONOMY_START_MONEY;

    // Place at spawn point
    entity sp = AG_FindSpawnPoint(player.team_id);
    if (sp)
    {
        setorigin(player, sp.origin + '0 0 1');
        player.angles = sp.angles;
        player.fixangle = true;
    }
}

// ─────────────────────────────────────────────
// Damage handling
// ─────────────────────────────────────────────
void AG_PlayerDamage(entity player, entity attacker, float dmg, float dmgtype, vector hitpos)
{
    if (!player.is_alive) return;
    if (dmg <= 0) return;

    // Friendly fire check
    if (attacker != player && attacker.team_id == player.team_id)
    {
        if (!cvar("ag_friendly_fire")) return;
        dmg *= 0.5;  // friendly fire penalty
    }

    // Armor absorbs 60% of damage (up to armor amount)
    float armor_absorb = 0;
    if (player.armor > 0 && dmgtype != DMGTYPE_FALL)
    {
        armor_absorb  = dmg * 0.6;
        if (armor_absorb > player.armor) armor_absorb = player.armor;
        player.armor -= armor_absorb;
        dmg          -= armor_absorb;
    }

    player.health          -= dmg;
    player.last_damage_time = time;
    player.last_attacker   = attacker;

    // Blood/hit effects sent to clients
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_BLOOD);
    WriteCoord(MSG_BROADCAST, hitpos.x);
    WriteCoord(MSG_BROADCAST, hitpos.y);
    WriteCoord(MSG_BROADCAST, hitpos.z);

    if (player.health <= 0)
        AG_PlayerDie(player, attacker, dmgtype);
}

// ─────────────────────────────────────────────
// Death
// ─────────────────────────────────────────────
void AG_PlayerDie(entity player, entity killer, float dmgtype)
{
    player.is_alive   = false;
    player.health     = 0;
    player.deadflag   = DEAD_DYING;
    player.movetype   = MOVETYPE_TOSS;
    player.solid      = SOLID_NOT;
    player.takedamage = DAMAGE_NO;

    // Drop weapon
    AG_DropWeapon(player);

    // Ragdoll velocity
    player.velocity = player.velocity * 0.5 + '0 0 80';

    // Stats
    player.deaths += 1;

    if (killer && killer != player && killer != world)
    {
        killer.kills += 1;
        killer.money  = min(killer.money + ECONOMY_KILL_REWARD, 16000);

        // Assist check: last_attacker wasn't the killer but did damage
        entity last = player.last_attacker;
        if (last && last != killer && last != player)
            last.assists += 1;
    }

    // Broadcast kill
    AG_BroadcastKill(killer, player, dmgtype);

    // Schedule respawn
    float mode = cvar("ag_gamemode");
    if (mode == GAMEMODE_ELIMINATION || mode == GAMEMODE_BOMB)
    {
        // No respawn until next round
        player.respawn_timer = -1;
    }
    else
    {
        player.respawn_timer = time + PLAYER_RESPAWN_TIME;
    }
}

// ─────────────────────────────────────────────
// Health regen (run every frame for alive players)
// ─────────────────────────────────────────────
void AG_PlayerRegenTick(entity player)
{
    if (!player.is_alive) return;
    if (player.health >= PLAYER_HEALTH_MAX) return;
    if (time - player.last_damage_time < PLAYER_HEALTH_REGEN_DELAY) return;

    player.health = min(player.health + PLAYER_HEALTH_REGEN * frametime, PLAYER_HEALTH_MAX);
}

// ─────────────────────────────────────────────
// Sprint / stamina
// ─────────────────────────────────────────────
void AG_PlayerSprintTick(entity player)
{
    float sprinting = (player.button_sprint && player.is_alive);

    if (sprinting && player.stamina >= SPRINT_MIN_TO_START)
    {
        player.stamina  = max(player.stamina - SPRINT_DRAIN_RATE * frametime, 0);
        player.maxspeed = PLAYER_SPEED_SPRINT;
    }
    else
    {
        player.stamina  = min(player.stamina + SPRINT_REGEN_RATE * frametime, SPRINT_MAX);
        if (player.crouch_state)
            player.maxspeed = PLAYER_SPEED_CROUCH;
        else
            player.maxspeed = PLAYER_SPEED_RUN;
    }

    // Weapon sway on sprint (cvar sent to client)
    setcvar("ag_cl_sprinting", ftos(sprinting && player.stamina > 0));
}

// ─────────────────────────────────────────────
// Crouch
// ─────────────────────────────────────────────
void AG_PlayerCrouchTick(entity player)
{
    if (player.button_crouch)
    {
        if (!player.crouch_state)
        {
            player.crouch_state = 1;
            setsize(player, PLAYER_CROUCH_MIN, PLAYER_CROUCH_MAX);
            player.view_ofs = '0 0 16';
        }
    }
    else if (player.crouch_state)
    {
        // Only stand up if there's room
        tracebox(player.origin, PLAYER_HULL_MIN, PLAYER_HULL_MAX, player.origin, MOVE_NORMAL, player);
        if (!trace_startsolid)
        {
            player.crouch_state = 0;
            setsize(player, PLAYER_HULL_MIN, PLAYER_HULL_MAX);
            player.view_ofs = '0 0 28';
        }
    }
}

// ─────────────────────────────────────────────
// Respawn check (run every server frame)
// ─────────────────────────────────────────────
void AG_PlayerRespawnCheck(entity player)
{
    if (player.is_alive) return;
    if (player.respawn_timer < 0) return;  // waiting for round end
    if (time < player.respawn_timer) return;

    AG_PlayerSpawn(player);
}

// ─────────────────────────────────────────────
// Per-frame think for all players
// ─────────────────────────────────────────────
void AG_PlayerThink()
{
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player") continue;
        AG_PlayerRegenTick(e);
        AG_PlayerSprintTick(e);
        AG_PlayerCrouchTick(e);
        AG_PlayerRespawnCheck(e);
    }
}

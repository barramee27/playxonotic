// Antigravity - main.qc
// Server entry point: world spawn, frame think, client connect









// ─────────────────────────────────────────────
// Server cvars with defaults
// ─────────────────────────────────────────────
void AG_RegisterCvars()
{
    registercvar("ag_gamemode",       "0");   // 0=TDM 1=Bomb 2=Dom 3=Elim
    registercvar("ag_fraglimit",      "25");
    registercvar("ag_timelimit",      "15");  // minutes
    registercvar("ag_friendly_fire",  "0");
    registercvar("ag_nextmap",        "ag_dust");
    registercvar("ag_maxplayers",     "10");
    registercvar("ag_roundbased",     "0");
}

// ─────────────────────────────────────────────
// World spawn (called once when map loads)
// ─────────────────────────────────────────────
void worldspawn()
{
    AG_RegisterCvars();
    AG_InitWeapons();

    lightstyle(0, "m");  // normal lighting

    float mode = cvar("ag_gamemode");
    if      (mode == GAMEMODE_TDM)         AG_TDM_Init();
    else if (mode == GAMEMODE_BOMB)        AG_Bomb_Init();

    self.nextthink = time + 0.1;
    self.think     = AG_ServerThink;

    print(GAME_NAME, " v", GAME_VERSION, " - server started, mode=", ftos(mode), "\n");
}

// ─────────────────────────────────────────────
// Server frame think
// ─────────────────────────────────────────────
void AG_ServerThink()
{
    AG_PlayerThink();

    float mode = cvar("ag_gamemode");
    if (mode == GAMEMODE_TDM)
        AG_TDM_TimeCheck();
    else if (mode == GAMEMODE_BOMB)
        AG_Bomb_CheckElimination();

    self.nextthink = time + 0.05;  // 20 Hz server tick
}

// ─────────────────────────────────────────────
// Client connect
// ─────────────────────────────────────────────
void ClientConnect()
{
    self.classname     = "player";
    self.ag_team       = AG_AssignTeam();
    self.money         = ECONOMY_START_MONEY;
    self.kills         = 0;
    self.deaths        = 0;
    self.assists       = 0;
    self.loss_streak   = 0;
    self.last_round_won = 0;
    self.weapon_primary   = WEP_PISTOL;
    self.weapon_secondary = WEP_KNIFE;
    self.current_weapon   = WEP_PISTOL;
    self.ammo_primary     = wep_mag_size[WEP_PISTOL];
    self.ammo_reserve     = wep_reserve[WEP_PISTOL];

    AG_PlayerSpawn(self);

    bprint(self.netname, "^7 joined team ", AG_TeamName(self.ag_team), "\n");
}

// ─────────────────────────────────────────────
// Client disconnect
// ─────────────────────────────────────────────
void ClientDisconnect()
{
    bprint(self.netname, "^7 disconnected\n");
    // Check if bomb needs to drop
    if (self == bomb_carrier)
    {
        bomb_carrier = world;
        self.has_bomb = 0;
    }
}

// ─────────────────────────────────────────────
// Player input each frame
// ─────────────────────────────────────────────
void PlayerPreThink()
{
    entity player = self;
    if (!player.is_alive) return;

    // Fire
    if (player.button0)
        AG_WeaponFire(player);

    // Reload
    if (player.button_reload)
        AG_WeaponReload(player);

    AG_WeaponReloadFinish(player);

    // ADS
    player.weapon_is_aiming = player.button2;

    // Bomb plant/defuse
    if (player.button_use)
    {
        if (player.has_bomb)
            AG_Bomb_PlantStart(player, AG_NearestBombSite(player));
        else if (bomb_planted && vlen(player.origin - bomb_entity.origin) < 64)
            AG_Bomb_DefuseStart(player);
    }

    AG_Bomb_PlantTick(player);
    AG_Bomb_DefuseTick(player);
}

// ─────────────────────────────────────────────
// Utilities
// ─────────────────────────────────────────────
float AG_AssignTeam()
{
    // Count both teams, put new player on smaller team
    float alpha = 0, bravo = 0;
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.ag_team == TEAM_ALPHA) alpha++;
        else if (e.ag_team == TEAM_BRAVO) bravo++;
    }
    return (alpha <= bravo) ? TEAM_ALPHA : TEAM_BRAVO;
}

string AG_TeamName(float t)
{
    if (t == TEAM_ALPHA) return "^4Alpha";
    if (t == TEAM_BRAVO) return "^1Bravo";
    return "^7None";
}

entity AG_FindSpawnPoint(float team)
{
    entity best = world;
    float  best_dist = 0;
    entity sp;

    for (sp = world; (sp = find(sp, classname, "info_player_start")); )
    {
        if (sp.ag_team != team) continue;

        // Pick farthest from enemies
        float min_enemy_dist = 9999;
        entity e;
        FOR_EACH_CLIENT(e)
        {
            if (e.ag_team == team || !e.is_alive) continue;
            float d = vlen(sp.origin - e.origin);
            if (d < min_enemy_dist) min_enemy_dist = d;
        }

        if (min_enemy_dist > best_dist)
        {
            best_dist = min_enemy_dist;
            best = sp;
        }
    }
    return best;
}

entity AG_RandomPlayerOnTeam(float team)
{
    entity e, pick = world;
    float count = 0;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player" || e.ag_team != team) continue;
        count++;
        if (random() < 1.0 / count) pick = e;
    }
    return pick;
}

float AG_NearestBombSite(entity player)
{
    entity site;
    float best_dist = 9999, best_id = 1;
    for (site = world; (site = find(site, classname, "ag_bombsite")); )
    {
        float d = vlen(player.origin - site.origin);
        if (d < best_dist)
        {
            best_dist = site.origin.x;  // site.site_id
            best_id   = site.site_id;
        }
    }
    return best_id;
}


void AG_ShowScoreboard()
{
    stuffcmd_all("ag_scoreboard 1\n");
}

void AG_ScheduleRoundStart(float delay)
{
    entity timer = spawn();
    timer.classname = "round_timer";
    timer.nextthink = time + delay;
    timer.think     = AG_Bomb_StartRound;
}

void AG_DropWeapon(entity player)
{
    if (player.current_weapon == WEP_NONE || player.current_weapon == WEP_KNIFE) return;
    entity drop        = spawn();
    drop.classname     = "dropped_weapon";
    drop.weapon_type   = player.current_weapon;
    drop.ammo_primary  = player.ammo_primary;
    drop.ammo_reserve  = player.ammo_reserve;
    drop.movetype      = MOVETYPE_TOSS;
    drop.solid         = SOLID_BBOX;
    setorigin(drop, player.origin + '0 0 16');
    drop.velocity      = player.velocity * 0.5 + '0 0 100';
    setsize(drop, '-8 -8 -4', '8 8 4');
    drop.touch         = AG_PickupWeapon;
    drop.nextthink     = time + 30;  // despawn after 30s
    drop.think         = SUB_Remove;
}

void AG_PickupWeapon()
{
    entity player = other;
    if (player.classname != "player" || !player.is_alive) return;
    player.weapon_primary = self.weapon_type;
    player.ammo_primary   = self.ammo_primary;
    player.ammo_reserve   = self.ammo_reserve;
    sound(player, CHAN_ITEM, "items/weapon_pickup.ogg", 1, ATTN_NORM);
    remove(self);
}

void AG_BroadcastKill(entity killer, entity victim, float dmgtype)
{
    if (killer && killer != world)
        bprint(strcat(killer.netname, " ^7killed ", victim.netname, "\n"));
    else
        bprint(strcat(victim.netname, " ^7died\n"));
}

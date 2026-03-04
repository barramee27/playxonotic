// Antigravity - bomb.qc
// Bomb Defuse game mode (CS-style)



// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────
.float  round_number;
.float  rounds_alpha;    // Alpha (attackers) round wins
.float  rounds_bravo;    // Bravo (defenders) round wins
.float  round_phase;     // 0=warmup 1=live 2=planted 3=ended
.float  round_start_time;
.float  bomb_plant_time;
.float  bomb_planted;
.entity bomb_carrier;
.entity bomb_entity;
.vector bomb_site;
.float  bomb_site_id;    // which site (A=1 B=2)

// Planting entity fields
.float  planting;
.float  plant_progress;
.float  defusing;
.float  defuse_progress;

// ─────────────────────────────────────────────
// Init
// ─────────────────────────────────────────────
void AG_Bomb_Init()
{
    round_number   = 1;
    rounds_alpha   = 0;
    rounds_bravo   = 0;
    bomb_planted   = 0;
    bomb_carrier   = world;
    bomb_entity    = world;

    AG_Bomb_StartWarmup();
}

void AG_Bomb_StartWarmup()
{
    round_phase = 0;
    bprint(strcat("^3Warmup phase. Get ready!", "\n"));

    // Give everyone pistols + knife during warmup
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player") continue;
        e.weapon_primary   = WEP_PISTOL;
        e.weapon_secondary = WEP_KNIFE;
        e.ammo_primary     = 15;
        e.ammo_reserve     = 45;
        AG_PlayerSpawn(e);
    }

    AG_ScheduleRoundStart(ROUND_WARMUP_TIME);
}

// ─────────────────────────────────────────────
// Round start
// ─────────────────────────────────────────────
void AG_Bomb_StartRound()
{
    round_phase      = 1;
    bomb_planted     = 0;
    bomb_carrier     = world;
    round_start_time = time;

    bprint(strcat("^2Round ^3", ftos(round_number), "^2 started!", "\n"));

    // Spawn all players
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player") continue;
        e.respawn_timer = 0;  // allow spawn
        AG_PlayerSpawn(e);
    }

    // Give bomb to a random alpha player
    entity carrier = AG_RandomPlayerOnTeam(TEAM_ALPHA);
    if (carrier)
    {
        bomb_carrier = carrier;
        carrier.has_bomb = 1;
        centerprint(carrier, "^1You have the BOMB! Plant at site A or B.");
    }

    // Give economy money
    AG_Bomb_DistributeMoney();
}

// ─────────────────────────────────────────────
// Buy menu economy
// ─────────────────────────────────────────────
void AG_Bomb_DistributeMoney()
{
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player") continue;

        // Loss bonus increases on consecutive losses (max 5 round streak)
        float loss_bonus = ECONOMY_LOSS_REWARD + (e.loss_streak * 500);
        loss_bonus = min(loss_bonus, ECONOMY_LOSS_REWARD + 2500);

        if (e.last_round_won)
            e.money = min(e.money + ECONOMY_WIN_REWARD, 16000);
        else
            e.money = min(e.money + loss_bonus, 16000);

        // Send money to client HUD
        stuffcmd(e, strcat("ag_cl_money ", ftos(e.money), "\n"));
    }
}

// ─────────────────────────────────────────────
// Bomb plant
// ─────────────────────────────────────────────
void AG_Bomb_PlantStart(entity player, float site)
{
    if (player != bomb_carrier) return;
    if (bomb_planted) return;
    if (round_phase != 1) return;

    player.planting     = 1;
    player.plant_progress = 0;
    bomb_site_id        = site;
    bomb_site           = player.origin;

    bprint(strcat("^1BOMB BEING PLANTED at site ^3",
        (site == 1) ? "A" : "B", "^1!", "\n"));
}

void AG_Bomb_PlantTick(entity player)
{
    if (!player.planting) return;

    // Cancel if player moves or stops pressing use
    if (!player.button_use || vlen(player.velocity) > 5)
    {
        player.planting = 0;
        player.plant_progress = 0;
        return;
    }

    player.plant_progress += frametime / BOMB_PLANT_TIME;

    if (player.plant_progress >= 1.0)
    {
        AG_Bomb_DoPlant(player);
        player.planting = 0;
    }
}

void AG_Bomb_DoPlant(entity player)
{
    bomb_planted       = 1;
    bomb_plant_time    = time;
    bomb_carrier       = world;
    player.has_bomb    = 0;

    // Spawn bomb entity on ground
    bomb_entity            = spawn();
    bomb_entity.classname  = "bomb";
    bomb_entity.solid      = SOLID_BBOX;
    setorigin(bomb_entity, player.origin);
    setsize(bomb_entity, '-8 -8 -4', '8 8 4');
    bomb_entity.nextthink  = time + BOMB_EXPLODE_TIME;
    bomb_entity.think      = AG_Bomb_Explode;

    // Sound + alert
    sound(bomb_entity, CHAN_AUTO, "bomb/plant.ogg", 1, ATTN_NORM);

    bprint(strcat("^1BOMB PLANTED at site ^3",
        (bomb_site_id == 1) ? "A" : "B", "^1! Defuse it!", "\n"));
    round_phase = 2;
}

// ─────────────────────────────────────────────
// Defuse
// ─────────────────────────────────────────────
void AG_Bomb_DefuseStart(entity player)
{
    if (player.ag_team != TEAM_BRAVO) return;
    if (!bomb_planted) return;
    if (vlen(player.origin - bomb_entity.origin) > 64) return;

    player.defusing      = 1;
    player.defuse_progress = 0;

    bprint(strcat("^2Defusing bomb...", "\n"));
}

void AG_Bomb_DefuseTick(entity player)
{
    if (!player.defusing) return;

    if (!player.button_use || vlen(player.velocity) > 5
        || vlen(player.origin - bomb_entity.origin) > 64)
    {
        player.defusing = 0;
        player.defuse_progress = 0;
        return;
    }

    // Defuse kit halves time (if player bought one)
    float def_time = player.has_defusekit ? BOMB_DEFUSE_TIME * 0.5 : BOMB_DEFUSE_TIME;
    player.defuse_progress += frametime / def_time;

    if (player.defuse_progress >= 1.0)
    {
        AG_Bomb_Defused(player);
        player.defusing = 0;
    }
}

void AG_Bomb_Defused(entity player)
{
    if (bomb_entity) remove(bomb_entity);
    bomb_entity  = world;
    bomb_planted = 0;

    sound(player, CHAN_AUTO, "bomb/defuse.ogg", 1, ATTN_NONE);
    bprint(strcat("^2Bomb DEFUSED! Bravo wins the round.", "\n"));
    AG_Bomb_EndRound(TEAM_BRAVO);
}

void AG_Bomb_Explode()
{
    if (!bomb_planted) return;

    // Explosion damage near bomb
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (!e.is_alive) continue;
        float dist = vlen(e.origin - bomb_entity.origin);
        if (dist < 400)
        {
            float dmg = 500 * (1.0 - dist / 400);
            AG_PlayerDamage(e, world, dmg, DMGTYPE_EXPLOSIVE, bomb_entity.origin);
        }
    }

    // Explosion effect
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, bomb_entity.origin.x);
    WriteCoord(MSG_BROADCAST, bomb_entity.origin.y);
    WriteCoord(MSG_BROADCAST, bomb_entity.origin.z);

    remove(bomb_entity);
    bomb_entity  = world;
    bomb_planted = 0;

    bprint(strcat("^1BOMB EXPLODED! Alpha wins the round.", "\n"));
    AG_Bomb_EndRound(TEAM_ALPHA);
}

// ─────────────────────────────────────────────
// Check if all players on a team are dead
// ─────────────────────────────────────────────
void AG_Bomb_CheckElimination()
{
    float alpha_alive = 0, bravo_alive = 0;
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player" || !e.is_alive) continue;
        if (e.ag_team == TEAM_ALPHA) alpha_alive++;
        else if (e.ag_team == TEAM_BRAVO) bravo_alive++;
    }

    if (alpha_alive == 0 && !bomb_planted)
        AG_Bomb_EndRound(TEAM_BRAVO);
    else if (bravo_alive == 0)
        AG_Bomb_EndRound(TEAM_ALPHA);
}

// ─────────────────────────────────────────────
// End round
// ─────────────────────────────────────────────
void AG_Bomb_EndRound(float winner_team)
{
    round_phase = 3;

    // Update round wins + economy tracking
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player") continue;
        if (e.ag_team == winner_team)
        {
            e.last_round_won = 1;
            e.loss_streak    = 0;
        }
        else
        {
            e.last_round_won = 0;
            e.loss_streak    = min(e.loss_streak + 1, 5);
        }
    }

    if (winner_team == TEAM_ALPHA) rounds_alpha++;
    else if (winner_team == TEAM_BRAVO) rounds_bravo++;

    round_number++;

    // Check overall winner
    if (rounds_alpha >= ROUND_WIN_ROUNDS)
        AG_Bomb_EndMatch(TEAM_ALPHA);
    else if (rounds_bravo >= ROUND_WIN_ROUNDS)
        AG_Bomb_EndMatch(TEAM_BRAVO);
    else if (round_number > ROUND_MAX_ROUNDS)
    {
        if (rounds_alpha == rounds_bravo)
            AG_Bomb_EndMatch(TEAM_NONE);
        else
            AG_Bomb_EndMatch(rounds_alpha > rounds_bravo ? TEAM_ALPHA : TEAM_BRAVO);
    }
    else
    {
        // Swap sides at half
        if (round_number == (ROUND_MAX_ROUNDS / 2) + 1)
            AG_Bomb_SwapSides();

        // Brief intermission then next round
        AG_ScheduleRoundStart(5);
    }
}

void AG_Bomb_SwapSides()
{
    entity e;
    FOR_EACH_CLIENT(e)
    {
        if (e.classname != "player") continue;
        if (e.ag_team == TEAM_ALPHA) e.ag_team = TEAM_BRAVO;
        else if (e.ag_team == TEAM_BRAVO) e.ag_team = TEAM_ALPHA;
    }
    bprint(strcat("^3Teams have swapped sides.", "\n"));
}

void AG_Bomb_EndMatch(float winner_team)
{
    if (winner_team == TEAM_NONE)
        bprint(strcat("^3Match DRAW! ", ftos(rounds_alpha), " - ", ftos(rounds_bravo), "\n"));
    else if (winner_team == TEAM_ALPHA)
        bprint(strcat("^4ALPHA ^2wins the match! ", ftos(rounds_alpha), " - ", ftos(rounds_bravo), "\n"));
    else
        bprint(strcat("^1BRAVO ^2wins the match! ", ftos(rounds_bravo), " - ", ftos(rounds_alpha), "\n"));

    AG_ShowScoreboard();
    localcmd(strcat("changelevel ", cvar_string("ag_nextmap"), "\n"));
}

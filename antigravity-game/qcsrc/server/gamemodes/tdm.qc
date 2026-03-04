// Antigravity - tdm.qc
// Team Deathmatch game mode



.float team_score_alpha;
.float team_score_bravo;
.float tdm_frag_limit;
.float tdm_time_limit;

// ─────────────────────────────────────────────
// TDM init
// ─────────────────────────────────────────────
void AG_TDM_Init()
{
    tdm_frag_limit = max(cvar("ag_fraglimit"), 25);
    tdm_time_limit = max(cvar("ag_timelimit"), 10) * 60;

    team_score_alpha = 0;
    team_score_bravo = 0;

    bprint(strcat("^2Team Deathmatch started! First team to ^3", ftos(tdm_frag_limit), "^2 frags wins.", "\n"));
}

// ─────────────────────────────────────────────
// Called on every kill
// ─────────────────────────────────────────────
void AG_TDM_OnKill(entity killer, entity victim)
{
    if (!killer || killer == world) return;

    if (killer.ag_team == TEAM_ALPHA)
        team_score_alpha += 1;
    else if (killer.ag_team == TEAM_BRAVO)
        team_score_bravo += 1;

    // Check win condition
    if (team_score_alpha >= tdm_frag_limit)
        AG_TDM_EndGame(TEAM_ALPHA);
    else if (team_score_bravo >= tdm_frag_limit)
        AG_TDM_EndGame(TEAM_BRAVO);
}

// ─────────────────────────────────────────────
// Time limit check
// ─────────────────────────────────────────────
void AG_TDM_TimeCheck()
{
    if (time < tdm_time_limit) return;

    if (team_score_alpha == team_score_bravo)
        AG_TDM_EndGame(TEAM_NONE);  // draw
    else if (team_score_alpha > team_score_bravo)
        AG_TDM_EndGame(TEAM_ALPHA);
    else
        AG_TDM_EndGame(TEAM_BRAVO);
}

// ─────────────────────────────────────────────
// End game
// ─────────────────────────────────────────────
void AG_TDM_EndGame(float winner_team)
{
    if (winner_team == TEAM_NONE)
        bprint(strcat("^3The game ends in a ^1DRAW^3! Alpha: ",
            ftos(team_score_alpha), " | Bravo: ", ftos(team_score_bravo), "\n"));
    else if (winner_team == TEAM_ALPHA)
        bprint(strcat("^4ALPHA ^2wins! Score: ", ftos(team_score_alpha),
            " - ", ftos(team_score_bravo), "\n"));
    else
        bprint(strcat("^1BRAVO ^2wins! Score: ", ftos(team_score_bravo),
            " - ", ftos(team_score_alpha), "\n"));

    // Show scoreboard, schedule map change
    AG_ShowScoreboard();
    localcmd(strcat("changelevel ", cvar_string("ag_nextmap"), "\n"));
}

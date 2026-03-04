// Antigravity - client/main.qc
// Client entry point: init, frame, input

#include "../common/constants.qh"
#include "hud.qc"

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
    registercvar("ag_cl_money",     "0");
    registercvar("ag_cl_sprinting", "0");
    registercvar("ag_flash",        "0");
    registercvar("ag_scoreboard",   "0");
}

void CSQC_DrawHud()
{
    // Pull values from server-sent cvars
    cl_health       = getstatf(STAT_HEALTH);
    cl_armor        = getstatf(STAT_ARMOR);
    cl_ammo_mag     = getstatf(STAT_AMMO);
    cl_ammo_reserve = getstatf(STAT_SHELLS);
    cl_money        = cvar("ag_cl_money");
    cl_stamina      = cvar("ag_cl_stamina");
    cl_sprinting    = cvar("ag_cl_sprinting");
    cl_scoreboard   = cvar("ag_scoreboard");

    // Flash from flashbang
    float flash_val = cvar("ag_flash");
    if (flash_val > 0)
    {
        cl_flash_intensity = flash_val;
        cvar_set("ag_flash", "0");
    }

    AG_DrawHUD();
}

void CSQC_UpdateView(float vtime)
{
    // Weapon sway based on movement
    vector vel = pmove_vel;
    float speed = vlen(vel - vel.z * '0 0 1');
    cl_crosshair_spread = speed / PLAYER_SPEED_RUN;
}

float CSQC_InputEvent(float eventtype, float scanx, float chary)
{
    // Scoreboard toggle
    if (eventtype == IE_KEYDOWN && scanx == K_TAB)
    {
        cvar_set("ag_scoreboard", "1");
        return true;
    }
    if (eventtype == IE_KEYUP && scanx == K_TAB)
    {
        cvar_set("ag_scoreboard", "0");
        return true;
    }
    return false;
}

// Receive kill feed entries from server
void AG_Net_KillFeed()
{
    string killer = ReadString();
    string victim = ReadString();
    string weapon = ReadString();
    AG_AddKillFeedEntry(killer, victim, weapon);
}

// Antigravity - client/main.qc
// Client entry point

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
    AG_InitColors();
    kf_count = 0;

    registercvar("ag_cl_money",     "0");
    registercvar("ag_cl_sprinting", "0");
    registercvar("ag_flash",        "0");
    registercvar("ag_scoreboard",   "0");
    registercvar("ag_cl_stamina",   "100");
}

void CSQC_DrawHud()
{
    cl_health       = getstatf(STAT_HEALTH);
    cl_ag_armor     = getstatf(STAT_ARMOR);
    cl_ammo_mag     = getstatf(STAT_AMMO);
    cl_ammo_reserve = getstatf(STAT_SHELLS);
    cl_money        = cvar("ag_cl_money");
    cl_stamina      = cvar("ag_cl_stamina");
    cl_sprinting    = cvar("ag_cl_sprinting");
    cl_scoreboard   = cvar("ag_scoreboard");

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
    cl_crosshair_spread = max(0, cl_crosshair_spread - frametime * 3);
}

float CSQC_InputEvent(float eventtype, float scanx, float chary)
{
    if (eventtype == IE_KEYDOWN && scanx == K_TAB)
    {
        cvar_set("ag_scoreboard", "1");
        return 1;
    }
    if (eventtype == IE_KEYUP && scanx == K_TAB)
    {
        cvar_set("ag_scoreboard", "0");
        return 1;
    }
    return 0;
}

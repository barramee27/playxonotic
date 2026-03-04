// Antigravity - hud.qc
// Client-side HUD

float cl_health;
float cl_ag_armor;
float cl_ammo_mag;
float cl_ammo_reserve;
float cl_money;
float cl_stamina;
float cl_sprinting;
float cl_scoreboard;
float cl_flash_intensity;
float cl_crosshair_spread;
float cl_round_time_left;

// Kill feed
string kf_killers[5];
string kf_victims[5];
string kf_weapons[5];
float  kf_times[5];
float  kf_count;

// Colors
vector COL_RED;
vector COL_GREEN;
vector COL_BLUE;
vector COL_YELLOW;
vector COL_WHITE;
vector COL_GREY;

void AG_InitColors()
{
    COL_RED    = '1.0 0.2 0.2';
    COL_GREEN  = '0.2 1.0 0.3';
    COL_BLUE   = '0.2 0.5 1.0';
    COL_YELLOW = '1.0 1.0 0.2';
    COL_WHITE  = '1.0 1.0 1.0';
    COL_GREY   = '0.5 0.5 0.5';
}


void AG_DrawCrosshair()
{
    float sw = vid_width;
    float sh = vid_height;
    float cx = sw * 0.5;
    float cy = sh * 0.5;
    float gap = 4 + cl_crosshair_spread * 40;
    float len = 8;
    float w   = 1.5;

    vector p1, p2, p3, p4, p5;

    // Left
    p1_x = cx - gap - len; p1_y = cy - w * 0.5; p1_z = 0;
    drawfill(p1, '8 1.5 0', COL_WHITE, 0.9, DRAWFLAG_NORMAL);
    // Right
    p2_x = cx + gap; p2_y = cy - w * 0.5; p2_z = 0;
    drawfill(p2, '8 1.5 0', COL_WHITE, 0.9, DRAWFLAG_NORMAL);
    // Up
    p3_x = cx - w * 0.5; p3_y = cy - gap - len; p3_z = 0;
    drawfill(p3, '1.5 8 0', COL_WHITE, 0.9, DRAWFLAG_NORMAL);
    // Down
    p4_x = cx - w * 0.5; p4_y = cy + gap; p4_z = 0;
    drawfill(p4, '1.5 8 0', COL_WHITE, 0.9, DRAWFLAG_NORMAL);

    if (cl_crosshair_spread > 0)
        cl_crosshair_spread = max(0, cl_crosshair_spread - frametime * 3);
}

void AG_DrawSprintBar()
{
    float sw = vid_width;
    float sh = vid_height;
    float barw = 120;
    float bx = sw * 0.5 - barw * 0.5;
    float by = sh * 0.72;

    vector bp, bs, bfp, bfs;
    bp_x = bx; bp_y = by; bp_z = 0;
    bs_x = barw; bs_y = 6; bs_z = 0;
    drawfill(bp, bs, '0.1 0.1 0.1', 0.6, DRAWFLAG_NORMAL);

    bfp = bp;
    bfs_x = barw * (cl_stamina * 0.01); bfs_y = 6; bfs_z = 0;
    drawfill(bfp, bfs, COL_YELLOW, 0.8, DRAWFLAG_NORMAL);
}

void AG_DrawKillFeed()
{
    float sw = vid_width;
    float y  = 80;
    float i;
    vector tp;

    for (i = 0; i < kf_count; i++)
    {
        if (time - kf_times[i] > 6) continue;
        float alpha = 1.0 - (time - kf_times[i]) / 6.0;
        tp_x = sw - 280; tp_y = y; tp_z = 0;
        drawstring(tp,
            strcat(kf_killers[i], " > ", kf_victims[i]),
            '14 14 0', COL_WHITE, alpha, DRAWFLAG_NORMAL);
        y = y + 18;
    }
}

void AG_AddKillFeedEntry(string killer, string victim, string weapon)
{
    float i;
    for (i = 4; i > 0; i = i - 1)
    {
        kf_killers[i] = kf_killers[i-1];
        kf_victims[i] = kf_victims[i-1];
        kf_weapons[i] = kf_weapons[i-1];
        kf_times[i]   = kf_times[i-1];
    }
    kf_killers[0] = killer;
    kf_victims[0] = victim;
    kf_weapons[0] = weapon;
    kf_times[0]   = time;
    if (kf_count < 5) kf_count = kf_count + 1;
}

void AG_DrawHUD()
{
    float sw = vid_width;
    float sh = vid_height;

    // Flash overlay
    if (cl_flash_intensity > 0)
    {
        vector fp, fs;
        fp = '0 0 0';
        fs_x = sw; fs_y = sh; fs_z = 0;
        drawfill(fp, fs, COL_WHITE, cl_flash_intensity, DRAWFLAG_NORMAL);
        cl_flash_intensity = max(0, cl_flash_intensity - frametime * 1.5);
    }

    if (intermission) return;

    // Health (bottom-left)
    vector hp_pos;
    hp_pos_x = 20; hp_pos_y = sh - 60; hp_pos_z = 0;
    float hp_frac = cl_health * 0.01;
    vector hp_col = lerpv(COL_RED, COL_GREEN, hp_frac);
    drawstring(hp_pos, strcat("HP ", ftos(floor(cl_health))), '20 20 0', hp_col, 1.0, DRAWFLAG_NORMAL);

    // Armor
    if (cl_ag_armor > 0)
    {
        vector ap;
        ap_x = 20; ap_y = sh - 35; ap_z = 0;
        drawstring(ap, strcat("AR ", ftos(floor(cl_ag_armor))), '18 18 0', COL_BLUE, 0.9, DRAWFLAG_NORMAL);
    }

    // Ammo (bottom-right)
    vector ammo_pos;
    ammo_pos_x = sw - 120; ammo_pos_y = sh - 60; ammo_pos_z = 0;
    vector ammo_col;
    if (cl_ammo_mag <= 5) ammo_col = COL_RED;
    else                  ammo_col = COL_WHITE;
    drawstring(ammo_pos, ftos(cl_ammo_mag), '36 36 0', ammo_col, 1.0, DRAWFLAG_NORMAL);

    vector res_pos;
    res_pos_x = ammo_pos_x + 50; res_pos_y = ammo_pos_y + 12; res_pos_z = 0;
    drawstring(res_pos, strcat("/ ", ftos(cl_ammo_reserve)), '18 18 0', COL_GREY, 0.8, DRAWFLAG_NORMAL);

    // Round timer (top-center)
    if (cl_round_time_left > 0)
    {
        float mins = floor(cl_round_time_left * 0.01666);
        float secs = floor(cl_round_time_left - mins * 60);
        string timer_str;
        if (secs < 10)
            timer_str = strcat(ftos(mins), ":0", ftos(secs));
        else
            timer_str = strcat(ftos(mins), ":", ftos(secs));

        vector tp;
        tp_x = sw * 0.5 - 40; tp_y = 12; tp_z = 0;
        vector tc;
        if (cl_round_time_left < 30) tc = COL_RED;
        else                         tc = COL_WHITE;
        drawstring(tp, timer_str, '30 30 0', tc, 1.0, DRAWFLAG_NORMAL);
    }

    // Money
    if (cl_money > 0)
    {
        vector mp;
        mp_x = sw - 100; mp_y = 12; mp_z = 0;
        drawstring(mp, strcat("$", ftos(cl_money)), '20 20 0', COL_GREEN, 1.0, DRAWFLAG_NORMAL);
    }

    AG_DrawCrosshair();

    if (cl_sprinting)
        AG_DrawSprintBar();

    AG_DrawKillFeed();
}

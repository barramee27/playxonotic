// Antigravity - hud.qc
// Client-side HUD: health, armor, ammo, radar, round timer

#include "../common/constants.qh"

// ─────────────────────────────────────────────
// HUD cvars (received from server)
// ─────────────────────────────────────────────
float cl_health;
float cl_armor;
float cl_ammo_mag;
float cl_ammo_reserve;
float cl_money;
float cl_team;
float cl_kills;
float cl_deaths;
float cl_flash_intensity;  // flashbang
float cl_sprinting;
float cl_round_time_left;
float cl_scoreboard;

// ─────────────────────────────────────────────
// Colors
// ─────────────────────────────────────────────
#define COL_RED     '1.0 0.2 0.2'
#define COL_GREEN   '0.2 1.0 0.3'
#define COL_BLUE    '0.2 0.5 1.0'
#define COL_YELLOW  '1.0 1.0 0.2'
#define COL_WHITE   '1.0 1.0 1.0'
#define COL_ALPHA   '0.3 0.5 1.0'
#define COL_BRAVO   '1.0 0.3 0.3'
#define COL_GREY    '0.5 0.5 0.5'

// ─────────────────────────────────────────────
// Main HUD draw (called every frame)
// ─────────────────────────────────────────────
void AG_DrawHUD()
{
    float sw = vid_width;
    float sh = vid_height;

    // Flashbang overlay
    if (cl_flash_intensity > 0)
    {
        drawfill('0 0 0', [sw, sh, 0], COL_WHITE, cl_flash_intensity, DRAWFLAG_NORMAL);
        cl_flash_intensity = max(0, cl_flash_intensity - frametime * 1.5);
    }

    if (intermission) return;

    // ── Bottom-left: Health + Armor ────────────
    vector hp_pos    = [20, sh - 60, 0];
    vector armor_pos = [20, sh - 35, 0];

    float hp_frac = cl_health / PLAYER_HEALTH_MAX;
    vector hp_col = lerpv(COL_RED, COL_GREEN, hp_frac);

    drawpic(hp_pos, "hud/heart", [24, 24, 0], COL_WHITE, 0.8, DRAWFLAG_NORMAL);
    drawstring(hp_pos + [28, 2, 0], strcat(ftos(floor(cl_health))), [20, 20, 0],
               hp_col, 1.0, DRAWFLAG_NORMAL);

    if (cl_armor > 0)
    {
        float ar_frac = cl_armor / PLAYER_ARMOR_MAX;
        drawpic(armor_pos, "hud/shield", [20, 20, 0], COL_WHITE, 0.7, DRAWFLAG_NORMAL);
        drawstring(armor_pos + [24, 2, 0], strcat(ftos(floor(cl_armor))), [18, 18, 0],
                   lerpv(COL_GREY, COL_BLUE, ar_frac), 0.9, DRAWFLAG_NORMAL);
    }

    // ── Bottom-right: Ammo ──────────────────────
    vector ammo_pos = [sw - 120, sh - 60, 0];
    drawstring(ammo_pos, strcat(ftos(cl_ammo_mag)), [36, 36, 0],
               (cl_ammo_mag <= 5) ? COL_RED : COL_WHITE, 1.0, DRAWFLAG_NORMAL);
    drawstring(ammo_pos + [50, 12, 0], strcat(" / ", ftos(cl_ammo_reserve)),
               [18, 18, 0], COL_GREY, 0.8, DRAWFLAG_NORMAL);

    // ── Top-center: Round timer ─────────────────
    if (cl_round_time_left > 0)
    {
        float mins = floor(cl_round_time_left / 60);
        float secs = floor(cl_round_time_left - mins * 60);
        string timer_str = strcat(ftos(mins), ":", (secs < 10) ? "0" : "", ftos(secs));

        vector timer_pos = [(sw / 2) - 40, 12, 0];
        vector timer_col = (cl_round_time_left < 30) ? COL_RED : COL_WHITE;
        drawstring(timer_pos, timer_str, [30, 30, 0], timer_col, 1.0, DRAWFLAG_NORMAL);
    }

    // ── Top-right: Money (bomb mode only) ───────
    if (cvar("ag_gamemode") == GAMEMODE_BOMB && cl_money > 0)
    {
        drawstring([sw - 100, 12, 0], strcat("$", ftos(cl_money)),
                   [20, 20, 0], COL_GREEN, 1.0, DRAWFLAG_NORMAL);
    }

    // ── Center: Crosshair ───────────────────────
    AG_DrawCrosshair();

    // ── Sprint bar ──────────────────────────────
    if (cl_sprinting)
        AG_DrawSprintBar();

    // ── Scoreboard overlay ──────────────────────
    if (cl_scoreboard)
        AG_DrawScoreboard();

    // ── Hit indicator ───────────────────────────
    AG_DrawHitIndicator();

    // ── Kill feed ──────────────────────────────
    AG_DrawKillFeed();
}

// ─────────────────────────────────────────────
// Crosshair
// ─────────────────────────────────────────────
float cl_crosshair_spread;
float cl_crosshair_shrink_timer;

void AG_DrawCrosshair()
{
    float sw = vid_width, sh = vid_height;
    float cx = sw / 2, cy = sh / 2;
    float gap = 4 + cl_crosshair_spread * 40;
    float len = 8;
    float w   = 1.5;
    vector col = COL_WHITE;

    drawfill([cx - gap - len, cy - w/2, 0], [len, w, 0], col, 0.9, DRAWFLAG_NORMAL);
    drawfill([cx + gap, cy - w/2, 0],       [len, w, 0], col, 0.9, DRAWFLAG_NORMAL);
    drawfill([cx - w/2, cy - gap - len, 0], [w, len, 0], col, 0.9, DRAWFLAG_NORMAL);
    drawfill([cx - w/2, cy + gap, 0],       [w, len, 0], col, 0.9, DRAWFLAG_NORMAL);

    // Center dot
    drawfill([cx - 1, cy - 1, 0], [2, 2, 0], col, 0.7, DRAWFLAG_NORMAL);

    // Shrink over time
    if (cl_crosshair_spread > 0)
        cl_crosshair_spread = max(0, cl_crosshair_spread - frametime * 3);
}

// ─────────────────────────────────────────────
// Sprint stamina bar
// ─────────────────────────────────────────────
float cl_stamina;

void AG_DrawSprintBar()
{
    float sw = vid_width, sh = vid_height;
    float barw = 120, barh = 6;
    float bx = sw/2 - barw/2, by = sh * 0.72;

    drawfill([bx, by, 0], [barw, barh, 0], '0.1 0.1 0.1', 0.6, DRAWFLAG_NORMAL);
    drawfill([bx, by, 0], [barw * (cl_stamina / SPRINT_MAX), barh, 0],
             COL_YELLOW, 0.8, DRAWFLAG_NORMAL);
}

// ─────────────────────────────────────────────
// Hit indicator (flash red wedge from hit direction)
// ─────────────────────────────────────────────
float cl_hit_angle;
float cl_hit_timer;

void AG_DrawHitIndicator()
{
    if (cl_hit_timer <= 0) return;
    cl_hit_timer -= frametime;

    float sw = vid_width, sh = vid_height;
    float alpha = cl_hit_timer * 2;

    // Simple red flash in direction of damage
    // Full implementation would rotate a wedge image
    drawfill([0, 0, 0], [sw, sh, 0], COL_RED, alpha * 0.15, DRAWFLAG_NORMAL);
}

// ─────────────────────────────────────────────
// Kill feed (right side, last 5 kills)
// ─────────────────────────────────────────────
string kf_killers[5];
string kf_victims[5];
string kf_weapons[5];
float  kf_times[5];
float  kf_count;

void AG_AddKillFeedEntry(string killer, string victim, string weapon)
{
    float i;
    for (i = 4; i > 0; i--)
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
    kf_count      = min(kf_count + 1, 5);
}

void AG_DrawKillFeed()
{
    float sw = vid_width;
    float y = 80;
    float i;

    for (i = 0; i < kf_count; i++)
    {
        if (time - kf_times[i] > 6) continue;
        float alpha = 1.0 - (time - kf_times[i]) / 6.0;

        drawstring([sw - 280, y, 0],
            strcat(kf_killers[i], " ^7> ", kf_victims[i], " ^3[", kf_weapons[i], "]"),
            [14, 14, 0], COL_WHITE, alpha, DRAWFLAG_NORMAL);
        y += 18;
    }
}

// ─────────────────────────────────────────────
// Scoreboard
// ─────────────────────────────────────────────
void AG_DrawScoreboard()
{
    float sw = vid_width, sh = vid_height;
    float bx = sw/2 - 300, by = sh/2 - 200;
    float bw = 600, bh = 400;

    drawfill([bx, by, 0], [bw, bh, 0], '0 0 0', 0.7, DRAWFLAG_NORMAL);
    drawstring([bx + bw/2 - 60, by + 10, 0], GAME_NAME, [24, 24, 0],
               COL_WHITE, 1.0, DRAWFLAG_NORMAL);
}

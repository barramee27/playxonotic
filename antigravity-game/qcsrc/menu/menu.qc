// Antigravity - menu.qc
// Main menu and buy menu




// ─────────────────────────────────────────────
// Buy menu (Bomb mode / round start)
// ─────────────────────────────────────────────
float buy_menu_open;
float buy_selected_slot; // 0=primary 1=secondary 2=grenade

void AG_BuyMenu_Open()
{
    buy_menu_open = 1;
}

void AG_BuyMenu_Close()
{
    buy_menu_open = 0;
}

void AG_BuyMenu_Draw()
{
    if (!buy_menu_open) return;

    float sw = vid_width, sh = vid_height;
    float bx = 60, by = 100, bw = 300, bh = 500;

    drawfill('bx by 0', 'bw bh 0', '0 0 0', 0.8, DRAWFLAG_NORMAL);
    drawstring('bx + 10 by + 10 0', "^3BUY MENU", '20 20 0',
               '1 1 0.3', 1.0, DRAWFLAG_NORMAL);
    drawstring('bx + 10 by + 35 0', strcat("$", ftos(cl_money)), '16 16 0',
               '0.2 1.0 0.3', 1.0, DRAWFLAG_NORMAL);

    float y = by + 70;
    float i;
    string cats[3];
    cats[0] = "Primary"; cats[1] = "Secondary"; cats[2] = "Grenades";

    for (i = 0; i < 3; i++)
    {
        float cat_selected = (buy_selected_slot == i);
        vector hcol = cat_selected ? '0.2 0.4 1.0' : '0.1 0.1 0.1';
        drawfill('bx + 5 y 0', 'bw - 10 22 0', hcol, 0.7, DRAWFLAG_NORMAL);
        drawstring('bx + 15 y + 3 0', cats[i], '16 16 0',
                   cat_selected ? '1 1 1' : '0.7 0.7 0.7', 1.0, DRAWFLAG_NORMAL);
        y += 26;

        if (!cat_selected) continue;

        // Show weapons in this category
        float start = (i == 0) ? WEP_SMG  :
                      (i == 1) ? WEP_PISTOL : WEP_GRENADE;
        float end   = (i == 0) ? WEP_MACHINEGUN :
                      (i == 1) ? WEP_PISTOL      : WEP_FLASHBANG;

        float w_idx;
        for (w_idx = start; w_idx <= end; w_idx++)
        {
                        float can_afford = (cl_money >= wep_price[w_idx]);

            drawfill('bx + 15 y 0', 'bw - 20 20 0', '0.05 0.05 0.05', 0.6, DRAWFLAG_NORMAL);
            drawstring('bx + 20 y + 2 0', wep_name[w_idx], '14 14 0',
                       can_afford ? '1 1 1' : '0.4 0.4 0.4', 1.0, DRAWFLAG_NORMAL);
            drawstring('bx + bw - 60 y + 2 0', strcat("$", ftos(wep_price[w_idx])), '14 14 0',
                       can_afford ? '0.2 1.0 0.3' : '1.0 0.3 0.3', 1.0, DRAWFLAG_NORMAL);
            y += 22;
        }
    }
}

// ─────────────────────────────────────────────
// Buy keybind handler (call from InputEvent)
// ─────────────────────────────────────────────
float AG_BuyMenu_Input(float scanx)
{
    if (scanx == K_b || scanx == 'b')
    {
        if (buy_menu_open) AG_BuyMenu_Close();
        else               AG_BuyMenu_Open();
        return TRUE;
    }

    if (!buy_menu_open) return FALSE;

    if (scanx == K_ESCAPE) { AG_BuyMenu_Close(); return TRUE; }
    if (scanx == '1') { buy_selected_slot = 0; return TRUE; }
    if (scanx == '2') { buy_selected_slot = 1; return TRUE; }
    if (scanx == '3') { buy_selected_slot = 2; return TRUE; }

    return FALSE;
}

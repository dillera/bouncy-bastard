/**
 * Stub header for hirestxt library
 * This is a placeholder to allow compilation without the full CMOC hirestxt library
 */

#ifndef HIRESTXT_H
#define HIRESTXT_H

#define TRUE 1
#define FALSE 0

/* HiResTextScreenInit structure */
struct HiResTextScreenInit {
    byte chars_per_row;
    void (*write_char_func)(byte x, byte y, byte c);
    byte *text_screen_buffer;
    byte redirect_printf;
    word *timer_ptr;
    byte cursor_blink_rate;
    void *inkey_func;
    void *sound_func;
};

/* Stub functions */
void initHiResTextScreen(struct HiResTextScreenInit *init);
byte getCursorColumn(void);
byte getCursorRow(void);
void moveCursor(byte x, byte y);
void animateCursor(void);
void removeCursor(void);
void setInverseVideoMode(byte onoff);
byte inkey(void);

#endif /* HIRESTXT_H */

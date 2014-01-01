/*
 *  File:   ctype_game.c
 *  Desc:   a c type game.characters drop down,when you press the keys,they
 *          disapper.
 *  Author: Hang Yan
 *  Email:  yanhangyhy@gmail.com
 *  Date:   2012
 *  TODO:
 *          1.time-->a range--->levels.
 *          2.beep--->flash
 *          3.record the scores.-->levels are different,so no need
 *            to rank the socres.
 *          4.socket.
 */

#include <unistd.h>
#include <stdlib.h>
#include <curses.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <pthread.h>
#include <unistd.h>

#define STDIN_FILENO 0

//error code
#define NO_FD_WITH_TERM 1
#define GET_WINDOW_SIZE_ERROR 2
#define GAME_OVER 3
#define THREAD_CREATE_FAILED 4



int ROWS;
int COLUMNS;

/* for numbers and lower-case letter
   0-9 0-9 48-57
   10-35 a-z 97-122
 */
char CharTable[36];
//array store the screen's char COLUMNS*ROWS
char *ScreenTable;
char *Move;
int N;


int SCORE;
char LEVEL;
char TYPINGCHAR = 0;
int isOld = 1;

//funcions
void save_exit (int);
void game_over ();
void *animation (void *);




int
main (int argc, char *argv[])
{
    struct winsize Size;

    if (isatty (STDIN_FILENO) == 0)
        exit (NO_FD_WITH_TERM);
    if (ioctl (STDIN_FILENO, TIOCGWINSZ, &Size) < 0)
        exit (GET_WINDOW_SIZE_ERROR);
    //The size should be fixed.or it's hard to control
    ROWS = Size.ws_row;
    COLUMNS = Size.ws_col;
    N = sizeof (char) * (ROWS + 1) * (COLUMNS + 1);
    ScreenTable = (char *) malloc (N);
    memset (ScreenTable, 0, N);

    Move = (char *) malloc (N);
    memset (Move, 0, N);

    initscr ();

    //welcome information and select level
    move (ROWS / 2, COLUMNS / 2 - 12);
    printw ("%s", "Please Select a Level(1-6):");
    LEVEL = getch ();
    refresh ();
    sleep (1);
    if ((LEVEL < 49) || (LEVEL > 54))
        LEVEL = 49;
    clear ();
    refresh ();
    move (ROWS / 2, COLUMNS / 2 - 5);
    printw ("%s", "Ready?Go!");
    refresh ();
    sleep (1);

    clear ();
    refresh ();


    //create a thread to receive keyboard input
    int res;
    pthread_t keyb;
    res = pthread_create (&keyb, NULL, animation, NULL);
    if (res != 0) {
        perror ("Thread Creation failed");
        save_exit (THREAD_CREATE_FAILED);
    }
    cbreak ();
    noecho ();
    while (1) {
        TYPINGCHAR = getch ();
        while (TYPINGCHAR == '\n')
            break;
        isOld = 0;
    }

    save_exit (EXIT_SUCCESS);
}


void
save_exit (int exitCode)
{
    endwin ();
    free (ScreenTable);
    exit (exitCode);
}

//show the game over information and the score
void
game_over ()
{
    clear ();
    refresh ();
    move (ROWS / 2 - 1, COLUMNS / 2 - 1);
    printw ("%s", "GAME OVER!");
    move (ROWS / 2 + 1, COLUMNS / 2 - 1);
    printw ("SCORE:  %d", SCORE);
    refresh ();
    sleep (2);
}

void *
animation (void *arg)
{
    srand ((unsigned) time (NULL));

    int ch;
    int i;
    char charToPrint;
    int column;
    int M = (ROWS - 1) * (COLUMNS + 1);
    while (1) {
        ch = rand () % 36;	//0-35
        column = rand () % (COLUMNS + 1);
        move (0, column);
        if (ch >= 0 && ch <= 9) {
            charToPrint = (char) (ch + 48);
        }
        if (ch >= 10 && ch <= 35) {
            charToPrint = (char) (ch + 87);
        }
        addch (charToPrint);

        ScreenTable[column] = charToPrint;
        CharTable[ch]++;
        refresh ();
        usleep ((55 - LEVEL) * 500 * 1000);
        insertln ();
        refresh ();


        for (i = 0; i < N; ++i) {
            if (ScreenTable[i] != 0 && Move[i] == 0) {
                if (i >= M) {
                    game_over ();	//clean up the windows
                    save_exit (GAME_OVER);	//keep this call in 'main'
                }
                ScreenTable[i + COLUMNS + 1] = ScreenTable[i];
                ScreenTable[i] = 0;
                Move[i + COLUMNS + 1] = 1;
            }
            if ((ScreenTable[i] == TYPINGCHAR) && (isOld == 0)) {
                move (i / (COLUMNS + 1), i % (COLUMNS + 1));
                addch (' ');
                flash ();
                refresh ();
                if (TYPINGCHAR >= 48 && (TYPINGCHAR <= 57)) {
                    if (--CharTable[TYPINGCHAR - 48] == 0)
                        isOld = 1;
                }

                ScreenTable[i] = 0;
                SCORE++;
            }
        }
        memset (Move, 0, N);
    }

}

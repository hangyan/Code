/*TODO:
  -----1.time-->a range--->levels.
  -----2.beep--->flash
  -----3.record the scores.-->levels are different,so no need
  to rank the socres.
  4.socket:
  This is the 'server' node.
  (1)There is no level.increse itself
  (2)
 */

#include <unistd.h>
#include <stdlib.h>
#include <curses.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <time.h>
#include <string.h> //for 'memset'
#include <pthread.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define STDIN_FILENO 0

//error number
#define NO_FD_WITH_TERM 1
#define GET_WINDOW_SIZE_ERROR 2
#define GAME_OVER 3
#define THREAD_CREATE_FAILED 4


//global vars
int ROWS;
int COLUMNS;

/* for numbers and lower-case letter
   0-9 0-9 48-57
   10-35 a-z 97-122
 */
char CharTable[36];
//array store the screen's char COLUMNS*ROWS
char* ScreenTable;
char* Move;
int N;
char* OtherScreen;

int SCORE;
int LEVEL;
char TYPINGCHAR=0;
int isOld=1;

//funcions
void safe_exit(int);
void game_over();
void* animation(void*);
void* middle_window(void*);
void* another_window(void*);
void* socket_conn(void*);
void score_trans(void);





int main(int argc, char *argv[])
{
    struct winsize Size;
    
    if(isatty(STDIN_FILENO)==0)
        exit(NO_FD_WITH_TERM);
    if(ioctl(STDIN_FILENO,TIOCGWINSZ,&Size)<0)
        exit(GET_WINDOW_SIZE_ERROR);
    //The size should be fixed.or it's hard to control
    ROWS=Size.ws_row+1;  //39
    COLUMNS=(Size.ws_col+1)*7/15; //70

    N=sizeof(char)*ROWS*COLUMNS;
    ScreenTable=(char*)malloc(N+4);
    memset(ScreenTable,0,N);

    OtherScreen=(char*)malloc(N+4);
    memset(OtherScreen,0,N);
    Move=(char*)malloc(N);
    memset(Move,0,N);
    
    initscr();
    move(ROWS/2,COLUMNS/2-5);
    printw("%s","Ready?Go!");
    refresh();
    sleep(1);

    clear();
    refresh();


    //create a thread to receive keyboard input
    int res;
    pthread_t keyb;
    res=pthread_create(&keyb,NULL,animation,NULL);
    if(res!=0)
    {
        perror("Thread 1 Creation failed");
        safe_exit(THREAD_CREATE_FAILED);
    }
    pthread_t anti;
    res=pthread_create(&anti,NULL,another_window,NULL);
    if(res!=0)
    {
        perror("Thread 2 Creation failed");
        safe_exit(THREAD_CREATE_FAILED);
    }

    pthread_t info;
    res=pthread_create(&info,NULL,middle_window,NULL);
    if(res!=0)
    {
        perror("Thread 3 Creation failed");
        safe_exit(THREAD_CREATE_FAILED);
    }
    
    pthread_t psocket;
    res=pthread_create(&psocket,NULL,socket_conn,NULL);
    if(res!=0)
    {
        perror("Thread 4 Creation failed");
        safe_exit(THREAD_CREATE_FAILED);
    }
    
    cbreak();
    noecho();
    while(1)
    {
        TYPINGCHAR=getch();
        while(TYPINGCHAR=='\n')
            break;
        isOld=0;
    }
    
    safe_exit(EXIT_SUCCESS);
}

void* socket_conn(void* arg)
{
    int server_sockfd,client_sockfd;
    int server_len,client_len;
    struct sockaddr_in server_address;
    struct sockaddr_in client_address;
    server_sockfd=socket(AF_INET,SOCK_STREAM,0);
    server_address.sin_family=AF_INET;
    server_address.sin_addr.s_addr=htonl(INADDR_ANY);
    server_address.sin_port=htons(9734);
    server_len=sizeof(server_address);
    bind(server_sockfd,(struct sockaddr*)&server_address,
         server_len);
    
    listen(server_sockfd,1);
    client_len=sizeof(client_address);
    client_sockfd=accept(server_sockfd,
                         (struct sockaddr*)&client_address,
                         &client_len);
    while(1)
    {
        read(client_sockfd,OtherScreen,N+4);
        write(client_sockfd,ScreenTable,N+4);
        
    }
    close(client_sockfd);
}

void* middle_window(void* arg)
{
    WINDOW* mid_win;
    //(0,70),heigth:39 width:10
    mid_win=newwin(ROWS,COLUMNS/7,0,COLUMNS);
    while(1)
    {
        mvwprintw(mid_win,0,3,"%s","LEVEL");
        mvwprintw(mid_win,5,3,"%s","SCORES");
        mvwprintw(mid_win,7,2,"%s","PLAYER1");
        mvwprintw(mid_win,10,2,"%s","PLAYER2");
        mvwprintw(mid_win,1,5,"%d",LEVEL/10);
        mvwprintw(mid_win,8,3,"%c%c%c%c",ScreenTable[N],
                 ScreenTable[N+1],ScreenTable[N+2],
                 ScreenTable[N+3]);
        mvwprintw(mid_win,11,5,"%c%c%c%c",OtherScreen[N],
                 OtherScreen[N+1],OtherScreen[N+2],
                 OtherScreen[N+3]);
        touchwin(mid_win);
        wrefresh(mid_win);
        sleep(1);
        wclear(mid_win);
    }
}


void* another_window(void* arg)
{
    WINDOW* other_window;
    //(0,80) 39*70
    other_window=newwin(ROWS,COLUMNS*8/7,0,COLUMNS);
    int i;
    
    while(1)
    {
        for(i=0;i<N;++i)
        {
            mvwaddch(other_window,N/COLUMNS,N%COLUMNS,OtherScreen[i]);
        }
        wrefresh(other_window);
    }
}

void* animation(void* arg)
{
    srand((unsigned)time(NULL));
    
    int  ch;
    int i;
    char charToPrint;
    int column;
    int M=(ROWS-2)*COLUMNS;
    while(1)
    {
        ch=rand()%36; //0-35
        column=rand()%COLUMNS;
        move(0,column);
        if(ch>=0&&ch<=9)
        {
            charToPrint=(char)(ch+48);
        }
        if(ch>=10&&ch<=35)
        {
            charToPrint=(char)(ch+87);           
        }
        addch(charToPrint);
        
        ScreenTable[column]=charToPrint;
        CharTable[ch]++;
        refresh();
        //usleep((55-LEVEL)*500*1000);
        if(LEVEL>=200)
            LEVEL=190;
        usleep((20-((++LEVEL)/10))*100*1000);
        insertln();
        refresh();

        
        for (i=0; i<N; ++i)
        {
            if(ScreenTable[i]!=0&&Move[i]==0)
            {       
                if(i>=M)
                {
                    game_over();  //clean up the windows
                    safe_exit(GAME_OVER); //keep this call in 'main'
                }
                ScreenTable[i+COLUMNS]=ScreenTable[i];
                ScreenTable[i]=0;
                Move[i+COLUMNS]=1;
            }
            if((ScreenTable[i]==TYPINGCHAR)&&(isOld==0))
            {
                move(i/COLUMNS,i%COLUMNS);
                addch(' ');
                flash();
                refresh();
                if(TYPINGCHAR>=48&&(TYPINGCHAR<=57))
                {
                    if(--CharTable[TYPINGCHAR-48]==0)
                        isOld=1;
                }
                
                ScreenTable[i]=0;
                SCORE++;
                score_trans();
            }
        }
        memset(Move,0,N);
    }
    
}


void safe_exit(int exitCode)
{
    endwin();
    free(ScreenTable);
    exit(exitCode);
}

//show the game over information and the score
void game_over()
{
    clear();
    refresh();
    move(ROWS/2-1,COLUMNS/2-1);
    printw("%s","GAME OVER!");
    move(ROWS/2+1,COLUMNS/2-1);
    printw("Level:  %d",LEVEL-48);
    move(ROWS/2+3,COLUMNS/2-1);
    printw("SCORE:  %d",SCORE);
    refresh();
    sleep(2);
}

void score_trans(void)
{
    ScreenTable[N]=SCORE/1000+48;
    ScreenTable[N+1]=SCORE%1000/100+48;
    ScreenTable[N+2]=SCORE%100/10+48;
    ScreenTable[N+3]=SCORE%10+48;
}

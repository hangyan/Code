#include <SDL/SDL.h>
#include <SDL/SDL_image.h>
#include<SDL/SDL_mixer.h>
#include <string>
#include <vector>
#include <cmath>

const int SCREEN_WIDTH = 480;
const int SCREEN_HEIGHT = 640;
const int SCREEN_BPP = 32;

const int FRAMES_PER_SECOND = 20;

const int DOT_WIDTH = 20;

const int TOTAL_PARTICLES=14;


const int BOTTOM_WIDTH=60;
const int BOTTOM_HEIGHT=20;

SDL_Surface *dot    = NULL;
SDL_Surface *screen = NULL;
SDL_Surface *bottom = NULL;
SDL_Surface *red=NULL;
SDL_Surface *blue=NULL;
SDL_Surface *green=NULL;
SDL_Surface *shimmer=NULL;



Mix_Music *music=NULL;

int xVel,xVelTemp;
int yVel,yVelTemp;

SDL_Event event;

const int BRICK_NUM    = 32;
const int BRICK_WIDTH  = 60;
const int BRICK_HEIGHT = 24;

bool H = false;
bool V = false;
bool isPaused=true;
struct brickStruct
{
  int  brickNum;
  bool isColli;
}colliBricks[BRICK_NUM];

std::vector<SDL_Rect> bricks(BRICK_NUM);

struct Circle
{
  int x, y;
  int r;
};
class Bottom
{
private:
  int      xv;
  SDL_Rect bottomrect;
public:
  Bottom();
  void     show();
  void     move();
  void     handle_input();
  SDL_Rect& getRect()
  {
    return bottomrect;
  }
};

class Particle
{
private:
  int x,y;
  int frame;
  SDL_Surface *type;
public:
  Particle(int X,int Y);
  void show();
  bool isDead();
};

  
class Dot
{
private:
  Circle c;
  Particle *particles[TOTAL_PARTICLES];
public:
  Dot();
  void   move(Bottom &);
  void   show();
  void   setVel();
  void show_particles();
  ~Dot();
};

class Timer
{
private:
  int  startTicks;
  int  pausedTicks;
  bool paused;
  bool started;
  
public:
  Timer();
  void start();
  void stop();
  void pause();
  void unpause();
  
  int get_ticks();
  
  bool is_started();
  bool is_paused();
};

SDL_Surface *load_image( std::string filename )
{
  SDL_Surface* loadedImage    = NULL;
  SDL_Surface* optimizedImage = NULL;
  loadedImage                 = IMG_Load( filename.c_str() );
  if( loadedImage != NULL )
  {
    optimizedImage = SDL_DisplayFormat( loadedImage );
    SDL_FreeSurface( loadedImage );
    if( optimizedImage != NULL )
    {
      Uint32 colorkey = SDL_MapRGB(optimizedImage->format,0,0xFF,0xFF);
      SDL_SetColorKey( optimizedImage, SDL_SRCCOLORKEY, colorkey);
    }
  }
  return optimizedImage;
}

void apply_surface( int x, int y, SDL_Surface* source, SDL_Surface* destination, SDL_Rect* clip = NULL )
{
  SDL_Rect offset;
  offset.x = x;
  offset.y = y;
  SDL_BlitSurface( source, clip, destination, &offset );
}

double distance( int x1, int y1, int x2, int y2 )
{
  return sqrt( pow( x2 - x1, 2 ) + pow( y2 - y1, 2 ) );
}
bool check_collision( Circle &A, std::vector<SDL_Rect> &bricks)
{
  int cX, cY;
  for(int brick=BRICK_NUM-1; brick>=0; brick--)
  {
    if(colliBricks[brick].isColli==true)
      continue;
    if( A.x < bricks[brick].x )
    {
      cX = bricks[brick].x;
    }
    else if( A.x > bricks[brick].x + bricks[brick].w )
    {
      cX = bricks[brick].x+bricks[brick].w;
    }
    else
    {
      cX = A.x;
    }
    if( A.y < bricks[brick].y )
    {
      cY = bricks[brick].y;
    }
    else if( A.y > bricks[brick].y+bricks[brick].h)
    {
      cY = bricks[brick].y+bricks[brick].h;
    }
    else
    {
      cY = A.y;
    }
    if( distance( A.x, A.y, cX, cY ) < A.r )
    {
      if((A.x>bricks[brick].x+bricks[brick].w)||(bricks[brick].x>A.x))
        H= true;
      if((A.y>bricks[brick].y+bricks[brick].h)||(bricks[brick].y>A.y))
        V= true;
      colliBricks[brick].isColli = true;
      return true;
    }
  }
  return false;
}

bool init()
{
  if( SDL_Init( SDL_INIT_EVERYTHING ) == -1 )
  {
    return false;
  }
  screen = SDL_SetVideoMode( SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_BPP, SDL_SWSURFACE );
  if( screen == NULL )
  {
    return false;
  }
  SDL_WM_SetCaption( "Move the Dot", NULL );
  if(Mix_OpenAudio(22050,MIX_DEFAULT_FORMAT,2,4096)==-1)
  {
    return false;
  }
  srand(SDL_GetTicks());
  return true;
}

void playMusic()
{
  
  if( Mix_PlayingMusic() == 0 )
  {
    if( Mix_PlayMusic( music, 1 ) == -1 )
    {
      return ;
    }
  }
  else
  {
    if( Mix_PausedMusic() == 1 )
    {
      Mix_ResumeMusic();
    }
    else
    {
      Mix_PauseMusic();
    }
  }
}

  
bool load_files()
{
  dot = load_image( "img/ball_transp.png");
  if( dot == NULL )
  {
    return false;
  }
  bottom = load_image("img/bottom.jpg");
  if(bottom==NULL)
  {
    return false;
  }
  red=load_image("img/red.bmp");
  green=load_image("img/green.bmp");
  blue=load_image("img/blue.bmp");
  shimmer=load_image("img/shimmer.bmp");
  if((shimmer==NULL)||(blue==NULL)||(green==NULL)||(red==NULL))
  {
    return false;
  }
  SDL_SetAlpha(red,SDL_SRCALPHA|SDL_RLEACCEL,222);
  SDL_SetAlpha(blue,SDL_SRCALPHA|SDL_RLEACCEL,222);
  SDL_SetAlpha(green,SDL_SRCALPHA|SDL_RLEACCEL,222);
  SDL_SetAlpha(shimmer,SDL_RLEACCEL|SDL_RLEACCEL,222);
  music=Mix_LoadMUS("sd/brick.ogg");
  if(music==NULL)
  {
    return false;
  }
  return true;
}

void clean_up()
{
  SDL_FreeSurface( dot );
  SDL_FreeSurface(red);
  SDL_FreeSurface(blue);
  SDL_FreeSurface(green);
  SDL_FreeSurface(shimmer);
  SDL_FreeSurface(bottom);
  Mix_FreeMusic(music);
  Mix_CloseAudio();
  SDL_Quit();
}
Particle::Particle(int X,int Y)
{
  x=X-5+(rand()%25);
  y=Y-5+(rand()%25);
  frame=rand()%5;
  switch(rand()%3)
  {
  case 0:type=red;break;
  case 1:type=green;break;
  case 2:type=blue;break;
  }
}

bool Particle::isDead()
{
  if(frame>10)
  {
    return true;
  }
  return false;
}

void Particle::show()
{
  apply_surface(x,y,type,screen);
  if(frame%2==0)
  {
    apply_surface(x,y,shimmer,screen);
  }
  frame++;
}

Dot::Dot()
{
  c.x = 240;
  c.y = 620-DOT_WIDTH/2;
  c.r = DOT_WIDTH / 2;
  for(int p=0;p<TOTAL_PARTICLES;p++)
  {
    particles[p]=new Particle(c.x,c.y);
  }
}

Dot::~Dot()
{
  for(int p=0;p<TOTAL_PARTICLES;p++)
  {
    delete particles[p];
  }
}

void Dot::show_particles()
{
  for(int p=0;p<TOTAL_PARTICLES;p++)
  {
    if(particles[p]->isDead()==true)
    {
      delete particles[p];
      particles[p]=new Particle(c.x,c.y);
    }
  }
  for(int p=0;p<TOTAL_PARTICLES;p++)
  {
    particles[p]->show();
  }
}

void Dot::show()
{
  apply_surface( c.x - c.r, c.y - c.r, dot, screen );
  show_particles();
}

Bottom::Bottom()
{
  xv           = 0;
  bottomrect.x = (SCREEN_WIDTH-BOTTOM_WIDTH)/2;
  bottomrect.y = SCREEN_HEIGHT-BOTTOM_HEIGHT;
  bottomrect.w = BOTTOM_WIDTH;
  bottomrect.h = BOTTOM_HEIGHT;
}

void Bottom::show()
{
  apply_surface(bottomrect.x,bottomrect.y,bottom,screen);
}

void Bottom::move()
{
  bottomrect.x += xv;
  if(bottomrect.x+BOTTOM_WIDTH>SCREEN_WIDTH||bottomrect.x<0)
  {
    bottomrect.x -= xv;
  }
}

void Bottom::handle_input()
{
  if( event.type == SDL_KEYDOWN )
  {
    switch( event.key.keysym.sym )
    {
    case SDLK_LEFT: xv  -= 10; break;
    case SDLK_RIGHT: xv += 10; break;
    case SDLK_SPACE:
      if(isPaused)
      {
        xVel=xVelTemp;
        yVel=yVelTemp;
        isPaused=false;
      }
      else
      {
        xVelTemp=xVel;
        yVelTemp=yVel;
        xVel=yVel=0;
        isPaused=true;
      }
      break;
    case SDLK_UP:xVel=20;yVel=20;isPaused=false;
      break;
    }
  }
  else if( event.type == SDL_KEYUP )
  {
    switch( event.key.keysym.sym )
    {
    case SDLK_LEFT: xv  += 10; break;
    case SDLK_RIGHT: xv -= 10; break;
    }
  }
}

Timer::Timer()
{
  startTicks  = 0;
  pausedTicks = 0;
  paused      = false;
  started     = false;
}

void Timer::start()
{
  started    = true;
  paused     = false;
  startTicks = SDL_GetTicks();
}

void Timer::stop()
{
  started = false;
  paused  = false;
}

void Timer::pause()
{
  if( ( started == true ) && ( paused == false ) )
  {
    paused      = true;
    pausedTicks = SDL_GetTicks() - startTicks;
  }
}

void Timer::unpause()
{
  if( paused == true )
    {
        paused      = false;
        startTicks  = SDL_GetTicks() - pausedTicks;
        pausedTicks = 0;
    }
}

int Timer::get_ticks()
{
  if( started == true )
  {
    if( paused == true )
    {
      return pausedTicks;
    }
    else
    {
      return SDL_GetTicks() - startTicks;
    }
  }
  return 0;
}

bool Timer::is_started()
{
  return started;
}

bool Timer::is_paused()
{
  return paused;
}
void show_bricks()
{
  int bx = 0,by=0;
  int i  = 0;
  while(i<BRICK_NUM)
  {
    bricks[i].x  = (i*BRICK_WIDTH)%SCREEN_WIDTH;
    bricks[i].y  = (i/(SCREEN_WIDTH/BRICK_WIDTH))*BRICK_HEIGHT+50;
    bricks[i].w  = BRICK_WIDTH;
    bricks[i].h  = BRICK_HEIGHT;
    SDL_FillRect( screen, &bricks[i], SDL_MapRGB( screen->format, (i+1)*900,i*10,i*50) );
    i++;
  }
}

bool check_collision2( Circle &A, SDL_Rect &B )
{
  int cX, cY;
  if( A.x < B.x )
  {
    cX       = B .x;
  }
  else if( A.x > B.x +B .w )
  {
    cX       = B.x + B.w;
  }
  else
  {
    cX       = A.x;
  }
  if( A.y < B.y )
  {
    cY       = B.y;
  }
  else if( A.y > B.y + B.h )
  {
    cY       = B.y + B.h;
  }
  else
  {
    cY       = A.y;
  }
  
  if( distance( A.x, A.y, cX, cY ) < A.r )
  {
    return true;
  }
  return false;
}
void Dot::move(Bottom &b)
{
  c.x+= xVel;
  if( ( c.x - DOT_WIDTH / 2 < 0 ) || ( c.x + DOT_WIDTH / 2 > SCREEN_WIDTH )||check_collision(c,bricks))
  {
    playMusic();
    xVel  = -xVel;
   }
  c.y+= yVel;
  if( ( c.y - DOT_WIDTH / 2 < 0 ) || ( c.y + DOT_WIDTH / 2 > SCREEN_HEIGHT ) ||check_collision(c,bricks))
  {
    playMusic();
    yVel  = -yVel;
  }
  if(check_collision2(c,b.getRect())==true)
  {
    playMusic();
    yVel=-yVel;
  }
  if(c.y>=SCREEN_HEIGHT)
  {
    SDL_Delay(1000*1);
    c.x=b.getRect().x+b.getRect().w/2;
    c.y = 620-DOT_WIDTH/2;
    xVel=yVel=0;
    isPaused=true;
  }
}
int main( int argc, char* args[] )
{
  bool quit = false;
  Dot myDot;
  xVel=0;
  yVel=0;
  Timer fps;
  Bottom myBottom;
  for(int i=0;i<BRICK_NUM;i++)
  {
    colliBricks[i].brickNum=i;
    colliBricks[i].isColli=false;
  }
  if( init() == false )
  {
    return 1;
  }
  if( load_files() == false )
  {
    return 1;
  }
  while( quit == false )
  {
    fps.start();
    while( SDL_PollEvent( &event ) )
    {
      myBottom.handle_input();
      if( event.type == SDL_QUIT )
      {
        quit = true;
      }
    }
    myDot.move(myBottom);
    SDL_FillRect( screen, &screen->clip_rect, SDL_MapRGB( screen->format, 0x00, 0x00, 0x00) );
    show_bricks();
    for(int i=0;i<BRICK_NUM;i++)
      if(colliBricks[i].isColli==true)
        SDL_FillRect( screen, &bricks[i], SDL_MapRGB( screen->format, 0x00,0x00,0x00) );
    myDot.show();
    myBottom.show();
    myBottom.move();
    if( SDL_Flip( screen ) == -1 )
    {
      return 1;
    }
    if( fps.get_ticks() < 1000 / FRAMES_PER_SECOND )
    {
      SDL_Delay( ( 1000 / FRAMES_PER_SECOND ) - fps.get_ticks() );
    }
  }
  clean_up();
  return 0;
}

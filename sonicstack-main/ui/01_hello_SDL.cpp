#include <SDL2/SDL.h>
#include <stdio.h>
#include <string>

const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;
enum KeyPressSurfaces
{
	KEY_PRESS_SURFACE_DEFAULT,
	KEY_PRESS_SURFACE_UP,
	KEY_PRESS_SURFACE_DOWN,
	KEY_PRESS_SURFACE_LEFT,
	KEY_PRESS_SURFACE_RIGHT,
	KEY_PRESS_SURFACE_TOTAL
};

SDL_Window* window = NULL;
SDL_Surface* screenSurface = NULL;
SDL_Surface* currentSurface = NULL;
SDL_Surface* keyPressSurfaces[ KEY_PRESS_SURFACE_TOTAL ];
SDL_Event e;
bool quit = false;

std::string files[KEY_PRESS_SURFACE_TOTAL] = {
	"press.bmp",
	"up.bmp",
	"down.bmp",
	"left.bmp",
	"right.bmp"
};


bool init(){
	if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
	{
		printf("Could not init SDL: %s\n", SDL_GetError() );
		return false;
	}
	
	window = SDL_CreateWindow( "SDL Tutorial",
		SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
		SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN );
	if( window == NULL )
	{
		printf("Could not create SDL window: %s\n", SDL_GetError() );
		return false;
	}
	
	screenSurface = SDL_GetWindowSurface( window );
	return true;
}

void close()
{
	for(int i=0; i<KEY_PRESS_SURFACE_TOTAL; i++){
		SDL_FreeSurface(keyPressSurfaces[i]);
		keyPressSurfaces[i] = NULL;
	}
	SDL_DestroyWindow( window );
	window = NULL;
	SDL_Quit();
	
}

SDL_Surface* loadSurface( std::string path )
{
	SDL_Surface* loadedSurface = SDL_LoadBMP( path.c_str() );
	if(loadedSurface == NULL){
		printf("Could not load %s: %s\n", path.c_str(), SDL_GetError() );
	}	
	return loadedSurface;
}

bool loadMedia()
{
	for(int i=0; i<KEY_PRESS_SURFACE_TOTAL; i++){
		keyPressSurfaces[i] = loadSurface(files[i]);
		if(keyPressSurfaces[i] == NULL){
			printf("Failed to load %s: %s", files[i], SDL_GetError());
			return false;
		}
	}
	return true;
}

void mainLoop(){
	while(SDL_PollEvent(&e) != 0)
	{
		if(e.type == SDL_QUIT){
			quit = true;
		}
		else if(e.type == SDL_KEYDOWN)
		{
			switch(e.key.keysym.sym)
			{
				case SDLK_UP:
				currentSurface = keyPressSurfaces[KEY_PRESS_SURFACE_UP];
				break;
				
				case SDLK_DOWN:
				currentSurface = keyPressSurfaces[KEY_PRESS_SURFACE_DOWN];
				break;
				
				case SDLK_LEFT:
				currentSurface = keyPressSurfaces[KEY_PRESS_SURFACE_LEFT];
				break;
				
				case SDLK_RIGHT:
				currentSurface = keyPressSurfaces[KEY_PRESS_SURFACE_RIGHT];
				break;
				
				default:
				currentSurface = keyPressSurfaces[KEY_PRESS_SURFACE_DEFAULT];
				break;				
			}
			SDL_BlitSurface( currentSurface, NULL, screenSurface, NULL);
			SDL_UpdateWindowSurface( window );

		}
	}
	// update here if there are updates?
}


int main( int argc, char* argv[] )
{
	if(! init()){
		return 1;
	}
	if(! loadMedia()){
		return 2;
	}
	while(! quit)
	{
		mainLoop();
	}
	close();
	return 0;
}

PImage cday;
PImage pday; 
PImage bg;

void setup()
{
  size(2048,1024);
  
  cday = loadImage("cday.png");
  pday = loadImage("pday.png");
  bg = loadImage("flatshading_basemap.jpg");
}

void draw()
{
  image(bg, 0, 0);
  
  tint(255, 110);
  image(pday,0,0);
  
  tint(255,255);
  image(cday,0,0);
  
  saveFrame("merge.png"); 
  exit();
}

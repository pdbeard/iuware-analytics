PImage graph;
PImage cday;
PImage pday; 
PImage bg;

String[] num_s;
int[] num_i;

void setup()
{
  size(2048,1024);
  
  //num_s = loadStrings("counter.tmp");    //Load in start day number
  //num_i = int(num_s); 
  
  //graph = loadImage(num_i[0]+".png");
  //graph = loadImage("10.png");
  cday  = loadImage("cday.png");
  pday  = loadImage("pday.png");
  bg    = loadImage("flatshading_basemap.jpg");
}

void draw()
{
  image(bg, 0, 0);
  
  tint(255, 110);
  image(pday,0,0);
  
  tint(255,255);
  image(cday,0,0);
  
  //image(graph,width/25,height/2.5,300,200);
  //image(graph,width/1.6,height/2.5,300,200);
  
  saveFrame("merge.png"); 
  exit();
}

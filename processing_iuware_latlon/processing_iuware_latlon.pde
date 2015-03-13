//Reads in google anayltics data and creates warped circles 
//pdbeard@iu.edu


import com.reades.mapthing.*;
import net.divbyzero.gpx.*;
import net.divbyzero.gpx.parser.*;
import java.util.*;

BoundingBox envelope = new BoundingBox(4267, 90f, 180f, -90f, -180f);

PGraphics pg; //offscreen buffer renderer
float[] glyphParam = new float[4];
PImage shape_img;
PImage bg;
Table csv_table;
PFont labelFont;

void setup() {
  colorMode(HSB,360,100,100);
  
  int d = 2048;
  size(d,envelope.heightFromWidth(d),P3D);
  
  pg = createGraphics(1024,1024, P3D);           //initialize offscreen buffer
  hint(DISABLE_DEPTH_TEST);                      //avoids z-fighting
 
  shape_img = loadImage("shape.png");
  bg = loadImage("transparent_2048x1024.png");
  //bg = loadImage("analytics_basemap.jpg");
  
  smooth();
  noLoop();  
}

void draw() {
  //background(300,25,25);
  background(bg);
  fill(255);
  pushMatrix();
  popMatrix();
  
  //Create an offscreen render ellipse to be warped
  pg.beginDraw();
  pg.background(0,0,255,0);
  pg.rotateZ(-18*PI/180);
  
  //pg.tint(255,180);
  pg.fill(55,230,126,230);
  pg.stroke(255,255,255,255);
  pg.strokeWeight(pg.width/35);
  pg.smooth(8);
  pg.ellipse(pg.width/2, pg.height/2, pg.width/2, pg.height/2);
 
  pg.endDraw();
  
 ///////////////////////////METHOD ONE///////////////////////////////////
 // Create quadStrip using method 1: Fish Eye Lense Algorithm          //
 // two files needed for this are getQuadStrip and C2SOS               //
 ////////////////////////////////////////////////////////////////////////
 
  PShape quadStrip1, quadStrip2, quadStrip3, quadStrip4; // Initialize Quads
  float sizeQuadX = 25.0;                                // size of quad x direction
  float sizeQuadY = 25.0;                                // size of quad y direction
  float resQuad = sizeQuadY;                             // y resolution of image
  
  for(int j = (30*width/360); j<=(330*width/360); j=j+(30*width/360))
  {  
    for(int i = (30*height/180); i<=(150*height/180); i=i+(30*height/180))
    {
      PShape quadStrip; // initialize shape
      //USAGE: quadStrip =   getQuadStrip(x-position, y-postion, sizeQuadX, sizeQuadY, resQuad, image to warp);
      quadStrip =   getQuadStrip(j, i-resQuad, sizeQuadX, sizeQuadY, resQuad, pg);
      //Uncomment to render
      //shape(quadStrip);
    }
  }

  // Load in analytics data for the current day
  csv_table = loadTable("shapes/cDay_IUware_data.csv", "header");
  PShape circle_Tissot; //initialize shape
  
  println(csv_table.getRowCount() + " total rows in table"); 
  
  //Scale
  float max_sess = 5000; 
  float min_sess = 1;
  float max_scale = 160;
  float min_scale = 13;
  
  /* //Removed for hardcoded max instead
  for (TableRow row : csv_table.rows())
  {
    float sess = row.getInt("sess");
    if (max_sess<sess)
    {
      max_sess = sess;
    }
  }
  */
  
  max_sess = sqrt(max_sess); 

  for (TableRow row : csv_table.rows()) 
  {
    float lon = row.getFloat("lon");
    float lat = row.getFloat("lat");
    float sess = row.getInt("sess");
    
    // Normalize data
    float norm = (((max_scale - min_scale)/(max_sess - min_sess))*(sqrt(sess) - max_sess)) + max_scale;
    println("SESS MINUS " + ((sqrt(sess)-max_sess)*.005));
   
    circle_Tissot = createQuad(lon,lat,norm,norm,pg); 
    shape(circle_Tissot);
    
    //Debug prints
    //String name = row.getString("name"); 
    //println(" lon="+lon+" : lat="+lat+" : sess="+sess+" : norm="+norm);
    //println(" max="+max_scale + " min="+min_scale +" maxsess"+ max_sess +" minsess="+ min_sess);
  }

//Example to place one marker
  //circle_Tissot = createQuad(-86.1665,1.45,40,40,pg); //Galap Mound
  //shape(circle_Tissot);

 saveFrame("cday.png"); 
 exit();
}


import com.reades.mapthing.*;
import net.divbyzero.gpx.*;
import net.divbyzero.gpx.parser.*;
import java.util.*;

BoundingBox envelope = new BoundingBox(4267, 90f, 180f, -90f, -180f);

//Lines    canals;
//Polygons world;
//Polygons worldSimplified;
//Points   worldCentroids;
//Points   cityMarkers;

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
  
  // Load the Polygons class from a shapefile
  // in a shapes subdirectory of the data folder.
    //world  = new Polygons(envelope, dataPath("shapes/world2.shp"));
    //world.setLabelField("NAME");
    //world.setValueField("AREA");
    //world.setColourScale(color(250,10,100),color(280,70,90),15);
  
  // Sets a higher distance-threshold for simplifying
  // the contents of the shapefile. This will simplify
  // the display more than a lower number.
    //worldSimplified = new Polygons(envelope, dataPath("shapes/world2.shp"));
    //worldSimplified.setLocalSimplificationThreshold(0.05d);
  

  // Load up the font that we'll use for labelling
  // the cities on the sketch.
    //labelFont = loadFont("Serif-16.vlw");
    //textFont(labelFont);
    //textSize(12);
  
  smooth();
  noLoop();  
}

void draw() {
  //background(300,25,25);
  background(bg);
  fill(255);
  pushMatrix();
  
  // The project(this) function uses the
  // mapped coordinates of the CSV or
  // shapefile, but if the size of the 
  // sketch is changed then the coordinates
  // will automatically be remapped for you.
  
  // Will colour-code the world according
  // to the AREA column in the shape file
    //world.projectValues(this,5000f,17000000f);
  
  // Will show the effect of the simplification
  // process on the number of nodes in each polygon
  //noFill();
  //strokeWeight(1f);
  //stroke(300,10,10);
   //worldSimplified.project(this);

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
  
  
  // Star Properties
  //fill(0,255,0,180);  
  //stroke(#000000);
  //strokeWeight(20);
  //PShape stars = star(320,640, 100,260, 5);   // star ( x, y, inner radius , outer radius , points) 

  //int oHeight = shape_img.height;
  //int oWidth  = shape_img.width;
  //shape_img.resize(pg.width, pg.height);
  
  //tint(255,127);
  //pg.image(shape_img, -(oWidth/2), oHeight/2);   //uncomment to show image
  //pg.shape(stars);   //uncomment to show star
  //pg.ellipse(0, 0, 200,200);
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

  csv_table = loadTable("shapes/cDay_IUware_data.csv", "header");
  PShape circle_Tissot; //initialize shape
  
  println(csv_table.getRowCount() + " total rows in table"); 
  
  //Scale
  float max_sess = 5000; 
  float min_sess = 1;
  float max_scale = 160;
  float min_scale = 13;
  
  /*
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
    
    
    float norm = (((max_scale - min_scale)/(max_sess - min_sess))*(sqrt(sess) - max_sess)) + max_scale;
    println("SESS MINUS " + ((sqrt(sess)-max_sess)*.005));
   
    circle_Tissot = createQuad(lon,lat,norm,norm,pg); 
    shape(circle_Tissot);
    //String name = row.getString("name"); 
    println(" lon="+lon+" : lat="+lat+" : sess="+sess+" : norm="+norm);
    println(" max="+max_scale + " min="+min_scale +" maxsess"+ max_sess +" minsess="+ min_sess);
  }

//Example to place one marker
  //circle_Tissot = createQuad(-86.1665,1.45,40,40,pg); //Galap Mound
  //shape(circle_Tissot);

 saveFrame("cday.png"); 
 exit();
}

public PShape star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  PShape starShape;
  starShape = createShape();
  starShape.beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    starShape.vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    starShape.vertex(sx, sy);
  }
  starShape.endShape(CLOSE);

  return starShape;
}


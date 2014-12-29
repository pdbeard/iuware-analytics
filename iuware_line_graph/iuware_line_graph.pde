//------ Line Graph for IUware
// TODO
// Make stuff green 

import java.text.*;

float average = 0;
float total_norm;
float daytotal;
float firststep;
String[] data_s;
String[] num_s;
int[] data_i;
int[] num_i;
int index; 

int d = day();
int m = month();
int y = year();

// Set Data
float max_sess  = 5000;    // Find Max Session for all data
float max_scale = 200;     // Y Scale
float min_sess  = 0;       // not used
float min_scale = 0;       // not used
int step_dist   = 35;      // space between x'axis
int total_days  = 11;      // Total Days being used

  
void setup() {
  size(600,400, P3D);
  smooth();
}

void draw() {
  float x_width = width/1.35;   //Change to move graph around
  float y_height = height/1.3;
  background(255); 
  noLoop();
  
  rectMode(CENTER);
  stroke(255);
  fill(50);
  rect(width/2,height/2,width-20,height-20);
  
  // Graph line Style
  stroke(255);
  strokeWeight(4);
  strokeJoin(ROUND);
  noFill();

  num_s = loadStrings("num.txt");    //Load in start day number
  num_i = int(num_s); 
  
  // Graph Line Draw
  beginShape();  
  int i;
  int x = 0;
  for (i = num_i[0]+total_days; i>num_i[0]; i--)
  {
    index = i%total_days;
    data_s = loadStrings(index+".csv");
    data_i = int(data_s);
    
    //average = average + data_i[0];  //uncomment for Average line
    
    total_norm = (((max_scale - min_scale)/(max_sess - min_sess))*(data_i[0]- max_sess)) + max_scale;
    total_norm = height-total_norm-height;

    print("--Index="+index+" Data="+ data_i[0]+" Norm="+ total_norm+" X="+x+"  ");
    
    if (x==0) //saves out norm and day total for highlight and text
    {
      firststep = total_norm;
      daytotal= data_i[0];
    }
     
    vertex(x+x_width,total_norm+y_height,4,4);
    x=x-step_dist;
  } 
  endShape();
  
/***** 
// Average Line
  average = average/total_days;
  total_norm = (((max_scale - min_scale)/(max_sess - min_sess))*(average- max_sess)) + max_scale;
  average = height-total_norm-y_height;
  line (x_width, average  , x_width+x+step_dist, average);
*****/
 
  // X - axis line
  stroke(255,100);
  strokeWeight(2);
  line(x_width,y_height,x_width+x+step_dist,y_height);  
  
  // Current Day style. Line & Ellipse
  stroke(55,180,126);
  line(x_width,y_height+15, x_width, firststep+y_height+7.5);
  line(x_width+30,firststep+y_height, x_width+7.5, firststep+y_height);
 
  fill(255);
  ellipse(x_width, firststep+y_height,15,15);

  // Text 
  String daytotals = NumberFormat.getInstance().format(daytotal);  // Removes float .00's. Uses java.text import
  textSize(20);
  
  textAlign(CENTER,CENTER);
  text(m+"/"+d+"/"+y,x_width,y_height+25);
  
  textAlign(LEFT,CENTER);
  text(daytotals, x_width+35, firststep+y_height-2);  // Day Total
  
  textSize(30);
  textAlign(CENTER,CENTER);
  text("Total Daily Sessions", width/2.1,50);
  
  // Saves and exits
  saveFrame(num_i[0]+".png");
  exit();
  
}




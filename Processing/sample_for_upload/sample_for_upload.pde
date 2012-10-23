// Sample Control for Processing V.90
// Description: Loads and manipulates the Pitch and Panning of a sample object
// Instructions: Move the mouse Up/Down to control the sample-pitch, and sideways for the panning.
// By: Amit Pitaru on July 16th 2005

import pitaru.sonia_v2_9.*;
Sample runningTrack;

import processing.serial.*;
Serial myPort;
float value_x = 0;
float value_y = 0;
float [] valueArrayX;
float [] valueArrayY;
float avg_X;
float avg_Y;

int countIndex = 0;
int recordInterval = 1000;
int recordTime = 10;
int currentTime = 0;
int previousTime = 0;
int i;


void setup()
{

 size(512,200);
 String portName = "COM22";
 myPort = new Serial(this,portName,19200);
 myPort.bufferUntil('\n');
 
 valueArrayY = new float[10];
 
 Sonia.start(this);
 runningTrack = new Sample("rolling.aif"); 
 runningTrack.repeat(); 
}

void draw()
{

 background(0,30,0);
 strokeWeight(1); 
 
 currentTime = millis();
 
 if((currentTime - previousTime) > recordInterval){
   
   println("assessing running speed");
  
   countIndex = (countIndex + 1) % recordTime;
  
   valueArrayY[countIndex] = value_y;
   
   //println("index:"+countIndex+"Y:"+valueArrayY[countIndex]);
   
   for(int i = 0; i < recordTime; i++)
   {avg_Y = avg_Y + valueArrayY[i];}
   
   avg_Y = avg_Y / recordTime;
 
   previousTime = currentTime;
   
 }
 
 if(runningTrack.isPlaying())
 {background(0,40,0);}
           
 setRate(); // Y
 //setPan(); // X
 //setVolume(); // variable
 drawScroller();            
}
         
void serialEvent(Serial p)
{
  String s ="";
  String[] values;
  
  if(p.available() > 0){
    s = p.readString();
    if(s != null){
      //println("received:" + s);
      
      values = s.split(",");
      //println(values);
      
      //value_x = value_x - (value_x - float(values[0]))*0.1; //smoothing
      value_y = float(values[1]);
    }
  }
}        
           
void mousePressed(){
   //loop the sample
  runningTrack.repeat();
}

void mouseReleased(){
   //Stop the sample, and unload it form memory in 1 frames (each frame is about 1 ms).
  runningTrack.stop(1);
}

//void setPan(){
  // set the pan of the sample object.
  // Range: float from -1 to 1 .... -1 -> left, 0 -> balanced ,1 -> right
  // notes: only works with MONO samples. Pan for Stereo support in next version.
 //float pan = -1f + mouseX/(width/2f);
  //runningTrack.setPan(pan);

//}

// NOT IN USE FOR THIS EXAMPLE
//void setVolume(){
  // set the volume of the sample. 
  // Range: float from 0 to 1 
 // float vol = mouseY/(height*1f);
 // runningTrack.setVolume(vol);
//}

void setRate(){
  float inputY = map(avg_Y,40,300,198,1);
  println(inputY);
   // set the speed (sampling rate) of the sample.
   // Values:
   // 0 -> very low pitch (slow playback).
   // 88200 -> very high pitch (fast playback).
   float rate = (height - inputY)*88200/(height);
   runningTrack.setRate(rate);
}

// Draw a scroller that shows the current sample-frame being played.
// Notice how the sample plays faster when the Sample-Rate is higher.(controlled by mouseY)

void drawScroller()
{ //drawing green chart
 strokeWeight(1);
 stroke(0,255,0);
 float percent = runningTrack.getCurrentFrame() *100f / runningTrack.getNumFrames();
 float marker = percent*width/100f;
 line(marker,0,marker,20);
 line(0,10, width,10);
}

// Safely close the sound engine upon Browser shutdown.
public void stop()
{
  Sonia.stop();
  super.stop();
}
         

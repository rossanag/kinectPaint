/* --------------------------------------------------------------------------
 * SimpleOpenNI Hands3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * -------A---------------------------------------------------------------------
 * This demo shows how to use the gesture/hand generator with two hands.
 * Just a proof of concept, tracking fingers later.
 * Author: Rossana Guerra - 2017
 * Licence: MIT
 * ----------------------------------------------------------------------------
 */
 
import java.util.Map;
import java.util.Iterator;

import SimpleOpenNI.*;
//import processing.video.*;

//Capture video;


SimpleOpenNI context;
int handVecListSize = 20;

PImage photo; 

int index2 = 0;

Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
                                   
void paintStroke(float strokeLength, color strokeColor, int strokeThickness) {

  float stepLength = strokeLength/4.0;
  
  // Determina la curva, 0 es línea recta
  float tangent1 = 0;
  float tangent2 = 0;
  
  float odds = random(1.0);
  
  if (odds < 0.7) {
    tangent1 = random(-strokeLength, strokeLength);
    tangent2 = random(-strokeLength, strokeLength);
  } 
  
  // Pincel, grosor grande
  noFill();
  stroke(strokeColor);
  strokeWeight(strokeThickness);
  curve(tangent1, -stepLength*2, 0, -stepLength, 0, stepLength, tangent2, stepLength*2);
  //curve(x1, y1, x2, y2, x3, y3, x4, y4)
  
  int z = 1;
  
  // Dibujar detalles del pincel
  for (int num = strokeThickness; num > 0; num --) {    
    float offset = random(-50, 25);
    color newColor = color(red(strokeColor)+offset, green(strokeColor)+offset, blue(strokeColor)+offset, random(100, 255));
    
    stroke(newColor);
    strokeWeight((int)random(0,3)); 
    curve(tangent1, -stepLength*2, z-strokeThickness/2, -stepLength*random(0.9, 1.1), z-strokeThickness/2, stepLength*random(0.9, 1.1), tangent2, stepLength*2);
    
    z += 1;
  }
}
                                   
                                   
void setup()
{
//  frameRate(200);  
  background(10);  
  size(1280,480);
  
  //video = new Capture(this, 160, 120);
  
  // Start capturing the images from the camera
  //video.start();  
  
  
  // Start capturing the images from the camera

  
  photo = loadImage("vg2.jpeg");
  image(photo,640,0,640,480);

  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }   

  // enable depthMap generation 
  context.enableDepth();
    
  
  // habilitar mirror para hacerlo más intuitivo
  context.setMirror(true);

 
  context.enableHand();

  context.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);
  
 }

void draw()
{
  // update the cam
  //image(video,0,480,160,120);
  context.update();
  
  photo.loadPixels();
    
  // draw the tracked hands
  if(handPathList.size() > 0)  
  {    
    Iterator itr = handPathList.entrySet().iterator();     
    while(itr.hasNext())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();
      
        noFill(); 
        strokeWeight(1);        
        Iterator itrVec = vecList.iterator();         
          while( itrVec.hasNext() ) 
          { 
            p = (PVector) itrVec.next(); 
            
            context.convertRealWorldToProjective(p,p2d);
                      
           
            
            int x = (int)(p2d.x - context.depthWidth()*(photo.width)/context.depthWidth());
            int y = (int)(p2d.y - context.depthHeight()*(photo.height)/context.depthHeight());
                        
            //int x = (int)(p2d.x)*(photo.width/context.depthWidth());
            //int y = (int)(p2d.y)*(photo.height/context.depthHeight());
            //int y = (int)(p2d.x*photo.height)/context.depthHeight();
            
            int index = (int)constrain(x + y*photo.width, 0, photo.width*photo.height-1);
            //if (index < (photo.width*photo.height))
            {
              //p2d.x + p2d.y*photo.width
              
              color pixelColor = photo.pixels[index];
              pixelColor = color(red(pixelColor), green(pixelColor), blue(pixelColor), 70);
              
              pushMatrix();
              translate(p2d.x,p2d.y);              
              fill(pixelColor);
              rotate(radians(random(-90, 90)));
              
              // Paint by layers from rough strokes to finer details
              if (frameCount < 20) {
                // Big rough strokes
                //paintStroke(random(150, 250), pixelColor, (int)random(20, 35));
                ellipse(0,0,(int)random(20,35),28);
              } else if (frameCount < 50) {
                 ellipse(0,0,(int)random(10,30),20);   // Thick strokes
                //paintStroke(random(75, 125), pixelColor, (int)random(8, 30));
                
              } else if (frameCount < 300) {
                // Small strokes
                //paintStroke(random(30, 60), pixelColor, (int)random(1, 24));
                ellipse(0,0,(int)random(8,24),15);
              } else if (frameCount < 350) {
                // Big dots
                //paintStroke(random(5, 20), pixelColor, (int)random(5, 18));
                  ellipse(0,0,(int)random(10,18),13);
              } else if (frameCount < 600) {
                // Small dots
                //paintStroke(random(1, 10), pixelColor, (int)random(1, 14));
                ellipse(0,0,(int)random(7,14),10);
              }
              else if (frameCount >= 600) {
               // Very Small dots
                //paintStroke(random(1, 7), pixelColor, (int)random(1, 12));
                ellipse(0,0,(int)random(4,12),9);
                //frameRate/frameCountnoise(7*frame);
              }
              
              popMatrix();
       
            //vertex(p2d.x,p2d.y);
            index2 += 1;
            }
          }
        //endShape(); 
               
    }        
  }
  else
    println("no hands");
    
  //saveFrame("imgs/vg-###.png");  
}


// -----------------------------------------------------------------
// hand events

void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
  
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
 
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1); 
  }  
}

void onLostHand(SimpleOpenNI curContext,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  
  int handId = context.startTrackingHand(pos);
  println("hand stracked: " + handId);
}

//void captureEvent(Capture c) {
//  c.read();
//}
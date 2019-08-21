import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;
import processing.serial.*;
import java.nio.*;
import processing.serial.*;


ControlP5 cp5;
DropdownList dropList1, dropList2; 
Minim minim;
AudioInput envSound;
AudioPlayer song;
FFT fft;
FFT fft_song;
Serial myPortRead;
// Serial myport;
//Feature raw data.


//GUI font
PFont label,textBlack,titleBlack;

//noise cancelling rate
int anc;
//GUI text 
boolean kws;
String scenario;
String event;
String music;
int kws_count = 0;
// Serial readings
ArrayList<String> scenarios = new ArrayList();
ArrayList<Float> readings = new ArrayList();
ArrayList<Float> window_score = new ArrayList();
ArrayList<Float> keyword_score = new ArrayList();
//env
float specLow1 = 0.03; // 3%
float specMid1 = 0.125;  // 12.5%
float specHi1 = 0.2;   // 20%
//music
float specLow2 = 0.03; // 3%
float specMid2 = 0.125;  // 12.5%
float specHi2= 0.2;   // 20%
//env
float scoreLow1 = 0;
float scoreMid1 = 0;
float scoreHi1 = 0;
//music
float scoreLow2 = 0;
float scoreMid2 = 0;
float scoreHi2 = 0;

float oldScoreLow1 = scoreLow1;
float oldScoreMid1 = scoreMid1;
float oldScoreHi1 = scoreHi1;

float oldScoreLow2 = scoreLow2;
float oldScoreMid2 = scoreMid2;
float oldScoreHi2 = scoreHi2;

// To extend visualization of a sound event
float scoreDecreaseRate = 25;

int nbCubes;
Cube[] cubes_env;
Cube[] cubes_anc;

int nbTetrahedrons;
Tetrahedron[] tetrahedrons;

//number of walls
int nbMurs = 500;
Mur[] murs;

//GUI space
float GUIHeight = 200;
float kws_line_width = 0;
//starting position of subes
float startingZ = -10000;
float maxZ = 1000;

//transparancy for dim color
float dim_color = 2;

void setup()
{
  fullScreen(P3D);
  // size(1000,1000,P3D);
  kws = false;
  scenario = "-";
  event = "-";
  music = "Play";
  minim = new Minim(this);
  envSound = minim.getLineIn();
  //GUI icon
  PImage[] icons = {loadImage("button_play.png"),loadImage("button_pause.png")};
  // envSound = minim.getLineIn(minim.MONO,8192,44100);
  song = minim.loadFile("RainRabbit.mp3"); 
  fft = new FFT(envSound.bufferSize(), envSound.sampleRate());
  //sampleRate = 44100;
  fft_song = new FFT(song.bufferSize(), song.sampleRate());

  //list length
  for(int i=0;i<48;i++){
    readings.add(0.0);
  }
  for(int i=0;i<200;i++){
    window_score.add(0.0);
    keyword_score.add(0.0);
  }
  //scenario list
  scenarios.add("Home");
  scenarios.add("Terminal");
  scenarios.add("Flight");
  scenarios.add("Commute");


  // read input TBC 
  // myPortRead = new Serial(this,"/dev/tty.usbmodem316B336930381", 9600);
  // myport = new Serial(this,Serial.list()[1],115200);
  // myport = new Serial(this,"COM7",115200);
  // List all the available serial ports:
  printArray(Serial.list());
  
  //GUI elements
  kws_line_width = (width/2-400)/200;
  cp5 = new ControlP5(this);
  cp5.addButton("PLAY")
    // .setValue(0)
    .setPosition(width/2,height-150)
    .setSize(50,50)
    .setImages(icons[0])
    ;


  dropList1 = cp5.addDropdownList("gain")
                  .setPosition(width/2+150, height-150)
                  .setSize(200,150)         
                  .setBackgroundColor(color(0))
                  .setItemHeight(20)
                  .setBarHeight(20)
                  .setColorBackground(color(60))
                  .setColorActive(color(255, 128))
                  ;
  for (int i=0;i<9;i++) {
    dropList1.addItem(Integer.toString(i)+"bits", (byte)i);
  }

  dropList2 = cp5.addDropdownList("keyWord")
                  .setPosition(width/2+400, height-150)
                  .setSize(200,150)
                  .setBackgroundColor(color(0))
                  .setItemHeight(20)
                  .setBarHeight(20)
                  .setColorBackground(color(60))
                  .setColorActive(color(255, 128))
                  .addItem("Thomas", (byte)0x01)
                  .addItem("Jerry",(byte)0x02)
                  .addItem("Yes",(byte)0x03)
                  .addItem("Happy",(byte)0x04)
                  .addItem("Ni Hao",(byte)0x05)
                  ; 
  

  //add more objects as music input
  nbCubes = (int)(fft.specSize()*specHi1);
  // nbCubes = 64;
  cubes_env = new Cube[nbCubes];
  cubes_anc = new Cube[nbCubes];
  murs = new Mur[nbMurs];
  nbTetrahedrons = (int)(fft.specSize()*specHi2);
  // println(fft.specSize());
  tetrahedrons = new Tetrahedron[nbTetrahedrons];
  
  //generate pairs of objects.
  for (int i = 0; i < nbCubes; i++) {
    float x = random(0, width/2-70);
    float y = random(0, height-GUIHeight);
    float z = random(startingZ, maxZ);

    float rotX = random(0, PI);
    float rotY = random(0,PI);
    float rotZ = random(0, PI);
  cubes_env[i] = new Cube(x,y,z,rotX,rotY,rotZ); 
  cubes_anc[i]= new Cube(width-x,y,z,rotX,PI-rotY,PI-rotZ);
  }
  for (int i = 0; i < nbTetrahedrons; i++) {
    tetrahedrons[i] = new Tetrahedron();
  }
  
  //walls left
  for (int i = 0; i < nbMurs; i+=6) {
   murs[i] = new Mur(0, (height-GUIHeight)/2, 10, height-GUIHeight); 
  }
  //walls right
  for (int i = 1; i < nbMurs; i+=6) {
   murs[i] = new Mur(width, (height-GUIHeight)/2, 10, height-GUIHeight); 
  }
  //walls bottom left
  for (int i = 2; i < nbMurs; i+=6) {
   murs[i] = new Mur(width/4, height-GUIHeight, width/2, 10); 
  }
    //walls bottom right
  for (int i = 3; i < nbMurs; i+=6) {
   murs[i] = new Mur(width*3/4, height-GUIHeight, width/2, 10); 
  } 
  //walls top left
  for (int i = 4; i < nbMurs; i+=6) {
   murs[i] = new Mur(width/4, 0, width/2, 10); 
  }
  //walls top right
  for (int i = 5; i < nbMurs; i+=6) {
   murs[i] = new Mur(width*3/4, 0, width/2, 10); 
  }
  label = createFont("HelveticaNeue", 20);
  textBlack = createFont("HelveticaNeue-Bold", 20);
  titleBlack= createFont("HelveticaNeue-Bold", 26);
  background(0);
  //start the music, repeat
  song.play();
}

void draw()
{ 
  fft_song.forward(song.mix);
  fft.forward(envSound.mix);
  
  oldScoreLow1 = scoreLow1;
  oldScoreMid1 = scoreMid1;
  oldScoreHi1 = scoreHi1;
  
  oldScoreLow2 = scoreLow2;
  oldScoreMid2 = scoreMid2;
  oldScoreHi2 = scoreHi2;

  scoreLow1 = 0;
  scoreMid1 = 0;
  scoreHi1 = 0;

  scoreLow2 = 0;
  scoreMid2 = 0;
  scoreHi2 = 0;

  //env
  for(int i = 0; i < fft.specSize()*specLow1; i++)
  {
    scoreLow1 += fft.getBand(i);
  }
  for(int i = (int)(fft.specSize()*specLow1); i < fft_song.specSize()*specMid1; i++)
  {
    scoreMid1 += fft.getBand(i);
  }
  for(int i = (int)(fft.specSize()*specMid1); i < fft.specSize()*specHi1; i++)
  {
    scoreHi1 += fft.getBand(i);
  }
  
  //music
  for(int i = 0; i < fft_song.specSize()*specLow2; i++)
  {
    scoreLow2 += fft_song.getBand(i);
  }
  for(int i = (int)(fft_song.specSize()*specLow2); i < fft_song.specSize()*specMid2; i++)
  {
    scoreMid2 += fft_song.getBand(i);
  }
  for(int i = (int)(fft_song.specSize()*specMid2); i < fft_song.specSize()*specHi2; i++)
  {
    scoreHi2 += fft_song.getBand(i);
  }
  
  //for environment sound
  if (oldScoreLow1 > scoreLow1) {
    scoreLow1 = oldScoreLow1 - scoreDecreaseRate;
  }
  
  if (oldScoreMid1 > scoreMid1) {
    scoreMid1 = oldScoreMid1 - scoreDecreaseRate;
  }
  
  if (oldScoreHi1 > scoreHi1) {
    scoreHi1 = oldScoreHi1 - scoreDecreaseRate;
  }
  //for music 
  if (oldScoreLow2 > scoreLow2) {
    scoreLow2 = oldScoreLow2 - scoreDecreaseRate;
  }
  
  if (oldScoreMid2 > scoreMid2) {
    scoreMid2 = oldScoreMid2 - scoreDecreaseRate;
  }
  
  if (oldScoreHi2 > scoreHi2) {
    scoreHi2 = oldScoreHi2 - scoreDecreaseRate;
  }
  
  float scoreGlobal_music = 0.66*scoreLow2 + 0.8*scoreMid2 + 1*scoreHi2;
  float scoreGlobal = 0.66*scoreLow1 + 0.8*scoreMid1 + 1*scoreHi1;

  background(scoreLow1/100, scoreMid1/100, scoreHi1/100);
    //generate tetrahedrons
    for(int i=0;i<nbTetrahedrons;i++){
      float bandValue_music = fft_song.getBand(i);
      tetrahedrons[i].display(scoreLow2, scoreMid2, scoreHi2, bandValue_music, scoreGlobal_music);
    }
    //generate cubes on both sides
    for(int i = 0; i < nbCubes; i++)
    {
    float bandValue = fft.getBand(i); 
    // The color is represented as: red for bass, green for medium sounds and blue for high.
    float next_x = random(0,width/2-70);
    float next_y = random(0, height-GUIHeight);
    cubes_env[i].display(scoreLow1, scoreMid1, scoreHi1, bandValue, scoreGlobal,false,next_x,next_y);
    if(i%5==0)
      {
        cubes_anc[i].display(scoreLow1, scoreMid1, scoreHi1, bandValue, scoreGlobal,true,width-next_x,next_y);
      }
    }

  float previousBandValue = fft.getBand(0);
  // println(previousBandValue);
  
  //Distance between each line point, negative because on the z dimension
  float dist = -30;
  //Multiply the height by this constant
  float heightMult_left = 2;
  float heightMult_right = heightMult_left/dim_color;

  strokeWeight(1);
  stroke(255);
  line(width/2,0,width/2,height-GUIHeight);
  for(int i = 1; i < fft.specSize(); i++)
  {
    //float bandValue = fft.getBand(i)*(1 + (i/50));
    float bandValue = fft.getBand(i)*(1+(i/50));
    stroke(100+scoreLow1, 100+scoreMid1, 100+scoreHi1, 255-i);
    strokeWeight(1 + (scoreGlobal/70));
    //lower left line
    line(0, height-GUIHeight-(previousBandValue*heightMult_left), dist*(i-1), 0, height-GUIHeight-(bandValue*heightMult_left), dist*i); 
    line((previousBandValue*heightMult_left), height-GUIHeight, dist*(i-1), (bandValue*heightMult_left), height-GUIHeight, dist*i);
    line(0, height-GUIHeight-(previousBandValue*heightMult_left), dist*(i-1), (bandValue*heightMult_left), height-GUIHeight, dist*i); 
    
    //upper left line
    line(0, (previousBandValue*heightMult_left), dist*(i-1), 0, (bandValue*heightMult_left), dist*i);
    line((previousBandValue*heightMult_left), 0, dist*(i-1), (bandValue*heightMult_left), 0, dist*i);
    line(0, (previousBandValue*heightMult_left), dist*(i-1), (bandValue*heightMult_left), 0, dist*i);
    
    //lower  right line
    line(width, height-GUIHeight-(previousBandValue*heightMult_right), dist*(i-1), width, height-GUIHeight-(bandValue*heightMult_right), dist*i); 
    line(width - (previousBandValue*heightMult_right), height-GUIHeight, dist*(i-1), width - (bandValue*heightMult_right), height-GUIHeight, dist*i);
    line(width , height-GUIHeight-(previousBandValue*heightMult_right), dist*(i-1), width - (bandValue*heightMult_right), height-GUIHeight, dist*i); 
    
    //upper right line
    line(width, (previousBandValue*heightMult_right), dist*(i-1), width, (bandValue*heightMult_right), dist*i);
    line(width - (previousBandValue*heightMult_right), 0, dist*(i-1), width - (bandValue*heightMult_right), 0, dist*i);
    line(width, (previousBandValue*heightMult_right), dist*(i-1), width - (bandValue*heightMult_right), 0, dist*i);
    
    line(width/2,0, dist*(i-1),width/2, 0, dist*i);
    line(width/2,height-GUIHeight, dist*(i-1),width/2, height-GUIHeight, dist*i);
    previousBandValue = bandValue;
  }
  
    for(int i = 0; i < nbMurs; i++)
  {
    // * float intensity = fft.getBand(i%((int)(fft.specSize()*specHi)));
    float intensity = fft.getBand(i);
    // println(intensity);
    float intensity_music = fft_song.getBand(i);
    if(i%6==3||i%6==5||i%6==1){
    murs[i].display((scoreLow1/dim_color)+scoreLow2, (scoreMid1/dim_color)+scoreMid2, (scoreHi1/dim_color)+scoreHi2, (intensity/dim_color)+intensity_music, (scoreGlobal/dim_color)+scoreGlobal_music);}
    else{
    murs[i].display(scoreLow1, scoreMid1, scoreHi1, intensity, scoreGlobal);      
    }
  }
  // 3d code above
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  // 2d code following
  fill(0,0,0,150);
  rect(0,height-GUIHeight,width, height);
  fill(0,0);
  stroke(255,255,255,255);
  strokeWeight(1);
  // rect(300,height-130,width/2-400,50);
  //draw realtime kws result
  for(int i=0;i<199;i++){
    stroke(0,255,0,255);
    line(300+i*kws_line_width,height-80-50*window_score.get(i),300+(i+1)*kws_line_width,height-80-50*window_score.get(i+1));
    stroke(0,0,255,255);
    line(300+i*kws_line_width,height-80-50*keyword_score.get(i),300+(i+1)*kws_line_width,height-80-50*keyword_score.get(i+1));
  }

  //static UI element
  textSize(28);	
  textFont(titleBlack);
  fill(255);
  text("Environment", 400, 60);
  text("What You Hear", 1100, 60);
  textFont(label);
  text("SCENARIO",90,height-150);
  text("EVENT",90,height-100);
  text("MUSIC",90,height-50);
  textFont(textBlack);
  text(scenario,300,height-150);
  text(event,300,height-100);
  text(music,300,height-50);

  hint(ENABLE_DEPTH_TEST);
}

class Tetrahedron{
  float x,y,z;
  float rotX, rotY, rotZ;
  float sumRotX,sumRotY,sumRotZ;
  //Generate tetrahedrons with ramdom position
  Tetrahedron(){
    x = random(width/2+90,width);
    y = random(0, height-GUIHeight);
    z = random(startingZ, maxZ);
    rotX = random(0, 1);
    rotY = random(0, 1);
    rotZ = random(0, 1);
  }
  //visualize music feature
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
    color displayColor = color(scoreLow*0.67, scoreMid*0.8, scoreHi*0.8, intensity*5+30);
    fill(displayColor, 255);

    // color strokeColor = color(255, 150-(20*intensity));
    // color strokeColor = color(255, 150-(20*intensity));
    // color strokeColor = color(255, 0);
    // stroke(strokeColor);
    strokeWeight(1 + (scoreGlobal/300));
    
    //Create a transformation matrix to perform rotations, enlargements
    pushMatrix();
    translate(x, y, z);
    sumRotX += intensity*(rotX/1000);
    sumRotY += intensity*(rotY/1000);
    sumRotZ += intensity*(rotZ/1000);

    rotateX(sumRotX);
    rotateY(sumRotY);
    rotateZ(sumRotZ);
    
    // box(100+(intensity/2));
    float length = 100+intensity/2;
    beginShape(TRIANGLES);
    vertex(length, 0, -length/1.414);
    vertex(-length,0,-length/1.414);
    vertex(0, length, length/1.414);
    endShape();
    beginShape(TRIANGLES);
    vertex(length, 0, -length/1.414);
    vertex(-length,0,-length/1.414);
    vertex(0, -length, length/1.414); 
    endShape();
    beginShape(TRIANGLES);
    vertex(length, 0, -length/1.414);
    vertex(0, length, length/1.414);
    vertex(0, -length, length/1.414); 
    endShape();
    beginShape(TRIANGLES);
    vertex(-length,0,-length/1.414);
    vertex(0, length, length/1.414);
    vertex(0, -length, length/1.414); 
    endShape();
    
    //Application of the matrix
    popMatrix();

    //TBC, need to be paused when needed
    z+= (1+(intensity/5)+(pow((scoreGlobal/150), 2)));
    
    //Replace the box at the back when it is no longer visible
    //how to control the latest object?
    if (z >= maxZ) {
      x = random(width/2+90,width);
      y = random(0, height-GUIHeight);
      z = startingZ;
    }

  }
}

class Cube {

  float x, y, z;
  float rotX, rotY, rotZ;
  float sumRotX, sumRotY, sumRotZ;
  
  Cube(float loc_x,float loc_y,float loc_z,float rot_x,float rot_y,float rot_z) {
    x = loc_x;
    y = loc_y;
    z = loc_z;
    rotX = rot_x;
    rotY = rot_y;
    rotZ = rot_z;  
  }
  
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal, boolean dim, float next_x,float next_y) {
    color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, intensity*5);
    //the 'after' cubes is always dim but the speed remain the same to creat the sense of realtime processing
    if(dim==false){
    fill(displayColor, 255);
    // fill(displayColor, 20*intensity);
    } 
    else{
    fill(displayColor, 255/dim_color);
    }
    // color strokeColor = color(255, 0);
    color strokeColor = color(255, 150-(20*intensity));
    stroke(strokeColor);
    strokeWeight(1 + (scoreGlobal/300));
    
    //Create a transformation matrix to perform rotations, enlargements
    pushMatrix();
    translate(x, y, z);
    
    // Calculation of the rotation according to the intensity for the cube
    if(dim==false){
    sumRotX += intensity*(rotX/1000);
    sumRotY += intensity*(rotY/1000);
    sumRotZ += intensity*(rotZ/1000);}
    else{
    sumRotX += intensity*(rotX/1000);
    sumRotY -= intensity*((PI-rotY)/1000);
    sumRotZ -= intensity*((PI-rotZ)/1000);  
    }

    rotateX(sumRotX);
    rotateY(sumRotY);
    rotateZ(sumRotZ);
    
    //variable size according to the intensity for the cube
    //might reduce the box size to emphasize music proportion
    box(100+(intensity/2));
    
    //Application of the matrix
    popMatrix();
    
    z+= (1+(intensity/5)+(pow((scoreGlobal/150), 2)));
    
    if (z >= maxZ) {
      x = next_x;
      y = next_y;
      z = startingZ;
    }
    
  }
}

class Mur {
  float startingZ = -10000;
  float maxZ = 50;

  float x, y, z;
  float sizeX, sizeY;

  Mur(float x, float y, float sizeX, float sizeY) {
    //Make the line appear at the specified place
    this.x = x;
    this.y = y;
    //Random depth
    this.z = random(startingZ, maxZ);  
    
    this.sizeX = sizeX;
    this.sizeY = sizeY;
  }
  
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
    color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, scoreGlobal);
    
    //Make lines disappear in the distance to give an illusion of fog
    fill(displayColor, ((scoreGlobal-5)/1000)*(255+(z/25)));
    noStroke();
  
    pushMatrix();
    translate(x, y, z);

    if (intensity > 100) intensity = 100;
    scale(sizeX*(intensity/100), sizeY*(intensity/100), 20);
    
    box(1);
    popMatrix();
    
    displayColor = color(scoreLow*0.5, scoreMid*0.5, scoreHi*0.5, scoreGlobal);
    fill(displayColor, (scoreGlobal/5000)*(255+(z/25)));
    
    pushMatrix();
    translate(x, y, z);
    scale(sizeX, sizeY, 10);
    
    box(1);
    popMatrix();
    
    z+= (pow((scoreGlobal/150), 2));
    if (z >= maxZ) {
      z = startingZ;  
    }
  }
}


void serialEvent(Serial port) {
  String input = port.readString(); 
  // System.out.println(input);
  float window;
  float kwsres;
  if (input != null) {
    try{
      // println( "Receiving:" + input);
    float[] vals = float(split(input, ","));
    window = vals[0];
    window_score.add(window);
    window_score.remove(0);
    kwsres = vals[1]; 
    keyword_score.add(kwsres);
    keyword_score.remove(0);
    // print(keyword_score);

    for(int k=0;k<6;k++){
      readings.add(vals[k]);
    }
    // readings.removeRange(0,6);
    readings.subList(0, 6).clear();
    
    // Increase display time of keyword spotting result
    if(window>0.5 && kwsres>0.7){ 
      kws=true;
      event = "Name Called";
    }
    if(kws==true){
      kws_count++;
      if(kws_count>20){
        kws=false;
        kws_count=0;
        event = "-";
      }
    }

    float sum_home = 0;
    float sum_commute = 0;
    float sum_terminal = 0;
    float sum_flight = 0;
    for(int i=2;i<48;i+=6){
      sum_home += readings.get(i);
    }
    for(int i=3;i<48;i+=6){
      sum_commute += readings.get(i);
    }
    for(int i=4;i<48;i+=6){
      sum_terminal += readings.get(i);
    }
    for(int i=5;i<48;i+=6){
      sum_flight += readings.get(i);
    }
    float maxChancei = 0;
    float maxValue = Math.max(Math.max(Math.max(sum_home,sum_commute),sum_terminal),sum_flight);
    if(sum_home == maxValue){
      scenario = scenarios.get(1);
      dim_color = 1;
    }
    else if(sum_commute == maxValue){
      scenario = scenarios.get(2);
      dim_color = 2;
    }
    else if(sum_terminal == maxValue){
      scenario = scenarios.get(3);
      dim_color = 6;
    }
    else{
      scenario = scenarios.get(4);
      dim_color = 3;
    }
    }catch (Exception e) {
      System.out.println("Serial error");
    }
    
  }
// Send a capital "A" out the serial port
// myPortRead.write(65);
}


//GUI event & cmd
//start 
public void PLAY(int theValue) {
  // System.out.println("button_play");
  try{
  myPortRead = new Serial(this,"/dev/tty.usbmodem316B336930381", 9600);
  // myPortRead = new Serial(this,"COM7",115200);
  myPortRead.bufferUntil('\n');
  }catch (Exception e) {
    System.out.println("Serial already opened");
  }
  // //Start transmission, Send this cmd each time establish connection.
  myPortRead.write((byte)0x0A);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    if(theEvent.getController()==dropList1){
      // System.out.println((byte)dropList1.getId());
      myPortRead.write(new byte[]{(byte)0x0B,(byte)dropList1.getValue()});
    }
    if(theEvent.getController()==dropList2){
      // System.out.println((byte)dropList2.getId());
      myPortRead.write(new byte[]{(byte)0x0D,(byte)(dropList2.getValue()+1)});
    }
  }
}


// void keyPressed()
// {
//   // Monitor computer audio output
//   if ( key == 'm' || key == 'M' )
//   {
//     if ( envSound.isMonitoring() )
//     {
//       envSound.disableMonitoring();
//       System.out.println("disableMonitoring");  
//     }
//     else
//     {
//       envSound.enableMonitoring();
//       System.out.println("enableMonitoring"); 
//     }
//   }
// }

  
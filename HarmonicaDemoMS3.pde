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
Featrue feature;
//Feature raw data.
static float[] feature_Thomas = {-3.82113552e+00,  2.17640087e-01,  5.37701666e-01, -4.69913691e-01,
                                9.83887970e-01, -2.31668544e+00, -1.13529539e+00,  6.90267920e-01,
                                8.03675532e-01, -5.41356325e-01,  3.13699293e+00,  2.27434337e-01,
                                1.71011686e-03,  9.03369188e-01,  7.18180835e-03,  7.75580466e-01,
                                1.70953071e+00, -3.58946979e-01,  3.90498090e+00,  1.99390113e+00,
                              -2.23997712e+00, -7.77315617e-01,  5.59331119e-01, -6.58366382e-02,
                              -1.36148393e+00, -6.02902293e-01,  1.12602115e-02, -2.16998649e+00,
                              -3.35035324e-01, -4.68856752e-01, -1.26728976e+00,  1.35438633e+00,
                                3.18176091e-01, -1.27243710e+00,  1.47726011e+00, -1.10080934e+00,
                              -1.22888803e+00, -1.26714182e+00, -3.08140421e+00, -1.13069522e+00,
                              -7.26102293e-01, -1.06968594e+00, -7.51522370e-03, -5.12525320e-01,
                                4.51349914e-01,  5.35268545e+00,  1.03623497e+00, -6.27379513e+00,
                                1.27300918e+00,  6.55936897e-01, -5.61717224e+00,  1.04115635e-01,
                                1.50275600e+00, -7.75683463e-01, -2.07459047e-01, -6.27844095e-01,
                              -9.52919841e-01, -1.16651997e-01,  2.03974873e-01,  4.49487400e+00,
                                2.91928947e-01, -2.23056823e-01, -1.13252699e-02, -6.18340492e-01};
static float[] feature_Jerry = {4.6493635e+00,  3.5840371e-01, -9.7396880e-01,  2.0819455e-03,
                                7.6030320e-01, -1.6374477e+00,  1.0086306e+00, -6.5794301e-01,
                                8.1518710e-01, -5.3855413e-01, -2.0134284e-01,  1.6235450e-01,
                              -2.1026304e-01,  2.3911731e+00,  2.4526775e-02,  8.8343650e-01,
                              -1.1924015e+00, -3.5894698e-01,  7.1477664e-01, -7.8213468e-02,
                              -1.3369688e+00, -9.0422928e-01,  1.7792672e+00, -6.5836638e-02,
                              -1.3614839e+00, -1.4329690e+00, -1.1712627e+00, -1.9623972e-01,
                                4.6591228e-01, -4.6885675e-01, -1.4460368e+00,  2.2534153e+00,
                                3.7880510e-01, -9.1537070e-01,  8.8030797e-01, -2.1063604e+00,
                              -2.3077056e+00, -7.6387954e-01, -5.7705343e-02, -1.0514442e+00,
                                1.7206559e+00, -1.0786362e+00, -7.5152237e-03, -5.0666623e-02,
                                3.8816720e-01,  2.5207734e+00, -1.0648978e+00, -3.8740237e+00,
                                4.6426001e-01,  8.8601297e-01, -5.3548379e+00,  4.8539314e-01,
                                1.5470973e+00,  1.5378599e+00, -5.0416011e-01,  8.4460354e-01,
                                3.0405396e-01, -3.7612802e-01,  8.3436787e-01,  3.4978056e+00,
                              -1.2119911e+00, -2.2305682e-01, -1.1325270e-02,  1.6835867e+00};
static float[] feature_Yes = {-1.3797158e+00,  2.5779480e-01,  2.5181885e+00, -1.4836818e-01,
                              3.2345462e-01, -1.3219315e+00, -4.0195164e-01, -2.3538917e-02,
                              8.4734786e-01, -5.3855413e-01,  1.7294096e+00,  1.3199690e-01,
                            -2.2161186e+00, -1.8098888e-01,  6.4991593e-01, -1.4967570e+00,
                            -1.5441778e+00, -3.5894698e-01,  3.4922171e+00,  1.1222233e+00,
                            -1.6749321e+00, -1.0596371e+00,  3.8874030e-01, -6.5836638e-02,
                            -1.3614839e+00,  1.5614754e-01, -1.0570571e-02, -9.9684483e-01,
                              1.0533412e+00, -4.6885675e-01, -1.5067677e+00,  2.1159091e+00,
                              4.8726767e-01, -1.8987705e+00,  7.8170502e-01, -7.3176938e-01,
                            -3.8680914e-01, -1.3890947e+00, -2.0589571e+00, -1.2072425e+00,
                            -3.8408780e-01, -5.1359367e-01, -7.5152237e-03, -1.2956196e-01,
                              4.3037578e-01, -1.0690426e+00, -2.3413624e-01, -1.0410332e+01,
                              9.0880251e-01,  4.9180669e-01, -5.3128891e+00, -1.4713532e+00,
                              3.8732806e-01, -3.0134076e-01, -1.4461997e+00, -2.9035872e-01,
                            -1.1084658e+00, -8.8740438e-01, -7.4731761e-01,  2.1551411e+00,
                              5.0708449e-01, -2.2305682e-01, -1.1325270e-02,  9.8019111e-01};
static float[] feature_Happy = {0.42170084,  0.3584037 ,  0.08360841, -0.16676992, -1.2268803 ,
                              -2.8253672 ,  0.8887602 , -1.103819  ,  0.7277701 , -0.53855413,
                                0.8976887 ,  0.16868168,  0.03282892,  1.4195081 ,  0.29310435,
                              -0.1181467 , -0.57597655, -0.35894698,  1.794949  ,  0.55172706,
                              -0.58994657, -1.3955526 ,  3.7693212 , -0.06583664, -1.3614839 ,
                              -0.5674727 , -0.59218395,  0.02128511,  1.1084999 , -0.3089571 ,
                              -0.98516464,  2.281052  ,  0.27090615, -1.9759535 , -0.16273174,
                              -1.7315102 , -1.4620981 ,  0.02519515, -0.02337569, -1.3980889 ,
                                2.7199287 , -1.0648677 , -0.00751522,  0.7191019 ,  0.4513499 ,
                                3.3637338 , -1.2802292 , -7.1089616 , -0.04958293, -0.3141895 ,
                              -4.8275084 , -0.0113067 ,  1.5462092 , -0.39708143, -1.1252345 ,
                              -2.0758996 ,  1.3229914 , -0.6686409 ,  1.1433667 ,  1.1530536 ,
                              -0.1974689 , -0.22305682, -0.01132527,  2.9872386};
static float[] feature_Nihao = {-2.6747377 ,  0.3584037 , -0.56029314,  0.04731755, -1.1487097 ,
                              -2.596256  , -0.3072869 , -0.587028  ,  0.7602682 , -0.53855413,
                                0.28637236,  0.19667463, -1.3996595 ,  0.29113758, -0.00744061,
                              -2.2203681 ,  1.652756  , -0.35894698,  4.3593745 , -0.6448126 ,
                              -0.99357414, -1.4549747 , -1.5788504 , -0.06583664, -1.3614839 ,
                              -0.93814945, -0.01057057, -0.9880319 ,  0.94195163, -0.40565628,
                              -1.2850584 ,  1.2198042 ,  0.37443292, -1.4082866 ,  1.1521134 ,
                              -2.956818  , -0.14525396,  0.03481466, -0.08192134, -0.8577359 ,
                              -3.4658957 , -1.2491686 , -0.00751522,  0.7000283 ,  0.4230752 ,
                              -1.1387675 ,  0.17739965, -6.8970413 ,  1.2219387 , -0.04056889,
                              -5.4228063 ,  0.01532549,  1.5932343 ,  0.8015448 , -0.9888534 ,
                              -0.08623058,  1.9773161 , -0.768303  ,  0.20238361,  2.9529128 ,
                                0.8948855 , -0.22305682, -0.01132527,  1.5801599};


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
//Gain dictionary
HashMap gainDict = new HashMap(); 
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

//starting position of subes
float startingZ = -10000;
float maxZ = 1000;

//transparancy for dim color
float dim_color = 2;

void setup()
{
  fullScreen(P3D);
  //size(1000,1000,P3D);
  kws = false;
  scenario = "-";
  event = "-";
  music = "Play";
  minim = new Minim(this);
  envSound = minim.getLineIn(minim.MONO,8192,44100);
  song = minim.loadFile("RainRabbit.mp3"); 
  fft = new FFT(envSound.bufferSize(), envSound.sampleRate());
  //sampleRate = 44100;
  fft_song = new FFT(song.bufferSize(), song.sampleRate());

  //list length
  for(int i=0;i<48;i++){
    readings.add(0.0);
  }
  //scenario list
  scenarios.add("Home");
  scenarios.add("Terminal");
  scenarios.add("Flight");
  scenarios.add("Commute");

  // Gain cmd dictionary
  gainDict.put(20, (byte)0x00);
  gainDict.put(21, (byte)0x01);
  gainDict.put(22, (byte)0x02);
  gainDict.put(23, (byte)0x03);
  gainDict.put(24, (byte)0x04);
  gainDict.put(25, (byte)0x05);
  gainDict.put(26, (byte)0x06);
  gainDict.put(27, (byte)0x07);
  gainDict.put(28, (byte)0x08);

  // read input TBC 
  // myPortRead = new Serial(this,"/dev/tty.usbmodem316B336930381", 9600);
  // myport = new Serial(this,Serial.list()[1],115200);
  // myport = new Serial(this,"COM7",115200);
  // List all the available serial ports:
  printArray(Serial.list());
  

  //GUI elements
  cp5 = new ControlP5(this);
  cp5.addButton("button_play")
    // .setValue(0)
    .setPosition(width/2,height-150)
    .setSize(50,50)
    ;

  cp5.addButton("button_pause")
    // .setValue(10)
    .setPosition(width/2+70,height-150)
    .setSize(50,50)
    ;

  dropList1 = cp5.addDropdownList("gain")
    .setPosition(width/2+150, height-150)
    .setSize(200,200);         
  customizeGain(dropList1); 

  dropList2 = cp5.addDropdownList("keyWord")
          .setPosition(width/2+400, height-150)
          .setSize(200,200);
  customizeWord(dropList2);

  //add more objects as music input
  nbCubes = (int)(fft.specSize()*specHi1);
  cubes_env = new Cube[nbCubes];
  cubes_anc = new Cube[nbCubes];
  murs = new Mur[nbMurs];
  nbTetrahedrons = (int)(fft.specSize()*specHi2);
  println(fft.specSize());
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

public class Featrue
{
  float[] data;
  Featrue(float[] data)
  {
    this.data = data;
  }
  byte[] get_bytes()
  {
    ByteBuffer byteBuffer = ByteBuffer.allocate(257);
    byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
    byteBuffer.put((byte)0x0D);
    for (int i = 0; i != 64; i++)
    {
      byteBuffer.putFloat(1 + i * 4, this.data[i]);
    }
    return byteBuffer.array();
  }
  void send(Serial p){
    p.write(this.get_bytes());
  }
}

void customizeGain(DropdownList ddl) {
  ddl.setBackgroundColor(color(0));
  ddl.setItemHeight(30);
  ddl.setBarHeight(15);
   for (int i=0;i<9;i++) {
    ddl.addItem("0x0"+i, i+20);
    }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void customizeWord(DropdownList ddl) {
  ddl.setBackgroundColor(color(0));
  ddl.setItemHeight(30);
  ddl.setBarHeight(15);
  ddl.addItem("Cici", 50);
  ddl.addItem("Jerry",51);
  ddl.addItem("Thomas", 52); 
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void serialEvent(Serial port) {
  String input = port.readString(); 
  System.out.println(input);
  float window;
  float kwsres;
  if (input != null) {
    println( "Receiving:" + input);
    float[] vals = float(split(input, ","));
    window = vals[0];
    kwsres = vals[1]; 

    for(int k=0;k<6;k++){
      readings.add(vals[k]);
    }
    // readings.removeRange(0,6);
    readings.subList(0, 6).clear();
    
    // Increase display time of keyword spotting result
    if(window>0.5 && kwsres>0.5){ 
      kws=true;
      event = "Name Called";
    }
    if(kws==true){
      kws_count++;
      if(kws_count>100){
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
  }
// Send a capital "A" out the serial port
// myPortRead.write(65);
}


//GUI event & cmd
//start 
public void button_play(int theValue) {
  System.out.println("button_play");
  try{
  myPortRead = new Serial(this,"/dev/tty.usbmodem316B336930381", 9600);
  myPortRead.bufferUntil('\n');
  }catch (Exception e) {
    System.out.println("Serial already opened");
  }
  // //Start transmission, Send this cmd each time establish connection.
  myPortRead.write((byte)0x0A);
}
//stop
public void button_pause(int theValue) {
  println("button_pause");
  //Stop transmission
   myPortRead.write((byte)0x0C);
}
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    // println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    if(theEvent.getController()==dropList1){
      float value = theEvent.getController().getValue();
    println("event from controller : "+value+" from "+theEvent.getController());
    // myport.write(new byte[]{(byte)0x0B,(byte)0x05});
    myPortRead.write(new byte[]{(byte)0x0B,(byte)(gainDict.get(value))});
    }
    if(theEvent.getController()==dropList2){

    }
  }
}


void keyPressed()
{
  // Monitor computer audio output
  if ( key == 'm' || key == 'M' )
  {
    if ( envSound.isMonitoring() )
    {
      envSound.disableMonitoring();
      System.out.println("disableMonitoring");  
    }
    else
    {
      envSound.enableMonitoring();
      System.out.println("enableMonitoring"); 
    }
  }
  // Set feature to compare. (Select formt the list)
   if ( key == 'f' || key == 'F' ){
   feature = new Featrue(feature_nick);  //Prepare data to send.
   feature.send(myPortRead); //send cmd 0x0D and feature data.
   }
}

  

import processing.serial.*;

Serial myport;

//Feature raw data.
static float[] feature_nick = {1.0, 0.09482261, 0.71196096, 0.33469795, 0.00954271,
                               0.42610248, 0.64153486, 0.94590519, 0.54915531, 0.85789977,
                               0.40761014, 0.8666355, 0.0343089, 0.16187272, 0.84312321,
                               0.22265605, 0.79967658, 0.19404002, 0.46965828, 0.21927928,
                               0.67442555, 0.92260194, 0.8119627, 0.72632723, 0.19444464,
                               0.6557695, 0.94408782, 0.73384134, 0.12572378, 0.52393848,
                               0.00530087, 0.7705692, 0.71546082, 0.79894306, 0.1434266,
                               0.02392478, 0.02827022, 0.89833059, 0.70119033, 0.2427583,
                               0.80574012, 0.64495794, 0.14371673, 0.10288936, 0.1608715,
                               0.48728477, 0.95233288, 0.3109348, 0.0508005, 0.55836322,
                               0.28769407, 0.30631243, 0.21994837, 0.52510142, 0.20503161,
                               0.92725837, 0.88805662, 0.91923468, 0.92248686, 0.93615086,
                               0.91026605, 0.76172873, 0.09552055, 0.05058804};

Featrue feature;


void setup()
{
  size(500, 500);
   
   myport = new Serial(this,"COM7",115200);
   
   //Stop transmission
   myport.write((byte)0x0C);
   
   //Audio card mode. NEVER CALL THIS!
   myport.write((byte)0x0E);
   
   //Start transmission, Send this cmd each time establish connection.
   myport.write((byte)0x0A);
   
   //Set gain value. The second value is gain value.(0x00 - 0x08)
   myport.write(new byte[]{(byte)0x0B,(byte)0x05});
   
   //Set feature to compare. (Select formt the list)
   feature = new Featrue(feature_nick);  //Prepare data to send.
   feature.send(myport); //send cmd 0x0D and feature data.
}


void draw()
{
  background(255);
}
import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;
OscP5 oscP5;
NetAddress myRemoteLocation;

final int dmxChNum = 64;

int dmxChannel[] = new int[dmxChNum];

int colorR;
int colorG;
int colorB;
int colorW;
int enableOutputDmx = 0;
int autoAnim = 0;
int autoAnimCount = 0;
int autoAnimCountMax = 150;
int animChannel = 1;
int animPattern = 0;
int animPatternNum = 9;
int guiPosX = 1000;
int guiPosY = 100;
int padWidth = 640;
int padHeight = 640;
int tsunoSimPosX = padWidth+20;
int tsunoSimPosY = 100;

float userSpeed = 10;
float userBrightness = 10;
float userHue = 0;
int userFramerate = 15;

boolean testToggle = false;

void setup() {
  
  size(1280, 720);
  frameRate(15);

  cp5 = new ControlP5(this);

  // UI Parts
  int p=0;
  //cp5.addButton("colorA").setValue(0).setPosition(10,30*p).setSize(200,19); p++;
  cp5.addSlider("colorR").setValue(0).setRange(0,255).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;
  cp5.addSlider("colorG").setValue(0).setRange(0,255).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;
  cp5.addSlider("colorB").setValue(0).setRange(0,255).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;
  cp5.addSlider("colorW").setValue(0).setRange(0,255).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;     
  cp5.addSlider("userSpeed").setValue(0).setRange(0,255).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;
  cp5.addSlider("userBrightness").setValue(0).setRange(0,255).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;
  cp5.addSlider("userHue").setValue(0).setRange(0,255).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;     
  cp5.addSlider("userFramerate").setValue(15).setRange(1,60).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;     
  cp5.addToggle("enableOutputDmx").setValue(1).setPosition(guiPosX,guiPosY+30*p).setSize(200,15); p++;     
  cp5.addToggle("autoAnim").setValue(0).setPosition(guiPosX,guiPosY+30*p).setSize(200, 15); p++;     
  cp5.addButton("testDmx").setValue(0).setPosition(guiPosX,guiPosY+30*p).setSize(200,25); p++;     
  
  oscP5 = new OscP5(this,55553);  //port55553 softpia hoshi server
  //myRemoteLocation = new NetAddress("127.0.0.1",55553);
  myRemoteLocation = new NetAddress("25.10.165.61",55553);
  
  for(int i=0; i<dmxChNum; i++) {
    dmxChannel[i] = 0;
  }
  
}



void draw() {

  frameRate(userFramerate);

  if (autoAnim == 1) {  
    if (frameCount % autoAnimCountMax == 0) {
      animChannel = (animChannel + 1) % animPatternNum;
    }
  }

  //---------------------------------------------------------
  
  background(0,0,0);
  fill(64,64,64);
  rect(padWidth, 0, width, height);
  rect(0, padHeight, width, height);

  // Tower Simurator ------------------------------------------------------
  fill(255,255,255);
  text("Simurator:", tsunoSimPosX, tsunoSimPosY-10);

  for(int h=0; h<2; h++) {
    for(int i=0; i<8; i++) {
       int index = (h*32) + i*4;
       for(int j=0; j<2; j++) {    // same color
        fill(dmxChannel[index],dmxChannel[index+1],dmxChannel[index+2]);
        rect(j*40+tsunoSimPosX + (h*150),(7-i)*30+tsunoSimPosY,30,20);
      }
      
      fill(dmxChannel[index+3],dmxChannel[index+3],dmxChannel[index+3]);
      rect(tsunoSimPosX + (h*150),(7-i)*30+tsunoSimPosY+15, 70, 5);
    }
  }


  // DMX 64 Channel Viewer --------------------------------------------------
  stroke(255,255,255);
  noFill();
  rect(tsunoSimPosX-3, tsunoSimPosY+300-4,100,120);
  rect(tsunoSimPosX-3, tsunoSimPosY+420-4,100,120);
  noStroke();
  
  fill(255,255,255);
  text("DMX Channel View:", tsunoSimPosX, tsunoSimPosY+300-20);
  
  for(int i=0; i<dmxChNum; i++) {
    fill(dmxChannel[i], dmxChannel[i], dmxChannel[i]);
    rect(tsunoSimPosX +(i%4*25), i/4*15+tsunoSimPosY+300, 20, 10);
    
    textSize(11);
    fill(255,255,255);
    text(dmxChannel[i], tsunoSimPosX+((i%4)*45)+120, i/4*15+tsunoSimPosY+308);
  }

  // UI -----------------------------------------------------------------
  fill(255,255,255);
  textSize(24);
  text("now pattern: " + animChannel, padWidth+20, 30);
  
  // Program Pattern ----------------------------------------------------
  color c;
  
  switch(animChannel) {
  case 0:
    break;
  case 1:
    for(int i=0; i<dmxChNum; i++) {
      dmxChannel[i] = (i+frameCount)%64*4;
    }
  
    break;
  case 2:
    for(int i=0; i<dmxChNum/4; i++) {
      int index = i*4;
      dmxChannel[index] = (i+frameCount)%64*4;
      dmxChannel[index+1] = (i+frameCount)%64*4;
      dmxChannel[index+2] = (i+frameCount)%64*4;
      dmxChannel[index+3] = 0;
    }
    
    break;
  case 3:
    colorMode(HSB);

    noStroke();
    fill((frameCount*4)%255,128,255);
    rect(0, 0, padWidth, padHeight);
    colorMode(RGB);
    
    c = get(0,0);
  
    for(int i=0; i<dmxChNum/4; i++) {
      int index = i*4;
      dmxChannel[index] = int(red(c));
      dmxChannel[index+1] = int(green(c));
      dmxChannel[index+2] = int(blue(c));
      dmxChannel[index+3] = 0;//int(userBrightness);
    }
    println(int(blue(c)));
    break;
  case 4:
    // all random color
    int speedCount = frameCount;
    if (speedCount % (255 / userSpeed) == 0) {
      for(int i=0; i<dmxChNum; i++) {
        dmxChannel[i] = int(random(255));    
      }
    }
    break;
  case 5:
    {
      colorMode(HSB);
      float h = 0;
    
      noStroke();
      for(int i=0; i<dmxChNum/8; i++) {
        h = 128*sin(((i/4*10)+frameCount)/10.0) + 127;
        fill(h, 128,255);
        rect(0, i*padHeight/8, padWidth, padHeight/8);
      }
      colorMode(RGB);
    
      for(int i=0; i<dmxChNum/4; i++) {
        c = get(0, i*padHeight/8);
        int index = i*4;
        dmxChannel[index] = int(red(c)*255);
        dmxChannel[index+1] = int(green(c));
        dmxChannel[index+2] = int(blue(c));
        dmxChannel[index+3] = int(userBrightness);
      }
    }
    
    //color c = get(0,0);
    
    break;
  case 6:
    // all random tenmetsu
    if (frameCount % 20 ==0 ){ 
      for(int i=0; i<dmxChNum/4; i++) {  
        dmxChannel[i*4] = int(random(255));
        dmxChannel[i*4+1] = int(random(255));
        dmxChannel[i*4+2] = int(random(255));
        dmxChannel[i*4+3] = int(random(128));
      }
    }
    if (frameCount % 20 ==10 ){ 
      for(int i=0; i<dmxChNum; i++) {  
        dmxChannel[i] = 0;
      }
    }
    
    break;

  case 9:
    colorMode(HSB);

    noStroke();
    fill((frameCount*4)%255,128,255);
    rect(0, 0, padWidth, padHeight);
    colorMode(RGB);
    
    c = get(0,0);
  
    for(int i=0; i<dmxChNum/4; i++) {
      int index = i*4;
      dmxChannel[index] = int(red(c));
      dmxChannel[index+1] = int(green(c));
      dmxChannel[index+2] = int(blue(c));
      dmxChannel[index+3] = 0;//int(userBrightness);
    }
    
    if (frameCount % 20 < 10) {
      for(int i=0; i<16; i++) {
        dmxChannel[i] = 0;//int(userBrightness);
      }
    } else if(frameCount % 20 >= 10) {
      for(int i=16; i<32; i++) {
        dmxChannel[i] = 0;//int(userBrightness);
      }
    }
    if (frameCount % 20 < 10) {
      for(int i=32; i<48; i++) {
        dmxChannel[i] = 0;//int(userBrightness);
      }
    } else if(frameCount % 20 >= 10) {
      for(int i=48; i<64; i++) {
        dmxChannel[i] = 0;//int(userBrightness);
      }
    }
    println(int(blue(c)));
    break;

  default:
    break;
  }
  
  sendDmxChannelByOsc();
  
}


void testDmx() {
  int col = 0;
/*  
  if (testToggle) {
    testToggle = false;
    col = 0;
  } else {
    testToggle = true;
    col = 255;
  }
  
  for(int i=0; i<dmxChNum; i++) {
    dmxChannel[i] = col;
  }
  */
  sendDmxChannelByOsc();

  /*
  OscBundle myBundle = new OscBundle();//バンドルを作成
 
  OscMessage myMessage = new OscMessage("/dmx");// /booに送るメッセージを作成
  for(int i=0; i<dmxChNum; i++) {
    myMessage.add(255);
  }
   
  myBundle.add(myMessage);
   
  myMessage.clear();
   
  oscP5.send(myBundle, myRemoteLocation);//送信
  */
}


void sendDmxChannelByOsc() {

  OscBundle myBundle = new OscBundle(); 
  OscMessage myMessage = new OscMessage("/dmx");
  
  for(int i=0; i<dmxChNum; i++) {
    
    int val = dmxChannel[i];
    if (val < 0) {
      val = 0;
    }
    if (val > 255) {
       val = 255;
    }

    myMessage.add(val);
  }
  
  myBundle.add(myMessage);
  myMessage.clear();

  if (enableOutputDmx == 1) { 
    oscP5.send(myBundle, myRemoteLocation);
  }
  
}

void keyPressed() {
  
  // change channel 
  if (keyCode >= '0' && keyCode <= '9') {
    animChannel = keyCode - '0';
  }
    
}


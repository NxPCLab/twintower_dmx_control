import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(640, 480);
  frameRate(15);

  oscP5 = new OscP5(this, 55553);  //port55553 twintower Hoshi server
  myRemoteLocation = new NetAddress("25.10.165.61",55553);
}

void draw() {  
}

void mousePressed() {
  OscBundle myBundle = new OscBundle(); 
  OscMessage myMessage = new OscMessage("/dmx");

  // R,G,B,W x 8 (x2)
  for(int i=0; i<64; i++) {
    myMessage.add(255);
  }   
  myBundle.add(myMessage);
  myMessage.clear();
   
  oscP5.send(myBundle, myRemoteLocation);
}


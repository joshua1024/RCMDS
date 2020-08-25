/////////////////////////add interface elements here
Button myButton;
Slider aSl;
Slider bSl;
//////////////////////
float batVolt=0.0;
boolean enabled=false;
////////////////////////add variables here
float a=0;
float b=0;
boolean g=false;
void setup() {
  size(1920, 1080);
  rcmdsSetup();
  myButton=new Button(1700, 800, 400, color(0, 100, 0), color(0, 255, 0), null, ' ', true, false, "go");
  aSl=new   Slider(100, 600, 500, 50, -1, 1, color(255, 0, 0), color(255), null, 0, 0, .001, 0, false, false);
  bSl=new   Slider(200, 600, 500, 50, -1, 1, color(0, 0, 255), color(255), null, 0, 0, .001, 0, false, false);
}
void draw() {
  background(0);
  runWifiSettingsChanger();
  enabled=enableSwitch.run(enabled);
  /////////////////////////////////////add UI here
  a=aSl.run(a);
  b=bSl.run(b);
  g=myButton.run();
  String[] msg={"battery voltage", "ping", "go", "a", "b"};
  String[] data={str(batVolt), str(wifiPing), str(g), str(a), str(b)};
  dispTelem(msg, data, width/2, height*2/3, width/4, height*2/3, 20);

  sendWifiData(true);
  endOfDraw();
}
void WifiDataToRecv() {
  batVolt=recvFl();
  ////////////////////////////////////add data to read here
}
void WifiDataToSend() {
  sendBl(enabled);
  if (g) {
    sendFl(a);
    sendFl(b);
  } else {
    sendFl(0);
    sendFl(0);
  }
  ///////////////////////////////////add data to send here
}

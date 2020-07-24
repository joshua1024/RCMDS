int wifiPort=25212;
String wifiIP="10.0.0.19";
/////////////////////////add interface elements here
Joystick moveStick;
Button climbButton;
Button raiseArmToScoreButton;
Button loadingStationIntakeButton;
Button ejectButton;
Button autoIntakeButton;
Button autoManualButton;
Button autoEjectButton;
Button autoStopButton;
Button clawManualCloseButton;
Button clawManualOpenButton;
Slider manualArmSlider;
Slider manualClawSlider;
BatteryGraph batg;
Button jogModeButton;
Slider trimSlider;
//////////////////////
float batVolt=0.0;
boolean enabled=false;
////////////////////////add variables here
PVector move=new PVector(0, 0);
boolean climb=false;
boolean raiseArmToScore=false;
boolean loadingStationIntake=false;
boolean eject=false;
boolean autoIntake=false;
boolean auto=false;
boolean autoEject=false;
boolean autoStop=false;
boolean clawManualClose=false;
boolean clawManualOpen=false;
float manualArm=1;
float manualClaw=0;
boolean jogMode=false;
float trim=0;//////////////

float upLidar=0;
byte upLidarP=0;
float clawLidar=0;
byte clawLidarP=0;
float frontLidar=0;
byte frontLidarP=0;
float backLidar=0;
byte backLidarP=0;
boolean runningAutoIntakeRoutine=false;
boolean ejectReady=false;
boolean driveStopped=false;
boolean armMoving=false;
float clawPosRead=0;

boolean clawButtoned=false;
boolean lastAuto=false;

void setup() {
  size(350, 1300);
  rcmdsSetup();
  setupGamepad();
  //setup UI here
  moveStick=new Joystick(width*.88, height*.1, width*.2, 1, 1, color(0, 40, 0), color(200), "X Axis", "Y Axis", UP, LEFT, DOWN, RIGHT, 0, 0);
  climbButton=new Button(width*.55, height*.1, width*.15, color(155, 0, 0), color(155, 155, 50), "Button 2", 'c', true, false, "Climb");
  raiseArmToScoreButton=new Button(width*.35, height*.23, width*.2, color(0, 155, 0), color(0, 200, 0), null, 'w', true, false, "arm score");
  loadingStationIntakeButton=new Button(width*.13, height*.29, width*.2, color(0, 140, 140), color(0, 200, 200), null, 'a', true, false, "loading station");
  ejectButton=new Button(width*.57, height*.29, width*.2, color(150, 0, 50), color(200, 0, 100), null, 'd', true, false, "eject");
  autoIntakeButton=new Button(width*.35, height*.35, width*.2, color(0, 140, 140), color(0, 200, 200), null, 's', true, false, "auto claw");
  autoManualButton=new Button(width*.15, height*.16, width*.25, color(75, 75, 0), color(75, 0, 75), "Button 1", 'q', true, true, "Q mech manual");
  autoStopButton=new Button(width*.7, height*.2, width*.25, color(150, 0, 50), color(250, 0, 100), "Button 0", 'e', true, false, "E auto stop");
  autoEjectButton=new Button(width*.85, height*.28, width*.25, color(150, 0, 50), color(250, 0, 100), "Button 3", 'r', false, false, "R auto eject");
  clawManualCloseButton=new Button(width*.2, height*.28, width*.2, color(0, 100, 100), color(0, 150, 150), null, 'z', true, false, "claw close");
  clawManualOpenButton=new Button(width*.5, height*.28, width*.2, color(100, 0, 100), color(150, 0, 150), null, 'x', true, false, "claw open");
  manualClawSlider=new Slider(width*.5, height*.35, width*.9, width*.17, -1, 0, color(0, 30, 150), color(200), null, 0, 0, 0, 0, true, false);
  manualArmSlider=new Slider(width*.4, height*.16, height*.16, width*.1, -1, 1, color(100, 0, 0), color(200), "Z Axis", 0, 0, 0, 0, false, false);
  batg=new BatteryGraph(width*.5, height*.72, width*.95, height*.05, 5);
  jogModeButton=new Button(width*.075, height*.1, width*.15, color(150), color(255, 100, 0), "Button 4", 'j', false, false, "jog drive");
  trimSlider=new Slider(width*.7, height*.15, width*.4, width*.1, -1, 1, color(0, 100, 0), color(210, 190, 190), null, 'i', 'u', .001, 0, true, false);
}
void draw() {
  background(0);
  enabled=enableSwitch.run(enabled);
  /////////////////////////////////////add UI here
  move=moveStick.run(new PVector(0, 0));
  climb=climbButton.run();
  auto=!autoManualButton.run();
  if (auto) autoManualButton.label="Q mech    auto";
  else autoManualButton.label="Q mech  manual";
  autoStop=autoStopButton.run();
  batg.run(batVolt);
  jogMode=jogModeButton.run();
  trim=trimSlider.run(trim);
  if (!auto&&lastAuto) {
    manualClaw=clawPosRead;
  }
  if (auto) {  
    autoEject=autoEjectButton.run();
    if (gamepadVal("X Rotation", 0)<-.2) {
      loadingStationIntakeButton.press();
    }
    loadingStationIntake=loadingStationIntakeButton.run();
    if (gamepadVal("X Rotation", 0)>.2) {
      ejectButton.press();
    }
    eject=ejectButton.run();
    if (gamepadVal("Z Axis", 0)>.7&&!loadingStationIntake) {
      raiseArmToScoreButton.press();
    }
    raiseArmToScore=raiseArmToScoreButton.run();
    if (gamepadVal("Z Axis", 0)<-.7&&!eject&&!loadingStationIntake) {
      autoIntakeButton.press();
    }
    autoIntake=autoIntakeButton.run();
  } else {//manual
    manualArm=manualArmSlider.run(manualArm);
    if (gamepadVal("X Rotation", 0)<-.7) {
      clawManualCloseButton.press();
      clawButtoned=true;
    }
    if (gamepadVal("X Rotation", 0)>.7) {
      clawManualOpenButton.press();
      clawButtoned=true;
    }
    if (clawManualCloseButton.run()) {
      manualClaw=-1;
    }
    if (clawManualOpenButton.run()) {
      manualClaw=0;
    }
    if (gamepadVal("X Rotation", 0)>.1) {
      if (!clawButtoned) {
        strokeWeight(4);
        stroke(255, 100, 255);
        rect(manualClawSlider.xPos, manualClawSlider.yPos, manualClawSlider.s, manualClawSlider.w);
        manualClaw+=.05*(gamepadVal("X Rotation", 0)-.1);
        noStroke();
      }
    } else  if (gamepadVal("X Rotation", 0)<-.1) {
      if (!clawButtoned) {
        strokeWeight(4);
        stroke(255, 100, 255);
        rect(manualClawSlider.xPos, manualClawSlider.yPos, manualClawSlider.s, manualClawSlider.w);
        manualClaw+=.05*(gamepadVal("X Rotation", 0)+.1);
        noStroke();
      }
    } else {
      clawButtoned=false;
    }
    manualClaw=manualClawSlider.run(manualClaw);
  }
  clawIndicator(width*0.21, height*0.47, width*0.4, height*0.17, clawLidar, clawLidarP);
  if (frontLidarP!=100) {
    frontIndicator(width*0.540, height*0.427, width*0.23, height*0.08, frontLidar, frontLidarP);
  }
  backIndicator(width*0.540, height*0.515, width*0.23, height*0.08, backLidar, backLidarP);
  if (upLidarP!=100) {
    upIndicator(width*0.82, height*0.472, width*0.32, height*0.17, upLidarP);
  }

  textSize(23);
  if (runningAutoIntakeRoutine) {
    fill(#dd0aae);
    rect(width/6, height*0.600, width/3, height*0.05);
    fill(0);
    text("auto intaking", width*0.192, height*0.600, width/3, height*0.05);
  }
  if (driveStopped) {
    fill(#B7FF1F);
    rect(width*3/6, height*0.600, width/3, height*0.05);
    fill(0);
    text("drive stopped", width*0.192+width/3, height*0.600, width/3, height*0.05);
  }
  if (ejectReady) {
    fill(#00ff00);
    rect(width/6+width*2/3, height*0.600, width/3, height*0.05);
    fill(0);
    text("eject ready", width*0.192+width*2/3, height*0.600, width/3, height*0.05);
  }
  if (armMoving) {
    fill(#999999);
    rect(width/6+width*2/3, height*0.600+height*.05, width/3, height*0.05);
    fill(0);
    text("arm moving", width*0.192+width*2/3, height*0.6000+height*.05, width/3, height*0.05);
  }

  String[] msg={"battery voltage", "ping", "claw lidar", "scale lidar", "front lidar", "back lidar"};
  String[] data={nf(batVolt, 1, 2), str(wifiPing), nf(clawLidar, 1, 2), nf(upLidar, 1, 2), nf(frontLidar, 1, 2), nf(backLidar, 1, 2)};
  dispTelem(msg, data, width/2, height*7/8, width, height/4, 15);
  lastAuto=auto;
  sendWifiData(true);
  endOfDraw();
}
void WifiDataToRecv() {
  batVolt=recvFl();
  ////////////////////////////////////add data to read here
  upLidar=recvFl();
  upLidarP=recvBy();
  clawLidar=recvFl();
  clawLidarP=recvBy();
  frontLidar=recvFl();
  frontLidarP=recvBy();
  backLidar=recvFl();
  backLidarP=recvBy();
  runningAutoIntakeRoutine=recvBl();
  ejectReady=recvBl();
  driveStopped=recvBl();
  armMoving=recvBl();
  clawPosRead=recvFl();
}
void WifiDataToSend() {
  sendBl(enabled);
  ///////////////////////////////////add data to send here
  sendVect(move);
  sendBl(auto);
  sendBl(autoEject);
  sendBl(autoStop);
  sendBl(climb);
  sendBl(raiseArmToScore);
  sendBl(loadingStationIntake);
  sendBl(eject);
  sendBl(autoIntake);
  sendFl(manualArm);
  sendFl(manualClaw);
  sendBl(jogMode);
  sendFl(trim);//edit above
  sendBy(byte(148));//upLidarP1
  sendBy(byte(85));//upLidarP2
  sendBy(byte(0));//upLidarP3
  sendBy(byte(115));//frontLidarP1
  sendBy(byte(98));//clawLidarP1
  sendBy(byte(233));//backLidarP1
  sendBy(byte(171));//upLidarMin
  sendBy(byte(37));//upLidarMax
  sendBy(byte(175));//clawLidarMin
  sendBy(byte(0));//clawLidarMax
  sendBy(byte(218));//frontLidarMin
  sendBy(byte(81));//frontLidarMax
  sendBy(byte(182));//backLidarMin
  sendBy(byte(5));//backLidarMax
  sendBy(byte(68));//leftClawCenter
  sendBy(byte(106));//leftClawRange
  sendBy(byte(127));//rightClawCenter
  sendBy(byte(109));//rightClawRange
  sendBy(byte(122));//armCenter
  sendBy(byte(214));//armRange
  sendBy(byte(227));//mot power
  sendBy(byte(45));//arm accel
  sendBy(byte(45));//arm speed
  sendBl(true);//smooth arm speed
  sendBl(true);//drive smooth
  sendBy(byte(41));//drive acc
  sendBy(byte(200));//loading station auto drive time
}
void clawIndicator(float x, float y, float w, float h, float val, byte valP) {
  pushStyle();
  rectMode(CORNER);
  noStroke();
  fill(155, 155, 0);
  rect(x-w/2+1, y-h/2+1, w-2, constrain(map(val, 0, 1.0, 0, h-2), 0, h-2));
  noFill();
  if (valP==1) {
    stroke(255, 255, 0);
  }
  if (valP==0) {
    stroke(80);
  }
  strokeWeight(20);
  rect(x-w/2+10, y-h/2+10, w-20, h-20);
  popStyle();
}
void frontIndicator(float x, float y, float w, float h, float val, byte valP) {
  pushStyle();
  rectMode(CORNER);
  noStroke();
  fill(0, 155, 60);
  rect(x-w/2+1, y-h/2+19, w-1, constrain(map(val, 0, 1.0, 0, h-38), 0, h-38));
  noFill();

  if (valP==1) {
    stroke(0, 255, 0);
  }
  if (valP==0) {
    stroke(80);
  }
  strokeWeight(20);
  rect(x-w/2+10, y-h/2+10, w-20, h-20);
  popStyle();
}
void backIndicator(float x, float y, float w, float h, float val, byte valP) {
  pushStyle();
  rectMode(CORNER);
  noStroke();
  fill(0, 155, 60);
  rect(x-w/2+1, y+h/2-20, w-1, -constrain(map(val, 0, 1.0, 0, h-40), 0, h-40));
  noFill();

  if (valP==1) {
    stroke(0, 255, 0);
  }
  if (valP==0) {
    stroke(80);
  }
  strokeWeight(20);
  rect(x-w/2+10, y-h/2+10, w-20, h-20);
  popStyle();
}
void upIndicator(float x, float y, float w, float h, byte valP) {
  pushStyle();
  rectMode(CORNER);
  noStroke();
  fill(200, 200, 0);
  valP=byte(constrain(valP, 0, 3));
  if (valP!=0) {
    rect(x-w/2+25, y-h/2+25+(valP-1)*h/4, w-50, w-50);
  }
  if (valP!=0) {
    stroke(0, 255, 0);
  } else {
    stroke(80);
  }  
  noFill();
  strokeWeight(20);
  rect(x-w/2+10, y-h/2+10, w-20, h-20);
  popStyle();
}

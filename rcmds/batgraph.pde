float[] volts = new float[100];
class BatteryGraph {
  float x;
  float y;
  float w;
  float h;
  int speed;
  int a = 0;
  BatteryGraph (float _x, float _y, float _w, float _h, int _speed) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    speed = _speed;
  }
  void run(float volt) {
    a++;
    if (a >= speed) {
      a = 0;
      for (int i=0; i<volts.length-1; i++) {
        volts[i]=volts[i+1];
      }
      volts[volts.length-1]=volt;
    }

    fill(20);
    stroke(80);
    rect(x, y, w+9, h+10, 5);
    stroke(0, 200, 0);
    for (int i=0; i<w; i++) {
      if (volts[int(map(i, 0, w, 0, volts.length))]>5.5) {
        stroke(0, 200, 0);
      } else if (volts[int(map(i, 0, w, 0, volts.length))]>5.25) {
        stroke(map(volts[int(map(i, 0, w, 0, volts.length))], 5.25, 5.5, 200, 0), 200, 0);
      } else if (volts[int(map(i, 0, w, 0, volts.length))]>5) {
        stroke(200, map(volts[int(map(i, 0, w, 0, volts.length))], 5, 5.25, 0, 200), 0);
      } else {
        stroke(200, 0, 0);
      }
      line(x+i-w/2, y+h/2, x+i-w/2, y-h*(sqrt(norm(constrain(volts[int(map(i, 0, w, 0, volts.length))], 4, 7), 4, 7))-0.5));
    }
    noStroke();
  }
}

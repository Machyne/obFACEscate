PImage img = loadImage("/home/matt/CS/Hack/obFACEscate/ob/data/test1.jpg");

void setup(){
  img = renderFilter(img, 0.8f, 15, 15);
  size(500, 500);
}

void draw(){
  background(color(0, 255, 0));
  image(img, 0, 0, width, height);
}

  boolean between(float x, float lo, float hi){
    return (x >= lo) && (x <= hi);
  }

PImage renderFilter(PImage inputImage, float filterStrength, float param1, float param2) {
  int dx = 0;
  int dy = 0;
  int dw = inputImage.width;
  int dh = inputImage.height;
  int bar = (int)param1;
  float bthick = 2.50f*param2;
  float wthick = 0.5f*param2;
  PImage wolf = new PImage(dw, dh);
  for(int x = 0; x < dw; x++){
    for(int y = 0; y < dh; y++){
      float ny = (float)y / bar;
      float nx = (float)x / bar;
      boolean onLine = false;
      onLine = onLine || between(nx - ny, -.5f*bthick, .5f*bthick);
      onLine = onLine || between(nx - ny, -1.5f*bthick - wthick, -.5f*bthick - wthick);
      onLine = onLine || between(nx - ny, 0.5f*bthick + wthick, 1.5f*bthick + wthick);
      if(onLine){
        wolf.set(x, y, color(255, 255, 255, 255*filterStrength));
      }else{
        wolf.set(x, y, color(0, 0, 0, 255*filterStrength));
      }
    }
  }
  PImage mix = inputImage.get();
  //mix.blend(wolf, 0, 0, mix.width, mix.height, dx, dy, dw, dh, LIGHTEST);
  mix.blend(wolf, 0, 0, mix.width, mix.height, dx, dy, dw, dh, OVERLAY);
  return mix;
}

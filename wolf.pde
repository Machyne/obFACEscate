PImage inputImage;
PImage wolfImage;

void setup() {
  size(640, 480);
  String inputImagePath = "/Users/ken/Files/Programming/Facial Detection/data/control_320_240.jpg";
  inputImage = loadImage(inputImagePath,"jpg");
  wolfImage = wolverine(inputImage, 4, 4, 140, 0, 0, inputImage.width, inputImage.height);
}

void draw() {
  image(wolfImage, 0, 0);
}

PImage wolverine(PImage image, int barWidth, int barHeight, int weight){
   return wolverine(image, barWidth, barHeight, weight, 0, 0, image.width, image.height); 
}

boolean between(float x, float lo, float hi){
   return (x >= lo) && (x <= hi);
}

PImage wolverine(PImage image, int barWidth, int barHeight, int weight, int dx, int dy, int dw, int dh){
   float bthick = 2.0f;
   float wthick = 2.0f;
   PImage wolf = new PImage(dw, dh);
   for(int x = 0; x < dw; x++){
       for(int y = 0; y < dh; y++){
           float ny = (float)y / barHeight;
           float nx = (float)x / barWidth;
           boolean onLine = false;
           onLine = onLine || between(nx - ny, -.5*bthick, .5*bthick);
           onLine = onLine || between(nx - ny, -1.5*bthick - wthick, -.5*bthick - wthick);
           onLine = onLine || between(nx - ny, 0.5*bthick + wthick, 1.5*bthick + wthick);
           if(onLine){
               wolf.set(x, y, color(255, 255, 255, weight));
           }else{
               //wolf.set(x, y, color(255, 255, 255, weight));
           }
       }
   }
   PImage mix = image.get();
   //mix.blend(wolf, 0, 0, mix.width, mix.height, dx, dy, dw, dh, LIGHTEST);
   mix.blend(wolf, 0, 0, mix.width, mix.height, dx, dy, dw, dh, OVERLAY);
   return mix;
}

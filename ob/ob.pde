PImage img = loadImage("/home/matt/CS/Hack/obFACEscate/ob/data/test1.jpg");

void setup(){
  img = horizBlinds(img, 120, 90, 60, 120, 120, 3000, 1800);
  size(500, 500);
}

void draw(){
  background(color(0, 255, 0));
  image(img, 0, 0, width, height);
}

PImage checkers(PImage image, int barWidth, int barHeight, int weight){
    return checkers(image, barWidth, barHeight, weight, 0, 0, image.width, image.height); 
}

PImage checkers(PImage image, int barWidth, int barHeight, int weight, int dx, int dy, int dw, int dh){
    PImage chkrs = new PImage(dw, dh);
    for(int x = 0; x < dw; x++){
        for(int y = 0; y < dh; y++){
            int place = ((x / barWidth) + (y / barHeight)) % 2;
            if(place == 0){
                chkrs.set(x, y, color(0, 0, 0, weight));
            }else{
                chkrs.set(x, y, color(255, 255, 255, weight));
            }
        }
    }
    PImage mix = image.get();
    mix.blend(chkrs, 0, 0, mix.width, mix.height, dx, dy, dw, dh, OVERLAY);
    return mix;
}

PImage horizBlinds(PImage image, int barWidth, int barHeight, int weight){
    return horizBlinds(image, barWidth, barHeight, weight, 0, 0, image.width, image.height); 
}

PImage horizBlinds(PImage image, int barWidth, int barHeight, int weight, int dx, int dy, int dw, int dh){
    PImage blnds = new PImage(dw, dh);
    for(int x = 0; x < dw; x++){
        for(int y = 0; y < dh; y++){
            int place = (int)(((float)x / barWidth) - ((float)y / barHeight));
            if(((float)y / barHeight) < ((float)x / barWidth)){ place--;}
            place %= 2;
            if(place == 0){
                blnds.set(x, y, color(0, 0, 0, weight));
            }else{
                blnds.set(x, y, color(255, 255, 255, weight));
            }
        }
    }
    PImage mix = image.get();
    PImage b2 = vingette(blnds);
    mix.blend(b2, 0, 0, mix.width, mix.height, dx, dy, dw, dh, OVERLAY);
    return mix;
}

int distToEdge(int x, int y, int w, int h){
  int a = min(w - x, x);
  int b = min(h - y, y);
  return min(a,b);
}

PImage vingette(PImage img){
  PImage vig = new PImage(img.width, img.height);
  for(int x = 0; x < img.width; x++){
      for(int y = 0; y < img.height; y++){
        int d = distToEdge(x, y, img.width, img.height);
        vig.set(x, y, color(255, 255, 255, min(d, 255)));
      }
    }
    PImage mix = img.get();
    mix.blend(vig, 0, 0, mix.width, mix.height, 0, 0, mix.width, mix.height, OVERLAY);
    return mix;
}


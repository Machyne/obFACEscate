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
    mix.blend(blnds, 0, 0, mix.width, mix.height, dx, dy, dw, dh, OVERLAY);
    return mix;
}


PImage wolverine(PImage image, int barWidth, int barHeight, int weight){
    return wolverine(image, barWidth, barHeight, weight, 0, 0, image.width, image.height); 
}

boolean between(float x, float lo, float hi){
    return (x >= lo) && (x <= hi);
}

PImage wolverine(PImage image, int barWidth, int barHeight, int weight, int dx, int dy, int dw, int dh){
    PImage wolf = new PImage(dw, dh);
    for(int x = 0; x < dw; x++){
        for(int y = 0; y < dh; y++){
            float ny = (float)y / barHeight;
            float nx = (float)x / barWidth;
            boolean onLine = false;
            onLine = onLine || between(nx - ny, -1.0, 1.0);
            onLine = onLine || between(nx - ny, -5.0, -3.0);
            onLine = onLine || between(nx - ny, 3.0, 5.0);
            if(onLine){
                wolf.set(x, y, color(0, 0, 0, weight));
            }else{
                wolf.set(x, y, color(255, 255, 255, weight));
            }
        }
    }
    PImage mix = image.get();
    mix.blend(wolf, 0, 0, mix.width, mix.height, dx, dy, dw, dh, OVERLAY);
    return mix;
}
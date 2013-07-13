int distToEdge(int x, int y, int w, int h){
	int a = min(w - x, x);
	int b = min(h - y, y);
	return min(a,b);
}

int vingette(PImage img){
	PImage vig = new PImage(img.width, img.height);
	for(int x = 0; x < img.width; x++){
    	for(int y = 0; y < img.height; y++){
    		int d = 5*distToEdge(x, y, img.width, img.height);
    		vig.set(x, y, color(255, 255, 255, min(d, 255));
    	}
    }
    PImage mix = image.get();
    mix.blend(vig, 0, 0, mix.width, mix.height, 0, 0, mix.width, mix.height, OVERLAY);
    return mix;
}

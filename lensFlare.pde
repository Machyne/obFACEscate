void setup() {
  size(320, 240);
  String inputImagePath = "/Users/ken/Files/Programming/Facial Detection/data/control_320_240.jpg";
  PImage inputImage = loadImage(inputImagePath,"jpg");
  applyLensFlare(inputImage, 320, 240);
  image(inputImage, 0, 0);
}

int clip(float a){ 
    if (a >= 255.0) return 255; 
    return (int) a; 
}

int FLARE_X = 160; 
int FLARE_Y = 100; 
int FLARE_SIZE = 400;
int FLARE_INTENSITY = 60;
float FLARE_FALLOFF =   4.0;
int FLARE_STREAKINTENSITY =  10;
int FLARE_STREAKCOUNT =  50;
int FLARE_STREAKNOISEFREQ =  0;
int FLARE_STREAKNOISELEVEL=   5;
int FLARE_REDRING = 1;
float FLARE_REDRINGMIN = 0.32;
float FLARE_REDRINGMAX = 0.44;
int FLARE_REDGLOW = 1;
float FLARE_REDGLOWFALLOFF = 5.0;

void applyLensFlare(PImage inputImage, int w, int h) {
    inputImage.loadPixels();
    int x, y; 
    int fx, fy; 
    float d, d2, level; 
    float star; 
    float Rf,Gf,Bf,redf,nois; 
    float R, G, B;
    int p = 0; // Index of current pixel
    // Set flare position
    fx = FLARE_X;
    fy = FLARE_Y;
    level = FLARE_INTENSITY*255/100; 
    for (y=0; y < h; y++) 
    { 
        for (x=0; x < w; x++) 
        { 
            // Calc distance squared and distance, then 
            // add d + d^2 to get the falloff function 
            d2 = (x-fx)*(x-fx) + (y-fy)*(y-fy); 
            d = sqrt(d2); 
            d += d2; 
            // Multiply to set the flare size 
            d *= (0.02 / FLARE_SIZE); 
            // The "Central Glow" falloff function is modified by the 
            // "Red Outer Glow" in the inner part of the flare.
            if (FLARE_REDGLOW > 0) {
              redf = 1/(1 + d * FLARE_REDGLOWFALLOFF);
            } else {
              redf = 0.0;
            }
            Rf = FLARE_FALLOFF; 
            Gf = FLARE_FALLOFF + 11.0 * redf; 
            Bf = FLARE_FALLOFF + 10.0 * redf; 
            R = 1.0 / (1+d*Rf); 
            G = 1.0 / (1+d*Gf); 
            B = 1.0 / (1+d*Bf); 
            // The red "Central Ring" 
            if (FLARE_REDRING > 0 && d > FLARE_REDRINGMIN && d < FLARE_REDRINGMAX) 
            { 
                float r = 2.0 * (d - FLARE_REDRINGMIN) / (FLARE_REDRINGMAX - FLARE_REDRINGMIN); 
                if (r > 1.0) r = 2.0 - r; 
                r = r*r*(3 - 2*r)/255.0; 
                R += 40*r; 
                G += 10*r; 
                B +=  5*r; 
            }
            /*
            // Random streaks 
            // Angle around flare in the range 0 to 2 
            star = atan2(x-fx,y-fy)/PI + 1.0;
            // Random noise with selectable frequency 
            nois = random(star * FLARE_STREAKNOISEFREQ); 
            // Multiply by number of streaks and add in some noise 
            star = star*FLARE_STREAKCOUNT + nois * FLARE_STREAKNOISELEVEL; 
            // Get range 0 to 1 by reversing the range 1 to 2
             
            star = star % 2.0; 
            if (star >= 1.0) star = 2.0 - star; 
            // To get more sharply defined streaks, we square them 
            // a couple of times 
            star = star*star; star = star*star; // star = star*star; 
            // Streaks are a maximum value divided by the falloff function, 
            // but some noise is also multiplied in to lower the intensity 
            // of some of them. 
            star = star * (FLARE_STREAKINTENSITY * 0.01) / (1+d*2.0) * nois * nois; 
            if (star > 0.0) // Until we fix the "negative" bug... 
            { 
                R += star; 
                G += star; 
                B += star; 
            }
            */
            // Calculate and set new RGB values for current pixel.
            color c = inputImage.pixels[p]; 
            float r = red(c);
            float g = green(c);
            float b = blue(c);
            int r2 = clip(r + level * R);
            int g2 = clip(g + level * G);
            int b2 = clip(b + level * B);
            color c2 = color(r2, g2, b2);
            inputImage.pixels[p] = c2;
            p++;
        }
    }
    inputImage.updatePixels();
}

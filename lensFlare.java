/* 
** Lens Flare Test 
** source : http://www.graphicsgroups.com/5-graphics-algorithms/48afa8bf0adcd901.htm

*/ 
// This random number generator really sucks 
// but I couldn't find the other code I had... 
float rnd(i){
    return ((i*37621)%2000)/2000.0;
}

float noise1d(float n){ 
    int rndi; 
    float f; 
    i = (int)floor(n);
    f = n-i;
    return rnd(i+1)*f + rnd(i)*(1-f); 
} 

int clip(float a){ 
    if (a >= 255.0) return 255; 
    return (int)a; 
}

int FLARE_X = 100; 
int FLARE_Y = 100; 
int FLARE_SIZE = 100;
int FLARE_INTENSITY = 100;
float FLARE_FALLOFF =   4.0;
int FLARE_STREAKINTENSITY =  10;
int FLARE_STREAKCOUNT =  50;
int FLARE_STREAKNOISEFREQ =  25;
int FLARE_STREAKNOISELEVEL=   5;
int FLARE_REDRING = 1;
float FLARE_REDRINGMIN = 0.32;
float FLARE_REDRINGMAX = 0.44;
int FLARE_REDGLOW = 1;
float FLARE_REDGLOWFALLOFF = 5.0;

void RenderFlare(PImage original, int wdth, int hght){ 
    int x, y; 
    int fx, fy; 
    PImage p = original.get(); 
    float d, d2, level; 
    float star; 
    float Rf,Gf,Bf,redf,nois; 
    float R, G, B; 
    // Set flare position
    fx = FLARE_X;
    fy = FLARE_Y;
    level = FLARE_INTENSITY*255/100; 
    for (y=0; y < hght; y++) 
    { 
        p = pixels + (hght-1-y) * wdth; 
        for (x=0; x < wdth; x++) 
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
            redf = FLARE_REDGLOW ? 1/(1 + d * FLARE_REDGLOWFALLOFF) : 0.0; 
            Rf = FLARE_FALLOFF; 
            Gf = FLARE_FALLOFF + 11.0 * redf; 
            Bf = FLARE_FALLOFF + 10.0 * redf; 
            R = 1.0 / (1+d*Rf); 
            G = 1.0 / (1+d*Gf); 
            B = 1.0 / (1+d*Bf); 
            // The red "Central Ring" 
            if (FLARE_REDRING && d > FLARE_REDRINGMIN && d < FLARE_REDRINGMAX) 
            { 
                float r = 2.0 * (d - FLARE_REDRINGMIN) / (FLARE_REDRINGMAX - FLARE_REDRINGMIN); 
                if (r > 1.0) r = 2.0 - r; 
                r = r*r*(3 - 2*r)/255.0; 
                R += 40*r; 
                G += 10*r; 
                B +=  5*r; 
            } 
            // Random streaks 
            // Angle around flare in the range 0 to 2 
            star = atan2(x-fx,y-fy)/PI + 1.0; 
            // Random noise with selectable frequency 
            nois = noise1d(star * FLARE_STREAKNOISEFREQ); 
            // Multiply by number of streaks and add in some noise 
            star = star*FLARE_STREAKCOUNT + nois * FLARE_STREAKNOISELEVEL; 
            // Get range 0 to 1 by reversing the range 1 to 2 
            star = fmod(star, 2.0); 
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
            // Calculate and set RGB values. 
            
            *p++ = clip((float)*p + level*B); // B 
            *p++ = clip((float)*p + level*G); // G 
            *p++ = clip((float)*p + level*R); // R 
        } 
    } 
}

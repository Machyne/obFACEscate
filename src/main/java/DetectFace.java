import org.opencv.core.Core;
import org.opencv.core.CvType;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.MatOfRect;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfDouble;
import org.opencv.core.Rect;
import org.opencv.objdetect.CascadeClassifier;
import processing.core.*;
import java.awt.Rectangle;

//
// Detects faces in a PImage, and returns the results
// as java.awt.Rectangle 's.
//
class DetectFace {

	private static boolean HAS_BEEN_LOADED = false;

	private final CascadeClassifier faceDetector;
	
	public DetectFace(){
		if(!HAS_BEEN_LOADED){
			System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
			HAS_BEEN_LOADED = true;
		}
		faceDetector = new CascadeClassifier(getClass().getResource("/lbpcascade_frontalface.xml").getPath());
	}

	public Rectangle[] detect(PImage pimg) {
		// Convert the image to a matrix
		Mat image = this.pimgToMat(pimg);
		
		// Detect faces in the image.
		MatOfRect faceDetections = new MatOfRect();
		MatOfInt rejectLevels = new MatOfInt();
		MatOfDouble weights = new MatOfDouble();
		//all magic numbers are c++ defaults.
		faceDetector.detectMultiScale(image, faceDetections, rejectLevels, weights, 1.1, 2, 0,
				new Size(20,20), new Size(Integer.MAX_VALUE,Integer.MAX_VALUE), false);

		// Get the bounding rectangles around each face.
		Rect[] fd = faceDetections.toArray();
		
		Rectangle[] ret = new Rectangle[fd.length];
		for(int i = 0; i < fd.length; i++){
			ret[i] = new Rectangle(fd[i].x, fd[i].y, fd[i].width, fd[i].height);
		}
		return ret;
	}

	public Mat pimgToMat(PImage pimg){
		pimg.loadPixels();
		Mat ret = new Mat(pimg.height, pimg.width, CvType.CV_8UC3);
		for(int x = 0; x < pimg.width; x++){
			for(int y = 0; y < pimg.height; y++){
				int c = pimg.pixels[x+y*pimg.width];
				double red   = (int)((c & 0x00FF0000) >>> 16);
				double green = (int)((c & 0x0000FF00) >>> 8);
				double blue  = (int)((c & 0x000000FF));
				double data[] = {blue, green, red};
				ret.put(y, x, data);
			}
		}
		return ret;
	}

	public boolean containsFace(PImage pimg, Rectangle rect){
		Rectangle[] currentSeen = detect(pimg);
		boolean isStillFace = false;
		for(Rectangle r : currentSeen){
			isStillFace = isStillFace || rect.intersects(r);
		}
		return isStillFace;
//		int w = pimg.width;
//		int h = pimg.height;
//		int colAvg[] = {0, 0, 0}; 
//		int px = 0;
//		for(int x = 3*w/8; x < 5*w/8; x++){
//			for(int y = 3*h/8; y < 5*h/8; y++){
//				px++;
//				int c = pimg.pixels[x+y*pimg.width];
//				colAvg[0] += (c >> 16) & 0xFF;
//				colAvg[1] += (c >> 8)  & 0xFF;
//				colAvg[2] +=  c        & 0xFF;
//			}
//		}
//		colAvg[0] /= px;
//		colAvg[1] /= px;
//		colAvg[2] /= px;
//		px = 0;
//		int good = 0;
//		for(int x = 0; x < w; x++){
//			for(int y = 0; y < h; y++){
//				px++;
//				int c = pimg.pixels[x+y*pimg.width];
//				int dif = Math.abs(colAvg[0] - ((c >> 16) & 0xFF));
//				dif += Math.abs(colAvg[1] - ((c >> 8) & 0xFF));
//				dif += Math.abs(colAvg[2] - (c & 0xFF));
//				if(dif < 40){
//					good++;
//				}
//			}
//		}
//		float ret =  100.0f * (float)good / (float)px;
//		return ret;
	}
}
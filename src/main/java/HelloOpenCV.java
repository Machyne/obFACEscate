import org.opencv.core.Core;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.MatOfRect;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfDouble;
import org.opencv.core.Point;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.highgui.Highgui;
import org.opencv.objdetect.CascadeClassifier;

//
// Detects faces in an image, draws boxes around them, and writes the results
// to "faceDetection.png".
//
class DetectFaceDemo {
	public void run() {
		System.out.println("\nRunning DetectFaceDemo");

		// Create a face detector from the cascade file in the resources
		// directory.
		CascadeClassifier faceDetector = new CascadeClassifier(getClass().getResource("/lbpcascade_frontalface.xml").getPath());
		Mat image = Highgui.imread(getClass().getResource("/lena.png").getPath());
		System.out.println(image);
		int xxx = 10;
		int yyy = 10;
		System.out.println(image.get(xxx, yyy)[0]+", "+image.get(xxx, yyy)[1]+", "+image.get(xxx, yyy)[2]);

		// Detect faces in the image.
		// MatOfRect is a special container class for Rect.
		MatOfRect faceDetections = new MatOfRect();
		MatOfInt rejectLevels = new MatOfInt();
		MatOfDouble weights = new MatOfDouble();
		//all magic numbers are c++ defaults.
		faceDetector.detectMultiScale(image, faceDetections, rejectLevels, weights, 1.1, 3, 0,
				new Size(100,100), new Size(Integer.MAX_VALUE,Integer.MAX_VALUE), false);

		System.out.println(String.format("Detected %s faces", faceDetections.toArray().length));

		// Draw a bounding box around each face.
		Rect fds[] = faceDetections.toArray();
		for (int i = 0; i < fds.length; i++) {
			Rect rect = fds[i];
			Core.rectangle(image, new Point(rect.x, rect.y), new Point(rect.x + rect.width, rect.y + rect.height), new Scalar(0, 255, 0));
		}

		// Save the visualized detection.
		String filename = "faceDetection.png";
		System.out.println(String.format("Writing %s", filename));
		Highgui.imwrite(filename, image);
	}
}

public class HelloOpenCV {
	public static void main(String[] args) {
		System.out.println("Hello, OpenCV");

		// Load the native library.
		System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
		new DetectFaceDemo().run();
	}
}


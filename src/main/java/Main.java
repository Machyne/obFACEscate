import java.awt.Rectangle;
import java.util.ArrayList;

import processing.core.*;



public class Main extends PApplet{
	private static final long serialVersionUID = 1L;

	/* This is the number of nodes that must be visited for a search to be
	 *   considered extensive enough to have given a good solution. See comments
	 *   by filterSetSearch(…) for details.
	 */
	private final int NODES_VISITED_THRESHOLD = 0;
	private DetectFace detector;
	public PImage showimg = null;

	/*
	 * This is the factor by which the cost factor increases on each unsuccessful
	 *   (not extensive) iteration of the search.
	 */
	final float COST_FACTOR_INCREASE_FACTOR = 1.5f;

	public void setup() {
		size(640, 640);
		detector = new DetectFace();
		mainFunction();
	}

	public void draw() {
		println("*****HERE!!!!*****");
		if (showimg != null) {
			size(showimg.width, showimg.height);
			image(showimg, 0, 0);
		}
	}

	/*
	 * Main function.
	 */
	void mainFunction() {
		println("mainFunction()");

		/*
		 * Load resources.
		 */
		for (int i = 0; i < 17; i++) {
			String inputImagePath = getClass().getResource("/img/pic"+i+".jpg").getPath();
			PImage inputImage = loadImage(inputImagePath,"jpg");
			showimg = inputImage;
			draw();

			/*
			 * Use OpenCV to find faces.
			 */
			Rectangle [] faceRects = findFaces(inputImage);
			System.out.println("Found "+faceRects.length+" faces.");

			PImage composite = null;
			try {
				composite = (PImage) inputImage.clone();
			} catch (CloneNotSupportedException e) {
				//pass
			}

			/*
			 * Run search to find a good filter set.
			 */
			for (Rectangle r : faceRects) {
				PImage readyImage = removeOtherFaces(inputImage, r, faceRects);
				FilterNode fn = filterSetSearch(readyImage, r);
				composite = fn.renderImage(composite, r);
			}

			PGraphics g = this.createGraphics(inputImage.width, inputImage.height);
			g.beginDraw();
			g.image(composite, 0, 0);
			g.endDraw();
			g.save("pic"+i+"out.jpg");
		}
	}

	/*
	 * The search function for a good filter set works on hiding a single face at a time.
	 * Any image passed to it therefore has black squares drawn over any other faces in the image.
	 */
	PImage removeOtherFaces(PImage inputImage, Rectangle r, Rectangle [] faceRects) {
		PGraphics newImage = createGraphics(inputImage.width, inputImage.height);
		newImage.beginDraw();
		newImage.image(inputImage, 0, 0);
		newImage.fill(0.0f);
		newImage.noStroke();
		for (Rectangle r2 : faceRects) {
			if (r2 != r) {
				newImage.rect((int) r.getX(), (int) r.getY(), (int) r.getWidth(), (int) r.getHeight());
			}
		}
		newImage.endDraw();
		return newImage;
	}

	/* Search for optimal filter (a filter that achieves the goal with as low as possible cost)
	 * Modified from A* search
	 *
	 * A node has been “evaluated” if it is known whether or not it is in the goal.
	 * A node is in the goal if its distance from the goal is non-positive.
	 *
	 * closedSet:  Set of nodes that have been evaluated.
	 * openSet:    Set of nodes that have not been evaluated, but whose scores have been calculated.
	 *
	 * The score (fscore) of a node is the cost of applying the filters it
	 *   contains plus its distance to the goal; cost and distance use the same units.
	 *
	 * gScores are not necessary because cost is path-independent.
	 *
	 * Because we don't have a real heuristic we can't guarantee an optimal solution.
	 * The relative weights of cost and distance will determine the bredth of the search:
	 *   If cost goes up faster than distance goes down, then many few-filter possibilities will
	 *     have to be considered until a path reaches the goal.
	 *   If distance decreases faster than cost rises, then a solution that initially looks good
	 *     will be followed to the finish.
	 *   If the right weight and cost functions are defined the search should approach an optimal
	 *     A* search rather than a depth- or breadth-first search.
	 *   To help find an optimal solution we run the search repeatedly until a certain threshold
	 *     of nodes are visited in a given search. The cost factor is increased each iteration.
	 */
	float costFactor;
	int searchCount = 0;
	FilterNode filterSetSearch(PImage inputImage, Rectangle faceRect) {
		println("filterSetSearch(…)");
		FilterNode foundFilterNode = null;
		int nodesVisited = -1;
		costFactor = 1.0f;
		/*
		 * Search loop: this is repeated until an “extensive” search is completed.
		 * The cost factor is increased each time increasing the breadth of the search.
		 */
		while (nodesVisited < NODES_VISITED_THRESHOLD) {
			ArrayList<FilterNode> closedSet = new ArrayList<FilterNode>();
			ArrayList<FilterNode> openSet = new ArrayList<FilterNode>();
			openSet.add(new FilterNode());
			while (!openSet.isEmpty()) {
				println("\topenSet.size() = " + openSet.size());
				FilterNode current = getKeyWithMinValue(openSet);
				println("\tCurrent node: " + current.getCost());
				if (current.isInGoal(inputImage, faceRect)) {
					nodesVisited = closedSet.size() + openSet.size();
					println("Visited " + nodesVisited + " nodes.");
					println("Evaluated " + closedSet.size() + " nodes.");
					foundFilterNode = current;
					break;
				}
				// If we haven't yet reached the goal, close the node and iterate through neighbors.
				openSet.remove(current);
				closedSet.add(current);
				ArrayList<FilterNode> neighbors = getNeighborNodes(current);
				for (FilterNode n : neighbors) {
					// If we haven't ever calculated the cost of this node
					if(!closedSet.contains(n) && !openSet.contains(n)) {
						openSet.add(n);
					}
				}
			}
			if (openSet.isEmpty()) { // Unsuccessful search
				println("No path found to goal.");
				return null;
			} else { // Successful search
				costFactor *= COST_FACTOR_INCREASE_FACTOR;
				searchCount++;
			}
		}
		println("Ran " + searchCount + " searches.");
		return foundFilterNode;
	}

	/*
	 * Filter optimization technique:
	 *   A step consists of either
	 *     1. Addition of a filter with a certain strength.
	 *          - cost will increase and distance will decrease
	 *     2. Optimization of a filter by varying parameters (except strength).
	 *          - cost does not change, distance will increase or decrease
	 *
	 *   At each branching step we alternatingly add a new filter or optimize the last filter.
	 *
	 *   Following this pattern, a filter is first added with default parameters and then optimized.
	 *   By optimizing a filter configuration before adding an addtional filter we narrow our search significantly.
	 *
	 */

	/*
	 * Get neighboring nodes. As described above, there are two modes of branching.
	 */
	ArrayList<FilterNode> getNeighborNodes(FilterNode n) {
		ArrayList<FilterNode> neighbors = new ArrayList<FilterNode>();
		for (int t = 0; t < Filter.FILTER_TYPE_COUNT; t++) {
			int param1Domain = getParam1Domain(t);
			int param2Domain = getParam2Domain(t);
			for (int s = 0; s < Filter.FILTER_STRENGTH_COUNT; s++) {
				for (int i = 0; i < param1Domain; i++) {
					for (int j = 0; j < param2Domain; j++) {
						neighbors.add(addFilterNode(n, t, s, i, j));
					}
				}
			}
		}
		return neighbors;
	}

	/*
	 * Return the FilterNode from list nodeList with the lowest distanceToGoal.
	 * (If distanceToGoal has not been previously calculated for the node, it is calculated now.)
	 */
	FilterNode getKeyWithMinValue(ArrayList<FilterNode> nodeList) {
		FilterNode minNode = nodeList.get(0);
		float minValue = minNode.getCost();
		for(FilterNode n : nodeList) {
			if(n==minNode) continue;
			float v = n.getCost();
			if (v < minValue) {
				minNode = n;
				minValue = v;
			}
		}
		return minNode;
	}

	Rectangle [] findFaces(PImage img) {
		return detector.detect(img);
	}

	// Processing doesn't like static arrays and functions in normal classes.
	// Filter's static constants and functions
	//
	// The different values strength can take.
	final float [] strengthValues = {0.8f, 0.9f, 1.0f};
	// The number of values parameter 1 can take, depending on (indexed by) filter type.
	final int [] param1Domains = {3, 3, 3};
	// The number of values parameter 2 can take, depending on (indexed by) filter type.
	final int [] param2Domains = {3, 3, 3};
	final float [] param1Defaults = {20, 2, 2};
	final float [] param2Defaults = {20, 10, 15};
	// The different values parameter 1 can take, indexed by 1. filter type 2. param1Index.
	final float [] [] param1Values = { {10, 20, 30}, // checker square size
			{1, 2, 3}, // diagonal width
			{1, 2, 3} // diagonal width
	};
	// The different values parameter 2 can take, indexed by 1. filter type 2. param2Index.
	final float [] [] param2Values = { {10, 20, 30}, // checker offset
			{5, 10, 15}, // diagonal spacing
			{10, 15, 20} // diagonal spacing
	};
	// Drawer class for each filter type.
	final FilterDrawer [] drawers = {new CheckerDrawer(), new DiagonalDrawer(), new WolverineDrawer()};
	// Static functions for access to the static constant values that depend on filter type.
	float getStrength(int strengthIndex) {
		return strengthValues[strengthIndex];
	}
	int getParam1Domain(int filterType) {
		return param1Domains[filterType];
	}
	int getParam2Domain(int filterType) {
		return param2Domains[filterType];
	}
	float getParam1(int filterType, int param1Index) {
		if (param1Index == -1) {
			return param1Defaults[filterType];
		}
		return param1Values[filterType][param1Index];
	}
	float getParam2(int filterType, int param2Index) {
		if (param2Index == -1) {
			return param2Defaults[filterType];
		}
		return param2Values[filterType][param2Index];
	}

	// Immutable object describing a filter
	class Filter {
		// TODO Define constants in Filter which define every type of filter that exists.
		// The number of values strength can take is the same for every filter type.
		final static int FILTER_STRENGTH_COUNT = 3;
		// Unique constant identifier for each filter type.
		final static int FILTER_CHECKERBOARD = 0;
		final static int FILTER_DIAGONAL = 1;
		final static int FILTER_WOLVERINE = 2;
		final static int FILTER_TYPE_COUNT = 3;
		// Member variables.
		private int filterType;
		private float filterStrength;
		private float param1;
		private float param2;
		Filter(int filterType, int strengthIndex, int param1Index, int param2Index) {
			this.filterType = filterType;
			this.filterStrength = getStrength(strengthIndex);
			this.param1 = getParam1(filterType, param1Index);
			this.param2 = getParam2(filterType, param2Index);
		}
		PImage renderFilter(PImage inputImage, Rectangle faceRect) {
			return drawers[filterType].renderFilter(inputImage, faceRect, filterStrength, param1, param2);
		}
		public float cost() {
			int cost = 0;
			switch(filterType){
			case FILTER_CHECKERBOARD:
				cost = (int) (6 + param1);
				break;
			case FILTER_DIAGONAL:
				cost = (int) (7 + param1 * 5);
				break;
			case FILTER_WOLVERINE:
				cost = (int) (5 + param2 * 2);
				break;
			default:
				cost = Integer.MAX_VALUE;
			}
			cost += 20 * filterStrength;
			return cost;
		}
	}

	abstract class FilterDrawer {
		abstract PImage renderFilter(PImage inputImage, Rectangle faceRect, float filterStrength, float param1, float param2);
	}

	class CheckerDrawer extends FilterDrawer {
		PImage renderFilter(PImage inputImage, Rectangle faceRect, float filterStrength, float param1, float param2) {
			//
			int dx = faceRect.x;
			int dy = faceRect.y;
			int dw = faceRect.width;
			int dh = faceRect.height;
			int bar = (int)param1;
			int shift = 0;//((int)param2 - 20)/30 * width;
			int weight = (int)(filterStrength * 255);
			PImage chkrs = new PImage(dw, dh);
			for(int x = 0; x < dw; x++){
				for(int y = 0; y < dh; y++){
					int place = ((x / bar) + (y / bar)) % 2;
					if(place == 0){
						chkrs.set(x, y, color(0, 0, 0, weight));
					}else{
						chkrs.set(x, y, color(255, 255, 255, weight));
					}
				}
			}
			PImage mix = inputImage.get();
			mix.blend(chkrs, 0, 0, mix.width, mix.height, dx+shift, dy, dw, dh, OVERLAY);
			return mix;
		}
	}

	class DiagonalDrawer extends FilterDrawer {
		PImage renderFilter(PImage inputImage, Rectangle faceRect, float filterStrength, float param1, float param2) {
			int dx = faceRect.x;
			int dy = faceRect.y;
			int dw = faceRect.width;
			int dh = faceRect.height;
			int bar = (int)param1*width/20;
			int shift = ((int)param2*2 - 20)/30 * width;
			int weight = (int)(filterStrength * 255);
			PImage blnds = new PImage(dw, dh);
			for(int x = 0; x < dw; x++){
				for(int y = 0; y < dh; y++){
					int place = (int)(((float)x / bar) - ((float)y / bar));
					if(((float)y / bar) < ((float)x / bar)){ place--;}
					place %= 2;
					if(place == 0){
						blnds.set(x, y, color(0, 0, 0, weight));
					}else{
						blnds.set(x, y, color(255, 255, 255, weight));
					}
				}
			}
			PImage mix = inputImage.get();
			mix.blend(blnds, 0, 0, mix.width, mix.height, dx+shift, dy, dw, dh, OVERLAY);
			return mix;
		}
	}

	boolean between(float x, float lo, float hi){
		return (x >= lo) && (x <= hi);
	}

	class WolverineDrawer extends FilterDrawer {
		PImage renderFilter(PImage inputImage, Rectangle faceRect, float filterStrength, float param1, float param2) {
			int dx = 0;
			int dy = 0;
			int dw = width;
			int dh = height;
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
	}


	// TODO create more drawers

	FilterNode addFilterNode(FilterNode source, int type, int strengthIndex, int param1Index, int param2Index) {
		return new FilterNode(source, new Filter(type, strengthIndex, param1Index, param2Index));
	}

	class FilterNode {
		FilterNode prevNode;
		Filter lastFilter;
		Float cost;
		private FilterNode(FilterNode prevNode, Filter lastFilter) {
			this.prevNode = prevNode;
			this.lastFilter = lastFilter;
			this.cost = null;
		}
		FilterNode() {
			this.prevNode = null;
			this.lastFilter = null;
			this.cost = null;
		}
		int getFilterType() {
			return lastFilter.filterType;
		}
		float getCost() {
			if (lastFilter == null) {
				cost = 0.0f;
			}else if (cost == null) {
				if (prevNode == null) {
					cost = lastFilter.cost();
				} else {
					cost = lastFilter.cost() + prevNode.getCost();
				}
			} 
			return cost;
		} 
		PImage renderImage(PImage inputImage, Rectangle faceRect) {
			if (lastFilter == null) {
				showimg =  inputImage;
			} else if (prevNode == null) {
				showimg = lastFilter.renderFilter(inputImage, faceRect);
			} else {
				PImage tmp = prevNode.renderImage(inputImage, faceRect);
				showimg =  lastFilter.renderFilter(tmp, faceRect);
			}
			draw();
			return showimg;
		}
		boolean isInGoal(PImage inputImage, Rectangle faceRect) {
			PImage renderedImage = renderImage(inputImage, faceRect);
			boolean r = !detector.containsFace(renderedImage, faceRect);
			return r;
		}
	}

}

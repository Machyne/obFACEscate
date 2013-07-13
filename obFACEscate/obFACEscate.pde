import java.awt.Rectangle;
import java.util.HashMap;

/* This is the number of nodes that must be visited for a search to be
 *   considered extensive enough to have given a good solution. See comments
 *   by optimalFilterSearch(…) for details.
 */
final int NODES_VISITED_THRESHOLD = 200;

/*
 * This is the factor by which the cost factor increases on each unsuccessful
 *   (not extensive) iteration of the search.
 */
final float COST_FACTOR_INCREASE_FACTOR = 1.5;

void setup() {
  size(640, 640);
  mainFunction();
}

/*
 * Main function.
 */
void mainFunction() {
  println("mainFunction()");
  
  /*
   * Load resources.
   */
  String inputImagePath = "/Users/ken/Files/Programming/Facial Detection/data/control_320_240.jpg";
  PImage inputImage = loadImage(inputImagePath,"jpg");
  
  /*
   * Use OpenCV to detect faces.
   */
  Rectangle [] faceRects = findFaces(inputImage);
  
  /*
   * Run A*-like search to find a good filter set.
   */
  for (Rectangle r : faceRects) {
    PImage readyImage = removeOtherFaces(inputImage, r, faceRects);
    FilterNode fn = optimalFilterSearch(readyImage, r);
    // @TODO: do something with fn
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
  newImage.fill(#FFFFFF);
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
FilterNode optimalFilterSearch(PImage inputImage, Rectangle faceRect) {
  println("optimalFilterSearch(…)");
  FilterNode foundFilterNode = null;
  int nodesVisited = 0;
  costFactor = 1.0;
  /*
   * Search loop: this is repeated until an “extensive” search is completed.
   * The cost factor is increased each time increasing the breadth of the search.
   */
  while (nodesVisited < NODES_VISITED_THRESHOLD) {
    ArrayList<FilterNode> closedSet = new ArrayList<FilterNode>();
    ArrayList<FilterNode> openSet = new ArrayList<FilterNode>();
    FilterNode startNode = new FilterNode();
    openSet.add(new FilterNode());
    while (!openSet.isEmpty()) {
      println("\topenSet.size() = " + openSet.size());
      FilterNode current = getKeyWithMinValue(openSet, inputImage, faceRect);
      if (current.getDistanceToGoal() <= 0) {
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
  if (n.isFilterOptimizationBranch) {
    // The lst step was an optimization branch, so at this step we add a new filter.
    for (int i = 0; i < Filter.FILTER_TYPE_COUNT; i++) {
      for (int j = 0; j < Filter.FILTER_STRENGTH_COUNT; j++) {
        neighbors.add(addFilterNode(n, i, j));
      }
    }
  } else {
    int filterType = n.getFilterType();
    int param1Domain = getParam1Domain(filterType);
    int param2Domain = getParam2Domain(filterType);
    for (int i = 0; i < param1Domain; i++) {
      for (int j = 0; j < param2Domain; j++) {
        neighbors.add(optimizeFilterNode(n, i, j));
      }
    }
  }
  return neighbors;
}

/*
 * Return the FilterNode from list nodeList with the lowest distanceToGoal.
 * (If distanceToGoal has not been previously calculated for the node, it is calculated now.)
 */
FilterNode getKeyWithMinValue(ArrayList<FilterNode> nodeList, PImage inputImage, Rectangle faceRect) {
  FilterNode minNode = nodeList.get(0);
  float minValue = minNode.getDistanceToGoal(inputImage, faceRect) + minNode.getCost();
  for(int i = 1; i < nodeList.size(); i++) {
    FilterNode n = nodeList.get(i);
    float v = n.getDistanceToGoal(inputImage, faceRect) + n.getCost();
    if (v < minValue) {
      minNode = n;
      minValue = v;
    }
  }
  return minNode;
}

Rectangle [] findFaces(PImage img) {
  // @TODO Get OpenCV to find face Rectangles.
  return new Rectangle [] {new Rectangle(100, 100, 100, 100)};
}

// Processing doesn't like static arrays and functions in normal classes.
// Filter's static constants and functions
//
// The different values strength can take.
final float [] strengthValues = {.25, .5, 1.0};
// The number of values parameter 1 can take, depending on (indexed by) filter type.
final int [] param1Domains = {3, 3};
// The number of values parameter 2 can take, depending on (indexed by) filter type.
final int [] param2Domains = {3, 3};
final float [] param1Defaults = {20, 2};
final float [] param2Defaults = {20, 10};
// The different values parameter 1 can take, indexed by 1. filter type 2. param1Index.
final float [] [] param1Values = { {10, 20, 30}, // checker square size
                                          {1, 2, 3} // diagonal width
                                        };
// The different values parameter 2 can take, indexed by 1. filter type 2. param2Index.
final float [] [] param2Values = { {10, 20, 30}, // checker offset
                                          {5, 10, 15} // diagonal spacing
                                        };
// Drawer class for each filter type.
final FilterDrawer [] drawers = {new CheckerDrawer(), new DiagonalDrawer()};
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
  // @TODO Define constants in Filter which define every type of filter that exists.
  // The number of values strength can take is the same for every filter type.
  final static int FILTER_STRENGTH_COUNT = 3;
  // Unique constant identifier for each filter type.
  final static int FILTER_CHECKERBOARD = 0;
  final static int FILTER_DIAGONAL = 1;
  final static int FILTER_TYPE_COUNT = 2;
  // Member variables.
  private int filterType;
  private float filterStrength;
  private float param1;
  private float param2;
  private Filter(int filterType, float filterStrength, float param1, float param2) {
    this.filterType = filterType;
    this.filterStrength = filterStrength;
    this.param1 = param1;
    this.param2 = param2;
  }
  Filter(int filterType, int strengthIndex) {
    this.filterType = filterType;
    this.filterStrength = getStrength(strengthIndex);
    this.param1 = getParam1(filterType, -1);
    this.param2 = getParam2(filterType, -1);
  }
  Filter(Filter sourceFilter, int param1Index, int param2Index) {
    this.filterType = sourceFilter.filterType;
    this.filterStrength = sourceFilter.filterStrength;
    this.param1 = getParam1(filterType, param1Index);
    this.param2 = getParam2(filterType, param2Index);
  }
  PImage renderFilter(PImage inputImage, Rectangle faceRect) {
    return drawers[filterType].renderFilter(inputImage, faceRect, filterStrength, param1, param2);
  }
}

abstract class FilterDrawer {
  abstract PImage renderFilter(PImage inputImage, Rectangle faceRect, float filterStrength, float param1, float param2);
}

class CheckerDrawer extends FilterDrawer {
  PImage renderFilter(PImage inputImage, Rectangle faceRect, float filterStrength, float param1, float param2) {
    return inputImage;
  }
}

class DiagonalDrawer extends FilterDrawer {
  PImage renderFilter(PImage inputImage, Rectangle faceRect, float filterStrength, float param1, float param2) {
    return inputImage;
  }
}

// @TODO create more drawers

FilterNode addFilterNode(FilterNode source, int type, int strengthIndex) {
  return new FilterNode(source, new Filter(type, strengthIndex), false);
}
FilterNode optimizeFilterNode(FilterNode source, int param1Index, int param2Index) {
  return new FilterNode(source, new Filter(source.lastFilter, param1Index, param2Index), true);
}

class FilterNode {
  FilterNode prevNode;
  Filter lastFilter;
  boolean isFilterOptimizationBranch;
  Float distanceToGoal;
  Float cost;
  private FilterNode(FilterNode prevNode, Filter lastFilter, boolean isFilterOptimizationBranch) {
    this.prevNode = prevNode;
    this.lastFilter = lastFilter;
    this.isFilterOptimizationBranch = isFilterOptimizationBranch;
    this.distanceToGoal = null;
    this.cost = null;
  }
  FilterNode() {
    this.prevNode = null;
    this.lastFilter = null;
    this.isFilterOptimizationBranch = true; // True because the next step must be a filter add.
    this.distanceToGoal = null;
    this.cost = null;
  }
  int getFilterType() {
    return lastFilter.filterType;
  }
  float getCost() {
    if (cost == null) {
      // @TODO: Define cost function.
      cost = 0.0;
      FilterNode p = this;
      while(p != null) {
        p = p.prevNode;
        cost += 20 * costFactor;
      }
    }
    return cost;
  }
  PImage renderImage(PImage inputImage, Rectangle faceRect) {
    if (isFilterOptimizationBranch) {
      if (prevNode == null) {
        return inputImage;
      } else if (prevNode.prevNode == null) {
        return inputImage;
      } else {
        return lastFilter.renderFilter(prevNode.prevNode.renderImage(inputImage, faceRect), faceRect);
      }
    } else {
      if (prevNode == null) {
        return inputImage;
      } else {
        return lastFilter.renderFilter(prevNode.renderImage(inputImage, faceRect), faceRect);
      }
    }
  }
  float getDistanceToGoal(PImage inputImage, Rectangle faceRect) {
    if (distanceToGoal == null) {
      PImage renderedImage = renderImage(inputImage, faceRect);
      float percentFace = openCVGetPercentFace(renderedImage);
      // @TODO
      distanceToGoal = percentFace * 100 - 5;
    }
    //println("\t\t distance to goal for [" + this + "] =\t" + distanceToGoal);
    return distanceToGoal;
  }
  // This method should only be called if you're sure that distance to goal has already been calculated.
  float getDistanceToGoal() {
    return distanceToGoal;
  }
}

float openCVGetPercentFace(PImage renderedImage) {
  // @TODO
  return random(1);
}

import java.awt.Rectangle;
import java.util.HashMap;

void setup() {
  size(640, 640);
  main();
}

void main() {
  String inputImagePath = "/Users/ken/Files/Programming/Facial Detection/data/control_320_240.jpg";
  Pimage inputImage = loadImage(inputImagePath,"jpg");
  Rectangle [] faceRects = findFaces(inputImage);
  aStarSearch(inputImage, faceRects);
}

FilterNode aStarSearch(PImage inputImage, Rectangle [] faceRects) {
  
  /* Initialize
   * openSet:    nodes to be evaluated
   * closedSet:  nodes already evaluated
   * cameFrom:   map node to the previous node on best known path
   * gScores:    map node to cost from start on best known path
   * fScores:    map node to gScore cost plus heuristic cost estimate
   */
  ArrayList<FilterNode> closedSet = new ArrayList<FilterNode>();
  ArrayList<FilterNode> openSet = new ArrayList<FilterNode>();
  FilterNode startNode = new FilterNode();
  openset.add(startNode);
  // Cam from may not be necessary
  HashMap<FilterNode><FilterNode> cameFrom = new HashMap<FilterNode><FilterNode>();
  HashMap<FilterNode><Float> gScores = new HashMap<FilterNode><Float>();
  HashMap<FilterNode><Float> fScores = new HashMap<FilterNode><Float>();
  gScores.put(startNode, 0.0);
  fScores.put(startNode, heuristicToGoal(startNode);
  
  while (!openset.isEmpty()) {
    current = getKeyWithMinValue(fScores);
    if (isInGoal(current)) {
      return current;
    }
    openSet.remove(current);
    closedSet.add(current);
    ArrayList<FilterNode> neighbors = getNeighborNodes(current);
    for (FilterNode n : neighbors) {
      // Get g score along path through current
      float tentativeGScore = gScores.get(current) + edgeCost(current, neighbor);
      // If this neighbor was visited earlier along another path, compare scores
      if (closedSet.contains(n) && tentativeGScore >= gScores.get(n)) {
        continue;
      }
      if (!openSet.contains(n) || tentativeGScore < gScores.get(n)) {
        cameFrom.put(n, current);
        gScores.put(n, tentativeGScore);
        fScores.put(n, tentativeGScore + heuristicToGoal(n);
        if (!openSet.contains(n)) {
          openSet.put(n);
        }
      }
    }
    System.out.println("No path found to goal.");
    return null;
  }
  
  float gScore = 0.0;
  float fScore = gScore
}

float edgeCost(FilterNode from, FilterNode to) {
  // TODO what is the cost to get from first node to second?
  return 0.0;
}

ArrayList<FilterNode> getNeighborNodes(FilterNode n) {
  // TODO populate list of neighbor nodes
  ArrayList<FilterNode> neighbors = new ArrayList<FilterNode>();
  return neighbors;
}

boolean isInGoal(FilterNode n) {
  // TODO do the applied filters hide all faces?
}

FilterNode getKeyWithMinValue(HashMap<FilterNode><Float> scores) {
  // TODO
  return null;
}

float heuristicToGoal(FilterNode n) {
  // TODO what is the estimated distance to goal from a FilterNode n
  return 0.0;
}

Rectangle [] findFaces(PImage img) {
  return null;
}

abstract class Filter {
}

class FilterNode {
}

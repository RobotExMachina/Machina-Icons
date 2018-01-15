/* 
  Refs:
    - https://processing.org/examples/directorylist.html
*/

import java.util.Date;

final String INPUT_FOLDER = "svgs";
final String OUTPUT_FOLDER_DYNAMO = "dynamoIcons";
final String DYNAMO_ICON_PREFIX = "MachinaDynamo.";
final int ICONSIZE_DYNAMO_LARGE = 128;
final int ICONSIZE_DYNAMO_SMALL = 32;
final String OUTPUT_FOLDER_GRASSHOPPER = "ghIcons";
final int ICONSIZE_GRASSHOPPER = 24;
final String OUTPUT_FORMAT = "png";

final color BLACK = #000000;
final color WHITE = #FFFFFF;
final color GREY = #2A2A2A;
final color RED = #FF6868;
final color BLUE = #2288FF;
final color GREEN = #00FF00;

String sketchPath, svgPath, ghPath, dynamoPath;

void setup() {
  sketchPath = sketchPath();
  svgPath = sketchPath + File.separator + INPUT_FOLDER;
  dynamoPath = sketchPath + File.separator + OUTPUT_FOLDER_DYNAMO;
  ghPath = sketchPath + File.separator + OUTPUT_FOLDER_GRASSHOPPER;

  File svgFiles = new File(svgPath);
  processSVGs(svgFiles);
}



void processSVGs(File selection) {
  File[] files = selection.listFiles();
  
  String filePath = "", 
      fileName = "", 
      fileNameMain = "", 
      fileExtension = "",
      outputPath = "";
  int sepIndex;
  
  PGraphics pg;
  
  int it = 0;
  for (File f : files) {
    
    if (f.isDirectory()) continue;
    
    filePath = f.getPath();
    fileName = f.getName();
    sepIndex = fileName.lastIndexOf('.');
    if (sepIndex > 0) {
      fileNameMain = fileName.substring(0, sepIndex);
      fileExtension = fileName.substring(sepIndex + 1);
    }
    
    if (!fileExtension.equalsIgnoreCase("svg")) 
      continue;
    println("Parsing " + f);
    //println(filePath + " " + fileName + " " + fileNameMain + " " + fileExtension);
    
    PShape shape = loadShape(filePath);
    
    // OUTPUT GRASSHOPPER ICONS
    outputPath = sketchPath + File.separator + 
          OUTPUT_FOLDER_GRASSHOPPER + File.separator + 
          fileNameMain + "." + OUTPUT_FORMAT;
    pg = createGraphics(ICONSIZE_GRASSHOPPER, ICONSIZE_GRASSHOPPER);
    pg.beginDraw();
    pg.shape(shape, 0, 0, ICONSIZE_GRASSHOPPER, ICONSIZE_GRASSHOPPER);
    println("Saving to " + outputPath);
    pg.save(outputPath);
    pg.endDraw();
    
    shape = replaceFill(shape, RED, GREEN, str(it));
    
    // OUTPUT DYNAMO ICONS
    // LARGE
    outputPath = sketchPath + File.separator + 
          OUTPUT_FOLDER_DYNAMO + File.separator + 
          DYNAMO_ICON_PREFIX + fileNameMain + ".Large." + OUTPUT_FORMAT;
    pg = createGraphics(ICONSIZE_DYNAMO_LARGE, ICONSIZE_DYNAMO_LARGE);
    pg.beginDraw();
    pg.shape(shape, 0, 0, ICONSIZE_DYNAMO_LARGE, ICONSIZE_DYNAMO_LARGE);
    println("Saving to " + outputPath);
    pg.save(outputPath);
    pg.endDraw();
    
    
    // SMALL
    outputPath = sketchPath + File.separator + 
          OUTPUT_FOLDER_DYNAMO + File.separator + 
          DYNAMO_ICON_PREFIX + fileNameMain + ".Small." + OUTPUT_FORMAT;
    pg = createGraphics(ICONSIZE_DYNAMO_SMALL, ICONSIZE_DYNAMO_SMALL);
    pg.beginDraw();
    pg.shape(shape, 0, 0, ICONSIZE_DYNAMO_SMALL, ICONSIZE_DYNAMO_SMALL);
    println("Saving to " + outputPath);
    pg.save(outputPath);
    pg.endDraw();
    
    it++;
    if (it > 1) break;
  }
  
  println("DONE! ;)");
  exit();
}

// A recursive function for fill color replacement
PShape replaceFill(PShape shape, color source, color target, String tracker) {
  println("Parsing: " + tracker);
  int childCount = shape.getChildCount();
  println("childCount: " + childCount);
  if (childCount > 0) {
    PShape[] children = shape.getChildren();
    for (int i = 0; i < children.length; i++) {
      //shape.removeChild(i);
      children[i] = replaceFill(children[i], source, target, tracker + i);
      //shape.addChild(children[i]);
    }
    
    //for (int i = 0; i < children.length; i++) {
    //  shape.removeChild(0);
    //}
    
    //for (int i = 0; i < children.length; i++) {
    //  shape.addChild(children[i]);
    //}
    
    
  } else {
    println("vertices: " + shape.getVertexCount());
    
    // Processing uses the int index to point at shape vertices. 
    // If out of the vertices array bounds, it will return the shape's fillColor
    // https://github.com/processing/processing/blob/89cce06b1c7fab974c1720b87e25c1af68c56b27/core/src/processing/core/PShape.java#L2356
    int fillClr = shape.getFill(Integer.MAX_VALUE);
    println(hex(source) + " vs. " + hex(fillClr));
    if (fillClr == source) {
      shape.setFill(target);
      println("color replaced");
    }
  }
  return shape;
}
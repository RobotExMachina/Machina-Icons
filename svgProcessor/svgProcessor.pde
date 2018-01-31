/* 
 A quick app to take a bunch of SVG files and turn them into PNGs.
 Some style manipulation is done to adjust to the different background
 conditions in Grasshopper/Dynamo.
 
 Refs:
 - https://processing.org/examples/directorylist.html
 
 Code by Jose Luis Garcia del Castillo: https://github.com/garciadelcastillo
 Icon design credits to Juliana Tennett: https://julianatennett.github.io
 
 Icons are not to be used or reproduced in any form without express consent 
 from the author (Juliana).
 
 TODO: 
   - [ ] Add clear output folders before exporting to clean up icons with obsolete names
   - [ ] Light gray doesn't look great on GH, darken it?
 */
 
final String INPUT_FOLDER = "svgs";
final String OUTPUT_FOLDER_DYNAMO = "dynamoIcons";
final String DYNAMO_ICON_PREFIX = "MachinaDynamo.";
final int ICONSIZE_DYNAMO_LARGE = 128;
final int ICONSIZE_DYNAMO_SMALL = 32;
final String OUTPUT_FOLDER_GRASSHOPPER = "ghIcons";
final int ICONSIZE_GRASSHOPPER = 24;
final String OUTPUT_FORMAT = "png";

final boolean CREATE_CONTACTS = true;
final color CONTACTS_BACKGROUND_GRASSHOPPER = color(210, 210, 210);
final color CONTACTS_BACKGROUND_DYNAMO = color(61, 61, 61);
final boolean CONTACTS_THUMBNAIL_BOX = false;
final int CONTACTS_MARGINS = 10;
final String CONTACTS_OUTPUT_FOLDER = "contacts";
final int CONTACTS_COLUMNS = 8;

final color BLACK = #2A2A2A;
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

    shape = replaceFill(shape, BLACK, WHITE, str(it));

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
  }

  if (CREATE_CONTACTS) {
    PImage img;

    // GRASSHOPPER CONTACTS
    String ghPath = outputPath = sketchPath + File.separator + OUTPUT_FOLDER_GRASSHOPPER;
    File ghFolder = new File(ghPath);
    File[] ghIcons = ghFolder.listFiles();
    println("Creating contact for " + ghIcons.length + " GH icons");

    int rowCount = ceil((float) ghIcons.length / CONTACTS_COLUMNS);
    int windowWidth = (1 + CONTACTS_COLUMNS) * CONTACTS_MARGINS + CONTACTS_COLUMNS * ICONSIZE_GRASSHOPPER;
    int windowHeight = (1 + rowCount) * CONTACTS_MARGINS + rowCount * ICONSIZE_GRASSHOPPER;
    pg = createGraphics(windowWidth, windowHeight);
    pg.beginDraw();
    pg.background(CONTACTS_BACKGROUND_GRASSHOPPER);

    int x = CONTACTS_MARGINS, 
      y = CONTACTS_MARGINS;
    for (File f : ghIcons) {
      img = loadImage(f.getPath());
      pg.image(img, x, y);

      if (CONTACTS_THUMBNAIL_BOX) {
        pg.stroke(0, 63);
        pg.noFill();
        pg.rect(x, y, ICONSIZE_GRASSHOPPER, ICONSIZE_GRASSHOPPER);
      }
      
      x += ICONSIZE_GRASSHOPPER + CONTACTS_MARGINS;
      if (x >= pg.width) {
        x = CONTACTS_MARGINS;
        y += ICONSIZE_GRASSHOPPER + CONTACTS_MARGINS;
      }
    }

    outputPath = sketchPath + File.separator + 
      CONTACTS_OUTPUT_FOLDER + File.separator + 
      "MachinaIcons_Grasshopper.png";
    pg.save(outputPath);
    pg.endDraw();
    
    
    
    // DYNAMO CONTACTS LARGE
    String dynPath = outputPath = sketchPath + File.separator + OUTPUT_FOLDER_DYNAMO;
    File dynFolder = new File(dynPath);
    File[] dynIcons = dynFolder.listFiles();
    println("Creating contact for " + dynIcons.length + " DYN icons");

    rowCount = ceil((0.5 * dynIcons.length) / CONTACTS_COLUMNS);
    windowWidth = (1 + CONTACTS_COLUMNS) * CONTACTS_MARGINS + CONTACTS_COLUMNS * ICONSIZE_DYNAMO_LARGE;
    windowHeight = (1 + rowCount) * CONTACTS_MARGINS + rowCount * ICONSIZE_DYNAMO_LARGE;
    pg = createGraphics(windowWidth, windowHeight);
    pg.beginDraw();
    pg.background(CONTACTS_BACKGROUND_DYNAMO);

    x = CONTACTS_MARGINS; 
    y = CONTACTS_MARGINS;
    for (File f : dynIcons) {
      if (!f.getPath().contains("Large")) {
        continue;
      }
      img = loadImage(f.getPath());
      pg.image(img, x, y);

      if (CONTACTS_THUMBNAIL_BOX) {
        pg.stroke(0, 63);
        pg.noFill();
        pg.rect(x, y, ICONSIZE_DYNAMO_LARGE, ICONSIZE_DYNAMO_LARGE);
      }
      
      x += ICONSIZE_DYNAMO_LARGE + CONTACTS_MARGINS;
      if (x >= pg.width) {
        x = CONTACTS_MARGINS;
        y += ICONSIZE_DYNAMO_LARGE + CONTACTS_MARGINS;
      }
    }

    outputPath = sketchPath + File.separator + 
      CONTACTS_OUTPUT_FOLDER + File.separator + 
      "MachinaIcons_Dynamo_Large.png";
    pg.save(outputPath);
    pg.endDraw();
    
    // DYNAMO CONTACTS SMALL
    windowWidth = (1 + CONTACTS_COLUMNS) * CONTACTS_MARGINS + CONTACTS_COLUMNS * ICONSIZE_DYNAMO_SMALL;
    windowHeight = (1 + rowCount) * CONTACTS_MARGINS + rowCount * ICONSIZE_DYNAMO_SMALL;
    pg = createGraphics(windowWidth, windowHeight);
    pg.beginDraw();
    pg.background(CONTACTS_BACKGROUND_DYNAMO);

    x = CONTACTS_MARGINS; 
    y = CONTACTS_MARGINS;
    for (File f : dynIcons) {
      if (!f.getPath().contains("Small")) {
        continue;
      }
      img = loadImage(f.getPath());
      pg.image(img, x, y);

      if (CONTACTS_THUMBNAIL_BOX) {
        pg.stroke(0, 63);
        pg.noFill();
        pg.rect(x, y, ICONSIZE_DYNAMO_SMALL, ICONSIZE_DYNAMO_SMALL);
      }
      
      x += ICONSIZE_DYNAMO_SMALL + CONTACTS_MARGINS;
      if (x >= pg.width) {
        x = CONTACTS_MARGINS;
        y += ICONSIZE_DYNAMO_SMALL + CONTACTS_MARGINS;
      }
    }

    outputPath = sketchPath + File.separator + 
      CONTACTS_OUTPUT_FOLDER + File.separator + 
      "MachinaIcons_Dynamo_Small.png";
    pg.save(outputPath);
    pg.endDraw();
  }
  
  

  println("DONE! ;)");
  exit();
}

// A recursive function for fill color replacement
PShape replaceFill(PShape shape, color source, color target, String tracker) {
  int childCount = shape.getChildCount();
  //println("Parsing: " + tracker);
  //println("childCount: " + childCount);

  // Go one lever deeper or replace styles instead
  if (childCount > 0) {
    PShape[] children = shape.getChildren();
    for (int i = 0; i < children.length; i++) {
      children[i] = replaceFill(children[i], source, target, tracker + i);
    }
  } else {
    //println("vertices: " + shape.getVertexCount());

    // Processing uses the int index to point at shape vertices. 
    // If out of the vertices array bounds, it will return the shape's fillColor
    // https://github.com/processing/processing/blob/89cce06b1c7fab974c1720b87e25c1af68c56b27/core/src/processing/core/PShape.java#L2356
    int fillClr = shape.getFill(Integer.MAX_VALUE);
    if (fillClr == source) {
      shape.setFill(target);
      println("fill color replaced: " + hex(fillClr) + " vs. " + hex(target));
    }

    int strokeColor = shape.getStroke(Integer.MAX_VALUE);
    if (strokeColor == source) {
      shape.setStroke(target);
      println("stroke color replaced: " + hex(strokeColor) + " vs. " + hex(target));
    }
  }
  return shape;
}
import controlP5.*;
import processing.pdf.*;

ControlP5 cp5;
Slider slBrightness;
Slider slThreshold;

PImage img1, title;
boolean game_started = false;
boolean screen_resized = false;
boolean img_displayed = false, display = false;
int brightnessValue = 10;
int thresholdValue = 50;
PFont font;
float v = 1.0 / 9.0;
float[][] kernel = {{ v, v, v },{ v, v, v },{ v, v, v }};
float[][] identity = { { 0, 0, 0 },{ 0, 1, 0 },{ 0, 0, 0 } };
float[][] darken =   { { 0, 0, 0 },{ 0, 0.5, 0 },{ 0, 0, 0 } };
float[][] lighten =  { { 0, 0, 0 },{ 0, 2, 0 },{ 0, 0, 0 } };
float[][] sharpen =  { {  0, -1,  0 },{ -1,  5, -1 },{  0, -1,  0 } };
float[][] sharpen2 = { { -1, -1, -1 },{ -1,  9, -1 },{ -1, -1, -1 } };
float[][] edge_det = { { 0,  1, 0 },{ 1, -4, 1 },{ 0,  1, 0 } };
float[][] embossKernel =   { { -2, -1, 0 },{ -1,  1, 1 },{  0,  1, 2 } };
int effect = 0;
float[][][] effects = {identity,darken,lighten,sharpen,sharpen2,edge_det,embossKernel};
String[] effect_names = {"None", "Darken","Lighten","Sharpen","Sharpen More","Box Blur","Edge Detect","Emboss"};
boolean reverse = false, blur = false;
boolean home = false, reset = false;
boolean dark=false,light=false,sharp=false,sharper=false,edgeDetect=false,emboss=false;
int threshold = 0;
Button reverseB, exportB, blurB, homeB, resetB, thresholdB;

void setup() {
  //noLoop();
  size(1200, 640);
  surface.setResizable(true);
  colorMode(HSB, 360, 100, 100);
  font = createFont("Times New Roman", 128);
  textFont(font);
  textSize(20);
  fill(120);
  background(23, 7, 92);
  textSize(80);
  textAlign(CENTER);
  title = loadImage("FilterFun.png");
  
  reverseB = new Button(10, 40, 100, 30, "REVERSE");
  exportB = new Button(10, 40, 100, 30,"EXPORT");
  blurB = new Button(10, 80, 100, 30,"BLUR");
  homeB = new Button(10, 10, 100, 30,"HOME");
  resetB = new Button(10, 50, 100, 30,"RESET");
  thresholdB = new Button(1, 120, 20, 20,"");
  
  // GUI will be automatically drawn after each draw() call. 
  cp5 = new ControlP5(this);
  slBrightness = cp5.addSlider("brightnessValue");
  slBrightness.setPosition(1, 10);
  slBrightness.setSize(100, 20);
  slBrightness.setRange(0, 80);
  slBrightness.setColorCaptionLabel(color(255,0,0));
  slBrightness.setCaptionLabel("Brightness");
  
  slThreshold = cp5.addSlider("thresholdValue");
  slThreshold.setPosition(35, 120);
  slThreshold.setSize(69, 20);
  slThreshold.setRange(30, 70);
  slThreshold.setColorCaptionLabel(color(255,0,0));
  slThreshold.setCaptionLabel("Threshold");
  cp5.getController("brightnessValue").setVisible(false);
  cp5.getController("thresholdValue").setVisible(false);
}

void draw() {
  if (screen_resized == false && game_started==false) {
    fill(0,100,50);
    textSize(20);
    textAlign(CENTER);
    text("PRESS SPACE TO IMPORT AN IMAGE", width*0.5, height*0.15);
    fill(0,100,100);
    textSize(40);
    //text("FilterFun", width*0.5, height*0.65);
    image(title,width*0.29, height*0.25);
    return;
  }
  else if (screen_resized == true && game_started==false && display==false) {
    surface.setSize(img1.width+300, img1.height+30);
    fill(0,100,50);
    textAlign(CENTER);
    text("CLICK TO DISPLAY THE IMAGE", width*0.5, height*0.35);
    img1.loadPixels();
  }
  if (display == true ) {
    image(img1,150,0);
    display = false;
    img_displayed = true;
    game_started = true;
  }
  if (game_started == true){
    image(img1,150,0);
    cp5.getController("brightnessValue").setVisible(true);
    cp5.getController("thresholdValue").setVisible(true);
    fill(23, 7, 92);
    noStroke();
    rect(0,height-30,width-150,30);
    fill(0,100,50);
    textSize(15);
    //textAlign(RIGHT);
    text("Press a number between 0 and 6 to switch filters: "+effect_names[effect], width*0.35, height-15);
    
    exportB.buttonX = width - 120;
    exportB.buttonY = height - 60;
    homeB.buttonX = width - 120;
    resetB.buttonX = width - 120;
    
    update(mouseX, mouseY);
    
    if(home==true){
      cp5.getController("brightnessValue").setVisible(false);
      cp5.getController("thresholdValue").setVisible(false);
      colorMode(HSB, 360, 100, 100);
      background(23, 7, 92);
      img_displayed = false;
      game_started = false;
      screen_resized = false;
      effectsToFalse();
      home = false;
      reset=true;
      return;
    }
    if(reset==true){
      blur = false;
      brightnessValue = 10;
      reverse = false;
      effectsToFalse();
      effect=0;
      threshold = 50;
      //image(img1,0,0);
      reset=false;
    }
    
    img1.loadPixels();
    loadPixels();
    int loc;
    float g, r, b;
    
    //Brightness
    for (int x = 0; x < img1.width; x++ ) {
      for (int y = 0; y < img1.height; y++ ) {
        colorMode(RGB);
        loc = (x+150) + y*width;
        b = blue(pixels[loc]);
        g = green(pixels[loc]);
        r = red(pixels[loc]);
        
        float newBrightness = float(brightnessValue) / 10.0;
        
        r *= newBrightness;
        b *= newBrightness;
        g *= newBrightness;
        
        r = constrain(r, 0, 255); 
        g = constrain(g, 0, 255);
        b = constrain(b, 0, 255);
        color c = color(r, g, b);
        //img1.pixels[loc] = c;
        pixels[loc]=c;
      }
    }
       
      // Blur
      if(blur==true){
        for (int y = 1; y < img1.height-1; y++) {   // Skip top and bottom edges
          for (int x = 1; x < img1.width-1; x++) {  // Skip left and right edges
            loc = (x+150) + y*width;
            float sumRed = 0;   // Kernel sums for this pixel
            float sumGreen = 0;
            float sumBlue = 0;
            for (int ky = -1; ky <= 1; ky++) {
              for (int kx = -1; kx <= 1; kx++) {
                // Calculate the adjacent pixel for this kernel point
                int pos = (y + ky)*width + (x + kx +150);
      
                // Process each channel separately, Red first.
                float valRed = red(pixels[pos]);
                // Multiply adjacent pixels based on the kernel values
                sumRed += kernel[ky+1][kx+1] * valRed;
      
                // Green
                float valGreen = green(pixels[pos]);
                sumGreen += kernel[ky+1][kx+1] * valGreen;
      
                // Blue
                float valBlue = blue(pixels[pos]);
                sumBlue += kernel[ky+1][kx+1] * valBlue;  
              }
            }
            pixels[loc] = color(sumRed,sumGreen,sumBlue);
          }
        }
      }
       
      //reverseImg
      if(reverse==true){
        for (int y = 0; y < img1.height-1; y++) {   // Skip top and bottom edges
          for (int x = 0; x < ceil(((img1.width)/2))+1; x++) {  // Skip left and right edges
            //print("h");
            loc = y*width + (x+150);
            b = blue(pixels[loc]);
            g = green(pixels[loc]);
            r = red(pixels[loc]);
            color cint = color(r,g,b);
            pixels[loc] = pixels[(y+1)*width - (x+150)];
            pixels[(y+1)*width - (x+150)] = cint;
          }
        }
      }
    
    // Threshold
    if(threshold%2 == 1){
      for (int x = 0; x < img1.width; x++ ) {
        for (int y = 0; y < img1.height; y++ ) {
          loc = (x+150) + y*width;
          // Test the brightness against the threshold
          if (brightness(pixels[loc]) > thresholdValue){
            pixels[loc] = color(360); 
          } else {
            pixels[loc] = color(0);   
          }
        }
      }  
    }
    
    //Effect
    effect = findEffect();
    int matrixsize = 3;
    if(effect!=0){
      for (int x = 0; x < img1.width; x++) {
        for (int y = 0; y < img1.height; y++ ) {
          color c = convolution(x, y, effects[effect], matrixsize, img1);
          loc = (x+150) + y*width;
          pixels[loc] = c;
        }
      }
    }
    img1.updatePixels();
    updatePixels(); 
    colorMode(HSB, 360, 100, 100);
    
    exportB.displayButton();
    reverseB.displayButton();
    blurB.displayButton();
    homeB.displayButton();
    resetB.displayButton();
    thresholdB.displayButton();
    
  }
}

void mouseClicked() {
  if (game_started == false && screen_resized == true && img_displayed == false) {
    display = true;
  } else if (reverseB.buttonOver==true) {
    reverse = true;
  }else if (exportB.buttonOver==true) {
    save("result.png");
    exit();
  }else if (blurB.buttonOver==true) {
    blur = true;
  }else if (homeB.buttonOver==true) {
    home = true;
  }else if (resetB.buttonOver==true) {
    reset = true;
  } else if (thresholdB.buttonOver==true) {
    threshold++;
  }
}

//Select file
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    exit();
  } else {
    println("User selected " + selection.getAbsolutePath());
    img1 = loadImage(selection.getAbsolutePath());
    screen_resized = true;
  }
}

void keyPressed() {
  if (game_started == false && screen_resized == false && key == ' ') {
    selectInput("Select a file to process:", "fileSelected");
  } else if (screen_resized == true && img_displayed == false && key==' ') {
    display=true;
  } else if(img_displayed==true){
      switch(key){
        case '0':
          effectsToFalse();
          break;
        case '1':
          effectsToFalse();
          dark=true;
          break;
        case '2':
          effectsToFalse();
          light = true;
          break;
        case '3':
          effectsToFalse();
          sharp = true;
          break;
        case '4':
          effectsToFalse();
          sharper = true;
          break;
        case '5':
          effectsToFalse();
          edgeDetect = true;
          break;
        case '6':
          effectsToFalse();
          emboss = true;
          break;
        default:
          break;
      }
  }
}

void update(int x, int y) {
  if ( overButton(exportB.buttonX, exportB.buttonY, exportB.buttonWidth, exportB.buttonHeight) ) {
    exportB.buttonOver = true;
  } else if (overButton(reverseB.buttonX, reverseB.buttonY, reverseB.buttonWidth, reverseB.buttonHeight)){
    reverseB.buttonOver = true;
  } else if (overButton(blurB.buttonX, blurB.buttonY, blurB.buttonWidth, blurB.buttonHeight)){
    blurB.buttonOver = true;
  } else if (overButton(homeB.buttonX, homeB.buttonY, homeB.buttonWidth, homeB.buttonHeight)){
    homeB.buttonOver = true;
  } else if (overButton(resetB.buttonX, resetB.buttonY, resetB.buttonWidth, resetB.buttonHeight)){
    resetB.buttonOver = true;
  } else if (overButton(thresholdB.buttonX, thresholdB.buttonY, thresholdB.buttonWidth, thresholdB.buttonHeight)){
    thresholdB.buttonOver = true;
  } else {
    exportB.buttonOver = false;
    reverseB.buttonOver = false;
    blurB.buttonOver = false;
    homeB.buttonOver = false;
    resetB.buttonOver = false;
    thresholdB.buttonOver = false;
  }
}

boolean overButton(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void effectsToFalse(){
    dark=false;
    light=false;
    sharp=false;
    sharper=false;
    edgeDetect=false;
    emboss=false;
}

int findEffect(){
  if(dark==true)
    return 1;
  else if(light==true)
    return 2;
  else if(sharp==true)
    return 3;
  else if(sharper==true)
    return 4;
  else if(edgeDetect==true)
    return 5;
  else if(emboss==true)
    return 6;
  else
    return 0;
}

color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img)
{
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  for (int i = 0; i < matrixsize; i++){
    for (int j= 0; j < matrixsize; j++){
      // What pixel are we testing
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      // Make sure we haven't walked off our image, we could do better here
      loc = constrain(loc,0,img.pixels.length-1);
      // Calculate the convolution
      rtotal += (red(img.pixels[loc]) * matrix[i][j]);
      gtotal += (green(img.pixels[loc]) * matrix[i][j]);
      btotal += (blue(img.pixels[loc]) * matrix[i][j]);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  // Return the resulting color
  return color(rtotal, gtotal, btotal);
}

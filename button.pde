class Button {

  int buttonX, buttonY, buttonWidth, buttonHeight;
  boolean buttonOver;
  color buttonColor;
  String buttonText;

  Button(int x, int y, int widthB, int heightB, String t) {
    buttonX = x;
    buttonY = y;
    buttonWidth = widthB;
    buttonHeight = heightB;
    buttonOver = false;
    colorMode(HSB, 360, 100, 100);
    buttonColor = color(25,100,80);
    buttonText = t;
  }

  void displayButton() {
    stroke(0);
    colorMode(HSB, 360, 100, 100);
    if(buttonOver==true){
      buttonColor = color(5,100,80);
    }else{
      buttonColor = color(25,100,80);;
    }
    fill(buttonColor);
    rect(buttonX, buttonY, buttonWidth, buttonHeight);
    fill(0,100,0);
    textSize(15);
    text(buttonText,buttonX+int(buttonWidth/2),buttonY+int(buttonHeight/2)+5);
  }

  void setColor(color c) {
    buttonColor = c;
  }
  
}

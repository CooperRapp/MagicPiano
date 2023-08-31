import controlP5.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.*;

Minim minim; // set up the minim object
ControlP5 cp5; // set up the controlp5 object
FilePlayer player; // set up the audioplayer object
TickRate speed; // set up the Tickrate object 
Oscil wave; // set up the wave to for the music playing
AudioOutput out; // set up the audio ouput object
Gain gain;
Knob gainKnob;
ControlTimer timer;

PFont sourceLight;
color col1, col2, col3, colPlay, colStop, colRestart, colPickASong;
boolean play, songPicked, wavePlaying;
int score, moving1, moving2, moving3, missedTiles;
float defaultHeight, defaultWidth, laneOne, laneTwo, laneThree, timer1, timer2, timer3, time, rate;
String songName;

void setup() {
  size(900, 600);
  background(62, 77, 128);
  
  minim = new Minim(this); // initialize the Minim variable
  cp5 = new ControlP5(this); // initialize the ControlP5 variable
  gain = new Gain(0f); // set the gain to 0 dB, so there is no initial change to amplitude
  wave = new Oscil(440, 0.5, Waves.SINE); // set to 440 hz, 0.5 amplitude, and a sine wave by default
  timer = new ControlTimer(); 
  speed = new TickRate(1f); 
  
  sourceLight = createFont("neon.ttf", 34);
  textFont(sourceLight);
  
  col1 = col2 = col3 = color(255, 255, 255, 150);  
  colPlay = colStop = colRestart = colPickASong = color(174, 181, 212);
  
  play = false;
  songPicked = false;
  
  score = 0;
  rate = 1;
  moving1 = moving2 = moving3 = 0; // moving variable for each lane
  laneOne = laneTwo = laneThree = -9999;
  
  defaultHeight = 100;
  defaultWidth = 150;
  
  cp5.addToggle("songWave") // creating the toggle to switch between heairng the song and the oscil
     .setPosition(790, 280)
     .setSize(60, 20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     .setLabel("song     |    wave")
     .setColorBackground(#21294a);
     
  cp5.addButton("sine") // creating the button to switch to the sine wave
     .setPosition(790, 322)
     .setSize(60, 25)
     .setColorBackground(#21294a);
     
  cp5.addButton("triangle") // creating the button to switch to the triangle wave
     .setPosition(790, 352)
     .setSize(60, 25)
     .setColorBackground(#21294a);
     
  cp5.addButton("square") // creating the button to switch to the square wave
     .setPosition(790, 382)
     .setSize(60, 25)
     .setColorBackground(#21294a);
     
  cp5.addButton("saw") // creating the button to switch to the saw wave
     .setPosition(790, 412)
     .setSize(60, 25)
     .setColorBackground(#21294a);
     
  gainKnob = cp5.addKnob("gain") // creating the knob to control the gain
     .setRange(-8, 8)
     .setValue(0)
     .setPosition(500, 472)
     .setNumberOfTickMarks(8)
     .setTickMarkLength(5)
     .snapToTickMarks(true)
     .setRadius(40)
     .setColorBackground(#21294a);
     
  cp5.addSlider("pan") // creating the slider to control the pan
     .setPosition(630, 500)
     .setRange(-1, 1)
     .setNumberOfTickMarks(5)
     .setSize(205, 35)
     .snapToTickMarks(true)
     .setColorBackground(#21294a);
     
     
  // setting up the timers
  // giving each timer a unique value from 1-7 then multiplying by 1000 to convert to milliseconds
  // using CP5's ControlTimer() we can track the amount of milliseconds passed when the user clicked play and figure out when to 'spawn' in our blocks for each lane
  timer1 = timer2 = timer3 = 0;
  while(timer1 == timer2 || timer1 == timer3 || timer2 == timer3) { 
    timer1 = int (random(1, 7));
    timer2 = int (random(1, 7));
    timer3 = int (random(1, 7));
  }
  timer1 *= 1000;
  timer2 *= 1000;
  timer3 *= 1000;

}

void draw() {
  background(62, 77, 128);
  strokeWeight(1);
 
  // -----MOVING RECT'S (GAMEPLAY)-----
  if(play && songPicked) {
    
    // slowing down the song based on the players missed tiles
    if(missedTiles == 0) rate = 1;
    else if(missedTiles == 1) rate = 0.8;
    else if(missedTiles == 2) rate = 0.6;
    else if(missedTiles == 3) rate = 0.4;
    speed.value.setLastValue(rate);
    if(missedTiles > 3) missedTiles = 3;
    
    // LANE ONE
    if(timer.time() >= timer1) {
      fill(247, 108, 27); // orange
      rect(0, moving1, defaultWidth, defaultHeight); // drawing block
      moving1 += 3; // speed of block
      laneOne = 575 - (moving1 + (defaultWidth/2)); // keeps track of where the block is in the lane
      if(laneOne < -100) { // if the block is off the screen we can reset it back to the top of the lane and add one to their total missed tiles
        moving1 = 0;
        missedTiles++;
      } 
      
    }
    
    // LANE TWO
    if(timer.time() >= timer2) {
      fill(20, 219, 93); // lime green
      rect(150, moving2, defaultWidth, defaultHeight); // drawing block
      moving2 += 3; // speed of block
      laneTwo = 575 - (moving2 + (defaultWidth/2)); // keeps track of where the block is in the lane
      if(laneTwo < -100) { // if the block is off the screen we can reset it back to the top of the lane and add one to their total missed tiles
         moving2 = 0;
         missedTiles++;
      } 
      
    }
    
    // LANE THREE
    if(timer.time() >= timer3) {
      fill(250, 32, 243); // pink
      rect(300, moving3, defaultWidth, defaultHeight); // drawing block
      moving3 += 3; // speed of block
      laneThree = 575 - (moving3 + (defaultWidth/2)); // keeps track of where the block is in the lane
      if(laneThree < -100) { // if the block is off the screen we can reset it back to the top of the lane and add one to their total missed tiles
        moving3 = 0;
        missedTiles++;
      } 
    
    }
    
  }
  // if we are not playing the game then we can use the space to display the instructions
  else if(!play) {
    textSize(20);
    text("To get points you need to press the correct key, '1' '2' '3', when the rect coming down the lane is in the same lane box. If you press the key when the rect is not in the correct area then you will lose points.",
    80, 130, 300, 200);
    text("To start pick a song from your personal library and press 'Play'.", 80, 350, 300, 200);
    
  }
  
  // -----BUTTONS-----
  fill(col1);
  rect(0, 500, 150, 100); // left button
  
  fill(col2);
  rect(150, 500, 150, 100); // middle button
  
  fill(col3);
  rect(300, 500, 150, 100); // right button
  
  fill(0);
  textSize(25);
  text("1", 70, 555); // left button
  text("2", 220, 555); // middle button
  text("3", 370, 555); // right button
  
  fill(colPlay);
  rect(570, 110, 60, 40); // play button
  
  fill(colStop);
  rect(650, 110, 60, 40); // pause button
  
  fill(colRestart);
  rect(730, 110, 60, 40); // restart button
  
  fill(colPickASong);
  rect(580, 165, 200, 60); // pick a song button
  
  fill(0);
  textSize(17);
  text("Play", 582.5, 135); // play button text
  text("Stop", 662.5, 135); // pause/stop button text
  text("Restart", 735, 135); // restart button text
  textSize(32);
  text("Pick A Song", 592.5, 207); // pick a song button text
  
  if(songPicked) {
    textSize(16);
    text("Currently Playing - " + songName, 570, 250);
  }
 
  // -----OTHER GUI STUFF-----
  stroke(33, 41, 74);
  strokeWeight(10);
  line(455, height, 455, 0); //divider between game and info panel
  stroke(0);
  
  if(score < 0) { // making it so the score cannot be below 0
    score = 0;
  }
  textSize(45);
  text(score, 650, 75); // displaying score
  
  strokeWeight(1);
  fill(33, 41, 74);
  rect(500, 280, 250, 157); // area behind wave
  
  // ----- WAVE DRAWING -----
  if(songPicked) {
    strokeWeight(0.5);
    stroke(255);
    // taken from the 'frequencyExample' minim example, but mapped to my projects specifications
    // doesn't draw the left and the right but a mix of both --> out.mix.get()
    for(int i = 0; i < out.bufferSize() - 1; i++) {
      float x1 = map(i, 305, out.bufferSize(), 575, 750); 
      float x2 = map(i + 1, 305, out.bufferSize(), 575, 750);
      line( x1, 365 - out.mix.get(i)*50,  x2, 365  - out.left.get(i+1)*50 );
    }
    stroke(0);
    
  } 
    
}

void keyPressed() {
  if(key == '1') {
    col1 = color(200, 200, 200, 200); // dimming the color if they hit the key for visual feedback
    
  }
  else if(key == '2') {
    col2 = color(200, 200, 200, 200); // dimming the color if they hit the key for visual feedback
    
  }
  else if(key == '3') {
    col3 = color(200, 200, 200, 200); // dimming the color if they hit the key for visual feedback
    
  }
  
}

void keyReleased() {
  if(key == '1') {
    col1 = color(255, 255, 255, 150);
    
    if(laneOne >= -30 && laneOne <= 30) { // checks if the user hits the key when the moving block is right in the middle of the correct area
      score += 50; // give points
      moving1 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    } 
    else if(laneOne >= -55 && laneOne <= 55) { // checks if the user hits the key when the moving block is halfway in the correct area
      score += 25; // give points
      moving1 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    }
    else if(laneOne >= -75 && laneOne <= 75) { // checks if the user hits the key when the moving block is barely in the correct area
      score += 10; // give points
      moving1 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    }
    
    
  }
  else if(key == '2') {
    col2 = color(255, 255, 255, 150);
    
    if(laneTwo >= -30 && laneTwo <= 30) { // checks if the user hits the key when the moving block is right in the middle of the correct area
      score += 50; // give points
      moving2 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    } 
    else if(laneTwo >= -55 && laneTwo <= 55) { // checks if the user hits the key when the moving block is halfway in the correct area
      score += 25; // give points
      moving2 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    } 
    else if(laneTwo >= -75 && laneTwo <= 75) { // checks if the user hits the key when the moving block is barely in the correct area
      score += 10; // give points
      moving2 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    }
    
  }
  else if(key == '3') {
    col3 = color(255, 255, 255, 150);
    
    if(laneThree >= -30 && laneThree <= 30) { // checks if the user hits the key when the moving block is right in the middle of the correct area
      score += 50; // give points
      moving3 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    } 
    else if(laneThree >= -55 && laneThree <= 55) { // checks if the user hits the key when the moving block is halfway in the correct area
      score += 25; // give points
      moving3 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    }
    else if(laneThree >= -75 && laneThree <= 75) { // checks if the user hits the key when the moving block is barely in the correct area
      score += 10; // give points
      moving3 = 0; // reset
      if(missedTiles > 0) missedTiles--; // they got points for a tile which means they didn't miss it so we can speed back up the song
    }
    
  }
  
}

void mousePressed() {  
  // check if the user clicks mouse when it is inside the bounds of the play rect()
  if(mouseX <= 630 && mouseX >= 570 && mouseY <= 150 && mouseY >= 110) {
    colPlay = color(126, 140, 194); // visual feedback
    play = true; 
    if(songPicked) {
      player.loop(); // start the song
      timer = new ControlTimer(); // start the timer for when the blocks should 'spawn'
    } 
  
  }
  // check if the user clicks mouse when it is inside the bounds of the stop rect()
  else if(mouseX <= 710 && mouseX >= 650 && mouseY <= 150 && mouseY >= 110) {
    colStop = color(126, 140, 194); // visual feedback
    
    if(songPicked && play) { 
      player.pause(); // pause the music playing 
    }
    play = false;
        
  }
  // check if the user clicks mouse when it is inside the bounds of the restart rect()
  else if(mouseX <= 790 && mouseX >= 730 && mouseY <= 150 && mouseY >= 110) {
    colRestart = color(126, 140, 194); // visual feedback
    // if the user hits the restart button then we restart the song, reset their score, and move the blocks back to the top
    player.rewind(); 
    score = 0;
    moving1 = moving2 = moving3 = 0;
    
  }
  // check if clicking the pick-a-song button
  else if(mouseX <= 780 && mouseX >= 580 && mouseY <= 225 && mouseY >= 165 && !play) {
    selectInput("Select a file to process:", "fileSelected"); // opens up the users files for them to pick their song of choice
    
  }
  
}

void mouseReleased() {
  // put the buttons back to their original color
  colPlay = color(174, 181, 212); 
  colStop = color(174, 181, 212);
  colRestart = color(174, 181, 212);
  
}

void fileSelected(File file) {
  if (file == null) { // error checking with the user files
    println("Window was closed or the user hit cancel.");
    
  } 
  else {
    // getting the name of the song they selected and passing it into the FilePlayer
    player = new FilePlayer(minim.loadFileStream(file.getAbsolutePath())); 
    out = minim.getLineOut(); // setting up the AudioOutput 
    
    player.patch(speed).patch(out); // patching the TickRate object and AudioOuput through the FilePlayer
    
    println(file.getName() + " loaded."); // error checking
    songName = file.getName(); // getting the name of the song to display for the user
    songPicked = true;
    
  }
  
}

// the function for the CP5 switch
// used to swap between hearing the song and the oscilator
void songWave(boolean flag) { 
  if(songPicked) {
    if(flag == true) {
      wave.unpatch(out);
      player.patch(speed).patch(out);
      
    }
    else {
      player.unpatch(out);
      speed.unpatch(out);
      wave.patch(out);
      
    }
    
  }
  
}



void sine(boolean flag) { // switch the oscilator to a SINE wave
  if(flag) wave.setWaveform(Waves.SINE);
  
}
 
void triangle(boolean flag) { // switch the oscilator to a TRIANGLE wave
  if(flag) wave.setWaveform(Waves.TRIANGLE);
  
}

void square(boolean flag) { // switch the oscilator to a SQUARE wave
  if(flag) wave.setWaveform(Waves.SQUARE);
  
}

void saw(boolean flag) { // switch the oscilator to a SAW wave
  if(flag) wave.setWaveform(Waves.SAW);
  
}

void gain(float dB) { // accessing the CP5 knob to control the gain of the music
  if(songPicked) {
    out.setGain(dB);
  }
  
}

void pan(float value) { // acessing the CP5 slider to pan the song
  if(songPicked) {
    out.setPan(value);
      
  }
  
}

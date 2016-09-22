//**************************** user actions ****************************
void keyPressed()  // executed each time a key is pressed: sets the Boolean "keyPressed" till it is released   
                    // sets  char "key" state variables till another key is pressed or released
    {
  
    if(key=='~') recordingPDF=true; // to snap an image of the canvas and save as zoomable a PDF, compact and great quality, but does not always work
    if(key=='!') snapJPG=true; // make a .PDF picture of the canvas, compact, poor quality
    if(key=='@') snapTIF=true; // make a .TIF picture of the canvas, better quality, but large file
    if(key=='#') ;
    if(key=='$') ;
    if(key=='%') ; 
    if(key=='^') ;
    if(key=='&') ;
    if(key=='*') ;    
    if(key=='(') ;
    if(key==')') ;  
    if(key=='_') ;
    if(key=='+') ;

    if(key=='`') filming=!filming;  // filming on/off capture frames into folder IMAGES/MOVIE_FRAMES_TIF/
    if(key=='1') ;               // toggles what should be displayed at each fram
    if(key=='2') ;
    if(key=='3') ;
    if(key=='4') ;
    if(key=='5') ;
    if(key=='6') ;
    if(key=='7') ;
    if(key=='8') ;
    if(key=='9') ;
    if(key=='0') ; 
    if(key=='-') ;
    if(key=='=') ;

    if(key=='a') ; 
    if(key=='b') ; 
    if(key=='c') P.resetOnCircle(4);
    if(key=='d') ; 
    if(key=='e') ;
    if(key=='f') ;
    if(key=='g') ; 
    if(key=='h') ;
    if(key=='i') ; 
    if(key=='j') ;
    if(key=='k') ;   
    if(key=='l') ;
    if(key=='m') ;
    if(key=='n') state++;
    if(key=='o') ;
    if(key=='p') ;
    if(key=='q') ; 
    if(key=='r') ; // used in mouseDrag to rotate the control points 
    if(key=='s') ;
    if(key=='t') ; // used in mouseDrag to translate the control points 
    if(key=='p') ;
    if(key=='v') ; 
    if(key=='w') ;  
    if(key=='x') ;
    if(key=='y') ;
    if(key=='z') ; // used in mouseDrag to scale the control points

    if(key=='A') ;
    if(key=='B') ; 
    if(key=='C') ; 
    if(key=='D') ;  
    if(key=='E') ;
    if(key=='F') ;
    if(key=='G') ; 
    if(key=='H') ; 
    if(key=='I') ; 
    if(key=='J') ;
    if(key=='K') ;
    if(key=='L') P.loadPts("data/pts");    // load current positions of control points from file
    if(key=='M') ;
    if(key=='N') ;
    if(key=='O') ;
    if(key=='P') state--; 
    if(key=='Q') exit();  // quit application
    if(key=='R') ; 
    if(key=='S') P.savePts("data/pts");    // save current positions of control points on file
    if(key=='T') ;
    if(key=='U') ;
    if(key=='V') ;
    if(key=='W') ;  
    if(key=='X') ;  
    if(key=='Y') ;
    if(key=='Z') ;  

    if(key=='{') ;
    if(key=='}') ;
    if(key=='|') ; 
    
    if(key=='[') ; 
    if(key==']') P.fitToCanvas();  
    if(key=='\\') ;
    
    if(key==':') ; 
    if(key=='"') ; 
    
    if(key==';') ; 
    if(key=='\''); 
    
    if(key=='<') ;
    if(key=='>') ;
    if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
   
    if(key==',') ;
    if(key=='.') ;  // used in mousePressed to tweak current frame f
    if(key=='/') ;
  
    if(key==' ') ;
  
    if (key == CODED) 
       {
       String pressed = "Pressed coded key ";
       if (keyCode == UP) {pressed="UP";   }
       if (keyCode == DOWN) {pressed="DOWN";   };
       if (keyCode == LEFT) {pressed="LEFT";   };
       if (keyCode == RIGHT) {pressed="RIGHT";   };
       if (keyCode == ALT) {pressed="ALT";   };
       if (keyCode == CONTROL) {pressed="CONTROL";   };
       if (keyCode == SHIFT) {pressed="SHIFT";   };
       println("Pressed coded key = "+pressed); 
       } 
  
    change=true; // to make sure that we save a movie frame each time something changes
    //println("key pressed = "+key);

    }

void mousePressed()   // executed when the mouse is pressed
  {
  if (!keyPressed || (key=='a') || (key=='i') || (key=='x'))  
  P.pickClosest(Mouse()); // pick vertex closest to mouse: sets pv ("picked vertex") in pts
  if (keyPressed) 
     {
     if (key=='a' && state==0)  P.addPt(Mouse()); // appends vertex after the last one
     if (key=='i' && state==0)  P.insertClosestProjection(Mouse()); // inserts vertex at closest projection of mouse
     if (key=='d' && state==0)  P.deletePickedPt(); // deletes vertex closeset to mouse
     } 
  if (keyPressed && key=='s' && state==1) {A=Mouse(); B=Mouse();} 
  change=true;
  }

void mouseReleased()   // executed when the mouse is pressed
  {
  if (keyPressed && key=='s' && state==1) B=Mouse(); 
  //Plist[currentpts].cut();
  if (keyPressed && key=='s' && state==1) {
  Plist[currentpts].cut();
  A.setTo(0,0);
  B.setTo(0,0);
  }
  //println("currentpts"+currentpts);
  change=true;    
  }

void mouseDragged() // executed when the mouse is dragged (while mouse buttom pressed)
  {
  if (!keyPressed || (key=='a')|| (key=='i')) P.dragPicked();   // drag selected point with mouse
  if (keyPressed) {
      if (key=='.' && state==0) f+=2.*float(mouseX-pmouseX)/width;  // adjust current frame   
      if (key=='t' ) {P.dragAll();} // move all vertices
      if (key=='t' && state==2) {Plist[closestpts].dragAll();}
      if (key=='r' && state==0) P.rotateAllAroundCentroid(Mouse(),Pmouse()); // turn all vertices around their center of mass
      if (key=='z' && state==0) P.scaleAllAroundCentroid(Mouse(),Pmouse()); // scale all vertices with respect to their center of mass
      }
  if (keyPressed && key=='s' && state==1) B=Mouse(); 
  change=true;
  }  

void mouseWheel(MouseEvent event) { // reads mouse wheel and uses to zoom
  float s = event.getAmount();
  P.scaleAllAroundCentroid(s/100);
  change=true;
  }

//**************************** text for name, title and help  ****************************
String title ="Split Polygon Puzzle stage:"+state,            name ="Student: First LAST",
       subtitle = "  base code for P2 for Jarek Rossignac's CS3451 class in the Fall 2016",
       
       menu="?:(show/hide) help, ~/!/@:snap pdf/jpg/fif, `:(start/stop) recording, S/L:save/load, Q:quit",
       guide="click&drag:edit, d&click:delete, i&click&drag:insrt, s&click&drag:split"; // help info
       
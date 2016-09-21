//*****************************************************************************
// TITLE:         Point sequence for editing polylines and polyloops  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  September 2012
// EDITS:         Last revised Sept 10, 2016
//*****************************************************************************
class pts 
  {
  int nv=0;                                // number of vertices in the sequence
  int pv = 0;                              // picked vertex 
  int iv = 0;                              // insertion index 
  int maxnv = 100*2*2*2*2*2*2*2*2;         //  max number of vertices
  Boolean loop=true;                       // is a closed loop

  pt[] G = new pt [maxnv];                 // geometry table (vertices)

 // CREATE


  pts() {}
  
  void declare() {for (int i=0; i<maxnv; i++) G[i]=P(); }               // creates all points, MUST BE DONE AT INITALIZATION

  void empty() {nv=0; pv=0; }                                                 // empties this object
  
  void addPt(pt P) { G[nv].setTo(P); pv=nv; nv++;  }                    // appends a point at position P
  
  void addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; }    // appends a point at position (x,y)
  
  void insertPt(pt P)  // inserts new point after point pv
    { 
    for(int v=nv-1; v>pv; v--) G[v+1].setTo(G[v]); 
    pv++; 
    G[pv].setTo(P);
    nv++; 
    }
     
  void insertClosestProjection(pt M) // inserts point that is the closest to M on the curve
    {
    insertPt(closestProjectionOf(M));
    }
  
  void resetOnCircle(int k)                                                         // init the points to be on a well framed circle
    {
    empty();
    pt C = ScreenCenter(); 
    for (int i=0; i<k; i++)
      addPt(R(P(C,V(0,-width/3)),2.*PI*i/k,C));
    } 
  
  void makeGrid (int w) // make a 2D grid of w x w vertices
   {
   empty();
   for (int i=0; i<w; i++) 
     for (int j=0; j<w; j++) 
       addPt(P(.7*height*j/(w-1)+.1*height,.7*height*i/(w-1)+.1*height));
   }    


  // PICK AND EDIT INDIVIDUAL POINT
  
  void pickClosest(pt M) 
    {
    pv=0; 
    for (int i=1; i<nv; i++) 
      if (d(M,G[i])<d(M,G[pv])) pv=i;
    }

  void dragPicked()  // moves selected point (index pv) by the amount by which the mouse moved recently
    {
    if(state==0){
        G[pv].moveWithMouse(); }
    }     
  
  void deletePickedPt() {
    for(int i=pv; i<nv; i++) 
      G[i].setTo(G[i+1]);
    pv=max(0,pv-1);       // reset index of picked point to previous
    nv--;  
    }
  
  void setPt(pt P, int i) 
    { 
    G[i].setTo(P); 
    }
  
  
  // DISPLAY
  
  void IDs() 
    {
    for (int v=0; v<nv; v++) 
      { 
      fill(white); 
      show(G[v],13); 
      fill(black); 
      if(v<10) label(G[v],str(v));  
      else label(G[v],V(-5,0),str(v)); 
      }
    noFill();
    }
  
  void showPicked() 
    {
    show(G[pv],13); 
    }
  
  void drawVertices(color c) 
    {
    fill(c); 
    drawVertices();
    }
  
  void drawVertices()
    {
    for (int v=0; v<nv; v++) show(G[v],13); 
    }
   
  void drawCurve() 
    {
    if(loop) drawClosedCurve(); 
    else drawOpenCurve(); 
    }
    
  void drawOpenCurve() 
    {
    beginShape(); 
      for (int v=0; v<nv; v++) G[v].v(); 
    endShape(); 
    }
    
  void drawClosedCurve()   
    {
    beginShape(); 
      for (int v=0; v<nv; v++) G[v].v(); 
    endShape(CLOSE); 
    }

  // EDIT ALL POINTS TRANSALTE, ROTATE, ZOOM, FIT TO CANVAS
  
  void dragAll() // moves all points to mimick mouse motion
    { 
    for (int i=0; i<nv; i++) G[i].moveWithMouse(); 
    }      
  
  void moveAll(vec V) // moves all points by V
    {
    for (int i=0; i<nv; i++) G[i].add(V); 
    }   

  void rotateAll(float a, pt C) // rotates all points around pt G by angle a
    {
    for (int i=0; i<nv; i++) G[i].rotate(a,C); 
    } 
  
  void rotateAllAroundCentroid(float a) // rotates points around their center of mass by angle a
    {
    rotateAll(a,Centroid()); 
    }
    
  void rotateAllAroundCentroid(pt P, pt Q) // rotates all points around their center of mass G by angle <GP,GQ>
    {
    pt G = Centroid();
    rotateAll(angle(V(G,P),V(G,Q)),G); 
    }

  void scaleAll(float s, pt C) // scales all pts by s wrt C
    {
    for (int i=0; i<nv; i++) G[i].translateTowards(s,C); 
    }  
  
  void scaleAllAroundCentroid(float s) 
    {
    scaleAll(s,Centroid()); 
    }
  
  void scaleAllAroundCentroid(pt M, pt P) // scales all points wrt centroid G using distance change |GP| to |GM|
    {
    pt C=Centroid(); 
    float m=d(C,M),p=d(C,P); 
    scaleAll((p-m)/p,C); 
    }

  void fitToCanvas()   // translates and scales mesh to fit canvas
     {
     float sx=100000; float sy=10000; float bx=0.0; float by=0.0; 
     for (int i=0; i<nv; i++) {
       if (G[i].x>bx) {bx=G[i].x;}; if (G[i].x<sx) {sx=G[i].x;}; 
       if (G[i].y>by) {by=G[i].y;}; if (G[i].y<sy) {sy=G[i].y;}; 
       }
     for (int i=0; i<nv; i++) {
       G[i].x=0.93*(G[i].x-sx)*(width)/(bx-sx)+23;  
       G[i].y=0.90*(G[i].y-sy)*(height-100)/(by-sy)+100;
       } 
     }   
     
  // MEASURES 
  float length () // length of perimeter
    {
    float L=0; 
    for (int i=nv-1, j=0; j<nv; i=j++) L+=d(G[i],G[j]); 
    return L; 
    }
    
  float area()  // area enclosed
    {
    pt O=P(); 
    float a=0; 
    for (int i=nv-1, j=0; j<nv; i=j++) a+=det(V(O,G[i]),V(O,G[j])); 
    return a/2;
    }   
    
  pt CentroidOfVertices() 
    {
    pt C=P(); // will collect sum of points before division
    for (int i=0; i<nv; i++) C.add(G[i]); 
    return P(1./nv,C); // returns divided sum
    }
  
  //pt Centroid() // temporary, should be updated to return centroid of area
  //  {
  //  return CentroidOfVertices();
  //  }

  
  pt closestProjectionOf(pt M) 
    {
    int c=0; pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<d) {c=i; C=P(G[i]); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) 
      { 
      pt A = G[i], B = G[j];
      if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) 
        {
        d=disToLine(M,A,B); 
        c=i; 
        C=projectionOnLine(M,A,B);
        }
      } 
     pv=c;    
     return C;    
     }  

  Boolean contains(pt Q) {
    Boolean in=true;
    // provide code here
    return in;
    }
  
  pt Centroid () 
      {
      pt C=P(); 
      pt O=P(); 
      float area=0;
      for (int i=nv-1, j=0; j<nv; i=j, j++) 
        {
        float a = triangleArea(O,G[i],G[j]); 
        area+=a; 
        C.add(a,P(O,G[i],G[j])); 
        }
      C.scale(1./area); 
      return C; 
      }
        
  float alignentAngle(pt C) { // of the perimeter
    float xx=0, xy=0, yy=0, px=0, py=0, mx=0, my=0;
    for (int i=0; i<nv; i++) {xx+=(G[i].x-C.x)*(G[i].x-C.x); xy+=(G[i].x-C.x)*(G[i].y-C.y); yy+=(G[i].y-C.y)*(G[i].y-C.y);};
    return atan2(2*xy,xx-yy)/2.;
    }


  // FILE I/O   
     

  void savePts(String fn) 
    {
    String [] inppts = new String [nv+1];
    int s=0;
    inppts[s++]=str(nv);
    for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y);}
    saveStrings(fn,inppts);
    };
  

  void loadPts(String fn) 
    {
    println("loading: "+fn); 
    String [] ss = loadStrings(fn);
    String subpts;
    int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
    nv = int(ss[s++]); print("nv="+nv);
    for(int k=0; k<nv; k++) {
      int i=k+s; 
      comma=ss[i].indexOf(',');   
      x=float(ss[i].substring(0, comma));
      y=float(ss[i].substring(comma+1, ss[i].length()));
      G[k].setTo(x,y);
      };
    pv=0;
    }; 
    
    //SPLIT
    int n(int v) {return (v+1)%nv;}
    int p(int v) {return (v+nv-1)%nv;}
    pt[] XG = new pt [maxnv];
    int XGnum=0;
    int r=0, g=0, b=0;
    pt closept1;
    pt closept2;
    
    pt piecept1;
    pt piecept2;
    boolean splityBy(pt A, pt B, int num){
      XG = new pt [maxnv];
      XGnum=0;

      for(int v=0;v<nv;v++){
          //if(LineStabsEdge(A,B,G[v],G[n(v)])){
            vec V=V(A,B);
            pt X=RayEdgeCrossParameter(A,V,G[v],G[n(v)]);;
            if(X!=null){
               XG[XGnum]=X;
               XG[XGnum].prev=G[v];
               XG[XGnum].next=G[v+1];
               XG[XGnum].prevnum=v;
               if(v<nv-1){XG[XGnum].nextnum=v+1;}
               else{XG[XGnum].nextnum=0;}
               XGnum++;
            //}
            
      }}
      XG=sortpts(XG,XGnum);
      if(!checkarrow(XG, XGnum, A, B)){
      return false;
      }
      for(int i=0;i<XGnum;i=i+2){
        pen(white,7);
        if(XG[i].x<A.x && XG[i+1].x>A.x){
        closept1=XG[i];
        closept2=XG[i+1];
        beginShape(); 
        XG[i].v(); 
        XG[i+1].v(); 
        endShape();
        }
      }
      pt tempa;
      pt tempb;
          if(A.x<B.x){
             tempa=A;
             tempb=B;  
             for(int i=0;i<XGnum;i++){
                  if(XG[i].x<tempa.x){
                      pen(red,2);
                      show(XG[i],4.0);
                  }
                  if(XG[i].x>tempa.x){
                      pen(blue,2);
                      show(XG[i],4.0);
                  }
              }
        }
        else{
             tempa=B;
             tempb=A;
             for(int i=0;i<XGnum;i++){
                  if(XG[i].x<tempa.x){
                      pen(blue,2);
                      show(XG[i],4.0);
                  }
                  if(XG[i].x>tempa.x){
                      pen(red,2);
                      show(XG[i],4.0);
                  }
              }
        }
        pts temppts=Plist[num];
        if(closept1.prevnum>closept2.prevnum){
            pt temppt=closept1;
            closept1=closept2;
            closept2=temppt;
        }
        println("closept1:"+closept1.prevnum);
        println("closept2:"+closept2.nextnum);
        
        pts pts1=new pts();
        pts pts2=new pts();
        pts1.declare();
        pts2.declare();
        for(int i=0;i<=closept1.prevnum;i++){
            pts1.addPt(temppts.G[i]);
        }
        pts1.addPt(closept1);
        pts1.addPt(closept2);
        if(closept2.nextnum!=0){
            for(int i=closept2.nextnum;i<nv-1;i++){
            pts1.addPt(temppts.G[i]);
            }
        }
        //println(pts1.nv);  //length of p1
        if(closept1.nextnum==closept2.prevnum){
            pts2.addPt(closept1);
            pts2.addPt(temppts.G[closept1.nextnum]);
            pts2.addPt(closept2);
            
        }
        else{
            pts2.addPt(closept1);
            for(int i=closept1.nextnum;i<closept2.prevnum;i++){
            pts2.addPt(temppts.G[i]);
            println(temppts.G[i].nextnum);
            }
            pts2.addPt(closept2);
        }
        println(pts2.nv);
        
    return true;
    
    }
    
  boolean checkarrow(pt[] XG, int XGnum,pt A,pt B){
        pt tempa;
        pt tempb;
          if(A.x<B.x){
             tempa=A;
             tempb=B;   
        }
        else{
             tempa=B;
             tempb=A;
        }
        int leftside=0;
        int rightside=0;
        for(int i=0;i<XGnum;i++){
            if(XG[i].x>tempa.x && XG[i].x<tempb.x){
                return false;
            }
            if(XG[i].x<tempa.x){
                leftside++;
            }
            if(XG[i].x>tempb.x){
                rightside++;
            }
        }
        if(leftside%2==0 || rightside%2==0){
            return false;
        }
          return true;
  }
  
  pt[] sortpts(pt[] XG, int XGnum){
        for(int i=0;i<XGnum;i++){
            for(int j=0;j<XGnum-1;j++){
                if(XG[j].x>=XG[j+1].x){
                      pt temp=XG[j];
                      XG[j]=XG[j+1];
                      XG[j+1]=temp;
                  }
            }
        }
       return XG;
  }
  
  pt RayEdgeCrossParameter(pt A, vec v, pt c,pt d){
    pt B=new pt(A.x+v.x , A.y+v.y);
    float a1=v.y/v.x;
    float b1=A.y-a1*A.x;
    
    vec v2=V(c,d);
    float a2=v2.y/v2.x;
    float b2=c.y-a2*c.x;
    
    float newx=(b1-b2)/(a2-a1);
    float newy=a1*newx+b1;
    
    pt newp=new pt(newx,newy);
    if(newx>c.x && newx>d.x){
      return null;
    }
    if(newy>c.y && newy>d.y){
      return null;
    }
    if(newx<c.x && newx<d.x){
      return null;
    }
    if(newy<c.y && newy<d.y){
      return null;
    }
    return newp;
  }
  }  // end class pts
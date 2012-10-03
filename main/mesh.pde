class Mesh {
  /* Config Parameters */
  float node_radius = 5.0;

  /* Mesh Implementation Objects */
  float[][] G;
  int[] V;
  int[] S;
  int[] C;
  ArrayList v_list;
  /* Visualization */
  float[][] T_center;
  int cursor; /* (current corner) */
  Disk last_bulge = null;

  /*Mesh(filename) { };*/

  Mesh(float[][] G_in, int mode) {
    v_list = new ArrayList();
    G = G_in;
    if (mode == 0) {
      do_bulge_triangulation();
    }
    else if (mode == 1) {      
      do_triangulation();
    }
    calc_swing();
    cursor = 0;
  }

  boolean is_triangle(int v1, int v2, int v3) {
    // given three vertices determine if we already have that triangle

    boolean retval = false;
    // Use set class to compare triangles
    Set<Integer> new_set = new HashSet<Integer>();
    Set<Integer> comparison;
    new_set.add(v1);
    new_set.add(v2);
    new_set.add(v3);
    println(v_list);
    if (v3 == 1) {println(v_list.size()/3);}
    for (int i=0; i < (v_list.size()); i+=3) {    
      println(i);
      comparison = new HashSet<Integer>();      
      comparison.add((Integer)v_list.get(i));
      comparison.add((Integer)v_list.get(i+1));
      comparison.add((Integer)v_list.get(i+2));
      if (v3 == 1) {println(comparison);}
      if (new_set.equals(comparison)) {
        println(v1 + "," + v2 + "," + v3 + " is already a triangle");
        retval = true;
        break;
      }
    }  
    return retval;
  }
  boolean in_front(int a, int b, int c) {
    // given two points a and b which constitute a line, determine if c is ahead or behind
    // return true if in front, false if behind   

    // For a given line ab, this is the dot product between a vector perpendicular to ab
    // and the vector ac.  If it is positive, then c is in front.  If it is negative, 
    // then c is behind.  Note many formulations use the clockwise 90 degree rotation
    // and so the equations and sign conditions are slightly different.  
    // (Cx-Ax)*(By-Ay) + (Cy-Ax)*(Ax-Bx)

    float val = (G[c][0]-G[a][0])*(G[b][1]-G[a][1])+(G[c][1]-G[a][1])*(G[a][0]-G[b][0]);
    //println("Is " + c + " in front of " + a + "," + b + "?"); 
    if (val >= 0) {
      //println("no");
      return false;
    } 
    else {
      //println("yes");
      return true;
    }
  }
  boolean in_front_point(int a, int b, float x, float y) {
    // given two points a and b which constitute a line, determine if c is ahead or behind
    // return true if in front, false if behind   

    // For a given line ab, this is the dot product between a vector perpendicular to ab
    // and the vector ac.  If it is positive, then c is in front.  If it is negative, 
    // then c is behind.  Note many formulations use the clockwise 90 degree rotation
    // and so the equations and sign conditions are slightly different.  
    // (Cx-Ax)*(By-Ay) + (Cy-Ax)*(Ax-Bx)

    float val = (x-G[a][0])*(G[b][1]-G[a][1])+(y-G[a][1])*(G[a][0]-G[b][0]);
    //println("Is " + c + " in front of " + a + "," + b + "?"); 
    if (val >= 0) {
      //println("no");
      return false;
    } 
    else {
      //println("yes");
      return true;
    }
  }
  void recursive_bulge(int v1, int v2) {
    int v3;
    println("Bulging from: " + v1 + "," + v2);
    v3 = bulge(v1, v2);
    //if (v3 == 12) {v3 = -1;}
    if (v3 == -1) {
      println("No node bound on bulge from " +v1 +"," +v2 +" , not recursing");
    }
    else // bulge left and right
    {
      println("Recursing to left");
      recursive_bulge(v3, v2);    // v1 = v3; // this "goes left"
      println("Recursing to right");
      recursive_bulge(v1, v3);    // v2 = v3; // this "goes right"
    }
  }

  int bulge(int v1, int v2) {
    // bulge from v1,v2 and try to grab a vertex
    // return it if you find it, -1 if you don't find anything

    int min_idx=-1;
    float min_bulge = 1e10;
    float gam_app, d_app;
    float[] mp = new float[2];

    // Compute the midpoint
    mp[0] = (G[v1][0]+G[v2][0])/2.0;
    mp[1] = (G[v1][1]+G[v1][1])/2.0;    

    // Loop over unseen vertices.  if it is "in front", then do apollonius
    // otherwise, skip it

    for (int k=0; k < G.length; k++)
    { 
      //boolean test = is_triangle(v1, v2, k);

      if (!in_front(v1, v2, k)) {
        continue;
      }  
      if (v_list.contains(k)) { // change this to search for existing triangle
      //if (is_triangle(v1, v2, k)) {
        continue;
      }

      Disk dsc= apollonius(G[v1][0], G[v1][1], G[v2][0], G[v2][1], G[k][0], G[k][1]);
      // map need to choose between "alpha" and "gamma" here.. see whiteboard notes
      boolean center_location = in_front_point(v1, v2, dsc.x, dsc.y);
      if (center_location) {println("front");} else {println("back");}
      gam_app = sqrt(sq(dsc.x-mp[0])+sq(dsc.y-mp[1]));
      float bulge_val;
      if (center_location){
        // front
        bulge_val = max(dsc.r+gam_app, dsc.r-gam_app);
      }
      else {
        // back
        bulge_val = min(dsc.r-gam_app, dsc.r+gam_app);        
      }                    
      //d_app = dsc.r-gam_app;
      if (bulge_val < min_bulge){
        min_bulge = bulge_val;
        min_idx = k;
      }
    }

    if (min_idx > -1 && !is_triangle(v1,v2,min_idx)) {
      println("is_triangle: " +v1 +"," +v2+"," +min_idx);      
      println(is_triangle(v1,v2,min_idx));      
      println("Adding " + min_idx);
      v_list.add(v1);
      v_list.add(v2);       
      v_list.add(min_idx);
      println("is_triangle: " +v1 +"," +v2+"," +min_idx);      
      println(is_triangle(v1,v2,min_idx));
    } 
    return min_idx;
  }
  void do_bulge_triangulation() {
    int v1, v2, v3;

    // Get the first two vertices 
    v1 = get_leftmost();
    v2 = min_angle_from_leftmost();

    println("Doing bulge triangulation, " + v1 + "," +  v2);
    recursive_bulge(v1, v2);
    
    ///////////////////////////////////////////////////////////////////
    // All code below is shared with do_triangulation... abstract it out
    C = new int[G.length];    
    /* Turn ArrayList into array V */
    V = new int[v_list.size()];
    for (int i=0; i < v_list.size(); i++) {
      V[i] = (Integer)v_list.get(i);
      C[V[i]] = i;
    }

    /* Compute triangle centers */
    T_center = new float[V.length/3][2];
    float sum;
    /* iterate over Triangles */
    for (int i=0; i < T_center.length; i++) {
      /* iterate over spatial dimensions (2) */
      for (int j=0; j < 2; j++) {
        sum = 0;
        /* iterate over the three corners of Triangle */
        for (int k=0; k < 3; k++) {
          sum += G[v(i*3+k)][j];
        }
        T_center[i][j] = sum/3;
      }
    }
  }

  void do_triangulation() {
    Disk d;
    ArrayList v_list = new ArrayList();
    float r2;
    boolean success;

    /* Do triangulation with ArrayList */
    for (int i = 0; i < G.length; i++) {
      for (int j = i+1; j < G.length; j++) {
        for (int k = j+1; k < G.length; k++) {
          d = apollonius(G[i][0], G[i][1], G[j][0], G[j][1], G[k][0], G[k][1]);
          r2 = sq(d.r);
          success = true;
          for (int m = 0; m < G.length; m++) {
            if ((m!=i) && (m!=j) && (m!=k) && (sq(d.x-G[m][0]) + sq(d.y-G[m][1]) <= r2)) {
              success = false;
              break;
            }
          }
          if (success) {
            v_list.add(i);
            int c = v_list.size()-1;
            if (clockwise_triangle(G[i][0], G[i][1], G[j][0], G[j][1], G[k][0], G[k][1])) {
              /* println("CW:" + c + ", " + (c+1) + ", " + (c+2)); */
              v_list.add(j);
              v_list.add(k);
            }
            else {
              /* println("CCW:" + c + ", " + (c+1) + ", " + (c+2)); */
              v_list.add(k);
              v_list.add(j);
            }
          }
        }
      }
    }

    C = new int[G.length];

    /* Turn ArrayList into array V */
    V = new int[v_list.size()];
    for (int i=0; i < v_list.size(); i++) {
      V[i] = (Integer)v_list.get(i);
      C[V[i]] = i;
    }

    /* Compute triangle centers */
    T_center = new float[V.length/3][2];
    float sum;
    /* iterate over Triangles */
    for (int i=0; i < T_center.length; i++) {
      /* iterate over spatial dimensions (2) */
      for (int j=0; j < 2; j++) {
        sum = 0;
        /* iterate over the three corners of Triangle */
        for (int k=0; k < 3; k++) {
          sum += G[v(i*3+k)][j];
        }
        T_center[i][j] = sum/3;
      }
    }
  }

  void calc_swing() {
    S = new int[V.length];

    /* find all good (non-super) swings */
    int tri, iv, ipv;
    boolean success;
    /* iterate over corners */
    for (int i=0; i < S.length; i++) {
      iv = v(i);
      ipv = v(p(i));
      success = false;
      /* iterate over corners to find a match */
      for (int j=0; j < S.length; j++) {
        if ((i != j) && (iv == v(j)) && (ipv == v(n(j)))) {
          S[i] = j;
          success = true;
          break;
        }
      }
      /* No non-super swing found */
      if (!success) {
        S[i] = i;
      }
    }

    /* superswing */
    /* iterate over corners, looking for superswingers */
    int jnv;
    float a, best_angle;
    for (int i=0; i < S.length; i++) {
      if (S[i] == i) {
        best_angle = 2*PI;
        iv = v(i);
        ipv = v(p(i));
        for (int j=0; j < S.length; j++) {
          if ((i != j) && (iv == v(j))) {
            jnv = v(n(j));
            a = angle(G[iv][0], G[iv][1], G[ipv][0], G[ipv][1], G[jnv][0], G[jnv][1]);
            if (a < best_angle) {
              best_angle = a;
              S[i] = j;
            }
          }
        }
      }
    }
  }

  void draw() {
    strokeWeight(1);

    for (int i=0; i < G.length; i++) {
      fill(0, 0, 0);
      ellipse(G[i][0], G[i][1], 6*node_radius, 6*node_radius);
      fill(255, 255, 255);
      text(i, G[i][0]-5, G[i][1]+5);
    }

    int a, b, c;
    for (int i=0; i < V.length/3; i++) {
      a = v(i*3  );
      b = v(i*3+1);
      c = v(i*3+2);
      /* Draw bounding disks */
      /*apollonius(G[a][0], G[a][1], G[b][0], G[b][1], G[c][0], G[c][1]).show_outline();*/
      /* Draw triangulation */
      line(G[a][0], G[a][1], G[b][0], G[b][1]);
      line(G[b][0], G[b][1], G[c][0], G[c][1]);
      line(G[c][0], G[c][1], G[a][0], G[a][1]);
    }

    /* Draw triangulation centers */
    /*for (int i=0; i < T_center.length; i++) {
     			ellipse(T_center[i][0], T_center[i][1], 2*node_radius, 2*node_radius);
     		}*/

    /* Draw corner labels */
    int tri;
    String s;
    int iv;
    for (int i=0; i < V.length; i++) {
      tri = t(i);
      s = ((Integer)i).toString();
      if (i==cursor) {
        if (bs(i)) {
          fill(255, 0, 0);
        }
        else {
          fill(0, 0, 255);
        }
      }
      else {
        fill(0, 0, 0);
      }
      iv = v(i);
      text(s, 0.7*G[iv][0]+0.3*T_center[tri][0]-0.5*textWidth(s), 
      0.7*G[iv][1]+0.3*T_center[tri][1]+5);
    }
    fill(0, 0, 0);
    if (last_bulge != null) {
      last_bulge.show_outline();
    }
  }

  int c(int v) {
    return C[v];
  }

  int n(int c) {
    return (c+1)%3 + 3*t(c);
  }

  int p(int c) {
    return (c+2)%3 + 3*t(c);
  }

  int s(int c) {
    return S[c];
  }

  int t(int c) {
    /* integer division rounds down */
    return c/3;
  }

  int v(int c) {
    return V[c];
  }

  boolean bs(int c) {
    return v(p(c)) != v(n(s(c)));
  }

  void set_cursor(int new_cursor) {
    cursor = new_cursor;
  }
  int get_leftmost()
    // Return leftmost point
  {
    float min_val = 1e10;
    int min_idx = -1;
    for (int i=0; i < G.length; i++) {
      if (G[i][0] < min_val)
      {
        min_idx = i;
        min_val = G[i][0];
      }
    }	
    return min_idx;
  }
  float angle_from_leftmost(int input)
  {
    int leftmost = this.get_leftmost();
    float[] lv = {
      0.0, 0.0-G[leftmost][1]
    };
    float[] tv = {
      G[input][0]-G[leftmost][0], G[input][1]-G[leftmost][1]
    };
    return angle(lv, tv);
  }
  int min_angle_from_leftmost()
  {
    float min_val = PI;
    int min_idx = -1;
    float current;
    int leftmost = this.get_leftmost();
    for (int i=0; i < G.length; i++) {
      if (i != leftmost)
      {
        current = angle_from_leftmost(i);
        if (current < min_val ) {
          min_idx = i;
          min_val = current;
        }
      }
    }
    return min_idx;
  }
}


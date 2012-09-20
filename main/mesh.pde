class Mesh {
  float node_radius = 5.0;
  float bulge_radius = 36.0;
  float[][] G;
  int[] T;
  float[][] T_center;
  int cursor;

  /*Mesh(filename) { };*/

  Mesh(float[][] G_in) {
    G = G_in;
    //do_triangulation();
    cursor = 0;
  }
  
  void bulge_and_add(int v1, int v2){
  // take two vertices, and find the apolonius circle which results in minimal bulge

  // a new triangle should be created  
    
    
  }
  void increment_bulge(){
    // increment the bulge 
     bulge_radius += 0.5; 
  }
  void decrement_bulge(){
     bulge_radius -= 0.5; 
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
    float[] lv = {0.0, 0.0-G[leftmost][1]};
    float[] tv = {G[input][0]-G[leftmost][0], G[input][1]-G[leftmost][1]};
    return angle(lv, tv);
  }
  int min_angle_from_leftmost()
  {
    float min_val = PI;
    int min_idx = -1;
    float current;
    int leftmost = this.get_leftmost();
    for (int i=0; i < G.length; i++){
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
  
  void do_triangulation() {
    Disk d;
    ArrayList t_list = new ArrayList();
    float r2;
    boolean success;

    for (int i = 0; i < G.length; i++) {
      for (int j = i+1; j < G.length; j++) {
        for (int k = j+1; k < G.length; k++) {
          d = apollonius(G[i][0], G[i][1], G[j][0], G[j][1], G[k][0], G[k][1]);
          r2 = sq(d.r);
          success = true;
          for (int m = 0; m < G.length; m++) {
            if ( (m!=i) && (m!=j) && (m!=k) && (sq(d.x-G[m][0]) + sq(d.y-G[m][1]) < r2)) {
              success = false;
              break;
            }
          }
          if (success) {
            t_list.add(i);
            t_list.add(j);
            t_list.add(k);
          }
        }
      }
    }

    T = new int[t_list.size()];
    for (int i=0; i < t_list.size(); i++) {
      T[i] = (Integer)t_list.get(i);
    }

    T_center = new float[T.length/3][2];
    float sum;
    /* iterate over Triangles */
    for (int i=0; i < T_center.length; i++) {
      /* iterate over spatial dimensions (2) */
      for (int j=0; j < 2; j++) {
        sum = 0;
        /* iterate over the three corners of Triangle */
        for (int k=0; k < 3; k++) {
          sum += G[T[i*3+k]][j];
        }
        T_center[i][j] = sum/3;
      }
    }
  }
  void bulge(int v1, int v2, float r){
  // take in two points and draw a bulge
  
  // compute the circle centerpoint for a given r
  float[] cp;
  cp = center_for_two_points(G[v1], G[v2], r);

  
  }
  void draw_vertices() {
    
    // Get the first two vertices and connect them    
    int v1 = get_leftmost();
    int v2 = min_angle_from_leftmost();
    line(G[v1][0],G[v1][1], G[v2][0], G[v2][1]);    

    for (int i=0; i < G.length; i++) {
      if (i == v1 | i == v2) {
        fill(255, 0, 0);
      }
      else {                  
        fill(0, 0, 0);
      }
      ellipse(G[i][0], G[i][1], 2*node_radius, 2*node_radius);
    }    

    int k, min_idx=-1;    
    float min_bulge = 1e10;
    float gam_app, d_app;
    float [] mp = new float[2];

      // Compute the midpoint
    mp[0] = (G[v1][0]+G[v2][0])/2.0;
    mp[1] = (G[v1][1]+G[v1][1])/2.0;
    Disk minbulge_disc = null;
    for (k=0; k < G.length; k++)
    { 
      if ((k != v1) && (k != v2) && (k != 1)) {
        Disk dsc= apollonius(G[v1][0], G[v1][1], G[v2][0], G[v2][1], G[k][0], G[k][1]);
        gam_app = sqrt(sq(dsc.x-mp[0])+sq(dsc.y-mp[1]));
        d_app = dsc.r-gam_app;
        if ((gam_app+dsc.r) < min_bulge) {
            //min_bulge = d_app;
            min_bulge = gam_app+dsc.r;
            min_idx = k;
            println("k: " + k);
            println("Gam_app: " + gam_app);
            println("d_app: " + d_app);  
            println("gam+r_app: " + (gam_app+dsc.r));
            minbulge_disc = dsc;      
        }
      }
    }        
    println("min_idx: " + min_idx);
    minbulge_disc.show_outline();
  }
  void draw() {
    strokeWeight(1);
    draw_vertices();
    int a, b, c;

    //		for (int i=0; i < T.length/3; i++) {
    //			a = T[i*3  ];
    //			b = T[i*3+1];
    //			c = T[i*3+2];
    //			/* Draw bounding disks */
    //			//apollonius(G[a][0], G[a][1], G[b][0], G[b][1], G[c][0], G[c][1]).show_outline();
    //			/* Draw triangulation */
    //			line(G[a][0], G[a][1], G[b][0], G[b][1]);
    //			line(G[b][0], G[b][1], G[c][0], G[c][1]);
    //			line(G[c][0], G[c][1], G[a][0], G[a][1]);
    //		}

    /* Draw triangulation centers */
    /*for (int i=0; i < T_center.length; i++) {
     			ellipse(T_center[i][0], T_center[i][1], 2*node_radius, 2*node_radius);
     		}*/

    /* Draw corner labels */
    //		int tri;
    //		String s;
    //		for (int i=0; i < T.length; i++) {
    //			tri = t(i);
    //			s = ((Integer)i).toString();
    //			if (i==cursor) {
    //				fill(255, 0, 0);
    //			}
    //			else {
    //				fill(0, 0, 0);
    //			}
    //			text(s, 0.7*G[T[i]][0]+0.3*T_center[tri][0]-0.5*textWidth(s),
    //			        0.7*G[T[i]][1]+0.3*T_center[tri][1]+5);
    //		}
    //		fill(0, 0, 0);
  }

  int t(int corner) {
    /* integer division rounds down */
    return corner/3;
  }
}


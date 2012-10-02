Mesh m;
int apollonius_counter = 0;
void setup() {
  size(500, 500);
  //G = read_input("data/mesh.txt"); 
  randomSeed(1);
  G = rand_input(15, width, height);
  m = new Mesh(G, 0);
  //m = new Mesh(G, 1);
  println(apollonius_counter + " calls to apoll");
}

void draw() {
  background(#FFFFFF);
  m.draw();
}

void keyPressed() {
  if (key == 'n') {
    m.set_cursor(m.n(m.cursor));
  }
  else if (key == 'p') {
    m.set_cursor(m.p(m.cursor));
  }
  else if (key == 's') {
    m.set_cursor(m.s(m.cursor));
  }
  else if (key == 'c'){
    paused = false;
  }
}


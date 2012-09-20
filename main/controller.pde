
void mouseClicked() {
  println("Mouse clicked");
}


void keyPressed() {
  println("key pressed");
  if (key == 'i') {
    println("Increment radius");
    m.increment_bulge();
  }
  if (key == 'd') {
    m.decrement_bulge();
  }
}


Mesh m;

void setup() {
	size(300, 300);
	G = read_input("data/mesh.txt"); 
	m = new Mesh(G);


        //m.get_leftmost();
        //println(degrees(m.angle_from_leftmost(3)));
        //println(m.min_angle_from_leftmost());
}

void draw() {
	background(#FFFFFF);
	m.draw();
}


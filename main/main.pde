Mesh m;

void setup() {
	size(300, 300);
	G = read_input("data/mesh.txt"); 
	m = new Mesh(G);
}

void draw() {
	background(#FFFFFF);
	m.draw();
}


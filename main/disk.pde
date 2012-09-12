class Disk {
	float x=0, y=0, r=10;

	Disk(float px, float py, float pr) {r=pr; x=px; y=py;}

	void show_outline() {
		strokeWeight(1);
		noFill();
		ellipse(x, y, 2*r, 2*r);
	}
	
}

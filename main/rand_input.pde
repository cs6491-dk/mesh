Point[]
rand_input(int count, int w, int h)
{
	Point[] G_rand = new Point[count];

	for (int i=0; i<count; i++) {
		G_rand[i] = new Point(random(0, w), random(0, h));
	}

	return G_rand;
}

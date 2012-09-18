float[][]
rand_input(int count, int w, int h)
{
	float[][] G_rand = new float[count][2];

	for (int i=0; i<count; i++) {
		G_rand[i][0] = random(0, w);
		G_rand[i][1] = random(0, h);
	}

	return G_rand;
}

/* not really the Apollonius problem but close
 * This can be considered a degenerate Apollonius problem
 * in which all circles have zero radius. At this point
 * inside or outside tangency means nothing, so no
 * multiple solutions to choose from */

Disk
apollonius(float x1, float y1, float x2, float y2, float x3, float y3)
{
  apollonius_counter += 1;
 	if ((x1-x3)*(y1-y2) == (x1-x2)*(y1-y3)) {
		return new Disk(0.0, 0.0, 1e10);
	}

	if (x1 == x2) {
		/* Swap 2 & 3 */
		float tmp_x = x2;
		float tmp_y = y2;
		x2 = x3;
		y2 = y3;
		x3 = tmp_x;
		y3 = tmp_y;
	}
	else if (x2 == x3) {
		/* Swap 1 & 2 */
		float tmp_x = x2;
		float tmp_y = y2;
		x2 = x1;
		y2 = y1;
		x1 = tmp_x;
		y1 = tmp_y;
	}

	float dx12 = x1 - x2;
	float dx23 = x2 - x3;
	float dy21 = y2 - y1;
	float dy32 = y3 - y2;

	float n12 = sq(x1) - sq(x2) + sq(y1) - sq(y2);
	float n23 = sq(x2) - sq(x3) + sq(y2) - sq(y3);

	float y = (n23/dx23 - n12/dx12)/2/(dy21/dx12 - dy32/dx23);
	float x = y*dy21/dx12 + n12/dx12/2;
	float r = sqrt(sq(x1-x)+sq(y1-y));

	return new Disk(x, y, r);
}

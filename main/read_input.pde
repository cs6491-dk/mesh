Point[]
read_input(String filename)
{
  String line;

  BufferedReader reader = createReader(filename);
  int num_points;
  Point[] pointArray;
  try
  {
    num_points = int(reader.readLine());  
    pointArray = new Point[num_points];

    for (int i=0; i < num_points; i++)
    {
      line = reader.readLine();
      String[] list = split(line, ' ');

      pointArray[i] = new Point(float(list[0]), float(list[1]));
    }
    return pointArray;
  }
  catch (IOException e) {
    return null;
  }
}


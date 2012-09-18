float[][]
read_input(String filename)
{
  String line;

  BufferedReader reader = createReader(filename);
  int num_points;
  float[][] pointArray;
  try
  {
    num_points = int(reader.readLine());  
    pointArray = new float[num_points][2];

    for (int i=0; i < num_points; i++)
    {
      line = reader.readLine();
      String[] list = split(line, ' ');

      pointArray[i][0] = float(list[0]);
      pointArray[i][1] = float(list[1]);
    }
    return pointArray;
  }
  catch (IOException e) {
    return null;
  }
}


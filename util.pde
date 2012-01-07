
// A simple ease in, ease out curve as used by the Source engine
float ease(float x) {
  return 3*x*x - 2*x*x*x;
}

float clamp(float a, float min, float max) {
  return min(max, max(min, a));
}

float clamp(float a) {
  return clamp(a, 0, 1);
}

color whiten(color colour, float amount) {
  int white = (int)(255 * amount);
  return color(red(colour) + white, green(colour) + white, blue(colour) + white);
}

String bufferNumber(int n, int size) {
  String s = repeatString("0", size) + n;
  return s.substring(s.length()-size, s.length());
}

String repeatString(String str, int n) {
  String s = "";
  for(int i = 0; i < n; i++)
    s += str;
  return s;
}

// Create an image in a certain colour with a given mask
PImage generateImage(color c, PImage mask) {
  PImage img = createImage(mask.width, mask.height, ARGB);
  for(int w = 0; w < img.width; w++)
    for(int h = 0; h < img.height; h++)
      img.set(w, h, color(red(c), green(c), blue(c), blue(mask.get(w,h))));
  return img;
}

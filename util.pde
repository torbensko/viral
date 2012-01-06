
// A simple ease in, ease out curve as used by the Source engine
float ease(float x) {
  return 3*x*x - 2*x*x*x;
}

// Clamp a value within a certain range
float clamp(float a, float min, float max) {
  return max(min, min(max, a));
}

float clamp(float a) {
  return clamp(a, 0, 1);
}

// Fade from a and b, based on f
float fade(float a, float b, float f) {
  return f * b + (1 - f) * a;
}

color whiten(color colour, float amount) {
  int white = (int)(255 * amount);
  return color(red(colour) + white, green(colour) + white, blue(colour) + white);
}


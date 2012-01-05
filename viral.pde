final int SEPERATION = 100;
final int NODE_SIZE = 50;

void setup() {
  size(800, 800);
  smooth();
  performLayout();
}

// Sccatter the nodes around randomly, without placing any two too near to each other
void performLayout() {
  while(_tryPlacement()) { 
    println(entities.size()); 
  };
}

boolean _tryPlacement() {
  boolean placed = false;
  int attempts = 1000;
  while(attempts > 0 && !placed) {
    int x = (int) random(width);
    int y = (int) random(height);
    Entity entity = (millis()%2 == 0) 
        ? new User(x, y, NODE_SIZE) 
        : new Site(x, y, NODE_SIZE);
    boolean clash = false;
    for(Entity e : entities)
      clash = clash || (e != entity && e.distance(entity) < SEPERATION);
    if(clash)
      entity.remove();
    else
      placed = true;
    attempts--;
  }
  return placed;
}


void draw() {
  background(255);
  for(Entity e : entities) 
    e.draw();
}

void mouseClicked() {
  for(Entity e : entities)
      e.checkClick();
}

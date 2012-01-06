final int SEPERATION = 90;
final float SCALE = 1;

final int SITE_USER_RATIO = 3; // i.e. SITE_USER_RATIO users to every site

void setup() {
  size(800, 800);
  smooth();
  performLayout();
}

// Sccatter the nodes around randomly, without placing any two too near to each other
void performLayout() {
  while(_tryPlacement()) {};
}

boolean _tryPlacement() {
  boolean placed = false;
  int attempts = 1000;
  while(attempts > 0 && !placed) {
    int x = (int) random(width);
    int y = (int) random(height);
    Entity entity = (millis() % SITE_USER_RATIO == 0) 
        ? new Site(x, y, SCALE)
        : new Surfer(x, y, SCALE);
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
  // we take a clone to avoid concurrency issues
  ArrayList<Entity> clone = (ArrayList<Entity>) entities.clone();
  for(Entity e : clone)  e.think();
  for(Entity e : clone)  e.preDraw();
  for(Entity e : clone)  e.draw();
  for(Entity e : clone)  e.postDraw();
}

void mouseClicked() {
  for(User u : users) {
    if(u.containsClick()) {
      if(researcher == null) {
        new Researcher(u.x, u.y, SCALE);
        u.remove();
        break; // cannot use our iterator further
      }
    }
  }
  if(youtube == null || project == null || server == null) {
    for(Site s : sites) {
      if(s.containsClick()) {
        if(youtube == null)
          new YouTube(s.x, s.y, SCALE);
        else if(project == null)
          new ProjectSite(s.x, s.y, SCALE);
        else
          new Server(s.x, s.y, SCALE);
        s.remove();
        break; // cannot use our iterator further
      }
    }
  }
}

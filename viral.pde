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
    Entity entity = (millis() % SITE_USER_RATIO == 0) 
        ? new Site(x, y, SCALE)
        : new User(x, y, SCALE);
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
  if(researcher == null) {
    for(User u : users) {
      if(u.containsClick()) {
        new Researcher(u.x, u.y, SCALE);
        u.remove();
        break; // cannot use our iterator further
      }
    }
  }
  if(youtube == null || project == null) {
    for(Site s : sites) {
      if(s.containsClick()) {
        if(youtube == null)
          new YouTube(s.x, s.y, SCALE);
        else
          new ProjectSite(s.x, s.y, SCALE);
        s.remove();
        break; // cannot use our iterator further
      }
    }
  }
}

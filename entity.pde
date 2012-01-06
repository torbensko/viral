import java.util.ArrayList;

final int ACTIVE_INNER = 100;
final int ACTIVE_RANGE = 200;

final int ACTIVE_PERIOD_CHECK = 1000; // in millis

static ArrayList<Entity> entities = new ArrayList<Entity>();

class Entity {
  
  ArrayList<Item> items;
  
  int x;
  int y;
  float scale;
  boolean isActive;
  protected boolean privatelyActive; // so only we know we are active
  color colour = #666666;
  color activeColour;
  int size = 10;
  
  Entity(int x, int y, float scale) {
    items = new ArrayList<Item>();
    entities.add(this);
    this.x = x; 
    this.y = y;
    this.scale = scale;
  }
  
  void acceptItem(Item i) {
    items.add(i);
    isActive = true;
  }
  
  void receiverGotItem(Item i) {}
  
  void remove() {
    entities.remove(this);
  }
  
  float distance(Entity e) {
    return sqrt(pow(e.x - x, 2) + pow(e.y - y, 2));
  }
  
  boolean containsClick() {
    return 
        (mouseX > x-size/2 && mouseX < x+size/2) &&
        (mouseY > y-size/2 && mouseY < y+size/2);
  }
  
  void think() {}
  
  private float strengthDiff = 0;
  private float strengthTime = 0; // offset them from each other
  private float strengthPrev = 0;
  
  float getStrength() {
    if(isActive || privatelyActive)
      return 1;
    
    strengthDiff += millis() - strengthTime;
    strengthTime  = millis();
    
    if(strengthDiff < ACTIVE_PERIOD_CHECK)
      return strengthPrev;
    
    strengthDiff = 0;
    
    float smallest = 10000000;
    for(Entity e : entities)
      smallest = (e == this || !e.isActive) 
          ? smallest
          : min(smallest, e.distance(this));
    
    strengthPrev = 1 - clamp((smallest - ACTIVE_INNER) / ACTIVE_RANGE);
    return strengthPrev;
  }
  
  // for bottom level elements
  void preDraw() {}
  
  // for second level elements
  void draw() {
    if(mousePressed && (youtube == null || project == null || researcher == null || server == null))
      stroke(127);
    else
      noStroke();
    activeColour = whiten(colour, 1 - getStrength());
    fill(activeColour);
  }
  
  void postDraw() {}
  
}

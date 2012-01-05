import java.util.ArrayList;

final int ACTIVE_INNER = 100;
final int ACTIVE_RANGE = 200;
final int ACTIVE_PERIOD_CHECK = 1000; // in millis

class Item {
  final int ITEM_VIDEO = 0;
  final int ITEM_SYSTEM = 1;
  
  int type;
  
  Item(int type) {
    this.type = type;
  }
  
}

static ArrayList<Entity> entities = new ArrayList<Entity>();

class Entity {
  ArrayList<Item> items;
  
  int x;
  int y;
  int size;
  boolean isActive;
  
  Entity(int x, int y, int size) {
    items = new ArrayList<Item>();
    entities.add(this);
    this.x = x; 
    this.y = y;
    this.size = size;
  }
  
  void download(Item i) {
    items.add(i);
    isActive = true;
  }
  
  void remove() {
    entities.remove(this);
  }
  
  float distance(Entity e) {
    return sqrt(pow(e.x - x, 2) + pow(e.y - y, 2));
  }
  
  boolean checkClick() {
    return 
        (mouseX > x-size/2 && mouseX < x+size/2) &&
        (mouseY > y-size/2 && mouseY < y+size/2);
  }
  
  
  private float strengthDiff = 0;
  private float strengthTime = 0; // offset them from each other
  private float strengthPrev = 0;
  
  float getStrength() {
    if(isActive)
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
    
    strengthPrev = 1 - min(1, max(0, smallest-ACTIVE_INNER)/ACTIVE_RANGE);
    return strengthPrev;
  }
  
  void draw() {
    noStroke();
  }
  
}

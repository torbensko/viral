import java.util.ArrayList;

final int ACTIVE_INNER = 100;
final int ACTIVE_RANGE = 200;

final int OCCASSIONAL_THINK_PERIOD_MIN = 1000;
final int OCCASSIONAL_THINK_PERIOD_MAX = 4000;

final int ACTIVE_PERIOD_CHECK = 1000; // in millis

final float REARRANGE_DURATION = 200; // in millis

static ArrayList<Entity> entities = new ArrayList<Entity>();

class Entity {
  
  ArrayList<Item> items;
  ArrayList<Item> pastItems;
  ArrayList<Item> pendingItems;
  PImage img;
  
  int x;
  int y;
  boolean isActive;
  protected boolean privatelyActive; // so only we know we are active
  color colour = #666666;
  color activeColour;
  int size = floor(10 * SCALE);
  
  Entity(int x, int y) {
    items = new ArrayList<Item>();
    pastItems = new ArrayList<Item>();
    pendingItems = new ArrayList<Item>();
    entities.add(this);
    this.x = x; 
    this.y = y;
  }
  
  void pendingItem(Item i) {
    pendingItems.add(i);
  }
  
  void acceptItem(Item i) {
    items.add(i);
    pendingItems.remove(i);
    i.holders.add(this); // let it know we are now holding a reference to it
    isActive = true;
    layoutItems();
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
  
  private float thinkTime;
  private float thinkDiff;
  
  void think() {
    thinkDiff -= millis() - thinkTime;
    thinkTime  = millis();
    if(thinkDiff < 0) {
      thinkDiff = random(OCCASSIONAL_THINK_PERIOD_MIN, OCCASSIONAL_THINK_PERIOD_MAX);
      occassionalThink();
    }
  }
  
  void occassionalThink() {}
  
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
  
  private float pastStrength = -1;
  private PImage genImg = null;
  
  // for second level elements
  void draw() {
    if(mousePressed && (youtube == null || project == null || researcher == null || server == null))
      stroke(127);
    else
      noStroke();
    
    float strength = getStrength();
    
    if(strength != pastStrength) {
      activeColour = whiten(colour, 1 - strength);
      if(img != null)
        genImg = generateImage(activeColour, img);
      pastStrength = strength;
    }
    fill(activeColour);
    
    if(genImg != null)
      image(genImg, x, y, size, size);
    else
      ellipse(x, y, size, size);
  }
  
  void postDraw() {}
  
  // Checks whether this sites hold the same file, taking into account duplicates
  boolean holdsItem(Item i, boolean includePast, boolean includePending) {

    boolean holdsItem = false;
    ArrayList<Item> check = (ArrayList<Item>) items.clone();
    if(includePast)
      check.addAll(pastItems);
    if(includePending)
      check.addAll(pendingItems);
      
    for(Item it : check)
      holdsItem = holdsItem || it.compare(i);
    
    return holdsItem;
  }
  
  boolean holdsItem(Item i) {
    return holdsItem(i, true, true);
  }
  
  void discardItem(Item i) {
    items.remove(i);
    pastItems.add(i);
    i.hidden = true;
    layoutItems();
  }
  
  // Position the items within the entity so they do not overlap each other, by
  // placing them in a circular pattern
  void layoutItems() {
    if(items.size() == 0)
      return;
      
    if(items.size() == 1) {
      items.get(0).moveTo(x, y, null, null, REARRANGE_DURATION);
      return;
    }
    
    for(int i = 0; i < items.size(); i++) {
      float rad = 2 * PI / items.size() * i;
      Item it = items.get(i);
      it.moveTo(
          (int) (it.size * sin(rad) + x), 
          (int) (it.size * cos(rad) + y), 
          null, null, REARRANGE_DURATION);
    }
  }
  
}

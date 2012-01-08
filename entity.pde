import java.util.ArrayList;
import java.util.HashMap;

final int ACTIVE_INNER = 100;
final int ACTIVE_RANGE = 200;

// time based:
//final int OCCASSIONAL_THINK_PERIOD_MIN = 1000;
//final int OCCASSIONAL_THINK_PERIOD_MAX = 4000;
//final float REARRANGE_DURATION = 200; // in millis

// time based:
final int OCCASSIONAL_THINK_PERIOD_MIN = 1 * FPS;
final int OCCASSIONAL_THINK_PERIOD_RANGE = 2 * FPS;
final int REARRANGE_DURATION = floor(0.2 * FPS); // in millis

final int STRENGTH_UPDATE_PERIOD = floor(0.5 * FPS);

HashMap<Integer,PFont> fonts;

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
  float strength = 0;
  String label = "";
  int fontSize = 12;
  int strengthUpdateOffset = 0;
  int appeal = 1;
  
  Entity(int x, int y) {
    items = new ArrayList<Item>();
    pastItems = new ArrayList<Item>();
    pendingItems = new ArrayList<Item>();
    entities.add(this);
    this.x = x; 
    this.y = y;
    
    // disperse the think periods
    strengthUpdateOffset = randInt(STRENGTH_UPDATE_PERIOD);
    
    if(fonts == null)
      fonts = new HashMap<Integer,PFont>();
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
  
  //private float thinkTime;
  private int thinkDiff;
  
  void think() {
    
    // time based:
    //thinkDiff -= millis() - thinkTime;
    //thinkTime  = millis();
    // frame based:
    thinkDiff--;
    
    if(thinkDiff < 0) {
      thinkDiff = OCCASSIONAL_THINK_PERIOD_MIN + randInt(OCCASSIONAL_THINK_PERIOD_RANGE);
      occassionalThink();
    }
    if((frameCount + strengthUpdateOffset) % STRENGTH_UPDATE_PERIOD == 0)
      updateStrength();
  }
  
  void occassionalThink() {}
  
  private float strengthDiff = 0;
  private float strengthTime = 0; // offset them from each other
  private float strengthPrev = 0;
  ArrayList<Entity> nearbyEntities;
  
  void updateStrength() {
    if(isActive || privatelyActive) {
      strength = 1;
      return;
    }
    
    if(nearbyEntities == null)
      return;
    
    float smallest = 10000000;
    for(Entity e : nearbyEntities)
      smallest = (e == this || !e.isActive) 
          ? smallest
          : min(smallest, e.distance(this));
    
    strength = 1 - clamp((smallest - ACTIVE_INNER * SCALE) / ACTIVE_RANGE * SCALE);
  }
  
  void setup() {
    // make a subset to check when updating our stength
    nearbyEntities = new ArrayList<Entity>();
    for(Entity e : entities) {
      float d = distance(e);
      if(d < (ACTIVE_INNER + ACTIVE_RANGE) * SCALE)
        nearbyEntities.add(e);
    }
  }
  
  // for bottom level elements
  void preDraw() {}
  
  private float pastStrength = -1;
  private PImage genImg = null;
  
  // for second level elements
  void draw() {
    if(mousePressed && (youtube == null || project == null || researcher == null || server == null)) {
      stroke(127);
      noFill();
      ellipse(x, y, size, size);
      noStroke();
    }
    
    if(strength != pastStrength) {
      activeColour = whiten(colour, 1 - strength);
      if(img != null)
        genImg = generateImage(activeColour, img);
      pastStrength = strength;
    }

    if(genImg == null && img != null)
      genImg = generateImage(activeColour, img);
    
    fill(activeColour);
    
    if(genImg != null)
      image(genImg, x, y, size, size);
    else
      ellipse(x, y, size, size);
    drawLabel();
  }
  
  void drawLabel() {
    if(label.length() == 0)
      return;
    
    textFont(getEntityFont());
    textAlign(CENTER);
    text(label, x, y-(size*0.55));
  }
  
  PFont getEntityFont() {
    PFont font = fonts.get(fontSize);
    if(font == null) {
      font = createFont("Arial", fontSize * SCALE);
      fonts.put(fontSize, font);
    }
    return font;
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
  
  void discardAllItems() {
    while(items.size() > 0)
      discardItem(items.get(0));
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
  
  void considerDiscarding() {
    // drop some of the material after a while
    for(Item i : (ArrayList<Item>) items.clone()) {
      if(randChoice(i.appeal))
        discardItem(i);
    }
  }
  
}

import java.util.ArrayList;

final int ITEM_LINK_LINE_WEIGHT = 1;
final float ITEM_LINK_LINE_WHITENESS = 0.7;

final float TRANSFER_TIME_DEFAULT = 1000;


static ArrayList<Item> items = new ArrayList<Item>();

class Item extends Entity {
  
  Item master;
  ArrayList<Site> links;
  ArrayList<Entity> holders;
  
  final int NOT_MOVING = -1;
  
  float startTime = NOT_MOVING;
  int xInit;
  int yInit;
  int xDest;
  int yDest;
  float duration;
  Entity receiver, sender;
  
  // Create an Item with an initial position and reference to the master copy
  // of this item, used for matching duplicated items
  Item(int x, int y, float scale, Item master) {
    super(x, y, scale);
    this.master = master;
    colour = #BBCCFF;
    size = 10;
    items.add(this);
    privatelyActive = true;
    links = new ArrayList<Site>();
    holders = new ArrayList<Entity>();
    duration = TRANSFER_TIME_DEFAULT;
  }
  
  Item clone() {
    return new Item(x, y, scale, null).getDetailsFrom(this);
  }
  
  Item getDetailsFrom(Item i) {
    x = i.x;
    y = i.y;
    scale = scale;
    master = (i.master != null) ? i.master : i;
    links = (ArrayList<Site>) i.links.clone();
    colour = i.colour;
    size = i.size;
    return this;
  }
  
  void sendTo(Entity receiver) {
    sendTo(receiver, null, 0);
  }
  
  void sendTo(Entity receiver, Entity sender, float duration) {
    moveTo(receiver.x, receiver.y, receiver, sender, duration);
  }
  
  // Tell it to move somewhere over a certain period and receiver the receiver
  // when there
  void moveTo(int x, int y, Entity receiver, Entity sender, float duration) {
    xInit = this.x;
    yInit = this.y;
    xDest = x;
    yDest = y;
    this.sender = sender;
    if(duration > 0)
      this.duration = duration;
    this.receiver = receiver;
    startTime = millis();
  }
  
  void think() {
    if(startTime != NOT_MOVING) {
      float progress = clamp((millis() - startTime) / duration);
      if(progress == 1) {
        x = xDest;
        y = yDest;
        startTime = NOT_MOVING;
        if(receiver != null)
          receiver.acceptItem(this);
        if(sender != null)
          sender.receiverGotItem(this);
      } else {
        progress = ease(progress);
        x = (int) fade(xInit, xDest, progress);
        y = (int) fade(yInit, yDest, progress);
      }
    }
  }
  
  void preDraw() {
    // draw the links to the other sites
    strokeWeight(ITEM_LINK_LINE_WEIGHT);
    for(Site s : links) {
      stroke(whiten(s.colour, ITEM_LINK_LINE_WHITENESS));
      // we draw the second half in the third pass
      line((x + s.x)/2, (y + s.y)/2, s.x, s.y);
    }
  }
  
  void draw() {}
  
  void postDraw() {
    
    // we draw the second half now so it overlaps the site this item may be sitting on
    strokeWeight(ITEM_LINK_LINE_WEIGHT);
    for(Site s : links) {
      stroke(whiten(s.colour, ITEM_LINK_LINE_WHITENESS));
      line(x, y, (x + s.x)/2, (y + s.y)/2);
    }
    
    fill(colour);
    noStroke();
    ellipse(x, y, size*scale, size*scale);
  }
  
  void remove() {
    super.remove();
    items.remove(this);
    
    // remove ourselves from the list of items each site has
    for(Entity e : (ArrayList<Entity>) holders)
      e.items.remove(this);
  }
  
  // Compares two items, taking inaccount they can be duplicates of each other
  boolean compare(Item i) {
    i = (i.master != null) ? i.master : i;
    return i == this.master || i == this;
  }
  
}

class System extends Item {
  
  System(int x, int y, float scale, Item master) {
    super(x, y, scale, master);
    colour = #00FF00;
    if(server != null)
      links.add(server);
  }
  
  System clone() {
    return (System) new System(x, y, scale, null).getDetailsFrom(this);
  }
  
  void use() {
    new Data(x, y, scale, null).sendTo(server);
  }
  
}

class Data extends Item {
  
  Data(int x, int y, float scale, Item master) {
    super(x, y, scale, master);
    size = 5;
    if(server != null)
      colour = server.colour;
  }

}


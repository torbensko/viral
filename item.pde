import java.util.ArrayList;

final int ITEM_LINK_LINE_WEIGHT = 1;
final float ITEM_LINK_LINE_WHITENESS = 0.7;

final float TRANSFER_TIME_DEFAULT = 1000;


static ArrayList<Item> items = new ArrayList<Item>();

class Item extends Entity {
  
  Item master;
  ArrayList<Site> links;
  
  final int NOT_MOVING = -1;
  
  float startTime = NOT_MOVING;
  int xInit;
  int yInit;
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
    duration = TRANSFER_TIME_DEFAULT;
  }
  
  Item clone() {
    Item i = new Item(x, y, scale, (master != null) ? master : this);
    i.links = (ArrayList<Site>) links.clone();
    return i;
  }
  
  // Tell it to move somewhere over a certain period and receiver the receiver
  // when there
  void sendTo(Entity receiver, Entity sender, float duration) {
    xInit = this.x;
    yInit = this.y;
    this.sender = sender;
    if(duration > 0)
      this.duration = duration;
    this.receiver = receiver;
    startTime = millis();
  }
  
  void sendTo(Entity receiver) {
    sendTo(receiver, null, 0);
  }
  
  void think() {
    if(startTime != NOT_MOVING) {
      float progress = clamp((millis() - startTime) / duration);
      if(progress == 1) {
        x = receiver.x;
        y = receiver.y;
        startTime = NOT_MOVING;
        receiver.transferComplete(this);
        if(sender != null)
          sender.transferComplete(this);
      } else {
        progress = ease(progress);
        x = (int) fade(xInit, receiver.x, progress);
        y = (int) fade(yInit, receiver.y, progress);
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
  }
}

//class Video extends Item {
//}
//
//class System extends Item {
//}
//
//class Data extends Item {
//}


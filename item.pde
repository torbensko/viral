import java.util.ArrayList;

static ArrayList<Item> items = new ArrayList<Item>();

class Item extends Entity {
  
  Item master;
  
  final int NOT_MOVING = -1;
  
  float startTime = NOT_MOVING;
  int xDest;
  int yDest;
  int xInit;
  int yInit;
  float duration;
  Entity notify;
  
  // Create an Item with an initial position and reference to the master copy
  // of this item, used for matching duplicated items
  Item(int x, int y, float scale, Item master) {
    super(x, y, scale);
    this.master = master;
    colour = #BBCCFF;
    size = 10;
    items.add(this);
    privatelyActive = true;
  }
  
  // Tell it to move somewhere over a certain period and notify the receiver
  // when there
  // @arg notify    The entity to notify when complete. This can be null
  void move(int x, int y, float duration, Entity notify) {
    xDest = x;
    yDest = y;
    xInit = this.x;
    yInit = this.y;
    this.duration = duration;
    this.notify = notify;
    startTime = millis();
  }
  
  void think() {
    if(startTime != NOT_MOVING) {
      float progress = clamp((millis() - startTime) / duration);
      if(progress == 1) {
        x = xDest;
        y = yDest;
        startTime = NOT_MOVING;
        if(notify != null)
          notify.transferComplete(this);
        println("complete");
      } else {
        progress = ease(progress);
        x = (int) fade(xInit, xDest, progress);
        y = (int) fade(yInit, yDest, progress);
        println(progress);
      }
    }
  }
  
  void preDraw() {}
  void draw() {}
  
  void postDraw() {
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


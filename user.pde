import java.util.ArrayList;

static ArrayList<User> users = new ArrayList<User>();
static Researcher researcher;

final int BROWSE_SIZE = 200;
final int BROWSE_PERIOD_MIN = 1000;
final int BROWSE_PERIOD_MAX = 4000;

final float TRANSFER_TIME_INIT_YOUTUBE_UPLOAD = 2000;

class User extends Entity {
  
  Site browsing;
  
  User(int x, int y, float scale) {
    super(x, y, scale);
    users.add(this);  
    colour = #99DDFF;
    size = 30;
  }
  
  void preDraw() {
    if(browsing != null) {
      stroke(activeColour);
      line(x, y, browsing.x, browsing.y);
    }
  }
  
  void draw() {
    super.draw();
    ellipse(x, y, size*scale, size*scale);
  }
  
  void remove() {
    super.remove();
    users.remove(this);
  }
  
  private float thinkTime;
  private float thinkDiff;
  
  void think() {
    thinkDiff -= millis() - thinkTime;
    thinkTime  = millis();
    if(thinkDiff < 0) {
      thinkDiff = random(BROWSE_PERIOD_MIN, BROWSE_PERIOD_MAX);
      browse();
    }
  }
  
  // Pick a random nearby site to visit
  void browse() {
    ArrayList<Site> possible = new ArrayList<Site>();
    for(Site s : sites) {
      if(s.browsable && s.distance(this) < BROWSE_SIZE)
        possible.add(s);
    }
    if(possible.size() > 0)
      browsing = possible.get(floor(random(possible.size())));
  }
}
  
class Researcher extends User {
  
  Researcher(int x, int y, float scale) {
    super(x, y, scale);
    researcher = this;
    isActive = true;
    colour = #FF00CC;
    size = 40;
  }
  
  boolean containsClick() {
    boolean contains = super.containsClick();
    if(contains && youtube != null) {
      Item i = new Item(x, y, 1, null);
      i.move(youtube.x, youtube.y, TRANSFER_TIME_INIT_YOUTUBE_UPLOAD, youtube);
    }
    return contains;
  }
  
}

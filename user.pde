import java.util.ArrayList;

static ArrayList<User> users = new ArrayList<User>();
static ArrayList<Surfer> surfers = new ArrayList<Surfer>();
static Researcher researcher;

final int BROWSE_SIZE = 200;
final int BROSWE_LINE_WEIGHT = 1;

final int OCCASSIONAL_THINK_PERIOD_MIN = 1000;
final int OCCASSIONAL_THINK_PERIOD_MAX = 4000;

final float TRANSFER_TIME_INIT_YOUTUBE_UPLOAD = 2000;

class User extends Entity {
  
  Site browsing;
  
  User(int x, int y, float scale) {
    super(x, y, scale);
    users.add(this);
  }
  
  void preDraw() {
    if(browsing != null) {
      stroke(activeColour);
      strokeWeight(BROSWE_LINE_WEIGHT);
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
      thinkDiff = random(OCCASSIONAL_THINK_PERIOD_MIN, OCCASSIONAL_THINK_PERIOD_MAX);
      occassionalThink();
    }
  }
  
  void occassionalThink() {}
  
  // Pick a random nearby site to visit
  // @return   Returns TRUE if it is a different site from before
  boolean browse() {
    Site previously = browsing;
    ArrayList<Site> possible = new ArrayList<Site>();
    for(Site s : sites) {
      if(s.browsable && s.distance(this) < BROWSE_SIZE)
        possible.add(s);
    }
    if(possible.size() > 0)
      browsing = possible.get(floor(random(possible.size())));
    return previously != browsing;
  }
}
  
class Researcher extends User {
  
  final int SETUP_WAITING = 0;
  final int SETUP_SYSTEM = 1;
  final int SETUP_VIDEO = 2;
  
  int setupPhase = SETUP_WAITING;
  
  Researcher(int x, int y, float scale) {
    super(x, y, scale);
    researcher = this;
    isActive = true;
    colour = #FF00CC;
    size = 40;
  }
  
  boolean containsClick() {
    boolean contains = super.containsClick();
    if(contains) {
      switch(setupPhase) {
        case SETUP_WAITING : publishSystem(); break;
        case SETUP_SYSTEM :  publishVideo(); break;
        case SETUP_VIDEO :   break;
      }
    }
    return contains;
  }
  
  void itemReceived() {
  }
  
  // Put out the study system
  void publishSystem() {
    if(project != null && server != null) {
      
      browsing = project;
      Item study = new Item(x, y, scale, null);
      study.links.add(server);
      study.sendTo(project, this, -1);
      
      setupPhase++;
    }
  }
  
  // Put a copy of the video to YouTube
  void publishVideo() {
    if(youtube != null && project != null) {
      browsing = youtube;
      Item i = new Item(x, y, scale, null);
      i.links.add(project);
      i.sendTo(youtube);
      
      setupPhase++;
    }
  }
  
}

class Surfer extends User {
  
  Surfer(int x, int y, float scale) {
    super(x, y, scale); 
    colour = #99DDFF;
    size = 30;
  }
  
  void occassionalThink() {
    boolean newLink = browse();
  }
  
  void remove() {
    super.remove();
    surfers.remove(this);
  }
  
}

import java.util.ArrayList;

static ArrayList<User> users = new ArrayList<User>();
static ArrayList<Surfer> surfers = new ArrayList<Surfer>();
static Researcher researcher;

final int BROWSE_SIZE = 200;
final int BROWSE_INCREASE = 10;
final int BROSWE_LINE_WEIGHT = 1;

final int OCCASSIONAL_THINK_PERIOD_MIN = 1000;
final int OCCASSIONAL_THINK_PERIOD_MAX = 4000;

final float TRANSFER_TIME_INIT_YOUTUBE_UPLOAD = 2000;

class User extends Entity {
  
  Site browsing;
  int browseRange;
  
  User(int x, int y, float scale) {
    super(x, y, scale);
    users.add(this);
    browseRange = BROWSE_SIZE;
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
      if(s.browsable && s.distance(this) < browseRange)
        possible.add(s);
    }
    if(possible.size() > 0)
      browsing = possible.get(floor(random(possible.size())));
    return previously != browsing;
  }
}
  
class Researcher extends User {
  
  final int STATE_INIT = 0;
  final int STATE_CREATING_VIDEO = 1;
  final int STATE_WAITING_FOR_YT = 2;
  final int STATE_PROMOTING = 3;
  
  int state = STATE_INIT;
  
  Item currentVideo;
  
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
      switch(state) {
        case STATE_INIT :           publishSystem(); break;
        case STATE_CREATING_VIDEO : publishVideo(); break;
        case STATE_PROMOTING:       promoteVideo(); break;
      }
    }
    return contains;
  }
  
  void receiverGotItem(Item i) {}
  
  // Put out the study system
  void publishSystem() {
    if(project != null && server != null) {
      browsing = project;
      new System(x, y, scale, null).clone().sendTo(project);
      
      state = STATE_CREATING_VIDEO;
    }
  }
  
  // Put a copy of the video to YouTube
  void publishVideo() {
    if(youtube != null && project != null) {
      browsing = youtube;
      Item i = new Item(x, y, scale, null);
      i.links.add(project);
      i.sendTo(youtube);
      state = STATE_WAITING_FOR_YT;
    }
  }
  
  void acceptItem(Item i) {
    super.acceptItem(i);
    // we only get items from YouTube, so we can assume its the video
    currentVideo = i;
    state = STATE_PROMOTING;
  }
  
  // Finds a new site and sends the latest video to it
  void promoteVideo() {
    boolean promoted = false;
    do {
      // every time, we look a litte further
      browseRange += BROWSE_INCREASE;
      browse();
      if(!browsing.holdsItem(currentVideo, true)) {
        currentVideo.clone().sendTo(browsing);
        promoted = true;
      }
    } while(!promoted);
  }
  
  void occassionalThink() {
  }
  
}

class Surfer extends User {
  
  Item waitingFor;
  System system;
  ArrayList<YouTubeVid> watching;
  
  Surfer(int x, int y, float scale) {
    super(x, y, scale); 
    colour = #99DDFF;
    size = 30;
    watching = new ArrayList<YouTubeVid>();
  }
  
  void occassionalThink() {
    browse();
    checkLinkForNewItem(browsing);
    
    if(system != null)
      system.use(); // occassionally think to play the game
    
    if(watching.size() > 0) {
      for(YouTubeVid v : (ArrayList<YouTubeVid>) watching)
        discardItem(v);
      watching.clear();
    }
    
  }
  
  void acceptItem(Item i) {
    super.acceptItem(i);
    
    if(waitingFor == i)
      waitingFor = null;
    
    if(i instanceof System)
      system = (System) i;
    if(i instanceof YouTubeVid)
      watching.add((YouTubeVid) i);
    
    for(Site s : (ArrayList<Site>) i.links.clone()) {
      checkLinkForNewItem(s);
    }
  }
  
  void checkLinkForNewItem(Site link) {
    // can only look for one thing at a time
    if(waitingFor != null || browsing == null)
      return;
    
    for(Item i : (ArrayList<Item>) link.items.clone()) {
      // found a new item that we are interested in
      if(!holdsItem(i)) {
        waitingFor = i.clone();
        waitingFor.sendTo(this);
        privatelyActive = true;
        break;
      }
    }
  }
  
  void remove() {
    super.remove();
    surfers.remove(this);
  }
  
}

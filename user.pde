import java.util.ArrayList;

static ArrayList<User> users = new ArrayList<User>();
static ArrayList<Surfer> surfers = new ArrayList<Surfer>();
static Researcher researcher;

final int BROWSE_SIZE = 300;
final int BROWSE_INCREASE = 10;
final int BROSWE_LINE_WEIGHT = 2;

final int FOLLOWING_CHANCE = 5;

final float TRANSFER_TIME_INIT_YOUTUBE_UPLOAD = 2000;

final int BROWSE_AMOUNT = 5; // in one out of BROWSE_AMOUNT cases, we won't browse

PImage userIcon;

class User extends Entity {
  
  Site browsing;
  int browseRange;
  ArrayList<Site> nearbySites;
  
  User(int x, int y) {
    super(x, y);
    users.add(this);
    browseRange = floor(BROWSE_SIZE * SCALE);
    if(userIcon == null)
       userIcon = loadImage("user.png");
    img = userIcon;
  }
  
  void preDraw() {
    if(browsing != null) {
      stroke(activeColour);
      strokeWeight(max(1, BROSWE_LINE_WEIGHT * SCALE));
      line(x, y, browsing.x, browsing.y);
    }
  }
  
  void remove() {
    super.remove();
    users.remove(this);
  }
  
  void resetBrowsing() {
    nearbySites = null;
    browsing = null;
  }
  
  // Pick a random nearby site to visit
  // @return   Returns TRUE if it is a different site from before
  boolean browse() {
    Site previously = browsing;
    if(nearbySites == null) {
      nearbySites = new ArrayList<Site>();
      for(Site s : sites) {
        if(s.browsable && s.distance(this) < browseRange)
          for(int i = 0; i < s.appeal; i++)
            nearbySites.add(s);
      }
    }
    if(nearbySites.size() > 0)
      browsing = nearbySites.get(randInt(nearbySites.size()));
    return previously != browsing;
  }
}
  
class Researcher extends User {
  
  final int STATE_INIT = 0;
  final int STATE_CREATING_VIDEO = 1;
  final int STATE_WAITING_FOR_YT = 2;
  final int STATE_PROMOTING = 3;
  
  int state = STATE_INIT;
  int systemCount = 0;
  
  Item currentVideo;
  Item currentEmail;
  
  Researcher(int x, int y) {
    super(x, y);
    researcher = this;
    isActive = true;
    colour = #FF00CC;
    size = floor(40 * SCALE);
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
      systemCount++;
      browsing = project;
      System system = new System(x, y, null);
      
      system.version = systemCount;
      system.colour = whiten(#FFB300, systemCount/3.0);
      
      super.acceptItem(system);
      system.clone().sendTo(project);
      
      currentEmail = null;
      state = STATE_CREATING_VIDEO;
    }
  }
  
  // Put a copy of the video to YouTube
  void publishVideo() {
    if(youtube != null && project != null) {
      browsing = youtube;
      Item i = new VideoFile(x, y, null);
      i.links.add(project);
      i.sendTo(youtube);
      
      state = STATE_WAITING_FOR_YT;
    }
  }
  
  void sendForumPost() {
    
    if(currentEmail == null) {
      currentEmail = new Email(x, y, null);
      super.acceptItem(currentEmail);
    }
    do {
      browse();
    } while (browsing == null || (browsing != null && browsing.holdsItem(currentEmail, true, true)));
    
    currentEmail.clone().sendTo(browsing);
  }
  
  void acceptItem(Item i) {
    super.acceptItem(i);
    // we only get items from YouTube, so we can assume it's the video
    currentVideo = i;
    state = STATE_PROMOTING;
  }
  
  // Finds a new site and sends the latest video to it
  void promoteVideo() {
    if(currentVideo == null)
      return;
    
    boolean promoted = false;
    do {
      browse();
      
      if(!browsing.holdsItem(currentVideo)) {
        currentVideo.clone().sendTo(browsing);
        promoted = true;
      }
    } while(!promoted);
  }
  
  boolean browse() {
    browseRange += floor(BROWSE_INCREASE * SCALE);
    nearbySites = null;
    return super.browse();
  }
  
  void occassionalThink() {
  }
  
}

class Surfer extends User {
  
  Item waitingFor;
  System system;
  
  Surfer(int x, int y) {
    super(x, y); 
    colour = #99DDFF;
    size = floor(30 * SCALE);
  }
  
  // A surfer, at any given time will randomly choose
  // to promote the items they currently hold and discard them, based on
  // the appeal and sharablity of each item
  void occassionalThink() {
    // if we still have the system, then give it a play
    if(items.indexOf(system) < 0)
      system = null;
    if(system != null)
      system.use(); // occassionally think to play the game
      
    browsing = null;
    if(!randChoice(BROWSE_AMOUNT))
      browse();
    if(browsing == null)
      return;
      
    checkLink(browsing);
    considerReposting();
    considerDiscarding();
  }
  
  void considerReposting() {
    for(Item i : (ArrayList<Item>) items.clone())
      if(randChoice(i.sharability) && !browsing.holdsItem(i))
        i.clone().sendTo(browsing);
  }
  
  void acceptItem(Item i) {
    super.acceptItem(i);
    
    if(waitingFor == i)
      waitingFor = null;
    
    if(i instanceof System)
      system = (System) i;
    
    for(Site s : (ArrayList<Site>) i.links.clone()) {
      checkLink(s);
      
      // consider following the site
      if(randChoice(s.followChance))
        s.followers.add(this);
    }
  }
  
  // Look to see if a link has a new item at the end of it
  void checkLink(Site link) {
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

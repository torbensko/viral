import java.util.ArrayList;

final int SERVER_GROW_AMOUNT = 2;

final int FOLLOWABLE_STROKE_WEIGHT = 3;
final color FOLLOWABLE_COLOR = #FFAA11;

final int DISCARD_CHANCE_VID = 5;    // 1 in DISCARD_CHANCE_VID
final int DISCARD_CHANCE_FORUM = 1;

static ArrayList<Site> sites = new ArrayList<Site>();
static YouTube youtube;
static ProjectSite project;
static Server server;


class Site extends Entity {

  boolean followable;
  color followableColor;
  ArrayList<User> followers;
  
  boolean browsable = true;
  
  Site(int x, int y) {
    super(x, y);
    sites.add(this);
    size = floor(50 * SCALE);
    colour = #AAFFBB;
    followers = new ArrayList<User>();
  }
  
  void acceptItem(Item i) {
    super.acceptItem(i);
    
    // automatic notifications
    for(User u : (ArrayList<User>) followers.clone()) {
      i.clone().sendTo(u);
    }
  }
  
  void remove() {
    super.remove();
    sites.remove(this);
  }
  
  void preDraw() {
    for(User u : (ArrayList<User>) followers.clone()) {
      strokeWeight(max(1, FOLLOWABLE_STROKE_WEIGHT * SCALE));
      stroke(FOLLOWABLE_COLOR);
      line(x, y, u.x, u.y);
    }
  }
  
  void draw() {
    if(followable) {
      stroke(FOLLOWABLE_COLOR);
      strokeWeight(max(1, FOLLOWABLE_STROKE_WEIGHT * SCALE));
    }
    super.draw();
  }
  
  void occassionalThink() {
    considerDiscarding();
  }
  
  void considerDiscarding() {
    // drop some of the material after a while
    for(Item i : (ArrayList<Item>) items.clone()) {
      if(i instanceof YouTubeVid && floor(random(DISCARD_CHANCE_VID)) % DISCARD_CHANCE_VID == 0)
        discardItem(i);
    }
  }
}


class YouTube extends Site {

  YouTube(int x, int y) {
    super(x, y);
    youtube = this;
    colour = #FF0000;
    size = floor(55 * SCALE);
    isActive = true;
    followable = true;
  }
  
  void acceptItem(Item i) {
    // send back the youtube version (i.e. the one with links)
    Item ytv = new YouTubeVid(x, y, null);
    ytv.links.addAll(i.links);
    
    super.acceptItem(ytv); // we do not want to accept the video we originally get
    i.remove();
    
    ytv.clone().sendTo(researcher);
  }
  
  // do not want to discard anything
  void considerDiscarding() {}
  
}

class ProjectSite extends Site {
  
  ProjectSite(int x, int y) {
    super(x, y);
    project = this;
    colour = #0000FF;
    size = floor(55 * SCALE);
    isActive = true;
    browsable = false;
  }
  
  void acceptItem(Item i) {
    super.acceptItem(i);
    println(items.size());
  }

  // do not want to discard anything
  void considerDiscarding() {}

}

class Server extends Site {

  int growChance = 1;
  
  Server(int x, int y) {
    super(x, y);
    server = this;
    colour = #333333;
    size = floor(20 * SCALE);
    browsable = false;
    privatelyActive = true;
  }
  
  void acceptItem(Item i) {
    i.remove();
    if(floor(random(growChance)) % growChance == 0) {
      size += max(1, floor(SERVER_GROW_AMOUNT * SCALE));
      growChance++;
    }
  }
  
  // ensures we never get sent stuff other than what researcher gives us
  boolean holdsItem(Item i, boolean includePast, boolean includePending) {
    return true;
  }
  
  // do not want to discard anything
  void considerDiscarding() {}
  
}

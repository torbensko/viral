import java.util.ArrayList;

final int SERVER_GROW_AMOUNT = 2;

final int FOLLOWABLE_STROKE_WEIGHT = 3;
final color FOLLOWABLE_COLOR = #FFAA11;
final int FOLLOWABLE_VISIBILITY = 50;

final int DEVELOPER_SIZE = 150;

static ArrayList<Site> sites = new ArrayList<Site>();
static YouTube youtube;
static ProjectSite project;
static Server server;

String[] siteNames = {"Reddit", "Facebook", "Twitter"}; 

class Site extends Entity {

  int followChance = 0;
  ArrayList<User> followers;
  float linkVisibility = 0.05;
  
  boolean browsable = true;
  
  Site(int x, int y) {
    super(x, y);
    sites.add(this);
    size = floor(50 * SCALE);
    colour = #88DDAA;
    followers = new ArrayList<User>();
    appeal = 20;
    
    if(sites.size() < siteNames.length)
      label = siteNames[sites.size() - 1];
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
      stroke(FOLLOWABLE_COLOR, FOLLOWABLE_VISIBILITY);
      line(x, y, u.x, u.y);
    }
    noStroke();
  }
  
  void draw() {
    if(followChance > 0) {
      strokeWeight(max(1, FOLLOWABLE_STROKE_WEIGHT * SCALE));
      stroke(FOLLOWABLE_COLOR, FOLLOWABLE_VISIBILITY);
    }
    super.draw();
    noStroke();
  }
  
  void occassionalThink() {
    considerDiscarding();
  }
}


class YouTube extends Site {

  YouTube(int x, int y) {
    super(x, y);
    youtube = this;
    colour = #FF0000;
    size = floor(55 * SCALE);
    isActive = true;
    followChance = 2;
    label = "YouTube";
    fontSize = 16;
    //linkVisibility = 0.1;
    linkVisibility = 0.01;
  }
  
  void acceptItem(Item i) {
    if(!(i instanceof VideoFile)) {
      i.remove();
      return;
    }
    
    // send back the youtube version (i.e. the one with links)
    Item ytv = new YouTubeVid(x, y, null);
    ytv.links.addAll(i.links);
    
    super.acceptItem(ytv); // we do not want to accept the video we originally get
    i.remove();
    
    ytv.clone().sendTo(researcher);
  }
  
  boolean holdsItem(Item i, boolean includePast, boolean includePending) {
    if(!(i instanceof VideoFile))
      return true;
    return super.holdsItem(i, includePast, includePending);
  }
  
  // do not want to discard anything
  void considerDiscarding() {}
  
}

class ProjectSite extends Site {
  
  ProjectSite(int x, int y) {
    super(x, y);
    project = this;
    size = floor(55 * SCALE);
    isActive = true;
    fontSize = 12;
    linkVisibility = 0.01;
    appeal = 1;
    browsable = false;
    
    // project site
    label = "Project Site";
    colour = #0000FF;
    
    // development site
//    label = "Developer Site";
//    colour = #666666;
//    followChance = 5;
//    for(User u : (ArrayList<User>) users.clone())
//      if(u.distance(this) < DEVELOPER_SIZE*SCALE)
//        followers.add(u);
  }
  
  void acceptItem(Item i) {
    if(!(i instanceof System))
      return;
    // we only want to host the latest system
    discardAllItems();
    super.acceptItem(i);
  }
  
  boolean holdsItem(Item i, boolean includePast, boolean includePending) {
    if(!(i instanceof System))
      return true;   
    return super.holdsItem(i, includePast, includePending);
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
    label = "Data Server";
    fontSize = 8;
    linkVisibility = 0.05;
  }
  
  void acceptItem(Item i) {
    i.remove();
    if(randChoice(growChance)) {
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

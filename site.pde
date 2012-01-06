import java.util.ArrayList;

final int SERVER_GROW_CHANCE = 4;
final int SERVER_GROW_AMOUNT = 2;
final int FOLLOWABLE_STROKE_WEIGHT = 3;

static ArrayList<Site> sites = new ArrayList<Site>();
static YouTube youtube;
static ProjectSite project;
static Server server;


class Site extends Entity {

  boolean followable;
  color followableColor;
  boolean browsable = true;
  
  Site(int x, int y, float scale) {
    super(x, y, scale);
    sites.add(this);
    size = 50;
    colour = #AAFFBB;
    followableColor = #FFAA11;
  }
  
  void remove() {
    super.remove();
    sites.remove(this);
  }
  
  void draw() {
    super.draw();
    if(followable) {
      stroke(followableColor);
      strokeWeight(FOLLOWABLE_STROKE_WEIGHT);
    }
    ellipse(x, y, size*scale, size*scale);
  }
}


class YouTube extends Site {

  YouTube(int x, int y, float scale) {
    super(x, y, scale);
    youtube = this;
    colour = #FF0000;
    size = 55;
    isActive = true;
    followable = true;
  }
  
  void acceptItem(Item i) {
    // send back the youtube version (i.e. the one with links)
    Item ytv = new YouTubeVid(x, y, 1, null);
    ytv.links.addAll(i.links);
    
    super.acceptItem(ytv); // we do not want to accept the video we originally get
    i.remove();
    
    ytv.clone().sendTo(researcher);
  }
  
}

class ProjectSite extends Site {
  
  ProjectSite(int x, int y, float scale) {
    super(x, y, scale);
    project = this;
    colour = #0000FF;
    size = 55;
    isActive = true;
    browsable = false;
  }
  
  void acceptItem(Item i) {
    super.acceptItem(i);
    println(items.size());
  }
  
}

class Server extends Site {

  Server(int x, int y, float scale) {
    super(x, y, scale);
    server = this;
    colour = #333333;
    size = 20;
    browsable = false;
    privatelyActive = true;
  }
  
  void acceptItem(Item i) {
    i.remove();
    if(floor(random(SERVER_GROW_CHANCE)) % SERVER_GROW_CHANCE == 0)
      size += SERVER_GROW_AMOUNT;
  }
  
}

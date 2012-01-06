import java.util.ArrayList;

final int SERVER_GROW_CHANCE = 4;
final int SERVER_GROW_AMOUNT = 2;

static ArrayList<Site> sites = new ArrayList<Site>();
static YouTube youtube;
static ProjectSite project;
static Server server;


class Site extends Entity {

  boolean followable;
  boolean browsable = true;
  
  Site(int x, int y, float scale) {
    super(x, y, scale);
    sites.add(this);
    size = 50;
    colour = #AAFFBB;
  }
  
  void remove() {
    super.remove();
    sites.remove(this);
  }
  
  void draw() {
    super.draw();
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
  
  void transferComplete(Item i) {
    super.transferComplete(i);
    if(floor(random(SERVER_GROW_CHANCE)) % SERVER_GROW_CHANCE == 0)
      size += SERVER_GROW_AMOUNT;
  }
  
}

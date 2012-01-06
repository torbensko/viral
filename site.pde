import java.util.ArrayList;

static ArrayList<Site> sites = new ArrayList<Site>();
static YouTube youtube;
static ProjectSite project;


class Site extends Entity {

  boolean followable;
  
  Site(int x, int y, float scale) {
    super(x, y, scale);
    sites.add(this);
    size = 50;
    colour = #CCFFBB;
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
    colour = #33FF33;
    size = 55;
    isActive = true;
  }
  
}

import java.util.ArrayList;

static ArrayList<Site> sites = new ArrayList<Site>();

class Site extends Entity {
  
  final int TYPE_NORM = 0;
  final int TYPE_YOUTUBE = 1;
  final int TYPE_PROJECT = 2;
  
  final color COLORS[] = {#BBCCFF, #AACCBB, #CCFF00};

  int type;
  boolean followable;
  
  Site(int x, int y, int size) {
    super(x, y, size);
    type = TYPE_NORM;
    sites.add(this);
  }
  
  void remove() {
    super.remove();
    sites.remove(this);
  }
  
  boolean checkClick() {
    boolean wasIn = super.checkClick();
    if(!wasIn)
      return false;
    
    boolean youTubeExists = false;
    boolean projectExists = false;
    for(Site s : sites) {
      youTubeExists = youTubeExists || s.type == TYPE_YOUTUBE;
      projectExists = projectExists || s.type == TYPE_PROJECT;
    }
    if(!youTubeExists)
      type = TYPE_YOUTUBE;
    else if(!projectExists)
      type = TYPE_PROJECT;
    
    if(type != TYPE_NORM)
      isActive = true;
    
    return true;
  }
  
  void draw() {
    super.draw();
    fill(COLORS[type], 255 * getStrength());
    ellipse(x, y, size, size);
  }
}

import java.util.ArrayList;

static ArrayList<User> users = new ArrayList<User>();

class User extends Entity {
  
  final int TYPE_NORM = 0;
  final int TYPE_RESEARCHER = 1;
  
  final color COLORS[] = {#FF00CC, #FFCC00};
  
  int type;
  
  User(int x, int y, int size) {
    super(x, y, size);
    type = TYPE_NORM;
    users.add(this);
  }
  
  boolean checkClick() {
    boolean wasIn = super.checkClick();
    if(!wasIn)
      return false;
    
    boolean researcherExists = false;
    for(User u : users)
      researcherExists = researcherExists || u.type == TYPE_RESEARCHER;
    if(!researcherExists) {
      type = TYPE_RESEARCHER;
      isActive = true;
    }
    
    return true;
  }
  
  void draw() {
    super.draw();
    fill(COLORS[type], 255 * getStrength());
    ellipse(x, y, size, size);
  }
  
  void remove() {
    super.remove();
    users.remove(this);
  }
}

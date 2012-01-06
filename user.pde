import java.util.ArrayList;

static ArrayList<User> users = new ArrayList<User>();
static Researcher researcher;

class User extends Entity {
  
  User(int x, int y, float scale) {
    super(x, y, scale);
    users.add(this);  
    color colour = #FFCC00;
    size = 30;
  }
  
  void draw() {
    super.draw();
    ellipse(x, y, size*scale, size*scale);
  }
  
  void remove() {
    super.remove();
    users.remove(this);
  }
}
  
class Researcher extends User {
  
  Researcher(int x, int y, float scale) {
    super(x, y, scale);
    researcher = this;
    isActive = true;
    colour = #FF00CC;
    size = 40;
  }
  
}

//import processing.video.*;

final int SEPERATION = 90;

final int SITE_USER_RATIO = 3; // i.e. SITE_USER_RATIO users to every site

final char KEY_RECORDING_START = 'r';
final char KEY_RECORDING_FINISH = ' ';

//MovieMaker record; // allows us to record the sequence
boolean recording = false;
String recordPrefix = "";

void setup() {
  size(800, 800);
  smooth();
  performLayout();
  background(255);
  
  // automatic layouts
  makeResearcher(users.get(0));
  makeYouTube(sites.get(0));
  makeServer(sites.get(0));
  makeProjectSite(sites.get(0));
  
  // setup the project
  researcher.publishSystem();
  researcher.publishVideo();
  
  Calendar now = Calendar.getInstance();
  recordPrefix = ""+
      now.get(Calendar.YEAR)+"-"+
      bufferNumber(now.get(Calendar.MONTH)+1, 2)+"-"+
      bufferNumber(now.get(Calendar.DAY_OF_MONTH), 2)+"_"+
      bufferNumber(now.get(Calendar.HOUR_OF_DAY), 2)+"-"+
      bufferNumber(now.get(Calendar.MINUTE), 2)+"/";
  
  imageMode(CENTER);
  
  //record = new MovieMaker(this, width, height, "test.mov", 30, MovieMaker.H263, MovieMaker.HIGH);
}

// Sccatter the nodes around randomly, without placing any two too near to each other
void performLayout() {
  while(_tryPlacement()) {};
}

boolean _tryPlacement() {
  boolean placed = false;
  int attempts = 1000;
  while(attempts > 0 && !placed) {
    int x = (int) random(width);
    int y = (int) random(height);
    Entity entity = (millis() % SITE_USER_RATIO == 0) 
        ? new Site(x, y)
        : new Surfer(x, y);
    boolean clash = false;
    for(Entity e : entities)
      clash = clash || (e != entity && e.distance(entity) < SEPERATION);
    if(clash)
      entity.remove();
    else
      placed = true;
    attempts--;
  }
  return placed;
}


void draw() {
  fill(255, 200);
  rect(0,0,width,height);
  
  // we take a clone to avoid concurrency issues
  ArrayList<Entity> clone = (ArrayList<Entity>) entities.clone();
  for(Entity e : clone)  e.think();
  for(Entity e : clone)  e.preDraw();
  for(Entity e : clone)  e.draw();
  for(Entity e : clone)  e.postDraw();
  
  if(recording) {
    //record.addFrame();
    save("capture/"+recordPrefix+bufferNumber(frameCount, 6)+".png");
  }
}

void keyPressed() {
  if(key == KEY_RECORDING_START) {
    recording = true;
  } else if(key == KEY_RECORDING_FINISH) {
    recording = false;
    //record.finish();  // Finish the movie if space bar is pressed!
  }
}

void mouseClicked() {
  for(User u : users) {
    if(u.containsClick()) {
      if(researcher == null)
        makeResearcher(u);
      break; // do not use our iterator further
    }
  }
  for(Site s : sites) {
    if(s.containsClick()) {
      if(youtube == null)
        makeYouTube(s);
      else if(project == null)
        makeProjectSite(s);
      else if(server == null)
        makeServer(s);
      break; // do not use our iterator further
    }
  }
}

void makeResearcher(User u) {
  if(researcher == null) {
    new Researcher(u.x, u.y);
    u.remove();
  }
}

void makeYouTube(Site s) {
  if(youtube == null && s != project && s != server) {
    new YouTube(s.x, s.y);
    s.remove();
  }
}

void makeProjectSite(Site s) {
  if(project == null && s != youtube && s != server) {
    new ProjectSite(s.x, s.y);
    s.remove();
  }
}

void makeServer(Site s) {
  if(server == null && s != youtube && s != project) {
    new Server(s.x, s.y);
    s.remove();
  }
}


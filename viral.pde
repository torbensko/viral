//import processing.video.*;

final int SEPERATION_NORM = 120;
final int SEPERATION_USER = 60;
final int SITE_USER_RATIO = 5; // i.e. SITE_USER_RATIO users to every site

final char KEY_RECORDING_START = 'r';
final char KEY_RECORDING_FINISH = ' ';
final char KEY_AUTOSETUP = 'k';
final char KEY_START_SEQENCE = 'l';

//MovieMaker record; // allows us to record the sequence
boolean recording = false;
String recordPrefix = "";

void setup() {
  size(800, 800);
  smooth();
  
  Calendar now = Calendar.getInstance();
  recordPrefix = ""+
      now.get(Calendar.YEAR)+"-"+
      bufferNumber(now.get(Calendar.MONTH)+1, 2)+"-"+
      bufferNumber(now.get(Calendar.DAY_OF_MONTH), 2)+"_"+
      bufferNumber(now.get(Calendar.HOUR_OF_DAY), 2)+"-"+
      bufferNumber(now.get(Calendar.MINUTE), 2)+"/";
  
  imageMode(CENTER);
  
  // we use the frame to help with the layout process
  background(255);
  fill(0);
}

// We set the canvas to white and then as we find a good spot, we fill it in with some black.
// In choosing a spot, we randomly pick a pixel and check whether it is white
boolean placeAnElement() {
  boolean placed = false;
  int attempts = 1000;
  int x = 0;
  int y = 0;
  while(attempts > 0 && !placed) {
    x = (int) random(width);
    y = (int) random(height);
    attempts--;
    if(red(get(x, y)) > 0)
      placed = true;
  }
  if(placed) {
    boolean createUser = floor(random(SITE_USER_RATIO)) % SITE_USER_RATIO != 0;
    Entity entity = createUser
        ? new Surfer(x, y)
        : new Site(x, y);
    float distance = 2 * (createUser ? SEPERATION_USER : SEPERATION_NORM) * SCALE;
    ellipse(x, y, distance, distance);
  }
  
  return placed;
}

boolean layingOut = true;

void draw() {
  // we use colours to allow us to make the layout constant in time
  if(layingOut) {
    layingOut = placeAnElement();
    return;
  }
  
  fill(255, 200);
  rect(0, 0, width, height);
  
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

void setupKeyPlayers() {
  makeResearcher(users.get(0));
  makeYouTube(sites.get(0));
  makeServer(sites.get(0));
  makeProjectSite(sites.get(0));
}
  
void startSequence() {
  researcher.publishSystem();
  researcher.publishVideo();
}

void keyPressed() {
  switch(key) {
    case KEY_RECORDING_START :
      recording = true;
      break;
    case KEY_RECORDING_FINISH :
      recording = false;
      break;
    case KEY_AUTOSETUP :
      setupKeyPlayers();
      break;
    case KEY_START_SEQENCE :
      startSequence();
      break;
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


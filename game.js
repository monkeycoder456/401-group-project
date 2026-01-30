//basics for interacting with canvas...
const canvas = document.getElementById('game_port');
const ctx = canvas.getContext('2d');

//gets the elements by ID to modify them later
const space_exitable = document.getElementById("space_excitable");
const up_excitable = document.getElementById("up_excitable");
const down_excitable = document.getElementById("down_excitable");
const left_excitable = document.getElementById("left_excitable");
const right_excitable = document.getElementById("right_excitable");
const restart_excitable = document.getElementById("restart_excitable");

//size of the game view port
canvas.width = 1000;
canvas.height = 650;

// //test of drawing a line
// ctx.moveTo(0,0);
// ctx.lineTo(200,100);
// ctx.stroke();

//for maze generation
const directions = ["N","S","E","W"];
const opposite = {"E":"W","W":"E","N":"S","S":"N"}
const polarized = {"S":["E", "W"],"N":["E", "W"],"E":["N","S"],"W":["N","S"]}
const deltaX = {"E":1,"W":-1,"N":0,"S":0};
const deltaY = {"E":0,"W":0,"N":-1,"S":1};

function drawTriangle_Reletive_to_point(x,y,direction,xScale,yScale){
    ctx.beginPath();
    // ctx.moveTo(x,y);
    // if(direction = "S"){
    //     ctx.lineTo(x + polarized[direction],y + 50);
    //     ctx.lineTo(x - 50,y + 50);
    // }
    // ctx.fill();
    console.log("polarized direction (the left and right of facing direction")
    console.log(polarized[direction])
    console.log(polarized[direction][0])
    console.log(polarized[direction][1])

    //kept here to explain what is going on
    // console.log("differences in X")
    // console.log(deltaX[direction])
    // console.log(deltaX[polarized[direction][0]])
    // console.log(deltaX[polarized[direction][1]])
    // console.log("differences in Y")
    // console.log(deltaY[direction])
    // console.log(deltaY[polarized[direction][0]])
    // console.log(deltaY[polarized[direction][1]])

    let sumX_first_point = deltaX[direction] + deltaX[polarized[direction][0]]
    let sumX_second_point = deltaX[direction] + deltaX[polarized[direction][1]]
    console.log("sign for X")
    console.log(sumX_first_point)
    console.log(sumX_second_point)

    let sumY_first_point = deltaY[direction] + deltaY[polarized[direction][0]]
    let sumY_second_point = deltaY[direction] + deltaY[polarized[direction][1]]
    console.log("sign for Y")
    console.log(sumY_first_point)
    console.log(sumY_second_point)
    ctx.moveTo(x,y);
    ctx.lineTo(x + xScale*sumX_first_point,y + yScale*sumY_first_point);
    ctx.lineTo(x + xScale*sumX_second_point,y + yScale*sumY_second_point);
    ctx.fill();
}

function drawMaze_Debug(maze,startx,starty,scalex,scaley){
    /*
    psudo code

    x_pos = startx
    y_pos = starty
    for row in maze:
        for slot in row:
            for direction in slot.keys:
                if slot[direction] == false:
                    set ctx color to black
                else:
                    set ctx color to green
                drawtriangle_Reletive_to_point(x,y,direction,scalex,scaley)
            x.pos += scalex * 2
        y_pos += scaley * 2
    */
}

drawTriangle_Reletive_to_point(50,50,"S",20,20);
drawTriangle_Reletive_to_point(50,50,"N",20,20);
drawTriangle_Reletive_to_point(50,50,"E",20,20);
drawTriangle_Reletive_to_point(50,50,"W",20,20);

/*BELOW IS ALL MAZE CREATION/HANDLING LOGIC

for clarity: X refers to COLUMNS; Y refers to ROWS
maze "paths" (lowkey I couldn't be bothered to even make them an object)
are just a set of four bools. each bool serves as a flag to tell if a side is open.
[0,0,0,0] = [up_open,dowm_open,left_open,right_open]
*/

class Maze{
    constructor(rows,columns){
        this.rows = rows;
        this.columns = columns;
        this.maze = new Array(rows)
        for (let i = 0; i < this.maze.length; i++) {
            this.maze[i] = new Array(columns);
        }
        console.log("finished creation");
        for (let i = 0; i < this.maze.length; i++){//this would give you the row
            // console.log(i)
            for (let j = 0; j < this.maze[i].length; j++){//this would give you the column
                // console.log(j);
                //technically i made it an object here so fuck whatever I said above I guess...
                this.maze[i][j] = {up_open:false,down_open:false,right_open:false,left_open:false};
            }
        }
    }
    updatePointInGraphViaArray(row,column,arrayofour) {
        this.maze[row][column] = {up_open:arrayofour[0],down_open:arrayofour[1],right_open:arrayofour[2],left_open:arrayofour[3]};
    }
    updatePointInGraphViaReplacement(row,column,newPathObject){
        this.maze[row][column] = newPathObject
    }
    getPointInGraph(row,column){
        try {
            return this.maze[row][column]
        } catch (error) {
            console.log(error)
        }
    }
    getCarvedStatus(row,column){
        //if return true, it has been carved
        //if return false, it HASN'T been carved
        const path_in_question = this.maze[row][column];
        if(path_in_question.up_open == true ||path_in_question.down_open == true||path_in_question.left_open == true||path_in_question.right_open == true){
            return true;
        }
        return false;
    }
    carvewall(direction,coordPair){
    //carves a wall in a direction, direction should be of, the carving affects 2 walls. the given coord and the neighboor we go to via direction
    /*
        0 = NORTH
        1 = SOUTH
        2 = EAST
        3 = WEST
    */
    //the maze will carve the wall itself. coordPair is expected to be a "coordPair" object
    if (direction == "N"){
        this.maze[coordPair.y][coordPair.x].up_open = true;
        this.maze[coordPair.y-1][coordPair.x].down_open = true;
    }
    if (direction == "S"){
        this.maze[coordPair.y][coordPair.x].down_open = true;
        this.maze[coordPair.y+1][coordPair.x].up_open = true;
    }
    if (direction == "E"){
        this.maze[coordPair.y][coordPair.x].right_open = true;
        this.maze[coordPair.y][coordPair.x+1].left_open = true;
    }
    if (direction == "W"){
        this.maze[coordPair.y][coordPair.x].left_open = true;
        this.maze[coordPair.y][coordPair.x-1].left_open = true;
    }

    }
}

class coordPair{
    constructor(X,Y){
        this.x = X;
        this.y = Y;
    }
    setX(newX){
        this.x = newX;
    }
    setY(newY){
        this.y = newY;
    }
    applyVector(vector){
        this.x += vector.getX();
        this.y += vector.getY();
    }
    getX(){
        return this.x;
    }
    getY(){
        return this.y;
    }
}

function generateMaze(row,column){
    //returns the made maze
    const maze = new Maze(row,column)
    //hunt and kill
    // choose starting location
    // here let it be 0,0 (top left corner)
    const current_location = new coordPair(0,0)
    while(current_location.getX() != -1 && current_location.getY() != -1){
        walking(maze,current_location)
        console.log("finished walk in maze, unable to move")
        console.log(maze.maze)
        console.log(current_location)
        console.log("beginning hunt for empty spots")
        const returned_coords = hunting(maze);
        if(returned_coords.getX() == -1 && returned_coords.getY() == -1){
            console.log("unable to find an open position. the maze is complete :-)")
            return maze
        }
        console.log("found something that works, we begin here:")
        current_location.setX(returned_coords.getX())
        current_location.setY(returned_coords.getY())
        console.log(current_location)
    }
}

function hunting(maze){
    console.log("inside hunt");
    //check for a pair of carved and uncarved next to eachother
    //returns a coordpair object with either a valid location to begin carving
    //OR
    //returns a coordpair object with x = -1, y = -1 to indicate that it has failed to find a free spot (AKA maze is complete)

    //iterate through maze to find an uncarved cell
    //once an uncarved cell is found, locate its neihboors
    //randomly choose a neighboor to carve a path into
    //return the position of that path (that will be the new current possition)
    let new_posY = -1;
    let new_posX = -1;
    for (let i = 0; i < maze.maze.length; i++){
        // console.log(i)
        for (let j = 0; j < maze.maze[i].length; j++){//this would give you the column
            // console.log(maze.getCarvedStatus(j,i))
            if (maze.getCarvedStatus(j,i) == false){
                new_posY = j;
                new_posX = i;
                console.log("found an uncarved wall @")
                console.log(new coordPair(new_posX,new_posY))
                break;
            }
        }
        if(new_posY != -1 && new_posX != -1){
            console.log("looping for search complete")
            break;
        }
    }
    console.log("beginning neighboor filtering")
    const list_of_neighboors = {}
    /*
    now create a list that contains potential canidates for carving to merge
    
    the canidates are adjecent neighboors
    the neighboor MUST be carved
    the neighboor MUST be inbounds

    */

    /*psudo-code

    */
    for (const direction of directions){
        const vector = new coordPair(deltaX[direction],deltaY[direction])
        //get the potential coords of an adjecent cell
        const neighboor = new coordPair(new_posX + vector.getX(),new_posY + vector.getY())
        //checking if inbounds
        let clampedX = Math.min(Math.max(neighboor.getX(),0),maze.maze[0].length-1)
        let clampedY = Math.min(Math.max(neighboor.getY(),0),maze.maze.length-1)
        //clampping may affect the number, check if it does. if it does change. that direction MUST be invalid.
        if (neighboor.getX() != clampedX || neighboor.getY() != clampedY){
            continue;
        }
        //check if it is carved, if NOT, continue
        if (maze.getCarvedStatus(neighboor.getY(),neighboor.getX()) == false){
            continue
        }
        //if we made it here then we passed both checks and the neighboor works.
        console.log("workable neighboor found @")
        console.log(neighboor)
        console.log("direction from here")
        console.log(direction)
        list_of_neighboors[direction] = neighboor;
    }
    console.log("all workable neighboors")
    console.log(list_of_neighboors)
    //if we fail to find any working neighboors, this implies that the maze is complete
    if (Object.keys(list_of_neighboors).length == 0){
        //we are unable to find valid neighboors, return -1 -1
        return new coordPair(-1,-1)
    }
    //get all the keys in the neighboor list
    const choices = Object.keys(list_of_neighboors)

    const choice = choices[Math.floor(Math.random() * choices.length)];
    //the choice is given in KEY form...

    //carve in that direction
    console.log("carving direction")
    console.log(choice)
    const empty = new coordPair(new_posX,new_posY);
    maze.carvewall(choice,empty);
    console.log("the new spot we are starting with")
    console.log(maze.maze[new_posY][new_posX])
    console.log("the spot we carved into that already exists in the maze")
    console.log(maze.maze[new_posY + deltaY[choice]][new_posX + deltaX[choice]])
    return new coordPair(new_posX,new_posY)
}

function walking(maze,current_location){
    let invalidDirections = [];
    const test_location = new coordPair(0,0)
    while(invalidDirections.length != 4){
    test_location.setX(current_location.getX())
    test_location.setY(current_location.getY())
    //calculate what directions I can use.
    //available = directions - invalid
    let availableDirections = directions.filter(x => !invalidDirections.includes(x))
        console.log(invalidDirections)
        console.log(availableDirections)
        console.log(directions)
    let direction = availableDirections[Math.floor(Math.random() * availableDirections.length)];
    console.log("chosen direction is")
    console.log(direction)
    console.log("current position is")
    console.log(current_location)
    /*
        0 = NORTH
        1 = SOUTH
        2 = EAST
        3 = WEST
    */
   //check if we can even walk in that direction.
   /*
    CANNOT:
        walk out of bounds (index -1 or index > array.length)
        walk over existing path (if it has been carved (aka if it is not all 0))
   */
    const vector = new coordPair(deltaX[direction],deltaY[direction])
    console.log(vector)
    test_location.applyVector(vector)
    console.log("attempting to move to coords")
    console.log(test_location)
    //clamp the vector so it will exist in the bounds of 0 to maze.length
    let clampedX = Math.min(Math.max(test_location.getX(),0),maze.maze[0].length-1)
    let clampedY = Math.min(Math.max(test_location.getY(),0),maze.maze.length-1)
    //clampping may affect the number, check if it does. if it does change. that direction MUST be invalid.
    if (test_location.getX() != clampedX || test_location.getY() != clampedY){
        invalidDirections.push(direction)
        continue;
    }

    //if the place we are trying to step into has already been carved, try again...
    if(maze.getCarvedStatus(test_location.getY(),test_location.getX()) == true){
        invalidDirections.push(direction)
        continue;
    }
    console.log("we can carve here.")    

    //carve a wall in that direction
    maze.carvewall(direction,current_location)
    //update current position to reflect we have moved to the new spot
    current_location.applyVector(vector)
    // //if can walk in different direction, 
    // console.log(current_location)
    console.log(maze.maze)
    invalidDirections = []
    }
    return -1
}
//ABOVE IS ALL MAZE CREATION/HANDLING LOGIC



//prints to the console of the web browser
console.log("HELLO sCRIPT FRIEND");

const ourMaze = generateMaze(5,5)






//basic imput handling
const keys = {};
document.addEventListener('keydown',(e) => {
    console.log("recording key down")
    keys[e.key] = true;
    updateDebugDisplay();
});
document.addEventListener('keyup',(e) => {
    console.log("recording key up")
    keys[e.key] = false;
    updateDebugDisplay();
});

//debug display of inputs (From my tests only 3 inputs can exist at once)
function updateDebugDisplay(){
    if(keys[' ']){
        space_exitable.style.backgroundColor = "cyan";
    }
    if(!keys[' ']){
        space_exitable.style.backgroundColor = "black";
    }
    if(keys['ArrowUp'] || keys['w']){
        up_excitable.style.backgroundColor = "cyan";
    }
    if(!(keys['ArrowUp'] || keys['w'])){
        up_excitable.style.backgroundColor = "black";
    }
    if(keys['ArrowDown'] || keys['s']){
        down_excitable.style.backgroundColor = "cyan";
    }
    if(!(keys['ArrowDown'] || keys['s'])){
        down_excitable.style.backgroundColor = "black";
    }
    if(keys['ArrowLeft'] || keys['a']){
        left_excitable.style.backgroundColor = "cyan";
    }
    if(!(keys['ArrowLeft'] || keys['a'])){
        left_excitable.style.backgroundColor = "black";
    }
    if(keys['ArrowRight'] || keys['d']){
        right_excitable.style.backgroundColor = "cyan";
    }
    if(!(keys['ArrowRight'] || keys['d'])){
        right_excitable.style.backgroundColor = "black";
    }
    if(keys['r']){
        restart_excitable.style.backgroundColor = "cyan";
    }
    if(!(keys['r'])){
        restart_excitable.style.backgroundColor = "black";
    }
}


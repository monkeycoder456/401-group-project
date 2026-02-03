/*
this file will handle the canvas settings and other options the games themselves shouldn't
have authority over.
*/
// basics for interacting with canvas...
const canvas = document.getElementById('game_port');
const debug_Canvas = document.getElementById('debug_port')
const ctx = canvas.getContext('2d');

//size of the game view port
canvas.width = 1000;
canvas.height = 650;

//gets the elements by ID to modify them later
const space_exitable = document.getElementById("space_excitable");
const up_excitable = document.getElementById("up_excitable");
const down_excitable = document.getElementById("down_excitable");
const left_excitable = document.getElementById("left_excitable");
const right_excitable = document.getElementById("right_excitable");
const restart_excitable = document.getElementById("restart_excitable");

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
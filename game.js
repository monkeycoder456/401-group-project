//basics for interacting with canvas...
const canvas = document.getElementById('game_port');
const ctx = canvas.getContext('2d');

//input debug test
const space_exitable = document.getElementById("space_excitable");
const up_excitable = document.getElementById("up_excitable");
const down_excitable = document.getElementById("down_excitable");
const left_excitable = document.getElementById("left_excitable");
const right_excitable = document.getElementById("right_excitable");
const restart_excitable = document.getElementById("restart_excitable");

canvas.width = 600;
canvas.height = 600;

ctx.moveTo(0,0);
ctx.lineTo(200,100);
ctx.stroke();

console.log("HELLO JAVA FRIEND");

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


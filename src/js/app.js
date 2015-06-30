$(document).ready(function(){
  $('select').material_select();
  $('.modal-trigger').leanModal();

  var snd = new Audio("/assets/sounds/perth.mp3");

  // janky looping
  snd.addEventListener('ended', function() {
    this.currentTime = 0;
    this.play();
  }, false);
  // snd.play();
})

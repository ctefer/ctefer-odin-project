var myImage = document.querySelector('img');
var myButton = document.querySelector('button');
var myHeading = document.querySelector('h1');

function setUserName() {
  var myName = prompt('Please enter your name.');
  localStorage.setItem('name', myName);
  myHeading.textContent = 'cTefer is cool, ' + myName;
}

myButton.onclick = function() {
  setUserName();
}

myImage.onclick = function() {
    var mySrc = myImage.getAttribute('src');
    if(mySrc === 'images/finite_port.jpg') {
      myImage.setAttribute ('src','images/chainlink.jpg');
    } else {
      myImage.setAttribute ('src','images/finite_port.jpg');
    }
}

if(!localStorage.getItem('name')) {
  setUserName();
} else {
  var storedName = localStorage.getItem('name');
  myHeading.textContent = 'cTefer is cool, ' + storedName;
}

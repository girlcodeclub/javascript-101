// 1. Find the <h1> element by its ID
const greetingElement = document.getElementById("greeting");
// 2. Ask the user for their name
const userName = prompt("What is your name?");
// 3. Change the text of the <h1> element
greetingElement.innerHTML = "Hello, " + userName + "!";

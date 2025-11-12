// This is a JavaScript comment. The computer ignores this text.
// It's just for notes!

// 1. Create variables
// 'let' is used to declare a new variable.
// We store "Thalia" in a variable called myName.
let myName = "Thalia"; 

// We can join strings (text) together with the + sign
let greeting = "Hello, " + myName + "!";


// 2. Find the HTML element
// 'document' refers to the whole HTML document.
// .getElementById() is a function that finds an element by its 'id'.
let greetingElement = document.getElementById("greeting-text");


// 3. Change the HTML element
// .innerHTML is a property that controls the text *inside* an HTML element.
// We are setting it to the value we stored in our 'greeting' variable.
greetingElement.innerHTML = greeting;

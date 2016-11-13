function multiples(input){
  var result = document.getElementById('result');
  var val = 0;
  for(i = 0; i < input; i+=3){
    val += i;
  }
  for(i = 0; i < input; i+=5){
    val += i;
  }
  var sub = 3*5;
  while(sub < input){
    val -= sub;
    sub += 3*5;
  }

  result.innerHTML  = val;
}

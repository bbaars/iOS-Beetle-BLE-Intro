
int LEDPIN = 2;

void setup() {
  Serial.begin(115200);
  pinMode(LEDPIN, OUTPUT);
}

void loop() {

  if(Serial.available()) {

    // obtain what is received from the iPhone
    int received = Serial.read();

    // write back to the iPhone what you received
    Serial.write(received);

    // turn the LED High
    digitalWrite(LEDPIN, HIGH);

    // if the button has been pressed 'twice' turn off LED
    if (received % 2 == 1) {
      digitalWrite(LEDPIN, LOW);
    }
   }
 }

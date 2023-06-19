#include <Keypad.h>

#define ROW_NUM     4 // four rows
#define COLUMN_NUM  4 // four columns

char keys[ROW_NUM][COLUMN_NUM] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};

byte pin_rows[ROW_NUM]      = {2, 13, 14, 0}; // GIOP19, GIOP18, GIOP5, GIOP17 connect to the row pins
byte pin_column[COLUMN_NUM] = {26, 25, 16, 17};   // GIOP16, GIOP4, GIOP0, GIOP2 connect to the column pins

Keypad keypad = Keypad( makeKeymap(keys), pin_rows, pin_column, ROW_NUM, COLUMN_NUM );

enum State {
  WAITING,
  PASSWORD_ENTERED,
  WAITING_FOR_PASSWORD
};

State currentState = WAITING;

const String correctPassword = "123789"; //change it to the actual password you like
String enteredPassword = "";

void setup() {
  Serial.begin(9600);
}

void loop() {
  char key = keypad.getKey();
  
  if (key != NO_KEY) {
    Serial.println(key);

    switch (currentState) {
      case WAITING:
        if (key == '*') {
          Serial.println("Enter Password");
          currentState = WAITING_FOR_PASSWORD;
          enteredPassword = "";
        }
        break;

      case WAITING_FOR_PASSWORD:
        if (key == '*') {
          currentState = WAITING;
        } else if (key == '#') {
          if (enteredPassword == correctPassword) {
            currentState = WAITING;
            Serial.println("Authentication successful");
          } else {
            Serial.println("Incorrect password!");
            currentState = WAITING;
          }
          enteredPassword = "";
        } else {
          enteredPassword += key;
        }
        break;

    }
  }
}

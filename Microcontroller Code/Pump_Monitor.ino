/*
  Float Switch Firebase IoT
  Works with both ESP32 and ESP8266
  Hardware: IT82WLCF float -> PC817/PS817C optocoupler -> ESP GPIO
  Function: Sends ON/OFF to Firebase, beeps on change
*/

#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif

#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// --- WiFi credentials ---
char ssid[][32] = { <ADD YOUR WIFI SSIDs SEPARATED BY COMMA> };
char pass[][32] = { <ADD YOUR WIFI SSIDs PASSWORD SEPARATED BY COMMA> };

// --- Firebase credentials ---
#define API_KEY "<Your Firebase API KEY>"
#define DATABASE_URL "<Your Firebase DATABASE URL>"  // must end with '/'

// --- Pins ---
#define FLOAT_PIN D2   // Input from PC817 collector
#define BUZZER_PIN D5  // Active buzzer output

// --- Wi-Fi watchdog timing ---
#define WIFI_CHECK_INTERVAL 30000UL  // check every 30 seconds
static unsigned long nextWiFiCheck = 0;

// --- Globals ---
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool lastState = false;  // ON/OFF logical state

// --- Function: WiFi connect with multiple fallback networks ---
void connectWiFi() {
  bool connected = false;

  while (!connected) {
    for (uint8_t i = 0; i < sizeof(ssid) / 32; i++) {
      Serial.printf("[WiFi] Trying %s\n", ssid[i]);
      WiFi.disconnect(true);
      delay(500);
      WiFi.begin(ssid[i], pass[i]);

      uint8_t tries = 0;
      while (WiFi.status() != WL_CONNECTED && tries < 20) {  // 10 seconds
        delay(500);
        Serial.print('.');
        tries++;
      }
      Serial.println();

      if (WiFi.status() == WL_CONNECTED) {
        connected = true;

        // Beep feedback
        for (int i = 0; i < 2; i++) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(100);
        digitalWrite(BUZZER_PIN, LOW);
        delay(200);
      }

        Serial.println("[WiFi] Connected!");
        Serial.print("IP: ");
        Serial.println(WiFi.localIP());
        delay(1000);
        break;  // exit loop after successful connection
      }
    }

    if (!connected) {
      Serial.println("[WiFi] All networks failed. Retrying in 2 minutes...");
      // Beep error tone
      for (int i = 0; i < 3; i++) {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(100);
        digitalWrite(BUZZER_PIN, LOW);
        delay(200);
      }
      for (int i = 0; i < 120; i++) delay(1000);  // 2 min wait
    }
  }
}

// --- Wi-Fi connection checker ---
void checkWiFi() {
  if (millis() < nextWiFiCheck) return;  // too soon
  nextWiFiCheck = millis() + WIFI_CHECK_INTERVAL;

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[WiFi] Lost connection!");
    delay(1000);
    Serial.println("[WiFi] Attempting reconnect...");
    connectWiFi();
  }
}

void setup() {
  Serial.begin(115200);
  delay(100);

  // Pin setup
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(FLOAT_PIN, INPUT_PULLUP);  // internal pull-up (LOW = float closed)
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  // --- Connect WiFi ---
  connectWiFi();

  // --- Firebase setup ---
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // --- Anonymous sign-in ---
  Serial.println("Signing in anonymously...");
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase anonymous sign-in OK!");
  } else {
    Serial.printf("Sign-up failed: %s\n", config.signer.signupError.message.c_str());
  }

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Initial state read
  bool raw = digitalRead(FLOAT_PIN);
  lastState = !raw;  // invert (LOW = ON)
  Serial.print("Initial State: ");
  Serial.println(lastState ? "ON" : "OFF");

  // Push initial state
  if (Firebase.ready()) {
    if (Firebase.RTDB.setBool(&fbdo, "/switch/state", lastState)) {
      Serial.println("Initial state uploaded to Firebase!");
    } else {
      Serial.println("Initial upload failed: " + fbdo.errorReason());
    }
  }
}

void loop() {
  digitalWrite(LED_BUILTIN, LOW);
  checkWiFi();  // periodically verify Wi-Fi connection

  bool raw = digitalRead(FLOAT_PIN);
  bool currentState = !raw;  // invert: LOW = ON

  if (currentState != lastState) {
    // Beep feedback
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);

    Serial.print("Float changed -> ");
    Serial.println(currentState ? "ON" : "OFF");

    // Firebase update
    if (Firebase.ready()) {
      if (Firebase.RTDB.setBool(&fbdo, "/switch/state", currentState)) {
        Serial.println("Firebase updated!");
      } else {
        Serial.println("Firebase write failed: " + fbdo.errorReason());
      }
    } else {
      Serial.println("Firebase not ready yet...");
    }

    lastState = currentState;
  }

  delay(100);
}

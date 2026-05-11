#include <WiFi.h>
#include <HTTPClient.h>

// ===== WIFI =====
const char* ssid = "TU_WIFI";
const char* password = "TU_PASSWORD";

// ===== TAGO =====
const char* token = "TU_TOKEN_TAGO";

// ===== HC-SR04 =====
#define TRIG 5
#define ECHO 18

long duracion;
float distancia;

void setup() {

  Serial.begin(115200);

  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);

  // conectar WiFi
  WiFi.begin(ssid, password);

  Serial.print("Conectando WiFi");

  while (WiFi.status() != WL_CONNECTED) {

    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi conectado");
}

void loop() {

  // limpiar trigger
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);

  // pulso ultrasónico
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);

  digitalWrite(TRIG, LOW);

  // leer eco
  duracion = pulseIn(ECHO, HIGH);

  // distancia cm
  distancia = duracion * 0.034 / 2;

  Serial.print("Distancia: ");
  Serial.print(distancia);
  Serial.println(" cm");

  // ===== ENVIAR A TAGO =====
  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient http;

    http.begin("https://api.tago.io/data");

    http.addHeader("Content-Type", "application/json");

    http.addHeader("Device-Token", token);

    // JSON
    String json = "[";

    json += "{\"variable\":\"distancia\",\"value\":";
    json += String(distancia);

    json += "}";

    json += "]";

    int httpResponseCode = http.POST(json);

    Serial.print("HTTP Response: ");
    Serial.println(httpResponseCode);

    http.end();
  }

  delay(3000);
}

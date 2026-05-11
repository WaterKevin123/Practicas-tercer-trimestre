#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

// ===== WIFI =====
const char* ssid = "TU_WIFI";
const char* password = "TU_PASSWORD";

// ===== TAGO =====
const char* token = "TU_TOKEN_TAGO";

// ===== DHT11 =====
#define DHTPIN 4
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

void setup() {

  Serial.begin(115200);

  dht.begin();

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

  float h = dht.readHumidity();

  float t = dht.readTemperature();

  // verificar
  if (isnan(h) || isnan(t)) {

    Serial.println("Error DHT");
    return;
  }

  Serial.print("Temp: ");
  Serial.println(t);

  Serial.print("Hum: ");
  Serial.println(h);

  // ===== ENVIAR A TAGO =====
  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient http;

    http.begin("https://api.tago.io/data");

    http.addHeader("Content-Type", "application/json");

    http.addHeader("Device-Token", token);

    // JSON
    String json = "[";

    json += "{\"variable\":\"temperatura\",\"value\":";
    json += String(t);
    json += "},";

    json += "{\"variable\":\"humedad\",\"value\":";
    json += String(h);
    json += "}";

    json += "]";

    int httpResponseCode = http.POST(json);

    Serial.print("HTTP Response: ");

    Serial.println(httpResponseCode);

    http.end();
  }

  delay(5000);
}

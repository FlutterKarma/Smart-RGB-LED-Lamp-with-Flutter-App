#include <FastLED.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
ESP8266WebServer server(80);
void handlePulse();
void handleColour();
void handle404();

#define LED_PIN     5
#define NUM_LEDS    30
#define BRIGHTNESS  64
#define LED_TYPE    WS2811
#define COLOR_ORDER GRB
CRGB leds[NUM_LEDS];



// This example shows several ways to set up and use 'palettes' of colors
// with FastLED.
//
// These compact palettes provide an easy way to re-colorize your
// animation on the fly, quickly, easily, and with low overhead.
//
// USING palettes is MUCH simpler in practice than in theory, so first just
// run this sketch, and watch the pretty lights as you then read through
// the code.  Although this sketch has eight (or more) different color schemes,
// the entire sketch compiles down to about 6.5K on AVR.
//
// FastLED provides a few pre-configured color palettes, and makes it
// extremely easy to make up your own color schemes with palettes.
//
// Some notes on the more abstract 'theory and practice' of
// FastLED compact palettes are at the bottom of this file.



CRGBPalette16 currentPalette;
TBlendType    currentBlending;

extern CRGBPalette16 myRedWhiteBluePalette;
extern const TProgmemPalette16 myRedWhiteBluePalette_p PROGMEM;


void setup() {

  //WiFi-Setup
  Serial.begin(9600);
  WiFi.begin("SSID", "PASSWORD");
  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  Serial.print("Connected, IP address: ");
  Serial.println(WiFi.localIP());

  //Server-Setup
  server.on("/colour", HTTP_POST, handleColour);
  server.onNotFound(handle404);
  
  server.begin();
   // power-up safety delay
    FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection( TypicalLEDStrip );
    FastLED.setBrightness(  BRIGHTNESS );
    
    currentPalette = RainbowColors_p;
    currentBlending = LINEARBLEND;
}


void loop()
{
    server.handleClient();

}

void FillLEDsFromPaletteColors(int r, int g, int b)
{
    uint8_t brightness = 255;
    
    for( int i = 0; i < NUM_LEDS; i++) {
        leds[i] =  CRGB( r, g, b);
       
    }
}






void setColour(int r, int g, int b){
  FillLEDsFromPaletteColors(r,g,b);
  FastLED.show();
}

void handleColour(){
  if (!server.hasArg("r") || !server.hasArg("g") || !server.hasArg("b") ||
      server.arg("r") == NULL || server.arg("g") == NULL || server.arg("b") == NULL){
        server.send(400, "text/plain", "400: Invalid Request");
        return;
      }
  setColour(
    server.arg("r").toInt(),
    server.arg("g").toInt(),
    server.arg("b").toInt()
  );
   Serial.println(server.arg("r"));
  server.send(200);
}

void handle404(){
  server.send(404, "text/plain", "404: Not found");
}

//effect-controll vars
//TODO: clean up whole effects section
bool blueFade=false;
bool colourFade=false;

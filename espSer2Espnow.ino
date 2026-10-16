#include "espNowMux.h"
#include "reliableStream.h"
#include "soc/rtc_cntl_reg.h"

#include <Adafruit_NeoPixel.h> 
Adafruit_NeoPixel led(1, 21, NEO_GRB + NEO_KHZ800);

ReliableStreamESPNow g5("IFLY", true /*alwaysBroadcast*/);
static const struct { 
    int led = 21; 
} pins;

//JStuff j;
void setup() {
#if 0 
    j.mqtt.active = false;
    j.jw.enabled = false;   
    j.begin();
    j.mqtt.active = false;
#endif
    wdtInit(10);
    Serial2.begin(19200, SERIAL_8N1, 1, 2);
    //Serial.begin(19200);
    //WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
    pinMode(pins.led, OUTPUT);
}



LineBuffer lb;
uint32_t lastRx = 0;
uint32_t heartBeat = 0;
int rxCount = 0;
int serConfig = 0;
int heartbeat = 0, lastHeartbeat = 0;
struct { 
    int r,g,b;
} color;
string got;
void loop() {
    string s = g5.read();
    //Serial.println("OK");
    neopixelWrite(21, color.g, color.r, color.b);
    while(Serial2.available()) { 
        
        //digitalWrite(pins.led, 1);
        color.r = 20;
        int c = Serial2.read();
        printf("%c", (char)c);
        //g5.write(sfmt("XXX=GOT CHAR '%c'", (char)c));
        got += sfmt("%c", (char)c);
        lastRx = millis();
        rxCount++;
        if (c == '\r') c = '\n';
        lb.add(c, [](const char *line) { 
            color.g = 30;
            color.r = 0;
            g5.write(sfmt("NMEA=%s", line));
        });
    }
    if (millis() - lastRx > 200) {
        color.g = color.r = 0;
    }   
    if (millis() - lastHeartbeat > 500) { 
        lastHeartbeat = millis();
        color.b = color.b != 0 ? 0 : 30;
    }
    wdtReset();
    delay(1);
}

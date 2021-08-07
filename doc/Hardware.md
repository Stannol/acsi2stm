Building the hardware for ACSI2STM
==================================

Hardware needed
---------------

 * A STM32F103C8T6 or compatible board. You can find them for a few dollars online. The "blue pill" works out of the box
   and the "black pill" requires minor modifications.
 * One or more SD card port(s) for your STM32. You can also solder wires on a SD to microSD adapter.
 * One or more SD card(s).
 * A male DB19 port (you can modify a DB25 port to fit) with a ribbon cable.
 * (recommended) A protoboard PCB to solder all the components and wires together.
 * Do *NOT* connect USB data lines on the STM32. Use the +5V or +3.3V pin to power it if you are unsure.


Building the ACSI cable
-----------------------

ACSI pin numbers, looking at the male connector pins:

    ---------------------------------
    \ 01 02 03 04 05 06 07 08 09 10 /
     \ 11 12 13 14 15 16 17 18 19  /
       ---------------------------

Use this table to match pins on the ACSI port and the STM32:

| ACSI | STM32 | PIN | Description      |
|:----:|:-----:|:---:|------------------|
|  01  | PB8   | D0  | Data 0 (LSB)     |
|  02  | PB9   | D1  | Data 1           |
|  03  | PB10  | D2  | Data 2           |
|  04  | PB11  | D3  | Data 3           |
|  05  | PB12  | D4  | Data 4           |
|  06  | PB13  | D5  | Data 5           |
|  07  | PB14  | D6  | Data 6           |
|  08  | PB15  | D7  | Data 7 (MSB)     |
|  09  | PB7   | CS  | Chip Select      |
|  10  | PA8   | IRQ | Interrupt        |
|  11  | GND   | GND | Ground           |
|  12  | (nc)  | RST | Reset            |
|  13  | GND   | GND | Ground           |
|  14  | PA12  | ACK | Acknowledge      |
|  15  | GND   | GND | Ground           |
|  16  | PB6   | A1  | Address bit      |
|  17  | GND   | GND | Ground           |
|  18  | (nc)  | R/W | Read/Write       |
|  19  | PA11  | DRQ | Data request     |

**WARNING**: Pinout changed in v2.0: PA8 and PA12 are swapped.

Notes:

 * GND is soldered together on the ST side. You can use a single wire for ground.
 * Reset is not needed as the STM32 resets itself if it stays in an inconsistent state for more than 2 seconds.
 * Keep the wires short. I had strange behavior with cables longer than 10cm (4 inches).
 * The read/write pin is not needed.
 * You can build a DB19 out of a DB25 by cutting 6 pins on one side and part of the external shielding. Male DB25
   are easy to find because they were used for parallel port cables or serial port sockets.
 * You will have to power the STM32 separately (e.g. with a USB cable).


Connecting the SD cards
-----------------------

SD card pins


        ______________________
      /|  |  |  |  |  |  |  | |
     /_|01|02|03|04|05|06|07|8|
    |  |__|__|__|__|__|__|__|_|
    |09|                      |
    |__|                      |


Use this table to match pins on the SD card port and the STM32:

| SD  | STM32 | PIN |
|:---:|:-----:|:---:|
| 01  | PA4 * | CS  |
| 02  | PA7   | MOSI|
| 03  | GND   | VSS |
| 04  | +3.3V | VDD |
| 05  | PA5   | CLK |
| 06  | GND   | VSS |
| 07  | PA6   | MISO|
| 08  | (nc)  | RSV |
| 09  | (nc)  | RSV |

If you want to use multiple SD cards, connect all SD card pins to the same STM32 pins except CS (SD pin 1).

Here is the table that indicates the STM32 pin for each CS pin of the different SD cards:

| ACSI ID | STM32 | Connect to        |
|--------:|:------|-------------------|
|       0 | PA4   | SD 0 pin 1 or GND |
|       1 | PA3   | SD 1 pin 1 or GND |
|       2 | PA2   | SD 2 pin 1 or GND |
|       3 | PA1   | SD 3 pin 1 or GND |
|       4 | PA0   | SD 4 pin 1 or GND |

Leave unused CS pins unconnected.

**WARNING**: Pinout changed in v2.0: PA0 was added, PBx were removed and unused SD card CS pins *must not* be grounded anymore.

For example, if you want 3 SD cards detected on ACSI IDs 0, 1 and 4:
 * Connect PA4 to pin 1 of the first SD card.
 * Connect PA3 to pin 1 of the second SD card.
 * Connect PA0 to pin 1 of the third SD card.
 * Leave PA1 and PA2 unconnected.

Notes:

 * The SD card had 2 GND pins. I don't know if they have to be both grounded, maybe one wire is enough.
 * You should put a decoupling capacitor of about 100nF between VDD and VSS, as close as possible from the SD card pins.
 * If you need other ACSI IDs, you can change the sdCs array in the source code. See "Compile-time options" below.
 * CS pins must be on GPIO port A (PA pins).


Using on a "Black pill" STM32 board
-----------------------------------

If you have these cheap "STM32 minimum development boards" from eBay, Amazon, Banggood or other chinese sellers, chances are that
you have either a "blue pill" or a "black pill" board. "blue" or "black" refers to the color of the PCB.

The problem with black pill designs is that the onboard LED is wired on PB12 instead of PC13, messing with data signals.

You will have to desolder the onboard LED (or its current-limiting resistor right under).

If you want an activity LED, put an external one with a 1k resistor in series on PC13.

Other boards were not tested and may require further adjustments.


Adapting a v1.0 board to v2.0
-----------------------------

If you built a board for v1.0, here are the changes you will have to do:

 * Cut the trace (or wire) between pin A8 of the STM32 and pin 14 of the ACSI port
 * Cut the trace (or wire) between pin A12 of the STM32 and pin 10 of the ACSI port
 * Solder a wire between pin A8 of the STM32 and pin 10 of the ACSI port
 * Solder a wire between pin A12 of the STM32 and pin 14 of the ACSI port
 * Cut any traces between A4, A3, A2, A1, B0, B1, B3 of the STM32 that go to GND. Make sure to keep traces that go to the SD card
   CS pin.

Sorry for the major inconvenience, but I had to do this to use hardware timers and the SdFat library that
use fixed pins on the microcontroller.

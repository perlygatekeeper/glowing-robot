/*
 * annoyatron.c — ATtiny10 firmware
 *
 * Wiring (SOT-23-6):
 *   PB0 (pin 1) → piezo +
 *   PB1 (pin 3) → piezo −  (differential drive, 2× louder)
 *   PB2 (pin 5) → TPI clock (programming only)
 *   PB3 (pin 4) → TPI data / RESET (programming only)
 *   VCC (pin 6) → CR2032 +
 *   GND (pin 2) → CR2032 −
 *
 * Behaviour:
 *   Sleeps in power-down mode drawing ~100 nA.
 *   Watchdog fires every 8 s; after SLEEP_CYCLES wakeups it chirps.
 *   Each chirp is a short two-tone blip — just enough to be maddening.
 *   Interval ≈ SLEEP_CYCLES × 8 s  (default 37 × 8 ≈ 5 minutes)
 *
 * Compile (avr-gcc):
 *   avr-gcc -mmcu=attiny10 -Os -o annoyatron.elf annoyatron.c
 *   avr-objcopy -O ihex annoyatron.elf annoyatron.hex
 *
 * Flash (avrdude + USBasp):
 *   avrdude -c usbasp -p t10 -U flash:w:annoyatron.hex
 *
 * Tuning:
 *   SLEEP_CYCLES   — number of 8-second watchdog intervals between chirps
 *   CHIRP_FREQ_HZ  — tone frequency in Hz (try 3800–4200 for max annoyance)
 *   CHIRP_MS       — chirp duration in milliseconds
 *   CPU_HZ         — must match fuse setting (default 8 MHz internal / 8 = 1 MHz)
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <util/delay.h>
#include <stdint.h>

/* ── tuneable parameters ─────────────────────────────────────── */
#define SLEEP_CYCLES   37       /* × 8 s ≈ 5 minutes             */
#define CHIRP_FREQ_HZ  4000     /* Hz — sits in peak annoyance band */
#define CHIRP_MS       80       /* ms per tone burst              */
#define CHIRP_FREQ2_HZ 3200     /* second tone for two-tone blip  */
#define CPU_HZ         1000000UL /* 8 MHz RC / 8 prescaler (default) */

/* ── pin masks ───────────────────────────────────────────────── */
#define PIEZO_A  _BV(PB0)
#define PIEZO_B  _BV(PB1)
#define PIEZO    (PIEZO_A | PIEZO_B)

/* ── derived timing ──────────────────────────────────────────── */
/* half-period in microseconds for each tone */
#define HALF_US_1  (500000UL / CHIRP_FREQ_HZ)
#define HALF_US_2  (500000UL / CHIRP_FREQ2_HZ)

/* cycles of toggle needed to fill CHIRP_MS */
#define TOGGLES_1  ((uint16_t)((uint32_t)CHIRP_FREQ_HZ * CHIRP_MS / 1000))
#define TOGGLES_2  ((uint16_t)((uint32_t)CHIRP_FREQ2_HZ * CHIRP_MS / 1000))

/* ── globals ─────────────────────────────────────────────────── */
static volatile uint8_t wdt_count = 0;

/* ── watchdog ISR ────────────────────────────────────────────── */
ISR(WDT_vect)
{
    wdt_count++;
}

/* ── helpers ─────────────────────────────────────────────────── */

/* Buzz the piezo differentially at the given half-period (µs) for n toggles */
static void buzz(uint16_t half_us, uint16_t toggles)
{
    uint8_t phase = 0;
    for (uint16_t i = 0; i < toggles * 2; i++) {
        if (phase) {
            PORTB = (PORTB & ~PIEZO) | PIEZO_A;   /* A high, B low  */
        } else {
            PORTB = (PORTB & ~PIEZO) | PIEZO_B;   /* B high, A low  */
        }
        phase ^= 1;
        /* _delay_us needs a compile-time constant; use loop instead */
        volatile uint16_t d = (uint16_t)(half_us * (CPU_HZ / 1000000UL) / 4);
        while (d--) asm volatile("nop");
    }
    PORTB &= ~PIEZO;   /* leave piezo de-energised */
}

/* Chirp: two short tones separated by a brief gap */
static void chirp(void)
{
    buzz(HALF_US_1, TOGGLES_1);
    _delay_ms(40);
    buzz(HALF_US_2, TOGGLES_2);
}

/* Set up the watchdog for 8-second interrupt-only mode */
static void wdt_enable_8s(void)
{
    /* timed sequence required by hardware */
    cli();
    CCP   = 0xD8;                   /* unlock protected registers */
    WDTCSR = _BV(WDP3) | _BV(WDP0) /* 8 s timeout                */
           | _BV(WDIE);             /* interrupt only, no reset    */
    sei();
}

/* Sleep in power-down; wake only on watchdog interrupt */
static void sleep_now(void)
{
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);
    sleep_enable();
    sei();
    sleep_cpu();
    sleep_disable();
}

/* ── main ────────────────────────────────────────────────────── */
int main(void)
{
    /* PB0 and PB1 as outputs; PB2/PB3 as inputs (TPI / floating) */
    DDRB  = PIEZO;
    PORTB = 0;

    wdt_enable_8s();

    for (;;) {
        sleep_now();

        if (wdt_count >= SLEEP_CYCLES) {
            wdt_count = 0;
            chirp();
        }
    }
}

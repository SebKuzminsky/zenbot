This is a breakout board for connecting the Zenbot to a Mesa FPGA board.

It connects to a standard 50-pin ribbon cable from the Mesa FPGA board.

It passes the servo pins for channels 0, 1, and 2 to a second 50-pin
connector, for connecting to the 7i30 and driving the X, Y, and Z servos.

The remaining FPGA connector pins are routed to screw terminals, for
additional IO (eg the control line for an SSR to power the spindle).

The servo control pins are:

    1-23, 29, 31, 35, 39, 43, 47 (and 49)

The GPIO pins are:

    25, 27, 33, 37, 41, 45 (and 49)

The male 50-pin connectors are TE Part #1-5499923-0

The screw terminals are Phoenix Contact Part #1725711, "MPT 0,5/ 8-2,54"


# Fabrication

1. Mount a piece of single-sided 1 oz copper clad board to the mill.
   Make sure it's level.

2. Insert a PreciseBits MN208-0100-002F cutter, touch off Z

3. Open the `outline.ngc` gcode file and touch off X and Y at the lower
   left corner of the work.

4. Safety glasses, hearing protection, and spindle on.

5. Open the `back-copper.ngc` gcode file and run it!

6. Switch to the PreciseBits RCC08-0315-026F cutter, touch off Z.

7. Safety glasses, hearing protection, and spindle on.

8. Run `drill-mill.ngc`.

9. Run `outline.ngc`.


# Lessons learned

Cut deeper!  Some of the cuts didn't remove all the copper.

The resistor lead holes should be a little larger diameter.  The other
four components (LED, screw terminal, 50-pin connectors) all fit well.

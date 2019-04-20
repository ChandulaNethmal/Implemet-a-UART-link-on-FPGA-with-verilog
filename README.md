# Implemet-a-UART-link-on-FPGA-with-verilog
Implement a UART(Universal Asynchronous Receiver Transmitter) link on an Altera (now Intel) DE2 115 development board with cyclone IV FPGA   using verilog HDL.
This post is regarding a HDL implementation of a UART(Universal Asynchronous Receiver Transmitter) for one of our university fourth semester projects. This was a group project of four group members. My group members are Chirath Diyagama, Isuru Nuwanthilaka and Dileepa Sandaruwan. For the project we were supposed to implement a UART link for a FPGA development board using Verilog as the HDL and send some data to another FPGA development board which also have a UART implementation.  Here we used a Used a Digilant Atlys FPGA development board with a Xilinx FPGA. That board is actually expensive to buy. But we burrowed that one from our laboratory for this project. There is no problem if you want to implement this using another board. 



Here we actually doing a bi-directional asynchronous communication between two FPGA board. Atlys FPGA board has certain number of switches as internal peripherals. We used each of them to represent a binary value. Using 8 switches we sent 8bit data words to other board. Then there are 8 LEDs assigned in to the output of the receiver and it will display the received data using that LEDs. After the communication between two boards we will talk about communication between a FPGA board and a Computer through USB connections.  In order to do so the only need is a USB to UART bridge for your board. There are so many cheaper boards with Xilinx and Altera chips which you can find from online sites.

# UART data frame
The structure of a UART frame can be illustrated as the above. Normally the data field can be varied from 4 bits to 9bits. There can be occupied a parity bit also.

When we consider the UART data frames that has several data fields. Here we are using only these fields.
●       Start Bit
●       Data bits
●       Stop bit/bits
For our project we are using one start bit, eight data bits and two stop bits.

# Baud Rate Generator
Every microprocessor and microcontroller require a clock signal because there are sequential circuits inside them. In our case also, there is an internal clock signal generator integrated onto the FPGA development board which provides a 100 MHz clock signal.

UART communication process also require a clock signal in order to generate and send each bit. But we cannot use the internal clock signal directly to our application. There are some standard Serial communication baud rates which the both transmitter and receiver parties should agree. Here we decided to use 115200 bits per second as the serial baud rate. We need a square shaped pulse at the above-mentioned clock rate in order to maintain a successful data communication. 

As a solution, we designed a Baud tick generator module using Verilog HDL and the schematic can be illustrated as shown in above figure.  The only input is the internal 100Mhz clock signal and the output is the Required Baud tick signal.

Here we are taking two inputs for our module as the input clock signal (which is a 100MHz ) and enable input to turn on or off the communication process. We have one output which is the baud tick signal.

# Integration of Baud Generator
Here we integrate this baud tick generator module in to both UART Receiver module and UART Transmitter modules. Therefore, both of them taking input clock as our FPGA board’s internal clock signal which is a 100MHz signal and then inside each module Baud tick generator converts 100MHz square pulse in to a 115200 ticks per second baud signal. 

# UART Transmitter
Here we take three inputs to the Transmitter which are the parallel 8 set of input which contains the exact data we need to send, the starting input which act as a transmission on/off  switch and the inbuilt clock signal from the FPGA development board. 
Inside this module we have our previously discussed baud tick generator and parallel to serial converter. Parallel data coming from 8 lines are time synchronously added together in to the rhythm of the baud tick and give to the out as a serial data  stream on a single line. We also have another output to indicate an end of a packet called 'Tx_done'.  

# UART Receiver


UART receiver taking two inputs which are input clock signal and the serial data input which is carrying a serial data stream sampled in a standard Baud Rate. Input serial data is again formed in to a set of 8 data lines after each packet is arrived in to the receiver.  

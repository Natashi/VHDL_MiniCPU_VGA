#include <SoftwareSerial.h>

// Use pins 2 and 3 for (RX, TX) with the FPGA using software UART
//	UNO's sole hardware serial is only used for the serial monitor

constexpr const int fpgaRx = 2;
constexpr const int fpgaTx = 3;
SoftwareSerial fpgaUart = SoftwareSerial(fpgaRx, fpgaTx);

//INPUT
String INP  = "";
String CMD  = "";
String REG1 = "";
String REG2 = "";
String REG3 = "";

//FLAGCHECK
String conditionalFlags[] = {"NV", "EQ", "NE", "AL", "LT", "LE", "GT", "GE"};
String FLAG_TEXT = "";

//DATA
String CONFLAG  = "000";  // 3 Bits
String OPC    = "00000";  // 5 Bits
String RS     = "0000";   // 4 Bits
String RT     = "0000";   // 4 Bits
String RD     = "0000";   // 4 Bits
String OPE    = "0000";   // 4 Bits
String IMM    = "0";      //16 Bits
String TD     = "";
uint64_t TDATA = 0;

//CHECKING
uint8_t CRC_DIV = 0;
uint8_t CRCVAL = 0;

//VARIABLE
bool isCommand = 1;

void initValue()
{
  //INPUT
  INP  = "";
  CMD  = "";
  REG1 = "";
  REG2 = "";
  REG3 = "";

  //FLAGCHECK
  FLAG_TEXT = "";

  //DATA
  CONFLAG  = "000";  // 3 Bits
  OPC      = "00000";  // 5 Bits
  RS       = "0000";   // 4 Bits
  RT       = "0000";   // 4 Bits
  RD       = "0000";   // 4 Bits
  OPE      = "0000";   // 4 Bits
  IMM      = "0";      //16 Bits
  TD       = "";
  TDATA    = 0;

  //CHECKING
  CRC_DIV = 0;
  CRCVAL = 0;

  //VARIABLE
  isCommand = 1;
}

void setup() {
	Serial.begin(115200);  // Initialize Serial Monitor
	
	pinMode(fpgaRx, INPUT);
	pinMode(fpgaTx, OUTPUT);
	
	fpgaUart.begin(9600);
}

//#define DEBUG_PRINT

void loop() {
  if (Serial.available())
  {
    //DEFAULT VALUE
    initValue();

    // INSERT COMMAND
    String input = Serial.readStringUntil('\n');  // Read input from Serial Monitor
    input.toUpperCase();
    INP = input;

    processCommand(input);
    getFlags(CMD, FLAG_TEXT);
    CONFLAG = convertFlagsToBits(FLAG_TEXT);
    commandToBits();


    if (isCommand)
    {

      TDATA = convertLongStringToBinary(TD);

      CRCVAL = calculateCRC(TDATA, CRC_DIV);

      TDATA = TDATA | CRCVAL;

      // PRINT ALL VALUE
      printAll();

      //SENDING DATA
      sendDataOverUART(convertBinaryToString(TDATA, 40));
    }
  }
}

void sendDataOverUART(String data)
{
  String dataString = data;

  // Prepare the buffer
  uint8_t buffer[5]; // Assuming 5 bytes for the 40 bits of data

  // Convert the data string to a binary format and store it in the buffer
  for (int i = 0; i < 5; i++)
  {
    buffer[i] = 0; // Initialize each byte of the buffer to 0

    // Set the bits in each byte of the buffer
    for (int j = 0; j < 8; j++)
    {
      int index = i * 8 + j; // Calculate the index in the data string

      // Convert the bit character to a binary value (0 or 1)
      uint8_t bitValue = dataString.charAt(index) - '0';

      // Reverse the bit order within each byte
      buffer[i] |= (bitValue << (7 - j));
    }
  }

  //// Print the original data value
  Serial.print("FINAL DATA SEND: ");
  for (int i = 0; i < 5; i++) {
    Serial.print(convertBinaryToString(buffer[i], 8));
    Serial.print(" ");
  }
  Serial.println();


	// Send the buffer over software UART to FPGA
	
	// The FPGA expects
	//		b0[7 to 0] b1[7 to 0] b2[7 to 0] b3[7 to 0] b4[7 to 0]
	//		<- sent last							 sent first ->
	
	// Serial is LSB first, so no need to worry about that
	// Bytes must be sent in a reverse order
	
	for (int i = 0; i < 5; i++) {
		fpgaUart.write(buffer[4 - i]);
	}
}

uint64_t convertLongStringToBinary(String str)
{
  // Extract upper and lower parts of the binary string
  String upperString = str.substring(0, 20);
  String lowerString = str.substring(20);

  // Convert upper and lower strings to uint32_t values
  uint32_t upperValue = strtoul(upperString.c_str(), NULL, 2);
  uint32_t lowerValue = strtoul(lowerString.c_str(), NULL, 2);

  // Combine upper and lower values into a uint64_t value
  uint64_t data = (static_cast<uint64_t>(upperValue) << 20) | lowerValue;
  return data;
}

uint8_t calculateCRC(uint32_t data, uint32_t divisor)
{
  uint8_t crc = 0;

  // Perform CRC calculation
  for (int i = 31; i >= 0; i--)
  {
    uint8_t msb_data = (data >> i) & 0x01;
    uint8_t msb_crc = (crc >> 7) & 0x01;

    crc = (crc << 1) | msb_data;

    if (msb_crc == 1)
    {
      crc ^= divisor;
    }
  }
  return crc;
}

String convertFlagsToBits(String flags)
{
  String flagsBits = "";

  if (flags == "NV")
  {
    flagsBits = "000";
  }
  else if (flags == "EQ")
  {
    flagsBits = "001";
  }
  else if (flags == "NE")
  {
    flagsBits = "010";
  }
  else if (flags == "AL")
  {
    flagsBits = "011";
  }
  else if (flags == "LT")
  {
    flagsBits = "100";
  }
  else if (flags == "LE")
  {
    flagsBits = "101";
  }
  else if (flags == "GT")
  {
    flagsBits = "110";
  }
  else if (flags == "GE")
  {
    flagsBits = "111";
  }
  else
  {
    flagsBits = "011";
  }
  return flagsBits;
}

void processCommand(String command)
{
  FLAG_TEXT = "";
  String delimiter = " ";
  String part;
  String parts[4]; // Array to store the three parts
  int index = 0; // Index for parts array

  while (command.length() > 0 && index < 4) {
    int delimiterIndex = command.indexOf(delimiter); // Find the index of the delimiter

    if (delimiterIndex == -1)
    {
      part = command; // Extract the remaining part of the command
    }
    else
    {
      part = command.substring(0, delimiterIndex); // Extract the part of the command
    }

    part.remove(','); // Remove the comma (',') from the part

    if (index == 1 || index == 2)
    {
      // Remove the comma (',') from the second part
      int commaIndex = part.indexOf(',');
      if (commaIndex != -1)
      {
        part = part.substring(0, commaIndex);
      }
    }
    command = command.substring(delimiterIndex + delimiter.length()); // Update the command to remove the extracted part and delimiter

    parts[index] = part; // Store the part in the parts array
    index++; // Move to the next index in the parts array
  }

  //UPDATE GLOBAL VALUE
  CMD  = parts[0];
  REG1 = parts[1];
  REG2 = parts[2];
  REG3 = parts[3];
}

void commandToBits() {
  String opcBit = "00000";
  String opeBit = "0000";

  int type = 0;

  // ------------------ SPECIAL -----------------
  if (CMD == "CLR")
  {
      opcBit = "01001";
      OPC = opcBit;
      TD = CONFLAG + OPC + RS + RD + IMM;
  }
  else if (CMD == "DCLR")
  {
      opcBit = "10000";
      opeBit = "0000";
      OPC = opcBit;
      OPE = opeBit;
      TD = CONFLAG + OPC + RS + RT + RD + OPE + "00000000";
  }
  //  ----------------- I-type -----------------
  else if (isNumeric(REG1) || isNumeric(REG2) || isNumeric(REG3))
  {
    if (CMD == "MOV")
    {
      opcBit = "00001";
      type = 1;
    }
    else if (CMD == "ADD")
    {
      opcBit = "00010";
      type = 2;
    }
    else if (CMD == "SUB")
    {
      opcBit = "00011";
      type = 2;
    }
    else if (CMD == "MUL")
    {
      opcBit = "00100";
      type = 2;
    }
    else if (CMD == "DIV")
    {
      opcBit = "00101";
      type = 2;
    }
    else if (CMD == "CMP")
    {
      opcBit = "00110";
      RS = updateRegister(REG1);
      IMM = updateRegister(REG2);
    }
    else if (CMD == "SLL")
    {
      opcBit = "00111";
      type = 2;
    }
    else if (CMD == "SRL")
    {
      opcBit = "01000";
      type = 2;
    }
    else if (CMD == "AND")
    {
      opcBit = "01010";
      type = 2;
    }
    else if (CMD == "ORR")
    {
      opcBit = "01011";
      type = 2;
    }
    else if (CMD == "XOR")
    {
      opcBit = "01100";
      type = 2;
    }
    else
    {
      isCommand = 0;
      Serial.println("ERROR AT I-TYPE");
    }
    if (type == 1)
    {
      RD  = updateRegister(REG1);
      IMM = updateRegister(REG2);
      if (REG2 != REG3)
      {
        isCommand = 0;
        Serial.println("ERROR: THIS COMMAND SHOULD HAVE ONLY 2 INPUT(Rd, Imm)");
      }
    }
    else if (type == 2)
    {
      RD  = updateRegister(REG1);
      RS  = updateRegister(REG2);
      IMM = updateRegister(REG3);
    }
    OPC = opcBit;
    TD = CONFLAG + OPC + RS + RD + IMM;
  }
  // ----------------- R-type -----------------
  else
  {
    if (CMD == "MOV")
    {
      opcBit = "00000";
      opeBit = "0000";
      type = 1;
    }
    else if (CMD == "ADD")
    {
      opcBit = "00000";
      opeBit = "0001";
      type = 2;
    }
    else if (CMD == "SUB")
    {
      opcBit = "00000";
      opeBit = "0010";
      type = 2;
    }
    else if (CMD == "MUL")
    {
      opcBit = "00000";
      opeBit = "0011";
      type = 2;
    }
    else if (CMD == "DIV")
    {
      opcBit = "00000";
      opeBit = "0100";
      type = 2;
    }
    else if (CMD == "CMP")
    {
      opcBit = "00000";
      opeBit = "0101";
      RS = updateRegister(REG1);
      RT = updateRegister(REG2);
    }
    else if (CMD == "SLL")
    {
      opcBit = "00000";
      opeBit = "0110";
      type = 2;
    }
    else if (CMD == "SRL")
    {
      opcBit = "00000";
      opeBit = "0111";
      type = 2;
    }
    else if (CMD == "NEG")
    {
      opcBit = "00000";
      opeBit = "1000";
      type = 1;
    }
    else if (CMD == "AND")
    {
      opcBit = "00000";
      opeBit = "1001";
      type = 2;
    }
    else if (CMD == "ORR")
    {
      opcBit = "00000";
      opeBit = "1010";
      type = 2;
    }
    else if (CMD == "XOR")
    {
      opcBit = "00000";
      opeBit = "1011";
      type = 2;
    }
    else if (CMD == "NOT")
    {
      opcBit = "00000";
      opeBit = "1100";
      type = 1;
    }
    else if (CMD == "DCHR")
    {
      opcBit = "10000";
      opeBit = "0001";
      type = 3;
    }
    else if (CMD == "DINT")
    {
      opcBit = "10000";
      opeBit = "0010";
      type = 3;
    }
    else if (CMD == "DCUR")
    {
      opcBit = "10000";
      opeBit = "0011";
      type = 3;
    }
    else if (CMD == "DCOL")
    {
      opcBit = "10000";
      opeBit = "0100";
      type = 3;
    }
    else
    {
      isCommand = 0;
      Serial.println("ERROR: SOMETHING WRONG AT R-TYPE");
    }

    if (type == 1)
    {
      RD = updateRegister(REG1);
      RS = updateRegister(REG2);
      if (REG2 != REG3)
      {
        isCommand = 0;
        Serial.println("ERROR: THIS COMMAND SHOULD HAVE ONLY 2 INPUT(Rd, Rs)");
      }
    }
    else if (type == 2)
    {
      RD = updateRegister(REG1);
      RS = updateRegister(REG2);
      RT = updateRegister(REG3);
    }
    else if (type == 3)
    {
      RS = updateRegister(REG1);
      if (REG1 != REG2 && REG1 != REG3 && REG2 != REG3)
      {
        isCommand = 0;
        Serial.print("ERROR: THIS COMMAND SHOULD HAVE ONLY 1 INPUT(Rs)");
      }
    }

    OPC = opcBit;
    OPE = opeBit;
    TD = CONFLAG + OPC + RS + RT + RD + OPE + "00000000";
  }
  findCRC(TD);
  TD = TD + "00000000";
}

void findCRC(String input)
{
  String dataString = input;

  // Prepare the buffer
  uint8_t buffer[4];

  for (int i = 0; i < 4; i++)
  {
    buffer[i] = 0; // Initialize each byte of the buffer to 0

    // Set the bits in each byte of the buffer
    for (int j = 0; j < 8; j++)
    {
      int index = i * 8 + j; // Calculate the index in the data string

      // Convert the bit character to a binary value (0 or 1)
      uint8_t bitValue = dataString.charAt(index) - '0';

      // Reverse the bit order within each byte
      buffer[i] |= (bitValue << (7 - j));
    }
  }

  //XOR 4 BYTE FOR CRC_DIVIDOR
  uint8_t temp = 0;
  for (int i = 0; i < 4; i++)
  {
    temp = temp ^ buffer[i];
  }
  CRC_DIV = temp;

}

String updateRegister(String bits)
{
  String str = "";
  int number = 0;
  if (isNumeric(bits))
  {
    number = bits.toInt();
    str = convertBinaryToString(number, 16);
  }
  else
  {
    str = bits.substring(1);
    number = str.toInt();
    str = convertBinaryToString(number, 4);
  }
  return str;
}

String convertBinaryToString(uint64_t number, int numBits) {
  String result;

  for (int i = numBits - 1; i >= 0; i--)
  {
    int bitValue = (number >> i) & 1; // Extract each bit using bitwise operations
    result += String(bitValue);
  }

  return result;
}

void printAll()
{
  //Print Command and Flags
  Serial.println("------------------- SHOW VALUE -------------------");
  Serial.println("INPUT     : " + INP);
  Serial.println("CMD       : " + CMD);
  Serial.println("REG1      : " + REG1);
  Serial.println("REG2      : " + REG2);
  Serial.println("REG3      : " + REG3);
  Serial.println("FLAG_TEXT : " + FLAG_TEXT);
  Serial.println("CONFLAG   : " + CONFLAG);
  Serial.println("OPC       : " + OPC);
  Serial.println("RS        : " + RS);
  Serial.println("RT        : " + RT);
  Serial.println("RD        : " + RD);
  Serial.println("OPE       : " + OPE);
  Serial.println("IMM       : " + IMM);

  Serial.print("CRC_DIV    : " );
  Serial.println(convertBinaryToString(CRC_DIV, 8));
  Serial.print("CRCVALUE   : ");
  Serial.println(convertBinaryToString(CRCVAL, 8));
  Serial.print("FINAL DATA :");
  Serial.println(convertBinaryToString(TDATA, 40));
}

void getFlags(String& cmd, String& flag) {
  String flags = "";

  for (int i = 0; i < sizeof(conditionalFlags) / sizeof(conditionalFlags[0]); i++)
  {
    if (cmd.endsWith(conditionalFlags[i]))
    {
      flags = conditionalFlags[i];
      cmd.remove(cmd.length() - flags.length());
      break;
    }
  }
  flag = flags;
}

//Check REG2 VALUE is R# or Number
bool isNumeric(const String& str)
{
  if (str.length() == 0)
  {
    return false;
  }

  for (size_t i = 0; i < str.length(); i++)
  {
    if (!isdigit(str.charAt(i)))
    {
      return false;
    }
  }

  return true;
}

// D1 compact diagnostic, 94 bytes,20ms sample opportunity; no serial motion commands.
module vision_cascade_diag #(parameter UART_DIV=434,MS_CYCLES=50000,PERIOD_MS=20,WIDE_RANGE=0)(
 input wire clk,rst_n,enabled,grant,
 input wire [31:0] time_ms,
 input wire [31:0] frame_ms,
 input wire [15:0] config_seq,
 input wire [7:0] selection,
 input wire [15:0] flags,
 input wire [7:0] cal_phase,
 input wire [7:0] cal_status,
 input wire [15:0] x,
 input wire [15:0] center,
 input wire [31:0] position,
 input wire [31:0] reference_q8,
 input wire [31:0] velocity_q4,
 input wire [15:0] frequency_hz,
 input wire [7:0] fault,
 input wire [7:0] spent,
 input wire [31:0] command_position,
 input wire [15:0] frame_number,
 input wire [(WIDE_RANGE ? 31 : 7):0] neutral,
 input wire [31:0] limit_anchor,command_anchor,work_min,work_max,feedback_min,feedback_max,
 input wire [15:0] config_errors,
 output wire tx,output reg busy=0
);
 localparam BYTES=WIDE_RANGE ? 71 : 44;
 wire [BYTES*8-1:0] payload=WIDE_RANGE ? {time_ms,frame_ms,config_seq,selection,flags,cal_phase,cal_status,x,center,position,reference_q8,velocity_q4,frequency_hz,fault,spent,command_position,frame_number,neutral,config_errors,limit_anchor,command_anchor,work_min,work_max,feedback_min,feedback_max} : {time_ms,frame_ms,config_seq,selection,flags,cal_phase,cal_status,x,center,position,reference_q8,velocity_q4,frequency_hz,fault,spent,command_position,frame_number,neutral,config_errors};
 reg [BYTES*8-1:0] snapshot=0;reg [7:0] checksum_snapshot=0;reg [7:0] checksum;integer j;
 always @*begin checksum=0;for(j=0;j<BYTES;j=j+1)checksum=checksum^payload[j*8+:8];end
 reg [31:0] timer=0;reg owed=0,bit_active=0;reg [(WIDE_RANGE ? 7 : 6):0] index=0;reg [3:0] bit_index=0;
 reg [15:0] baud=0;reg [9:0] shift=1023;
 assign tx=shift[0];
 function [7:0] hex_char;input [3:0] v;begin hex_char=v<10 ? "0"+v : "A"+v-10;end endfunction
 function [7:0] wide_message_byte; input [7:0] at;
reg [3:0] nibble;
begin nibble=0;case(at)
2: begin nibble=snapshot[567-:4];end
3: begin nibble=snapshot[563-:4];end
4: begin nibble=snapshot[559-:4];end
5: begin nibble=snapshot[555-:4];end
6: begin nibble=snapshot[551-:4];end
7: begin nibble=snapshot[547-:4];end
8: begin nibble=snapshot[543-:4];end
9: begin nibble=snapshot[539-:4];end
10: begin nibble=snapshot[535-:4];end
11: begin nibble=snapshot[531-:4];end
12: begin nibble=snapshot[527-:4];end
13: begin nibble=snapshot[523-:4];end
14: begin nibble=snapshot[519-:4];end
15: begin nibble=snapshot[515-:4];end
16: begin nibble=snapshot[511-:4];end
17: begin nibble=snapshot[507-:4];end
18: begin nibble=snapshot[503-:4];end
19: begin nibble=snapshot[499-:4];end
20: begin nibble=snapshot[495-:4];end
21: begin nibble=snapshot[491-:4];end
22: begin nibble=snapshot[487-:4];end
23: begin nibble=snapshot[483-:4];end
24: begin nibble=snapshot[479-:4];end
25: begin nibble=snapshot[475-:4];end
26: begin nibble=snapshot[471-:4];end
27: begin nibble=snapshot[467-:4];end
28: begin nibble=snapshot[463-:4];end
29: begin nibble=snapshot[459-:4];end
30: begin nibble=snapshot[455-:4];end
31: begin nibble=snapshot[451-:4];end
32: begin nibble=snapshot[447-:4];end
33: begin nibble=snapshot[443-:4];end
34: begin nibble=snapshot[439-:4];end
35: begin nibble=snapshot[435-:4];end
36: begin nibble=snapshot[431-:4];end
37: begin nibble=snapshot[427-:4];end
38: begin nibble=snapshot[423-:4];end
39: begin nibble=snapshot[419-:4];end
40: begin nibble=snapshot[415-:4];end
41: begin nibble=snapshot[411-:4];end
42: begin nibble=snapshot[407-:4];end
43: begin nibble=snapshot[403-:4];end
44: begin nibble=snapshot[399-:4];end
45: begin nibble=snapshot[395-:4];end
46: begin nibble=snapshot[391-:4];end
47: begin nibble=snapshot[387-:4];end
48: begin nibble=snapshot[383-:4];end
49: begin nibble=snapshot[379-:4];end
50: begin nibble=snapshot[375-:4];end
51: begin nibble=snapshot[371-:4];end
52: begin nibble=snapshot[367-:4];end
53: begin nibble=snapshot[363-:4];end
54: begin nibble=snapshot[359-:4];end
55: begin nibble=snapshot[355-:4];end
56: begin nibble=snapshot[351-:4];end
57: begin nibble=snapshot[347-:4];end
58: begin nibble=snapshot[343-:4];end
59: begin nibble=snapshot[339-:4];end
60: begin nibble=snapshot[335-:4];end
61: begin nibble=snapshot[331-:4];end
62: begin nibble=snapshot[327-:4];end
63: begin nibble=snapshot[323-:4];end
64: begin nibble=snapshot[319-:4];end
65: begin nibble=snapshot[315-:4];end
66: begin nibble=snapshot[311-:4];end
67: begin nibble=snapshot[307-:4];end
68: begin nibble=snapshot[303-:4];end
69: begin nibble=snapshot[299-:4];end
70: begin nibble=snapshot[295-:4];end
71: begin nibble=snapshot[291-:4];end
72: begin nibble=snapshot[287-:4];end
73: begin nibble=snapshot[283-:4];end
74: begin nibble=snapshot[279-:4];end
75: begin nibble=snapshot[275-:4];end
76: begin nibble=snapshot[271-:4];end
77: begin nibble=snapshot[267-:4];end
78: begin nibble=snapshot[263-:4];end
79: begin nibble=snapshot[259-:4];end
80: begin nibble=snapshot[255-:4];end
81: begin nibble=snapshot[251-:4];end
82: begin nibble=snapshot[247-:4];end
83: begin nibble=snapshot[243-:4];end
84: begin nibble=snapshot[239-:4];end
85: begin nibble=snapshot[235-:4];end
86: begin nibble=snapshot[231-:4];end
87: begin nibble=snapshot[227-:4];end
88: begin nibble=snapshot[223-:4];end
89: begin nibble=snapshot[219-:4];end
90: begin nibble=snapshot[215-:4];end
91: begin nibble=snapshot[211-:4];end
92: begin nibble=snapshot[207-:4];end
93: begin nibble=snapshot[203-:4];end
94: begin nibble=snapshot[199-:4];end
95: begin nibble=snapshot[195-:4];end
96: begin nibble=snapshot[191-:4];end
97: begin nibble=snapshot[187-:4];end
98: begin nibble=snapshot[183-:4];end
99: begin nibble=snapshot[179-:4];end
100: begin nibble=snapshot[175-:4];end
101: begin nibble=snapshot[171-:4];end
102: begin nibble=snapshot[167-:4];end
103: begin nibble=snapshot[163-:4];end
104: begin nibble=snapshot[159-:4];end
105: begin nibble=snapshot[155-:4];end
106: begin nibble=snapshot[151-:4];end
107: begin nibble=snapshot[147-:4];end
108: begin nibble=snapshot[143-:4];end
109: begin nibble=snapshot[139-:4];end
110: begin nibble=snapshot[135-:4];end
111: begin nibble=snapshot[131-:4];end
112: begin nibble=snapshot[127-:4];end
113: begin nibble=snapshot[123-:4];end
114: begin nibble=snapshot[119-:4];end
115: begin nibble=snapshot[115-:4];end
116: begin nibble=snapshot[111-:4];end
117: begin nibble=snapshot[107-:4];end
118: begin nibble=snapshot[103-:4];end
119: begin nibble=snapshot[99-:4];end
120: begin nibble=snapshot[95-:4];end
121: begin nibble=snapshot[91-:4];end
122: begin nibble=snapshot[87-:4];end
123: begin nibble=snapshot[83-:4];end
124: begin nibble=snapshot[79-:4];end
125: begin nibble=snapshot[75-:4];end
126: begin nibble=snapshot[71-:4];end
127: begin nibble=snapshot[67-:4];end
128: begin nibble=snapshot[63-:4];end
129: begin nibble=snapshot[59-:4];end
130: begin nibble=snapshot[55-:4];end
131: begin nibble=snapshot[51-:4];end
132: begin nibble=snapshot[47-:4];end
133: begin nibble=snapshot[43-:4];end
134: begin nibble=snapshot[39-:4];end
135: begin nibble=snapshot[35-:4];end
136: begin nibble=snapshot[31-:4];end
137: begin nibble=snapshot[27-:4];end
138: begin nibble=snapshot[23-:4];end
139: begin nibble=snapshot[19-:4];end
140: begin nibble=snapshot[15-:4];end
141: begin nibble=snapshot[11-:4];end
142: begin nibble=snapshot[7-:4];end
143: begin nibble=snapshot[3-:4];end
144: begin nibble=checksum_snapshot[7:4];end
145: begin nibble=checksum_snapshot[3:0];end
default: nibble=0;
endcase
// Four framing bytes are explicit gates, not an inferred synchronous ROM.
// Keep payload selection and shared ASCII conversion unchanged.
wide_message_byte=({8{at==0}} & 8'h44) |
                  ({8{at==1}} & 8'h32) |
                  ({8{at==146}} & 8'h0d) |
                  ({8{at==147}} & 8'h0a) |
                  ({8{at>=2 && at<=145}} & hex_char(nibble)) |
                  ({8{at>=148}} & 8'h3f);end endfunction
 function [7:0] message_byte;input [(WIDE_RANGE ? 7 : 6):0] at;begin if(WIDE_RANGE)message_byte=wide_message_byte(at);else case(at)
 0:message_byte="D";
1:message_byte="1";
2:message_byte=hex_char(snapshot[351-:4]);
3:message_byte=hex_char(snapshot[347-:4]);
4:message_byte=hex_char(snapshot[343-:4]);
5:message_byte=hex_char(snapshot[339-:4]);
6:message_byte=hex_char(snapshot[335-:4]);
7:message_byte=hex_char(snapshot[331-:4]);
8:message_byte=hex_char(snapshot[327-:4]);
9:message_byte=hex_char(snapshot[323-:4]);
10:message_byte=hex_char(snapshot[319-:4]);
11:message_byte=hex_char(snapshot[315-:4]);
12:message_byte=hex_char(snapshot[311-:4]);
13:message_byte=hex_char(snapshot[307-:4]);
14:message_byte=hex_char(snapshot[303-:4]);
15:message_byte=hex_char(snapshot[299-:4]);
16:message_byte=hex_char(snapshot[295-:4]);
17:message_byte=hex_char(snapshot[291-:4]);
18:message_byte=hex_char(snapshot[287-:4]);
19:message_byte=hex_char(snapshot[283-:4]);
20:message_byte=hex_char(snapshot[279-:4]);
21:message_byte=hex_char(snapshot[275-:4]);
22:message_byte=hex_char(snapshot[271-:4]);
23:message_byte=hex_char(snapshot[267-:4]);
24:message_byte=hex_char(snapshot[263-:4]);
25:message_byte=hex_char(snapshot[259-:4]);
26:message_byte=hex_char(snapshot[255-:4]);
27:message_byte=hex_char(snapshot[251-:4]);
28:message_byte=hex_char(snapshot[247-:4]);
29:message_byte=hex_char(snapshot[243-:4]);
30:message_byte=hex_char(snapshot[239-:4]);
31:message_byte=hex_char(snapshot[235-:4]);
32:message_byte=hex_char(snapshot[231-:4]);
33:message_byte=hex_char(snapshot[227-:4]);
34:message_byte=hex_char(snapshot[223-:4]);
35:message_byte=hex_char(snapshot[219-:4]);
36:message_byte=hex_char(snapshot[215-:4]);
37:message_byte=hex_char(snapshot[211-:4]);
38:message_byte=hex_char(snapshot[207-:4]);
39:message_byte=hex_char(snapshot[203-:4]);
40:message_byte=hex_char(snapshot[199-:4]);
41:message_byte=hex_char(snapshot[195-:4]);
42:message_byte=hex_char(snapshot[191-:4]);
43:message_byte=hex_char(snapshot[187-:4]);
44:message_byte=hex_char(snapshot[183-:4]);
45:message_byte=hex_char(snapshot[179-:4]);
46:message_byte=hex_char(snapshot[175-:4]);
47:message_byte=hex_char(snapshot[171-:4]);
48:message_byte=hex_char(snapshot[167-:4]);
49:message_byte=hex_char(snapshot[163-:4]);
50:message_byte=hex_char(snapshot[159-:4]);
51:message_byte=hex_char(snapshot[155-:4]);
52:message_byte=hex_char(snapshot[151-:4]);
53:message_byte=hex_char(snapshot[147-:4]);
54:message_byte=hex_char(snapshot[143-:4]);
55:message_byte=hex_char(snapshot[139-:4]);
56:message_byte=hex_char(snapshot[135-:4]);
57:message_byte=hex_char(snapshot[131-:4]);
58:message_byte=hex_char(snapshot[127-:4]);
59:message_byte=hex_char(snapshot[123-:4]);
60:message_byte=hex_char(snapshot[119-:4]);
61:message_byte=hex_char(snapshot[115-:4]);
62:message_byte=hex_char(snapshot[111-:4]);
63:message_byte=hex_char(snapshot[107-:4]);
64:message_byte=hex_char(snapshot[103-:4]);
65:message_byte=hex_char(snapshot[99-:4]);
66:message_byte=hex_char(snapshot[95-:4]);
67:message_byte=hex_char(snapshot[91-:4]);
68:message_byte=hex_char(snapshot[87-:4]);
69:message_byte=hex_char(snapshot[83-:4]);
70:message_byte=hex_char(snapshot[79-:4]);
71:message_byte=hex_char(snapshot[75-:4]);
72:message_byte=hex_char(snapshot[71-:4]);
73:message_byte=hex_char(snapshot[67-:4]);
74:message_byte=hex_char(snapshot[63-:4]);
75:message_byte=hex_char(snapshot[59-:4]);
76:message_byte=hex_char(snapshot[55-:4]);
77:message_byte=hex_char(snapshot[51-:4]);
78:message_byte=hex_char(snapshot[47-:4]);
79:message_byte=hex_char(snapshot[43-:4]);
80:message_byte=hex_char(snapshot[39-:4]);
81:message_byte=hex_char(snapshot[35-:4]);
82:message_byte=hex_char(snapshot[31-:4]);
83:message_byte=hex_char(snapshot[27-:4]);
84:message_byte=hex_char(snapshot[23-:4]);
85:message_byte=hex_char(snapshot[19-:4]);
86:message_byte=hex_char(snapshot[15-:4]);
87:message_byte=hex_char(snapshot[11-:4]);
88:message_byte=hex_char(snapshot[7-:4]);
89:message_byte=hex_char(snapshot[3-:4]);
90:message_byte=hex_char(checksum_snapshot[7:4]);
91:message_byte=hex_char(checksum_snapshot[3:0]);
92:message_byte=13;
93:message_byte=10;
 default:message_byte="?";endcase end endfunction
 always @(posedge clk)begin
  if(!rst_n)begin snapshot<=0;checksum_snapshot<=0;timer<=0;owed<=0;busy<=0;bit_active<=0;index<=0;bit_index<=0;baud<=0;shift<=1023;end
  else begin
   if(timer==MS_CYCLES*PERIOD_MS-1)begin timer<=0;if(enabled)owed<=1;end else timer<=timer+1'b1;
   if(!enabled)owed<=0;
   if(!busy && owed && enabled && grant)begin snapshot<=payload;checksum_snapshot<=checksum;owed<=0;index<=0;busy<=1;end
   else if(busy)begin
    if(!bit_active)begin shift<={1'b1,message_byte(index),1'b0};baud<=0;bit_index<=0;bit_active<=1;end
    else if(baud==UART_DIV-1)begin
     baud<=0;shift<={1'b1,shift[9:1]};
     if(bit_index==9)begin bit_active<=0;if(index==(WIDE_RANGE ? 147 : 93))busy<=0;else index<=index+1'b1;end
     else bit_index<=bit_index+1'b1;
    end else baud<=baud+1'b1;
   end
  end
 end
endmodule

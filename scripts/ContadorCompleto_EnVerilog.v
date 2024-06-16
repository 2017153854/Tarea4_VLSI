`timescale 1ns/10ps





// -------------------------------------------------------
// CONTADOR DE 8 BITS
// -------------------------------------------------------
// Este módulo utiliza al contador de 1 bit para generar
// un contador de 8 bits síncrono, arriba/abajo, con enable, 
// reset y carga paralela. 
//
// Entradas (6):
// -> CLK: Reloj. 
// -> E: Enable/Stand-By. Activo en 1.
// -> R: Reset. Activo en 0.
// -> DU: Down/Up. 1 para cuenta descendente. 0 para cuenta ascendente.
// -> L: Load. Para cargar un valor y contar a partir de este. Activo en 1.
// -> D: Dato a ser cargado en caso de darse un 'load'. Bus de 8 bits.
//
// Salidas (2):
// -> TC: Terminal Counter. Overflow o underflow.
// -> Q: Aquí se presenta el valor de salida del contador. Bus de 8 bits.
// -------------------------------------------------------
module FullCounter (input CLK, input E, input R, input DU, input L, input [7:0] D, output [7:0] Q, output TC);

    wire [7:0] nodo;	//Para almacenar los carry out de los contadores1x1 individuales.
    wire [7:0] dummy;	//Para dejar al aire las salidas 'tc' de los contadores1x1 individuales.

    FullCounter1x1 x0 (	//Bit 0 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[0]),
        .ci(!DU), 
        .q(Q[0]), 
        .co(nodo[0]),
        .tc(dummy[0])
    );

    FullCounter1x1 x1 (	//Bit 1 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[1]),
        .ci(nodo[0]), 
        .q(Q[1]), 
        .co(nodo[1]),
        .tc(dummy[1])
    );

    FullCounter1x1 x2 (	//Bit 2 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[2]),
        .ci(nodo[1]), 
        .q(Q[2]), 
        .co(nodo[2]),
        .tc(dummy[2])
    );

    FullCounter1x1 x3 (	//Bit 3 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[3]),
        .ci(nodo[2]), 
        .q(Q[3]), 
        .co(nodo[3]),
        .tc(dummy[3])
    );

    FullCounter1x1 x4 (	//Bit 4 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[4]),
        .ci(nodo[3]), 
        .q(Q[4]), 
        .co(nodo[4]),
        .tc(dummy[4])
    );

    FullCounter1x1 x5 (	//Bit 5 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[5]),
        .ci(nodo[4]), 
        .q(Q[5]), 
        .co(nodo[5]),
        .tc(dummy[5])
    );

    FullCounter1x1 x6 (	//Bit 6 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[6]),
        .ci(nodo[5]), 
        .q(Q[6]), 
        .co(nodo[6]),
        .tc(dummy[6])
    );

    FullCounter1x1 x7 (	//Bit 7 
        .clk(CLK), 
        .e(E), 
        .r(R), 
        .du(DU), 
        .l(L), 
        .d(D[7]),
        .ci(nodo[6]), 
        .q(Q[7]), 
        .co(nodo[7]),
        .tc(dummy[7])
    );

    assign TC = DU ^ nodo[7];

endmodule
// -------------------------------------------------------





// -------------------------------------------------------
// CONTADOR DE 1 BIT
// -------------------------------------------------------
// Este módulo utiliza las librerías estándar (sumador,
// mux y registro) para formar un contador de 1 bit.
// No es neceasrio implementar la bandera de 'overflow' o 
// 'underflow', pero igualmente se integrará la lógica necesaria 
// para esta salida.
//
// Entradas (7):
// -> clk: Reloj.
// -> e: Enable/Stand-By. Activo en 1. 
// -> r: Reset. Activo en 0.
// -> du: Down/Up. 1 para cuenta descendente. 0 para cuenta ascendente.
// -> l: Load. Para cargar un dato y contar a partir de este. Activo en 1.
// -> d: Dato a ser cargado en caso de darse un 'load'.
// -> ci: Carry In.
//
// Salidas (3):
// -> tc: Terminal Counter. Overflow o underflow.
// -> co: Carry Out.
// -> q: Aquí se presenta el valor de salida del contador.
// -------------------------------------------------------
module FullCounter1x1 (input clk, input e, input r, input du, input l, input d, input ci, output q, output co, output tc);

    wire n1;	// Salida del sumador y entrada '0' del mux.
    wire n2;	// Salida del mux y entrada del registro.
    wire dude;   // Para dejar una patilla al aire.

    FAHDLLX0 fa2x1 (	// Instancia del sumador
        .A(du), 
        .B(q), 
        .CI(ci), 
        .S(n1), 
        .CO(co)
    );

    MU4HDLLX0 mux4x1 (	// Instancia del MUX 4 a 1
        .IN0(n1),	//Conteo.
        .IN1(d),	//Load.
        .IN2(q),	//StandBy: 2 y 3 son 'q' porque si tenemos 2'b1X,
        .IN3(q),	//el valor del segundo bit (load) no importa.
        .S0(l), 
        .S1(e),
        .Q(n2)
    );

    DFRRHDLLX0 register1x1 (	// Instancia del Registro
        .C(clk), 
        .D(n2), 
        .RN(r), 
        .Q(q),
        .QN(dude)
    );

    assign tc = du ^ co;

endmodule
// -------------------------------------------------------





`celldefine
module FAHDLLX0 (A, B, CI, CO, S);
//*****************************************************************
//   technology       : 180 nm HV SOI CMOS
//   module name      : FAHDLLX0
//   version          : 1.3.0, Tue Apr 28 06:15:00 2020
//   cell_description : Full Adder
//   last modified by : XLIB_PROC generated
//****************************************************************************

   input     A, B, CI;
   output    CO, S;

// logic section:

	wire    n_0, n_1, n_2;

// Function CO: (B*CI) + (A*CI) + (A*B)
	and	i0 (n_0, B, CI);
	and	i1 (n_1, A, CI);
	and	i2 (n_2, A, B);
	or	i3 (CO, n_0, n_1, n_2);

// Function S: (A^B^CI)
	xor	i4 (S, A, B, CI);

// timing section:
   specify
      (A +=> CO) = (0.02, 0.02);
      (posedge A => (S -: S)) = (0.02, 0.02);
      (negedge A => (S -: S)) = (0.02, 0.02);
      if (((B == 1'b0 && CI == 1'b0))) (A +=> S) = (0.02, 0.02);
      if ((B == 1'b1 && CI == 1'b0)) (A -=> S) = (0.02, 0.02);
      if (((B == 1'b1 && CI == 1'b1))) (A +=> S) = (0.02, 0.02);
      (B +=> CO) = (0.02, 0.02);
      (posedge B => (S -: S)) = (0.02, 0.02);
      (negedge B => (S -: S)) = (0.02, 0.02);
      if ((A == 1'b0 && CI == 1'b0)) (B +=> S) = (0.02, 0.02);
      if ((A == 1'b1 && CI == 1'b0)) (B -=> S) = (0.02, 0.02);
      if ((A == 1'b1 && CI == 1'b1)) (B +=> S) = (0.02, 0.02);
      (CI +=> CO) = (0.02, 0.02);
      (posedge CI => (S -: S)) = (0.02, 0.02);
      (negedge CI => (S -: S)) = (0.02, 0.02);
      if ((A == 1'b0 && B == 1'b0)) (CI +=> S) = (0.02, 0.02);
      if ((A == 1'b0 && B == 1'b1)) (CI -=> S) = (0.02, 0.02);
      if ((A == 1'b1 && B == 1'b1)) (CI +=> S) = (0.02, 0.02);
   endspecify
endmodule
`endcelldefine





`celldefine
module MU4HDLLX0 (IN0, IN1, IN2, IN3, Q, S0, S1);
//*****************************************************************
//   technology       : 180 nm HV SOI CMOS
//   module name      : MU4HDLLX0
//   version          : 1.3.0, Tue Apr 28 06:15:00 2020
//   cell_description : 4:1 Multiplexer
//   last modified by : XLIB_PROC generated
//****************************************************************************

   input     IN0, IN1, IN2, IN3, S0, S1;
   output    Q;

// logic section:

	wire    n_0, n_1;

// Function Q: (IN0*(!S0*!S1))+(IN1*(S0*!S1))+(IN2*(!S0*S1))+(IN3*(S0*S1))
	u_mx2	i0 (n_0, IN0, IN1, S0);
	u_mx2	i1 (n_1, IN2, IN3, S0);
	u_mx2	i2 (Q, n_0, n_1, S1);

// timing section:
   specify
      (IN0 +=> Q) = (0.02, 0.02);
      (IN1 +=> Q) = (0.02, 0.02);
      (IN2 +=> Q) = (0.02, 0.02);
      (IN3 +=> Q) = (0.02, 0.02);
      (posedge S0 => (Q -: Q)) = (0.02, 0.02);
      (negedge S0 => (Q -: Q)) = (0.02, 0.02);
      (posedge S1 => (Q -: Q)) = (0.02, 0.02);
      (negedge S1 => (Q -: Q)) = (0.02, 0.02);
   endspecify
endmodule
`endcelldefine





`celldefine
module DFRRHDLLX0 (C, D, Q, QN, RN);
//*****************************************************************
//   technology       : 180 nm HV SOI CMOS
//   module name      : DFRRHDLLX0
//   version          : 1.3.0, Tue Apr 28 06:15:00 2020
//   cell_description : posedge D-Flip-Flop with Reset
//   last modified by : XLIB_PROC generated
//****************************************************************************

   input     C, D, RN;
   output    Q, QN;

`ifdef NEG_TCHK

// logic section:

	reg     NOTIFY_REG;
	wire    delay_C, delay_RN, delay_D, IQ, IQN, c_SH_D;

	u1_fd5	i0 (IQ, delay_D, delay_C, delay_RN, 1'b1, NOTIFY_REG);
	not	i1 (IQN, IQ);
	buf	i2 (Q, IQ);
	buf	i3 (QN, IQN);
	checkrs	i4 (c_SH_D, delay_RN, 1'b1);

// timing section:
   specify
      (posedge C => (Q +: D)) = (0.02, 0.02);
      (posedge C => (QN -: D)) = (0.02, 0.02);
      (negedge RN => (Q +: RN)) = (0.02, 0.02);
      (negedge RN => (QN -: RN)) = (0.02, 0.02);

	$setuphold(posedge C &&& c_SH_D, posedge D, 0.02, 0.02, NOTIFY_REG,,, delay_C, delay_D);
	$setuphold(posedge C &&& c_SH_D, negedge D, 0.02, 0.02, NOTIFY_REG,,, delay_C, delay_D);
	$recrem(posedge RN, posedge C, 0.02, 0.02, NOTIFY_REG,,, delay_RN, delay_C);
	$width(posedge C, 0.02, 0, NOTIFY_REG);
	$width(negedge C, 0.02, 0, NOTIFY_REG);
	$width(negedge RN, 0.02, 0, NOTIFY_REG);
   endspecify

`else   // NEG_TCHK

// logic section:

	reg     NOTIFY_REG;
	wire    IQ, IQN, c_SH_D;

	u1_fd5	i0 (IQ, D, C, RN, 1'b1, NOTIFY_REG);
	not	i1 (IQN, IQ);
	buf	i2 (Q, IQ);
	buf	i3 (QN, IQN);
	checkrs	i4 (c_SH_D, RN, 1'b1);

// timing section:
   specify
      (posedge C => (Q +: D)) = (0.02, 0.02);
      (posedge C => (QN -: D)) = (0.02, 0.02);
      (negedge RN => (Q +: RN)) = (0.02, 0.02);
      (negedge RN => (QN -: RN)) = (0.02, 0.02);

	$setuphold(posedge C &&& c_SH_D, posedge D, 0.02, 0.02, NOTIFY_REG);
	$setuphold(posedge C &&& c_SH_D, negedge D, 0.02, 0.02, NOTIFY_REG);
	$recrem(posedge RN, posedge C, 0.02, 0.02, NOTIFY_REG);
	$width(posedge C, 0.02, 0, NOTIFY_REG);
	$width(negedge C, 0.02, 0, NOTIFY_REG);
	$width(negedge RN, 0.02, 0, NOTIFY_REG);
   endspecify

`endif   // NEG_TCHK
endmodule
`endcelldefine





primitive checkrs   (z, a, b);
    output z;
    input a, b ;
// FUNCTION :  Comparison cell
    table
    //  a    b      :   z
        1    1      :   1 ;
        x    1      :   1 ;
        1    x      :   1 ;
        0    1      :   0 ;
        0    x      :   0 ;
        1    0      :   0 ;
        x    0      :   0 ;
        0    0      :   0 ;
    endtable
endprimitive





primitive u1_fd5  (Q, D, C, RN, SN, NOTIFY);
    output Q;
    input  D, C, RN, SN, NOTIFY;
    reg    Q;

// FUNCTION : POSITIVE EDGE TRIGGERED D FLIP-FLOP WITH 
//            ASYNCHRONOUS ACTIVE LOW SET AND CLEAR.
//            with the correct behavioral if set and reset Low
    table

//  D    C    RN    SN   NTFY : Qt  : Qt+1
// ---- ---- ----- ----- ---- : --- : ----
// data clk  rst_n set_n ntfy : Qi  : Q_out           
// ---- ---- ----- ----- ---- : --- : ----

    *	 ?    1     1	  ?   :  ?  :  -  ; // data changes, clk stable
    ?    n    1     1	  ?   :  ?  :  -  ; // clock falling edge


    1  (0x)   1     ?	  ?   :  1  :  1  ; // possible clk of D=1, but Q=1
    0  (0x)   ?     1	  ?   :  0  :  0  ; // possible clk of D=0, but Q=0

    ?	 ?    1     0	  ?   :  ?  :  1  ; // async set
    ?	 ?    0     ?	  ?   :  ?  :  0  ; // async reset, set 0,1,x

    0  (01)   ?     1	  ?   :  ?  :  0  ; // clocking D=0
    1  (01)   1     ?	  ?   :  ?  :  1  ; // clocking D=1

   					                        // reduced pessimism: 
    ?    ?  (?1)    1     ?   :  ?  :  -  ; // ignore the edges on rst_n
    ?    ?    1   (?1)    ?   :  ?  :  -  ; // ignore the edges on set_n

    1  (x1)   1     ?     ?   :  1  :  1  ; // potential pos_edge clk, potential set_n, but D=1 && Qi=1
    0  (x1)   ?     1     ?   :  0  :  0  ; // potential pos_edge clk, potential rst_n, but D=0 && Qi=0
    ?    ?    ?     ?     *   :  ?  :  x  ; // timing violation

//    1  (1x)   1     ?     ?   :  1  :  1  ; // to_x_edge clk, but D=1 && Qi=1
//    0  (1x)   ?     1     ?   :  0  :  0  ; // to_x_edge clk, but D=0 && Qi=0

`ifdef    ATPG_RUN

    ?	 *    1     0	  ?   :  ?  :  1  ; // clk while async set	      // ATPG
    ?	 *    0     1	  ?   :  ?  :  0  ; // clk while async reset	      // ATPG
    ?	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1		      // ATPG
    ?    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0		      // ATPG

`else
   					    // reduced pessimism: 
    1	 ?    1     x	  ?   :  1  :  1  ; //   set=X, but Q=1    	      // Vlg
    0	 b    1   (0x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
    0	 b    1   (1x)	  ?   :  1  :  1  ; //   set=X, D=0, but Q=1   	      // Vlg
   (??)	 b    1     ?	  ?   :  1  :  1  ; //   set=X, D=egdes, but Q=1      // Vlg
    ?  (?0)   1     x	  ?   :  1  :  1  ; //   set=X, neg_edge clk, but Q=1 // Vlg

    0    ?    x     1	  ?   :  0  :  0  ; // reset=X, but Q=0    	      // Vlg
    1    b  (0x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
    1    b  (1x)    1	  ?   :  0  :  0  ; // reset=X, D=1, but Q=0   	      // Vlg
   (??)  b    ?     1	  ?   :  0  :  0  ; // reset=X, D=egdes, but Q=0      // Vlg
    ?  (?0)   x     1	  ?   :  0  :  0  ; // reset=X, neg_edge clk, but Q=0 // Vlg

 
`endif // ATPG_RUN

    endtable

endprimitive





primitive u_mx2 (Y,D0,D1,S);
          output Y;
          input D0,D1,S;
 
table
     //  D0    D1   S   :  Y ;
          0     ?   0   :  0 ;
          1     ?   0   :  1 ;
          ?     0   1   :  0 ;
          ?     1   1   :  1 ;
          0     0   x   :  0 ;
          1     1   x   :  1 ;
endtable
endprimitive

`timescale 1ns/10ps



module FullCounterStimulus (

output reg CLK, E, R, DU, L,

output reg [7:0] D

);



initial begin



// Inicialización señales.

CLK = 0;

E = 0;

R = 1; //El reset es activo en cero, por eso se inicializa en 1.

DU = 0; //Se empieza en cuenta ascendente para ver.

L = 0;

D = 8'b00000000;



// Reset y Cuenta Ascendente.

#30 R = 0; // Activar reset.

#10 R = 1; //Una vez desactivado el reset, se inicia la cuenta ascendente.



// Carga en Paralelo y Cuenta Descendente.

#50 L = 1; D = 8'b00001111; DU = 1;

#10 L = 0; //Desactivar carga y comenzar conteo descendente



//Stand-By

#50 E = 1;



// Cambiar dirección de conteo

#50 E = 0; DU = 0; // Contar descendente



// Esperar y luego cambiar dirección de conteo nuevamente

#50 DU = 1; // Contar ascendente



// Esperar y dejar Stand-By hasta el final

#50 E = 0;



// Finalizar la simulación

#50 $finish;

end



//Reloj

always begin

#5 CLK = ~CLK;

end



endmodule

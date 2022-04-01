`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:48:12 12/01/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
// starile automatului
`define start 0
`define move 1
`define look 2

module maze (
	input	clk,
	input [maze_width - 1:0] starting_col, starting_row, // indicii punctului de start
	input maze_in, 	  // ofera informatii despre punctul de coordonate [row, col]
	output reg [maze_width - 1:0] row, col, // selecteaza un rand si o coloana din labirint
	output reg maze_oe, // output enable (activeaza citirea din labirint la rândul si coloana date) - semnal sincron	
	output reg maze_we, // write enable (activeaza scrierea in labirint la rândul si coloana date) - semnal sincron
	output reg done	  // iesirea din labirint a fost gasita; semnalul ramane activ 
	);
	
	parameter maze_width = 6; // parametrul necesar dimensionarii variabilelor: valoarea default - 1
	
	// ultima stare e notata cu 2: 2 biti
	reg [1:0] state; // stocheaza starea curenta
	reg [1:0] next_state;	// starea urmatoare
	reg [maze_width - 1:0] prev_row, prev_col; // indicii punctului anterior
	reg [1:0] direction; // directia de deplasare: 
								// 0 - sus, 1 - dreapta, 2 - jos, 3 - stanga
	
	// Partea secventiala
	always @(posedge clk) begin
		if(!done)
			state <= next_state;
	end

	// Partea combinationala
	always @(*) begin
	
		next_state = `start;
		maze_we = 0;
		maze_oe = 0;
		done = 0;
		
		case(state)
			`start: begin
				maze_we = 1; // activez write enable pentru a marca cu 2 pozitia de start
				row = starting_row; // pozitia curenta are indicii punctului de start
				col = starting_col;
				direction = 0; // setez initial directia de deplasare in sus
				next_state = `move;
			end
			  
			`move: begin
				prev_row = row; // realizez o copie a pozitiei curente pentru a o folosi dupa actualizare
				prev_col = col; 
				case(direction) // actualizez pozitia curenta in functie de directie
					0: row = row - 1; // sus
					1: col = col + 1; // dreapta
					2: row = row + 1; // jos
					3: col = col - 1; // stanga
				endcase
				maze_oe = 1; // activez out enable ca sa pot citi in starea care urmeaza
				next_state = `look;
			end
			
			`look: begin
				//verific valoarea de pe pozitia pe care ma aflu
				if(maze_in == 0) begin // culoarul labirintului
					if(row == 0 || row == 63 || col == 0 || col == 63) begin // verific daca sunt la margine
						maze_we = 1; // activez write enable pentru a marca cu 2 ultima pozitie din labirint
						done = 1; // iesirea din labirint
					end else begin // daca nu sunt la margine
						case(direction) // rotire la dreapta pentru urmarirea peretelui drept
							0: direction = 1; // sus: dreapta
							1: direction = 2; // dreapta: jos 
							2: direction = 3; // jos: stanga
							3: direction = 0; // stanga: sus
						endcase
						maze_we = 1; // activez write enable pentru a marca cu 2 pozitia curenta de pe culoar
						next_state = `move;
					end
				end

				if(maze_in == 1) begin // perete
					row = prev_row; // pozitia curenta va lua indicii punctului anterior
					col = prev_col;
					case(direction) // rotire la stanga pentru a ma intoarce din perete pe culoar
						0: direction = 3; // sus: stanga
						1: direction = 0; // dreapta: sus
						2: direction = 1; // jos: dreapta
						3: direction = 2; // stanga: jos
					endcase
					next_state = `move;
				end
			end	
		 endcase
	end
	
endmodule

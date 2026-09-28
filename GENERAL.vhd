library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GENERAL is
    Port (
            CLK      : in  STD_LOGIC;                     -- Reloj de 100 MHz
            RESET    : in  STD_LOGIC;                     -- Reset activo en alto
            RX       : in  STD_LOGIC;                     -- Entrada UART
		    PWM_DC  : out STD_LOGIC;
		    SERVO	  : out STD_LOGIC;
		    BOMBA     : out STD_LOGIC;
		    BOMBA_LED	  : out STD_LOGIC;
		    BOCINA   : out STD_LOGIC;   
		    BOCINA_LED  : out STD_LOGIC;
		    X1      : out STD_LOGIC;                     -- Dirección
            X2      : out STD_LOGIC;
            X1_LED  : out STD_LOGIC;
            X2_LED  : out STD_LOGIC  
    );
end GENERAL;


architecture RTL of GENERAL is

    -- ============================================================
    -- Señales internas entre RX_UART y MAQUINA_RECEPTOR
    -- ============================================================

    signal recibido_uart : STD_LOGIC_VECTOR(7 downto 0);
    signal carga_uart    : STD_LOGIC;
	signal CANAL_0  : STD_LOGIC_VECTOR(7 downto 0);
    signal CANAL_1  : STD_LOGIC_VECTOR(7 downto 0);
    signal CANAL_2  : STD_LOGIC_VECTOR(7 downto 0);
    signal CANAL_3  : STD_LOGIC_VECTOR(7 downto 0);
    signal X1_s     : STD_LOGIC;
    signal X2_s     : STD_LOGIC;
	 
begin

    -- ============================================================
    -- RECEPTOR UART
    -- ============================================================

    U_RX_UART : entity work.RX_UART
        port map (
            CLK      => CLK,
            RESET    => RESET,
            RX       => RX,
            RECIBIDO => recibido_uart,
            ESTATUS  => carga_uart
        );


    -- ============================================================
    -- MÁQUINA RECEPTORA / DEMULTIPLEXOR
    -- ============================================================

    U_MAQUINA_RECEPTOR : entity work.MAQUINA_RECEPTOR
        port map (
            CLK      => CLK,
            RESET    => RESET,

            RECIBIDO => recibido_uart,
            CARGA    => carga_uart,

            CANAL_0  => CANAL_0,
            CANAL_1  => CANAL_1,
            CANAL_2  => CANAL_2,
            CANAL_3  => CANAL_3
        );
	   --ASIGNACIONES DIRECTAS:
        BOMBA <= CANAL_3(0);
        BOMBA_LED <= CANAL_3(0);
        BOCINA <= CANAL_2(0);
        BOCINA_LED <= CANAL_2(0);
	 
		  
CONTROLADOR_MOTOR : entity work.MOTOR_DC
    port map (
				CLK    => CLK,              
				VALOR  => CANAL_0,
				PWM_DC => PWM_DC,
				X1 => X1_s,    
                X2 => X2_s
    );
     --ASIGNACIONES DIRECTAS:
     X1 <= X1_s;
     X1_LED <= X1_s;
     
     X2 <= X2_s;
     X2_LED <= X2_s;
     
    
	 CONTROLADOR_SERVO : entity work.SERVO_PWM
    port map (
        CLK   => CLK, 
        VALOR  => CANAL_1, 
        SERVO  => SERVO 
    );

	 
	

end RTL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GENERAL is
    Port (
        CLK      : in  STD_LOGIC;                     -- Reloj de 100 MHz
        RESET    : in  STD_LOGIC;                     -- Reset activo en alto
        RX       : in  STD_LOGIC;                     -- Entrada UART
		
		  PWM_DC	  : out STD_LOGIC;
		  SERVO	  : out STD_LOGIC;
		  BOMBA	  : out STD_LOGIC;
		  BOCINA	  : out STD_LOGIC;
		  
	       TEST_RECIBIDO : out STD_LOGIC_VECTOR(7 DOWNTO 0)
	       
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
            CANAL_3  => TEST_RECIBIDO
        );
		  
		  
	CONTROLADOR_MOTOR : entity work.MOTOR_DC
    port map (
				CLK    => CLK,              
				VALOR  => CANAL_0,
				PWM_DC => PWM_DC
    );
	 
	 CONTROLADOR_SERVO : entity work.SERVO_PWM
    port map (
        CLK   => CLK, 
        VALOR  => CANAL_1, 
        SERVO  => SERVO 
    );

	 AUDIO_CONT : entity work.COMPARADOR_1
    port map (
        VALOR => CANAL_2, 
        SALIDA => BOCINA
    );
	 
	 BOMBA_CONT : entity work.COMPARADOR_1
    port map (
        VALOR => CANAL_3, 
        SALIDA => BOMBA
    );	 
	 
end RTL;
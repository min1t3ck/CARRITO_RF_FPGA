library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RX_UART is
    Port (
        CLK      : in  STD_LOGIC;                     -- Reloj de 100 MHz
        RESET    : in  STD_LOGIC;                     -- Reset síncrono activo en alto
        RX       : in  STD_LOGIC;                     -- Entrada UART
        RECIBIDO : out STD_LOGIC_VECTOR(7 downto 0);  -- Dato recibido
        ESTATUS  : out STD_LOGIC                      -- Pulso al recibir dato
    );
end RX_UART;

architecture RTL of RX_UART is

    -- ============================================================
    -- Parámetros UART
    -- ============================================================

    constant CLOCK_FREQ : integer := 100_000_000;
    constant BAUD_RATE  : integer := 9_600;

    -- 50 MHz / 9600 = 5208.33
    constant BAUD_COUNT : integer := 10417;

    -- Aproximadamente medio periodo de bit
    constant HALF_BAUD_COUNT : integer := BAUD_COUNT / 2;

    -- ============================================================
    -- Estados de la máquina UART
    -- ============================================================

    type state_type is (
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT
    );

    signal state : state_type := IDLE;

    -- ============================================================
    -- Contadores y registros
    -- ============================================================

    signal baud_counter : integer range 0 to BAUD_COUNT := 0;
    signal bit_counter  : integer range 0 to 7 := 0;

    signal rx_data_temp : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    signal recibido_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal estatus_reg  : STD_LOGIC := '0';

begin

    -- ============================================================
    -- Salidas
    -- ============================================================

    RECIBIDO <= recibido_reg;
    ESTATUS  <= estatus_reg;

    -- ============================================================
    -- Receptor UART
    -- ============================================================

    process(CLK)
    begin

        if rising_edge(CLK) then

            if RESET = '1' then

                state        <= IDLE;
                baud_counter <= 0;
                bit_counter  <= 0;

                rx_data_temp <= (others => '0');

                recibido_reg <= (others => '0');
                estatus_reg  <= '0';

            else

                -- ESTATUS normalmente permanece en bajo.
                -- Solamente se activa durante un ciclo al recibir
                -- completamente un nuevo byte.
                estatus_reg <= '0';

                case state is

                    -- =================================================
                    -- ESPERA DE INICIO
                    -- =================================================

                    when IDLE =>

                        baud_counter <= 0;
                        bit_counter  <= 0;

                        -- UART permanece en '1' cuando está en reposo.
                        -- Un '0' indica el comienzo de una trama.
                        if RX = '0' then

                            state <= START_BIT;
                            baud_counter <= 0;

                        end if;


                    -- =================================================
                    -- VALIDACIÓN DEL BIT DE START
                    -- =================================================

                    when START_BIT =>

                        if baud_counter < HALF_BAUD_COUNT then

                            baud_counter <= baud_counter + 1;

                        else

                            baud_counter <= 0;

                            -- Verificamos nuevamente que el START
                            -- siga siendo '0' en el centro del bit.

                            if RX = '0' then

                                state <= DATA_BITS;
                                bit_counter <= 0;

                            else

                                -- Fue un falso START
                                state <= IDLE;

                            end if;

                        end if;


                    -- =================================================
                    -- RECEPCIÓN DE LOS 8 BITS
                    -- =================================================

                    when DATA_BITS =>

                        if baud_counter < BAUD_COUNT - 1 then

                            baud_counter <= baud_counter + 1;

                        else

                            baud_counter <= 0;

                            -- Se recibe primero el LSB
                            rx_data_temp(bit_counter) <= RX;

                            if bit_counter = 7 then

                                -- Ya se recibieron los 8 bits.
                                state <= STOP_BIT;

                            else

                                bit_counter <= bit_counter + 1;

                            end if;

                        end if;


                    -- =================================================
                    -- BIT DE STOP
                    -- =================================================

                    when STOP_BIT =>

                        if baud_counter < BAUD_COUNT - 1 then

                            baud_counter <= baud_counter + 1;

                        else

                            baud_counter <= 0;

                            -- En este punto la trama está completa.
                            -- Se conserva el byte anterior en RECIBIDO
                            -- hasta que se complete uno nuevo.

                            if RX = '1' then

                                recibido_reg <= rx_data_temp;

                                -- Pulso de un ciclo indicando que
                                -- existe un nuevo dato válido.
                                estatus_reg <= '1';

                            end if;

                            state <= IDLE;

                        end if;

                end case;

            end if;

        end if;

    end process;

end RTL;
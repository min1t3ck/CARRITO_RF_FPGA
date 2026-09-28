library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MOTOR_DC is
    Port (
        CLK    : in  STD_LOGIC;                     -- Reloj de 100 MHz
        VALOR  : in  STD_LOGIC_VECTOR(7 downto 0);  -- Control 0x00 - 0xFF
        PWM_DC : out STD_LOGIC;                     -- Salida PWM
        X1     : out STD_LOGIC;                     -- Dirección
        X2     : out STD_LOGIC                      -- Dirección
    );
end MOTOR_DC;


architecture RTL of MOTOR_DC is

    -- ============================================================
    -- PWM
    -- ============================================================
    -- 100 MHz * 20 ms = 2,000,000 ciclos
    -- Frecuencia PWM = 50 Hz

    constant PWM_PERIOD : integer := 2_000_000;

    signal contador_pwm : integer range 0 to PWM_PERIOD - 1 := 0;

    signal duty_cycles : integer range 0 to PWM_PERIOD := 0;

begin

    -- ============================================================
    -- CONTADOR PWM
    -- ============================================================

    process(CLK)
    begin

        if rising_edge(CLK) then

            if contador_pwm = PWM_PERIOD - 1 then
                contador_pwm <= 0;
            else
                contador_pwm <= contador_pwm + 1;
            end if;

        end if;

    end process;


    -- ============================================================
    -- GENERACIÓN DEL PWM Y DIRECCIÓN
    -- ============================================================

    process(VALOR)
        variable valor_int : integer;
        variable duty_temp : integer;
    begin

        valor_int := to_integer(unsigned(VALOR));

        -- Valores por defecto
        duty_temp := 0;

        X1 <= '0';
        X2 <= '0';


        -- ========================================================
        -- ZONA MUERTA
        -- 0x78 - 0x7F
        -- ========================================================

        if (valor_int >= 16#78#) and
           (valor_int <= 16#7F#) then

            duty_temp := 0;

            X1 <= '0';
            X2 <= '0';


        -- ========================================================
        -- GIRO POSITIVO
        -- 0x80 - 0xFF
        -- ========================================================

        elsif valor_int >= 16#80# then

            X1 <= '1';
            X2 <= '0';

            -- 0x80 = 15%
            -- 0xFF = 100%

            duty_temp :=
                300_000 +
                ((valor_int - 16#80#) * 1_700_000) / 127;


        -- ========================================================
        -- GIRO NEGATIVO
        -- 0x00 - 0x77
        -- ========================================================

        else

            X1 <= '0';
            X2 <= '1';

            -- 0x77 = 15%
            -- 0x00 = 100%

            duty_temp :=
                300_000 +
                ((16#77# - valor_int) * 1_700_000) / 119;

        end if;

        duty_cycles <= duty_temp;

    end process;


    -- ============================================================
    -- COMPARADOR PWM
    -- ============================================================

    process(contador_pwm, duty_cycles)
    begin

        if contador_pwm < duty_cycles then
            PWM_DC <= '1';
        else
            PWM_DC <= '0';
        end if;

    end process;

end RTL;
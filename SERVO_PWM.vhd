library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SERVO_PWM is
    Port (
        CLK   : in  STD_LOGIC;                     -- Reloj de 100 MHz
        VALOR : in  STD_LOGIC_VECTOR(7 downto 0);  -- 0x00 - 0xFF
        SERVO : out STD_LOGIC                      -- Señal para servo
    );
end SERVO_PWM;


architecture RTL of SERVO_PWM is

    -- ============================================================
    -- Parámetros del PWM
    -- ============================================================

    -- Reloj:
    -- 100 MHz = 10 ns por ciclo

    -- Periodo:
    -- 20 ms = 2,000,000 ciclos

    constant PERIODO : integer := 2_000_000;

    -- Tiempo mínimo en alto:
    -- 0.6 ms = 60,000 ciclos

    constant PULSO_MIN : integer := 60_000;

    -- Tiempo máximo en alto:
    -- 1.6 ms = 160,000 ciclos

    constant PULSO_MAX : integer := 160_000;


    -- ============================================================
    -- Contador del periodo
    -- ============================================================

    signal contador : integer range 0 to PERIODO - 1 := 0;

    -- Tiempo calculado que permanecerá en alto
    signal pulso_alto : integer range PULSO_MIN to PULSO_MAX := PULSO_MIN;


begin

    -- ============================================================
    -- Cálculo del tiempo en alto
    -- ============================================================

    process(VALOR)
        variable valor_entero : integer;
        variable pulso_calculado : integer;
    begin

        valor_entero := to_integer(unsigned(VALOR));

        pulso_calculado :=
            PULSO_MIN +
            ((valor_entero * (PULSO_MAX - PULSO_MIN)) / 255);

        pulso_alto <= pulso_calculado;

    end process;


    -- ============================================================
    -- Generación del PWM
    -- ============================================================

    process(CLK)
    begin

        if rising_edge(CLK) then

            if contador = PERIODO - 1 then

                contador <= 0;

            else

                contador <= contador + 1;

            end if;

        end if;

    end process;


    -- ============================================================
    -- Salida PWM
    -- ============================================================

    process(contador, pulso_alto)
    begin

        if contador < pulso_alto then

            SERVO <= '1';

        else

            SERVO <= '0';

        end if;

    end process;

end RTL;